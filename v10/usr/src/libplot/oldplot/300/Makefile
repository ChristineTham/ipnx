lib300.a:	*.c
	make `ls *.c|sed 's/\.c/.o/`
.c.o:
	cc -c -O $*.c
	ar r lib300.a $@
install:
	cp lib300.a /usr/lib
