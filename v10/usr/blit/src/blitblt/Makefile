CC=mcc

blitblt: blitblt.c
	cc blitblt.c -ldk -o blitblt

BBOBJ=bbterm.o sendbitmap.o sendch.o buttons.o kbdstring.o mice.o
bbterm.m: $(BBOBJ)
	mcc $(BBOBJ) -o bbterm.m

bcan.out: bcan.c
	cc bcan.c -o bcan.out

bdump: bdump.c
	cc bdump.c -o bdump

clean:
	rm -f *.o *.m *.out blitblt
