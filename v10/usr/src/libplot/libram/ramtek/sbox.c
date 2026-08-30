#include <stdio.h>
#include "ram.h"
sbox(x0, y0, x1, y1) 
double	x0, y0, x1, y1;
{
	register short *p;
	p = buf;
	*p++ = FILL;
	*p++ = FILL2;
	*p++ = e1->backgr;
	*p++ = SCX(x0);	
	*p++ = SCY(y1);
	*p++ = SCX(x1);	
	*p++ = SCY(y0);
	write(Rfd, buf, FOUT);
}
