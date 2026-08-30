.G1
define pie ?
frame ht 3 wid 3
coord x -1.2, 1.2 y -1.2, 1.2
ticks left off
ticks bot off
pic circle  radius x_gg(1)-x_gg(0) at x_gg(0), y_gg(0)
pi = 3.14159
rotat = 0.0
sum = 0
getsum($1); print sum
circle at sum,sum
copy $1 thru wedge
?
define wedge X 
half = rotat+ ( ( $1 / sum) * pi) 
rotat = rotat + ( ( $1 / sum) * 2 * pi) 
line from 0,0 to cos(rotat), sin(rotat) 
$2 at cos(half)*.7, sin(half)*.7
X
define add X sum = sum + $1 X
define getsum / copy $1 thru add /

pie("pie.d")
.G2
