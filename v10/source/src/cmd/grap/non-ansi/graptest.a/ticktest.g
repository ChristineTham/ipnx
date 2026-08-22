.G1
define tt X
	frame ht .5 wid 3
	ticks left off
	coord x $1,$2 y $1,$2 $3
	$1,$1
	$2,$2
	label right "$1 $2 $3"
X
define ll X log log X
.G2
.G1
tt(1, 5, ll)
.G2
.G1
tt(1.1, 4.9, ll)
.G2
.G1
tt(.99, 5.01, ll)
.G2
.G1
tt(5, 20, ll)
.G2
.G1
tt(6, 21, ll)
.G2
.G1
tt(79, 81, ll)
.G2
.G1
tt(1, 1000000, ll)
.G2
.G1
tt(1.1, 50.1, ll)
.G2
.G1
-10 -10
10 10
.G2
