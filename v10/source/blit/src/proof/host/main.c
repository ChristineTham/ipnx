#include	<stdio.h>
#include	<ctype.h>
#include	<setjmp.h>
#include	<signal.h>
#include	<sgtty.h>
#include 	"/usr/blit/include/jioctl.h"
#include	"../comm.h"

int zflag, jerq;
int res;
int scaled = 0;
jmp_buf env;
int gonow = 0;
int vpos, hpos, curfont, curpage, cursize;
int pages[200];
char devname[64];
struct sgttyb modes, savetty;

#ifdef	DEBUG
int verbose;
FILE *debug;
#endif	DEBUG

#define		LARGE		99999
#define		FATAL		1

main(argc, argv)
char *argv[];
{
	char c;
	int unproof = 0;
	int doinput = 0;
	int donothing = 0;
	/*
		analyse command line
	*/
	for(argv++; *argv && (**argv == '-'); argv++)
		switch(argv[0][1])
		{
		case 'z':
			zflag++;
			break;
		case 'u':
			unproof++;
			break;
		case 'w':
			scaled = 0;
			break;
		case 's':
			scaled = 1;
			break;
		case '\0':
			doinput = 1;
			break;
#ifdef	DEBUG
		case 'd':
			debug = stdin;
			break;
		case 'v':
			verbose++;
			break;
#endif	DEBUG
		default:
			fprintf(stderr, "unknown option '%s' ignored!\n", *argv);
			break;
		}
#ifdef	DEBUG
	if(debug)
	{
		debug = fopen("debug", "w");
		setbuf(debug, NULL);
	}
#endif	DEBUG
	if(*argv)
	{
		close(0);
		if(open(*argv, 0) == -1)
		{
			perror(*argv);
			exit(1);
		}
	}
	else if(!doinput)
	{	/* user just typed proof */
		donothing = isatty(0);
	}
	if(unproof)
	{
		ioctl(jerq, JTERM, (struct sgttyb *)0);
	}
	else
	{
		initblit(1);	/* blit is now a normal terminal */
		for(c = 0; c <= 10; c++)
			loadfont(c, "??");
		if(! donothing)
		{
			if(setjmp(env) == 0)
				troff();
		}
		ioctl(jerq, TIOCSETN, &savetty);
	}
}

int wantpage, doingpage;
int maxpage, eof, new, lastpageseen, new;

troff()
{
	int c;

	if(swallow()) return;	/* something wrong !!*/
	c = NAK;
	write(jerq, &c, 1);
	outc(scaled? C_SCALE:C_WINDOW);

	for(;;)
	{
		if((wantpage > maxpage) && !eof)
		{
			readhunk();
			new = lastpageseen;
		}
		else
			new = doingpage;
		if(doingpage == wantpage)
		{
			sendpkt();
			doingpage = wantpage = new;
			for(c = getjerq(); c != ACK; c = getjerq())
				cmd(c);
		}
	}
}

cmd(c)
{
	char str[256], ans[100];
	int n;
	extern jmp_buf env;

	c &= 0xFF;
#ifdef	DEBUG
	if(debug)fprintf(debug, "cmd(%d)\n", c);
#endif	DEBUG
	switch(c)
	{
	case C_PROBE:
		reads(ans);
		sprintf(str, "%s/%s", JERQFONT, ans);
		ans[0] = access(str, 4) == 0? ACK:NAK;
		write(jerq, ans, 1);
#ifdef	DEBUG
		if(debug)fprintf(debug, "probe(%s) returns %d", str, ans[0]);
#endif	DEBUG
		break;
	case C_FETCH:
		reads(str);
		sendfont(str);
		break;
	case C_SEEK:
		read(jerq, str, 1);
		read(jerq, str+1, 1);
		n = ((str[0]<<8) | str[1]) & 0xFFFF;
		goseek(n);
		oflush();
		outc(C_EXIT);
		oflush();
		break;
	case C_EXIT:
		longjmp(env, 1);
		break;
	}
}


char prooftty[]="/dev/tty";
char *ttyname();

initblit(load)
{
	char command[300];
	register i, notmpx;
	extern int jerq, zflag;

	jerq = open(prooftty, 2);
	if(jerq == -1)
	{
		fprintf(stderr, "proof couldn't open /dev/tty\n");
		exit(1);
	}
	notmpx = ioctl(jerq,JMPX,0) == -1;
	ioctl(jerq, TIOCGETP, &modes);
	savetty = modes;
	modes.sg_flags |= RAW;
	modes.sg_flags &= ~ECHO;
	ioctl(jerq, TIOCSETN, &modes);
	if((!isatty(1) || !verify()) && load)
	{
		sprintf(command, "%s %s %s <%s >%s", JLD, zflag?"-z":"",
			notmpx? JERQJ:JERQM, prooftty, prooftty);
		if(system(command) != 0)
		{
			fprintf(stderr, "%s failed\n", JLD);
			exit(1);
		}
		return(0);
	}
	return(1);
}

alarmcatch(){
}

verify()
{
	register rval;
	char c;

	signal(SIGALRM, alarmcatch);
	c=REQ;
	write(jerq, &c, 1);
	alarm(3);
	read(jerq, &c, 1);	/* if we alarm c is still a REQ (ACK) */
	alarm(0);
	rval = (c == NAK);
#ifdef	DEBUG
	if(debug)
		fprintf(debug, "verify: read 0%o\n", c);
#endif	DEBUG

	return rval;
}

done()
{
	exit(0);
}
