#include <stdio.h>
#include "ram.h"
vec(xx, yy) 
double	xx, yy; 
{
	register short *p;
	e1->copyx = xx; 
	e1->copyy = yy;
	p = buf;
	*p++ = WV;
	*p++ = 4;
	*p++ = SCX(xx);
	*p++ = SCY(yy);
	write(Rfd, buf, VOUT);
}
