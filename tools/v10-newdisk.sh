#!/usr/bin/env bash
#
# A new V10 disk: the pristine reference, the tape's binaries, the good kernel.
#
#	bash tools/v10-newdisk.sh
#
# Three things and nothing else.  Nothing is compiled and no filesystem is
# created: the reference image already carries V10 filesystems Bell Labs' own
# mkbitfs made.  No Eighth Edition is read anywhere.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/norun.sh"

GOLD="$ROOT/work/v10gold"
GOLDEN="$GOLD/ipnx-v10-made.img.pre-k16"   # has ipnx780, /etc/mkbitfs and netfs
OUT="$GOLD/v10-newdisk.img"
LOG="$ROOT/work/newdisk.log"
NETFSD="$ROOT/netfs/.build/release/netfsd"
TPORT="${TPORT:-9310}"; MPORT="${MPORT:-9311}"

[[ -e "$GOLDEN" ]] || { echo "v10-newdisk: no current golden"; exit 1; }
[[ -d "$ROOT/work/v10" ]] || { echo "v10-newdisk: no work/v10";  exit 1; }
python3 "$ROOT/tools/v10-tapebins.py" --check >/dev/null || {
    echo "v10-newdisk: tapebins.txt is stale"; exit 1; }

no_other_sims || exit 1

( cd "$ROOT/netfs" && swift build -c release ) >/dev/null || exit 1

PIDS=()
trap 'for p in "${PIDS[@]:-}"; do kill "$p" 2>/dev/null; done' EXIT
"$NETFSD" -p "$TPORT" -v "$ROOT/work/v10"   > "$ROOT/work/netfs-nd-t.log" 2>&1 & PIDS+=($!)
"$NETFSD" -p "$MPORT" -v "$ROOT/v10/mk/gen" > "$ROOT/work/netfs-nd-m.log" 2>&1 & PIDS+=($!)
sleep 1
for p in "${PIDS[@]}"; do kill -0 "$p" 2>/dev/null || { echo "netfsd died"; exit 1; }; done

# The REFERENCE is never written: it is cloned to the output, and the builder
# is cloned too, because booting mounts and mounting rewrites the superblock.
# A BLANK disk from zero every run: mkbitfs does not clear data blocks, so a
# reused file leaves the previous run's contents in what the new filesystem
# calls free space.
echo "== making a blank RA81 =="
rm -f "$OUT"; dd if=/dev/zero of="$OUT" bs=1m count=436 2>/dev/null
# The golden is CLONED, never booted directly: booting mounts, and mounting
# rewrites the superblock.
CLONE="$GOLD/nd-builder.img"
rm -f "$CLONE"; cp -c "$GOLDEN" "$CLONE" 2>/dev/null || cp "$GOLDEN" "$CLONE"

expect "$ROOT/tools/v10-newdisk.exp" "$CLONE" "$OUT" "$TPORT" "$MPORT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}

copied=$(sed -n '/^COPIED$/,/^COPIEDEND$/p' "$LOG" | grep -oE '^[0-9]+' | head -1)
want=$(grep -vcE '^#|^[[:space:]]*$' "$ROOT/v10/mk/gen/tapebins.txt")
echo
echo "== the new disk =="
echo "   made by         $(basename "$GOLDEN")'s own /etc/mkbitfs"
echo "   tape binaries   ${copied:-?} of ${want:-?}"
echo "   image           $OUT"
echo "== v10-newdisk exit $rc =="
exit "$rc"
