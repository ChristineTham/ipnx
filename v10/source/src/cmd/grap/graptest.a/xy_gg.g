# The names x_gg, y_gg, and xy_gg are used by grap as pic macros
# to map the x, y and xy coordinates into pic.  so you can use them
# too in pic constructs.  the names are not the most mnemonic, but
# at least they seem to work.  i ought to document this, or invent
# a better name...


.G1
0 0
1 1
2 4
3 9
4 16
pic spline from x_gg(0), y_gg(0) to x_gg(1), y_gg(1) to x_gg(2), y_gg(4) to x_gg(3), y_gg(9) to x_gg(4), y_gg(16)
.G2


.G1
0 0
1 1
2 4
3 9
4 16
pic spline from xy_gg(0,0) to xy_gg(1,1) to xy_gg(2,4) to xy_gg(3,9) to xy_gg(4,16)
.G2
