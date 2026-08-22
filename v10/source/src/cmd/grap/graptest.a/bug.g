.G1
copy thru { if $1 > 0 then X "x" at 0,0 X }
1
2
3
4
.G2
.G1
copy  thru X 
if 1 then Y "x" at 1,0  Y X
1 2
3 4
.G2
.G1
sh X awk 'BEGIN { print "hello" }' X
sh { awk 'BEGIN { print "goodbye" }' }
.G2
.G1
label left "\&"
sh @ who
who
@
copy "/tmp/hist"
.G2
