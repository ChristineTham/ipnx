#include	<stdio.h>
#include	<ctype.h>
#include	"../comm.h"
#include	"host.h"

extern jerq;
/*
	input from troff output
*/

getnl(s)
	register char *s;
{
	while((*s++ = getchar()) != '\n');
	*s = 0;
}

getstr(s)
	register char *s;
{
	for(*s = getchar(); isspace(*s); *s = getchar());
	for(; !isspace(*s); *++s = getchar());
	ungetc(*s, stdin);
	*s = 0;
}

eatline()
{
	while(getchar() != '\n');
}

getn()
{
	register n, c, sign;

	while(c = getchar())
		if(!isspace(c)) break;
	if(c == '-')
	{
		sign = -1;
		c = getchar();
	}
	else
		sign = 1;
	for(n = 0; isdigit(c); c = getchar())
		n = n*10 + c - '0';
	while(c == ' ') c = getchar();
	ungetc(c, stdin);
	return(n*sign);
}
/*********************************/

reads(s)
	register char *s;
{
	for(;;)
	{
		read(jerq, s, 1);
		if(*s++ == 0) return;
	}
}

sign(a)
{
	return(a>=0? 1:-1);
}

/*****************************************************************/

#define	NPAGES	500
#define	CLICK	200000

static struct
{
	int eof;
	int next, end;
	unsigned size;
	char *base;
	int maxpage;
	int pages[NPAGES];
} input;

bump()
{
	extern char *malloc(), *realloc();

	if(input.base)
		input.base = realloc(input.base, input.size += CLICK);
	else
		input.base = malloc(input.size = CLICK);
}

pageset(n)
{
	if(n > input.maxpage)
		input.maxpage = n;
	input.pages[n] = input.next;
#ifdef	DEBUG
	if(debug)fprintf(debug, "pageset: page[%d] set to %d\n", n, input.pages[n]);
#endif	DEBUG
}

goseek(n)
	register n;
{
	register m;

#ifdef	DEBUG
	if(debug)fprintf(debug, "goseek(%d) ", n);
#endif	DEBUG
	if((n > input.maxpage) || (input.pages[n].offset == 0))
	{
		while(! input.eof)
		{
			if(readpage() == n)
				break;
			input.next = input.end;
		}
	}
	if(n > input.maxpage)
		n = input.maxpage;
#ifdef	DEBUG
	if(debug)fprintf(debug, "mapped to %d ", n);
#endif	DEBUG
	input.next = input.pages[n];
#ifdef	DEBUG
	if(debug)fprintf(debug, "next set to %d\n", input.next);
#endif	DEBUG
}

/******************************/

outc(c)
{
#ifdef	DEBUG
	if(verbose&&debug)fprintf(debug, "outc(%d)\n", c);
#endif	DEBUG
	if(input.next == input.end) bump();
	input.base[input.next++] = c;
}

outn(i)
	register i;
{
#ifdef	DEBUG
	if(verbose&&debug)fprintf(debug, "outn(%d)\n", i);
#endif	DEBUG
	outc(i>>8);
	outc(i&0377);
}

outs(s)
	char *s;
{
	while(*s)
		outc(*s++);
	outc(*s);
}
