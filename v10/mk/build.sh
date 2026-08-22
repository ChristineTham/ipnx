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
# IFS='|' ON THE `read' PERSISTS INTO THE LOOP BODY, and that is not a style
# point -- it broke every compile in stage 1.  With IFS set to `|' the shell no
# longer splits on SPACE, so
#
#	CC="/bin/cc -B/lib/"   ...   $CC $CF $stem.c
#
# expanded to a single word and sh answered
#
#	build.sh: /bin/cc -B/lib/: not found
#
# twelve times, which reads as a missing compiler on the builder.  Restoring
# IFS as the first act of the body costs one line and confines the split to the
# read, where it is wanted.
OIFS=$IFS
while IFS='|' read path meth src objs libs note
do
	IFS=$OIFS
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

	# ------------------------------------------------------- an archive ---
	# `ORDER' IN THE OBJECTS COLUMN MEANS THIS IS A LIBRARY, and its member
	# order is the tape's own -- read from the file the extractor wrote when
	# it unpacked the archive.  It matters: V10's ld makes ONE sequential
	# pass when __.SYMDEF is absent or stale, so a library built in the
	# wrong order leaves backward references unresolved, and this golden has
	# neither lorder nor tsort to recompute it.
	#
	# The object-to-source map is the unit's own mkfile, which carries an
	# explicit `obj: dir/src.c' line for every member.
	case $objs in
	ORDER|*/ORDER)
		SD=$TAPE/$src
		if test "$objs" = ORDER
		then	ORD=$SD/$name/ORDER
		else	ORD=$SD/$objs
		fi
		if test ! -s $ORD
		then
			echo "$Q $path no ORDER at $name/ORDER"
			echo . >> no.cnt
			continue
		fi
		echo "P: $path `sed -n '$=' $ORD` members from $SD"
		# The flags ride the note, as they do for a program; the libs
		# column carries any named exclusion.
		AF="`echo $note | sed -e 's/^[^-]*//'`"
		DROP="`echo $libs | sed -e '/^DROP=/!d' -e 's/^DROP=//'`"
		ARCD=`echo $ORD | sed -e 's|/ORDER$||'`
		rm -rf w ; mkdir w ; cd w
		MK=
		for m in makefile Makefile mkfile
		do
			if test -s $SD/$m ; then MK=$SD/$m ; fi
		done
		# THE UNIT'S HEADERS COME IN FIRST.  Every stage-4 failure was a
		# quoted include the compiler could not resolve -- curses.ext,
		# jerq.h, io.h, balloc.h -- each sitting in the directory the
		# member came from.  A bundle carries its own headers too:
		# hp.c.a holds hp.h, ramtek.c.a holds ram.h, blit.c.a holds both
		# jcom.h and jplot.h, and 143 of 145 apparent blocks were these
		# four, inside the very archive the recipe unpacks.
		cp $SD/*.h . 2>/dev/null
		cp $SD/*.ext . 2>/dev/null
		if test -d $ARCD
		then	cp $ARCD/* . 2>/dev/null
		fi
		# OUR OVERLAY LAST, because it must WIN.  Copying it before the
		# bundle let the tape's own openpl.c overwrite our corrected one,
		# so the fix was on the disk and not in the compile -- the same
		# shape as "it is in the golden, it will arrive on Reset".
		orel=`echo $src | sed -e 's|^src/||'`
		if test -d $OURS/$orel
		then	cp $OURS/$orel/* . 2>/dev/null
		fi
		rm -f *.o
		rm -f mem.bad first.log
		# A BUNDLE'S MEMBERS ARE SOURCES, NOT OBJECTS.  `ar' predates tar
		# being everywhere and was the ordinary way to package any file
		# set, so on this tape X.c.a is an archive of .c FILES and `ar x'
		# is step one of the recipe:
		#	lib4014.a: tek.c.a
		#		mkdir xplot; cd xplot; ar x ../tek.c.a
		#		cc -c -O *.c; ar rc ../lib4014.a *.o
		# Read as "24 members have no source" it looks like tape rot.
		for o in `cat $ORD`
		do
			case " $DROP " in
			*" $o "*)	continue ;;
			esac
			case $o in
			*.h)	continue ;;
			esac
			st2=`echo $o | sed -e 's|\.[a-z]*$||'`
			# the mkfile names the source; fall back to a search
			# a member of an UNPACKED bundle is right there
			if test -s $ARCD/$st2.c
			then	rel=`echo $ARCD/$st2.c | sed -e "s|^$SD/||"`
			else	rel=
			fi
			if test -z "$rel"
			then
			rel=`sed -n "/^$st2\.o[ 	]*:/s/^[^:]*:[ 	]*//p" $MK 2>/dev/null | sed -e 's/[ 	].*//' -e 1q`
			fi
			if test -z "$rel" -o ! -s "$SD/$rel"
			then
				rel=
				for d in . gen stdio fio math csu sys
				do
					if test -s $SD/$d/$st2.c
					then	rel=$d/$st2.c
					elif test -s $SD/$d/$st2.s
					then	rel=$d/$st2.s
					fi
				done
			fi
			if test -z "$rel"
			then	echo "$st2" >> mem.bad ; continue
			fi
			ob=$st2.o
			case $rel in
			*.s)	${BP}../bin/as -o $ob $SD/$rel > m.log 2>&1 ;;
			*)	# THE SOURCE'S OWN DIRECTORY COMES WITH IT.
				# V10's cpp cannot resolve a quoted include for
				# an out-of-tree source, so lifting stdio/
				# fprintf.c into a scratch directory loses
				# iolib.h and seventeen members fail on a
				# header that is sitting beside the file they
				# came from.
				sdir=`echo $rel | sed -e 's|/[^/]*$||'`
				if test "$sdir" != "$rel"
				then	cp $SD/$sdir/*.h . 2>/dev/null
				fi
				# THE OVERLAY WINS AT THE MEMBER LEVEL TOO.
				# Copying it into the directory first is not
				# enough: this line then copies the TAPE's
				# source over the top of it, so the corrected
				# openpl.c was present in the directory and
				# absent from the compile.
				if test -s $OURS/$orel/$st2.c
				then	cp $OURS/$orel/$st2.c $st2.c 2>/dev/null
				else	cp $SD/$rel $st2.c 2>/dev/null
				fi
				# NOT /dev/null.  Discarding the compiler's
				# output made 261 members fail with no reason
				# at all, which is the same fault as a marker
				# that cannot say why it did not appear.
				( $CC -O $AF -c $st2.c 2>&1
				  echo "CCST=$?" ) | sed -e 20q > m.log ;;
			esac
			if test ! -s $ob
			then
				echo "$st2" >> mem.bad
				# The FIRST failure's reason, once: 261 copies
				# of the same message is not more evidence.
				if test ! -s first.log
				then	cp m.log first.log
				fi
			fi
		done
		nb=0 ; if test -s mem.bad ; then nb=`sed -n '$=' mem.bad` ; fi
		echo "P: members that did not compile: $nb"
		if test -s first.log
		then	sed -e 8q -e 's/^/P! first failure: /' first.log
		fi
		if test -s mem.bad ; then sed -e 20q -e 's/^/P! no member: /' mem.bad ; fi
		# `ar cr' ACCEPTS OBJECT NAMES THAT DO NOT EXIST, builds an
		# archive from whatever it CAN open, and ranlib blesses the
		# result.  So "an archive was built" is never the question --
		# "does it hold every member" is.  This stage first reported
		# PBUILT over an archive with 261 of 261 members missing, and
		# the driver's own `test -s libc.a' agreed with it.
		if test $nb -gt 0
		then
			echo "$Q $path -- $nb of $want members did not compile"
			echo . >> ../no.cnt
			cd ..
			continue
		fi
		# IN THE TAPE'S ORDER, not the shell's alphabetical glob.
		rm -f $name
		# THE MEMBER LIST GOES IN A FILE, not a variable read back
		# through nested quotes.  `echo "$MEM" | sed -n "$="' inside a
		# double-quoted echo inside backticks does not survive 1970s sh:
		# the counts came out as `2 of 1' and `29 of 1', which is a
		# quoting fault reported as a measurement.
		# A BUNDLE'S MEMBERS ARE NOT ALL SOURCES.  hp.c.a carries hp.h,
		# ramtek.c.a carries ram.h and blit.c.a carries both jcom.h and
		# jplot.h -- they are EXTRACTED beside the sources so `-I.'
		# finds them, and compiling them produces nothing.  143 of 145
		# apparent blocks were these four headers.
		sed -e "/^$DROP\$/d" -e '/\.h$/d' -e 's|\.[a-z]*$|.o|' $ORD > mem.lst
		want=`sed -n '$=' mem.lst`
		if test -z "$want" ; then want=0 ; fi
		ar cr $name `cat mem.lst` > /dev/null 2>&1
		ranlib $name > /dev/null 2>&1
		got=`ar t $name 2>/dev/null | sed -e '/SYMDEF/d' | sed -n '$='`
		if test -z "$got" ; then got=0 ; fi
		if test "$got" != "$want"
		then
			echo "$Q $path -- archive holds $got of $want members"
			echo . >> ../no.cnt
			cd ..
			continue
		fi
		if test -s $name && cp $name $DEST$path
		then
			echo "$P $name ($got members)"
			echo . >> ../ok.cnt
		else
			echo "$Q $path"
			echo . >> ../no.cnt
		fi
		cd ..
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
	echo "P: $path from $SD objs=$objs"
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
	# A UNIT MAY SPAN TWO DIRECTORIES.  cmd/ccom is ONE program built from
	# ccom/vax (the VAX back end) and ccom/common (the pcc front end): the
	# objects are plain names but the SOURCES and HEADERS are split, so
	# without the sibling the compile dies on
	#	./gencode.h: 2: Can't find include file mfile2.h
	# which reads as a missing header and is a missing directory.
	if test -d $SD/../common
	then
		cp $SD/../common/* . 2>/dev/null
	fi
	for o in $objs
	do
		case $o in
		../*)	d=`echo $o | sed -e 's|/[^/]*$||'`
			cp $SD/$d/* . 2>/dev/null ;;
		esac
	done
	# OUR OVERLAY WINS.  v10/src holds the named patches; copying it second
	# is what makes them real.  It is rooted at the TAPE'S src/, so
	# v10/src/cmd/... corresponds to tape src/cmd/... -- asking for
	# $OURS/src/cmd finds nothing at all.
	orel=`echo $src | sed -e 's|^src/||'`
	if test -d $OURS/$orel
	then
		cp $OURS/$orel/* . 2>/dev/null
	fi
	# THE TAPE SHIPS 1989 OBJECTS BESIDE THE SOURCE and a link over them
	# would pull Bell Labs' bytes into our binary silently -- and in the
	# flattering direction, since they resolve symbols our compile failed
	# to produce.
	rm -f *.o

	# THE FLAGS COME FROM THE PLAN, which took them from the unit's own
	# makefile or from cmd/Admin/Mk.  They are not decoration: cmd/as needs
	# -DUNIX -DUNIXDEVEL -DFLEXNAMES, cmd/yacc -DWORD32, cmd/c2 -DCOPYCODE.
	# Guessing -Od2 for everything gave `word displacement overflow' at link
	# time, which reads as a linker limit and is a missing flag.  The note is
	# `<idiom> <flags>', so the flags are everything after the first word.
	CF2="`echo $note | sed -e 's/^[^ ]* //'`"
	CF="$CF2 -c"

	# GENERATE ONCE, UP FRONT, IN THE MKFILE'S OWN ORDER.  cpp's recipe is
	#
	#	y.tab.h cpy.c rodata.c: cpy.y
	#		yacc -d cpy.y
	#		sh :yyfix >rodata.c
	#		mv y.tab.c cpy.c
	#
	# and the order is load-bearing: `:yyfix' does TWO things -- it prints
	# the parser tables to stdout AND deletes them from y.tab.c, leaving
	# `extern' declarations behind, then writes the file back.  Generating
	# per object took cpy.c from y.tab.c BEFORE :yyfix had edited it, so the
	# tables were in both files and ld said
	#	_yyexca: rodata.o: multiply defined
	# which reads as a duplicate symbol and is a wrong order.
	GRAM=
	for g in *.y
	do
		if test -s "$g" ; then GRAM=$g ; fi
	done
	if test -n "$GRAM"
	then
		need=no
		for o in $objs
		do
			st2=`echo $o | sed -e 's|.*/||' -e 's|\.o$||'`
			if test ! -s $st2.c ; then need=yes ; fi
		done
		if test $need = yes
		then
			yacc -d $GRAM > /dev/null 2>&1
			# the tables file: an object with neither .c nor .y
			for o in $objs
			do
				st2=`echo $o | sed -e 's|.*/||' -e 's|\.o$||'`
				if test ! -s $st2.c -a ! -s $st2.y -a -s :yyfix
				then	sh :yyfix > $st2.c 2>/dev/null
				fi
			done
			gs=`echo $GRAM | sed -e 's|\.y$||'`
			if test ! -s $gs.c -a -s y.tab.c
			then	cp y.tab.c $gs.c
			fi
		fi
	fi

	rm -f bad.lst
	for o in $objs
	do
		b=`echo $o | sed -e 's|.*/||'`
		stem=`echo $b | sed -e 's|\.o$||'`
		case $b in
		*.a)	continue ;;
		esac
		# AN OBJECT MAY HAVE ITS OWN FLAGS.  cpp's mkfile gives one:
		#	cpp.o: cpp.c
		#		cc $CFLAGS -DFLEXNAMES -DPD_MACH=D_vax \
		#		   -DPD_SYS=D_unix -c cpp.c
		# and without them cpp.c does not compile at all -- so the unit
		# flags alone lose the C PREPROCESSOR, which stage 2 cannot run
		# without.  The makefile is in this directory because the whole
		# unit was copied here, so its own line is the authority.
		# PURE sed, BECAUSE THE GUEST'S TOOLS ARE 1970s ONES.  The first
		# version used `grep --' and `tr " \t" "\n\n"', and neither works
		# here: V10's grep predates `--' and its tr takes \t and \n as the
		# LITERAL characters backslash-t and backslash-n, so the pipeline
		# silently produced nothing and cpp.o went on missing.
		XD=
		for mf in makefile Makefile mkfile
		do
			if test -s $mf
			then
				XD="$XD `sed -n \"/-c $stem\\.c/s/.*cc //p\" $mf 2>/dev/null | sed -e \"s/-c $stem\\.c.*//\" -e 's/[$][A-Za-z_][A-Za-z_]*//g' -e 's/[$]([A-Za-z_]*)//g' -e 1q`"
			fi
		done
		if test -s $stem.c
		then
			# sed -e 40q CLOSES THE PIPE so a compiler that will not
			# stop gets EPIPE.  An unbounded log once wrote the same
			# include error until 120 MB was gone and the filesystem
			# was blamed -- it had 111.8 MB free.  The status rides
			# the same pipe because a pipeline's $? is sed's and
			# 1970s sh has no PIPESTATUS.
			( $CC $CF $XD $stem.c 2>&1
			  echo "CCST=$?" ) | sed -e 40q > c.log
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
			# A SOURCE MAY BE GENERATED AS A SIDE EFFECT.  cmd/cpp's
			# mkfile says
			#	y.tab.h cpy.c rodata.c: cpy.y
			#		yacc -d cpy.y
			#		sh :yyfix >rodata.c
			#		mv y.tab.c cpy.c
			# so rodata.c has no rule and no file on the tape -- it
			# exists only in the object directory, after yacc has
			# run.  A builder that looks only for $stem.c reports a
			# missing object and the C PREPROCESSOR never builds.
			gen=no
			for g in *.y
			do
				if test -s "$g"
				then	yacc -d $g > /dev/null 2>&1; gen=yes
				fi
			done
			# WHICH GENERATED FILE IS WHICH.  cpp's mkfile makes TWO
			# sources from one grammar:
			#	yacc -d cpy.y ; sh :yyfix >rodata.c
			#	mv y.tab.c cpy.c
			# so the PARSER takes y.tab.c and the TABLES come from
			# :yyfix.  Running :yyfix for any missing source gave
			# cpy.c the table file's contents.  The grammar's own
			# name identifies the parser.
			if test $gen = yes -a -s y.tab.c
			then
				if test -s $stem.y
				then	cp y.tab.c $stem.c 2>/dev/null
				elif test -s :yyfix
				then	sh :yyfix > $stem.c 2>/dev/null
				fi
			fi
			if test -s $stem.c
			then
				( $CC $CF $stem.c 2>&1
				  echo "CCST=$?" ) | sed -e 40q > c.log
			else
				echo $b >> bad.lst
				continue
			fi
		fi
		if test ! -s $b
		then
			# `:rofix' IS A REAL BUILD STEP, not a helper.  cpp's
			# mkfile builds its table file through the ASSEMBLER:
			#	cc $CFLAGS -S rodata.c
			#	sh :rofix rodata.s
			#	cc -c rodata.s
			# because the tables must land in read-only data, which
			# is a property no C source can state.  A plain -c
			# produces nothing and the C PREPROCESSOR never builds.
			if test -s :rofix -a -s $stem.c
			then
				$CC $CF2 -S $stem.c > /dev/null 2>&1
				sh :rofix $stem.s > /dev/null 2>&1
				$CC -c $stem.s > /dev/null 2>&1
			fi
		fi
		if test ! -s $b
		then
			echo $b >> bad.lst
		fi
	done

	if test -s bad.lst
	then
		echo "$Q $path"
		sed -e 's/^/P! missing object: /' bad.lst
		# PREFIXED, BECAUSE THE DRIVER FILTERS.  It keeps only lines
		# starting with P, so an unprefixed compiler error is stripped
		# and twelve failures arrive with no reason at all -- which is
		# exactly what the first stage-1 run produced.
		sed -e 5q -e 's/^/P! /' c.log
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
	# `word displacement overflow' IS THE OPTIMISER, NOT THE PROGRAM.  -Od2
	# runs c2 and emits debug records; on a large program V10's ld cannot
	# relocate them and says so.  cmd/Admin/large exists for exactly this --
	# it names the big commands and compiles them -O -- but the list is the
	# tape's, taken against the tape's own compiler, and ours builds a few
	# more that overflow.  Retrying with -O is the tape's own remedy applied
	# to a name its list happens not to carry, and it is REPORTED rather
	# than silent, because a build that quietly changes its flags is a build
	# whose output nobody chose.
	if sed -e '/displacement overflow/!d' -e 1q l.log | grep . > /dev/null
	then
		echo "P! $name: -Od2 overflowed, retrying -O (Admin/large's remedy)"
		rm -f *.o $name
		for o in $objs
		do
			b=`echo $o | sed -e 's|.*/||'`
			stem=`echo $b | sed -e 's|\.o$||'`
			if test -s $stem.c
			then	$CC -O -c $stem.c > /dev/null 2>&1
			fi
		done
		( $CC -o $name $OO $LL 2>&1 ; echo "LDST=$?" ) | sed -e 40q > l.log
		lst=`sed -e '/^LDST=/!d' -e 's/LDST=//' -e 1q l.log`
	fi
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
		sed -e 5q -e 's/^/P! /' l.log
		echo . >> ../no.cnt
	fi
	cd ..
done < rows

n=0 ; if test -f ok.cnt ; then n=`sed -n '$=' ok.cnt` ; fi
m=0 ; if test -f no.cnt ; then m=`sed -n '$=' no.cnt` ; fi
echo "PLANOK $ST $n"
echo "PLANNO $ST $m"
echo "$E"
