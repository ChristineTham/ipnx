.G1
frame ht 3 wid 4
.G2
.G1
define g / print $1; a($1,999) /
define a / print $1; print $2 /
g(123)
.G2
.G1
ticks left off
1 1
2 2
.G2
.G1
copy  thru X
 "x" at 2,3 X
A
.G2
.G1
graph A
0 0
1 1
graph B "with .w at A.e + (1,0)"
2 2
3 3
graph C "with .n at A.s - (0,1)"
4 4 
5 5
.G2
.G1
1 1
2 2
.G2
.G1
copy  thru X
 "x" at 2,3 X
A
.G2
.G1
copy  thru X
  bullet at $2,$3 X
AK	1	401851
WY	1	469557
VT	1	511456
.G2
.G1
copy  thru X
 "x" at 2,3 X until "xxx"
A
xxx
.G2
.sp 1i
.G1
frame top invis right invis
coord x 0 to 10 y 0 to 5
ticks left in at 0 "bottommost tick", 1,2,3,4,5 "top tick"
ticks bot in at 0 , 2, 4, 6, 8, 10
label bot "this is a" "silly graph"
label left "left side label" "here"
grid bot dotted at 2,4,6,8
grid left dashed at 2.5

1 1
2 1.5
3 2
4 1.5
5 1
6 2
7 2.5
8 3
9 4
10 5
.G2
.G1
coord x 0 to 10 y 0 to 5
ticks left  at 0 "bottommost tick", 1,2,3,4,5 "top tick"
ticks bot at 0 , 2, 4, 6, 8, 10
label bot "this is a" "silly graph"
label left "left side label" "here" "and long as hell"
grid bot dotted at 2,4,6,8
grid left dashed at 2.5, 5

1 1
2 1.5
3 2
4 1.5
5 1
6 2
7 2.5
8 3
9 4
10 5
.G2
.G1
coord x 0 to 10 y 0 to 5
coord other x 0 to 10 y 1 to 6
draw dashed
draw other solid
coord
next at 1, 1
next at 2, 1.5
next at 3, 2
next at 4, 1.5
next at 5, 1
next at 6, 2
next at 7, 2.5
next at 8, 3
next at 9, 4
next at 10, 5
coord other
next at 1, 1
next at 2, 1.5
next at 3, 2
next at 4, 1.5
next at 5, 1
next at 6, 2
next at 7, 2.5 dotted
next at 8, 3 dotted
next at 9, 4 dotted
next at 10, 5
.G2
.G1
plot "abc" at 0,0
plot 123 at 1,1
plot -123 at 2,2
plot 12+3 "%6.2f" at 2,2
.G2
.G1
graph A1
	1,1
	2,2
graph A2 with .Frame.w at A1.Frame.e + (.2,0)
	ticks left off
	1,1
	2,2
.G2
.G1
.1 1
.2 2
.3 3
# can we read stuff with dec pts?
.G2
# excessively wide labels...
.G1
ticks off
label left "fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo"  wid 1
0 0
1 1
.G2
.G1
ticks off
label left "fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo"  wid 0
0 0
1 1
.G2

From doug Wed Jun 24 00:51:26 EDT 1992
This zinged peter at berkeley.
.PS
scale=100
.PE
.G1
draw solid
"0,0" at 0,0
"10,10" at 10,10
.G2
The graph is a disaster.
Better immunize grap.
[Done -- sets scale = 1 before each graph.]
