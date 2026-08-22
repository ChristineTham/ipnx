#include <stdio.h>
#include "ram.h"
erase()
{ 
	buf[0] = RESET;
	write(Rfd, buf, 2);
}
