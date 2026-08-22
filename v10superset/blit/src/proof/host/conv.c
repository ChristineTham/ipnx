/*
output language from troff:
all numbers are character strings

sn	size in points
fn	font as number from 1-n
cx	ascii character x
Cxyz	funny char xyz. terminated by white space
Hn	go to absolute horizontal position n
Vn	go to absolute vertical position n (down is positive)
hn	go n units horizontally (relative)
vn	ditto vertically
nnc	move right nn, then print c (exactly 2 digits!)
		(this wart is an optimization that shrinks output file size
		 about 35% and run-time about 15% while preserving ascii-ness)
Dt ...\n	draw operation 't':
	Dl x y		line from here by x,y
	Dc d		circle of diameter d with left side here
	De x y		ellipse of axes x,y with left side here
	Da cx cy ex ey	arc counter-clockwise; cx,cy to center, then ex,ey to end point
	D~ x y x y ...	wiggly line by x,y then x,y ...
nb a	end of line (information only -- no action needed)
w	paddable word space -- no action needed
	b = space before line, a = after
p	new page begins -- set v to 0
#...\n	comment
x ...\n	device control functions:
	x i	init
	x T s	name of device is s
	x r n h v	resolution is n/inch
		h = min horizontal motion, v = min vert
	x p	pause (can restart)
	x s	stop -- done for ever
	x t	generate trailer
	x f n s	font position n contains font s
	x H n	set character height to n
	x S n	set slant to N

	Subcommands like "i" are often spelled out like "init".
*/

#include	"host.h"

readhunk()
{
	register int c, k;
	int m, n, i, n1, m1;
	char str[100], buf[300];

	while(gonow == 0)
	{
		switch(c = getchar())
		{
		case EOF:
			eof = 1;
			return;
		case '\n':	/* when input is text */
		case ' ':
		case 0:		/* occasional noise creeps in */
			break;
		case '0': case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			/* two motion digits plus a character */
			hpos += (c-'0')*10 + getchar()-'0';
			buf[0] = getchar();
			buf[1] = 0;
			dochar(buf);
			break;
		case 'c':	/* single ascii character */
			buf[0] = getchar();
			buf[1] = 0;
			dochar(buf);
			break;
		case 'C':
			getstr(str);
			dochar(str);
			break;
		case 't':	/* straight text */
			eatline();
			break;
		case 'D':	/* draw function */
			xygoto();
			outc(C_DRAW);
			switch(getchar())
			{
			case 'l':	/* draw a line */
				outc(LINE);
				outn(n = getn());
				outn(m = getn());
				hpos += n;
				vpos += m;
				break;
			case 'c':	/* circle */
				outc(CIRCLE);
				outn(getn());
				break;
			case 'e':	/* ellipse */
				outc(ELLIPSE);
				outn(getn());
				outn(getn());
				break;
			case 'a':	/* arc */
				outc(ARC);
				outn(n = getn());
				outn(m = getn());
				hpos += n;
				vpos += m;
				outn(n = getn());
				outn(m = getn());
				hpos += n;
				vpos += m;
				break;
			case '~':	/* wiggly line */
				wiggly();
				break;
			default:
				break;
			}
			eatline();
			break;
		case 's':
			n = getn();	/* ignore fractional sizes */
			if(cursize == n)
				break;
			cursize = n;
			if((n >= SIZE_ORIG) && (n <= (C_MAX-C_SIZE+SIZE_ORIG)))
				outc(C_SIZE+n-SIZE_ORIG);
			else
			{
				outc(C_BSIZE);
				outc(n);
			}
			break;
		case 'f':
			curfont = getn();
			break;
		case 'H':	/* absolute horizontal motion */
			hpos = getn();
			break;
		case 'h':	/* relative horizontal motion */
			hpos += getn();
			break;
		case 'w':	/* word space */
			break;
		case 'V':
			vpos = getn();
			break;
		case 'v':
			vpos += getn();
			break;
		case 'p':	/* new page */
			outc(C_PAGE);
			outn(n = getn());
			pageset(lastpageseen);
			lastpageseen = n;
			/* set font and point size */
			return;
		case '#':	/* comment */
		case 'n':	/* end of line */
			eatline();
			break;
		case 'x':	/* device control */
			devcntrl();
			break;
		default:
			error(!FATAL, "unknown input character %o %c\n", c, c);
			done();
		}
	}
}

wiggly()
{
	int pts[200], i, n, c;

	for(pts[i = 0] = getn(); (c = getchar()) != '\n'; i++)
	{
		ungetc(c, stdin);
		pts[i] = getn();
	}
	outc(SPLINE);
	outc(i);
	for(n = 0; n != i; n++)
		outn(pts[n]);
}

devcntrl()	/* interpret device control functions */
{
        char str[20], str1[50], buf[50];
	int c, n;

	getstr(str);
	switch (str[0]) {	/* crude for now */
	case 'i':	/* initialize */
		break;
	case 'T':	/* device name */
		getstr(devname);
		break;
	case 't':	/* trailer */
		break;
	case 'p':	/* pause -- can restart */
		break;
	case 's':	/* stop */
		break;
	case 'r':	/* resolution assumed when prepared */
		outc(C_DEV);
		outc(RES);
		outn(res = getn());
		break;
	case 'f':	/* font used */
		outc(C_DEV);
		outc(FONT);
		outc(n = getn());
		getstr(str);
		outs(str);
		loadfont(n, str);
		break;
	/* these don't belong here... */
	case 'H':	/* char height */
		break;
	case 'S':	/* slant */
		break;
	}
	eatline();
}

error(f, s, a1, a2, a3, a4, a5, a6, a7) {
	fprintf(stderr, "d202: ");
	fprintf(stderr, s, a1, a2, a3, a4, a5, a6, a7);
	fprintf(stderr, "\n");
	if (f)
		done();
}
