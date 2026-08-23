#!/usr/bin/env bash
# Boot a throwaway copy of the golden.  One disk, no netfsd.
# The copy is deleted on exit -- booting mounts, and mounting rewrites the
# superblock, so the golden itself is never attached.
set -uo pipefail
ROOT="/Users/christie/Repositories/Unix/ipnx"

IMG="${1:-$ROOT/images/v10-golden}"
COPY="$ROOT/work/v10-golden-test.img"
ROM="$ROOT/images/uda"
CONF="$ROOT/images/v10-golden-test.conf"
trap 'rm -f "$COPY"' EXIT

rm -f "$COPY"
cp -c "$IMG" "$COPY" || exit 1

cat > "$CONF" <<EOF
set noasynch
set cpu 8m
set dz enable
set dz lines=8
set tto 7b
set rq0 ra73
attach rq0 $COPY
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
