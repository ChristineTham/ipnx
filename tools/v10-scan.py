#!/usr/bin/env python3
"""Scan every file in v10/source and write the plan for a Tenth Edition disk.

	tools/v10-scan.py            # scan, write docs/v10-plan.md
	tools/v10-scan.py --check    # is the plan current?
	tools/v10-scan.py --report   # what the scan found, nothing written

THE SCAN IS THE WHOLE TREE.  54,000-odd files, every one classified, because
every negative this project has got wrong came from surveying part of a tree
and stating the result as a fact about the whole: "the 5620's compiler is not
on the tape" (it is, in milligan), "145 library sources are absent" (they were
inside .c.a archives), "the commands are all under cmd/" (51 are not).  A file
that is not scanned cannot be planned, and a plan that skips a directory says
so rather than being silently short.

WHICH ROOT SUPPLIES WHAT.  Six archives, never merged -- src and secombe are
both /usr/src from different machines, so merging picks one file per path and
calls the result "the tape".

	src         BUILD.  Dan Cross's v10src; our 47 patches are written
	            against it and stages 1-3 are proven on it.
	milligan    BUILD into /usr/jerq.  The 5620 distribution: sgs is the
	            cross-compiler, src/mux the terminal software.
	include     INSTALL to /usr/include.  r70's reconstruction.
	sellers     INSTALL to /usr/man.  The manuals.
	secombe     WITNESS.  A second /usr/src -- a third opinion where our
	            bytes differ, never a build input.
	blit        PARKED.  The 68000 Blit, not the 5620 we emulate.

ORDER MATTERS AND IS NOT DERIVABLE.  tools/v10-source.sh unpacks every ar
archive into a directory, which keeps every byte and destroys the one thing a
directory cannot hold: the order of the members.  V10's ld makes ONE sequential
pass when __.SYMDEF is absent or stale, so libc.a must be rebuilt in the tape's
own order or backward references go unresolved -- and the golden has neither
lorder nor tsort to recompute it.  The extractor therefore writes ORDER beside
the members, and this scan reads it.
"""

import argparse
import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")
OURS = os.path.join(ROOT, "v10", "src")
PLAN = os.path.join(ROOT, "docs", "v10-plan.md")

BUILD_ROOTS = ("src", "milligan")
ROLE_ROOTS = {"src": "build", "milligan": "build", "include": "install",
              "sellers": "install", "secombe": "witness", "blit": "parked"}

# PARKED INSIDE A BUILD ROOT.  These are not ours to build and each is a
# different machine or a different operating system; left in, `src/history/ix'
# alone contributes a second `ls', a second `adb' and a second everything, and
# the plan then has two rows for one installed path.
PARKED_DIRS = ("src/history",          # IX -- the Ninth Edition's descendant
               "src/630",              # the 630 MTG, a different terminal
               "src/vol2", "src/doc",  # the manuals, not programs
               "src/sys")              # the OTHER kernel tree; lsys is ours

# A UNIT PER MACHINE, AND ONLY ONE OF THEM IS OURS.  cmd/adb has seven back
# ends -- 11v 68v comm cray null seq vax -- each building a program called
# `adb', so a scan that takes them all produces seven rows for /bin/adb and the
# build installs whichever ran last.  The VAX is the machine we emulate.
MACHDIR_KEEP = ("vax", "vax-v9", "comm", "common")
MACHDIR_DROP = ("11v", "68v", "68k", "cray", "seq", "null", "mips", "sparc",
                "sparc_sun", "sgi", "3b", "u3b", "pdp11", "i386", "m68k",
                "hp", "ibm", "sun", "sun3", "sun4", "apollo", "gould")

SRCEXT = (".c", ".s", ".y", ".l", ".g", ".lex", ".e", ".f")
BUILDFILES = ("makefile", "Makefile", "mkfile", "MAKEFILE")

# V10's own style is `# include <x>' as often as `#include' -- cpp.c itself
# opens `# include <libc.h>'.  A scan that misses the space declares every
# header present and the build then dies on the one that is not.
INC = re.compile(r"^[ \t]*#[ \t]*include[ \t]*([<\"])([^>\"]+)[>\"]", re.M)
RULE = re.compile(r"^([^\s:=#][^:=]*):([^=].*|)$", re.M)
MACRO = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)[ \t]*=[ \t]*(.*)$", re.M)
MAIN = re.compile(r"^[ \t]*(?:int[ \t]+|void[ \t]+)?main[ \t]*\(", re.M)


# --------------------------------------------------------------- the walk ---
# EVERY DIRECTORY ENTRY IS ACCOUNTED FOR, AND THE COUNT IS RECONCILED AGAINST
# THE FILESYSTEM.  os.walk alone is not exhaustive and the gap is silent: a
# SYMLINK TO A DIRECTORY lands in its dirnames, not its filenames, so
# secombe/cmd/map/export/libmap simply never appeared -- 54,327 seen against
# 54,328 on disk, a difference small enough to read as rounding and large
# enough to hide a whole subtree.  A BROKEN symlink (map/export/mapdata) does
# appear, and stat'ing it raises rather than answering.
#
# So the walk enumerates with scandir, records what each entry IS, and refuses
# to follow a symlinked directory -- following it would walk secombe's map data
# twice under two names and inflate every count downstream.
def walk():
    """Every entry under v10/source: (root, relpath, dirpath, name, kind)."""
    out = []
    stack = [TREE]
    seen_dirs = set()
    while stack:
        dp = stack.pop()
        real = os.path.realpath(dp)
        if real in seen_dirs:
            continue
        seen_dirs.add(real)
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
                tgt = os.path.realpath(e.path)
                if not os.path.exists(e.path):
                    out.append((root, r, dp, e.name, "broken-link"))
                elif os.path.isdir(e.path):
                    # NOT followed, but COUNTED -- see the note above.
                    out.append((root, r, dp, e.name, "link-dir"))
                else:
                    out.append((root, r, dp, e.name, "link-file"))
                continue
            if e.is_dir():
                stack.append(e.path)
                continue
            out.append((root, r, dp, e.name, "file"))
    return out


# ------------------------------------------------------------- inspection ---
# CLASSIFY BY CONTENT, NOT BY NAME, because on this tape the name lies in both
# directions and each lie has already cost this project a wrong conclusion:
#
#   libdbm.a   is `mv dbm.o libdbm.a'   -- a bare object wearing a .a name
#   libsdb.a   is `as dbxxx.s -o ...'   -- likewise
#   plot.c.a   is an archive of .c FILES, not objects; ar was the ordinary way
#              to package any file set before tar was everywhere
#   crlib      is libcurses' archive, with no .a at all
#
# A first read of 512 bytes answers all of it: 0407/0410/0413 is a VAX a.out,
# `!<arch>' an archive, `#!' a script, and anything with a NUL in the first
# block is not text.
MAGIC_AOUT = (0o407, 0o410, 0o413, 0o405, 0o560)


def sniff(path):
    """(kind, head) from the file's first block.  '' if unreadable."""
    try:
        with open(path, "rb") as fh:
            head = fh.read(512)
    except OSError:
        return "unreadable", b""
    if not head:
        return "empty", head
    if head[:8] == b"!<arch>\n":
        return "archive", head
    if head[:2] == b"#!":
        return "script", head
    if len(head) >= 2:
        mag = head[0] | (head[1] << 8)
        if mag in MAGIC_AOUT:
            return "object", head
    if b"\0" in head:
        return "binary", head
    return "text", head


def classify(name, path, kind):
    """What the build does with this entry.  Content decides; name informs."""
    if kind in ("broken-link", "link-dir"):
        return kind
    what, head = sniff(path)
    if what in ("unreadable", "empty"):
        return what
    if what == "archive":
        return "archive"
    if what == "object":
        return "object"
    if name in BUILDFILES:
        return "buildfile"
    if name == "ORDER":
        return "order"
    if what == "binary":
        return "data"
    # -- text from here down: the suffix is now a reliable hint
    for e in SRCEXT:
        if name.endswith(e):
            return "source"
    if name.endswith(".h") or name.endswith(".def"):
        return "header"
    if name.endswith(".o") or name.endswith(".x"):
        return "object"
    if re.match(r"^.*\.[0-9][a-z]?$", name):
        return "manual"
    if what == "script" or name.endswith(".sh"):
        return "script"
    return "text"


# ------------------------------------------------------------ build rules ---
def macros(text):
    m = {}
    # A CONTINUATION IS PART OF THE LINE.  sh's $OFILES spans three lines; read
    # separately they name eight of twenty-four objects, which would "prove"
    # that sixteen of the shell's own sources are not in its build.
    text = re.sub(r"\\\n", " ", text)
    for k, v in MACRO.findall(text):
        m[k] = v.strip()
    return m


def expand(s, m, depth=0):
    if depth > 8:
        return s
    def rep(mo):
        return m.get(mo.group(1) or mo.group(2) or mo.group(3), "")
    # THREE SPELLINGS.  `$(X)' and `${X}' are make; a BARE `$X' is plan9 mk,
    # which 205 of this tape's build files use -- cmd/sh links `$CC $LDFLAGS
    # $OFILES -o $TESTDIR/sh' and without the bare form none of it expands, so
    # the shell yielded no program at all.  $target and $prereq are mk's own
    # and are handled by the caller, so they are excluded here.
    out = re.sub(r"\$\(([A-Za-z_][A-Za-z0-9_]*)\)"
                 r"|\$\{([A-Za-z_][A-Za-z0-9_]*)\}"
                 r"|\$(?!target\b|prereq\b|stem\b)([A-Za-z_][A-Za-z0-9_]*)",
                 rep, s)
    return expand(out, m, depth + 1) if out != s and "$" in out else out


def recipes(text):
    """{target: [recipe lines]} -- a recipe is a BLOCK, not a line.

    cmd/ccom runs yacc and then seds y.tab.c into cgram.c on the NEXT line;
    cmd/2500 edits it with ed.  Judged a line at a time both look like a plain
    yacc call and the build would compile a generated source the tape never
    compiles.
    """
    out, cur = {}, None
    body = re.sub(r"\\\n", " ", text)
    for line in body.split("\n"):
        if line.startswith("\t"):
            if cur:
                out.setdefault(cur, []).append(line.strip())
            continue
        mo = RULE.match(line)
        if mo:
            cur = mo.group(1).strip()
            out.setdefault(cur, [])
            out[cur + "\0prereq"] = mo.group(2).strip()
        else:
            cur = None
    return out


def admin_dest(tree_dir):
    """cmd/Admin is the tape's own answer to `where does this install'."""
    d = os.path.join(tree_dir, "cmd", "Admin")
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


def programs(unitdir, rel, text, m, admin):
    """Every program this unit builds, with its objects, libs and flags.

    FOUR IDIOMS, and the third is the one a naive scan misses entirely:

      explicit   cc -o pack pack.o
      implicit   11cc: 11cc.c        -- one source, no recipe, make's rule
      a.out      a.out: awk.g.o ...  with `install: cp a.out /usr/bin/awk',
                 so the NAME comes from the cp and the OBJECTS from a.out
      Admin/Mk   the tape's own per-suffix rule, used by loose cmd/*.c
    """
    out = []
    rules = recipes(text)
    seen = set()

    # -- the a.out idiom: name from the install rule's cp destination
    aout_objs = rules.get("a.out\0prereq", "")
    for tgt in ("install", "all"):
        for line in rules.get(tgt, []):
            mo = re.match(r"cp\s+a\.out\s+(\S+)", expand(line, m))
            if mo and aout_objs:
                dest = mo.group(1)
                name = dest.rstrip("/").split("/")[-1]
                d = "/".join(dest.rstrip("/").split("/")[:-1]) or "/usr/bin"
                objs = [o for o in expand(aout_objs, m).split()
                        if o.endswith(".o")]
                if name and objs:
                    out.append((name, d, objs, "-", "a.out"))
                    seen.add(name)

    # -- where a unit's install rule puts things, for the rules that link
    #    without saying.  `cp $prereq /usr/bin' is the tape's commonest form and
    #    it names the DIRECTORY, not the file.
    instdir = {}
    for tgt in ("install", "all"):
        for raw in rules.get(tgt, []):
            # SEVERAL COMMANDS ON ONE LINE, and cmd/sh is why.  Its install is
            #   mv /bin/sh /bin/osh;   cp sh /bin/sh;   strip /bin/sh
            # so a whole-line match sees none of it, and a scanner reading
            # destinations without splitting would answer /bin/osh -- the
            # BACKUP -- because the mv comes first.  The source token must be
            # the product's own name.
            for line in re.split(r"[;&]+", expand(raw, m)):
                e = line.strip()
                if not e:
                    continue
                # `mv' INSTALLS TOO.  cmd/as is `mv as ${DESTDIR}/bin'; a
                # cp-only scan reads no destination and falls back to Admin.
                mo = re.match(r"(?:cp|mv)\s+(\S+)\s+(\S+)\s*$", e)
                if not mo or mo.group(1) == "a.out":
                    continue
                what, where = mo.group(1), mo.group(2)
                if where.endswith("/"):
                    where = where[:-1]
            # A DESTINATION FILE, not a directory: `cp sh /bin/sh'.  And the
            # source token must be the PRODUCT's name -- cmd/sh's makefile
            # opens `mv /bin/sh /bin/osh' on the same line, which would answer
            # /bin/osh to a scanner reading destinations.
                if where.count("/") >= 1 and not where.endswith(
                        ("/bin", "/etc", "/lib", "/usr/bin", "/usr/lib",
                         "/usr/games")):
                    d = "/".join(where.split("/")[:-1])
                    instdir.setdefault(what, d or "/usr/bin")
                else:
                    instdir.setdefault(what, where)

    # -- THE DEFAULT-a.out IDIOM, WHICH HAS NO -o AT ALL.  cmd/as is
    #        as: $(OBJS)
    #                $(CC) $(LDFLAGS) $(OBJS)
    #                mv a.out as
    #    so the link names no output, ld writes a.out, and the NEXT line
    #    renames it.  The assembler -- without which stage 1 cannot run -- had
    #    no row in the plan for exactly this reason, and the plan said so
    #    rather than quietly shipping eleven of twelve bootstrap programs.
    for tgt, lines in rules.items():
        if "\0prereq" in tgt:
            continue
        pre = expand(rules.get(tgt + "\0prereq", ""), m)
        for raw in lines:
            for line in re.split(r"[;&]+", expand(raw, m)):
                mo = re.match(r"\s*(?:mv|cp)\s+a\.out\s+(\S+)\s*$", line)
                if not mo:
                    continue
                name = mo.group(1).split("/")[-1]
                objs = [w for w in pre.split() if w.endswith((".o", ".a"))]
                if not objs or name in seen:
                    continue
                if not re.match(r"^[A-Za-z0-9_][A-Za-z0-9_.+-]*$", name):
                    continue
                out.append((name, instdir.get(name,
                                              admin.get(name, "/usr/bin")),
                            objs, "-", "a.out"))
                seen.add(name)

    # -- explicit link: find `-o NAME ...' in any recipe line.
    #
    # NOT ANCHORED ON A COMPILER TOKEN, and that is the fix rather than a
    # loosening.  cmd/adb/11v links with `$(CC) -o adb $(FILES)' and defines no
    # CC at all, so expanding an undefined macro to the empty string leaves
    # ` -o adb ...' with nothing for a `cc' pattern to match -- 269 cmd units
    # yielded no program for exactly this reason.  What identifies a link is the
    # -o, not the word in front of it.
    for tgt, lines in rules.items():
        if "\0prereq" in tgt:
            continue
        pre = expand(rules.get(tgt + "\0prereq", ""), m)
        for line in lines:
            e = expand(line, m)
            mo = re.search(r"-o\s+(\S+)", e)
            if not mo:
                continue
            name = mo.group(1)
            # THE OBJECTS MAY COME BEFORE `-o', AND cmd/sh IS WHY.  Its link is
            #   $CC $LDFLAGS $OFILES -o $TESTDIR/sh
            # with nothing after the target at all, so a pattern demanding
            # `-o NAME rest' matches nothing and the shell -- the program
            # /etc/init execs by absolute path -- was missing from the plan.
            # Take the whole line and remove the -o argument.
            rest = (e[:mo.start()] + " " + e[mo.end():])
            # mk spells these; make does not.  $target is the rule's own name
            # and $prereq its prerequisites -- cmd/2500 is
            # `2500: $OBJ' / `$CC $CFLAGS -o $target $prereq -lipc'.
            if name in ("$target", "$@"):
                name = tgt
            # `-o' MAY NAME A PATH.  cmd/sh links `-o $TESTDIR/sh' over
            # TESTDIR=., so the target is ./sh and a `no slash' test drops the
            # shell -- the one program /etc/init execs by absolute path.  An
            # ABSOLUTE directory there is also the install destination.
            odir = ""
            if "/" in name:
                odir, name = name.rsplit("/", 1)
                if odir in (".", ""):
                    odir = ""
            rest = rest.replace("$prereq", pre).replace("$^", pre)
            # A PROGRAM NAME IS A FILENAME, AND DROPPING THAT TEST PUT REGEXES
            # IN THE PLAN.  Unanchoring the search from a compiler token (the
            # fix for adb) also matched `grep -o '^(poot)$' ...' in cmd/worm,
            # so /usr/bin/'^(poot)$' became a row.  And `a.out' is never a
            # program: it is the intermediate the a.out idiom renames.
            if (not name or name in seen or name == "a.out"
                    or not re.match(r"^[A-Za-z0-9_][A-Za-z0-9_.+-]*$", name)
                    or name.endswith((".o", ".a", ".x", ".c", ".h"))):
                continue
            objs = [w for w in rest.split() if w.endswith((".o", ".a"))]
            libs = [w for w in rest.split() if w.startswith("-l")]
            if not objs:
                # `cc -o foo foo.c' links straight from source.
                srcs = [w for w in rest.split() if w.endswith(".c")]
                if not srcs:
                    continue
                objs = [w[:-2] + ".o" for w in srcs]
            dest = (odir if odir.startswith("/")
                    else instdir.get(name, admin.get(name, "/usr/bin")))
            out.append((name, dest, objs, " ".join(libs) or "-", "explicit"))
            seen.add(name)

    # -- implicit: `NAME: NAME.c' with no recipe
    for tgt, lines in rules.items():
        if "\0prereq" in tgt or lines:
            continue
        pre = rules.get(tgt + "\0prereq", "")
        if tgt in seen or "/" in tgt or "." in tgt:
            continue
        if expand(pre, m).strip() == tgt + ".c":
            out.append((tgt, admin.get(tgt, "/usr/bin"), [tgt + ".o"],
                        "-", "implicit"))
            seen.add(tgt)
    return out


def expand_globs(objs, srcs):
    """Resolve `y?.o' / `y[1-4].o' against the unit's real sources."""
    import fnmatch
    stems = {s.rsplit(".", 1)[0] for s in srcs if "." in s}
    out = []
    for o in objs:
        if not any(c in o for c in "?*["):
            out.append(o)
            continue
        stem = o[:-2] if o.endswith(".o") else o
        hit = sorted(s + ".o" for s in stems if fnmatch.fnmatch(s, stem))
        out.extend(hit if hit else [o])
    return out


def dedupe(progs):
    """One row per installed path, chosen by a STATED rule.

    Two rows for one path means the build installs whichever ran last, which is
    not a decision anybody made.  The order of authority, most specific first:

      a machine directory   cmd/adb/vax beats cmd/adb/comm -- comm is the
                            shared source, vax is the machine we emulate
      a unit of its own     cmd/ed beats the loose cmd/*.c Admin/Mk fallback,
                            because a directory with a makefile is the tape
                            describing its own build
      the shallower path    cmd/btree beats cmd/btree/gbt

    Anything dropped is RECORDED, because a silent tie-break is how a plan
    comes to install something nobody chose.
    """
    def rank(p):
        name, d, dest, objs, libs, how, root = p
        parts = d.split("/")
        r = 0
        # THE CANONICAL SOURCE OF A COMMAND OUTRANKS AN INCIDENTAL FILE OF THE
        # SAME NAME, and without this the recursion actively made the plan
        # worse: /bin/test came from milligan/jerq/src/sysmon/test (a 5620
        # program), /usr/bin/tee from cmd/learn, /usr/bin/fmt from lbin/Mail
        # and /usr/bin/pic from cmd/pascal/px.  Every one of those directories
        # happens to contain a file named after a command it has nothing to do
        # with -- learn has a tee.c because a lesson uses one.
        #
        # A command's own source is `cmd/NAME.c' (the loose Admin/Mk idiom) or
        # `cmd/NAME/' (a unit named for it).  Nothing else may outrank those.
        if len(parts) == 2 and parts[1] == "cmd" and how == "Admin/Mk":
            r -= 16                      # cmd/NAME.c IS the command
        # RECURSION IS THE WEAKEST EVIDENCE, so it loses to every real rule.
        # It exists to find programs no build rule names, not to overrule one.
        if how == "recursed":
            r += 12
        # A COMMAND DOES NOT COME OUT OF THE 5620 DISTRIBUTION.  milligan builds
        # into /usr/jerq; if it is competing for /bin or /usr/bin, it is a
        # coincidence of naming.
        if root == "milligan" and not dest.startswith("/usr/jerq"):
            r += 20
        # THE UNIT NAMED AFTER THE PROGRAM WINS, and this is not cosmetic:
        # cmd/yacc and cmd/picasso both build a `yacc', both explicit, both
        # three components deep -- a tie, broken by whichever the walk reached
        # first, which put picasso's yacc in the plan.  cmd/yacc is the yacc.
        # A DIRECTORY NAMED FOR THE PROGRAM IS THE STRONGEST EVIDENCE, and it
        # must beat the loose cmd/NAME.c below: where the tape has both,
        # cmd/ed/ and cmd/sort/ are its SECOND GENERATION of each and the loose
        # file is what they replaced.
        if parts[-1] == name:
            r -= 20
        if parts[-1] in MACHDIR_KEEP and parts[-1] not in ("comm", "common"):
            r -= 4                       # the machine's own back end
        if how != "Admin/Mk":
            r -= 2                       # a real buildfile beat the fallback
        r += len(parts)                  # prefer the shallower unit
        return r

    best, dropped = {}, []
    for p in progs:
        k = (p[2], p[0])
        if k not in best:
            best[k] = p
            continue
        if rank(p) < rank(best[k]):
            dropped.append(best[k])
            best[k] = p
        else:
            dropped.append(p)
    return sorted(best.values()), dropped


# THE COMMANDS ARE NOT ALL UNDER cmd/, AND SCANNING ONLY cmd/ REPORTED THAT AS
# A FACT ABOUT THE TAPE.  Same shape as "the 5620's compiler is not on the
# tape", which was a fact about one tree stated about the project.  Four more
# roots hold programs, and games is the one that shows it worst: 23 loose .c
# files with a main() and NONE of them reached the plan.
#
#   games   ~23 loose .c plus atc/ mille/ rogue/ sail/ trek/ ...
#   lbin    Mail, csh, kermit, mailx -- the Berkeley userland V8 carries
#   dregs   xstr, restor variants
#   local   site-local programs
#
# The install directory for games is /usr/games and it comes from V8's measured
# disk, not from V10's manual -- V10 does not document games at all, and V8 puts
# all twenty there.  cmd/Admin's `dest' has no opinion either, since its
# if-chain falls through to /usr/bin for anything not in its four lists.
LOOSE_AREAS = (("cmd", None),          # Admin decides
               ("games", "/usr/games"),
               ("lbin", "/usr/bin"),
               ("dregs", "/usr/bin"),
               ("local", "/usr/bin"))


def loose_commands(tree_dir, admin):
    """Loose *.c with a main(), across every root that holds programs."""
    out = []
    for area, fixed in LOOSE_AREAS:
        d = os.path.join(tree_dir, area)
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if not f.endswith(".c"):
                continue
            p = os.path.join(d, f)
            if not os.path.isfile(p):
                continue
            try:
                if not MAIN.search(open(p, errors="replace").read()):
                    continue
            except OSError:
                continue
            name = f[:-2]
            dest = fixed or admin.get(name, "/usr/bin")
            out.append((name, dest, [name + ".o"], "-", "Admin/Mk", area))
    return out


# ------------------------------------------------------------------ scan ---
def reconcile(entries):
    """Refuse to report a scan that did not see everything.

    A count that is nearly right is the dangerous kind: 54,327 against 54,328
    reads as rounding and was a symlinked directory holding a whole subtree.
    So the walk is checked against an independent enumeration before any number
    derived from it is printed -- the same argument as v10fs.py refusing to
    answer unless struct filsys computes to one block.
    """
    seen = {os.path.join(dp, n) for _, _, dp, n, _ in entries}
    disk, stack = set(), [TREE]
    while stack:
        d = stack.pop()
        try:
            for e in os.scandir(d):
                if e.is_symlink():
                    disk.add(e.path)
                elif e.is_dir():
                    stack.append(e.path)
                else:
                    disk.add(e.path)
        except OSError:
            pass
    missing, extra = disk - seen, seen - disk
    return missing, extra


def scan():
    files = walk()
    missing, extra = reconcile(files)
    if missing or extra:
        for p in sorted(missing)[:5]:
            print("v10-scan: NOT SEEN  %s" % p, file=sys.stderr)
        for p in sorted(extra)[:5]:
            print("v10-scan: PHANTOM   %s" % p, file=sys.stderr)
        sys.exit("v10-scan: the walk missed %d and invented %d -- refusing to "
                 "report" % (len(missing), len(extra)))

    admin = admin_dest(os.path.join(TREE, "src"))

    roles = collections.Counter()
    byroot = collections.Counter()
    units = {}                      # rel dir -> {buildfile, sources, ...}
    archives = []                   # (rel dir of unpacked .a, member count)

    for root, rel, dp, f, kind in files:
        byroot[root] += 1
        role = classify(f, os.path.join(dp, f), kind)
        roles[role] += 1
        d = os.path.dirname(rel)
        if role in ("source", "buildfile", "header", "order"):
            u = units.setdefault(d, {"build": None, "src": [], "hdr": [],
                                     "order": None, "root": root})
            if role == "buildfile" and u["build"] is None:
                u["build"] = f
            elif role == "source":
                u["src"].append(f)
            elif role == "header":
                u["hdr"].append(f)
            elif role == "order":
                u["order"] = f
        if f == "ORDER":
            try:
                n = sum(1 for l in open(os.path.join(dp, f)) if l.strip())
            except OSError:
                n = 0
            archives.append((os.path.dirname(rel), n))

    # programs, from the units we BUILD
    progs, parked = [], []
    for d, u in sorted(units.items()):
        if u["root"] not in BUILD_ROOTS:
            continue
        if not u["build"]:
            continue
        if any(d == p or d.startswith(p + "/") for p in PARKED_DIRS):
            parked.append(d)
            continue
        parts = d.split("/")
        last = parts[-1]
        if last in MACHDIR_DROP:
            parked.append(d)
            continue
        # AN UNPACKED PACKAGE IS A SECOND COPY OF THE TREE.  v10-source.sh
        # unpacks .tar/.cpio/.a members in place, so src/cmd/odist/src.tar
        # holds another whole odist and contributes a duplicate row for every
        # program in it.  The unpacking is right -- a file that is not
        # extracted cannot be analysed -- but it is not a build input.
        if any(c.endswith((".tar", ".cpio", ".a")) for c in parts):
            parked.append(d)
            continue
        # SUPERSEDED GENERATIONS, which the tape keeps beside the live one.
        # cmd/view2d/Old, brush/new, cmd/spell.old -- developers' working
        # directories, and what survived is whatever was last compiled in place.
        if last in ("Old", "old", "new", "bak", "orig") or last.endswith(
                (".old", ".bak", ".orig")):
            parked.append(d)
            continue
        # THE `oNAME' CONVENTION IS THE TAPE'S OWN WAY OF SAYING SUPERSEDED,
        # and it is checked rather than assumed: the park applies only where
        # the sibling NAME also exists.  cmd/sh's own makefile writes
        # `mv /bin/sh /bin/osh' -- the o- prefix IS the backup -- and the tree
        # carries osed0.c, olint1.c and OLDex_temp.c on the same principle.
        # Measured here: oasd++/asd++, omovie/movie, ops/ps, osh/sh.
        if (len(last) > 1 and last.startswith("o")
                and os.path.isdir(os.path.join(TREE,
                                               "/".join(parts[:-1]),
                                               last[1:]))):
            parked.append(d)
            continue
        p = os.path.join(TREE, d, u["build"])
        try:
            text = open(p, errors="replace").read()
        except OSError:
            continue
        m = macros(text)
        for name, dest, objs, libs, how in programs(os.path.join(TREE, d),
                                                    d, text, m, admin):
            # A GLOB IS NOT AN OBJECT LIST.  cmd/yacc links `y?.o' and
            # cmd/picasso `y[1-4].o'; passed through, the plan would name a
            # file that does not exist and the shell would expand it in the
            # WRONG directory.  Resolve against the unit's own sources.
            objs = expand_globs(objs, u["src"])
            progs.append((name, d, dest, objs, libs, how, u["root"]))

    # the loose *.c at the top of each area, which have no makefile at all
    for r in BUILD_ROOTS:
        for name, dest, objs, libs, how, area in loose_commands(
                os.path.join(TREE, r), admin):
            progs.append((name, r + "/" + area, dest, objs, libs, how, r))

    # ------------------------------------------------------ and RECURSE ---
    # A DIRECTORY WITH SOURCES AND NO USABLE BUILD RULE STILL HOLDS PROGRAMS.
    # Scanning only the top of each area left 54 directories under cmd/, three
    # under games/ (adv, boggle, doctor) and one under lbin/ with a main() and
    # no row -- either they carry no makefile at all, or they carry one this
    # scan could not read a link out of.  Either way the tape has the source and
    # the plan should say so.
    #
    # HOW MANY PROGRAMS A DIRECTORY HOLDS IS DECIDED BY ITS main()s, and the two
    # cases must not be conflated:
    #
    #   one main    the program is the whole directory -- every object
    #   many mains  one program per main, from ITS OWN object only.  71 units
    #               carry more than one; pairing each main with ALL the unit's
    #               objects would give cmd/awk a `maketab' carrying the whole
    #               of awk, because ld pulls in every .o it is named.
    have = {(p[1], p[0]) for p in progs}
    havedir = {p[1] for p in progs}
    for d, u in sorted(units.items()):
        if u["root"] not in BUILD_ROOTS or d in havedir:
            continue
        if any(d == p or d.startswith(p + "/") for p in PARKED_DIRS):
            continue
        parts = d.split("/")
        if parts[-1] in MACHDIR_DROP or len(parts) < 2:
            continue
        if any(c.endswith((".tar", ".cpio", ".a")) for c in parts):
            continue
        if parts[-1] in ("Old", "old", "new", "bak", "orig"):
            continue
        cs = [f for f in u["src"] if f.endswith(".c")]
        if not cs:
            continue
        mains = []
        for f in sorted(cs):
            try:
                if MAIN.search(open(os.path.join(TREE, d, f),
                                    errors="replace").read()):
                    mains.append(f)
            except OSError:
                pass
        if not mains:
            continue
        area = parts[1] if len(parts) > 1 else "cmd"
        fixed = "/usr/games" if area == "games" else None
        for f in mains:
            # ONE main() MEANS THE PROGRAM IS THE DIRECTORY.  cmd/pic and
            # cmd/grap keep theirs in main.c, so naming the program after the
            # FILE produced a `main' from each -- which then collided with
            # every other main and was dropped as a duplicate, losing pic and
            # grap outright.  This is the same blind spot that once left `sh'
            # with no row: a survey asking "does cmd/X hold X.c" never finds a
            # unit whose entry point is main.c.
            name = parts[-1] if len(mains) == 1 else f[:-2]
            if (d, name) in have:
                continue
            objs = ([c[:-2] + ".o" for c in sorted(cs)] if len(mains) == 1
                    else [name + ".o"])
            dest = fixed or admin.get(name, "/usr/bin")
            progs.append((name, d, dest, objs, "-", "recursed", u["root"]))
            have.add((d, name))

    progs, dropped = dedupe(progs)
    # NO SILENT CAPS.  A unit can emit programs and still end with none, if
    # every one of them loses a tie -- the recursion decides whether to fire
    # from a `have' set computed BEFORE dedupe.  cmd/movie and cmd/spool do
    # exactly that.  A plan that is short by two directories must say so;
    # silence reads as "covered everything" when it did not.
    final = {p[1] for p in progs}
    emptied = sorted({d[1] for d in dropped} - final)
    return {"files": files, "roles": roles, "byroot": byroot,
            "units": units, "progs": progs, "archives": archives,
            "admin": admin, "parked": parked, "dropped": dropped,
            "emptied": emptied}


# ------------------------------------------------------------------ plan ---
# THE BOOTSTRAP SET IS A DECISION, NOT A MEASUREMENT, so it is written down.
# Everything else in the plan is derived from the scan; these twelve are chosen,
# because "which programs must exist before anything else can be built" is not a
# question the tape answers -- V10 was never built from scratch.
#
#   the seven passes   V10's own ccom, as and libc.a are on the tape as linked
#                      VAX binaries and run on the builder, so only the passes
#                      with no binary strictly must be built -- but stage 3 is a
#                      fixpoint over all seven, so all seven are built.
#   ar cmp ed          stage 2 IS an archive and stage 3 IS a byte comparison,
#                      and the golden has neither tool.
#   halt sleep         a machine that cannot halt cleanly corrupts its disk.
BOOTSTRAP = [("yacc", "/usr/bin/yacc"), ("cpp", "/lib/cpp"),
             ("comp", "/lib/ccom"), ("as", "/bin/as"), ("c2", "/lib/c2"),
             ("ld", "/bin/ld"), ("cc", "/bin/cc"),
             ("ar", "/bin/ar"), ("cmp", "/bin/cmp"), ("ed", "/bin/ed"),
             ("halt", "/etc/halt"), ("sleep", "/usr/bin/sleep")]

STAGES = [("1", "The toolchain",
           "Built by the BUILDER's compiler into the new image, which is "
           "mounted throughout.  At the end of this stage the image has a C "
           "compiler of its own."),
          ("2", "libc",
           "Compiled by the passes stage 1 just installed -- `cc -B$MNT/lib/'."
           "  Member order is the tape's own, read from ORDER."),
          ("3", "The fixpoint",
           "The image rebuilds its own toolchain against its own libc.  "
           "Installs nothing new; it is the test the bootstrap exists to pass."),
          ("4", "The libraries", "Every archive the commands link against."),
          ("5", "The kernel",
           "Our ipnx780 config.  /unix goes down before the bulk of the files."),
          ("6", "The commands", "Everything else the scan found."),
          ("7", "/dev, /etc, /usr/include", "The tables and the headers."),
          ("8", "The manuals", "sellers, the tape's own documentation.")]


def build_plan(s):
    """[(stage, path, method, source, objects, libs, note)] -- every path."""
    rows = []
    boot = {n for n, _ in BOOTSTRAP}
    byname = {}
    for p in s["progs"]:
        byname.setdefault(p[0], []).append(p)

    # -- stage 1
    for name, dest in BOOTSTRAP:
        cand = [p for p in byname.get(name, []) if p[6] == "src"]
        if not cand:
            rows.append(("1", dest, "MISSING", "-", "-", "-",
                         "the scan found no source for this"))
            continue
        p = sorted(cand, key=lambda q: len(q[1].split("/")))[0]
        rows.append(("1", dest, "build", p[1], " ".join(p[3]), p[4], p[5]))

    # -- stage 2
    order = [d for d, n in s["archives"] if d.endswith("libc/libc.a")]
    n = dict(s["archives"]).get(order[0], 0) if order else 0
    rows.append(("2", "/lib/libc.a", "build", "src/libc", "ORDER", "-",
                 "%d members, the tape's own order" % n))

    # -- stage 4.  A LIBRARY IS DECIDED BY CONTENT, and there are two shapes:
    #
    #   libX.a    an archive of OBJECTS -- rebuild from the sources beside it
    #   X.c.a     an archive of SOURCES, which is the tape's own designated
    #             build route for the whole libplot family:
    #                 lib4014.a: tek.c.a
    #                         mkdir xplot; cd xplot; ar x ../tek.c.a
    #                         cc -c -O *.c; ar rc ../lib4014.a *.o
    #             so `ar x' is step one of the recipe, not a stray artefact.
    #             Read as "24 members have no source" it looks like tape rot.
    #
    # Superseded generations are skipped by the same rule as everywhere else:
    # oldplot, ostdio and liboc are what a working directory accumulates.
    # A UNIT CAN CARRY BOTH SHAPES, and libpen is the case: libpen.a with 21
    # OBJECTS beside pen.c.a with 22 SOURCES.  The bundle is the build route --
    # the tape's own recipe is `ar x' then compile -- and the object archive is
    # the ORACLE, Bell Labs' bytes to check ours against.  Emitting both gives
    # two rows for /usr/lib/libpen.a.
    bundles = {"/".join(d.split("/")[:-1]) for d, _ in s["archives"]
               if d.endswith(".c.a")}
    for d, cnt in sorted(s["archives"]):
        parts = d.split("/")
        base = parts[-1]
        unit = "/".join(parts[:-1])
        if not d.startswith("src/lib"):
            continue
        if base.endswith(".a") and not base.endswith(".c.a") and unit in bundles:
            continue                      # the oracle, not the build route
        if base in ("liboc.a",):
            continue                      # the superseded libc
        if base == "libc.a" and unit == "src/libc":
            continue                      # stage 2 builds it
        if any(x in parts for x in ("oldplot", "ostdio", "old", "Old")):
            continue
        if base.startswith("o") and base.endswith(".a"):
            continue                      # oliboc.a, olibtr.a -- superseded
        if base.endswith(".c.a"):
            # THE LIBRARY IS NAMED FOR ITS DIRECTORY, NOT ITS BUNDLE, and the
            # tape's own rule says so: `lib4014.a: tek.c.a'.  Deriving from the
            # bundle gives libtek.a and libhp.a -- names that appear on no -l
            # line anywhere -- and makes lib5620/blit.c.a and libblit/blit.c.a
            # collide on one output.
            name = unit.split("/")[-1] + ".a"
            how = "%d sources, extracted by the tape's own `ar x' recipe" % cnt
        elif base.endswith(".a") or base == "crlib":
            name = base if base.endswith(".a") else "libcurses.a"
            how = "%d members" % cnt
        else:
            continue
        rows.append(("4", "/usr/lib/" + name, "build", unit, "ORDER", "-", how))

    # -- stage 5
    rows.append(("5", "/unix", "build", "src/lsys", "ipnx780.m", "-",
                 "mkconf, then two compiles and one link"))

    # -- stage 6
    for name, d, dest, objs, libs, how, root in s["progs"]:
        if name in boot and root == "src":
            continue
        rows.append(("6", dest.rstrip("/") + "/" + name, "build", d,
                     " ".join(objs), libs, how))

    # -- stage 7 / 8
    rows.append(("7", "/usr/include/**", "tree", "include", "-", "-",
                 "r70's reconstruction"))
    rows.append(("7", "/dev/**", "mknod", "src/lsys/lib/tab", "-", "-",
                 "majors are the tape's, from lsys/lib/tab"))
    rows.append(("7", "/etc/**", "copy", "v10/src/etc", "-", "-",
                 "our config, from source, never typed in by a harness"))
    rows.append(("8", "/usr/man/**", "tree", "sellers/man", "-", "-",
                 "the tape's manuals"))
    return rows


def emit(s, rows):
    o = ["# The Tenth Edition golden image, file by file\n\n",
         "Generated by `tools/v10-scan.py` from a full scan of `v10/source`. ",
         "Do not edit.\n\n",
         "## What the scan saw\n\n",
         "| | |\n|---|---:|\n",
         "| entries walked | %s |\n" % format(len(s["files"]), ","),
         "| units | %s |\n" % format(len(s["units"]), ","),
         "| programs | %s |\n" % format(len(s["progs"]), ","),
         "| unpacked archives | %s |\n" % format(len(s["archives"]), ","),
         "| parked units | %s |\n" % format(len(s["parked"]), ","),
         "| duplicate rows dropped | %s |\n\n" % format(len(s["dropped"]), ","),
         "Every entry under `v10/source` is walked and reconciled against the "
         "filesystem before any number here is printed; the scan refuses to "
         "report if it missed one.\n\n",
         "## The rules\n\n",
         "1. **The source contains everything.** `v10/source` and `v10/src` "
         "are the only inputs.\n"
         "2. **No staging tree.** `$DEST` is the new image, mounted, for the "
         "whole run.\n"
         "3. **The new toolchain runs on the new image.** From stage 2 the "
         "compiler is the one on the disk being built.\n\n"]
    bystage = collections.defaultdict(list)
    for r in rows:
        bystage[r[0]].append(r)
    o.append("## Stages\n\n| stage | what | paths |\n|---|---|---:|\n")
    for st, title, _ in STAGES:
        o.append("| %s | %s | %s |\n"
                 % (st, title, format(len(bystage[st]), ",")))
    for st, title, why in STAGES:
        rs = bystage[st]
        o.append("\n## Stage %s — %s\n\n%s\n\n%s paths.\n\n"
                 % (st, title, why, format(len(rs), ",")))
        if not rs:
            continue
        o.append("| installed path | method | source | objects | libs | note |\n"
                 "|---|---|---|---|---|---|\n")
        for _, path, meth, src, objs, libs, note in sorted(rs, key=lambda r: r[1]):
            o.append("| `%s` | %s | `%s` | `%s` | `%s` | %s |\n"
                     % (path, meth, src, objs or "-", libs or "-",
                        str(note).replace("|", "\\|")))
    return "".join(o)


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--report", action="store_true")
    a = ap.parse_args(argv)

    if not os.path.isdir(TREE):
        sys.exit("v10-scan: no v10/source -- run tools/v10-source.sh")

    s = scan()
    print("v10-scan: %d files" % len(s["files"]))
    print("   by root:  " + "  ".join("%s %d" % (k or ".", v)
                                      for k, v in sorted(s["byroot"].items())))
    print("   by role:  " + "  ".join("%s %d" % kv
                                      for kv in s["roles"].most_common()))
    print("   units %d   programs %d   unpacked archives %d   parked units %d"
          % (len(s["units"]), len(s["progs"]), len(s["archives"]),
             len(s["parked"])))
    dup = collections.Counter((p[2], p[0]) for p in s["progs"])
    clash = [k for k, v in dup.items() if v > 1]
    print("   dropped as duplicates %d   (unresolved clashes %d)"
          % (len(s["dropped"]), len(clash)))
    for d, n in sorted(clash)[:6]:
        where = [p[1] for p in s["progs"] if p[0] == n and p[2] == d]
        print("      %s/%s  <- %s" % (d, n, ", ".join(where)))

    if s["emptied"]:
        print("   UNITS THAT BUILD NOTHING (every program lost a tie): %d"
              % len(s["emptied"]))
        for d in s["emptied"][:6]:
            print("      %s" % d)
    rows = build_plan(s)
    body = emit(s, rows)
    if a.report:
        return 0
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
    if miss:
        print("   NO SOURCE FOUND for %d bootstrap paths:" % len(miss))
        for r in miss:
            print("      %s" % r[1])
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
