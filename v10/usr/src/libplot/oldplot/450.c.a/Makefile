lib450.a:	*.c
	make `ls *.c|sed 's/\.c/.o/`
.c.o:
	cc -c -O $*.c
	ar r lib450.a $@
install:
	cp lib450.a /usr/lib
