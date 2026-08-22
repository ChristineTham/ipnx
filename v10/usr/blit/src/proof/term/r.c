#include <jerq.h>
#include "layer.h"
#include "font.h"
#include "../comm.h"
#include "term.h"

resize()
{
	Rectangle r;
	register x;
	register Layer *l;

	x = sqrt((long)(Drect.corner.x-Drect.origin.x)*
		(Drect.corner.y-Drect.origin.y)*17/22);	/* 22/17 = 11 x 8.5 inches */
	r.origin = P->layer->rect.origin;
	r.corner = add(r.origin, Pt(x, 22*x/17));
	if(r.corner.x > (XMAX-5))
	{
		r.origin.x -= r.corner.x - (XMAX-5);
		r.corner.x = (XMAX-5);
	}
	if(r.corner.y > (YMAX-5))
	{
		r.origin.y -= r.corner.y - (YMAX-5);
		r.corner.y = (YMAX-5);
	}
	dellayer(P->layer);
	l = newlayer(r);
	if(l == 0)
	{
		r.corner = add(r.origin, Pt(100,50));
		l = newlayer(r);
		if(l == 0)
			exit();	/* The Oh Shit case */
	}
	P->layer = l;
	Drect = P->rect = inset(r, 2);
	P->state |= RESHAPED;
#define	C_RESHAPE	8	/* should be in a .h but ... */
	mpxnewwind(P, C_RESHAPE);
}
