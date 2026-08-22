all:	jplot jplot.m jplot.j unplot
unplot: unplot.c
	ar x blit.c.a jcom.h
	cc -O unplot.c -o unplot
jplot: libblit.a ../driver.o
	cc driver.o libblit.a -lm -o jplot
libblit.a: blit.c.a
	mkdir xplot
	cd xplot;ar x ../blit.c.a
	cd xplot;cc -c -O *.c
	cd xplot;ar rc libblit.a *.o
	mv xplot/libblit.a libblit.a
	ranlib libblit.a
	rm xplot/*
	rmdir xplot
jplot.m:	inblit.a
	mkdir xplot
	cd xplot;ar x ../inblit.a
	cd xplot; ar x ../blit.c.a jcom.h
	cd xplot;/usr/blit/bin/mcc *.c -lmj -o jplot.m
	mv xplot/jplot.m jplot.m
	rm xplot/*
	rmdir xplot
jplot.j:	inblit.a
	mkdir xplot
	cd xplot;ar x ../inblit.a
	cd xplot;ar x ../blit.c.a jcom.h
	cd xplot;/usr/blit/bin/mcc -j *.c -lmj -o jplot.j
	mv xplot/jplot.j jplot.j
	rm xplot/*
	rmdir xplot
install:
	cp jplot.m /usr/blit/mbin
	cp jplot.j /usr/blit/mbin
	cp jplot /usr/blit/bin
clean:
	rm jplot.m jplot.j jplot driver.o
