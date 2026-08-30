SHELL=/bin/sh

COBJS=$(D)/dag.o \
	$(D)/decl.o \
	$(D)/enode.o \
	$(D)/error.o \
	$(D)/expr.o \
	$(D)/init.o \
	$(D)/input.o \
	$(D)/lex.o \
	$(D)/main.o \
	$(D)/output.o \
	$(D)/profio.o \
	$(D)/simp.o \
	$(D)/stmt.o \
	$(D)/string.o \
	$(D)/sym.o \
	$(D)/tree.o \
	$(D)/types.o

c-makefile:
	@echo 1>&2 run make from a target-specific directory

$(D)/rcc:	$(COBJS) $(OBJS)
		$(CC) $(LDFLAGS) -o $@ $(COBJS) $(OBJS)

C=../c

$(COBJS):	$(C)/c.h $(C)/token.h $(C)/ops.h
$(OBJS):	$(C)/c.h $(C)/token.h $(C)/ops.h

CCOPT=$(CFLAGS) $(INCLUDES)

$(D)/lex.o:	$(C)/keywords.h

$(D)/dag.o:	$(C)/dag.c;	$(CC) -c $(CCOPT) $(C)/dag.c && mv dag.o $@
$(D)/decl.o:	$(C)/decl.c;	$(CC) -c $(CCOPT) $(C)/decl.c && mv decl.o $@
$(D)/enode.o:	$(C)/enode.c;	$(CC) -c $(CCOPT) $(C)/enode.c && mv enode.o $@
$(D)/error.o:	$(C)/error.c;	$(CC) -c $(CCOPT) $(C)/error.c && mv error.o $@
$(D)/expr.o:	$(C)/expr.c;	$(CC) -c $(CCOPT) $(C)/expr.c && mv expr.o $@
$(D)/init.o:	$(C)/init.c;	$(CC) -c $(CCOPT) $(C)/init.c && mv init.o $@
$(D)/input.o:	$(C)/input.c;	$(CC) -c $(CCOPT) $(C)/input.c && mv input.o $@
$(D)/lex.o:	$(C)/lex.c;	$(CC) -c $(CCOPT) $(C)/lex.c && mv lex.o $@
$(D)/main.o:	$(C)/main.c;	$(CC) -c $(CCOPT) $(C)/main.c && mv main.o $@
$(D)/output.o:	$(C)/output.c;	$(CC) -c $(CCOPT) $(C)/output.c && mv output.o $@
$(D)/profio.o:	$(C)/profio.c;	$(CC) -c $(CCOPT) $(C)/profio.c && mv profio.o $@
$(D)/simp.o:	$(C)/simp.c;	$(CC) -c $(CCOPT) $(C)/simp.c && mv simp.o $@
$(D)/stmt.o:	$(C)/stmt.c;	$(CC) -c $(CCOPT) $(C)/stmt.c && mv stmt.o $@
$(D)/string.o:	$(C)/string.c;	$(CC) -c $(CCOPT) $(C)/string.c && mv string.o $@
$(D)/sym.o:	$(C)/sym.c;	$(CC) -c $(CCOPT) $(C)/sym.c && mv sym.o $@
$(D)/tree.o:	$(C)/tree.c;	$(CC) -c $(CCOPT) $(C)/tree.c && mv tree.o $@
$(D)/types.o:	$(C)/types.c;	$(CC) -c $(CCOPT) $(C)/types.c && mv types.o $@
