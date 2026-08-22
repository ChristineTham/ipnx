.G1
.ft H
draw pt solid
draw il dashed
coord il  x -5,30  y 0,7
coord pt  x -5,30  y -5,30
grid dotted bot from 0 to 25 by 5
grid dotted left from pt 0 to 25 by 5
ticks bot in 0 at -5,30
ticks left in 0 at pt -5,30
ticks right out 0 from il 0 to 7 by 1
label top "Input/Output Power Transfer At 100MHz"
label bot "Input Power" "(dBm)"
label left "Output Power" "(dBm)" left .15
label right "Insertion Loss" "(dB)"

# it's a bother that the the until xxx bit is really needed:

copy thru X
  next pt at pt $1,$2
  next il at il $1,$3
X until "xxx"
0       -.48    .48
7       6.31    .69
8       7.26    .74
9       8.26    .74
10      9.34    .66
11      10.34   .66
12      11.29   .71
13      12.27   .73
14      13.36   .64
15      14.35   .65
16      15.30   .70
17      16.23   .77
18      17.18   .82
19      18.16   .84
20      19.22   .78
21      20.17   .83
22      21.04   .95
23      21.84   1.16
24      22.68   1.32
25      23.41   1.59
26      24.02   1.98
27      24.54   2.45
xxx
.ft
.G2
