#!/usr/bin/env bash
#
# Launch the Tenth Edition golden, logged in, with this repository's v10/
# mounted on /n/v10 and the network up.
#
#	tools/v10-launch.sh [image] [port]
#
# THE MACHINE.  A VAX-11/780 with the golden on rq0, booted by the tape's own
# ROM (v10/usr/sys/boot/star/uda), plus an Interlan on NAT.  /etc/rc brings il0
# up at 10.0.2.15 with 10.0.2.2 as the gateway -- and 10.0.2.2 is this host,
# which is how the guest reaches the netfsd this script starts.
#
# WHY THIS IMAGE.  work/v10gold holds ~45 images and only some are a system.
# ipnx-v10-made.img.pre-k16 is verified: it reaches `login:', accepts root on
# the first try, and gives a shell.  v10-golden.img -- the OUTPUT of
# tools/v10-build.sh -- reaches `login:' and then the session dies instantly
# on every attempt, so it is not a machine you can log into.
#
# THE CONSOLE IS THIS TERMINAL, so ^E is SIMH's stop character: it drops you to
# `sim>' with the guest still running, and `c' resumes.  A telnet console would
# make ^E an ordinary byte, but then a client that closes the socket takes the
# machine down with it, which is worse.
#
# HOW TO STOP IT -- the rule that outranks everything else here.  A machine
# that was not cleanly halted has a corrupted disk.  V10's kernel does not sync
# on halt (lsys/md/machdep.c's boot() is two lines), so the userland sync is
# the whole flush, and V10 records in the superblock that a filesystem is
# mounted, so skipping the umount makes the next boot answer `In use' and carry
# on with an empty /usr showing through.
#
#	/etc/umount /n/v10
#	cd /; sync; sync
#	/etc/umount -a
#	sync
#	/etc/halt          <- wait for `death', THEN ^E and `quit'
#
# THIS BOOTS THE IMAGE ITSELF, not a copy, so the machine keeps what you do to
# it -- and loses it if you kill the simulator instead of halting it.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/norun.sh"

IMG="${1:-$ROOT/work/v10gold/ipnx-v10-made.img.pre-k16}"
PORT="${2:-9350}"
SIM="$ROOT/work/opensimh/BIN/vax780"
ROM="$ROOT/v10/usr/sys/boot/star/uda"
NETFSD="$ROOT/netfs/.build/release/netfsd"

[[ -f "$IMG" ]] || { echo "v10-launch: no image at $IMG" >&2; exit 1; }
[[ -x "$SIM" ]] || { echo "v10-launch: no simulator at $SIM" >&2; exit 1; }
[[ -f "$ROM" ]] || { echo "v10-launch: no boot rom at $ROM" >&2; exit 1; }
no_overlap "$IMG" || exit 1

if [[ ! -x "$NETFSD" ]]; then
    echo "== building netfsd =="
    ( cd "$ROOT/netfs" && swift build -c release ) || exit 1
fi

NETLOG="$ROOT/work/netfs-launch.log"
"$NETFSD" -p "$PORT" -v "$ROOT/v10" > "$NETLOG" 2>&1 &
NETPID=$!
trap 'kill "$NETPID" 2>/dev/null' EXIT
sleep 1
kill -0 "$NETPID" 2>/dev/null || { echo "v10-launch: netfsd died" >&2; tail -5 "$NETLOG" >&2; exit 1; }

echo "== Research UNIX, Tenth Edition -- VAX-11/780 =="
echo "   image    $(basename "$IMG")"
echo "   sha256   $(shasum -a 256 "$IMG" | cut -c1-16)"
echo "   serving  $ROOT/v10  ->  /n/v10   (port $PORT, pid $NETPID)"
echo
echo "   Booting, logging in and mounting; the console is yours after that."
echo

expect "$ROOT/tools/v10-launch.exp" "$IMG" "$PORT"
rc=$?
kill "$NETPID" 2>/dev/null
exit $rc
