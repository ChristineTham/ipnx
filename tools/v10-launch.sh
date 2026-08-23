#!/usr/bin/env bash
set -uo pipefail
ROOT="/Users/christie/Repositories/Unix/ipnx"

IMG="${1:-$ROOT/images/v10}"
# 9200 and 9201 are the app's own share ports -- FileShare.swift:46 gives
# .macos 9200 and .home 9201 -- and /etc/rc mounts them at /n/macos and
# /n/home, so the machine sees what the app serves.
PORT="${2:-9200}"
HPORT=$(( PORT + 1 ))
NETFSD="$ROOT/netfs/.build/release/netfsd"
ROM="$ROOT/images/uda"
NEW="$ROOT/images/v10-golden"
CONF="$ROOT/images/v10.conf"
NETPID=""; HOMEPID=""
trap 'kill $NETPID $HOMEPID 2>/dev/null' EXIT

# /n/macos IS THE HOST SYSTEM ROOT AND IS SERVED READ-ONLY.  netfsd defaults
# readOnly (main.swift:21), so the absence of -w here is the whole guard and
# must stay absent: the guest can read the Mac and can write nothing on it.
# /n/home is the user's own home and is read/write.
MACOS="${MACOS:-/}"
"$NETFSD"    -p "$PORT"  "$MACOS" & NETPID=$!
"$NETFSD" -w -p "$HPORT" "$HOME"  & HOMEPID=$!

cat > "$CONF" <<EOF
set noasynch
set cpu 8m
set dz enable
set dz lines=8
set tto 7b
set rq0 ra73
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
