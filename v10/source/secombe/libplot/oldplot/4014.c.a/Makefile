lib4014.a:	*.c
	make `ls *.c|sed 's/\.c/.o/`
.c.o:
	cc -c -O $*.c
	ar r lib4014.a $@
install:
	cp lib4014.a /usr/lib
