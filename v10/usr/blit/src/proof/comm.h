/*
	host <-> terminal protocol
*/

#define REQ	ACK	/* host->term; asks for a NAK \n if you are proof */
#define NAK	025	/* term->host; yes I am proof; goes into troff mode */
#define ACK	017
#define EOT	0	/* end of text */
#define	PACKET	128
#define	SHORT	65336

/*
	host -> terminal
*/
#define	C_HOR	128	/* 128-227 right horizontal shifts */
#define	C_PAGE	228	/* N; here comes page N */
#define C_FONT	229	/* set font to c-C_FONT (=0-10) */
#define C_BSIZE	240	/* B; set point size to B */
#define C_ABSH	241	/* N; move horiz absolute */
#define C_ABSV	242	/* N; move ver absolute */
#define	C_DEV	243	/* STR; send devcntrl (only res, font) */
#define		RES	1	/* n */
#define		FONT	2	/* n,str  mount font */
#define	C_DRAW	244	/* STR; wholde draw string */
#define		LINE	1
#define		CIRCLE	2	/* center, radius */
#define		ELLIPSE	3	/* center, major, minor */
#define		ARC	4	/* p1, p2, p3 */
#define		SPLINE	5	/* n, n points */
#define	C_EXIT	245	/* go away for ever */
#define	C_SCALE	246
#define	C_WINDOW	247
#define C_SIZE	248
#define C_MAX	255	/* set point size to c-C_SIZE+SIZE_ORIG */

#define	SIZE_ORIG	6

/*
	terminal -> host
*/
#define	C_PROBE	1	/* STR; return exists(str)? ACK:NAK */
#define	C_FETCH	2	/* STR; send down font str */
#define	C_SEEK	3	/* N; seek to page N */

#define	DEBUG		/* define this for debugging */

#ifdef	HOST
#ifdef	DEBUG
extern FILE *debug;
extern int verbose;
#endif	DEBUG
#endif	HOST
