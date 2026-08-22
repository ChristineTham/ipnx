MAIN     = keyboard.h kbd.c

KEYBOARD = keyboard.h keyboard.c

KBDSYS   = kbd.o keyboard.o

kbd.m:		$(KBDSYS);   mcc -o kbd.m  $(KBDSYS) 

kbd.o:		$(MAIN);     mcc -c -g     kbd.c

keyboard.o:	$(KEYBOARD); mcc -c -g     keyboard.c

save:		cp kbd.c o.kbd.c
		cp keyboard.c o.keyboard.c
		cp keyboard.h o.keyboard.h
		cp kbd.m o.kbd.m

install:	kbd.m
		mv kbd.m /usr/jerq/lib
		ikeya pull sola /usr/jerq/lib/kbd.m /usr/jerq/lib
		ikeya pull sola /usr/luca/kbd/kbd.c /usr/jerq/src/kbd
		ikeya pull sola /usr/luca/kbd/keyboard.c /usr/jerq/src/kbd
		ikeya pull sola /usr/luca/kbd/keyboard.h /usr/jerq/src/kbd
		ikeya pull sola /usr/luca/kbd/Makefile /usr/jerq/src/kbd

		
