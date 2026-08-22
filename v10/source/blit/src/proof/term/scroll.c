#include <jerq.h>
#include "layer.h"
#include "font.h"
#include "../comm.h"
#include "term.h"

extern int curpage;

scroll(p)
	Point p;
{
	int ret;
	Rectangle r, or;
	int horiz;

	if(ptinrect(p, arena.vbar))
		horiz = 0;
	else if(ptinrect(p, arena.hbar))
		horiz = 1;
	else
		return(0);
	or = r = arena.v;
	ret = sscroll(horiz, p);
	for(; button123(); nap(2))
	{
		p = mouse.xy;
		if((ptinrect(p, arena.hbar) && horiz) || (ptinrect(p, arena.vbar) && !horiz))
		{
			arena.v = r;
			ret = sscroll(horiz, p);
		}
	}
	if(! ptinrect(mouse.xy, horiz? arena.hbar:arena.vbar))
	{
		arena.v = or;
		ret = 0;
	}
	else if(!horiz)
	{
		r = arena.v;
		tseek(curpage);
		arena.v = r;
		doticks();
	}
	return(ret);
}

#define	convinit(bar, dim)	scale = arena.bar.corner.dim-arena.bar.origin.dim-2
#define	chartoy(N, bar, dim)	(scale*N/arena.psize.dim + arena.bar.origin.dim+1)
#define	ytochar(Y, bar, dim)	((long)arena.psize.dim*(Y - arena.bar.origin.dim - 1)/scale)

sscroll(horiz, p)
	Point p;
{
	register long scale;
	register d, xx;
	int ret = 'a';
	int ny;

	if(horiz)
	{
		convinit(hbar, x);
		if(button1())
			arena.v.origin.x -= p.x - arena.hbar.origin.x;
		else if(button2())
			arena.v.origin.x = ytochar(p.x, hbar, x);
		else
			arena.v.origin.x += p.x - arena.hbar.origin.x;
		d = arena.window.corner.x - arena.window.origin.x;
		if(arena.v.origin.x < 0)
			arena.v.origin.x = 0;
		if(arena.v.origin.x+d > arena.psize.x)
			arena.v.origin.x = arena.psize.x-d;
		arena.v.corner.x = arena.v.origin.x + d;
	}
	else
	{
		convinit(vbar, y);
		xx = mouse.buttons;
		if(xx&4)
			arena.v.origin.y -= p.y-arena.vbar.origin.y;
		else if(xx&2)
			arena.v.origin.y = ytochar(p.y, vbar, y);
		else
		{
			if(arena.v.corner.y == arena.psize.y)
				ret = '\n';
			else
				arena.v.origin.y += p.y-arena.vbar.origin.y;
		}
		ny = arena.v.origin.y;
		d = arena.window.corner.y - arena.window.origin.y;
		arena.v.origin.y = ny;
		if(arena.v.origin.y < 0)
			arena.v.origin.y = 0;
		if(arena.v.origin.y+d > arena.psize.y)
			arena.v.origin.y = arena.psize.y-d;
		arena.v.corner.y = arena.v.origin.y+d;
	}
	doticks();
	return(ret);
}

calcticks()
{
	register long scale;

	convinit(hbar, x);
	arena.htick = inset(arena.hbar, 1);
	arena.htick.origin.x = chartoy(arena.v.origin.x, hbar, x);
	arena.htick.corner.x = chartoy(arena.v.corner.x, hbar, x);
	convinit(vbar, y);
	arena.vtick = inset(arena.vbar, 1);
	arena.vtick.origin.y = chartoy(arena.v.origin.y, vbar, y);
	arena.vtick.corner.y = chartoy(arena.v.corner.y, vbar, y);
}

doticks()
{
	Rectangle rh, rv;

	rh = arena.htick;
	rv = arena.vtick;
	calcticks();
	if(!eqrect(arena.htick, rh))
		xor(rh), xor(arena.htick);
	if(!eqrect(arena.vtick, rv))
		xor(rv), xor(arena.vtick);
}

xor(r)
	Rectangle r;
{
	rectf(&display, r, F_XOR);
}

#ifndef	MPX
stipple(r)
	Rectangle r;
{
	cursinhibit();
	rectf(&display, r, F_CLR);
	cursallow();
}
#endif	MPX
