#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/norun.sh"

IMG="${1:-$ROOT/work/v10gold/ipnx-v10-made.img.pre-k16}"
PORT="${2:-9350}"
TPORT=$(( PORT + 1 ))
NETFSD="$ROOT/netfs/.build/release/netfsd"

no_overlap "$IMG" || exit 1
[[ -x "$NETFSD" ]] || ( cd "$ROOT/netfs" && swift build -c release ) || exit 1

"$NETFSD" -p "$PORT"  -v "$ROOT/v10"   > "$ROOT/work/netfs-v10.log"   2>&1 & NETPID=$!
"$NETFSD" -p "$TPORT" -v "$ROOT/tapes" > "$ROOT/work/netfs-tapes.log" 2>&1 & TAPEPID=$!
trap 'kill "$NETPID" "$TAPEPID" 2>/dev/null' EXIT

expect "$ROOT/tools/v10-launch.exp" "$IMG"
