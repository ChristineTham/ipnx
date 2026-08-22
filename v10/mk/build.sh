#!/bin/sh
# THE BUILD, ONE STAGE AT A TIME, DRIVEN BY THE PLAN.
#
#	sh build.sh <stage> <tape> <ours> <plan> <obj> <dest> <cc> <bprefix>
#
#	stage    1 2 4 5 6 7 8
#	tape     the mounted v10/source
#	ours     the mounted v10/src
#	plan     the directory holding v10-plan.md
#	obj      scratch on a writable filesystem
#	dest     THE NEW IMAGE, mounted -- $DEST for every install
#	cc       the driver to use
#	bprefix  -B argument: the directory holding the passes
#
# IT READS docs/v10-plan.md AND NOTHING ELSE.  A build that consults a second
# list can disagree with its own plan, which is how a stage came to name a
# makefile nobody generated and a script came to read a list that no longer
# existed.  A component list that appears twice will disagree, silently.
#
# ONE STAGE PER RUN, because each depends on the last: stage 2 compiles with
# the passes stage 1 installed, and stage 6 links against the libraries stage 4
# built.  Running them together hides which one failed.
#
# THE PLAN IS MARKDOWN.  A row is
#
#	| `/bin/ar` | build | `src/cmd` | `ar.o` | `-` | Admin/Mk |
#	  path       method  source      objects  libs  note
#
# and a section is `## Stage N -- Title'.  sed cuts both; nothing here needs a
# parser this guest does not have.
#
# EVERY TOP-LEVEL EXIT PRINTS THE END MARKER.  The driver waits for the
# program's own closing output, so a script that exits silently strands it for
# its whole timeout with a simulator at 100% CPU and no console to reach it.
ST=$1
TAPE=$2
OURS=$3
PLANDIR=$4
OBJ=$5
DEST=$6
CCP=$7
BP=$8

PLAN=$PLANDIR/v10-plan.md
CC="$CCP -B$BP"

# Markers spelled through variables, so the tty's echo of the command carries
# `$P' and not the token.  A literal in the QUESTION counts as an answer.
P=PBUILT
Q=PFAILED
I=PINST
N=PNOINST
E=PEND

if test ! -s $PLAN
then
	echo "no plan at $PLAN"
	echo "$E"
	exit 1
fi

mkdir $OBJ 2>/dev/null
cd $OBJ || { echo "no $OBJ"; echo "$E"; exit 1; }

# Cut this stage's rows.  `## Stage N ' opens it; the next `## Stage ' ends it.
sed -n "/^## Stage $ST /,/^## Stage [0-9] /p" $PLAN |
sed -e "/^| \`/!d" -e 's/^| //' -e 's/ |$//' -e 's/\`//g' -e 's/ | /|/g' > rows

if test ! -s rows
then
	echo "no rows for stage $ST"
	echo "$E"
	exit 0
fi

echo "PSTAGE $ST `sed -n '$=' rows` rows"

# A TALLY CANNOT LIVE IN A SHELL VARIABLE HERE.  1970s sh forks for a compound
# command carrying an input redirection, so `n=' inside `while read ... done <
# file' is lost in a dead child while an `echo >>' survives -- one run reported
# 26 of 26 libraries complete while its own counter said 42 members had not
# built, both numbers written by the same branch.
rm -f ok.cnt no.cnt
while IFS='|' read path meth src objs libs note
do
	name=`echo $path | sed -e 's|.*/||'`
	pdir=`echo $path | sed -e 's|/[^/]*$||'`

	case $meth in
	MISSING)
		echo "$Q $path -- the plan has no source"
		echo . >> no.cnt
		continue
		;;
	mknod)
		# objs is `kind major minor', libs is the mode.  The plan carries
		# them so this needs no second copy of the device table.
		set -- $objs
		/etc/mknod $DEST$path $1 $2 $3 2>/dev/null
		if test -b $DEST$path -o -c $DEST$path
		then	echo . >> ok.cnt
		else	echo "$Q $path"; echo . >> no.cnt
		fi
		continue
		;;
	copy)
		# The source is a path under the tape or under our overlay.
		f=$TAPE/$src
		if test ! -f $f
		then	f=$OURS/`echo $src | sed -e 's|^v10/src/||'`
		fi
		if test -f $f && cp $f $DEST$path
		then	echo . >> ok.cnt
		else	echo "$Q $path"; echo . >> no.cnt
		fi
		continue
		;;
	link)
		# A SECOND NAME FOR A BINARY, and it must be a hard link rather
		# than a copy: edit, ex, vi and view are ONE inode on the tape's
		# own disk, and four copies is four times the space on a root
		# filesystem that finishes 95% full.
		if ln $DEST$pdir/$src $DEST$path 2>/dev/null
		then	echo . >> ok.cnt
		else	echo "$Q $path -> $src"; echo . >> no.cnt
		fi
		continue
		;;
	tree)
		echo "$N $path -- a whole tree, the driver copies it"
		continue
		;;
	esac

	# ------------------------------------------------------------ build ---
	# IN-TREE, AND THAT IS NOT A PREFERENCE.  V10's cpp cannot resolve a
	# QUOTED include for an out-of-tree source and -I does not help: cpp.c
	# loops `for (dirp = dirs + inctype; *dirp; ++dirp)' with inctype 0 for
	# a quoted include, and dirs[0] is a pointer into argv that trmdir()
	# truncated in place -- so it never looks.  Measured 34 times as
	# `Can't find include file defs' with -I on the command line and the
	# header in the same directory.
	SD=$TAPE/$src
	if test ! -d $SD
	then
		echo "$Q $path no source dir $src"
		echo . >> no.cnt
		continue
	fi
	rm -rf w
	mkdir w
	cd w
	# `cp f1 ... fn d' is V10's own -- cmd/cp/cp.c loops -- so a directory
	# in the glob fails that one copy and every other file still lands.
	cp $SD/* . 2>/dev/null
	# AN OBJECT MAY LIVE IN A SIBLING DIRECTORY.  cmd/ccom links
	# `-o comp $(OFILES)' with objects from ../common, so the sources have
	# to come too or the link finds nothing.
	for o in $objs
	do
		case $o in
		../*)	d=`echo $o | sed -e 's|/[^/]*$||'`
			cp $SD/$d/* . 2>/dev/null ;;
		esac
	done
	# OUR OVERLAY WINS.  v10/src holds the named patches; copying it second
	# is what makes them real.
	if test -d $OURS/$src
	then
		cp $OURS/$src/* . 2>/dev/null
	fi
	# THE TAPE SHIPS 1989 OBJECTS BESIDE THE SOURCE and a link over them
	# would pull Bell Labs' bytes into our binary silently -- and in the
	# flattering direction, since they resolve symbols our compile failed
	# to produce.
	rm -f *.o

	# cmd/Admin/Mk: -O for the names in Admin/large, -Od2 for the rest.
	CF="-Od2 -c"
	case $note in
	*-O,*|*' -O '*)	CF="-O -c" ;;
	esac

	rm -f bad.lst
	for o in $objs
	do
		b=`echo $o | sed -e 's|.*/||'`
		stem=`echo $b | sed -e 's|\.o$||'`
		case $b in
		*.a)	continue ;;
		esac
		if test -s $stem.c
		then
			# sed -e 40q CLOSES THE PIPE so a compiler that will not
			# stop gets EPIPE.  An unbounded log once wrote the same
			# include error until 120 MB was gone and the filesystem
			# was blamed -- it had 111.8 MB free.  The status rides
			# the same pipe because a pipeline's $? is sed's and
			# 1970s sh has no PIPESTATUS.
			( $CC $CF $stem.c 2>&1 ; echo "CCST=$?" ) | sed -e 40q > c.log
		elif test -s $stem.s
		then
			( ${BP}../bin/as -o $b $stem.s 2>&1
			  echo "CCST=$?" ) | sed -e 40q > c.log
		elif test -s $stem.y
		then
			# yacc -d, which is the tape's own flag: sixteen makefiles
			# write it outright and four more write $YFLAGS over
			# `YFLAGS = -d'.  It is also what makes y.tab.h exist.
			yacc -d $stem.y > c.log 2>&1
			( $CC $CF y.tab.c 2>&1 ; echo "CCST=$?" ) | sed -e 40q >> c.log
			mv y.tab.o $b 2>/dev/null
		elif test -s $stem.l
		then
			lex $stem.l > c.log 2>&1
			( $CC $CF lex.yy.c 2>&1 ; echo "CCST=$?" ) | sed -e 40q >> c.log
			mv lex.yy.o $b 2>/dev/null
		else
			echo $b >> bad.lst
			continue
		fi
		if test ! -s $b
		then
			echo $b >> bad.lst
		fi
	done

	if test -s bad.lst
	then
		echo "$Q $path"
		sed -e 5q c.log
		echo . >> ../no.cnt
		cd ..
		continue
	fi

	LL=""
	case $libs in
	-)	;;
	*)	LL=$libs ;;
	esac
	OO=`echo $objs | sed -e 's|[^ ]*/||g'`
	rm -f $name
	( $CC -o $name $OO $LL 2>&1 ; echo "LDST=$?" ) | sed -e 40q > l.log
	lst=`sed -e '/^LDST=/!d' -e 's/LDST=//' -e 1q l.log`
	# THREE TESTS, because V10's ld WRITES ITS OUTPUT FILE even when symbols
	# are undefined -- it reports them and clears the execute bits, so
	# `test -s' passes on a binary that cannot run.  That has bitten this
	# project three times: stage 3's `Undefined: _atof', a 310,300-byte
	# kernel linked with _spcdev missing, and a diagnostic that re-ran a
	# failed link and printed success.
	sed -e '/Undefined/!d' -e 1q l.log > u.log
	if test "$lst" = 0 -a -s $name -a ! -s u.log
	then
		echo "$P $name"
		if test -d $DEST$pdir
		then
			if cp $name $DEST$path
			then	echo . >> ../ok.cnt
			else	echo "$N $path"; echo . >> ../no.cnt
			fi
		else
			echo "$N $path no $pdir"; echo . >> ../no.cnt
		fi
	else
		echo "$Q $name"
		sed -e 5q l.log
		echo . >> ../no.cnt
	fi
	cd ..
done < rows

n=0 ; if test -f ok.cnt ; then n=`sed -n '$=' ok.cnt` ; fi
m=0 ; if test -f no.cnt ; then m=`sed -n '$=' no.cnt` ; fi
echo "PLANOK $ST $n"
echo "PLANNO $ST $m"
echo "$E"
