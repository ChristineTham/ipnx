#!/usr/bin/env bash
#
# Restore run/ -- the working set tools/v10-launch.sh boots.
#
#	bash tools/v10-reset.sh
#
# Three things go in there and all three are reproducible: the two disks, from
# the committed archives, and the boot ROM, which is v10/usr/sys/boot/star/uda
# byte for byte.  The ROM is COPIED rather than extracted: the archives hold
# disks and nothing else, so a reset that only unpacked them left both
# launchers pointing at a run/uda that was not there, and simh answers that
# by running from an unloaded address rather than by saying so.
#
# `tar -xSjf', never without the S: it is the only standard format that
# restores a HOLE, so a 1.9 GB RA73 costs its non-zero bytes on disk.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="$ROOT/image"
OUT="$ROOT/run"

mkdir -p "$OUT" || exit 1

# GIT LFS, AND IT FAILS QUIETLY.  An unfetched pointer is a 132-byte text file,
# and tar rejects it with `not a bzip2 file' -- true, and no help at all about
# why.  132 bytes is not a disk image; say which command fixes it.
lfscheck() {
	[ -f "$1" ] || { echo "v10-reset: no ${1#"$ROOT/"}" >&2; return 1; }
	head -c 40 "$1" | grep -q 'git-lfs.github.com' || return 0
	echo "v10-reset: ${1#"$ROOT/"} is an unfetched LFS pointer -- run: git lfs pull" >&2
	return 1
}

lfscheck "$IMAGE/v10.tar.bz2" || exit 1
tar -xSjf "$IMAGE/v10.tar.bz2" -C "$OUT" || exit 1

# THE GOLDEN IS COMMITTED IN HALVES of 72,675,231 bytes, because GitHub refuses
# a file over 100 MB and .gitattributes' LFS filter matches `image/*.tar.bz2'
# and so does not take the .aa/.ab suffixes.  Joining them is part of a reset
# rather than a step somebody is expected to remember -- this script used to
# name a v10-golden.tar.bz2 that has never existed in a fresh clone.
#
# PIPED, NOT JOINED ON DISK.  `cat ... > image/v10-golden.tar.bz2' leaves a
# 145 MB file that .gitignore's `!image/*.tar.bz2' exception does NOT ignore,
# so it shows up untracked and invites exactly the commit the halves exist to
# prevent.  -S governs how tar WRITES the image, so a non-seekable input costs
# nothing: the holes still come back as holes.
if [ -f "$IMAGE/v10-golden.tar.bz2" ]; then
	lfscheck "$IMAGE/v10-golden.tar.bz2" || exit 1
	tar -xSjf "$IMAGE/v10-golden.tar.bz2" -C "$OUT" || exit 1
else
	set -- "$IMAGE"/v10-golden.tar.bz2.a?
	[ -f "$1" ] || { echo "v10-reset: no golden archive and no halves beside it" >&2; exit 1; }
	cat "$@" | tar -xSjf - -C "$OUT" || exit 1
fi

# The ROM the two launchers load at FA00.  Copied, not built: uda.s is the
# source beside it and nothing here assembles a VAX.
cp "$ROOT/v10/usr/sys/boot/star/uda" "$OUT/uda" || exit 1

ls -l "$OUT"
