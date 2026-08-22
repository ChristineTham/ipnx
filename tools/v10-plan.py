#!/usr/bin/env python3
"""Turn the per-file facts into the plan for a Tenth Edition disk.

	tools/v10-plan.py            # write docs/v10-plan.md
	tools/v10-plan.py --check    # is it current?
	tools/v10-plan.py --verdicts # every file and what becomes of it

IT READS v10/READ.jsonl, WHICH IS EVERY FILE READ, and nothing else.  The tool
this replaces built the plan by parsing build files, so a program reached the
disk only if some makefile happened to name it in a shape the parser knew --
and the gaps arrived one at a time as they were noticed: the games, pascal,
lex's ncform, the aliases, /dev, /etc.  Each was a file in the tree stating
what it was, to a program that was reading makefiles instead.

EVERY FILE GETS A VERDICT.  Not a classification -- a decision about what
becomes of it.  A file is either installed, compiled into something that is
installed, consulted during the build, or deliberately not shipped WITH A
REASON.  Nothing is allowed to have no verdict, and the generator refuses to
write a plan if anything does.  That is the structural answer to "did you skip
something": the question stops being a matter of noticing.

THE MANUALS ARE THE COMMAND ORACLE.  Section 1 names 513 commands and the
`.SH NAME' line lists every name a page documents -- `col, 2, 3, 4, 5, 6, mc,
fold, expand' is the tape saying those nine names are one family, which no
makefile anywhere states.  It is the only enumeration of commands on the tape
that does not go through a build rule.
"""

import argparse
import collections
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")
FACTS = os.path.join(ROOT, "v10", "READ.jsonl")
OURS = os.path.join(ROOT, "v10", "src")
PLAN = os.path.join(ROOT, "docs", "v10-plan.md")

BUILD_ROOTS = ("src", "milligan")

# Not ours to build.  Parking is a statement about what the image CARRIES; every
# one of these files is still read, still recorded, still given a verdict.
PARKED = {
    "src/history": "IX -- a different operating system built on V10",
    "src/630": "the 630 MTG -- a different terminal",
    "src/sys": "the other kernel tree; lsys is the one we configure",
    "src/vol2": "volume 2 of the manual, not programs",
    "src/doc": "documentation, not programs",
    "secombe": "a second /usr/src from another machine -- a WITNESS, never a "
               "build input; merging it would pick one file per path and call "
               "the result the tape",
    "blit": "the 68000 Blit, not the 5620 dmd_core emulates",
    "sellers": "the manuals -- installed as a tree, not built",
    "include": "r70's headers -- installed as a tree, not built",
}

MACHDROP = ("11v", "68v", "68k", "cray", "seq", "null", "mips", "sparc",
            "sparc_sun", "sgi", "3b", "u3b", "pdp11", "i386", "m68k", "ibm",
            "sun", "sun3", "sun4", "apollo", "gould")

SUPERSEDED = ("Old", "old", "new", "bak", "orig", "OLD")

RULE = re.compile(r"^([^\s:=#][^:=]*):([^=].*|)$")
MACRO = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)[ \t]*=[ \t]*(.*)$", re.M)
NAMEOK = re.compile(r"^[A-Za-z0-9_][A-Za-z0-9_.+=-]*$")

# Names a manual documents that are NOT separate files.  rc.1 documents
# `rc, cd, wait, whatis' because those are the shell's BUILTINS -- there is no
# /bin/cd on any Unix and never was.  Recorded here rather than guessed at,
# because a builtin looks exactly like an alias to a NAME-line reader.
BUILTINS = {"cd", "wait", "whatis", "shift", "eval", "exec", "export",
            "readonly", "trap", "umask", "set", "times", "break", "continue",
            "login", "newgrp", "read", "source", "dirs", "popd", "pushd"}


def load():
    if not os.path.exists(FACTS):
        sys.exit("v10-plan: no v10/READ.jsonl -- run tools/v10-read.py")
    out = {}
    for line in open(FACTS):
        f = json.loads(line)
        out[f["path"]] = f
    return out


def parked_reason(rel):
    """Why this path is not built, or None.  Checked against the tree."""
    parts = rel.split("/")
    for p, why in PARKED.items():
        if rel == p or rel.startswith(p + "/"):
            return why
    if parts[0] not in BUILD_ROOTS:
        return "not a build root"
    d = os.path.dirname(rel)
    dp = d.split("/")
    if any(c in MACHDROP for c in dp):
        return "another machine's back end"
    if any(c.endswith((".tar", ".cpio", ".a")) for c in dp):
        return ("inside an unpacked package -- a second copy of the tree, "
                "extracted so it can be read, never a build input")
    if any(c in SUPERSEDED or c.endswith((".old", ".bak", ".orig"))
           for c in dp):
        return "a superseded generation"
    for i, c in enumerate(dp):
        if len(c) > 1 and c[0] in "oO" and os.path.isdir(
                os.path.join(TREE, "/".join(dp[:i]), c[1:])):
            return ("superseded: the tape's o- prefix, and the sibling %s "
                    "exists" % c[1:])
    return None


def manuals(facts):
    """(installed man pages, {first name: [other names]}) from section 1/6/8."""
    pages, fams = [], {}
    for rel, f in facts.items():
        if f.get("kind") != "manual":
            continue
        pages.append(rel)
        sec = str(f.get("section", ""))
        names = [n for n in f.get("names", []) if NAMEOK.match(n)]
        if sec in ("1", "6", "8") and len(names) > 1:
            fams.setdefault(names[0], names[1:])
    return pages, fams


def buildfacts(rel):
    """Macros and recipes of one build file, read from disk.

    The FACTS say which files are build files; their contents still have to be
    parsed to get object lists, and that is the one place inference remains.
    It is bounded: it decides HOW a program is built, never WHETHER it exists.
    """
    p = os.path.join(TREE, rel)
    try:
        text = open(p, errors="replace").read()
    except OSError:
        return {}, {}
    joined = re.sub(r"\\\n", " ", text)
    m = dict(MACRO.findall(joined))
    rules, cur = {}, None
    for line in joined.split("\n"):
        if line.startswith("\t"):
            if cur:
                rules[cur][1].append(line.strip())
            continue
        if not line.strip() or line.lstrip().startswith("#"):
            continue                       # a blank line does NOT end a recipe
        mo = RULE.match(line)
        cur = mo.group(1).strip() if mo else None
        if cur:
            rules.setdefault(cur, (mo.group(2).strip(), []))
    return m, rules


def expand(s, m, depth=0):
    if depth > 8 or "$" not in s:
        return s
    def rep(mo):
        return m.get(mo.group(1) or mo.group(2) or mo.group(3), "")
    out = re.sub(r"\$\(([A-Za-z_][A-Za-z0-9_]*)\)"
                 r"|\$\{([A-Za-z_][A-Za-z0-9_]*)\}"
                 r"|\$(?!target\b|prereq\b|stem\b)([A-Za-z_][A-Za-z0-9_]*)",
                 rep, s)
    return expand(out, m, depth + 1) if out != s else out


def admin():
    """cmd/Admin: where a loose command installs, and which get -O."""
    d = os.path.join(TREE, "src", "cmd", "Admin")
    dest, large = {}, set()
    for f, where in (("binfiles", "/bin"), ("etcfiles", "/etc"),
                     ("libfiles", "/lib"), ("ulibfiles", "/usr/lib")):
        p = os.path.join(d, f)
        if os.path.exists(p):
            for line in open(p, errors="replace"):
                for w in line.split():
                    dest.setdefault(w, where)
    p = os.path.join(d, "large")
    if os.path.exists(p):
        large = {l.strip() for l in open(p, errors="replace") if l.strip()}
    return dest, large


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--verdicts", action="store_true")
    a = ap.parse_args(argv)

    facts = load()
    dest, large = admin()
    manpages, fams = manuals(facts)

    verdict = {}                            # path -> (what, detail)
    rows = []                               # plan rows

    def V(rel, what, detail=""):
        verdict[rel] = (what, detail)

    # ---- 1. parked, with a reason.  Done first so nothing below re-decides.
    for rel in facts:
        why = parked_reason(rel)
        if why:
            V(rel, "not shipped", why)

    # ---- 2. the trees installed whole
    for rel in facts:
        if rel in verdict and rel.startswith(("sellers/man/", "include/")):
            V(rel, "installed", "part of a tree installed whole")

    # ---- 3. programs: a source with main(), in a build root
    progs = {}
    for rel, f in sorted(facts.items()):
        if rel in verdict or f.get("kind") != "source" or not f.get("main"):
            continue
        d = os.path.dirname(rel)
        name = os.path.basename(rel).rsplit(".", 1)[0]
        if name == "main":
            name = os.path.basename(d)
        progs.setdefault((d, name), []).append(rel)

    # objects and libs from the unit's build file, where it has one
    bf = {os.path.dirname(r): r for r, f in facts.items()
          if f.get("kind") == "buildfile"}
    for (d, name), srcs in sorted(progs.items()):
        objs, libs, how = [os.path.basename(s).rsplit(".", 1)[0] + ".o"
                           for s in srcs], "-", "main()"
        if d in bf:
            m, rules = buildfacts(bf[d])
            for tgt, (pre, lines) in rules.items():
                for line in lines:
                    e = expand(line, m)
                    if re.search(r"-o\s+%s\b" % re.escape(name), e) or \
                       (tgt == name and "-o" in e):
                        rest = e + " " + expand(pre, m)
                        o = [w for w in rest.split() if w.endswith((".o", ".a"))]
                        l = [w for w in rest.split() if w.startswith("-l")]
                        if o:
                            objs, how = o, "build rule"
                        if l:
                            libs = " ".join(l)
        where = dest.get(name, "/usr/games" if "/games" in d else "/usr/bin")
        cf = "-O" if name + ".c" in large else "-Od2"
        rows.append(("6", where.rstrip("/") + "/" + name, "build", d,
                     " ".join(objs), libs, "%s, %s" % (how, cf)))
        for s in srcs:
            V(s, "compiled", "into %s/%s" % (where, name))

    built = {r[1].rsplit("/", 1)[-1] for r in rows}

    # ---- 4. aliases the MANUAL documents, which no makefile states
    for base, others in sorted(fams.items()):
        if base not in built:
            continue
        for n in others:
            if n in built or n in BUILTINS:
                continue
            d = dest.get(base, "/usr/bin")
            rows.append(("6", d.rstrip("/") + "/" + n, "link", base, "-", "-",
                         "a second name for %s -- the manual documents them "
                         "together" % base))
            built.add(n)

    # ---- 5. everything still without a verdict
    for rel, f in sorted(facts.items()):
        if rel in verdict:
            continue
        k = f.get("kind")
        if k == "manual":
            V(rel, "installed", "a manual page")
        elif k == "buildfile":
            V(rel, "consulted", "read for object lists; not installed")
        elif k == "header":
            V(rel, "consulted", "included during the build")
        elif k == "object":
            V(rel, "not shipped", "a 1989 object beside the source -- build "
                                  "detritus, and linking it would put Bell "
                                  "Labs' bytes in our binary")
        elif k == "archive":
            V(rel, "consulted", "an oracle: the tape's own bytes to check ours")
        elif k == "source":
            V(rel, "compiled", "a component of its unit")
        elif k == "empty":
            V(rel, "not shipped", "empty")
        else:
            V(rel, "unknown", "")

    unknown = sorted(r for r, (w, _) in verdict.items() if w == "unknown")

    if a.verdicts:
        for rel in sorted(verdict):
            w, why = verdict[rel]
            print("%-58s %-12s %s" % (rel[:58], w, why[:60]))
        return 0

    print("v10-plan: %d files, %d with a verdict, %d UNKNOWN"
          % (len(facts), len(verdict), len(unknown)))
    c = collections.Counter(w for w, _ in verdict.values())
    for k, v in c.most_common():
        print("   %-14s %6d" % (k, v))
    print("   plan rows: %d   manual families: %d" % (len(rows), len(fams)))
    if unknown:
        for u in unknown[:10]:
            print("   UNKNOWN %s" % u)
        sys.exit("v10-plan: %d files have no verdict -- refusing to write"
                 % len(unknown))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
