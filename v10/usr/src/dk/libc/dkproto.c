/*
 * Make sure that URP protocol is enabled on a datakit file.
 */
#include <sys/filio.h>	/* ipnx: sys/ioctl.h is on no tape */
#include <sys/dkio.h>

dkproto(file, linedis)
{
	if (ioctl(file, KIOCISURP, (char *)0) < 0)
		return(ioctl(file, FIOPUSHLD, &linedis));
	ioctl(file, KIOCINIT, (char *)0);
	return(0);
}
