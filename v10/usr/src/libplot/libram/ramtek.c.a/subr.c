#include <stdio.h>
#include "ram.h"
#define pHEIGHT 512.
#define pWIDTH  512.
#define pSMALL    0.5
short buf[256];
struct penvir  E[9] = {
{ 0., pHEIGHT-1., 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT-1., 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT, 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT, 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT, 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT, 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT, 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0},
{ 0., pHEIGHT, 0., 0., 1., -1.,pWIDTH, -pHEIGHT, 0., 0., 	
pSMALL, 1., 1, 0.,1, 255, 0}
};
struct penvir *e0 = E, *e1 = &E[1], *esave;
bcolor(s) 
char	*s; 
{
	while (*s != NULL) {
		switch (*s) {
		case 'z': 
			return(ZERO);
		case 'r': 
			return(RED);
		case 'g': 
			return(GREEN);
		case 'b': 
			return(BLUE);
		case 'm': 
			return(MAGENTA);
		case 'y': 
			return(YELLOW);
		case 'c': 
			return(CYAN);
		case 'w': 
			return(WHITE);
		case 'R': 
			return(atoi(s + 1));
		case 'G': 
			e1->pgap = atof(s + 1); 
			return(-1);
		case 'A': 
			e1->pslant = (180. - atof(s + 1)) / RADIAN; 
			return(-1);
		}
		while (*++s != NULL) 
			if (*s == '/') {
				s++;
				break;
			}
	}
	return(-1);
}
sscpy(a, b) 
struct penvir *a, *b; 
{ /* copy 'a' onto 'b' */
	b->left = a->left; 
	b->bottom = a->bottom; 
	b->xmin = a->xmin; 
	b->ymin = a->ymin;
	b->scalex = a->scalex; 
	b->scaley = a->scaley;
	b->sidex = a->sidex; 
	b->sidey = a->sidey;
	b->copyx = a->copyx; 
	b->copyy = a->copyy;
	b->quantum = a->quantum;
	b->grade = a->grade;
	b->pmode = a->pmode; 
	b->foregr = a->foregr; 
	b->backgr = a->backgr;
}
idle(){}

ptype(){}
