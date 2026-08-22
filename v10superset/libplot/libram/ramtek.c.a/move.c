#include <stdio.h>
#include "ram.h"
move(xx, yy) 
double	xx, yy; 
{
	register short *p;
	e1->copyx = xx;	
	e1->copyy = yy;
	p = buf;
	*p++ = SET;
	*p++ = STRT;
	*p++ = SCX(xx);	
	*p = SCY(yy);
	write(Rfd, buf, STRTARG);
}
