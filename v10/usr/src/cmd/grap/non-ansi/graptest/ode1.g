.G1
frame ht 2.5 wid 2.5
coord x 0,1 y 0,1
label bot "Direction field is $y prime = x sup 2 / y$"
label left "$y= sqrt {(2x sup 3 +1)/3}$"
ticks left in 0 at 0,1
ticks bot in 0 at 0,1
len=.04
for i from .01 to .91 by .1 do {
  for j from .01 to .91 by .1 do {
    deriv = i*i/j
    scale=min(1/deriv,1)
    line from i,j to i+scale*len,j+scale*len*deriv
  }
}
draw solid
for i from 0 to 1 by .05 do X
  next at i, exp(log((2*i*i*i+1)/3)/2)
X
.G2
