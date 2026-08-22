#!/usr/bin/env bash
#
# Build a Tenth Edition golden image in one pass.
#
#	bash tools/v10-build.sh [builder-image]
#
# Blank disk to finished disk in a single boot, with the new image mounted
# throughout and every stage installing into it.  docs/v10-plan.md is the plan;
# v10/mk/build.sh executes it; this puts a machine under them.
#
# THE THREE RULES IT KEEPS.
#
#   1  THE SOURCE CONTAINS EVERYTHING.  v10/source (all six TUHS archives,
#      54,328 entries, in the repository) and v10/src (our patches).  Nothing
#      else -- not the builder's filesystem, not the Eighth Edition, not a
#      previous golden, not a file a harness writes inline.
#
#   2  NO STAGING TREE.  $DEST is the new image, mounted, for the whole run.
#
#   3  THE NEW TOOLCHAIN RUNS ON THE NEW IMAGE.  After stage 1 the passes are
#      on the image and later stages compile with them.  The builder supplies a
#      running kernel and nothing else.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GOLD="$ROOT/work/v10gold"
BUILDER="$GOLD/${1:-ipnx-v10-made.img.pre-k16}"
OUT="$GOLD/${V10_OUT:-v10-golden.img}"
CLONE="$GOLD/build-builder.img"
LOG="$ROOT/work/v10-build.log"
NETFSD="$ROOT/netfs/.build/release/netfsd"
VPORT="${VPORT:-9340}"; PPORT="${PPORT:-9341}"

# ------------------------------------------------------------- the inputs ---
[[ -e "$BUILDER" ]]          || { echo "v10-build: no $BUILDER"; exit 1; }
[[ -d "$ROOT/v10/source" ]]  || { echo "v10-build: no v10/source -- run tools/v10-source.sh"; exit 1; }
[[ -d "$ROOT/v10/src" ]]     || { echo "v10-build: no v10/src"; exit 1; }
[[ -s "$ROOT/v10/mk/build.sh" ]] || { echo "v10-build: no v10/mk/build.sh"; exit 1; }

# THE PLAN MUST BE CURRENT.  A stale plan is a build that installs something
# nobody chose, which is the whole class of fault this rewrite is about.
python3 "$ROOT/tools/v10-scan.py" --check >/dev/null 2>&1 || {
    echo "v10-build: docs/v10-plan.md is stale -- run tools/v10-scan.py"; exit 1; }

# TWO SIMULATORS MUST NEVER RUN AT ONCE.  Match the process NAME, never the
# command line: `pgrep -f vax780' matches the waiter's own arguments, so a
# bare count reads 2 with one simulator running.
if pgrep -x vax780 >/dev/null 2>&1 || pgrep -x vax750 >/dev/null 2>&1; then
    echo "v10-build: a simulator is already running -- refusing to start"
    ps -o pid,etime,command -p "$(pgrep -x vax780 || pgrep -x vax750)" | sed 's/^/   /'
    exit 1
fi

echo "== building netfsd =="
( cd "$ROOT/netfs" && swift build -c release ) >/dev/null || exit 1

PIDS=()
trap 'for p in "${PIDS[@]:-}"; do kill "$p" 2>/dev/null; done' EXIT
serve() { "$NETFSD" -p "$1" -v "$2" > "$ROOT/work/netfs-build-$3.log" 2>&1 & PIDS+=($!); }
serve "$VPORT" "$ROOT/v10"   v10
serve "$PPORT" "$ROOT/docs"  plan
sleep 1
for p in "${PIDS[@]}"; do
    kill -0 "$p" 2>/dev/null || { echo "netfsd died"; tail -5 "$ROOT"/work/netfs-build-*.log; exit 1; }
done

# ------------------------------------------------------------ the outputs ---
# THE OUTPUT IS NEVER A GOLDEN'S PATH.  An earlier script wrote
# work/v10gold/ipnx-v10-made.img and `rm -f'd it before the guest did anything;
# a run killed a minute in destroyed the only copy.  Promotion is a separate,
# deliberate step after the result is checked.
#
# SPARSE, and not as a saving: `dd count=891072' writes 456 MB of real zeros.
# An unwritten region reads as zeros, so the disk is identical.  The rule about
# recreating from /dev/zero is about REUSE -- mkbitfs does not clear data
# blocks, so a reused file leaves the last run's contents in what the new
# filesystem calls free space.  A fresh sparse file has no previous contents.
echo "== making a blank RA81 (456 MB, sparse) =="
rm -f "$OUT"
dd if=/dev/zero of="$OUT" bs=1 count=0 seek=456228864 2>/dev/null
[[ $(stat -f%z "$OUT") == 456228864 ]] || { echo "v10-build: blank is the wrong size"; exit 1; }

# THE BUILDER IS CLONED, because booting mounts and mounting rewrites the
# superblock -- a clean, successful, properly halted run still leaves the image
# with a different hash than the one it started with.  cp -c is an APFS clone:
# no time, no space.
rm -f "$CLONE"
cp -c "$BUILDER" "$CLONE" 2>/dev/null || cp "$BUILDER" "$CLONE"

rm -f "$LOG"
expect "$ROOT/tools/v10-build.exp" "$CLONE" "$OUT" "$VPORT" "$PPORT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}

# ---------------------------------------------------------- the boot block ---
# HOST-SIDE, AFTER THE GUEST HAS HALTED.  508 bytes at sector 0, and the image
# must not be attached to a running simulator when it happens.
if [[ $rc -eq 0 ]]; then
    if pgrep -x vax780 >/dev/null 2>&1 || pgrep -x vax750 >/dev/null 2>&1; then
        echo "v10-build: a simulator is still running -- NOT writing the boot block"
        rc=1
    else
        dd if="$ROOT/v10/source/src/lsys/boot/bb/4kb" of="$OUT" \
           bs=512 count=1 conv=notrunc 2>/dev/null
        n=$(dd if="$OUT" bs=512 count=1 2>/dev/null | tr -d '\0' | wc -c | tr -d ' ')
        echo "== boot block: $n of 512 bytes non-zero =="
        [[ "$n" -gt 400 ]] || { echo "v10-build: the boot block did not land"; rc=1; }
    fi
fi

echo
echo "== v10-build =="
echo "   image    $OUT"
echo "   builder  $(basename "$BUILDER")  (cloned; the original is untouched)"
echo "   log      $LOG"
echo "== v10-build exit $rc =="
exit "$rc"
