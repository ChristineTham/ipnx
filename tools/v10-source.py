#!/usr/bin/env python3
"""Extract the Tenth Edition tape into the repository, COMPLETELY.

	tools/v10-source.py [--dest v10/source] [--dry-run] [--check]

WHY THIS IS THE FIRST TASK.  Every defect in this build has the same shape: a
scan of work/v10 -- 25,682 files with source, objects, binaries, build
detritus and another operating system all mixed together -- reported as a fact
about the tape.

	145 library sources read as ABSENT      they are inside .c.a archives
	 10 cmd units never surveyed            no .c at their top level
	  8 ipc directories never surveyed      EXTRA_ROOTS named only ipc/bin
	435 binaries became 296                 by inventing exclusions
	  1 libc member `printf' matched to a   basename equality across trees
	    command of the same name

None of those is a fact about V10.  Each is a scan that looked in one place.

NOTHING IS EXCLUDED, AND THAT IS THE WHOLE POINT.  An earlier version of this
script decided at extraction time what was worth keeping -- IX, the 630, object
archives, a.out files -- and every one of those judgements then had to be
re-litigated from a tree that no longer contained the evidence.  A file that is
not extracted cannot be analysed, counted, diffed or argued about; it can only
be remembered, and remembering is what has been wrong every time.

So: every file on the tape lands here, and the JUDGEMENTS live in MANIFEST --
data beside the tree, revisable without re-extracting, and readable by any tool
that wants to ask "how many binaries are there" without walking the tape again.

	kind    source    text the build compiles or reads
	        binary    a.out (0407/0410/0413) -- built, not source
	        object    a .o or .x member, or a file with no name in an a.out
	        archive   ar(1) -- UNPACKED, see below
	        ours      v10/src supersedes the tape here (PATCHES.md says why)

	tree    v10       the Tenth Edition proper
	        ix        src/history/ -- a DIFFERENT system, built on V10
	        630       src/630/ -- the 630 MTG, a different terminal

ARCHIVES ARE UNPACKED INTO A DIRECTORY NAMED AFTER THE ARCHIVE, which is the
tape's own idiom -- libplot's makefile reads `mkdir xplot; cd xplot; ar x
../tek.c.a'.  Doing it that way makes collisions structurally impossible: 408
members collide when they are unpacked beside the archive, 82 of them with
DIFFERENT bytes, and every one of those is a real pair of files that a flat
unpack would silently reduce to one.  libplot/oldplot alone has seven drivers
each carrying its own arc.c, circle.c, line.c and move.c.

	src/libplot/oldplot/300.c.a/arc.c      the 300's
	src/libplot/oldplot/4014.c.a/arc.c     the 4014's
	src/cmd/ratfor/old.a/r1.c              the superseded generation
	src/cmd/ratfor/r1.c                    the live one, untouched

The archive's own bytes are not written -- they are exactly its members, and
MANIFEST records the member ORDER, which is the only other thing an archive
holds.  V8's `ld' needs that order (see the __.SYMDEF rule in CLAUDE.md).

OUR PATCHES ARE WRITTEN IN PLACE, so this tree is buildable on its own.  Where
v10/src has a file it is OURS that lands here, marked `ours' in MANIFEST, with
the tape's sha256 recorded beside it.  That keeps two things true at once: the
builder builds from one tree, and every deviation from Bell Labs is listed.
"""

import argparse
import collections
import hashlib
import os
import shutil
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TAPE = os.path.join(ROOT, "work", "v10")
OURS = os.path.join(ROOT, "v10", "src")

AR_MAGIC = b"!<arch>\n"
EXE = (0o407, 0o410, 0o413)          # OMAGIC/NMAGIC/ZMAGIC: object or binary
OBJ_SUF = (".o", ".x")               # V10's object suffixes; lsys/lib uses .x


# CASE COLLISIONS, THE SAME PROBLEM v10-import.py ALREADY SOLVED.  macOS is
# case-insensitive, so `T.sub' and `t.sub' cannot both exist in one directory
# -- and a write of the second silently replaces the first with a zero exit
# status.  33 groups of archive members collide this way (awk's test suites,
# ccom's test inputs, 630's libfw).  The rule here is the tape import's rule,
# not a second one: fewest capitals wins, ties lexicographically, and the
# loser is stored with its capitals percent-escaped.  A rule rather than a
# judgement, so a re-extract lands on the same answer.
def escape(name):
    return "".join("%%%02X" % ord(c) if c.isupper() else c for c in name)


def spell(names):
    """{true name: name to store} for a set of siblings, collisions resolved."""
    groups = {}
    for n in names:
        groups.setdefault(n.lower(), []).append(n)
    out = {}
    for _, g in groups.items():
        if len(g) == 1:
            out[g[0]] = g[0]
            continue
        win = sorted(g, key=lambda n: (sum(c.isupper() for c in n), n))[0]
        for n in g:
            out[n] = n if n == win else escape(n)
    return out

# Which tree a path belongs to.  A LABEL, not a filter: everything is
# extracted and what gets BUILT is the plan's decision, not the extractor's.
TREES = (
    ("src/history/", "ix"),          # IX: a different system, built ON V10
    ("src/630/",     "630"),         # the 630 MTG: a different terminal
)


def tree_of(rel):
    for pre, name in TREES:
        if rel.startswith(pre):
            return name
    return "v10"


def is_archive(data):
    return data.startswith(AR_MAGIC)


def ar_members(data):
    """[(name, bytes)] of an ar archive, in the archive's own order."""
    out, o = [], len(AR_MAGIC)
    while o + 60 <= len(data):
        h = data[o:o + 60]
        name = h[0:16].decode("ascii", "replace").strip().rstrip("/")
        try:
            size = int(h[48:58].decode("ascii", "replace").strip())
        except ValueError:
            break
        body = data[o + 60:o + 60 + size]
        if name:
            out.append((name, body))
        o += 60 + size + (size & 1)
    return out


def classify(name, data):
    """source | binary | object -- by reading the BYTES, then the name."""
    if len(data) >= 2:
        if struct.unpack("<H", data[:2])[0] in EXE:
            # 0407 with no name is an object; with a name it is a program.
            # Both are built rather than written, so the distinction is only
            # for counting -- suffix is the honest test we have.
            return "object" if name.endswith(OBJ_SUF) else "binary"
    if name.endswith(OBJ_SUF):
        return "object"
    return "source"


# v10/src IS ROOTED AT THE TAPE'S src/, NOT AT THE TAPE.  v10/src/libc/stdio/
# printf.c corresponds to src/libc/stdio/printf.c, and getting that wrong is
# silent: every patch simply fails to match, the tape's version is written
# instead, and the tree looks complete while carrying none of our fixes.  The
# run that found this reported `ours 0' with 49 patches on disk.
OURS_PREFIX = "src"


def ours_index():
    """{path under the tape: (abs path, sha256)} for our patches AND additions."""
    out = {}
    for dp, _, fs in os.walk(OURS):
        for f in fs:
            if f == "PATCHES.md":
                continue
            p = os.path.join(dp, f)
            rel = os.path.join(OURS_PREFIX, os.path.relpath(p, OURS))
            out[rel] = (p, hashlib.sha256(open(p, "rb").read()).hexdigest())
    return out


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--dest", default="v10/source")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--check", action="store_true",
                    help="compare the tree on disk with what would be written")
    a = ap.parse_args(argv)

    if not os.path.isdir(TAPE):
        sys.exit("v10-source: no %s -- run tools/v10-import.py" % TAPE)
    dest = os.path.join(ROOT, a.dest)
    ours = ours_index()
    dry = a.dry_run or a.check

    rows = []               # (path, sha, size, kind, tree, origin)
    order = []              # (archive path, "member member ...")
    casemap = []            # (dir, stored spelling, true name)
    stat = collections.Counter()
    used = set()

    def put(rel, data, kind, origin):
        if rel in used:      # must be impossible; assert rather than trust
            sys.exit("v10-source: COLLISION on %s (from %s)" % (rel, origin))
        used.add(rel)
        rows.append((rel, hashlib.sha256(data).hexdigest(), len(data),
                     kind, tree_of(rel), origin))
        stat[kind] += 1
        if not dry:
            out = os.path.join(dest, rel)
            os.makedirs(os.path.dirname(out), exist_ok=True)
            with open(out, "wb") as fh:
                fh.write(data)

    for dp, dirs, fs in os.walk(TAPE):
        dirs.sort()
        for f in sorted(fs):
            src = os.path.join(dp, f)
            rel = os.path.relpath(src, TAPE)
            try:
                with open(src, "rb") as fh:
                    data = fh.read()
            except OSError:
                stat["unreadable"] += 1
                continue

            # OUR PATCH WINS, and the tape's hash is recorded beside it.
            if rel in ours:
                p, sha = ours[rel]
                with open(p, "rb") as fh:
                    body = fh.read()
                if rel in used:
                    sys.exit("v10-source: COLLISION on %s" % rel)
                used.add(rel)
                rows.append((rel, sha, len(body), "ours", tree_of(rel),
                             "v10/src (tape was %s)" %
                             hashlib.sha256(data).hexdigest()[:12]))
                stat["ours"] += 1
                if not dry:
                    out = os.path.join(dest, rel)
                    os.makedirs(os.path.dirname(out), exist_ok=True)
                    shutil.copy2(p, out)
                continue

            # AN ARCHIVE IS UNPACKED INTO A DIRECTORY OF ITS OWN NAME.
            if is_archive(data):
                mem = ar_members(data)
                stat["archives unpacked"] += 1
                order.append((rel, " ".join(n for n, _ in mem)))
                names = [n for n, _ in mem if n != "__.SYMDEF"]
                how = spell(names)
                for name, body in mem:
                    if name == "__.SYMDEF":
                        continue        # a ranlib index: regenerated, not source
                    if how[name] != name:
                        casemap.append((rel, how[name], name))
                        stat["case-escaped"] += 1
                    put(os.path.join(rel, how[name]), body,
                        classify(name, body), "ar " + rel)
                continue

            put(rel, data, classify(f, data), "tape")

    # ADDITIONS: v10/src files with no tape counterpart -- nafsmnt.c, the
    # headers reconstructed from the manual (shares.h, sys/lnode.h), our 780
    # kernel config, and the whole of /etc.  "src must contain EVERYTHING
    # required to create a golden image", so a tree missing these is not one.
    for rel, (p, sha) in sorted(ours.items()):
        if rel in used:
            continue
        with open(p, "rb") as fh:
            body = fh.read()
        used.add(rel)
        rows.append((rel, sha, len(body), "ours", tree_of(rel),
                     "v10/src (an ADDITION -- no upstream)"))
        stat["ours"] += 1
        if not dry:
            out = os.path.join(dest, rel)
            os.makedirs(os.path.dirname(out), exist_ok=True)
            shutil.copy2(p, out)

    if casemap:
        stat["case-escaped"] = len(casemap)
    rows.sort()
    if a.check:
        have = set()
        for dp, _, fs in os.walk(dest):
            for f in fs:
                r = os.path.relpath(os.path.join(dp, f), dest)
                if r != "MANIFEST":
                    have.add(r)
        want = {r[0] for r in rows}
        miss, extra = sorted(want - have), sorted(have - want)
        if miss or extra:
            print("v10-source: %s is STALE -- %d missing, %d extra"
                  % (a.dest, len(miss), len(extra)))
            for x in (miss + extra)[:10]:
                print("   %s" % x)
            return 1
        print("v10-source: %s is current (%d files)" % (a.dest, len(want)))
        return 0

    if not dry:
        with open(os.path.join(dest, "MANIFEST"), "w") as fh:
            fh.write("# The Tenth Edition tape, extracted whole.  "
                     "tools/v10-source.py wrote this; do not edit.\n")
            fh.write("# path\tsha256\tsize\tkind\ttree\torigin\n")
            for r in rows:
                fh.write("%s\t%s\t%d\t%s\t%s\t%s\n" % r)
            fh.write("#\n# archive member ORDER, which the members alone do "
                     "not preserve and V8's ld needs:\n")
            for arc, names in sorted(order):
                fh.write("#order\t%s\t%s\n" % (arc, names))
            fh.write("#\n# case collisions: members whose TRUE name macOS "
                     "cannot store beside its sibling.\n")
            for d, stored, true in sorted(casemap):
                fh.write("#case\t%s\t%s\t%s\n" % (d, stored, true))

    print("v10-source: %s" % ("DRY RUN" if dry else dest))
    for k, v in stat.most_common():
        print("   %-24s %6d" % (k, v))
    print("   %s" % ("-" * 32))
    print("   %-24s %6d" % ("files written", len(rows)))
    by = collections.Counter((r[4], r[3]) for r in rows)
    print("\n   by tree and kind (a LABEL -- what is BUILT is the plan's call):")
    for t in ("v10", "ix", "630"):
        line = "   %-6s" % t
        for k in ("source", "binary", "object", "ours"):
            line += "  %s %-6d" % (k, by[(t, k)])
        print(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
