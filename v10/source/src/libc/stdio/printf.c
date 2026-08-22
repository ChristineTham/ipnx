/*
 * pANS stdio -- printf
 */
#include "iolib.h"
#include <lcc/stdarg.h>	/* ipnx: as vfprintf.c does; see PATCHES.md */
printf(fmt)		/* ipnx: K&R, see PATCHES.md */
	char *fmt;
{
	int n;
	va_list args;
	va_start(args, fmt);
	n=vfprintf(stdout, fmt, args);
	va_end(args);
	return n;
}
