.G1
frame invis ht 3 wid 4.5 left solid bot solid
coord x 0,4800 y 0.0,1.1
label left "Magnitude" left .2
label bottom "Frequency"
ticks left out at 0 "0", .1 "", .2 "", .3 "", .4 "", .5 "0.5"
ticks left out at .6 "", .7 "", .8 "", .9 "", 1 "1.0", 1.1 ""
ticks bot out at 0 "0", 600 "", 1200 "1200", 1800 "", 2400 "2400"
ticks bot out at 3000 "", 3600 "3600", 4200 "", 4800 "4800"
# draw dotted
pi=4.*atan2(1.0,1.0)
t=1.0/9600
h0=-0.078125
h2=-0.171875
h4=-0.625
for fx from 0 to 4800 by 10 do {
   w=2.0*pi*fx*t
   h=-2.0*(h0*sin(5*w)+h2*sin(3*w)+h4*sin(w))
   "." at fx,h
}
line from 0,1 to 4800,1
.G2
