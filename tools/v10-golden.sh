#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/norun.sh"

GOLD="$ROOT/images/v10"
OUT="$ROOT/images/v10-golden"
PORT="${1:-9350}"
TPORT=$(( PORT + 1 ))
NETFSD="$ROOT/netfs/.build/release/netfsd"
NETPID=""; TAPEPID=""
trap 'kill $NETPID $TAPEPID 2>/dev/null' EXIT

no_overlap "$GOLD" "$OUT" || exit 1
[[ -x "$NETFSD" ]] || ( cd "$ROOT/netfs" && swift build -c release ) || exit 1

"$NETFSD" -p "$PORT"  -v "$ROOT/v10"   > "$ROOT/work/netfs-v10.log"   2>&1 & NETPID=$!
"$NETFSD" -p "$TPORT" -v "$ROOT/tapes" > "$ROOT/work/netfs-tapes.log" 2>&1 & TAPEPID=$!

rm -f "$OUT"
dd if=/dev/zero of="$OUT" bs=1 count=0 seek=$(( 3920490 * 512 )) 2>/dev/null

expect "$ROOT/tools/v10-golden.exp" "$GOLD" "$OUT"
