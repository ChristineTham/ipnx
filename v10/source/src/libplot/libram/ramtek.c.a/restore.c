#include <stdio.h>
#include "ram.h"
restore()
{
	register short *p;
	e1--;
	p = buf;
	*p++ = SET;
	*p++ = FORE;
	*p++ = e1->foregr;
	*p++ = SET;
	*p++ = BACK;
	*p++ = e1->backgr;
	write(Rfd, buf, FOREARG+BACKARG);
	move(e1->copyx, e1->copyy);
}
