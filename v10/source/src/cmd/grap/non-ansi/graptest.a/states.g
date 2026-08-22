.G1
define PopTicks2 X
ticks $1 in at 0.5e6 ".5", 1e6 "1", 2e6 "2", 5e6 "5",\
	10e6 "10", 20e6 "20"
X
define PopTicks3 X
ticks $1 in at 0.3e6 ".3", 1e6 "1", 3e6 "3", 10e6 "10", 30e6 "30"
X
frame invis ht 1 wid 5 bottom solid
label bot "Populations (in Millions) of the 50 States"
coord x 300000, 30000000 y 0, 1 log x
PopTicks2(bot)
ticks left off
copy "states.d" thru X vtick at ($3,.5) X
.G2
.G1
frame invis ht 1 wid 5 bottom solid
label bot "Populations (in Millions) of the 50 States"
coord x 300000, 30000000 y 0, 1000 log x
PopTicks2(bot)
ticks left off
copy "states.d" thru X bullet at ($3,200+600*rand()) X
.G2
.G1
frame ht 4 wid 5
label left "Rank in" "Population"
label bot "Population (Millions)"
minx=300000
coord x minx,30000000 y 0,51 log x
PopTicks2(bot)
ticks left out at 1, 50
thisy=51
define PlotState X
  thisy=thisy-1; thisx=$3
   bullet at (thisx, thisy)
   "\s-4$1\s+4" at (thisx*1.10, thisy)
  line from (minx,thisy) to (thisx,thisy)
X
copy "states.d" thru PlotState
.G2
.bp
.G1
frame ht 4 wid 5
label left "Rank in" "Population"
label bot "Population in Millions (Line is Zipf's Law)"
minx=300000
coord x minx,52000000 y 0,51 log x
PopTicks2(bot)
ticks bot out at 50e6 "50"
ticks left out at 1, 50
zlc=50200000 #Zipf's Law Constant: (Sum of pops)/50th Harmonic number
thisy=51
define PlotState X
  thisy=thisy-1; thisx=$3
   bullet at (thisx, thisy)
   "\s-4$1\s+4" at (thisx*1.10, thisy)
  line from (minx,thisy) to (zlc/thisy,thisy)
X
copy "states.d" thru PlotState
.G2
.G1
frame ht 4 wid 5
label left "Rank in" "Population"
label bot "Population in Millions (Line is Zipf's Law)"
minx=300000
coord x minx,52000000 y 0,51 log x
PopTicks2(bot)
ticks bot out at 50e6 "50"
ticks left out at 1, 50
zlc=50200000 #Zipf's Law Constant: (Sum of pops)/50th Harmonic number
thisy=51
draw solid
define PlotState X
  thisy=thisy-1; thisx=$3
   bullet at (thisx, thisy)
   "\s-4$1\s+4" at (thisx*1.10, thisy)
  next at (zlc/thisy,thisy)
X
copy "states.d" thru PlotState
.G2
.bp
.G1
.nf
frame ht 4 wid 5
label left "Population" "in Millions" bullet
label bot "Rank In Population"
label right "Representatives" square
coord pop x 0,51 y .18e6,30e6 log y
coord rep x 0,51 y .3,100 log y
coord abs x 0,51 y 0,1
ticks left in at pop .3e6 ".3", 1e6 "1", 3e6 "3", 10e6 "10", 30e6 "30"
ticks bot out at pop 1, 50
ticks right in at rep 1, 2, 5, 10, 20, 50, 100
define PlotState X
  thisrank=thisrank-1
   bullet at pop (thisrank,$3)
   square at rep (thisrank,$2)
  next at rep (thisrank, zlc/thisrank)
X
draw solid
zlc=435/4.5 #Zipf's Law Constant: Total reps / 50th Harmonic number
thisrank=51
copy "states.d" through PlotState
 "Zipf's Law" at abs (20, .4)
.fi
.G2
.DS
Include statepop.l here as soon as .e bug is fixed
.DE
.DS
Other plots of population
  Histogram
  Decreasing rank
  Cumulative (% of states <x)
.DE
.bp
.G1
frame ht 3 wid 5
label left "Representatives" left .3
label bot "Population (Millions)"
coord x 300000, 30000000 y .5, 50 log log
ticks left in at 1, 2, 5, 10, 20, 50
PopTicks3(bot)
copy "states.d" thru X bullet at ($3,$2) X
.G2
.G1
frame ht 3 wid 5
label left "Population per" "Representative" left .3
label bot "Population (Millions)"
coord x 300000, 30000000 y 380000, 700000 log x
ticks left in from 400000 to 700000 step 100000
PopTicks3(bot)
copy "states.d" thru X "\s-3$1\s+3" at ($3,$3/$2)X
.G2
.G1
frame ht 3 wid 5
label left "Population per" "Elector" left .3
label bot "Population (Millions)"
coord x 300000, 30000000 y 100000, 520000 log x
ticks left in from 100000 to 500000 step 100000
PopTicks3(bot)
copy "states.d" thru X "\s-3$1\s+3" at ($3,$3/($2+2)) X
.G2
.bp
.DS
XXX More
.DE
