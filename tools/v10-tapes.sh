#!/usr/bin/env bash
#
# Fetch the six V10 archives and decompress them for the guest.
#
#	bash tools/v10-tapes.sh          # -> work/tapes/*.tar
#
# THE HOST HALF OF THE BOOTSTRAP, AND ONLY THAT.  Everything about the shape of
# the tree is decided on the machine, by v10/usr/src/build/mkv10 -- which
# extracts these six, applies build/casenames, and writes v10.tar.
# docs/v10-build.md is the whole of it.
#
# TWO REASONS THE HOST HAS TO DO THIS, both of them about 1989.  www.tuhs.org
# answers plain HTTP with a 301 to https and V10 HAS NO TLS; and neither .gz nor
# .bz2 existed -- gzip is 1992, bzip2 1996 -- so cmd/ carries compress(.Z) and
# pack(.z) and nothing that reads these.  DECOMPRESSING IS NOT EXTRACTING, so
# doing it here costs nothing and decides nothing: the guest gets the only
# format its tar can read, and the case collisions stay the machine's problem,
# settled on a case-sensitive filesystem where the tape's own names survive.
#
# THE SIX:
#	norman      /usr/src, the larger of the two source tapes
#	secombe     /usr/src from a DIFFERENT machine -- newer in places
#	milligan    /usr/jerq, the 5620 distribution
#	sellers     /usr/man and vol2, the documentation
#	r70include  /usr/include, r70's reconstruction
#	blit        the 68000 Blit, a different terminal
#
# THIS USED TO EXTRACT THEM TOO, into a pristine v10tapes/ that fed a host-side
# reconstruction: v10-tree.py merged them into a corpus and v10-dist.py shaped
# that into v10/.  The machine does all of it now, so those 300 lines went with
# the corpus.  What they knew is not lost -- mkv10 reads the tapes through a
# PIPE (tar's endtape() calls backtape(), an MTIOCTOP ioctl that tolerates only
# ENOTTY, so an archive opened off a netfs share dies at the end-of-archive
# block), and build/casenames carries the case decisions with the evidence for
# each.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
W="$ROOT/work"

# FETCHED HERE, ON THE HOST, and nowhere else.  The guest cannot do it and the
# reason is not effort: www.tuhs.org answers plain HTTP with 301 to https and
# V10 has no TLS, and neither .gz nor .bz2 existed in 1989 -- gzip is 1992,
# bzip2 1996 -- so cmd/ carries compress(.Z) and pack(.z) and nothing that
# reads these.  Two of the six keep a v10- prefix they do not have at TUHS.
#
mkdir -p "$W"
CROSS=https://www.tuhs.org/Archive/Distributions/Research/Dan_Cross_v10
NORMAN=https://www.tuhs.org/Archive/Distributions/Research/Norman_v10
fetch() {
    [[ -s "$W/$1" ]] && return 0
    echo "   fetch $1"
    curl -fsSL --retry 3 -o "$W/$1.part" "$2/$3" || {
        echo "v10-tapes: could not fetch $2/$3" >&2; rm -f "$W/$1.part"; return 1; }
    mv "$W/$1.part" "$W/$1"
}
echo "== six archives =="
fetch v10src.tar.bz2    "$CROSS"  v10src.tar.bz2    || exit 1
fetch v10blit.tar.bz2   "$CROSS"  v10blit.tar.bz2   || exit 1
fetch v10-secombe.gz    "$NORMAN" secombe.gz        || exit 1
fetch v10-milligan.gz   "$NORMAN" milligan.gz       || exit 1
fetch v10-sellers.gz    "$NORMAN" sellers.gz        || exit 1
fetch r70include.tar    "$NORMAN" r70include.tar    || exit 1

# PLAIN TAR FOR THE GUEST.  mktape extracts on V10, where the filesystem is
# case-sensitive and the collisions this script spends its header on do not
# arise; decompressing is not extracting, so doing it here costs nothing and
# gives the guest the only format its tar can read -- gzip is 1992 and bzip2
# 1996, so a 1989 system has neither.  430 MB, against 1,533 MB of /usr.
# r70include is already plain tar, so it is copied rather than decompressed.
echo "== plain tar for the guest =="
mkdir -p "$W/tapes"
plain() {
    [[ -s "$W/tapes/$2" ]] && return 0
    echo "   $2"
    case $1 in
    *.bz2) bzcat  "$W/$1" > "$W/tapes/$2.part" ;;
    *)     gzcat  "$W/$1" > "$W/tapes/$2.part" ;;
    esac || { echo "v10-tapes: could not decompress $1" >&2
              rm -f "$W/tapes/$2.part"; return 1; }
    mv "$W/tapes/$2.part" "$W/tapes/$2"
}
plain v10src.tar.bz2  v10src.tar   || exit 1
plain v10blit.tar.bz2 v10blit.tar  || exit 1
plain v10-secombe.gz  secombe.tar  || exit 1
plain v10-milligan.gz milligan.tar || exit 1
plain v10-sellers.gz  sellers.tar  || exit 1
cp -f "$W/r70include.tar" "$W/tapes/r70include.tar" || exit 1
