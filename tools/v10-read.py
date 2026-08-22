#!/usr/bin/env python3
"""Read every file in v10/source and record what it says.

	tools/v10-read.py            # read the tree, write v10/source/READ
	tools/v10-read.py --summary  # what the read found
	tools/v10-read.py --man      # the commands the manuals document

READING IS NOT CLASSIFYING.  A classifier asks what a file IS -- source,
header, data -- from its first 512 bytes, and that is enough to count things
and nothing else.  Every gap this plan has had came from deciding a file's
ROLE without reading it: the games nobody built, the pascal command that is a
shell script, lex's ncform, the aliases in cmd/ex's makefile.  Each was sitting
in the tree saying what it was.

So this opens all 54,328 entries and records, per file, what the file itself
states.  Nothing here infers from a build rule; that is the other tool's job
and it is the one that kept being wrong.

WHAT EACH KIND OF FILE SAYS ABOUT ITSELF

	manual    .TH NAME SECTION and the `.SH NAME' line, which lists EVERY
	          name the page documents -- `ls, lc \\(mi list contents of
	          directory' is the tape stating that lc is a second name for
	          ls.  This is the only oracle on the tape that enumerates
	          commands without going through a makefile.
	source    whether it defines main(), what it includes, what it defines
	buildfile its targets and its install lines
	script    its interpreter and whether it looks like a command
	archive   its members, in ORDER
	object    its a.out magic and text size -- an EMPTY object is a real
	          hazard here, since the prebuilt lcc emits them while exiting 0
	data      its first line, which is often a header naming the format
"""

import argparse
import collections
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")
# NOT INSIDE THE TAPE.  Writing the report into v10/source makes the
# tree grow by one entry, so the next run reads 54,329 and the count
# that is supposed to be a constant drifts with its own output.
# JSON LINES, because the plan is generated FROM these facts and a
# human-shaped summary cannot carry an object list.  One record per
# file, every file, no sampling.
OUT = os.path.join(ROOT, "v10", "READ.jsonl")

INC = re.compile(r"^[ \t]*#[ \t]*include[ \t]*([<\"])([^>\"]+)[>\"]", re.M)
MAIN = re.compile(r"^[ \t]*(?:int[ \t]+|void[ \t]+)?main[ \t]*\(", re.M)
DEFINE = re.compile(r"^[ \t]*#[ \t]*define[ \t]+([A-Za-z_][A-Za-z0-9_]*)", re.M)
TH = re.compile(r"^\.TH\s+(\S+)\s+(\S+)", re.M)
SHNAME = re.compile(r"^\.SH\s+NAME\s*\n(.*?)(?=^\.SH|\Z)", re.M | re.S)
RULE = re.compile(r"^([^\s:=#][^:=]*):([^=].*|)$", re.M)

MAGIC_AOUT = (0o407, 0o410, 0o413, 0o405, 0o560)

# A DEFINITION IS A NAME AT COLUMN ZERO FOLLOWED BY A PARAMETER LIST, which is
# K&R C's shape and this whole tape is K&R.  An ANSI prototype ends in `;' and
# is a declaration, not a definition -- counting those would make every header
# look like it defined the world.
DEFN = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)[ \t]*\(([^;{]*)\)[ \t]*"
                  r"(?:\n[^;{]*)?\{", re.M)
CALL = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)[ \t]*\(")
# Not calls.  `if (' and `while (' look exactly like one to a regex.
C_KEYWORDS = {"if", "while", "for", "switch", "return", "sizeof", "do",
              "else", "case", "defined", "struct", "union", "enum", "int",
              "char", "long", "short", "float", "double", "void", "unsigned",
              "signed", "static", "extern", "register", "typedef", "const",
              "volatile", "goto", "break", "continue", "default"}


def read_file(path):
    """Everything this one file states about itself."""
    try:
        with open(path, "rb") as fh:
            raw = fh.read()
    except OSError as e:
        return {"kind": "unreadable", "why": str(e)}
    if not raw:
        return {"kind": "empty", "size": 0}

    f = {"size": len(raw)}
    if raw[:8] == b"!<arch>\n":
        f["kind"] = "archive"
        f["members"] = ar_members(raw)
        return f
    if len(raw) >= 2 and (raw[0] | (raw[1] << 8)) in MAGIC_AOUT:
        f["kind"] = "object"
        f["magic"] = raw[0] | (raw[1] << 8)
        if len(raw) >= 8:
            f["text"] = int.from_bytes(raw[4:8], "little")
            # AN OBJECT FILE IS NOT EVIDENCE THAT A COMPILER RAN.  The tape's
            # prebuilt lcc hands `-undef' to a cpp that rejects it, so cpp
            # writes nothing, rcc compiles the empty file, as assembles a valid
            # EMPTY object, and lcc exits 0.  A zero text size is the tell.
            f["empty_text"] = (f["text"] == 0)
        return f
    if b"\0" in raw[:512]:
        f["kind"] = "binary"
        return f

    try:
        text = raw.decode("utf-8", "replace")
    except Exception:
        f["kind"] = "binary"
        return f
    f["kind"] = "text"
    f["lines"] = text.count("\n") + 1
    f["first"] = text.split("\n", 1)[0][:200]

    name = os.path.basename(path)
    if text.startswith("#!"):
        f["interp"] = f["first"][2:].strip()

    # -- a manual page names every command it documents
    th = TH.search(text)
    if th or re.match(r"^.*\.[0-9][a-z]?$", name):
        f["kind"] = "manual"
        if th:
            f["man"] = th.group(1).lower()
            f["section"] = th.group(2)
        sh = SHNAME.search(text)
        if sh:
            f["names"] = man_names(sh.group(1))
            f["desc"] = man_desc(sh.group(1))
        return f

    # -- source
    if name.endswith((".c", ".y", ".l", ".s", ".g", ".lex", ".e", ".f")):
        f["kind"] = "source"
        f["main"] = bool(MAIN.search(text))
        f["includes"] = [(b, h) for b, h in INC.findall(text)]
        # WHAT THIS FILE DEFINES AND WHAT IT CALLS.  This is the difference
        # between reading a file and looking at it: a program's object list and
        # its -l flags are DERIVABLE from the source, and deriving them is the
        # only way to build a command whose makefile is missing, wrong, or
        # written for another machine -- which on this tape is common.  The
        # tape's own makefiles name libraries that exist nowhere in it
        # (-lbsd, -lport, -lsocket), so they cannot be the authority either.
        f["defines_fn"] = sorted(set(DEFN.findall(text)))
        called = set(CALL.findall(text))
        f["calls"] = sorted(called - set(f["defines_fn"]) - C_KEYWORDS)
        return f
    if name.endswith((".h", ".def")):
        f["kind"] = "header"
        f["defines"] = DEFINE.findall(text)[:40]
        f["includes"] = [(b, h) for b, h in INC.findall(text)]
        return f
    if name in ("makefile", "Makefile", "mkfile", "MAKEFILE"):
        f["kind"] = "buildfile"
        f["targets"] = [m.group(1).strip() for m in RULE.finditer(text)][:60]
        f["installs"] = [l.strip() for l in text.split("\n")
                         if re.search(r"^\t.*\b(cp|mv|ln)\b", l)][:40]
        return f
    if "interp" in f or name.endswith(".sh"):
        f["kind"] = "script"
        f["cmdish"] = bool(re.search(r"\$[0-9*@]|\bexec\b|\bcase\b", text))
        return f

    # -- A TEXT FILE STILL SAYS WHAT IT IS, and discarding that is how 6,072
    # files came to be READ and then have no verdict.  These are the tape's
    # data: troff macro packages, terminal descriptions, dictionaries, fonts,
    # tables and READMEs.  What they say about themselves:
    f["form"] = text_form(name, text)
    return f


ROFF = re.compile(r"^\.(?:de|ds|nr|so|TH|SH|PP|if|ie|tr|na|ad)\b", re.M)
TERMCAP = re.compile(r"^[a-z0-9|.-]+:\\?\s*$", re.M)
CFRAG = re.compile(r"^[ \t]*(?:#\s*(?:define|include|ifdef)|struct\s|"
                   r"static\s|extern\s)", re.M)


def text_form(name, text):
    """What a text file states it is, read from its content.

    The tape's data is not labelled by suffix -- tmac.an has no extension that
    says `troff macros', and a terminal description looks like nothing else.
    Reading is what tells them apart, and the verdict a file gets depends on
    it: a macro package is INSTALLED beside troff, a README is not.
    """
    head = text[:4000]
    low = name.lower()
    if ROFF.search(head):
        return "roff"
    if low.startswith(("readme", "read.me")) or low == "notes":
        return "readme"
    if low.startswith("makefile") or low.startswith("mkfile"):
        return "buildfile"
    if TERMCAP.search(head) and ":" in head and "\\" in head:
        return "termcap"
    if CFRAG.search(head):
        return "cfragment"
    if re.match(r"^[0-9]+\s", head) or re.match(r"^[A-Za-z]+\t", head):
        return "table"
    if all(len(l) < 40 for l in head.split("\n")[:30] if l.strip()):
        return "wordlist"
    return "text"


def man_names(block):
    """Every name a manual's NAME section documents.

    `ls, lc \\(mi list contents of directory' documents TWO commands, and the
    second is a name no makefile mentions.  The separator is roff's \\(mi (a
    minus sign), sometimes a literal - or \\-.
    """
    line = " ".join(l.strip() for l in block.strip().split("\n")
                    if not l.startswith("."))
    head = re.split(r"\\\(mi|\\-|\s+-\s+|\s+\\\(em\s+", line, 1)[0]
    out = []
    for w in head.split(","):
        w = w.strip().strip(".").strip()
        if w and re.match(r"^[A-Za-z0-9_][A-Za-z0-9_.+=-]*$", w):
            out.append(w)
    return out


def man_desc(block):
    """The English a manual page gives itself.

    `ls, lc \\(mi list contents of directory' -- everything after the roff
    minus sign IS the description, written by the people who wrote the
    program.  It is the only prose on the tape that says what a command does,
    and it is better than anything a scanner could infer.
    """
    line = " ".join(l.strip() for l in block.strip().split("\n")
                    if not l.startswith("."))
    parts = re.split(r"\\\(mi|\\-|\s+-\s+|\s+\\\(em\s+", line, maxsplit=1)
    if len(parts) < 2:
        return ""
    d = re.sub(r"\\f[A-Z0-9]|\\&|\\\(\w\w", "", parts[1]).strip()
    return re.sub(r"\s+", " ", d)[:150]


def ar_members(raw):
    """Member names IN ORDER -- a directory listing cannot hold order."""
    out, off = [], 8
    while off + 60 <= len(raw):
        h = raw[off:off + 60]
        if h[58:60] != b"`\n":
            break
        nm = h[0:16].decode("ascii", "replace").strip().rstrip("/")
        try:
            sz = int(h[48:58].decode("ascii", "replace").strip())
        except ValueError:
            break
        if nm and nm != "__.SYMDEF":
            out.append(nm)
        off += 60 + sz + (sz & 1)
    return out


def walk():
    """Every entry, symlinks counted and symlinked directories not followed."""
    out, stack, seen = [], [TREE], set()
    while stack:
        dp = stack.pop()
        real = os.path.realpath(dp)
        if real in seen:
            continue
        seen.add(real)
        try:
            entries = sorted(os.scandir(dp), key=lambda e: e.name)
        except OSError:
            continue
        for e in entries:
            rel = os.path.relpath(e.path, TREE)
            if e.is_symlink():
                out.append((rel, e.path, "link"))
            elif e.is_dir():
                stack.append(e.path)
            else:
                out.append((rel, e.path, "file"))
    return out


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--summary", action="store_true")
    ap.add_argument("--man", action="store_true")
    a = ap.parse_args(argv)

    entries = walk()
    print("v10-read: reading %d entries ..." % len(entries), file=sys.stderr)

    facts = {}
    kinds = collections.Counter()
    for rel, path, how in entries:
        if how == "link" and not os.path.exists(path):
            facts[rel] = {"kind": "broken-link"}
            kinds["broken-link"] += 1
            continue
        if how == "link" and os.path.isdir(path):
            facts[rel] = {"kind": "link-dir"}
            kinds["link-dir"] += 1
            continue
        f = read_file(path)
        facts[rel] = f
        kinds[f["kind"]] += 1

    if len(facts) != len(entries):
        sys.exit("v10-read: read %d of %d -- refusing to report"
                 % (len(facts), len(entries)))

    print("v10-read: %d entries READ (not sampled)" % len(facts))
    for k, v in kinds.most_common():
        print("   %-12s %6d" % (k, v))

    # -- what the manuals document
    cmds = collections.defaultdict(set)
    for rel, f in facts.items():
        if f.get("kind") != "manual":
            continue
        sec = str(f.get("section", "")).strip()
        for n in f.get("names", []):
            cmds[sec].add(n)
    print("\n   commands NAMED BY THE MANUALS, by section:")
    for sec in sorted(cmds, key=lambda x: (len(x), x)):
        print("      section %-4s %4d names" % (sec or "?", len(cmds[sec])))

    if a.man:
        for sec in sorted(cmds, key=lambda x: (len(x), x)):
            print("\n== section %s ==" % (sec or "?"))
            print("   " + " ".join(sorted(cmds[sec])))
        return 0

    # -- objects that are EMPTY, which is a hazard not a curiosity
    empty = [r for r, f in facts.items() if f.get("empty_text")]
    print("\n   objects with ZERO text (an lcc hazard): %d" % len(empty))

    # -- files stating a main()
    mains = [r for r, f in facts.items() if f.get("main")]
    print("   sources defining main(): %d" % len(mains))

    with open(OUT, "w") as fh:
        for rel in sorted(facts):
            f = dict(facts[rel])
            f["path"] = rel
            fh.write(json.dumps(f, sort_keys=True) + "\n")
    print("\n   -> %s" % os.path.relpath(OUT, ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
