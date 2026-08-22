
CC =	mcc -g
DFLAGS =	-DBLIT
CFLAGS =
LDFLAGS =
HFILES = 	host.h pacman.h style.h
CFILES =	blt.c board.c blitfonts.c fruit.c host.c main.c monsters.c pacman.c prf.c sched.c sounds.c
OFILES =	blt.o board.o blitfonts.o fruit.o host.o main.o monsters.o pacman.o prf.o sched.o sounds.o
pacman:	$(OFILES)
	$(CC) $(LDFLAGS) -o pacman $(OFILES)

blitfonts.c: bits2blit
	-bits2blit >blitfonts.c

bits2blit:   fonts.c bits2blit.c
	cc -o bits2blit -DBLIT bits2blit.c fonts.c

.c.o:	$(HFILES)
	$(CC) -c $(CFLAGS) $(DFLAGS) $*.c	


install:	pacman
	cp pacman /usr/jerq/demo/mpx/pacman
	mstrip /usr/jerq/demo/mpx/pacman

strip:	pacman
	mstrip pacman

shrink:
	-rm -f *.o

clean:	shrink
	-rm -f pacman errs core a.out

lint:	$(CFILES)
	lint -pc $(CFILES)

list:	$(CFILES) $(HFILES) makefile
	oprl -x makefile $(CFILES) $(HFILES)
	oprl -x -C $(CFILES)
	touch list
