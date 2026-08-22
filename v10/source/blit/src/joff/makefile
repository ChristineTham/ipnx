wrong:
	pwd

x9700:
	pr -n *.[hcy] */*.[hcy] makefile */makefile|r70 x9700

install:
	cp host/a.out /usr/jerq/lib/joff
	cp term/a.out /usr/jerq/mbin/joff.m
	mstrip -gv /usr/jerq/mbin/joff.m

stable:
	cp /usr/jerq/lib/joff /usr/tac/joff/lib/joff$$$$
	cp /usr/jerq/mbin/joff.m /usr/tac/joff/lib/joff.m$$$$

sizes:	host/a.out term/a.out
	size host/*.o a.out >sizes
	msize term/*.o a.out >>sizes
	wc *.h */*.[hc] >>sizes

backup:
	/usr/tac/bin/backup makefile *.[hcy] `pwd`
	/usr/tac/bin/backup host/makefile host/*.[hcy] `pwd`/host
	/usr/tac/bin/backup term/makefile term/*.[hcy] `pwd`/term
	/usr/tac/bin/backup bomb/makefile bomb/*.[hcy] `pwd`/bomb
