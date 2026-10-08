# include	"trek.h"
#include	<sys/types.h>
#include	<sys/stat.h>

/**
 **	dump game for later restart
 **/

/*
 * THE GAME IS SAVED BY NAME ON THE VAX.  The PDP-11 original wrote the
 * whole data space, from address 0 up to sbrk(0), and restart() read it
 * back over itself -- which on a split-I&D PDP-11 (`cc -i') is data and
 * nothing else.  Here a binary is ZMAGIC unless ld is told otherwise
 * (ld.c: `if (rflag == 0 && Nflag == 0 && nflag == 0) zflag++'), address
 * 0 is its read-only text, so the read back can only fail, and restart
 * says `Cannot restart'.  So the dump is the objects a game consists of, in a
 * fixed order.  Their pointers (Status.shipname, Etc.eventptr) stay valid
 * because, as before, only the binary that wrote a dump can read it.
 *
 * And its header is written at the VAX's sizes: an int read back with
 * read(f,&n,2) keeps two bytes of whatever the stack held, so the inode
 * check that calls a copied dump cheating compared half an int with
 * garbage.  stat.h's STATBUF is V6's stat layout, whose i_ino is not where
 * this fstat puts st_ino; <sys/stat.h> is this machine's.
 */
#define	CHECK	10		/* 9 was the PDP-11's whole-memory dump */

extern char	Snapshot[14 + sizeof Quad + sizeof Event + sizeof Base + sizeof Etc];	/* events.c:8 */

struct dumpobj
{
	char	*addr;
	int	len;
} Dumpobj[] =
{
	(char *)Quad,		sizeof Quad,
	(char *)Sect,		sizeof Sect,
	&Quadx,			sizeof Quadx,
	&Quady,			sizeof Quady,
	&Sectx,			sizeof Sectx,
	&Secty,			sizeof Secty,
	Damage,			sizeof Damage,
	(char *)Event,		sizeof Event,
	(char *)Kling,		sizeof Kling,
	(char *)&Nkling,	sizeof Nkling,
	(char *)&Initial,	sizeof Initial,
	(char *)&Status,	sizeof Status,
	(char *)&inittime,	sizeof inittime,
	(char *)&Game,		sizeof Game,
	(char *)&Move,		sizeof Move,
	(char *)&Param,		sizeof Param,
	(char *)&Etc,		sizeof Etc,
	(char *)Base,		sizeof Base,
	(char *)&Starbase,	sizeof Starbase,
	0,			0
};

inode(f)
{	struct stat	buf;

	fstat(f,&buf);
	return(buf.st_ino);
}

long Ftime(f)
{	struct stat	buf;

	fstat(f,&buf);
	return(buf.st_mtime);
}

dumpgame()
{
	register int	f;
	register struct dumpobj	*d;
	int		check;
	long		t;
	int		n;

	if((f=creat("trek.dump",0664))<0) {
		printf("Cannot create 'trek.dump'\n");
		return;
	}

	check=CHECK; write(f,&check,sizeof check);
	lseek(f,(long)(sizeof check + sizeof n + sizeof t),0);
	for (d = Dumpobj; d->addr; d++)
		if(write(f,d->addr,d->len)!=d->len) {
			printf("Failed to write dump\n");
			return;
		}
	if(write(f,Snapshot,sizeof Snapshot)!=sizeof Snapshot) {
		printf("Failed to write dump\n");
		return;
	}
	lseek(f,(long)sizeof check,0);
	n=inode(f); write(f,&n,sizeof n);
	time(&t); write(f,&t,sizeof t); close(f);
	exit(0);
}

restart()
{
	register int	f;
	register struct dumpobj	*d;
	int		check;
	char		chkpass[PWDLEN];
	long		t, tfile;
	int		n, nfile;

	if((f=open("trek.dump",0))<0) {
		printf("Cannot open 'trek.dump'\n");
		return(0);
	}

	read(f,&check,sizeof check);
	read(f,&n,sizeof n); read(f,&t,sizeof t);
	nfile=inode(f); tfile=Ftime(f);
	if(check!=CHECK) {
		printf("Cannot restart\n");
		exit(1);
	}
	for (d = Dumpobj; d->addr; d++)
		if(read(f,d->addr,d->len)!=d->len) {
			printf("Cannot restart\n");
			exit(1);
		}
	if(read(f,Snapshot,sizeof Snapshot)!=sizeof Snapshot) {
		printf("Cannot restart\n");
		exit(1);
	}
	getpasswd(chkpass);
	if (cf(chkpass, Game.passwd)) {
		printf("Incorrect password\n");
		exit(1);
	}
	unlink("trek.dump");
	if(nfile!=n || tfile>t+2)
		lose(L_CHEAT);
	return(1);
}
