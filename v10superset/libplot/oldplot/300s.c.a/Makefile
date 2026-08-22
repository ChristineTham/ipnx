lib300s.a:	*.c
	make `ls *.c|sed 's/\.c/.o/`
.c.o:
	cc -c -O $*.c
	ar r lib300s.a $@
install:
	cp lib300s.a /usr/lib
