#!/usr/bin/env python3
"""Survey the Tenth Edition source: what is built, from what, to where.

	tools/v10-world.py [--check]

READS v10/source, WHICH IS IN THE REPOSITORY.  Not work/v10, which is a tar
extract that may or may not be present and cannot be diffed in a review.  The
tree is the answer; this only reads it.

WHAT REPLACED THE INFERENCE.  The survey this rewrites guessed install paths
from V10's manual, from V8's measured disk, and from each unit's own `cp'
lines -- three oracles in a priority order, arrived at one failure at a time.
The tape has the answer outright, in cmd/Admin, which is Bell Labs' own
install manifest:

	Admin/dest        the lookup, verbatim:
	                    binfiles  -> /bin     etcfiles  -> /etc
	                    libfiles  -> /lib     ulibfiles -> /usr/lib
	                    otherwise -> /usr/bin
	Admin/Mk          the build rule, per suffix, honouring $DESTDIR
	Admin/large       27 names compiled -O; everything else -Od2

So `sh' installs to /bin because binfiles says so, not because a scan of the
makefile found `cp sh /bin'.  That question cost 92 units once.

A UNIT IS ANY DIRECTORY HOLDING BUILDABLE SOURCE, AT ANY DEPTH.  Not "a
directory under cmd/".  The old rule looked one level down and never saw
cmd/pascal's pc0, pi and pxp -- three programs -- or the 1,496 sources under
ap, basic, cyntax, icon, lcc, monk, pcc1, prefer and sml, or seven of ipc's
eight directories.  Depth is not a property of the tape and must not be a
property of the survey.

	loose file under cmd/   a program in its own right.  Admin/Mk's rule:
	                        cc -o $B $B.c, installed at Admin/dest $B.
	a directory             built by its own makefile: `make; make install'.
	                        Its programs come from its link rules.

THREE LINK IDIOMS, because the tape uses all three and the third is dominant:

	explicit   cc -o pack pack.o
	implicit   `11cc:  11cc.c' -- one source, no recipe, make's built-in
	a.out      a.out: awk.g.o awk.lx.o $(OFILES)
	           install: a.out ; cp a.out /usr/bin/awk
	           -- the NAME comes from the cp, the OBJECTS from the target

NOTHING IS EXCLUDED.  A unit that cannot be built is recorded with the reason,
never dropped: a survey that silently omits what it cannot handle reports its
own omissions as facts about the tape.
"""

import argparse
import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")      # the whole extract
SRC = os.path.join(TREE, "src")                 # where the programs are
GEN = os.path.join(ROOT, "v10", "mk", "gen")

BUILD_FILES = ("makefile", "Makefile", "mkfile", "Mkfile", "MAKEFILE")
CSUF = (".c",)
GENSUF = {".y": "yacc", ".l": "lex", ".g": "yacc", ".lex": "lex"}
ASUF = (".s",)

# Trees whose programs are not V10's.  Labelled, surveyed, and marked -- the
# plan decides whether to build them, not this.
FOREIGN = (("src/history/", "ix"), ("src/630/", "630"))


def tree_of(rel):
    for pre, name in FOREIGN:
        if rel.startswith(pre):
            return name
    return "v10"


# ------------------------------------------------------- Admin, the oracle ---

def admin():
    """{name: install directory} from cmd/Admin, plus the -O list.

    Admin/dest is a shell script and this is its `if' chain, in its order.
    Read rather than reimplemented: the order matters (a name in both
    binfiles and etcfiles goes to /bin) and it is stated there, not here.
    """
    base = os.path.join(SRC, "cmd", "Admin")
    dest, large = {}, set()
    for f, d in (("binfiles", "/bin"), ("etcfiles", "/etc"),
                 ("libfiles", "/lib"), ("ulibfiles", "/usr/lib")):
        p = os.path.join(base, f)
        if not os.path.exists(p):
            continue
        for line in open(p):
            n = line.strip()
            if n and n not in dest:     # first match wins, as dest's if-chain
                dest[n] = d
    p = os.path.join(base, "large")
    if os.path.exists(p):
        large = {l.strip() for l in open(p) if l.strip()}
    return dest, large


# ------------------------------------------------------------ the makefile ---

def read_build(d):
    """(text with continuations joined, filename) or (None, None).

    JOIN CONTINUATIONS FIRST.  sh's $OFILES spans three lines; read
    separately they name eight of twenty-four objects, which would "prove"
    that sixteen of the shell's own sources are not in its build.
    """
    for f in BUILD_FILES:
        p = os.path.join(d, f)
        if os.path.isfile(p):
            try:
                t = open(p, errors="replace").read()
            except OSError:
                return None, None
            return t.replace("\\\n", " "), f
    return None, None


def macros(text):
    """{NAME: value} for simple `NAME = value' lines, expanded once."""
    m = {}
    for line in text.splitlines():
        g = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$", line)
        if g:
            m[g.group(1)] = g.group(2).strip()
    for _ in range(4):                  # macros referring to macros
        for k, v in list(m.items()):
            m[k] = re.sub(r"\$[({]([A-Za-z_][A-Za-z0-9_]*)[)}]",
                          lambda x: m.get(x.group(1), ""), v)
    return m


def expand(s, m):
    for _ in range(4):
        s = re.sub(r"\$[({]([A-Za-z_][A-Za-z0-9_]*)[)}]",
                   lambda x: m.get(x.group(1), ""), s)
    return s


def rules(text):
    """[(targets, [prerequisites], [recipe lines])] -- a recipe is a BLOCK.

    cmd/ccom runs yacc and then seds y.tab.c on the NEXT line; judged a line
    at a time both look like a plain yacc call and the survey would compile a
    generated source the tape never compiles.
    """
    out, cur = [], None
    for line in text.splitlines():
        if line[:1] in ("\t", " ") and cur is not None and line.strip():
            cur[2].append(line.strip())
            continue
        if line.startswith("#") or not line.strip():
            continue
        g = re.match(r"^([^=:\t][^:=]*):([^=].*|)$", line)
        if g:
            if cur:
                out.append(cur)
            cur = (g.group(1).split(), g.group(2).split(), [])
        elif cur:
            out.append(cur)
            cur = None
    if cur:
        out.append(cur)
    return out


CC_O = re.compile(r"\b(?:cc|CC|\$[({]CC[)}]|ld|\$[({]LD[)}])\b[^;&|]*?"
                  r"-o\s+(\S+)((?:\s+[^;&|]*)?)")
CP = re.compile(r"\bcp\s+(\S+)\s+(\S+)")
MV = re.compile(r"\bmv\s+(\S+)\s+(\S+)")


def programs(d, rel, text, m, dest):
    """[(name, install dir, [objects], libs, how)] -- what this unit builds."""
    out, seen = [], set()
    rs = rules(text)

    # install destinations named by the unit itself: cp <product> <dir>/<name>
    # THE SOURCE TOKEN MUST BE THE PRODUCT'S NAME, which is what separates an
    # install from a backup: cmd/sh's makefile is `mv /bin/sh /bin/osh;
    # cp sh /bin/sh; strip /bin/sh' on one line, and the FIRST would answer
    # /bin/osh to a scanner reading destinations.
    installs = {}                       # product token -> (name, dir)
    for tg, pre, rec in rs:
        for line in rec:
            line = expand(line, m)
            for src, dst in CP.findall(line) + MV.findall(line):
                if dst.startswith("/") or "$" in dst:
                    dst = dst.replace("$(DESTDIR)", "").replace("${DESTDIR}", "")
                    if not dst.startswith("/"):
                        continue
                    dd, _, nm = dst.rpartition("/")
                    if not nm or nm.endswith((".h", ".1", ".c")):
                        continue
                    installs.setdefault(src, (nm, dd or "/usr/bin"))

    for tg, pre, rec in rs:
        for line in rec:
            line = expand(line, m)
            for g in CC_O.finditer(line):
                name = g.group(1)
                if name.endswith(".o") or "$" in name:
                    continue
                rest = g.group(2).split()
                objs = [x for x in rest if x.endswith((".o", ".a"))
                        and not x.startswith("-")]
                libs = [x for x in rest if x.startswith("-l")]
                # a.out: the NAME comes from the cp that installs it
                if name == "a.out":
                    if "a.out" not in installs:
                        continue
                    name, dd = installs["a.out"]
                else:
                    dd = installs.get(name, (None, None))[1]
                if name in seen:
                    continue
                seen.add(name)
                out.append((name, dd or dest.get(name, "/usr/bin"),
                            objs, libs, "explicit"))

    # the a.out target with no cc -o in its own recipe: objects are its
    # prerequisites, name from the install rule
    if "a.out" in installs:
        nm, dd = installs["a.out"]
        if nm not in seen:
            for tg, pre, rec in rs:
                if "a.out" in tg:
                    objs = [expand(x, m) for x in pre if x.endswith(".o")]
                    seen.add(nm)
                    out.append((nm, dd, objs, [], "a.out"))
                    break

    # implicit: `11cc: 11cc.c' -- one source, no recipe, make's built-in rule
    for tg, pre, rec in rs:
        if rec or len(tg) != 1:
            continue
        n = tg[0]
        if n in seen or "." in n or "/" in n or "$" in n:
            continue
        if len(pre) == 1 and pre[0] == n + ".c":
            seen.add(n)
            out.append((n, installs.get(n, (None, dest.get(n, "/usr/bin")))[1],
                        [n + ".o"], [], "implicit"))
    return out


# ------------------------------------------------------------------ survey ---

# --------------------------------------------------------- file by file ---
# EVERY SOURCE FILE GETS A ROW.  A per-directory survey cannot answer "is
# this file compiled, and into what", and that is the question the build
# needs -- cmd/sh dies on a profile.c that is not in its own $OFILES, and
# fifty units carry files their build does not compile (hello.c, x.c, awk's
# maketab helper, other machines' back ends in cmd/gcc, superseded
# generations like osed0.c and OLDex_temp.c).  Recorded per file, with the
# witness that put it in or left it out, rather than decided per directory.
#
# THREE WITNESSES IN THE KEEP DIRECTION, each the tape's own statement:
#   objects   the object is named in a build file's object list
#   leftover  a .o sits beside the source -- developers' working directories,
#             so what was compiled in place is evidence
#   named     the build names the SOURCE itself: cmd/docgen's makefile says
#             `docgen: docgen.c' and lets make's implicit rule do the rest,
#             so no docgen.o exists anywhere and without this witness the
#             test dropped the program the unit is named after
HDRSUF = (".h", ".def", ".defs")


def classify_files(dp, rel, fs, found, m, text, isunit=True):
    """[(path, unit, suffix, role, program, witness)] for every file here."""
    rows = []
    # which objects each program names
    owner = {}
    for name, d, objs, libs, how in found:
        for o in objs:
            owner.setdefault(o, name)
    have_o = {f for f in fs if f.endswith(".o")}
    named = set()
    if text:
        for tg, pre, rec in rules(text):
            for x in tg + pre:
                if x.endswith(CSUF) or os.path.splitext(x)[1] in GENSUF:
                    named.add(expand(x, m))

    for f in sorted(fs):
        ext = os.path.splitext(f)[1]
        base = os.path.splitext(f)[0]
        obj = base + ".o"
        if ext in CSUF or ext in GENSUF or ext in ASUF:
            if not isunit:
                rows.append((f, rel, ext, "packaged", "-",
                             "inside an ar archive -- extracted by the recipe"))
                continue
            if obj in owner:
                rows.append((f, rel, ext, "compiled", owner[obj], "objects"))
            elif obj in have_o:
                rows.append((f, rel, ext, "compiled", "-", "leftover .o"))
            elif f in named:
                rows.append((f, rel, ext, "compiled", "-", "named by build"))
            elif rel == "src/cmd":
                rows.append((f, rel, ext, "compiled", base, "Admin/Mk"))
            elif len(found) == 1 and not owner:
                rows.append((f, rel, ext, "compiled", found[0][0],
                             "sole program, no object list"))
            else:
                rows.append((f, rel, ext, "not compiled", "-",
                             "no witness -- see world.notes"))
        elif ext in HDRSUF:
            rows.append((f, rel, ext, "header", "-", "-"))
        elif f in BUILD_FILES:
            rows.append((f, rel, ext or "-", "buildfile", "-", "-"))
        elif ext == ".o":
            rows.append((f, rel, ext, "object", "-", "built, not source"))
        else:
            rows.append((f, rel, ext or "-", "data", "-", "-"))
    return rows


def survey():
    dest, large = admin()
    units, progs, gens, notes, files = [], [], [], [], []

    # WALK THE WHOLE TREE.  Surveying only directories that hold a .c left
    # 15,488 of 30,205 files unaccounted for -- every header under include/,
    # the whole of blit/, every man page, and each unpacked archive.  A file
    # with no row is a file no plan can place, which is how /usr/include and
    # /usr/man came to be carried from the Eighth Edition rather than built.
    for dp, dirs, fs in os.walk(TREE):
        dirs.sort()
        rel = os.path.relpath(dp, TREE)
        if rel == ".":
            rel = ""
        fs = [f for f in fs if f != "MANIFEST"]
        if not fs:
            continue

        # AN UNPACKED ARCHIVE IS A PACKAGE, NOT A UNIT: its members belong to
        # the directory that holds it, and the tape's own recipe extracts them
        # into the build directory (`mkdir xplot; cd xplot; ar x ../tek.c.a').
        # Its files are still surveyed -- they are just not a unit of their own.
        inarc = rel.endswith(".a") or ".a/" in rel + "/"

        srcs = sorted(f for f in fs if f.endswith(CSUF))
        gsrc = sorted(f for f in fs if os.path.splitext(f)[1] in GENSUF)
        asrc = sorted(f for f in fs if f.endswith(ASUF))
        isunit = bool(srcs or gsrc or asrc) and not inarc

        text, bf = read_build(dp)
        m = macros(text) if text else {}
        found = programs(dp, rel, text, m, dest) if (text and isunit) else []

        # LOOSE FILES UNDER cmd/ ARE PROGRAMS IN THEIR OWN RIGHT -- Admin/Mk's
        # rule, and the reason `cmd/ld.c' and `cmd/cc.c' were missed for weeks
        # (they are loose files, not cmd/ld/ and cmd/cc/ directories).
        if rel == "src/cmd":
            for f in srcs + gsrc + asrc:
                b = os.path.splitext(f)[0]
                if b in {p[0] for p in found}:
                    continue
                found.append((b, dest.get(b, "/usr/bin"), [b + ".o"], [],
                              "Admin/Mk"))

        for f in gsrc:
            gens.append((rel, GENSUF[os.path.splitext(f)[1]], f))

        files.extend(classify_files(dp, rel, fs, found, m, text, isunit))
        if not isunit:
            continue
        units.append((rel, bf or "-", len(srcs), len(gsrc), len(asrc),
                      tree_of(rel), len(found)))
        for name, d, objs, libs, how in found:
            progs.append((name, rel, d, " ".join(libs) or "-",
                          " ".join(objs) or "-", how,
                          "-O" if name in large else "-Od2", tree_of(rel)))
        if text and not found:
            notes.append((rel, "no link rule recognised in " + (bf or "?")))
        elif not text:
            notes.append((rel, "no build file"))
    return units, progs, gens, notes, files, dest, large


def write(units, progs, gens, notes, files, dry=False):
    def put(name, header, rows):
        p = os.path.join(GEN, name)
        body = header + "".join("\t".join(str(x) for x in r) + "\n" for r in rows)
        if dry:
            return body
        open(p, "w").write(body)
        return body

    put("world.units",
        "# dir\tbuildfile\tc\tgen\tasm\ttree\tprograms\n"
        "# tools/v10-world.py wrote this; do not edit.\n", units)
    put("world.prog",
        "# name\tdir\tinstall\tlibs\tobjects\thow\tcflags\ttree\n"
        "# install directory is cmd/Admin's answer unless the unit says "
        "otherwise.\n", progs)
    put("world.gen",
        "# dir\ttool\tsource\n", gens)
    put("world.notes",
        "# dir\twhy no program was derived -- recorded, never dropped\n", notes)
    put("world.files",
        "# file\tunit\tsuffix\trole\tprogram\twitness\n"
        "# EVERY source file in v10/source, and what the build does with it.\n",
        files)


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args(argv)
    if not os.path.isdir(SRC):
        sys.exit("v10-world: no %s -- run tools/v10-source.py" % SRC)

    units, progs, gens, notes, files, dest, large = survey()

    if a.check:
        bad = 0
        for n in ("world.units", "world.prog", "world.gen", "world.notes",
                  "world.files"):
            p = os.path.join(GEN, n)
            if not os.path.exists(p):
                print("v10-world: %s missing" % n); bad = 1
        if not bad:
            import io
            cur = {n: open(os.path.join(GEN, n)).read()
                   for n in ("world.units", "world.prog", "world.gen",
                             "world.notes", "world.files")}
            write(units, progs, gens, notes, files, dry=False)
            new = {n: open(os.path.join(GEN, n)).read() for n in cur}
            if cur != new:
                print("v10-world: generated files were STALE (rewritten)")
                bad = 1
        return bad
    write(units, progs, gens, notes, files)

    by = collections.Counter(u[5] for u in units)
    ptree = collections.Counter(p[7] for p in progs)
    how = collections.Counter(p[5] for p in progs)
    idir = collections.Counter(p[2] for p in progs)
    print("v10-world: %s" % os.path.relpath(SRC, ROOT))
    print("   units (a directory with buildable source, at ANY depth)")
    for t in ("v10", "ix", "630"):
        print("      %-5s %5d units   %5d programs" % (t, by[t], ptree[t]))
    print("   programs %d, by how the tape states them" % len(progs))
    for k, v in how.most_common():
        print("      %-12s %5d" % (k, v))
    print("   install directories (cmd/Admin is the oracle)")
    for k, v in idir.most_common(8):
        print("      %-14s %5d" % (k, v))
    print("   generators %d, units with no program derived %d (world.notes)"
          % (len(gens), len(notes)))
    role = collections.Counter(f[3] for f in files)
    wit = collections.Counter(f[5] for f in files if f[3] == "compiled")
    print("   FILE BY FILE: %d files" % len(files))
    for k, v in role.most_common():
        print("      %-14s %6d" % (k, v))
    print("   the witness that put each compiled file in the build")
    for k, v in wit.most_common():
        print("      %-26s %6d" % (k, v))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
