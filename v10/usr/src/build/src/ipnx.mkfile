#
# ipnx systems
#
STARS=ipnx-v10.u

all:V:	$STARS

$STARS:V:
	cc=$cc mk -f ../lib/mk.star $target
