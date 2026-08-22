.sp
.G1
frame top invis right invis ht 3 wid 4
coord x .5, 32 log x y 0,50
label bot "Minimum Partition Size"
label left "CPU Time" "(seconds per" "iteration)" left .3
ticks bot in at 1,2,4,8,16
ticks left in at 10,20,30,40,50
 "x  0% variation" at 2,20
 "o  5% variation" at 2,15
 "\s-3\(bu\s0 10% variation" at 2,10

copy thru %  "x" at $6*.909,$7/32 % until "end"
new 0	i 32	r 1	1431.88	385	236
new 0	i 32	r 16	753.92	420	266
new 0	i 32	r 2	1292.90	386	247
new 0	i 32	r 4	1066.88	384	256
new 0	i 32	r 8	918.32	433	267
end
copy thru %  "\s-3\(bu\s0" at $6*1.1,$7/32 % until "end"
new 10	i 32	r 1	1414.42	232	220
new 10	i 32	r 16	744.13	248	224
new 10	i 32	r 2	1232.30	214	214
new 10	i 32	r 4	1044.27	234	220
new 10	i 32	r 8	879.68	270	222
end
copy thru %  "o" at $6,$7/32 % until "end"
new 5	i 32	r 1	1445.75	192	198
new 5	i 32	r 16	740.90	230	222
new 5	i 32	r 2	1270.40	188	207
new 5	i 32	r 4	1070.65	204	207
new 5	i 32	r 8	924.35	245	216
end
.G2
