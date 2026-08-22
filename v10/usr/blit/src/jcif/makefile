CFLAGS=-g
CFILES=main.c alloc.c
OFILES=main.o cif.o alloc.o

all: jcif.m jcif

jcif: $(OFILES) jerq.o
	cc -o jcif $(OFILES) jerq.o -ly -ll

jcif.m: rect.o poly.o
	mcc -g -o jcif.m rect.o poly.o

rect.o: rect.c
	mcc -c -g rect.c

poly.o: poly.c
	mcc -c -g poly.c

cif.o: cif.c cif.h lex.yy.c

lex.yy.c: cif.lex
	lex cif.lex

$(OFILES): cif.h

print:
	@pr cif.h cif.lex cif.y $(CFILES)

wc:
	wc cif.h cif.lex cif.y $(CFILES)

clean:
	rm *.o cif.c lex.yy.c
