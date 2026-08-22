#!/usr/bin/env bash
#
# Build a Tenth Edition golden image in one pass.
#
#	bash tools/v10-build.sh [builder-image]
#
# Blank disk to finished disk in a single boot, with the new image mounted
# throughout and every stage installing into it.  docs/v10-bootstrap.md is the
# plan; this implements it.
#
# THE THREE RULES IT EXISTS TO KEEP.
#
#   1  THE SOURCE CONTAINS EVERYTHING.  work/v10 (the TUHS tarballs), v10/src
#      (our patches and captures) and v10/mk/gen (the generated build
#      description).  Nothing else -- not the builder's filesystem, not the
#      Eighth Edition, not a previous golden, not a file a harness writes
#      inline.
#
#   2  NO STAGING TREE.  $(DESTDIR) is the new image, mounted, for the whole
#      run.  The generated makefiles were written for this -- init.mk says
#      `cp init $(DESTDIR)/etc/init' -- and were driven the other way, which is
#      how 33 files reached a disk with no source but the machine that built
#      it.
#
#   3  THE NEW TOOLCHAIN RUNS ON THE NEW IMAGE.  After stage 1 the passes are
#      on the image and stage 2 compiles with `cc -B$MNT/lib/'.  By stage 3 the
#      image compiles itself.  The builder supplies a running kernel and
#      nothing else.
#
# WHAT IT REPLACES.  v10-mkdisk, v10-stage1..3, v10-libs, v10-link, v10-compile,
# v10-kernel, v10-netboot, v10-golden, v10-bigfs -- 22 scripts, 6,776 lines,
# every one of which built somewhere and copied afterwards.  They are in git
# (779fdec) if a measurement from the old world is ever needed; they are not
# here because the copying is the defect and leaving them invites its return.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/norun.sh"

GOLD="$ROOT/work/v10gold"
BUILDER="$GOLD/${1:-ipnx-v10-made.img.pre-k16}"
OUT="$GOLD/${V10_OUT:-v10-golden.img}"
CLONE="$GOLD/build-builder.img"
LOG="$ROOT/work/v10-build.log"
NETFSD="$ROOT/netfs/.build/release/netfsd"
TPORT="${TPORT:-9330}"; OPORT="${OPORT:-9331}"; MPORT="${MPORT:-9332}"

# ------------------------------------------------------------- the inputs ---
[[ -e "$BUILDER" ]]       || { echo "v10-build: no $BUILDER"; exit 1; }
[[ -d "$ROOT/work/v10" ]] || { echo "v10-build: no work/v10 -- run tools/v10-import.py"; exit 1; }
[[ -d "$ROOT/v10/src" ]]  || { echo "v10-build: no v10/src"; exit 1; }

# EVERY GENERATED LIST MUST BE CURRENT.  A stale list is a build that installs
# something nobody chose, which is the whole class of fault this rewrite is
# about.  Each of these has a --check that compares its output with what it
# would generate now.
for g in v10-overlay.py v10-tapebins.py v10-where.py v10-proto.py v10-world.py \
         v10-libs.py v10-prebuilt.py; do
    [[ -f "$ROOT/tools/$g" ]] || continue
    python3 "$ROOT/tools/$g" --check >/dev/null 2>&1 || {
        echo "v10-build: tools/$g reports its output stale -- regenerate it"; exit 1; }
done
python3 "$ROOT/v10/mk/mkdep.py" --check >/dev/null 2>&1 || {
    echo "v10-build: v10/mk/mkdep.py reports the makefiles stale"; exit 1; }

# The /etc content is source, not something a harness types into the disk.
for f in passwd group ttys rc motd fstab mtab utmp profile; do
    [[ -e "$ROOT/v10/src/etc/$f" ]] || {
        echo "v10-build: v10/src/etc/$f is missing -- proto-etc names it"; exit 1; }
done

no_other_sims || exit 1

echo "== building netfsd =="
( cd "$ROOT/netfs" && swift build -c release ) >/dev/null || exit 1

PIDS=()
trap 'for p in "${PIDS[@]:-}"; do kill "$p" 2>/dev/null; done' EXIT
serve() { "$NETFSD" -p "$1" -v "$2" > "$ROOT/work/netfs-build-$3.log" 2>&1 & PIDS+=($!); }
serve "$TPORT" "$ROOT/work/v10"      tape
serve "$OPORT" "$ROOT/v10/src"       ours
serve "$MPORT" "$ROOT/v10/mk/gen"    mk
sleep 1
for p in "${PIDS[@]}"; do
    kill -0 "$p" 2>/dev/null || { echo "netfsd died"; tail -5 "$ROOT"/work/netfs-build-*.log; exit 1; }
done

# ------------------------------------------------------------ the outputs ---
# THE OUTPUT IS NEVER THE GOLDEN'S PATH.  The script this replaces wrote
# work/v10gold/ipnx-v10-made.img and `rm -f'd it before the guest did anything;
# a run killed a minute in destroyed the golden, and no V10 image had ever been
# committed.  Promotion is a separate, deliberate copy after the result is
# checked.
#
# SPARSE, and that is not a saving for its own sake: `dd count=891072' writes
# 456 MB of real zeros and allocates every block.  An unwritten region of a
# sparse file reads as zeros, so the disk is identical.  The rule requiring a
# file recreated from /dev/zero is about REUSE -- mkbitfs does not clear data
# blocks, so a reused file leaves the last run's contents in what the new
# filesystem calls free space.  `rm' then a fresh sparse file has no previous
# contents at all.
echo "== making a blank RA81 (456 MB, sparse) =="
rm -f "$OUT"
dd if=/dev/zero of="$OUT" bs=1 count=0 seek=456228864 2>/dev/null
[[ $(stat -f%z "$OUT") == 456228864 ]] || { echo "v10-build: blank is the wrong size"; exit 1; }

# The builder is CLONED: booting mounts, and mounting rewrites the superblock.
rm -f "$CLONE"
cp -c "$BUILDER" "$CLONE" 2>/dev/null || cp "$BUILDER" "$CLONE"

expect "$ROOT/tools/v10-build.exp" "$CLONE" "$OUT" "$TPORT" "$OPORT" "$MPORT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}

# ---------------------------------------------------------- the boot block ---
# HOST-SIDE, AFTER THE GUEST HAS HALTED.  Guest-side writes to the raw device
# were tried and failed; this is 508 bytes at sector 0 and the image must not be
# attached to a running simulator when it happens.
if [[ $rc -eq 0 ]]; then
    if pgrep -x vax780 >/dev/null 2>&1 || pgrep -x vax750 >/dev/null 2>&1; then
        echo "v10-build: a simulator is still running -- NOT writing the boot block"
        rc=1
    else
        dd if="$ROOT/work/v10/src/lsys/boot/bb/4kb" of="$OUT" \
           bs=512 count=1 conv=notrunc 2>/dev/null
        n=$(dd if="$OUT" bs=512 count=1 2>/dev/null | tr -d '\0' | wc -c | tr -d ' ')
        echo "== boot block: $n of 512 bytes non-zero =="
        [[ "$n" -gt 400 ]] || { echo "v10-build: the boot block did not land"; rc=1; }
    fi
fi

# ------------------------------------------------------------ stage 8: verify ---
# ANY FILE WHOSE ONLY SOURCE IS THE BUILDER IS A BUILD FAILURE.  Not a note --
# the three defects this rewrite exists to prevent (a V8-format fstab, two stale
# mtab records, seven ix binaries) all arrived without being chosen, and this is
# the check that notices.
if [[ $rc -eq 0 && -f "$ROOT/tools/v10-manifest.py" ]]; then
    echo "== stage 8: provenance =="
    python3 "$ROOT/tools/v10-manifest.py" --disk "${OUT#$ROOT/}" \
            --builder "${CLONE#$ROOT/}" --out v10/mk/gen/manifest.txt --no-search \
        | sed 's/^/   /'
    bad=$(awk -F'\t' '$3=="builder"' "$ROOT/v10/mk/gen/manifest.txt" | wc -l | tr -d ' ')
    echo "   files whose only source is the builder: $bad"
    if [[ "$bad" != 0 ]]; then
        echo "   BUILD FAILED -- see v10/mk/gen/manifest.txt"
        awk -F'\t' '$3=="builder"{print "      "$1}' "$ROOT/v10/mk/gen/manifest.txt" | head -20
        rc=1
    fi
fi

echo
echo "== v10-build =="
echo "   image    $OUT"
echo "   builder  $(basename "$BUILDER")  (cloned; the original is untouched)"
echo "   log      $LOG"
echo "== v10-build exit $rc =="
exit "$rc"
