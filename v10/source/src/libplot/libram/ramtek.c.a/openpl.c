#include <stdio.h>
#include "ram.h"
#define red 07400
#define green 0360
#define blue 017
openpl()
{
	Rfd = open(RAMTEK,2);
	if(Rfd < 0){
		fprintf(stderr,"Can't open ramtek\n");
		exit(1);
	}
	cmap(red, green, blue);
	move(0., 0.);
}
cmap(c1, c2, c3)
{
	register short *p;
	register int i;
	p=buf;
	*p++ = LAM;
	*p++ = 0;
	*p++ = 1024;
	for(i=0;i<512;i++,p++){
		*p = 0;
		if(i&01)*p |= c1;
		if(i&02)*p |= c2;
		if(i&04)*p |= c3;
	}
	write(Rfd, buf, 1024+6);
	p=buf;
	*(++p) = 1023;
	*(++p) = 2;
	*(++p) = 0;
	write(Rfd, buf, 8);
}
