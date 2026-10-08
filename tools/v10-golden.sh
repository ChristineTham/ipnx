#!/usr/bin/env bash
# Boot a throwaway copy of the golden.  One disk, no netfsd.
# The copy is deleted on exit -- booting mounts, and mounting rewrites the
# superblock, so the golden itself is never attached.
#
#	bash tools/v10-golden.sh [IMAGE]           the console is this terminal
#	bash tools/v10-golden.sh --check [IMAGE]   unattended: boot, log in, halt
#
# WITHOUT --check THIS IS A CONSOLE, NOT A CHECK.  simh's console is the
# caller's terminal and the guest waits at login: for whoever is there, so it
# never exits by itself.  ^E ends it: simh makes ^E the terminal's interrupt
# character while the machine runs (sim_console.c), and the stop falls through
# to the `q' after `run' below.  CLAUDE.md listed this among the checks that
# decide whether a change is done, and on 8 Oct 2026 a run with nobody at the
# terminal sat at login: for ten minutes until the simulator was killed.
#
# --check ASKS THE SAME QUESTION UNATTENDED, through tools/v10drive.py rather
# than a third prompt matcher: it matches markers, strips the mark parity
# getty's first login: arrives with, and halts through /etc/down instead of
# dropping the machine.  An empty script, so the check is exactly the boot, a
# login as root, a shell that answers and a clean halt.  The exit status is
# v10drive's:
#	0  booted, logged in, answered, halted cleanly
#	1  refused before booting: a simulator already running, the image held
#	   by a writer, or the copy failed
#	2  no login: -- simh stopped, fsck -p dropped the boot to single user,
#	   or nothing came in 900 s
#	3  login: came and the shell never answered
#	4  /etc/down refused the halt twice
# and the console of every check is left in run/v10-golden-check.log.
set -uo pipefail
# DERIVED, NEVER WRITTEN DOWN.  This was a hardcoded /Users path, so the
# launcher worked on exactly one machine and silently pointed at nothing
# anywhere else -- including in a checkout of this repository beside it.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CHECK=
if [ "${1:-}" = --check ]; then
    CHECK=1
    shift
fi
IMG="${1:-$ROOT/run/v10-golden}"
COPY="$ROOT/run/v10-golden-test.img"
ROM="$ROOT/run/uda"
CONF="$ROOT/run/v10-golden-test.conf"

# A CHECK REFUSES BEFORE IT TOUCHES THE COPY.  v10drive.py refuses a second
# simulator too, but only after this script has replaced $COPY -- and $COPY is
# the disk an interactive run of this same script boots, so a check started
# beside one would rm the file out from under it.  And a golden someone is
# writing -- v10-launch.sh attaches it as the second drive, v10-reset.sh
# extracts over it -- would be copied half-made.  tools/norun.sh asks both.
if [ -n "$CHECK" ]; then
    source "$ROOT/tools/norun.sh"
    no_overlap "$IMG" || exit 1
fi
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

# THE CHECK.  v10drive writes its own conf, and its device set is this
# script's below -- its comment says so and the two are kept the same -- so the
# machine checked is the machine you would watch.  The script file names the
# log: v10drive writes SCRIPT.log beside it.
if [ -n "$CHECK" ]; then
    CMDS="$ROOT/run/v10-golden-check"
    echo "# tools/v10-golden.sh --check: no commands -- boot, login:, a shell, a halt" > "$CMDS"
    T0=$SECONDS
    python3 "$ROOT/tools/v10drive.py" "$COPY" "$CMDS"
    ST=$?
    if [ "$ST" -eq 0 ]; then
        echo "v10-golden: ok -- $IMG booted to login:, a shell answered and it halted cleanly, in $((SECONDS - T0)) s"
    else
        echo "v10-golden: FAILED, status $ST -- the console is in $CMDS.log" >&2
    fi
    exit "$ST"
fi

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
