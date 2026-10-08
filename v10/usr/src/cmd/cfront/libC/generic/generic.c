#include <stdio.h>
#include <libc.h>	/* ipnx: abort() is called below and nothing declared it;
			   cfront 2.1 refuses an undeclared function */

extern genericerror(int n, char* s)
{
	fprintf(stderr,"%s\n",s?s:"error in generic library function",n);
	abort();
	return 0;
};
