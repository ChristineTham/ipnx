# include	"trek.h"
# include	<sgtty.h>	/* its ECHO is 010, as trek's own define was */

/**
 **	get integer parameter
 **/

char		eof;

getintpar(s, n)
char	*s;
int	*n;
{
	register int		i;

	for ever {
		while ((eof|mkfault)==0 && lineended() && s) {
			printf("%s: %n", s);
			newline();
		}
		if((i=readint(n)) < 0)
			return(0);
		if(i>0)
			return(1);
		printf("? ");
		flushin();
	}
}

/**
 **	get floating parameter
 **/

getfltpar(s, f)
char	*s;
float	*f;
{
	register int		i;

	for ever {
		while ((eof|mkfault)==0 && lineended() && s) {
			printf("%s: %n", s);
			newline();
		}
		if((i=readreal(f)) < 0)
			return(0);
		if(i>0)
			return(1);
		printf("? ");
		flushin();
	}
}

/**
 **	get yes/no parameter
 **/

CVNTAB	Yntab[] =
{
	"n",	"o",
	"y",	"es",
	0
};

getynpar(s)
char	*s;
{
	return(getcodpar(s, Yntab));
}


/**
 **	get coded parameter
 **/

getcodpar(s, tab)
char	*s;
CVNTAB	tab[];
{
	char			input[100];
	register CVNTAB		*r;
	register char		*p, *q;
	int			c;

	for ever {
		while ((eof|mkfault)==0 && lineended() && s) {
			printf("%s: %n", s);
			newline();
		}
		if((c=reads(" \t\n0123456789-./;", input)) < 0)
			return(-1);
		if (c) {
			if (*input == '?') {
				for(r=tab; r->abrev; r++)
					printf("\t%s-%s\n", r->abrev, r->full);
				continue;
			}
			for (r = tab; r->abrev; r++)
			{
				p = input;
				for (q = r->abrev; *q; q++)
					if (*p++ != *q)
						break;
				if (!*q)
				{
					for (q = r->full; *p && *q; q++, p++)
						if (*p != *q)
							break;
					if (!*p || !*q)
						break;
				}
			}
		}
		if (c==0 || r->abrev==0)
		{
			printf("? ");
			flushin();
			continue;
		}
		return(r-tab);
	}
}


/**
 **	get password
 **/

getpasswd(buf)
char buf[];
{
	int s, m;
	register char c; register int ptr;
	struct sgttyb b;

	/* gtty and stty are gone from this libc -- rain fails on the same two
	 * names -- and the struct was V6's, two ints and then the mode, where
	 * this sgttyb keeps sg_flags at byte 4.  TIOCGETP is what atc uses. */
	s=signal(SIGINT,1);
	ioctl(0,TIOCGETP,&b); m=b.sg_flags; b.sg_flags &= ~ECHO; ioctl(0,TIOCSETP,&b);
	flushin();
	printf("Enter password: %n");
	
	ptr=0;
	while((c=readchar())!='\n') {
		if(ptr<PWDLEN) buf[ptr++]=c;
	}
	while(ptr<PWDLEN) buf[ptr++]=0;
	b.sg_flags = m; ioctl(0,TIOCSETP,&b);
	printf("\n");
	signal(SIGINT,s);
	flushin();
}

readsep(s)
char *s;
{
	register char rc;

	if(!(rc=any(nextchar(),s)))
		backspace();
	return(mkfault?(-1):rc);
}
