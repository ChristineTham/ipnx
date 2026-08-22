CC=mcc
CFLAGS= -g
go:	a.out
	../host/a.out m=/usr/jerq/lib/mpxterm t=`pwd`/a.out

a.out:	main.o lprintf.o host.o menu.o menus.o graphics.o menuhit.o
	mcc $(CFLAGS) main.o lprintf.o host.o menu.o menus.o graphics.o menuhit.o
	mopt a.out|grep "%"
	rm a.out
	mv m.out a.out
	mopt a.out|grep "%"
	rm a.out
	mv m.out a.out

lint:	a.out
	lint -I/usr/jerq/include -DMPX *.c|tee lint.out

menus.c: ../menus.c
	cp ../menus.c menus.c

host.o main.o menu.o lprintf.o graphics.o:../protocol.h
main.o : ../traps.h ../isp.h states.h
menu.o menus.o menuhit.o: ../menu.h
