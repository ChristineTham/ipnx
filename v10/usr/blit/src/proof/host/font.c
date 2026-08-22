#include <stdio.h>
#include <signal.h>
#include <sys/types.h>
#include <dir.h>
#include	<time.h>
#include "/usr/blit/include/jioctl.h"
#include "../comm.h"

static char name[11][32];
int curfont;
int blitfont = 0;
static blith, blitv;
extern vpos, hpos, jerq;

yset()
{
	vpos = 0;
	blitv = 0;
}

loadfont(n, s)
	char *s;
{
	strcpy(name[n], s);
}

static
special()
{
	register i;
	static last = 0;

	if(strcmp(name[last], "S") == 0)
		return(last);
	for(i = 0; i < 11; i++)
		if(strcmp(name[i], "S") == 0)
			return(last = i);
	return(0);
}

xygoto()
{
	register d;

	if(blitv != vpos)
	{
		outc(C_ABSV);
		outn(vpos);
		blitv = vpos;
	}
	if(blith != hpos)
	{
		if((blith < hpos) && (blith+99 >= hpos))
			outc(C_HOR + hpos-blith);
		else
		{
			outc(C_ABSH);
			outn(hpos);
		}
		blith = hpos;
	}
}

static
put(x, font)
{

	xygoto();
	if(font != blitfont)
	{
		blitfont = font;
		outc(C_FONT + blitfont);
	}
	outc(x);
}

dochar(c)
	char *c;
{
	register x;

#ifdef	DEBUG
	if(debug)fprintf(debug,"%s$",c);
#endif	DEBUG
	if(c[1] == 0)
		put(c[0], curfont);
	else
	{
		if(x = imap(c))
			put(x, curfont);
		else if(x = smap(c))
			put(x, special());
	}
#ifdef	DEBUG
	if(debug)fprintf(debug," returns %d",x);
#endif	DEBUG
}

sendfont(name)
	char *name;
{
	register n, fd;
	char buf[BUFSIZ], file[256];

	sprintf(file, "%s/%s", JERQFONT, name);
	fd = open(file, 0);
	if(fd == -1)
	{
		buf[0] = NAK;
		write(jerq, buf, 1);
#ifdef	DEBUG
		if(debug)fprintf(debug, "sendfont(%s) returns NAK\n", file);
#endif	DEBUG
		missing(name);
	}
	else
	{
		buf[0] = ACK;
		write(jerq, buf, 1);
		n = read(fd, buf, BUFSIZ);
		write(jerq, buf, n);
		while((n = read(fd, buf, BUFSIZ)) > 0)
			write(jerq, buf, n);
		close(fd);
#ifdef	DEBUG
		if(debug)fprintf(debug, "sendfont(%s) returns ACK+font\n", file);
#endif	DEBUG
	}
}

missing(name)
	char *name;
{
	static char miss[200][10];
	static next = 0;
	register s;
	register FILE *f;
	long clk;
	struct tm *tm;
	extern struct tm *localtime();

	for(s = 0; s != next; s++)
		if(strcmp(miss[s], name) == 0) return;
	strcpy(miss[next], name);
	if(next != 200)
		next++;
	if((f = fopen(JERQMISSING, "a")) != NULL)
	{
		time(&clk);
		tm = localtime(&clk);
		fprintf(f, "%s	%d/%d/%d\n", name, tm->tm_year, tm->tm_mon, tm->tm_mday);
		fclose(f);
	}
}
