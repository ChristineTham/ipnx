libplot.a:	*.c
	make `ls *.c|sed 's/\.c/.o/`
.c.o:
	cc -c -O $*.c
	ar r libplot.a $@
install:
	cp libplot.a /usr/lib
