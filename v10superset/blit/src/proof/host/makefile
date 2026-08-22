JERQBIN=/usr/blit/bin
JERQM=/usr/blit/mbin/proof.m
JERQJ=/usr/blit/lib/proof.j
JERQINCLUDE=/usr/blit/include
JERQFONT=/usr/blit/font
JERQMISSING=$(JERQFONT)/MISSING
JLD=$(JERQBIN)/68ld

LCLCFLAGS=-g
CC=cc
CFLAGS=-I$(JERQINCLUDE) -DHOST

.c.o:
	$(CC) $(CFLAGS) $(LCLCFLAGS) -c $<

proof: main.o io.o font.o map.o
	$(CC) $(CFLAGS) $(LCLCFLAGS) -o proof main.o io.o font.o map.o

main.o:	main.c ../comm.h
	$(CC) $(CFLAGS) $(LCLCFLAGS) -DJERQJ=\"$(JERQJ)\" -DJERQM=\"$(JERQM)\" \
		-DJERQFONT=\"$(JERQFONT)\" -DJLD=\"$(JLD)\" -c main.c
.$(JERQFONT) -DJLD=\"$(JLD)\" -c main.c
.$(JERQFONT) -DJLD=\"$(JLD)\" -c main.c

font.o:	font.c ../comm.h
	$(CC) $(CFLAGS) $(LCLCFLAGS) -DJERQFONT=\"$(JERQFONT)\" \
		 -DJERQMISSING=\"$(JERQMISSING)\" -c font.c

io.o:	io.c ../comm.h
	$(CC) $(CFLAGS) $(LCLCFLAGS) -DJERQFONT=\"$(JERQFONT)\" -c io.c

map.o:	map.c
	$(CC) $(CFLAGS) $(LCLCFLAGS) -DJERQFONT=\"$(JERQFONT)\" -c map.c

clean:
	rm -f *.o proof 

save:
	-cp $(JERQBIN)/proof oproof

install:	$(JERQBIN)/proof

$(JERQBIN)/proof:	proof
	cp proof $(JERQBIN)/proof

pp:
	pp -t"Host Proof" makefile ../comm.h host.h main.c conv.c font.c io.c map.c | dcan

lint:
	lint -I/usr/blit/include main.c io.c font.c map.c
