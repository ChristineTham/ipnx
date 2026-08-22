#include <jerq.h>
#include <jerqio.h>
#include "f.h"

#define FX	150
#define FY	150
#define OX	50
#define OY	50
char fontname[20];
int (*inch)();
FILE *infile;
Bitmap *spat;

inkbd()
{
	register c;
	do {
		wait(KBD);
		c = kbdchar();
	} while (c == -1);
	return((c == '\r') ? '\n' : c);
}

instd()
{
	register c;
	c = getc(infile);
	return(c);
}

main()
{
	jinit();
	request(KBD|SEND|RCV);
	space = 1;
	inch = instd;
	infile = stdin;
	spat = balloc(Rect(-OX,-FY,FX,OY));
	commands();
	inch = inkbd;
	commands();
	freefont();
	bfree(spat);
	exit();
}

Rectangle
pttorect(p)
Point p;
{
	Rectangle r;
	r.origin = r.corner = p;
	return(r);
}

Rectangle
mbbx(r,x)
Rectangle r;
register x;
{
	r.origin.x = min(x,r.origin.x);
	r.corner.x = max(x,r.corner.x);
	return(r);
}

Rectangle
mbby(r,y)
Rectangle r;
register y;
{
	r.origin.y = min(y,r.origin.y);
	r.corner.y = max(y,r.corner.y);
	return(r);
}

Rectangle
mbbpt(r,p)
Rectangle r;
Point p;
{
	register *rp = (int *) &r;
	*rp++ = min(p.x,*rp);
	*rp++ = min(p.y,*rp);
	*rp++ = max(p.x,*rp);
	*rp++ = max(p.y,*rp);
	return(r);
}

char *
intoken(buf)
char *buf;
{
	register c;
	register char *s;
	s = buf;
	while ((c = (*inch)()) == ' ' || c == '\n')
		;
	if (c == EOF)
		return(NULL);
	do {
		*s++ = c;
	} while ((c = (*inch)()) != ' ' && c != '\n');
	*s++ = '\0';
	return(buf);
}

isdigit(c)
register c;
{
	return(c>='0' && c<='9');
}

inint()
{
	register c,i,mflag = 0;
	register char *s;
	char buf[20];
	intoken(buf);
	s = buf;
	i = 0;
	if (*s == '-') {
		mflag = 1;
		s++;
	}
	while (isdigit(c = *s++))
		i = i*10 + c-'0';
	return(mflag ? -i : i);
}

equal(p,q)
register char *p,*q;
{
	for (; *p == *q; p++, q++)
		if (*p == '\0')
			return(1);
	return(0);
}

inmerg()
{
	char name[20];
	intoken(name);
	get202(name);
	showfull();
}

outcan()
{
	char name[20];
	intoken(name);
	putcanon(name,fontnum);
}

efont()
{
	char name[50];
	intoken(name);
	showem();
	readfont(name,fontnum);
	showem();
}

afont()
{
	char name[50];
	intoken(name);
	showem();
	alfont(name,fontnum);
	showem();
}

wfont()
{
	char name[50];
	intoken(name);
	writefont(name,fontnum);
}
	
include()
{
	FILE *f,*stdsave;
	char name[50];
	int (*insave)();
	if ((f = fopen(intoken(name),"r")) == (FILE *) NULL) {
		printf("can't open %s\n",name);
		exit();
	}
	insave = inch;
	stdsave = infile;
	inch = instd;
	infile = f;
	commands();
	fclose(f);
	infile = stdsave;
	inch = insave;
}

quit()
{
	exit();
}

echo()
{
	printf("echo\n");
}

snum() { fontnum = inint(); }

sspace() { space = inint(); }
extern int skip(),clear();

white()
{
	shrink(1);
}

reduce()
{
	shrink(0);
}

squish()
{
	shrink(2);
}


enadj()
{
	register i;
	i = inint();
	en(i);
}

typedef struct {
	char *text;
	int (*proc)();
} entry;

extern int ptsz,scale;
sptsz()
{
	ptsz = inint();
	scale = inint();
}

entry cmdvec[] = {
	{"cl",	clear},		/* clear current font */
	{"merg",	inmerg},	/* C001 */
	{"can",		outcan},	/* make versatec font file */
	{"i",	include},	/* include file */
	{"echo",	echo},
	{"q",	quit},
	{"e",	efont},
	{"w",	wfont},
	{"s",	skip},			/* make this char 0 width */
	{"space",	sspace},	/* between chars in font */
	{"white",	white},		/* insert white, not bits */
	{"en",	enadj},			/* make a space */
	{"f",	snum},			/* set fontnum */
	{"r",	reduce},
	{"sc",	squish},
	{"p",	sptsz},
	0,
};

commands()
{
	register char *s;
	register entry *e;
	char token[50];
	while ((s = intoken(token)) != NULL) {
		if (inch == instd && kbdchar() != -1)
			return;
		for (e = cmdvec; e->text != NULL; e++)
			if (equal(s,e->text)) {
				(*e->proc)();
				goto out;
			}
		printf("unrecognized command: %s\n",s);
out:
		;
	}
}
