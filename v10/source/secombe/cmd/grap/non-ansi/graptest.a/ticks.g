.G1
ticks left in
0 0
1 1
.G2
.G1
coord x 0, 1 y -50, 120
ticks bot off
ticks left out from -50 to 120 by 10
.G2
.G1
ticks off
0 0
1 1
.G2
.G1
ticks top right
0 0
1 1
.G2
.G1
ticks bot top left right
0 0
1 1
.G2
.G1
ticks out bot top left right
0 0
1 1
.G2
.G1
ticks left off
0 0
1 1
.G2
.G1
ticks left off top
0 0
1 1
.G2

.G1
ticks bot at 0,1
ticks left at 0,1
0 0
1 1
.G2
.G1
ticks top out
ticks right out
0 0
1 1
.G2
.G1
ticks right in 0 at 0, 1
0 0
1 1
.G2
.G1
frame invis
coord x 1956.5, 1966.5 y 0, 50
tick bot from 1957.5 to 1964.5
.G2

grid stuff:



"grid bottom" without iterator turns off the grid lines!

this is a feature, not a bug.
BUT:  if ticks off is moved after the iterator, this will fail.
that is a bug

.G1
grid left ticks off from 0 to 1 by .25
grid bottom
0 0
1 1
.G2

.G1
grid left off at 0, .5, 1
ticks bottom
0 0
1 1
.G2
