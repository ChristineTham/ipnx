#!/usr/bin/env bash
set -uo pipefail
ROOT="/Users/christie/Repositories/Unix/ipnx"

IMG="${1:-$ROOT/images/v10}"
PORT="${2:-9350}"
TPORT=$(( PORT + 1 ))
NETFSD="$ROOT/netfs/.build/release/netfsd"
ROM="$ROOT/images/uda"
NEW="$ROOT/images/v10-golden"
CONF="$ROOT/images/v10.conf"
NETPID=""; TAPEPID=""
trap 'kill $NETPID $TAPEPID 2>/dev/null' EXIT

"$NETFSD" -p "$PORT"  -v "$ROOT/v10" & NETPID=$!
"$NETFSD" -p "$TPORT" -v "$ROOT/tapes" & TAPEPID=$!

cat > "$CONF" <<EOF
set noasynch
set cpu 8m
set dz enable
set dz lines=8
set tto 7b
set rq0 ra81
attach rq0 $IMG
set rq1 ra73
attach rq1 $NEW
set il enable
set il address=2013E800
set il vector=E8
attach il nat:
load -o $ROM FA00
dep sp 200
dep r1 0
dep r3 0
dep r5 0
run FA02
q
EOF

"$ROOT/work/opensimh/BIN/vax780" $CONF
