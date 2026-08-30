MAKE=/bin/make
MAKEFILE=grabit.mk

OWNER=bin
GROUP=bin

MAN1DIR=/tmp
MAN5DIR=/usr/man/p_man/man5
POSTBIN=/usr/bin/postscript
POSTLIB=/usr/lib/postscript

all : grabit

install : all
	@if [ ! -d "$(POSTBIN)" ]; then \
	    mkdir $(POSTBIN); \
	    chmod 755 $(POSTBIN); \
	    : $(GROUP) $(POSTBIN); \
	    : $(OWNER) $(POSTBIN); \
	fi
	@if [ ! -d "$(POSTLIB)" ]; then \
	    mkdir $(POSTLIB); \
	    chmod 755 $(POSTLIB); \
	    : $(GROUP) $(POSTLIB); \
	    : $(OWNER) $(POSTLIB); \
	fi
	cp grabit $(POSTBIN)/grabit
	@chmod 755 $(POSTBIN)/grabit
	@: $(GROUP) $(POSTBIN)/grabit
	@: $(OWNER) $(POSTBIN)/grabit
	cp grabit.ps $(POSTLIB)/grabit.ps
	@chmod 644 $(POSTLIB)/grabit.ps
	@: $(GROUP) $(POSTLIB)/grabit.ps
	@: $(OWNER) $(POSTLIB)/grabit.ps
	cp grabit.1 $(MAN1DIR)/grabit.1
	@chmod 644 $(MAN1DIR)/grabit.1
	@: $(GROUP) $(MAN1DIR)/grabit.1
	@: $(OWNER) $(MAN1DIR)/grabit.1

clean :

clobber : clean
	rm -f grabit

grabit : grabit.sh
	sed "s'^POSTLIB=.*'POSTLIB=$(POSTLIB)'" grabit.sh >grabit
	@chmod 755 grabit

changes :
	@trap "" 1 2 3 15; \
	sed \
	    -e "s'^OWNER=.*'OWNER=$(OWNER)'" \
	    -e "s'^GROUP=.*'GROUP=$(GROUP)'" \
	    -e "s'^MAN1DIR=.*'MAN1DIR=$(MAN1DIR)'" \
	    -e "s'^MAN5DIR=.*'MAN5DIR=$(MAN5DIR)'" \
	    -e "s'^POSTBIN=.*'POSTBIN=$(POSTBIN)'" \
	    -e "s'^POSTLIB=.*'POSTLIB=$(POSTLIB)'" \
	$(MAKEFILE) >XXX.mk; \
	mv XXX.mk $(MAKEFILE); \
	sed \
	    -e "s'^.ds dQ.*'.ds dQ $(POSTLIB)'" \
	grabit.1 >XXX.1; \
	mv XXX.1 grabit.1

