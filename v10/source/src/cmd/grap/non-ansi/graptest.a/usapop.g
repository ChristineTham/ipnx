.G1
coord x 1785,1955 y 0,160
copy "usapop.d"
define fit X 35 + 1.4*($1-1870) X
line from 1850,fit(1850) to 1950,fit(1950)
.G2
.G1
coord x 1785,1955 y 3,160 log y
copy "usapop.d"
define fit X exp(0.75 + .012*($1-1800)) X
line from 1790,fit(1790) to 1920,fit(1920)
.G2
.G1
define PowerGraph Y
define newx X exp(power*(log(($1-1600)/100))) X
ticks bot out at newx(1800) "1800", newx(1900) "1900",\
		 newx(1950) "1950"
copy "usapop.d" thru X
  "\s-5\(bu\s+5" at newx($1),$2
X
Y
.G2
.bp
.G1
power=5
PowerGraph
.G2
.G1
power=6
PowerGraph
.G2
.G1
power=7
PowerGraph
.G2
