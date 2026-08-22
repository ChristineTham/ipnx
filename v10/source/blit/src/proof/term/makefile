JERQBIN=/usr/blit/bin
JERQMBIN=/usr/blit/mbin
JERQLIB=/usr/blit/lib
JERQSRC=/usr/blit/src
JERQINCLUDE=/usr/blit/include
JERQSGS=/usr/blit/m
JERQDEMO=/usr/blit/demo
JERQFONT=/usr/blit/font
JERQICON=/usr/blit/icon
MCC=$(JERQBIN)/mcc
MCFLAGS=
MLD=$(JERQBIN)/mld
MAR=$(JERQBIN)/mar

MAKEARG= -$(MAKEFLAGS) JERQBIN=$(JERQBIN) JERQLIB=$(JERQLIB) JERQSRC=$(JERQSRC)\
	JERQINCLUDE=$(JERQINCLUDE) JERQSGS=$(JERQSGS) JERQDEMO=$(JERQDEMO)\
	JERQFONT=$(JERQFONT) JJERQICON=$(JERQICON)\
	MCC=$(MCC) MCFLAGS=$(MCFLAGS) MLD=$(MLD) MAR=$(MAR)

SYSJC= $(JERQLIB)/libsys.a $(JERQLIB)/libj.a $(JERQLIB)/libc.a
LCLCFLAGS=-g
CC=cc
CFLAGS=-I$(JERQINCLUDE)

.SUFFIXES: .o .c
.c.o:
	$(MCC) $(MCFLAGS) $(LCLCFLAGS) -c $<

all:	proof.j proof.m

proof.m: main.o term.o troff.o scroll.o r.o
	$(MCC) $(MCFLAGS) $(LCLCFLAGS) -o proof.m main.o term.o troff.o scroll.o r.o
	mopt proof.m; mv m.out proof.m

proof.j:	jmain.o jterm.o jscroll.o jtroff.o
	$(MLD) -o proof.j -b 256 $(JERQLIB)/l.o jmain.o jterm.o jscroll.o jtroff.o $(SYSJC)

main.o scroll.o term.o troff.o r.o:	term.h ../comm.h

jmain.o:	main.c term.h ../comm.h
	$(MCC) -m -c main.c; mv main.o jmain.o

jterm.o:	term.c term.h ../comm.h
	$(MCC) -m -c term.c; mv term.o jterm.o

jtroff.o:	troff.c term.h ../comm.h
	$(MCC) -m -c troff.c; mv troff.o jtroff.o

jscroll.o:	scroll.c term.h ../comm.h
	$(MCC) -m -c scroll.c; mv scroll.o jscroll.o

save:
	-cp $(JERQMBIN)/proof.m oproof.m
	-cp $(JERQLIB)/proof.j oproof.j

install:	$(JERQMBIN)/proof.m $(JERQLIB)/proof.j

$(JERQMBIN)/proof.m:	proof.m
	cp proof.m $(JERQMBIN)/proof.m

$(JERQLIB)/proof.j:	proof.j
	cp proof.j $(JERQLIB)/proof.j

pp:
	pp -t"Term Proof" makefile ../comm.h term.h main.c r.c scroll.c term.c troff.c | dcan

lint:
	lint -I/usr/blit/include main.c r.c term.c troff.c
