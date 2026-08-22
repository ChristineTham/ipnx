.G1
draw solid
define fit X exp(1.8 + 2.7*$1) X
lx = 0
for ly from 10 to 230 by 10 do X
	line dotted from lx,fit(lx) to ly,fit(ly)
	lx = ly
X
.G2
