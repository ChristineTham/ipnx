#!/usr/bin/env bash
set -uo pipefail
# DERIVED, NEVER WRITTEN DOWN.  This was a hardcoded /Users path, so the
# launcher worked on exactly one machine and silently pointed at nothing
# anywhere else -- including in a checkout of this repository beside it.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IMG="${1:-$ROOT/run/v10}"
# 9200 and 9201 are the app's own share ports -- FileShare.swift:46 gives
# .macos 9200 and .home 9201 -- and /etc/rc mounts them at /n/macos and
# /n/home, so the machine sees what the app serves.
PORT="${2:-9200}"
HPORT=$(( PORT + 1 ))
# 9P, NOT netfs, BECAUSE THE GOLDEN SPEAKS 9P NOW.  /etc/rc mounts both shares
# with `runfs /n/macos /etc/9pfs 10.0.2.2 9200', so what has to be listening on
# these ports is a 9P2000.u server.  netfs is not gone -- it is V8's protocol
# and netfs/ and tools/netfsd.py stay for it -- it is simply not what this
# machine asks for any more.
#
# THE PYTHON ONE, because it is the only 9P server this project has: the app
# still embeds the Swift NetFS target and a Swift 9P server is not written yet.
# python3 is enough and needs no toolchain.
NINEP="$ROOT/tools/9pfsd.py"
ROM="$ROOT/run/uda"
NEW="$ROOT/run/v10-golden"
CONF="$ROOT/run/v10.conf"
NETPID=""; HOMEPID=""
trap 'kill $NETPID $HOMEPID 2>/dev/null' EXIT

# /n/macos IS THE HOST SYSTEM ROOT AND IS SERVED READ-ONLY.  9pfsd defaults to
# read-only, so the absence of -w here is the whole guard and must stay absent:
# the guest can read the Mac and can write nothing on it.  /n/home is the
# user's own home and is read/write.
#
# -L ON BOTH, and it is not optional for a real tree.  9P2000.u describes a
# symlink and netb's <rf.h> has nowhere to put one -- an Rfile is RFTREG or
# RFTDIR and nothing else -- so without -L every symlink under the share is
# visible to the guest and unreadable.  A home directory has plenty.
MACOS="${MACOS:-/}"
python3 "$NINEP" -L    -p "$PORT"  "$MACOS" & NETPID=$!
python3 "$NINEP" -L -w -p "$HPORT" "$HOME"  & HOMEPID=$!

# THE DEVICE SET IS THE KERNEL'S, NOT A PREFERENCE.  simh assigns Unibus
# addresses by DEC's floating-address algorithm at configure time
# (IOBA_AUTO/VEC_AUTO), so an address is a property of the SET of devices
# enabled and of the order they are enabled in -- turning on the fourth MSCP
# controller moved the Interlan from 0764000 to 0764040 when this was measured.
# ipnx-v10.m carries those measured addresses compiled in, and lists the seven
# lines it was measured against; they are reproduced below in its order.  Enable
# something else here, or in another order, and the kernel probes empty
# addresses -- autoconfig finds nothing, and the failure shows up later as a
# device that does not work rather than as a boot that stops.
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
attach rq0 $IMG
set rq1 ra73
attach rq1 $NEW
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
