#include	<jerq.h>
#include	<jerqio.h>
#include	"f.h"
#define MAGIC	((long)scale)
#define	NVEC	16
#define	OX	100
#define	OY	100
#define BUMP	150
#undef YMAX
#define YMAX	(Drect.corner.y)
int	xorig	= OX;
int	yorig	= OY;

/*
compile with -l4014
*/

struct vtag {
	int x,y;
	char	dx,dy;
	char	s;
	struct vtag *fwd,*bwd;
} ;
struct vtag all[NVEC], *mark, *frst, *fre;
struct vtag *more(), *incvec(), *newvec(), *Kill();
struct vtag *NIL = 0;

char	pin[2000];
char	*pinlast, *pinvlast, *getin();

int	nfrst = 0;
int	inv = 0;
int	lastx = 0;
int	again = 02000;
int	erasemode = 1;
int	ptsz	= 32;
int	mag	= 1;
long	tscldx	= 0;
long	scldx	= 0;
int	denom;
int	fin	= 0;
int	fudge;		/* to not amplify Mergenthaler glitches */

Rectangle NULLRECT;

int oldy;

MOVE(x,y)
{
	if (fflag == 0) {
		MBB = pttorect(Pt(x,y));
		fflag++;
	}
	else
		MBB = mbbpt(MBB,Pt(x,y));
	x += BUMP;
/*	y += BUMP;
	jmoveto(Pt(x,YMAX-y));	*/
	oldy = YMAX-y-BUMP;
}

CONT(x,y)
{
	Rectangle r;
	if (fflag == 0) {
		MBB = pttorect(Pt(x,y));
		fflag++;
	}
	else
		MBB = mbbpt(MBB,Pt(x,y));
	x += BUMP;
	y = YMAX-y-BUMP;
/*	jlineto(Pt(x,YMAX-y),F_OR); */
	r.origin.x = x;
	r.corner.x = x+1;
	if (y >= oldy) {
		r.origin.y = oldy;
		r.corner.y = y+1;
	}
	else {
		r.origin.y = y;
		r.corner.y = oldy+1;
	}
	rectf(&display,r,F_OR);
	oldy = y;
}

cross()
{
	rectf(&display,Rect(BUMP-50,YMAX-BUMP,BUMP+50,YMAX-BUMP+1),F_OR);
	rectf(&display,Rect(BUMP,YMAX-BUMP-50,BUMP+1,YMAX-BUMP+50),F_OR);
}
int (*move)() = MOVE, (*cont)() = CONT;


showfull()
{
	register t;
	rectf(&display,MBB,F_CLR);
	move = MOVE;
	cont = CONT;
	MBB = NULLRECT;
	ptsz = 16;
	scale = 32;
	cross();
	show();
	MBB = raddp(MBB,Pt(BUMP,BUMP));
	t = YMAX-MBB.origin.y;
	MBB.origin.y = YMAX-MBB.corner.y;
	MBB.corner.y = t;
	MBB = inset(MBB,-2);
}

get202(name)
char *name;
{
	FILE *f;
	f = fopen(name,"r");
	pinvlast = getin(f);
	fclose(f);
}

show()
{
	register struct vtag *p, *pn, *pnn;
	int w,i;

	pinlast = pin;
	lastx = scldx = tscldx = 0;
	fudge = scale/(2*ptsz);
	if(fudge > 10)
		fudge = 10;
   do {

	w = *pinlast++ &0377;
	w |= *pinlast++ <<8;
	again = w &02000;
	i = (w & 04000)? -((w&0777) + 2):(w & 0777);
	lastx += i;
#ifdef FOO
	tscldx += ptsz * i * 100;
#else
	tscldx += ptsz * i;
#endif
	scldx = tscldx-fudge;
	newvec(NIL,1,2+((w>>12)&016));
	lastx = frst->x - frst->dx;;
	for(p = frst->fwd; p!=frst; p = p->fwd) {
		if((p->x - p->dx) < lastx)
			lastx = p->x - p->dx;
	}
	while(1) {
		if(p->x <= lastx) {
loop:
			w = *pinlast++ & 0377;
		
			if(w < 15) switch(w)
			{
			case 0: /* word align */
				goto loop;
		
			case 6: /*new 2 at bottom*/
			case 5: /*new 2*/
			case 4: /*new 1 at bottom*/
			case 3: /*new 1*/
				w -= 1;
				newvec(p,w&01,w&06);
				goto loop;
		
			case 14: /* ch sign */
				p->s = !p->s;
				goto loop;
		
			case 13: /* Kill 2 */
			case 12: /* Kill 1 */
				w = (w-11) * 2;
				pnn = p;
				for(i = 0; i < w; i++) {
					pn = pnn;
					if((pnn = pn->fwd) == p) {
						if(i != w-1) {
							error("Kill too large");
						}
					}
					if(pn == mark) {
						mark = pnn;
					}
					if(pn == frst) {
						frst = pnn;
						nfrst = 1;
					}
				}
				p->bwd->fwd = pnn;
				pnn->bwd = p->bwd;
				pn->fwd = fre;
				fre = p;
				p = pnn;
				break;

			case 7: /* y disp */
				w = *pinlast++ & 0377;
				w |= *pinlast++ <<8;
				p->y = (w & 01000) ? w | ~0777: w & 0777;
				p->s = w & 04000?1:0;
				p->dy = 0;
				goto loop;
		
			case 9: /* kill and restart or end */
				goto wbreak;
		
			default:
				error("unknown\n");
			}
			else {
				incvec(p,w);
				p = p->fwd;
			}
		}else{
			p = p->fwd;
		}
		if((p == frst) && (!nfrst)) {
			lastx++;
#ifdef FOO
			scldx += ptsz*100;
			while (scldx > tscldx) {
				disp();
				tscldx += MAGIC*972;
			}
#else
			scldx += ptsz;
			while(scldx > tscldx) {
				disp();
				tscldx += MAGIC;
			}
#endif
		}
		nfrst = 0;
	}
wbreak:	;
   } while(again);
}


 struct vtag *
newvec(p,mk,n)
	struct vtag *p;
{
	struct vtag *pp,*pi;
	int i,w;

	if(p == NIL) {
		p = pp = fre = frst = mark = all;
		for(i = 0; i < NVEC; i++) {
			all[i].fwd = &all[i+1];
		}
		all[NVEC-1].fwd = NIL;
	}else {
		pp = p->bwd;
	}
	for(i = 0; i < n; i++) {
		pi = fre;
		if(pi == NIL) {
			error("newvec: Out of frelist.\n");
		}
		fre = pi->fwd;
		if(i == 0 ) {
			if(mk)
				mark = pi;
			if(p == frst)
				frst = pi;
		}
		pp->fwd = pi;
		pi->bwd = pp;
		pi->fwd = p;
		p->bwd = pi;
		w = *pinlast++ &0377;
		w |= *pinlast++ <<8;
		pi->x = lastx + ((w>>12) & 017);
		pi->y = (w & 01000) ? w | ~0777: w & 0777;
		pi->s = w & 04000 ? 1 : 0;
		pi->dx = pi->dy = 0;
		if(((w>>12) & 017) == 0)
			incvec(pi,*pinlast++ & 0377);
		pp = pi;
	}
	return(p);
}

 struct vtag *
incvec(p,b)
	struct vtag *p;
{
	register struct vtag *pt;

	pt = p;
loop:
	pt->dx = (b>>4) & 017;
	pt->x += pt->dx;
	pt->dy = pt->s?-(b&017):(b&017);
	pt->y += pt->dy;
	if(b == 15) {
		b = *pinlast++ &0377;
		goto loop;
	}
	return(p);
}

disp()
{
	int	odd,outy;
	struct vtag *q;
	static TICK;

	odd = 0;
	q = mark;
	do{
		if(denom = q->dx) {	/* active */
#ifdef FOO
			outy = ptsz*q->y;
			outy += (muldiv(((lastx - q->x) * q->dy * ptsz),100,972)
				/(denom));
			outy = (outy/MAGIC) * mag;
#else
			outy = ptsz*q->y;
			outy += ((lastx - q->x) * q->dy * ptsz)/(denom);
			outy = (outy/(MAGIC)) * mag;
#endif
#ifdef FOO
			if (odd)
				(*cont)((int)(tscldx/(MAGIC*972)),outy);
			else
				(*move)((int)(tscldx/(MAGIC*972)),outy);
#else
			if(odd)
				(*cont)(muldiv((int)tscldx,mag,MAGIC),outy);
			else
				(*move)(muldiv((int)tscldx,mag,MAGIC),outy);
#endif
			odd = !odd;
		}
		if (TICK-- < 0) {
			sw(NOWAIT);
			TICK = 20;
		}
	}while((q = q->fwd) != mark);
}

 char *
getin(f)
FILE *f;
{
	int c;
	register odd;
	register char *p;
	int d;

	p = pin;
	odd = 0;
	d = 0;

loop:
	c = 0;
	if((c = getc(f)) == EOF) {
		return(p);
	}
	if(c == ' ' || c == '\n')
		goto loop;
	if(c >= '0' && c <= '9') {
		c -= '0';
	}
	else if(c >= 'a' && c <= 'f') {
		c -= 'a'-10;
	}
	else if(c >= 'A' && c <= 'F') {
		c -= 'A'-10;
	}
	else {
		error("not hex\n");
	}
	if(inv)
		c = 15-c;
	if(odd)
		*p++ = d | c;
	else
		d = c << 4;
	odd = !odd;
	goto loop;
}

error(s)
char *s;
{
	printf("%s",s);
	exit(1);
}
