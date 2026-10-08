#!/usr/bin/env python3
"""Does every difference between v10/ and the golden disk have a way to reach it?

	python3 tools/v10-tree-check.py              every difference is delivered
	python3 tools/v10-tree-check.py --current    and none is still pending
	python3 tools/v10-tree-check.py --no-disk    only the half that needs no image
	python3 tools/v10-tree-check.py --golden IMG a disk other than run/v10-golden

v10/usr is the machine's /usr (docs/v10-build.md), but a repository edit
reaches a machine only through three doors: mkbuild carries src/build,
build/mkfiles' rows are copied by updatebuild, ipnxbuild and mkipnx, and patch
repairs or replaces what the tapes ship.  An edit through none of them is
recorded in git and lives nowhere else.  On 7 Oct 2026 that was ninety files,
some of them fixed three weeks earlier -- dmesg, docgen, troff, sdb, the
kernel's printf arguments, vol2 -- and the golden disk was still building every
one from the unfixed source, with no symptom anywhere.

THE PATCH HALF, which needs no disk.  patch copies some files whole from
build/ over the tree (`cp $GEN/v8/finddev.c $SRC/cmd/finddev.c').  Each such
target must equal its source here, or a fix went into the copy patch
overwrites -- finddev.c's did, so every machine lost it the next time patch
ran.  And each must be a build/mkfiles row, because patch runs only when the
patch SCRIPT is newer than its stamp (build/mkfile:254): an edit to a file it
copies otherwise waits for an unrelated edit to patch, which is how
ipnx-v10.m went stale until mkfile:1809 gave it a rule of its own.

THE DISK HALF reads run/v10-golden -- tools/v10-reset.sh restores it from
image/ -- with tools/v10fs.py, and needs every difference to be one of:

	pending   under src/build (mkbuild) or a build/mkfiles row: the next
		  updatebuild delivers it, the golden simply predates it
	expected  a named exception below, each with its reason

Anything else fails: a file that differs with no door, or one the golden holds
that v10/ does not -- debris a sweep missed, or a deletion nothing carries.
With --current, pending fails too, which is the question after a rebuild:
is the disk being committed the tree being committed?
"""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import v10fs  # noqa: E402

REPO = os.path.dirname(HERE)
USR = os.path.join(REPO, "v10", "usr")
BUILD = os.path.join(USR, "src", "build")
GOLDEN = os.path.join(REPO, "run", "v10-golden")

# Where patch's variables point, /usr-relative: patch:10-27.
VARS = {"SRC": "src", "SYS": "sys", "IDIR": "include"}

# EXPECTED DIFFERENCES, each with the reason it is not a fault.  A path here
# is checked for nothing else, so the list stays short and says why.
EXPECTED = {
    # build/src's kernel configuration, put on the machine by patch:2244,2257
    # and kept current by mkfile:1830-1836.  Deliberately not in v10/: one
    # configuration, in build/src, not two that drift (c4be5e2c).
    "/sys/ipnx": "patch's copy of build/src's kernel configuration",
    "/sys/ipnx/ipnx-v10.m": "patch's copy of build/src/ipnx-v10.m",
    "/sys/ipnx/mkfile": "patch's copy of build/src/ipnx.mkfile",
    # build/preserve rows 01 and 09: tape files a tape rule rewrites in place.
    # Both copies are build products -- camac.s's .stabs line is dated 2026 on
    # both sides -- because builds before bbe1a5a2 overwrote them with no copy
    # kept.  The tapes' originals are in neither; only the tapes can supply
    # them.  docs/v10-gaps.md records it.
    "/sys/io/camac.s": "preserve row 01, a build product on both sides",
    "/src/cmd/pascal/libpc/libpc": "preserve row 09, a build product on both sides",
}


def inshape():
    """build/inshape's rows: products installed INSIDE a shape root, kept by
    ipnxclean, and -- being build products -- never in git.  Read from the
    one list rather than written here: /maps/map used to be, and when
    flex.skel turned out to be the second such product, it was in none of
    the three places that special-cased the first."""
    out = {}
    with open(os.path.join(BUILD, "inshape")) as f:
        for ln in f:
            if re.match(r"[a-z0-9]", ln):
                parts = ln.split(None, 1)
                note = parts[1].strip() if len(parts) > 1 else ""
                out["/" + parts[0]] = "build/inshape: " + note
                # AND A DIRECTORY THAT EXISTS ONLY TO HOLD ONE.  The build
                # makes /usr/local/lib for flex.skel and ipnxclean keeps it
                # (its ancestors loop); the tree has no local/lib.  Only
                # ancestors absent from v10/ -- one that is there is a tape
                # directory and still compared like any other.
                d = os.path.dirname(parts[0])
                while d:
                    if not os.path.isdir(os.path.join(USR, d)):
                        out["/" + d] = "holds build/inshape's " + parts[0]
                    d = os.path.dirname(d)
    return out


EXPECTED.update(inshape())


def rows():
    with open(os.path.join(BUILD, "mkfiles")) as f:
        return set(ln.strip() for ln in f if re.match(r"[a-z0-9]", ln))


def patch_copies():
    """(source, target) pairs, repository-relative to v10/usr, for every
    whole-file copy patch makes -- `cp $GEN/x $VAR/y', plain or in a
    `for f in ...' loop over $f."""
    pairs = []
    words = None
    cp = re.compile(r"^\s*cp \$GEN/(\S+) \$(SRC|SYS|IDIR)/(\S+)")
    with open(os.path.join(BUILD, "patch")) as f:
        for ln in f:
            if ln.lstrip().startswith("#"):
                continue
            m = re.match(r"^\s*for f in (.+)$", ln)
            if m:
                words = m.group(1).split()
                continue
            if re.match(r"^\s*done\b", ln):
                words = None
                continue
            m = cp.match(ln)
            if not m:
                continue
            src, var, dst = m.group(1), m.group(2), m.group(3)
            for w in (words if "$f" in src and words else [None]):
                s = src.replace("$f", w) if w else src
                d = dst.replace("$f", w) if w else dst
                pairs.append(("src/build/" + s, VARS[var] + "/" + d))
    return pairs


def check_patch(have):
    bad = 0
    pairs = patch_copies()
    for src, dst in pairs:
        sp, dp = os.path.join(USR, src), os.path.join(USR, dst)
        if not os.path.exists(dp):
            if "/" + dst in EXPECTED:
                continue
            print("FAIL  %s: patch copies %s here and v10/ has no %s" % (dst, src, dst))
            bad += 1
            continue
        with open(sp, "rb") as a, open(dp, "rb") as b:
            if a.read() != b.read():
                print("FAIL  %s differs from %s, which patch copies over it -- "
                      "a fix made to one and not the other" % (dst, src))
                bad += 1
        if dst not in have:
            print("FAIL  %s has no build/mkfiles row -- an edit to %s would reach a "
                  "machine only when patch itself changed (mkfile:254)" % (dst, src))
            bad += 1
    print("patch: %d whole-file copies, %d problems" % (len(pairs), bad))
    return bad


def check_disk(have, current, golden):
    if not os.path.exists(golden):
        print("FAIL  no %s -- tools/v10-reset.sh restores it from image/" % golden)
        return 1
    fs = v10fs.V10FS(golden, "f")
    found, same = v10fs.compare(fs, USR, v10fs.usrtrees(USR))
    bad = pending = expected = 0
    for what, p, detail in found:
        rel = p.lstrip("/")
        if p in EXPECTED:
            expected += 1
            continue
        if what == "only on disk":
            if detail.endswith("(empty)"):
                expected += 1		# git cannot hold an empty directory
                continue
            print("FAIL  %s is on the golden and not in v10/ (%s): debris a sweep "
                  "missed, or a deletion no casefix row carries" % (p, detail))
            bad += 1
            continue
        if rel.startswith("src/build/") or rel in have:
            pending += 1
            if current:
                print("STALE %s: %s -- the golden predates this" % (p, what))
            continue
        print("FAIL  %s: %s (%s), and nothing delivers v10/'s copy to a machine -- "
              "add it to build/mkfiles" % (p, what, detail))
        bad += 1
    print("disk: %d identical, %d expected, %d pending delivery, %d undelivered"
          % (same, expected, pending, bad))
    return bad + (pending if current else 0)


def main():
    args = sys.argv[1:]
    golden = GOLDEN
    if "--golden" in args:
        i = args.index("--golden")
        if i + 1 >= len(args):
            sys.exit(__doc__.strip())
        golden = args[i + 1]
        del args[i:i + 2]
    if [a for a in args if a not in ("--current", "--no-disk")]:
        sys.exit(__doc__.strip())
    have = rows()
    bad = check_patch(have)
    if "--no-disk" not in args:
        bad += check_disk(have, "--current" in args, golden)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
