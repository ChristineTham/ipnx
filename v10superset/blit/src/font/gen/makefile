CFLAGS=-g
CFILES=f.c merg.c scale.c font.c
OFILES=f.o merg.o scale.o font.o

all:	f imap smap genascii genspec

f: $(OFILES)
	mcc $(CFLAGS) -o f $(OFILES)

f.o:	f.c f.h
	mcc $(CFLAGS) -c f.c

merg.o:	merg.c f.h
	mcc $(CFLAGS) -c merg.c

scale.o:	scale.c f.h
	mcc $(CFLAGS) -c scale.c

font.o:	font.c f.h
	mcc $(CFLAGS) -c font.c

mtest:	mtest.o map.o
	cc $(CFLAGS) -o mtest mtest.o map.o

genascii genspec:	sizes.h

pp:
	pp f.h f.c merg.c scale.c font.c imap.c genascii.c genspec.c ddump.c mtest.c map.c| dcan
