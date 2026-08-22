#include <jerq.h>
#include "layer.h"
#include "font.h"
#include "term.h"
#include "../comm.h"
#ifdef	MPX
#undef	cursinhibit
#undef	cursallow
#define	cursinhibit()	{}
#define	cursallow()	{}
#else	MPX
#undef	transform
#define transform(p)	p
#endif	MPX

#define	NEWLINESIZE	16
#define CURSOR '\01'	/* cursor char in font */
Point	fudge={5, 3};
static Point curpos;
#define	LINEBUFSIZE 100

static lscroll(), formfeed(), newline(), backspace(), nexttab();

struct line{
	char buf[LINEBUFSIZE];
	char *bufp;
} line;

term()
{
	artdeco(0);
	request(KBD|SEND|RCV);
	formfeed(&line, &curpos);
	termc(CURSOR, 0, &curpos);
	for(;;)
	{
		wait(KBD|RCV);
		reshape(0);	/* checks for reshape */
		if(own()&KBD)
		{
			while(own()&KBD)
				send(kbdchar()&0177);
		}
		if(own()&RCV)
		{
			termc(CURSOR, 0, &curpos);
			while(own()&RCV)
				termc(inchar(), 1, &curpos);
			termc(CURSOR, 0, &curpos);
		}
	}
}

termc(c, advance, pp)
	register Point *pp;
{
	register Fontchar *fp;
	register struct line *linep = &line;
	Rectangle r;
	Point p;

	if(c == 0xE0)	/* break */
		c = 0xFF;
	switch(c&=0x7F){
	default:
		fp=defont.info+c;
		if(fp->width+pp->x >= Drect.corner.x)
			newline(linep, pp);
		p= *pp;
		r.origin.x=fp->x;
		r.corner.x=(fp+1)->x;
		r.origin.y=fp->top;
		r.corner.y=fp->bottom;
		p.y+=fp->top;
		bitblt(defont.bits, r, &display, p, F_XOR);
		if(advance){
			pp->x+=fp->width;
			if(linep->bufp<linep->buf+LINEBUFSIZE)
				*linep->bufp++=c;
		}
		break;
	case REQ:
		send(NAK);
		break;
	case NAK:
		stipple(display.rect);
		artdeco(1);
		tterm();
		request(KBD|SEND|RCV);
		stipple(display.rect);
		artdeco(0);
		formfeed(linep, pp);
		break;
	case '\n':
		newline(linep, pp);
		break;
	case '\7':
		*((char *)(384*1024L+062)) = 2;	/* beep */
		break;
	case '\r':
		pp->x=Drect.origin.x+5;
		break;
	case '\013':	/* ^K: reverse linefeed */
		if(pp->y>Drect.origin.y+5)
			pp->y-=NEWLINESIZE;
		break;
	case '\b':
		backspace(linep, pp);
		break;
	case '\014':
		formfeed(linep, pp);
		break;
	case '\t':
		pp->x=nexttab(pp->x);
		if(pp->x>=Drect.corner.x)
			newline(linep, pp);
		if(linep->bufp<linep->buf+LINEBUFSIZE)
			*linep->bufp++=c;
		break;
	}
}

reshape(n)
{
#ifdef	MPX
	if((P->state&(RESHAPED|MOVED))==RESHAPED)
	{
		artdeco(n);
		curpos = Drect.origin;
		termc(CURSOR, 0, &curpos);
	}
	if(P->state&MOVED)
		curpos = add(sub(curpos, arena.org), Drect.origin);
	P->state &= ~(MOVED|RESHAPED);
	arena.org = Drect.origin;
#endif	MPX
}

/*int eightspaces=8*dispatch[' '].c_wid;*/
static int eightspaces=72;

static
nexttab(x){
	register xx=x-Drect.origin.x-5;
	return(xx-(xx%eightspaces)+eightspaces+Drect.origin.x+5);
}

static
backspace(linep, pp)
	register struct line *linep;
	register Point *pp;
{
	register char *p;
	register x=Drect.origin.x+5;
	if(linep->bufp>linep->buf){
		for(p=linep->buf; p<linep->bufp-1; p++)
			if(*p=='\t')
				x=nexttab(x);
			else
				x+=defont.info[*p].width;
		pp->x=x;
		--linep->bufp;
		if(*p!='\t')
			termc(*p, 0, pp);
	}
}

static
newline(linep, pp)
	struct line *linep;
	register Point *pp;
{
	register cursoff=0;
	if(pp->y+2*NEWLINESIZE > Drect.corner.y-2){
		/* weirdness is because the tail of the arrow may be anywhere */
		if(rectXrect(Rect(mouse.xy.x-16, mouse.xy.y-16, mouse.xy.x+16,
				mouse.xy.y+16), Drect)){
			cursinhibit();
			cursoff++;
		}
		lscroll();
		if(cursoff)
			cursallow();
	}else
		pp->y+=NEWLINESIZE;
	pp->x=Drect.origin.x+fudge.x;
	linep->bufp=linep->buf;
}

static
lscroll()
{
	Rectangle r;

	r = Drect;
	r.origin.y += NEWLINESIZE;
	bitblt(&display, r, &display, Pt(r.origin.x, r.origin.y-NEWLINESIZE), F_STORE);
	stipple(Rpt(Pt(Drect.origin.x, Drect.corner.y-NEWLINESIZE), Drect.corner));
}

static
formfeed(linep, pp)
	struct line *linep;
	Point *pp;
{
	stipple(Drect);
	*pp=add(Drect.origin, fudge);
	linep->bufp=linep->buf;
}

