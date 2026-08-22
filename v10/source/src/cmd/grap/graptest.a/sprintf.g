orgate!orux6!cam (charles meeks)
.G1
ticks off
plot sprintf("cats = %g Dogs = %g rain = %g",5,3,1) at (5,10)
.G2
.G1
variance = 1.234567
stddev = 4.56789
plot sprintf("var = %g, sd = %.2f", variance, stddev) at .5,.5
plot sprintf("var = %g", variance) ljust at .05,.05
plot sprintf("nonsense = %g", variance + stddev) rjust at .95,.95
0 0
1 1
.G2

.G1
a = 1
b = 2
print sprintf("stderr: a=%g, b=%g", a, b)
print sprintf("more stderr: a=%g", a)
.G2
