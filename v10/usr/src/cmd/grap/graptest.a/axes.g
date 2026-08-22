.sp 1i
Alix -- This is pretty crude, but it will at least show you
what i had in mind.  you can fiddle it until it's good enough
or you get totally frustrated.  (We should have allowed for this
case originally.)

brian

.G1
frame ht 6 wid 6 invis	# turn off normal frame if you don't want it
#data...

-5 -5
0 0
5 5

line from -5,0 to 5,0	# x axis
line from 0,-5 to 0,5	# y axis
ticks off		# turn off automatic ticks
for i from -5 to 5 by 1 do {	# manual ticks;  adjust to taste
	line from i,-.05 to i,0.05
	plot sprintf("%g", i) below at i,0

	line from -.05,i to 0.05,i
	plot sprintf("  %g", i) ljust at 0,i
}
.G2
