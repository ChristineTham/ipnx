.G1
frame ht 3 wid 5
coord x 0,42 y 0,11.5
ticks bot out from 0 to 40 by 10
ticks bot out from 15 to 35 by 10 ""
ticks top out from 10 to 40 by 5 ""
ticks left off
i=11
"File" at 3,10.7
copy "selforg.d" thru X
  i=i-1
  vtick at $2,i
  bullet at $3,i
  times at $4,i
  circle at $5,i
  line dashed from $2,i to $5,i
  "$1" at 3,i
X
ty=3
copy thru X
    $1 at 33,ty
    "$2" at 37,ty
    ty=ty-.7
X until "xxx"
vtick  OSO
bullet MTF
times  Count
circle Transpose
.G2
