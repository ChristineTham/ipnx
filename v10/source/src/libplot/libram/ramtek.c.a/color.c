#include <stdio.h>
#include "ram.h"
color(s) 
char	*s; 
{
	register int	k;
	register short *p;
	if ((k = bcolor(s)) >= 0) {
		e1->foregr = k;
		p = buf;
		*p++ = SET;
		*p++ = FORE;
		*p++ = e1->foregr;
		write(Rfd, buf, FOREARG);
	}
}
