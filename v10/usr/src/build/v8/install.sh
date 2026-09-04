# /etc/install.  v8's script, plus the two options System V's install has and
# this one did not.  patch:120 copies this file over the tape's cmd/install.sh,
# and mkfile:1222 installs that as $ETC/install, so this is the only install on
# the machine.
#
# v8's whole argument grammar was `[-s|-c] file dest' -- one option, in first
# position, with mv as the verb.  cmd/library/mkfile:41-45 calls
# `${INS} -m 444 -f ${INSLIB} ./$i' and `${INS} -f ${MAN} -m 444 library.1':
# System V's spelling, four arguments, and the two flags in either order.
# Reading `-m' as the source file made mv answer `cannot access -m' and chmod
# answer `444: No such file or directory', once per file for 32 files and again
# for the program.  So the options are read in a LOOP and order does not matter.
#
# AND -f COPIES.  mv is v8's verb and is right for a compiled program leaving
# its build directory, but library's ${LFILES} are 32 TAPE FILES -- help text,
# form definitions, known.list -- and moving them installs the package by
# emptying its own source directory.  System V's install copies; a caller that
# spells -f gets a copy.
cmd=/bin/mv
mode=
dir=

while :
do
	case ${1-""} in
	-s )	/usr/bin/strip $2
		shift ;;
	-c )	cmd=cp
		shift ;;
	-m )	mode=$2
		shift; shift ;;
	-f )	dir=$2
		cmd=cp
		shift; shift ;;
	-o )	shift ;;
	* )	break ;;
	esac
done

if [ -n "$dir" ]
then	file=$dir/$1
else
	if [ ! ${2-""} ]
	then	echo 'install: no destination specified.'
		exit 1
	fi
	if [ -d $2 ]
	then	file=$2/$1
	else	file=$2
	fi
fi

rm -f $file
$cmd $1 $file
if [ -n "$mode" ]
then	chmod $mode $file
else	chmod o-w,g+w $file
fi
if [ "`getuid`" = root ]
then	# NO chgrp ON THIS MACHINE -- cmd/ has none -- and v10's chown takes
	# user,group in one argument, which is how build/mkfile installs
	# /bin/sh: `/etc/chown bin,bin'.
	/etc/chown bin,bin $file
fi
