.G1
frame ht 2.5 wid 3
label left "Displacement" "in Thousands" "of Tons" "(log scale)"
label bot "Length in Feet (log scale)"
coord x 200,1200 y 2,110 log log
# ticks left in at 2, 5, 10, 20, 50, 100
# ticks right in at 2 "", 5, 10, 20, 50, 100
ticks bot in at 200 "200", 300, 400, 500 "500", 600, 700, 800, 900, 1000 "1000", 1100
# Others:
draw plus
	860 59
	716 21.5
	547 7.93
	585 11
	721 17.35
	390 3.46
	512 5.8
	563 8.9
	445 3.6
# Subs:
draw "\s-3\(ob\s0"
	219 2.9
	382 6.7
	425 8.25
	560 18.7
	267 2.86
	279 4.3
	360 6.9
# Carriers:
draw bullet
	979 64
	1039 78
	1092 93.4
	820 39.3

coord abs x 0,1 y 0,1
 "\s-3\(bu\s+3  Submarine" at abs .2,.7
 "\s-3\(ci\s+3  Carrier" at abs .2,.6
 "\s-3\(pl\s+3  Other" at abs .2, .5
.G2
