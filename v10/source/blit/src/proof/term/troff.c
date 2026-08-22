#include <jerq.h>
#include "layer.h"
#include "font.h"
#include "../comm.h"
#include "term.h"

Point cursor;	/* current point */
Font *curfont;
int curpage, dopage;
static fontno, fontchanged, psize, resolution = 1;
Texture cup =
{
	0x0100, 0x00E0, 0x0010, 0x03E0, 0x0400, 0x0FE0, 0x123C, 0x1FE2,
	0x101A, 0x101A, 0x1002, 0x103C, 0x1810, 0x6FEC, 0x4004, 0x3FF8
};

tterm()
{
	register c;
	int loop = 1;
	Texture *t;

	request(SEND|RCV|KBD|MOUSE);
	dopage = 0;
	cursor.x = cursor.y = 0;
	t = cursswitch(&cup);
	hblock();
	while(loop)
	{
		treshape();	/* checks for reshape */
		if(dmap(cursor.y) > arena.v.corner.y)
		{
			if(dmap(cursor.y) > arena.psize.y)
				arena.psize.y = dmap(cursor.y);
			if(user(1, curpage))
				break;
		}
		c = hchar();
		if(c < 128)
			drawchar(c);
		else if(c < C_PAGE)
			cursor.x += c - C_HOR;
		else if(c >= C_SIZE)
		{
			psize = c-C_SIZE+SIZE_ORIG;
			fontchanged++;
		}
		else if((c >= C_FONT) && (c <= C_FONT+10))
		{
			fontno = c-C_FONT;
			fontchanged++;
		}
		else switch(c)
		{
		case C_PAGE:
			c = inshort();
			if(c == -1)
			{
				loop = 0;
				if(user(0, c) == 0)
				{
					if(seeked)
						loop = 1;
					else
						send(C_EXIT);
				}
			}
			else if(dopage++ && user(0, c))
				loop = 0;
			cursor.y = 0;
			curpage = c;
			break;
		case C_BSIZE:
			psize = hchar();
			fontchanged++;
			break;
		case C_ABSH:
			cursor.x = inshort();
			break;
		case C_ABSV:
			cursor.y = inshort();
			break;
		case C_DEV:
			devcntrl();
			break;
		case C_DRAW:
			draw();
			break;
		case C_EXIT:
			send(ACK);
			bye();
			break;
		case C_WINDOW:
		case C_SCALE:
			setshrink(c == C_SCALE);
			break;
		}
	}
	(void)cursswitch(t);
}

devcntrl()
{
	switch(hchar())
	{
	case RES:
		resolution = inshort();
		break;
	case FONT:
		ldfont(hchar());
		fontchanged++;
		break;
	}
}

treshape()
{
	Point delta;

#ifdef	MPX
	if((P->state&(RESHAPED|MOVED))==RESHAPED)
	{
		artdeco(1);
		P->state &= ~(MOVED|RESHAPED);
	}
	if(P->state&MOVED)
	{
		P->state &= ~(MOVED|RESHAPED);
		delta = sub(Drect.origin, arena.org);
		arena.org = Drect.origin;
		arena.window = raddp(arena.window, delta);
		arena.vbar = raddp(arena.vbar, delta);
		arena.vtick = raddp(arena.vtick, delta);
		arena.hbar = raddp(arena.hbar, delta);
		arena.htick = raddp(arena.htick, delta);
	}
#endif	MPX
}

/************************************************************
	I/O
*/

gchar()
{
	wait(RCV);
	return(rcvchar());
}

static char block[PACKET], *nb, *ne;

hblock()
{
	register count;

	count = gchar();
	for(ne = nb = block; count--; *ne++ = gchar());
	(void)gchar();
}

hchar()
{
	if(nb == ne)
	{
		send(ACK);
		hblock();
	}
	return(*nb++ & 0xFF);
}

inshort()
{
	int i;
	register char *p = (char *) &i;
	*p++ = hchar();
	*p++ = hchar();
	return(i);
}

Point inpoint()
{
	Point p;

	p.x = inshort();
	p.y = inshort();
	return(p);
}

tseek(i)
{
	send(C_SEEK);
	sendn(i);
	do {
		send(ACK);
		hblock();
	} while(block[0]&0xFF != C_EXIT);
	stipple(arena.window);
	arena.v = rsubp(arena.v, Pt(0, arena.v.origin.y));
	doticks();
	dopage = 0;
	cursor.y = 0;	/* spring no traps */
}

/************************************************************
	Font management
*/

Font *curfont;
static age;
struct ftab
{
	int age;
	char name[10];
	Font *font;
} ftab[NFONTS];
static char fnames[11][10];
static struct ftab *oldf;

dmap(x)
{
	register long z = x;

	z *= 100;
	z += resolution/2;
	z /= resolution;
	return( (int)z );
}

Point
pmap(p)
	Point p;
{
	p.x = dmap(p.x);
	p.y = dmap(p.y);
	return(add(arena.window.corner, sub(p, arena.v.corner)));
}

setshrink(yes)
{
}

static
drawchar(c)
{
	register Fontchar *fp;
	Point p;
	Rectangle r;

	p = pmap(cursor);
	if(fontchanged)
	{
		c = loadfont(fontno, psize, c);
		fontchanged = 0;
	}
	if(c == 0)
	{
		curfont = &defont;
		c = '?';
	}
	if(c)
	{
		fp = curfont->info + c;
		r.origin.x=fp->x;
		r.corner.x=(fp+1)->x;
		r.origin.y=fp->top;
		r.corner.y=fp->bottom;
		p.y += fp->top - curfont->ascent;
		rectclip(&r, raddp(arena.window, sub(r.origin, p)));
		bitblt(curfont->bits, r, &display, p, F_OR);
	}
}

ldfont(n)
{
	register char *s;

	for(s = fnames[n];;)
		if((*s++ = hchar()) == 0)
			return;
}

loadfont(n, s, c)
{
	char name[64], file[64];

	sprintf(name, "%s.%d", fnames[n], s);
	if(findit(name))
		return(c);
	if(strcmp(fnames[n], "S") == 0)
	{
		sprintf(file, "%s/ALL", name);
		if(! probe(file))
		{
			sprintf(file, "%s/%d", name, c);
			if(findit(file))
				return(1);
			strcpy(name, file);
			c = 1;
		}
	
	}
	else
		strcpy(file, name);

	send(C_FETCH);
	sendnchars(strlen(file)+1, file);
	if(gchar() == NAK)
		return(0);
	strcpy(oldf->name, name);
	oldf->age = ++age;
	fontmsg(name);
	ffree(oldf->font);
	oldf->font = infont(gchar);
	if(oldf->font == 0) oldf->font = &defont;
	curfont = oldf->font;
	fontmsg(name);
	return(c);
}

probe(file)
	char *file;
{
	send(C_PROBE);
	sendnchars(strlen(file)+1, file);
	return(gchar() == ACK);
}

fontmsg(name)
	char *name;
{
	char buf[64];

	strcpy(buf, "loading font ");
	strcat(buf, name);
	string(&defont, buf, &display, add(Pt(10,3), Drect.origin), F_XOR);
}

static
findit(name)
	char *name;
{
	register struct ftab *f;
	register old = age+1, found = 0;

	for(f = ftab; f != &ftab[NFONTS]; f++)
		if(strcmp(f->name, name) == 0)
		{
			f->age = ++age;
			curfont = f->font;
			found++;
			break;
		}
	for(f = ftab; f != &ftab[NFONTS]; f++)
		if(f->age < old)
		{
			oldf = f;
			old = oldf->age;
		}
	return(found);
}

bye()
{
	int i;

	for(i = 0; i < NFONTS; i++)
		if(ftab[i].font != &defont)
			ffree(ftab[i].font);
	exit();
}

/**************************************************
	draw stuff
*/
draw()
{
	Point p, q, c;
	int a, b;

	a = hchar();
	switch(a)
	{
	case LINE:
		p = pmap(cursor);
		q = pmap(add(cursor, inpoint()));
		segment(&display, p, q, F_OR);
		break;
	case CIRCLE:
		p = pmap(cursor);
		a = dmap(inshort()/2);
		p.x += a;	/* point was left edge */
		circle(&display, p, a, F_OR);
		break;
	case ELLIPSE:
		a = dmap(inshort()/2);
		b = dmap(inshort()/2);
		p = add(pmap(cursor), Pt(a, 0));
		ellipse(&display, p, a, b, F_OR);
		break;
	case ARC:
		p = pmap(cursor);
		q = add(cursor, inpoint());
		c = pmap(q);
		q = pmap(add(q, inpoint()));
		arc(&display, c, p, q, F_OR);
		break;
	case SPLINE:
		jspline(hchar());
		break;
	}
}

static Point pts[60];

static
jspline(n)
	int n;
{
	register i;
	Point *pp;

	for(i = 0, pp = &pts[1]; i < n; i++)
		*pp++ = pmap(inpoint());
	spline(n+1, pts, F_OR);
}

static
spline(n, pp, f)
	register Point *pp;
	int n, f;
{
	register long w, t1, t2, t3, scale=1000; 
	register int i, j, steps=10; 
	Point p, q;

	pp[0] = pp[1];
	pp[n] = pp[n-1];
	p = pp[0];
	for(i = 0; i < n-1; i++)
	{
		for(j = 0; j < steps; j++)
		{
			w = scale * j / steps;
			t1 = w * w / (2 * scale);
			w = w - scale/2;
			t2 = 3*scale/4 - w * w / scale;
			w = w - scale/2;
			t3 = w * w / (2*scale);
			q.x = (t1*pp[i+2].x + t2*pp[i+1].x + 
				t3*pp[i].x + scale/2) / scale;
			q.y = (t1*pp[i+2].y + t2*pp[i+1].y + 
				t3*pp[i].y + scale/2) / scale;
			segment(&display, p, q, f);
			p = q;
		}
	}
}
