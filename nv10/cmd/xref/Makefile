xref:	xrefa xrefb
xrefa:	xrefa.o ctype.o input.o output.o string.o divide.o
	cc -o xrefa xrefa.o ctype.o input.o output.o string.o divide.o -ll
xrefb:	xrefb.o ctype.o input.o output.o string.o divide.o
	cc -o xrefb xrefb.o ctype.o input.o output.o string.o divide.o

.c.o:;	cc -O -c $<
