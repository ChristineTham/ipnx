#include <stdio.h>
#include "ram.h"
cfill(s) 
char	*s; 
{
	register int	k;
	register short *p;
	if ((k = bcolor(s)) >= 0) {
		e1->backgr = k;
		p = buf;
		*p++ = SET;
		*p++ = FORE;
		*p++ = e1->backgr;
		write(Rfd, buf, FOREARG);
	}
}
