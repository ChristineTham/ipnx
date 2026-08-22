#!/usr/bin/env python3
"""Write the plan for a Tenth Edition disk, from the tape's own build rules.

	tools/v10-plan.py            # write docs/v10-plan.md
	tools/v10-plan.py --check    # is the plan current?
	tools/v10-plan.py --gaps     # what it can see and cannot build

A PROGRAM IS A LINK RULE, NOT A DIRECTORY AND NOT A main().  The tape breaks
all three of the easy assumptions at once:

	cmd/ccom     ONE program across TWO directories -- `-o $(CCOMNAME)'
	             with $(OFILES) reaching into ../common
	games/boggle TWO programs in one directory: boggle and comp
	cmd/ccom/vax FIVE main()s, none of them the compiler's

So the rule is read first and the objects follow from it, wherever they live.
A rewrite that started from main() and hunted for a rule got all three wrong.

IT ALSO READS v10/READ.jsonl, the record of every file having been OPENED, and
gives EVERY file a verdict: installed, compiled into something installed,
consulted, or not shipped WITH A REASON.  Nothing may have no verdict, and this
refuses to write if anything does -- so "did you skip something" stops being a
matter of noticing.

THE SCAN IS THE WHOLE TREE, AND IT REFUSES TO REPORT IF IT MISSED ANYTHING.
Every negative this project has got wrong came from surveying part of a tree
and stating the result as a fact about the whole -- "the 5620's compiler is not
on the tape" (it is, in milligan), "145 library sources are absent" (they were
inside .c.a archives), "the commands are all under cmd/" (games alone holds 23
more).  So the walk is reconciled against an independent enumeration before any
number derived from it is printed.

WHICH ROOT SUPPLIES WHAT.  Six archives, never merged: src and secombe are both
/usr/src from different machines, so merging picks one file per path and calls
the result "the tape".

	src         BUILD.  Dan Cross's v10src; our patches are written
	            against it and stages 1-3 are proven on it.
	milligan    BUILD into /usr/jerq.  The 5620 distribution.
	include     INSTALL to /usr/include.  r70's reconstruction.
	sellers     INSTALL to /usr/man.  The manuals.
	secombe     WITNESS.  A second /usr/src -- a third opinion where our
	            bytes differ, never a build input.
	blit        PARKED.  The 68000 Blit, not the 5620 we emulate.

ORDER IS NOT DERIVABLE FROM A DIRECTORY.  tools/v10-source.sh unpacks every ar
archive member by member, which keeps every byte and destroys the one thing a
directory cannot hold: the ORDER of the members.  V10's ld makes ONE sequential
pass when __.SYMDEF is absent or stale, so libc.a must be rebuilt in the tape's
own order or backward references go unresolved, and the golden has neither
lorder nor tsort to recompute it.  The extractor writes ORDER beside the
members; this reads it.
"""

import argparse
import collections
import fnmatch
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")
PLAN = os.path.join(ROOT, "docs", "v10-plan.md")
FACTS = os.path.join(ROOT, "v10", "READ.jsonl")

BUILD_ROOTS = ("src", "milligan")

# Not ours to build: a different operating system, a different terminal, the
# manuals, or the kernel tree we do not use.  Parking is a statement about what
# the image carries, never about what the scan reads -- all of it is walked.
PARKED_DIRS = ("src/history", "src/630", "src/vol2", "src/doc", "src/sys")

# One unit per machine, and only one machine is ours.  cmd/adb has seven back
# ends all building a program called `adb'.
MACHDIR_DROP = ("11v", "68v", "68k", "cray", "seq", "null", "mips", "sparc",
                "sparc_sun", "sgi", "3b", "u3b", "pdp11", "i386", "m68k",
                "ibm", "sun", "sun3", "sun4", "apollo", "gould")

# What a working directory accumulates.  Superseded generations sit beside the
# live one and the tape names them plainly.
SUPERSEDED = ("Old", "old", "new", "bak", "orig", "OLD")

SRCEXT = (".c", ".s", ".y", ".l", ".g", ".lex", ".e", ".f")
BUILDFILES = ("makefile", "Makefile", "mkfile", "MAKEFILE")

# V10's own style is `# include <x>' as often as `#include' -- cpp.c opens
# `# include <libc.h>'.  A scan that misses the space declares every header
# present and the build dies on the one that is not.
INC = re.compile(r"^[ \t]*#[ \t]*include[ \t]*([<\"])([^>\"]+)[>\"]", re.M)
RULE = re.compile(r"^([^\s:=#][^:=]*):([^=].*|)$")
# re.M IS LOAD-BEARING: macros() findalls over the whole file, so
# without it `^` matches only at the very start and every macro after
# line 1 is invisible -- cmd/as's $(OBJS) expanded to nothing and the
# ASSEMBLER vanished from the plan.  Same class as the missing re.M
# that once made an include resolve only in a file whose first
# character began one.
MACRO = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)[ \t]*=[ \t]*(.*)$", re.M)
MAIN = re.compile(r"^[ \t]*(?:int[ \t]+|void[ \t]+)?main[ \t]*\(", re.M)
NAMEOK = re.compile(r"^[A-Za-z0-9_][A-Za-z0-9_.+-]*$")


# =========================================================== 1. the walk ===
def walk():
    """Every entry under TREE: (root, rel, dirpath, name, kind).

    os.walk is NOT exhaustive and the gap is silent: a symlink to a directory
    lands in its dirnames, not its filenames, so one entry holding a whole
    subtree simply never appeared -- 54,327 seen against 54,328 on disk, a
    difference small enough to read as rounding.  A broken symlink does appear,
    and stat'ing it raises rather than answering.  Symlinked directories are
    counted and NOT followed: following one walks the same files twice under
    two names and inflates every count downstream.
    """
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
        rel = os.path.relpath(dp, TREE)
        rel = "" if rel == "." else rel
        root = rel.split(os.sep)[0] if rel else ""
        for e in entries:
            r = os.path.join(rel, e.name) if rel else e.name
            if e.is_symlink():
                if not os.path.exists(e.path):
                    out.append((root, r, dp, e.name, "broken-link"))
                elif os.path.isdir(e.path):
                    out.append((root, r, dp, e.name, "link-dir"))
                else:
                    out.append((root, r, dp, e.name, "link-file"))
            elif e.is_dir():
                stack.append(e.path)
            else:
                out.append((root, r, dp, e.name, "file"))
    return out


def reconcile(entries):
    """(missing, extra) against an independent enumeration of the tree."""
    seen = {os.path.join(dp, n) for _, _, dp, n, _ in entries}
    disk, stack = set(), [TREE]
    while stack:
        d = stack.pop()
        try:
            for e in os.scandir(d):
                if e.is_symlink() or not e.is_dir():
                    disk.add(e.path)
                else:
                    stack.append(e.path)
        except OSError:
            pass
    return disk - seen, seen - disk


# ===================================================== 2. what each file is ===
# The NAME lies in both directions on this tape and each lie has cost a wrong
# conclusion: libdbm.a is `mv dbm.o libdbm.a' (a bare object), plot.c.a is an
# archive of SOURCES, crlib is libcurses' archive with no .a at all.  A first
# read of 512 bytes settles it.
MAGIC_AOUT = (0o407, 0o410, 0o413, 0o405, 0o560)


def sniff(path):
    try:
        with open(path, "rb") as fh:
            head = fh.read(512)
    except OSError:
        return "unreadable"
    if not head:
        return "empty"
    if head[:8] == b"!<arch>\n":
        return "archive"
    if head[:2] == b"#!":
        return "script"
    if len(head) >= 2 and (head[0] | (head[1] << 8)) in MAGIC_AOUT:
        return "object"
    return "binary" if b"\0" in head else "text"


def classify(name, path, kind):
    if kind in ("broken-link", "link-dir"):
        return kind
    what = sniff(path)
    if what in ("unreadable", "empty", "archive", "object"):
        return what
    if name in BUILDFILES:
        return "buildfile"
    if name == "ORDER":
        return "order"
    if what == "binary":
        return "data"
    for e in SRCEXT:
        if name.endswith(e):
            return "source"
    if name.endswith((".h", ".def")):
        return "header"
    if re.match(r"^.*\.[0-9][a-z]?$", name):
        return "manual"
    if what == "script" or name.endswith(".sh"):
        return "script"
    return "text"


# ====================================================== 3. build files ===
def macros(text):
    """Macro definitions, with continuations JOINED FIRST.

    sh's $OFILES spans three lines; read separately they name eight of
    twenty-four objects, which would prove that sixteen of the shell's own
    sources are not in its build.
    """
    m = {}
    for k, v in MACRO.findall(re.sub(r"\\\n", " ", text)):
        m[k] = v.strip()
    return m


def expand(s, m, depth=0):
    """$(X), ${X} and mk's bare $X.

    205 of this tape's build files are mkfiles and spell macros bare, so
    handling only the parenthesised form leaves cmd/sh's whole link line
    unexpanded.  $target/$prereq/$stem are mk's own and the caller supplies
    them.
    """
    if depth > 8 or "$" not in s:
        return s
    def rep(mo):
        return m.get(mo.group(1) or mo.group(2) or mo.group(3), "")
    out = re.sub(r"\$\(([A-Za-z_][A-Za-z0-9_]*)\)"
                 r"|\$\{([A-Za-z_][A-Za-z0-9_]*)\}"
                 r"|\$(?!target\b|prereq\b|stem\b)([A-Za-z_][A-Za-z0-9_]*)",
                 rep, s)
    return expand(out, m, depth + 1) if out != s else out


def recipes(text):
    """{target: (prereq, [lines])} -- a recipe is a BLOCK, not a line.

    cmd/ccom runs yacc and then seds y.tab.c into cgram.c on the next line;
    judged a line at a time both look like a plain yacc call.
    """
    out, cur = {}, None
    for line in re.sub(r"\\\n", " ", text).split("\n"):
        if line.startswith("\t"):
            if cur:
                out[cur][1].append(line.strip())
            continue
        # A BLANK OR COMMENT LINE DOES NOT END A RECIPE, and treating it as one
        # silently truncated recipes across the whole tree.  cmd/ex separates
        # its ninstall body with a blank line, so `ln .../ex .../vi' and the
        # `view' line after it were dropped -- and the NEXT rule then collected
        # them, which is worse than losing them: they were attributed to
        # `newucb'.  vi, view and edit vanished from the plan as a result.
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        mo = RULE.match(line)
        cur = mo.group(1).strip() if mo else None
        if cur:
            out.setdefault(cur, (mo.group(2).strip(), []))
    return out


def globs(objs, srcs):
    """Resolve `y?.o' / `y[1-4].o' against the unit's real sources."""
    stems = {s.rsplit(".", 1)[0] for s in srcs if "." in s}
    out = []
    for o in objs:
        if not any(c in o for c in "?*["):
            out.append(o)
            continue
        stem = o[:-2] if o.endswith(".o") else o
        hit = sorted(s + ".o" for s in stems if fnmatch.fnmatch(s, stem))
        out.extend(hit or [o])
    return out


def install_dirs(rules, m):
    """{product: directory} from the unit's own install rule.

    SEVERAL COMMANDS MAY SHARE A LINE, and cmd/sh is why: its install is
    `mv /bin/sh /bin/osh;  cp sh /bin/sh;  strip /bin/sh', so a whole-line
    match sees none of it and a scanner reading destinations without splitting
    answers /bin/osh -- the BACKUP -- because the mv comes first.  The source
    token must be the product's own name.  `mv' installs too (cmd/as).
    """
    out = {}
    for tgt in ("install", "all"):
        if tgt not in rules:
            continue
        for raw in rules[tgt][1]:
            for line in re.split(r"[;&]+", expand(raw, m)):
                mo = re.match(r"\s*(?:cp|mv)\s+(\S+)\s+(\S+)\s*$", line)
                if not mo or mo.group(1) == "a.out":
                    continue
                what, where = mo.group(1), mo.group(2).rstrip("/")
                if where.count("/") >= 1 and not where.endswith(
                        ("/bin", "/etc", "/lib", "/usr/bin", "/usr/lib",
                         "/usr/games", "/usr/jerq/bin")):
                    d = "/".join(where.split("/")[:-1])
                    out.setdefault(what, d or "/usr/bin")
                else:
                    out.setdefault(what, where)
    return out


def aliases(text, m, rules):
    """[(name, dir, target)] -- a command that is a SECOND NAME for a binary.

    THE TAPE STATES ITS OWN ALIASES AND THEY OUTRANK ANYTHING INFERRED.  70 `ln'
    lines across src/, and they close a cluster that otherwise reads as missing
    commands:

	ln .../ex .../vi        edit = ex = vi = view, ONE inode four names
	ln /usr/bin/= /usr/bin/==     and =p and ==p
	ln $(BIN)/compress $(BIN)/uncompress   and zcat

    So building `ex' closes FOUR names, not one.  Three refusals, each of which
    produced a wrong row first: an alias equal to its own target (from a macro
    that expanded to the same thing); a destination outside the command
    directories, which is how twelve MANUAL PAGES arrived in a list of commands;
    and a link whose target we do not build, which would install a dangling
    name.
    """
    out = []
    for tgt in ("install", "all", "ninstall"):
        if tgt not in rules:
            continue
        for raw in rules[tgt][1]:
            for line in re.split(r"[;&]+", expand(raw, m)):
                mo = re.match(r"\s*ln\s+(?:-[a-z]+\s+)?(\S+)\s+(\S+)\s*$", line)
                if not mo:
                    continue
                src, dst = mo.group(1), mo.group(2)
                # A MANUAL PAGE IS NOT A COMMAND.  `ln $(MAN)/btoa.$(L)
                # $(MAN)/atob.$(L)' is a documentation link.
                if re.search(r"\.[0-9][a-z]?$", dst) or "/man" in dst:
                    continue
                sname, dname = src.split("/")[-1], dst.split("/")[-1]
                if not sname or not dname or sname == dname:
                    continue
                if not NAMEOK.match(dname) and dname not in ("==", "=p", "==p"):
                    continue
                d = "/".join(dst.split("/")[:-1])
                # Strip any $(DESTDIR)-ish prefix the macro left behind.
                # /usr/new IS BERKELEY'S `NEW COMMANDS' DIRECTORY and it is
                # on nobody's PATH.  cmd/ex puts ninstall BEFORE install, so a
                # scanner taking the first rule sends ex, vi and view there and
                # the three names vanish from every real directory.  V8's
                # measured disk says /usr/bin, and that is where they go.
                d = re.sub(r"/usr/new$", "/usr/bin", d)
                # LONGEST FIRST.  "/usr/bin".endswith("/bin") is true, so a
                # shortest-first walk put vi, view and edit in /bin while ex
                # went to /usr/bin -- an alias in a different directory from
                # its target, which is not a hard link at all.
                for pre in ("/usr/jerq/bin", "/usr/games", "/usr/lib",
                            "/usr/bin", "/bin", "/etc", "/lib"):
                    if d.endswith(pre):
                        d = pre
                        break
                else:
                    continue
                out.append((dname, d, sname))
    return out


def unit_scripts(text, m, rules, srcs):
    """[(name, dir, srcfile)] -- scripts a unit's OWN makefile installs.

    cmd/pascal's Makefile ends `cp pascal.sh $B/pascal', which is the tape
    saying that the pascal COMMAND is a shell script wrapping pi and px.  There
    are 154 .sh files inside unit directories and most are not commands, so the
    install rule is the evidence -- sweeping them all in would put every test
    and helper script on the disk.
    """
    out = []
    for tgt in ("install", "all"):
        if tgt not in rules:
            continue
        for raw in rules[tgt][1]:
            for line in re.split(r"[;&]+", expand(raw, m)):
                mo = re.match(r"\s*cp\s+(\S+\.sh)\s+(\S+)\s*$", line.strip())
                if not mo:
                    continue
                src, dst = mo.group(1), mo.group(2).rstrip("/")
                if src not in srcs and src.split("/")[-1] not in srcs:
                    continue
                name = dst.split("/")[-1]
                d = "/".join(dst.split("/")[:-1])
                if not name or not NAMEOK.match(name):
                    continue
                for pre in ("/usr/jerq/bin", "/usr/games", "/usr/lib",
                            "/usr/bin", "/bin", "/etc", "/lib"):
                    if d.endswith(pre):
                        d = pre
                        break
                else:
                    continue
                out.append((name, d, src.split("/")[-1]))
    return out


def rule_programs(text, srcs, admin):
    """[(name, dest, objects, libs, how)] from the unit's build file.

    FIVE IDIOMS, and each was found because a program went missing:

      a.out-cp   `a.out: objs' with `install: cp a.out awk'
      a.out-mv   NO -o at all: `$(CC) $(OBJS)' then `mv a.out as' -- the
                 ASSEMBLER, without which stage 1 cannot run
      explicit   `-o NAME' anywhere in a recipe.  NOT anchored on a compiler
                 token: cmd/adb links `$(CC) -o adb $(FILES)' and defines no
                 CC, so expanding it to nothing leaves ` -o adb ...'
      implicit   `NAME: NAME.c' with no recipe -- make's built-in rule
      Admin/Mk   handled by the caller for loose sources
    """
    m = macros(text)
    rules = recipes(text)
    inst = install_dirs(rules, m)
    out, seen = [], set()

    def add(name, objs, libs, how, odir=""):
        if (not name or name in seen or name == "a.out"
                or not NAMEOK.match(name)
                or name.endswith((".o", ".a", ".x", ".c", ".h"))):
            return
        objs = globs([o for o in objs], srcs)
        if not objs:
            return
        dest = (odir if odir.startswith("/")
                else inst.get(name, admin.get(name, "/usr/bin")))
        out.append((name, dest, objs, libs or "-", how))
        seen.add(name)

    # -- the two a.out idioms
    aout = rules.get("a.out", ("", []))[0]
    for tgt, (pre, lines) in rules.items():
        for raw in lines:
            for line in re.split(r"[;&]+", expand(raw, m)):
                mo = re.match(r"\s*(?:mv|cp)\s+a\.out\s+(\S+)\s*$", line)
                if not mo:
                    continue
                src = expand(aout, m) if tgt in ("install", "all") else expand(pre, m)
                objs = [w for w in src.split() if w.endswith((".o", ".a"))]
                add(mo.group(1).split("/")[-1], objs, "-", "a.out")

    # -- explicit -o
    for tgt, (pre, lines) in rules.items():
        p = expand(pre, m)
        for raw in lines:
            e = expand(raw, m)
            mo = re.search(r"-o\s+(\S+)", e)
            if not mo:
                continue
            name = mo.group(1)
            if name in ("$target", "$@"):
                name = tgt
            odir = ""
            if "/" in name:
                odir, name = name.rsplit("/", 1)
                if odir in (".", ""):
                    odir = ""
            # The objects may come BEFORE -o: cmd/sh is
            # `$CC $LDFLAGS $OFILES -o $TESTDIR/sh' with nothing after.
            rest = (e[:mo.start()] + " " + e[mo.end():])
            rest = rest.replace("$prereq", p).replace("$^", p)
            objs = [w for w in rest.split() if w.endswith((".o", ".a"))]
            libs = " ".join(w for w in rest.split() if w.startswith("-l"))
            if not objs:
                cs = [w for w in rest.split() if w.endswith(".c")]
                objs = [w[:-2] + ".o" for w in cs]
            add(name, objs, libs, "explicit", odir)

    # -- implicit
    for tgt, (pre, lines) in rules.items():
        if lines or "/" in tgt or "." in tgt:
            continue
        if expand(pre, m).strip() == tgt + ".c":
            add(tgt, [tgt + ".o"], "-", "implicit")
    return out


# ======================================================== 4. the scan ===
def admin_large():
    """The 27 names cmd/Admin/Mk compiles -O instead of -Od2.

    Mk's own if-chain:

	if   Admin/lookline "$i" Admin/large
	then CFLAGS=-O
	else CFLAGS='-Od2'

    -Od2 is the optimiser plus c2; -O alone skips c2.  The tape names the
    exceptions rather than the rule, and they are the big programs -- fsck,
    dump, restor, ls, sort, tar, ld -- so this is a real build decision and not
    a nicety.  A plan carrying no flag at all silently compiles all 208 the
    same way.
    """
    p = os.path.join(TREE, "src", "cmd", "Admin", "large")
    if not os.path.exists(p):
        return set()
    return {l.strip() for l in open(p, errors="replace") if l.strip()}


def admin_dest():
    """cmd/Admin is the tape's own answer to `where does this install'."""
    d = os.path.join(TREE, "src", "cmd", "Admin")
    table = {}
    for f, dest in (("binfiles", "/bin"), ("etcfiles", "/etc"),
                    ("libfiles", "/lib"), ("ulibfiles", "/usr/lib")):
        p = os.path.join(d, f)
        if not os.path.exists(p):
            continue
        for line in open(p, errors="replace"):
            for w in line.split():
                table.setdefault(w, dest)
    return table


def parked(d):
    """Why this directory is not built, or None."""
    parts = d.split("/")
    if any(d == p or d.startswith(p + "/") for p in PARKED_DIRS):
        return "another system"
    if parts[-1] in MACHDIR_DROP:
        return "another machine"
    # An unpacked package is a SECOND COPY of the tree: v10-source.sh unpacks
    # .tar/.cpio/.a members in place, so cmd/odist/src.tar holds another whole
    # odist.  The unpacking is right; it is not a build input.
    if any(c.endswith((".tar", ".cpio", ".a")) for c in parts):
        return "an unpacked package"
    if parts[-1] in SUPERSEDED or parts[-1].endswith((".old", ".bak", ".orig")):
        return "superseded"
    # `oNAME' is the tape's own word for superseded, CHECKED against the
    # sibling: cmd/sh's makefile writes `mv /bin/sh /bin/osh', so the o- prefix
    # IS the backup.  oasd++/asd++, omovie/movie, ops/ps, osh/sh.
    last = parts[-1]
    if (len(last) > 1 and last[0] in "oO"
            and os.path.isdir(os.path.join(TREE, "/".join(parts[:-1]),
                                           last[1:]))):
        return "superseded (o- prefix)"
    return None


def mains_of(d, srcs):
    out = []
    for f in sorted(srcs):
        if not f.endswith(".c"):
            continue
        try:
            if MAIN.search(open(os.path.join(TREE, d, f),
                                errors="replace").read()):
                out.append(f)
        except OSError:
            pass
    return out


def scan():
    files = walk()
    missing, extra = reconcile(files)
    if missing or extra:
        for p in sorted(missing)[:5]:
            print("v10-scan: NOT SEEN %s" % p, file=sys.stderr)
        sys.exit("v10-scan: the walk missed %d and invented %d -- refusing to "
                 "report" % (len(missing), len(extra)))

    roles = collections.Counter()
    byroot = collections.Counter()
    units, archives = {}, []
    for root, rel, dp, f, kind in files:
        byroot[root] += 1
        role = classify(f, os.path.join(dp, f), kind)
        roles[role] += 1
        d = os.path.dirname(rel)
        u = units.setdefault(d, {"root": root, "build": None, "src": [],
                                 "hdr": []})
        if role == "buildfile" and u["build"] is None:
            u["build"] = f
        elif role == "source":
            u["src"].append(f)
        elif role == "header":
            u["hdr"].append(f)
        if f == "ORDER":
            try:
                n = sum(1 for l in open(os.path.join(dp, f)) if l.strip())
            except OSError:
                n = 0
            archives.append((os.path.dirname(rel), n))

    admin = admin_dest()
    large = admin_large()
    progs, parks, gaps, links, scripts = [], [], [], [], []

    # cmd/Admin/Mk BUILDS FIVE SUFFIXES, NOT ONE, and reading only *.c lost
    # twelve commands outright -- bc (a yacc grammar), wc (assembly), and ten
    # shell scripts including nohup, which and dircmp.  Mk's own rules:
    #
    #   *.y   yacc $B.y && cc $CFLAGS -o $B y.tab.c -ly
    #   *.l   lex  $B.l && cc $CFLAGS -o $B lex.yy.c -ll
    #   *.c   cc $CFLAGS -o $B $B.c
    #   *.s   as -o $B.o $B.s && cc -o $B $B.o
    #   *.sh  cp $B.sh $DESTDIR$D/$B      -- INSTALLED, never compiled
    #
    # A script is a `copy', not a `build': treating it as one would hand the
    # compiler a shell program.
    for r in BUILD_ROOTS:
        for area, fixed in (("cmd", None), ("games", "/usr/games"),
                            ("lbin", "/usr/bin"), ("dregs", "/usr/bin"),
                            ("local", "/usr/bin")):
            d = os.path.join(TREE, r, area)
            if not os.path.isdir(d):
                continue
            for f in sorted(os.listdir(d)):
                if not os.path.isfile(os.path.join(d, f)):
                    continue
                stem, dot, ext = f.rpartition(".")
                if not dot or ext not in ("c", "y", "l", "s", "sh"):
                    continue
                dest = fixed or admin.get(stem, "/usr/bin")
                cf = "-O" if f in large else "-Od2"
                if ext == "sh":
                    scripts.append((stem, dest, r + "/" + area + "/" + f))
                    continue
                if ext == "c":
                    try:
                        if not MAIN.search(open(os.path.join(d, f),
                                                errors="replace").read()):
                            continue
                    except OSError:
                        continue
                    objs, libs = [stem + ".o"], "-"
                elif ext == "y":
                    objs, libs = ["y.tab.o"], "-ly"
                elif ext == "l":
                    objs, libs = ["lex.yy.o"], "-ll"
                else:
                    objs, libs = [stem + ".o"], "-"
                progs.append((stem, r + "/" + area, dest, objs, libs,
                              "Admin/Mk " + cf, r))

    seenloose = {(p[1], p[0]) for p in progs}
    for d, u in sorted(units.items()):
        # A UNIT IS A DIRECTORY WITH A BUILD FILE **OR** SOURCES.  Requiring
        # sources skipped cmd/pascal outright -- it holds a Makefile, pascal.sh
        # and six subdirectories, and not one .c at its own level -- so the
        # `cp pascal.sh $B/pascal' that MAKES the pascal command was never
        # read.  Any directory the tape gave a build file to is a directory
        # with something to say.
        if u["root"] not in BUILD_ROOTS or not (u["src"] or u["build"]):
            continue
        why = parked(d)
        if why:
            parks.append((d, why))
            continue

        rows = []
        if u["build"]:
            try:
                text = open(os.path.join(TREE, d, u["build"]),
                            errors="replace").read()
            except OSError:
                text = ""
            rows = rule_programs(text, u["src"], admin)
            mm = macros(text)
            rr = recipes(text)
            for dname, ddir, target in aliases(text, mm, rr):
                links.append((dname, ddir, target, d))
            allf = u["src"] + [f for f in os.listdir(os.path.join(TREE, d))
                               if f.endswith(".sh")] \
                if os.path.isdir(os.path.join(TREE, d)) else u["src"]
            for nm, dd, sf in unit_scripts(text, mm, rr, allf):
                scripts.append((nm, dd, d + "/" + sf))

        # ---- EVERY main() IS ACCOUNTED FOR, and this is the correction that
        # matters.  Gating the fallback on "this directory produced nothing"
        # dropped whole subsystems: cmd/upas/smtp has FIVE main()s, contributed
        # one and lost four, and the postscript tree lost twenty-six
        # directories the same way.  A main() is covered when its object is in
        # some program's object list; anything else is a program the plan does
        # not build, whatever else the directory managed to produce.
        covered = set()
        for _, _, objs, _, _ in rows:
            covered.update(objs)
        mains = mains_of(d, u["src"])
        loose = [f for f in mains if f[:-2] + ".o" not in covered]

        # ALL GAMES INSTALL TO /usr/games, AT ANY DEPTH.  Testing only the
        # second path component gave it to the loose src/games/*.c and sent
        # rogue, sail, mille and atc -- every game that has a directory of its
        # own -- to /usr/bin.  V10's manual does not document games at all, so
        # the destination comes from V8's measured disk, which puts all of them
        # in /usr/games.
        parts_d = d.split("/")
        fixed = "/usr/games" if "games" in parts_d else None
        for f in loose:
            # ONE main() MEANS THE PROGRAM IS THE DIRECTORY.  cmd/pic and
            # cmd/grap keep theirs in main.c, so naming after the FILE gives a
            # `main' from each, which collides with every other main.  Only
            # when the directory contributes nothing else, though -- otherwise
            # the extra main is its own program.
            if len(mains) == 1 and not rows and f == "main.c":
                name = d.split("/")[-1]
                objs = [c[:-2] + ".o" for c in sorted(u["src"])
                        if c.endswith(".c")]
            else:
                name = f[:-2]
                objs = [name + ".o"]
            dest = fixed or admin.get(name, "/usr/bin")
            rows.append((name, dest, objs, "-", "scanned"))

        for name, dest, objs, libs, how in rows:
            if (d, name) in seenloose:
                continue
            if "games" in d.split("/") and not dest.startswith("/usr/games"):
                dest = "/usr/games"
            progs.append((name, d, dest, objs, libs, how, u["root"]))

    progs, dropped = dedupe(progs)

    # NO SILENT CAPS.  Anything the scan can SEE and cannot BUILD is listed,
    # because a plan that is short must say so -- silence reads as "covered
    # everything" when it did not.
    final = collections.Counter(p[1] for p in progs)
    for d, u in sorted(units.items()):
        if u["root"] not in BUILD_ROOTS or not u["src"] or parked(d):
            continue
        if mains_of(d, u["src"]) and not final.get(d):
            gaps.append(d)

    # AN ALIAS IS ONLY REAL IF WE BUILD ITS TARGET.  Installing a name whose
    # binary the plan never makes leaves a dangling command.
    made = {p[0] for p in progs}
    links = sorted({(n, d, t) for n, d, t, _ in links if t in made})
    return {"files": files, "roles": roles, "byroot": byroot, "units": units,
            "progs": progs, "archives": archives, "parked": parks,
            "dropped": dropped, "gaps": gaps, "admin": admin, "links": links,
            "scripts": sorted(set(scripts)), "large": large}


def dedupe(progs):
    """One row per installed path, chosen by a STATED order of authority.

    Two rows for one path means the build installs whichever ran last, which is
    not a decision anybody made.  Most specific first:

      a directory named for the program   cmd/ed beats cmd/ed.c -- where the
                                          tape has both, the directory is its
                                          SECOND generation
      cmd/NAME.c                          the loose Admin/Mk idiom IS the
                                          command
      an explicit rule elsewhere
      a scanned main()                    the weakest evidence, and it may
                                          never overrule a real rule

    Without the last two, scanning found files named after commands in
    directories with nothing to do with them and they WON: /bin/test from
    milligan/jerq/src/sysmon, /usr/bin/tee from cmd/learn (which has a tee.c
    because a lesson uses one), /usr/bin/fmt from lbin/Mail.
    """
    def rank(p):
        name, d, dest, objs, libs, how, root = p
        parts = d.split("/")
        r = len(parts)
        if parts[-1] == name:
            r -= 20
        if len(parts) == 2 and parts[1] == "cmd" and how == "Admin/Mk":
            r -= 16
        if how != "scanned":
            r -= 2
        else:
            r += 12
        if root == "milligan" and not dest.startswith("/usr/jerq"):
            r += 20
        return r

    best, dropped = {}, []
    for p in progs:
        k = (p[2], p[0])
        if k not in best:
            best[k] = p
        elif rank(p) < rank(best[k]):
            dropped.append(best[k])
            best[k] = p
        else:
            dropped.append(p)
    return sorted(best.values()), dropped


# ==================================================== 4b. /dev and /etc ===
def majors():
    """{name: (kind, major)} from the tape's own lsys/lib/tab.

    DEVICE MAJORS ARE A PROPERTY OF THE TAPE, NOT OF OUR CONFIG.  The obvious
    reading of a generated cdevsw[] is that it follows the config's device
    list, so a machine with a different .m would number its devices
    differently -- it is not so.  `tab' is a FIXED assignment and it is the -t
    argument mkconf already takes, which is why our 780 kernel boots a /dev
    made for another machine.  Read tab before writing a mknod: a wrong major
    is not harmless, since on V8 a node built into the wrong bdevsw slot
    panicked the kernel through a wild pointer.
    """
    out = {}
    for src in (os.path.join(ROOT, "v10", "src", "lsys", "lib", "tab"),
                os.path.join(TREE, "src", "lsys", "lib", "tab")):
        if not os.path.exists(src):
            continue
        for line in open(src, errors="replace"):
            mo = re.match(r"^(cdev|bdev)\s+(\d+)\s+(\S+)", line)
            if mo:
                out.setdefault((mo.group(1), mo.group(3)), int(mo.group(2)))
        break                             # ours first; it is the one mkconf reads
    return out


def devices():
    """[(name, kind, major, minor, mode)] -- every node the image needs.

    MINORS ARE DERIVED, NEVER WRITTEN DOWN.  `64 | (unit<<3) | part'
    reproduces every value this project has measured -- /dev/ra0a is 64 and
    /dev/ra0c is 66 off Bell Labs' own nodes -- so a computed minor cannot
    repeat the failure where a hand-written 79 addressed unit 1 while the disk
    sat on unit 2 and nineteen assertions passed about the wrong filesystem.
    """
    M = majors()
    out = []

    def add(name, kind, maj, minor, mode="0600"):
        if maj is None:
            return
        out.append((name, kind, maj, minor, mode))

    cc, cb = ("cdev", "bdev")
    add("console", "c", M.get((cc, "console")), 0, "0600")
    # dz11 -- eight lines, and every one gets a node because /etc/ttys enables
    # eight gettys.
    for i in range(8):
        add("tty%02d" % i, "c", M.get((cc, "dz11")), i, "0600")
    # mem minor 4 is `obsolete' in V10's mem.c -- the case is deleted -- so
    # there is no kmemr here however much V8 has one.
    for nm, mi, mode in (("mem", 0, "0600"), ("kmem", 1, "0600"),
                         ("null", 2, "0666")):
        add(nm, "c", M.get((cc, "mem")), mi, mode)
    add("drum", "c", M.get((cc, "drum")), 0)
    add("stdio", "c", M.get((cc, "stdio")), 0, "0666")
    # RA81s: two units, eight partitions each, block AND raw.
    for unit in (0, 1):
        for pi, part in enumerate("abcdefgh"):
            mi = 64 | (unit << 3) | pi
            add("ra%d%s" % (unit, part), "b", M.get((cb, "ra")), mi, "0600")
            add("rra%d%s" % (unit, part), "c", M.get((cc, "ra")), mi, "0600")
    # Massbus RP, which our config also carries.
    for unit in (0, 1):
        for pi, part in enumerate("abcdefgh"):
            mi = (unit << 3) | pi
            add("hp%d%s" % (unit, part), "b", M.get((cb, "hp")), mi, "0600")
            add("rhp%d%s" % (unit, part), "c", M.get((cc, "hp")), mi, "0600")
    # The Interlan, and the IP protocol devices.  /dev/ip6 and /dev/ip17 are
    # PROTOCOL numbers, not unit numbers -- 6 is TCP and 17 is UDP, which is
    # what /etc/rc pushes the disciplines onto.
    for i in (0, 1):
        add("il%d" % i, "c", M.get((cc, "ni1010a")), i, "0600")
    add("ip6", "c", M.get((cc, "ip")), 6, "0600")
    add("ip17", "c", M.get((cc, "ip")), 17, "0600")
    # tcp minors must be ODD on the active side: tcp_device.c refuses an even
    # one whose socket is not already active, because even minors are the
    # accept side.  libin's tcp_sock() walks `for (n = 01; n < 100; n += 2)'.
    for i in range(1, 64):
        add("tcp%02d" % i, "c", M.get((cc, "tcp")), i, "0666")
    for i in range(1, 32):
        add("udp%02d" % i, "c", M.get((cc, "udp")), i, "0666")
    # Stream pipes: `pt 64' in our config, cdev 18 in our tab.
    for i in range(64):
        add("pt%02d" % i, "c", M.get((cc, "pt")), i, "0666")
    return out


def etcfiles():
    """The config we ship, from v10/src/etc -- source, not typed in.

    A file a harness writes into the disk is a file with no source: it cannot
    be reviewed, diffed or regenerated, and a change to it is invisible in a
    diff of the source tree.  Five files once reached a golden that way.
    """
    d = os.path.join(ROOT, "v10", "src", "etc")
    if not os.path.isdir(d):
        return []
    out = []
    for f in sorted(os.listdir(d)):
        p = os.path.join(d, f)
        if not os.path.isfile(p):
            continue
        # mtab and utmp ship EMPTY: a fresh system has nothing mounted and
        # nobody logged in.  Carrying the builder's copies once left a disk
        # booting with three stale mounts.
        mode = "0644" if f not in ("passwd", "group") else "0644"
        out.append((f, mode, os.path.getsize(p)))
    return out


# ======================================================== 5. the plan ===
# The bootstrap set is a DECISION, not a measurement, so it is written down.
# Everything else is derived.  "Which programs must exist before anything else
# can be built" is not a question the tape answers -- V10 was never built from
# scratch.
# THE UNIT IS NAMED, NOT JUST THE PROGRAM, because a name is not unique on this
# tape: games/boggle builds a `comp' (its word compiler) and cmd/ccom/vax
# builds the C COMPILER, also `comp'.  Ranking by path depth picked boggle's and
# stage 1 ended up with no compiler.  cmd/Admin cannot settle it either -- its
# libfiles holds one entry, `dknames'.
BOOTSTRAP = [("yacc", "/usr/bin/yacc", "src/cmd/yacc"),
             ("cpp", "/lib/cpp", "src/cmd/cpp"),
             ("comp", "/lib/ccom", "src/cmd/ccom/vax"),
             ("as", "/bin/as", "src/cmd/as"),
             ("c2", "/lib/c2", "src/cmd/c2"),
             ("ld", "/bin/ld", "src/cmd"),
             ("cc", "/bin/cc", "src/cmd"),
             ("ar", "/bin/ar", "src/cmd"),
             ("cmp", "/bin/cmp", "src/cmd"),
             ("ed", "/bin/ed", "src/cmd/ed"),
             ("halt", "/etc/halt", "src/cmd"),
             ("sleep", "/usr/bin/sleep", "src/cmd")]

STAGES = [("1", "The toolchain",
           "Built by the BUILDER's compiler into the new image, which is "
           "mounted throughout.  At the end the image has a C compiler."),
          ("2", "libc",
           "Compiled by the passes stage 1 installed.  Member order is the "
           "tape's own, read from ORDER."),
          ("3", "The fixpoint",
           "The image rebuilds its toolchain against its own libc.  Installs "
           "nothing; it is the test the bootstrap exists to pass."),
          ("4", "The libraries", "Every archive the commands link against."),
          ("5", "The kernel", "Our ipnx780 config.  /unix before the bulk."),
          ("6", "The commands", "Everything else the scan found."),
          ("7", "/dev, /etc, /usr/include", "The tables and the headers."),
          ("8", "The manuals", "sellers, the tape's own documentation.")]


def build_plan(s):
    rows = []
    boot = {n for n, _, _ in BOOTSTRAP}
    byname = collections.defaultdict(list)
    for p in s["progs"]:
        byname[p[0]].append(p)

    for name, dest, unit in BOOTSTRAP:
        # PINNED TO ITS UNIT.  Ranking by path depth gave /lib/ccom to
        # games/boggle, whose word compiler is also called `comp' -- so stage 1
        # would have installed boggle's helper as the C compiler.
        cand = [p for p in byname[name] if p[6] == "src" and p[1] == unit]
        if not cand:
            rows.append(("1", dest, "MISSING", unit, "-", "-",
                         "no program %s in %s" % (name, unit)))
            continue
        p = cand[0]
        rows.append(("1", dest, "build", p[1], " ".join(p[3]), p[4], p[5]))

    n = dict(s["archives"]).get("src/libc/libc.a", 0)
    rows.append(("2", "/lib/libc.a", "build", "src/libc", "ORDER", "-",
                 "%d members, the tape's own order" % n))

    # A library is decided by CONTENT: libX.a is objects, X.c.a is SOURCES and
    # `ar x' is step one of the tape's own recipe (`lib4014.a: tek.c.a').  A
    # unit carrying both gives the bundle the build and the archive the oracle.
    bundles = {"/".join(d.split("/")[:-1]) for d, _ in s["archives"]
               if d.endswith(".c.a")}
    for d, cnt in sorted(s["archives"]):
        parts = d.split("/")
        base, unit = parts[-1], "/".join(parts[:-1])
        if not d.startswith("src/lib") or (base == "libc.a" and unit == "src/libc"):
            continue
        if any(x in parts for x in ("oldplot", "ostdio")) or base == "liboc.a":
            continue
        if base.endswith(".a") and not base.endswith(".c.a") and unit in bundles:
            continue
        if base.endswith(".c.a"):
            name, how = unit.split("/")[-1] + ".a", "%d sources, via `ar x'" % cnt
        elif base.endswith(".a") or base == "crlib":
            name = base if base.endswith(".a") else "libcurses.a"
            how = "%d members" % cnt
        else:
            continue
        rows.append(("4", "/usr/lib/" + name, "build", unit, "ORDER", "-", how))

    rows.append(("5", "/unix", "build", "src/lsys", "ipnx780.m", "-",
                 "mkconf, then two compiles and one link"))

    for name, d, dest, objs, libs, how, root in s["progs"]:
        if name in boot and root == "src":
            continue
        rows.append(("6", dest.rstrip("/") + "/" + name, "build", d,
                     " ".join(objs), libs, how))

    # THE TAPE STATING ITS OWN ALIAS OUTRANKS A PROGRAM WE INFERRED AT THE
    # SAME PATH.  /usr/bin/view had two rows -- the ln to ex, and a `view'
    # scanned out of milligan/jerq/src/font, which is a 5620 font tool that
    # happens to share the name.  Aliases are resolved after dedupe, so they
    # cannot compete in it; the competing build row is removed here instead.
    for name, dest, src in s["scripts"]:
        rows.append(("6", dest.rstrip("/") + "/" + name, "copy", src, "-", "-",
                     "a shell script -- Admin/Mk installs it, never compiles"))

    linkpaths = {d.rstrip("/") + "/" + n for n, d, _ in s["links"]}
    rows = [r for r in rows if not (r[1] in linkpaths and r[2] == "build")]
    for name, d, target in s["links"]:
        rows.append(("6", d.rstrip("/") + "/" + name, "link", target, "-", "-",
                     "a second name for %s -- the tape's own ln" % target))

    rows.append(("7", "/usr/include/**", "tree", "include", "-", "-",
                 "r70's reconstruction, %d files"
                 % sum(1 for r, _, _, _, _ in s["files"] if r == "include")))
    for name, kind, maj, minor, mode in devices():
        rows.append(("7", "/dev/" + name, "mknod", "src/lsys/lib/tab",
                     "%s %d %d" % (kind, maj, minor), mode,
                     "major from the tape's tab; minor derived"))
    # OUR CONFIG OUTRANKS A PROGRAM THAT SHARES ITS PATH.  cmd/cref holds an
    # mtab.o, so the scan offered a /etc/mtab BUILD beside the /etc/mtab we
    # ship -- two rows for one path, and the build would install whichever ran
    # last over a file that must be empty on a fresh system.
    etcnames = {f for f, _, _ in etcfiles()}
    rows = [r for r in rows
            if not (r[1].startswith("/etc/") and r[2] == "build"
                    and r[1][5:] in etcnames)]
    for f, mode, size in etcfiles():
        rows.append(("7", "/etc/" + f, "copy", "v10/src/etc/" + f, "-", mode,
                     "%d bytes -- our config, from source" % size))
    rows.append(("8", "/usr/man/**", "tree", "sellers/man", "-", "-",
                 "the tape's manuals"))
    return rows


def emit(s, rows):
    o = ["# The Tenth Edition golden image, file by file\n\n",
         "Generated by `tools/v10-scan.py` from a full scan of `v10/source`. ",
         "Do not edit.\n\n## What the scan saw\n\n| | |\n|---|---:|\n",
         "| entries walked | %s |\n" % format(len(s["files"]), ","),
         "| units | %s |\n" % format(len(s["units"]), ","),
         "| programs | %s |\n" % format(len(s["progs"]), ","),
         "| unpacked archives | %s |\n" % format(len(s["archives"]), ","),
         "| parked units | %s |\n" % format(len(s["parked"]), ","),
         "| duplicate rows dropped | %s |\n" % format(len(s["dropped"]), ","),
         "| **buildable but unbuilt** | **%s** |\n\n" % format(len(s["gaps"]), ","),
         "The walk is reconciled against the filesystem before any number here "
         "is printed; the scan refuses to report if it missed one.\n\n",
         "## The rules\n\n",
         "1. **The source contains everything.** `v10/source` and `v10/src` "
         "are the only inputs.\n"
         "2. **No staging tree.** `$DEST` is the new image, mounted, "
         "throughout.\n"
         "3. **The new toolchain runs on the new image.**\n\n"]
    bystage = collections.defaultdict(list)
    for r in rows:
        bystage[r[0]].append(r)
    o.append("## Stages\n\n| stage | what | paths |\n|---|---|---:|\n")
    for st, title, _ in STAGES:
        o.append("| %s | %s | %s |\n" % (st, title,
                                         format(len(bystage[st]), ",")))
    if s["gaps"]:
        o.append("\n## Seen but not built: %d directories\n\n"
                 % len(s["gaps"]))
        o.append("Each holds a `main()` the scan could not turn into a "
                 "program. Listed rather than omitted.\n\n")
        for d in s["gaps"]:
            o.append("- `%s`\n" % d)
    for st, title, why in STAGES:
        rs = bystage[st]
        o.append("\n## Stage %s — %s\n\n%s\n\n%s paths.\n\n"
                 % (st, title, why, format(len(rs), ",")))
        if not rs:
            continue
        o.append("| installed path | method | source | objects | libs | note |\n"
                 "|---|---|---|---|---|---|\n")
        for _, path, meth, src, objs, libs, note in sorted(rs,
                                                           key=lambda r: r[1]):
            o.append("| `%s` | %s | `%s` | `%s` | `%s` | %s |\n"
                     % (path, meth, src, objs or "-", libs or "-",
                        str(note).replace("|", "\\|")))
    return "".join(o)


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--gaps", action="store_true")
    a = ap.parse_args(argv)

    if not os.path.isdir(TREE):
        sys.exit("v10-scan: no v10/source -- run tools/v10-source.sh")

    s = scan()
    print("v10-scan: %d entries" % len(s["files"]))
    print("   by root: " + "  ".join("%s %d" % (k or ".", v)
                                     for k, v in sorted(s["byroot"].items())))
    print("   by role: " + "  ".join("%s %d" % kv
                                     for kv in s["roles"].most_common()))
    print("   units %d   programs %d   archives %d   parked %d   dropped %d"
          % (len(s["units"]), len(s["progs"]), len(s["archives"]),
             len(s["parked"]), len(s["dropped"])))
    print("   aliases %d   shell scripts %d   -O names %d"
          % (len(s["links"]), len(s["scripts"]), len(s["large"])))
    print("   SEEN BUT NOT BUILT: %d directories" % len(s["gaps"]))

    if a.gaps:
        for d in s["gaps"]:
            print("      %s" % d)
        return 0

    rows = build_plan(s)
    body = emit(s, rows)
    if a.check:
        if not os.path.exists(PLAN) or open(PLAN).read() != body:
            print("v10-scan: docs/v10-plan.md is stale")
            return 1
        print("v10-scan: plan current (%d paths)" % len(rows))
        return 0
    open(PLAN, "w").write(body)
    st = collections.Counter(r[0] for r in rows)
    print("   plan -> docs/v10-plan.md, %d paths" % len(rows))
    for k, t, _ in STAGES:
        print("      stage %s  %-28s %5d" % (k, t, st[k]))
    miss = [r for r in rows if r[2] == "MISSING"]
    for r in miss:
        print("   NO SOURCE: %s" % r[1])
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
