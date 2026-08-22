#!/usr/bin/env bash
#
# A source disk, made BY V10, on partition h.
#
#	bash tools/v10-srcdisk10.sh [builder-image]
#
# Produces work/v10gold/v10-src10.img: a whole-drive 435 MB filesystem holding
# the tape's src/ at the top, so it mounts as /usr/src.
#
# WHY NOT tools/v10-srcdisk.sh.  That one is V8-HOSTED -- it boots the Eighth
# Edition and compiles `v10mkbitfs' with V8's cc -- and V8 is out of the V10
# build.  It is left untouched; this is a separate tool, not an edit to it.
#
# NOTHING IS COMPILED HERE either: the builder already carries /etc/mkbitfs.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/norun.sh"

GOLD="$ROOT/work/v10gold"
BUILDER="$GOLD/${1:-ipnx-v10-made.img.pre-k16}"
OUT="$GOLD/${V10_OUT:-v10-src10.img}"
CLONE="$GOLD/src10-builder.img"
LOG="$ROOT/work/srcdisk10.log"
NETFSD="$ROOT/netfs/.build/release/netfsd"
TPORT="${TPORT:-9320}"

[[ -e "$BUILDER" ]]        || { echo "v10-srcdisk10: no $BUILDER"; exit 1; }
[[ -d "$ROOT/work/v10" ]]  || { echo "v10-srcdisk10: no work/v10 -- run tools/v10-import.py"; exit 1; }

no_other_sims || exit 1

( cd "$ROOT/netfs" && swift build -c release ) >/dev/null || exit 1

PIDS=()
trap 'for p in "${PIDS[@]:-}"; do kill "$p" 2>/dev/null; done' EXIT
"$NETFSD" -p "$TPORT" -v "$ROOT/work/v10" > "$ROOT/work/netfs-src10.log" 2>&1 & PIDS+=($!)
sleep 1
kill -0 "${PIDS[0]}" 2>/dev/null || { echo "netfsd died"; exit 1; }

# A BLANK DISK, SPARSE, CREATED FRESH EVERY RUN.
#
# `dd if=/dev/zero count=891072' writes 456 MB of real zeros and allocates
# every block on APFS.  A sparse file reads identically -- an unwritten region
# reads as zeros -- and allocates only what the guest actually writes.
#
# THE ZEROING RULE IS ABOUT REUSE, NOT ABOUT ZEROS.  CLAUDE.md requires a file
# recreated from /dev/zero before a committed artefact because mkbitfs does not
# clear data blocks, so a REUSED file leaves the previous run's contents in what
# the new filesystem calls free space: invisible to the guest, very visible to a
# compressor.  `rm' then a fresh sparse file has no previous contents at all, so
# it meets that requirement without allocating 456 MB.
echo "== making a blank RA81 (891,072 sectors = 456 MB, sparse) =="
rm -f "$OUT"
dd if=/dev/zero of="$OUT" bs=1 count=0 seek=456228864 2>/dev/null
[[ $(stat -f%z "$OUT") == 456228864 ]] || { echo "v10-srcdisk10: blank is the wrong size"; exit 1; }

# The builder is CLONED: booting mounts, and mounting rewrites the superblock.
rm -f "$CLONE"
cp -c "$BUILDER" "$CLONE" 2>/dev/null || cp "$BUILDER" "$CLONE"

expect "$ROOT/tools/v10-srcdisk10.exp" "$CLONE" "$OUT" "$TPORT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}

echo
echo "== the source disk =="
echo "   built by   $(basename "$BUILDER") -- V10, not V8"
echo "   image      $OUT"
echo "   mount it   attach rq1 <this>, then /etc/mount /dev/ra1h /usr/src"
echo "== v10-srcdisk10 exit $rc =="
exit "$rc"
