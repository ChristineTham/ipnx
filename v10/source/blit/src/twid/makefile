CFLAGS=-O -g
CC=mcc
OBJ=twid.o cursor.o data.o discture.o rotate.o bitmap.o
FILES=twid.c cursor.c data.c discture.c rotate.c bitmap.c

twid:	$(OBJ)
	mcc $(CFLAGS) -o twid $(OBJ)

cyntax:
	cyntax -m $(FILES) 2>&1 | cat

lint:
	@lint -I/usr/jerq/include $(FILES) -lj

clean:
	rm -rf twid $(OBJ) core
pp:
	pp -kjerq -ttwid $(FILES) | dcan

install:	twid
	cp twid /usr/jerq/lib/twid.m
	mstrip -gv /usr/jerq/lib/twid.m

twid.o data.o cursor.o:	twid.h
