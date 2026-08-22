.EQ
delim $$
.EN
.LP
asdfasdf a;lksdjf l;asdflk ad;lkf jalskdfj a;lsdkfj a;lsdkdfj a;lskdjf a;lskddjf a;lskdjf a;lkdjdf ;alksdjdf a;lskdjf ;alksdjdf 
.G1
frame ht 3 wid 3
coord x 0,6 y 0,20
label left "Run Time in" "Nanoseconds" left .3
ticks left in at 0 "$10 sup 0$", 3 "$10 sup 3$", 6 "$10 sup 6$", 9 "$10 sup 9$", 12 "$10 sup 12$", 15 "$10 sup 15$", 18 "$10 sup 18$"
label bot "Problem Size ($N$)"
ticks bot in at 0 "$10 sup 0$", 1 "$10 sup 1$", 2 "$10 sup 2$", 3 "$10 sup 3$", 4 "$10 sup 4$", 5 "$10 sup 5$", 6 "$10 sup 6$"
label right "Run Time in" "Common Units" right .5
ticks right in at 0 "nanosecond", 3 "microsecond", 6 "millisecond", 9 "second", 12.5 "hour", 13.93 "day", 15.41 "month", 16.5 "year", 18.52 "century"
line from 0,.5 to 6,18.5 solid
line from 0,7.3 to 6,13.3 dashed
 "TRS80 (19,500,000$N$)" at 1.6,10.8
 "Cray 1 (3.0$N sup 3$)" at 2.5,4
.G2
