.G1
frame ht 3 wid 5
coord x 10,35 y 10,25
ticks bot out at 10, 20, 30
ticks bot out  at 15 "", 25
ticks left out at 10 "10", 15, 20 "20"
copy "selforg.d" thru X plot "$1" size -3 at $4,$3 X
line dashed from 10,10 to 25,25
"Count" at 22.5,11
"MTF" at 12,17.5
"(MTF is superior" size -2 "below the line)"  at 30,13
.G2
