#!/usr/bin/env bash
# Boot a throwaway copy of the golden.  One disk, no netfsd.
# The copy is deleted on exit -- booting mounts, and mounting rewrites the
# superblock, so the golden itself is never attached.
set -uo pipefail
# DERIVED, NEVER WRITTEN DOWN.  This was a hardcoded /Users path, so the
# launcher worked on exactly one machine and silently pointed at nothing
# anywhere else -- including in a checkout of this repository beside it.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IMG="${1:-$ROOT/run/v10-golden}"
COPY="$ROOT/run/v10-golden-test.img"
ROM="$ROOT/run/uda"
CONF="$ROOT/run/v10-golden-test.conf"
trap 'rm -f "$COPY"' EXIT

rm -f "$COPY"
# A CHEAP COPY WHERE THE FILESYSTEM CAN, A REAL ONE WHERE IT CANNOT.  `cp -c'
# is macOS's clonefile and GNU cp REJECTS IT OUTRIGHT -- `cp: invalid option --
# c' -- so this script failed on the one machine CLAUDE.md promises the golden
# boots on: a plain Linux container with open-simh built from source.  It exited
# before the simulator ever started, and `set -uo pipefail' without -e meant the
# whole script still exited 0, so it read as a passing check.
#
# --reflink=auto is GNU's equivalent and degrades to a full copy by itself;
# --sparse=always keeps a 1.9 GB image at the ~500 MB it actually occupies.
# v8clone.sh has had this fallback for as long as it has existed (:51-59).
cp -c "$IMG" "$COPY" 2>/dev/null \
    || cp --reflink=auto --sparse=always "$IMG" "$COPY" 2>/dev/null \
    || cp "$IMG" "$COPY" \
    || exit 1

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
