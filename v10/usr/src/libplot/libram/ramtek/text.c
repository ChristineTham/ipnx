#include <stdio.h>
#include "ram.h"
text(s) 
char	*s; 
{
	register int	kx, ky;
	int centered, right, newline, more;
	register char *pc;
	register short *p;
	short *sp, *ct;
	char *sc, *ss;
	int n, kn;
	kx = SCX(e1->copyx);
	ky = SCY(e1->copyy);
	p = buf;
	*p++ = WT;
	*p++ = WIN;
	sp = p++;
	*(++p) = MAXX;
	*(++p) = MAXY;
	ct = ++p;
	while(1){
	pc = sc = (char *)(p+1);
	centered = right = newline = more = 0;
	for(ss=s;*ss != '\0';ss++){
		if (*ss == '\\') {
			switch (*(++ss)) {
			case 'C': 
				centered++;
				s = ss+1;
				continue;
			case 'R':
				s = ss+1;
				right++;
				continue;
			case 'L':
				s = ss+1;
				continue;
			case 'n':
				newline++;
				*(ss-1) =  '\0';
				if(*(ss+1) !=  '\0')more++;
				goto output;
			}
		}
		else if(*ss < ' ')*pc++ = ' ';
		else *pc++ = *ss;
	}
output:
	n = ss - s;
	kn = n*7;
	kx = SCX(e1->copyx);
	ky = SCY(e1->copyy);
	if(centered)kx -= kn/2 + 1;
	else if(right)kx -= kn + 1;
	*sp = kx;
	*(sp+1) = ky;
	if(n & 01){
		n++;
		*pc = ' ';
	}
	*ct = n;
	write(Rfd,buf,*p + TBASE);
	if(newline){
		ky += 9;
		e1->copyy = ( (double)(ky) - e1->bottom)/e1->scaley + e1->ymin + .5;
	}
	move(e1->copyx, e1->copyy);
	if(!more)break;
	s = ss + 1;
	}
}
