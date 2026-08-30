TARGET=
OS=
CFLAGS=
LDFLAGS=-s
D=$(HOST)-$(HOSTOS)

all:	$(D)/rcc

OBJS=$(D)/bind.o $(D)/gen.o $(D)/decode.o \
	$(D)/vax-sel.o $(D)/mips-sel.o $(D)/mc-sel.o $(D)/sparc-sel.o

INCLUDES=-I$(HOST) -I. -I../c
include ../c/makefile

$(COBJS):	config.h
$(OBJS):	config.h
$(OBJS):	gen.h

$(D)/bind.o:	$(D)/bind.c;		$(CC) -c $(CCOPT) $(D)/bind.c && mv `basename $(D)/bind.c .c`.o $@
$(D)/decode.o:	$(HOST)/decode.c;	$(CC) -c $(CCOPT) $(HOST)/decode.c && mv `basename $(HOST)/decode.c .c`.o $@
$(D)/gen.o:	gen.c;			$(CC) -c $(CCOPT) gen.c && mv `basename gen.c .c`.o $@

$(D)/vax-sel.o:		vax/sel.c vax/pseudos.c stabbsd.c
			$(CC) -c -Ivax $(CCOPT) vax/sel.c && mv `basename vax/sel.c .c`.o $@
$(D)/mips-sel.o:	mips/config.h mips/sel.c mips/pseudos.c
			$(CC) -c -Imips $(CCOPT) mips/sel.c && mv `basename mips/sel.c .c`.o $@
$(D)/mc-sel.o:		mc/sel.c mc/pseudos.c stabbsd.c
			$(CC) -c -Imc $(CCOPT) mc/sel.c && mv `basename mc/sel.c .c`.o $@
$(D)/sparc-sel.o:	sparc/config.h sparc/sel.c sparc/pseudos.c stabbsd.c
			$(CC) -c -Isparc $(CCOPT) sparc/sel.c && mv `basename sparc/sel.c .c`.o $@

RUN=run
V=$(TARGET)-$(OS)
include ../tst/makefile
