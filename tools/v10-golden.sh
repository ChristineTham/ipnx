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

# The same device set, in the same order, as v10-launch.sh -- ipnx-v10.m
# carries measured Unibus addresses and they are a property of the set and its
# order, so a test that enables anything else tests a different machine.  One
# disk is the only difference: attaching fewer drives does not float addresses,
# enabling fewer devices does.
cat > "$CONF" <<EOF
set noasynch
set cpu 128m
set vh disable
set rq enable
set rqb enable
set rqc enable
set rqd enable
set tq enable
set dz enable
set dz lines=32
set il enable
set il address=2013E800
set il vector=E8
set tto 7b
set rq0 ra73
attach rq0 $COPY
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
