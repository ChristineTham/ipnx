#!/bin/sh
# Test the GUEST's 9P client on the HOST, without a simulator.
#
#	tools/9pfs-test.sh
#
# v10/usr/src/build/src/9pfs.c is a V10 program: it implements libnetb's
# thirteen <rf.h> callbacks in terms of 9P2000.u, and V10's kernel reaches it
# through a pipe (see its header comment).  The netb half is Bell Labs' on both
# sides and needs no testing from us.  The 9P half is ours, it is where every
# marshalling bug will be, and it does not need a VAX to exercise: the file is
# ordinary C and the only V10-specific things it calls are tcp_sock(),
# tcp_connect() and in_address().
#
# So this stubs exactly those three plus libnetb's five globals, links the
# SHIPPING 9pfs.c unmodified against a driver that calls the callbacks in
# anger, and points it at a real tools/9pfsd.py.  Under a second, no kernel
# build, no boot, no fsck.  That is the whole argument for the bridge living in
# userland rather than in fs/net9.c, and it is worth keeping.
#
# THE ONE EDIT, and it is mechanical: `extern int errno;' is correct for V10
# and impossible on glibc, where errno is a macro.  The line is commented out
# in a scratch copy and nothing else is touched -- the diff is asserted below
# so this cannot quietly grow.
set -e
cd "$(dirname "$0")/.."
ROOT=$(pwd)
SRC=$ROOT/v10/usr/src/build/src/9pfs.c
T=$(mktemp -d)
trap 'rm -rf "$T"; kill $RO $RW 2>/dev/null || true' EXIT

sed 's|^extern int errno;$|/* harness: glibc makes errno a macro */|' "$SRC" > "$T/9pfs.c"
if [ "$(diff "$SRC" "$T/9pfs.c" | grep -c '^[<>]')" != 2 ]; then
	echo "9pfs-test: the errno substitution changed more than one line -- look at it" >&2
	exit 1
fi

cc -std=gnu89 -w -I "$ROOT/tools/9pfs-test/stub" -I "$ROOT/v10/usr/src/netfs/libnetb" \
   -o "$T/t9" "$T/9pfs.c" "$ROOT/tools/9pfs-test/drive.c"

mkdir -p "$T/ro/sub" "$T/rw/sub"
for d in ro rw; do
	echo "hello, world"                        > "$T/$d/hello"
	head -c 3000 /dev/zero | tr '\0' x         > "$T/$d/sub/deep"
	echo long                                  > "$T/$d/a_very_long_filename"
	ln -s hello "$T/$d/link"
done

python3 "$ROOT/tools/9pfsd.py"    -p 15700 "$T/ro" >/dev/null 2>&1 & RO=$!
python3 "$ROOT/tools/9pfsd.py" -w -p 15701 "$T/rw" >/dev/null 2>&1 & RW=$!
i=0
while [ $i -lt 100 ]; do
	if "$T/t9" 127.0.0.1 15700 >/dev/null 2>&1; then break; fi
	i=$((i+1)); sleep 0.05
done

rc=0
echo "read-only share"
"$T/t9" 127.0.0.1 15700    || rc=1
echo "read-write share"
"$T/t9" 127.0.0.1 15701 rw || rc=1
exit $rc
