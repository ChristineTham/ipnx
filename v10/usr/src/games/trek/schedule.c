# include	"trek.h"

/**
 **	schedule an event
 **/

EVENT *
schedule(type, delta, x, y, z)
int	type;
float	delta;
char	x, y;
char	z;
{
	register EVENT		*e;
	register int		i;

	for (i = 0; i < MAXEVENTS; i++)
	{
		e = &Event[i];
		if (e->evcode >= 0)
			continue;
		/* got a slot */
		e->evcode = type;
		e->date = Status.date + delta;
		e->x = x;
		e->y = y;
		e->evdata = z;
		if (type < 64)
			Etc.eventptr[type] = e;
		return(e);
	}
	syserr("Cannot schedule event %d parm %d %d %d", type, x, y, z);
	return((EVENT *) -1);
}


/**
 **	reschedule an event
 **/

reschedule(e, delta)
EVENT		*e;
float		delta;
{
	e->date += delta;
	return;
}


/**
 **	unschedule an event
 **/

unschedule(e)
EVENT		*e;
{
	if (e->evcode < 64)
		Etc.eventptr[e->evcode] = 0;
	e->date = 1e30;	/* was 1e50: past the VAX float's 1.7e38, and the compiler stops */
	e->evcode = -1;
	return;
}
