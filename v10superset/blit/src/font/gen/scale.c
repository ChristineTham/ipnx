#include <jerq.h>
#include <jerqio.h>
#include "f.h"

#define FX	100
#define FY	100
#define OX	20
#define OY	20

Rectangle mbb,nullrect = {100,100,-100,-100};		/* mbb of reduced char */
Point showpt;
Font *font[10];
Bitmap *spat;

freefont()
{
	register i;
	register Font *f;
	for (i = 0; i < 10; i++)
		if ((f = font[i]) != (Font *) NULL) {
			bfree(f->strike);
			free(f);
			font[i] = (Font *) NULL;
		}
}

Point
showfont(f,p,r)
Font *f;
Point p;
Rectangle r;
{
	register i,x;
	int left,right,edge;
	register Fontchar *inf;
	inf = f->info;
	edge = r.corner.x - p.x;	/* allowable right extreme */
	left = right = 0;
	for (i = 0; i <= f->n; i++, inf++) {
		if ((x = inf->x) > edge) {
			bitblt(f->strike,Rect(left,0,right,f->height),
				&display,p,F_XOR);
			p.y += f->height;
			left = right;
			edge = left + r.corner.x - p.x;
		}
		right = x;
	}
	bitblt(f->strike,Rect(left,0,right,f->height),&display,p,F_XOR);
	p.y += f->height;
	return(p);
}

showem(n)
int n;
{
	register i;
	Point p;
	Rectangle r;
	r = inset(Drect,5);
	p = r.origin;
	for (i = 0; i < n; i++)
		p = showfont(font[i],p,r);
}

Font *
newfont()
{
	register Font *f;
	f = (Font *) alloc(sizeof(Font));
	f->n = 0;
	f->height = f->ascent = 0;
	if ((f->strike = balloc(Rect(0,0,0,0))) == (Bitmap *) NULL) {
		printf("balloc failed!\n");
		exit();
	}
	f->info[0].x = 0;
	return(f);
}

Font *
inschar(f,t)
register Font *f;
int t;
{
	register i,j,x,y;
	int m,n,w,ascent,descent,height,left,kern;
	Bitmap *b;
	register Fontchar *in;
	ascent = max(f->ascent,-mbb.origin.y);
	descent = max(f->height-f->ascent-1,mbb.corner.y);
	height = ascent+descent+1;
	w = space + (mbb.corner.x - mbb.origin.x);
	left = f->info[f->n].x;
	b = balloc(Rect(0,0,left+w,height));
	rectf(b,b->rect,F_CLR);
	if (f->n > 0)
	bitblt(f->strike,f->strike->rect,b,Pt(0,ascent-f->ascent),F_STORE);
	y = ascent + mbb.origin.y;
	bitblt(spat,mbb,b,Pt(left,y),F_OR);
	bfree(f->strike);
	in = f->info+f->n;
	in->top = y;
	in->bottom = mbb.corner.y + ascent;
	in->width = space+mbb.corner.x;		/* a guess, better than w? */
	in->left = mbb.origin.x;
	(in+1)->x = left+w;
	if ((j = ascent-f->ascent) > 0) {	/* fix up previous ones */
		in = f->info;
		for (i = 0; i < f->n; i++, in++) {
			in->bottom += j;
			in->top += j;
		}
		f->ascent = ascent;
	}
	f->height = height;
	f->n++;
	f->strike = b;
	return(f);
}

smmove(x,y)
int x,y;
{
	x = x;
	oldy = -(y);
}

Rectangle
mbbrect(r,s)
Rectangle r,s;
{
	register *rp = (int *) &r;
	register *sp = (int *) &s;
	*rp++ = min(*sp++,*rp);
	*rp++ = min(*sp++,*rp);
	*rp++ = max(*sp++,*rp);
	*rp++ = max(*sp++,*rp);
	return(r);
}

smcont(x,y)
register x,y;
{
	register i;
	Rectangle r;
	x = x;
	y = -(y);
	r.origin.x = x;
	r.corner.x = x+1;
	if (y >= oldy) {
		r.origin.y = oldy;
		r.corner.y = y+1;
	}
	else {
		r.origin.y = y;
		r.corner.y = oldy+1;
	}
	mbb = mbbrect(mbb,r);
	rectf(spat,r,F_OR);
	oldy = y;
}

smclear()
{
	rectf(spat,spat->rect,F_CLR);
}

scrunch()		/* smash a X2 bitmap */
{
	register x,y,*p;
	Rectangle r;
	register Bitmap *a;
	r = spat->rect;
	a = balloc(r);
	x = r.origin.x;
	y = r.origin.y;
	bitblt(spat,r,spat,Pt(x,y+1),F_OR);
	bitblt(spat,r,a,r.origin,F_STORE);
/*	rectf(a,r,F_XOR);
	bitblt(a,r,spat,Pt(x+1,y),F_OR);
 */
	rectf(a,r,F_CLR);
	for (x = r.origin.x, y = r.origin.y; x < r.corner.x; x += 2)
		bitblt(spat,Rect(x+1,y,x+2,r.corner.y),a,Pt(x/2,y),F_STORE);
	rectf(spat,r,F_CLR);
	for (x = r.origin.x/2,y = r.origin.y; y < r.corner.y; y += 2)
		bitblt(a,Rect(x,y+1,r.corner.x,y+2),spat,Pt(x,y/2),F_STORE);
	for (x = 0, p = (int *) &mbb; x++ < 4; p++)
		*p = *p/2;
	bfree(a);
}

int fmax;

skip()
{
	register n;
	register Font *f;
	register Fontchar *i;
	if (fontnum >= fmax) {
		font[fontnum] = newfont();
		fmax = fontnum+1;
	}
	f = font[fontnum];
	n = f->n;
	i = f->info + n;
	(i+1)->x = i->x;
	i->top = i->bottom = 0;
	i->left = i->width = 0;
	f->n = n+1;
}

en(n)		/* put in the white space, not the bits */
register n;
{
	register Font *f;
	register Fontchar *i;
	f = font[fontnum];
	i = f->info + n;
	i->top = 0;
	i->bottom = f->height;
	i->left = 0;
	i->width = (i+1)->x - i->x;
}

shrink(whiteout)
{
	fflag = 0;
	mbb = nullrect;
	move = smmove;
	cont = smcont;
	smclear();
	show();
	if (whiteout == 1)
		smclear();
	else if (whiteout == 2)
		scrunch();
	showem(fmax);
	if (fontnum >= fmax) {
		font[fontnum] = newfont();
		fmax = fontnum+1;
	}
	inschar(font[fontnum],thresh);
	showem(fmax);
}

clear()
{
	register Font **f;
	f = &font[fontnum];
	if (fontnum >= fmax) {
		*f = newfont();
		fmax = fontnum+1;
	}
	else {
		if (*f != (Font *) NULL)
			freefont();
		*f = newfont();
	}
}

