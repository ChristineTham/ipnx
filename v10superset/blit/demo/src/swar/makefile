CC=mcc
CFLAGS=-g
swar:	swar.o
	mcc $(CFLAGS) swar.o -o swar
swar.o:	player0.icon player1.icon accel.h missile.icon deathstar.icon boom.icon
install:	swar
	mopt swar
	cp swar /usr/jerq/demo/mpx/swar
	mstrip -g /usr/jerq/demo/mpx/swar
clean:
	rm -f *.o m.out core swar
