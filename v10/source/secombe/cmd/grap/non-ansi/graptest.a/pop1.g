.G1
.nf
frame ht 4 wid 5
label left "Population" "(Millions)"
label bot "Rank In Population"
label right "Representatives"
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
   "\s-4$1\s+4" at abs thisrank, .05
X
draw solid
zlc=435/4.5 #Zipf's Law Constant: Total reps / 50th Harmonic number
thisrank=51
copy "states.d" through PlotState
.fi
.G2
