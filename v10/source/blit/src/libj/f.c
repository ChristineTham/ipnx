#include <jerq.h>
#undef MPX

Point p = {400,512};

main()
{
	register i,j;
	Point q;
	request(KBD);
	while ((own()&KBD) == 0) {
		for (i = 0; i < 800; i += 2) {
			q.x = i;
			q.y = 0;
			Jsetline(p,q);
			_line(&display,p,q,F_XOR);
			q.y = 1023;
			Jsetline(p,q);
			_line(&display,p,q,F_XOR);
			/*
			segment(&display,p,Pt(i,0),F_XOR);
			segment(&display,p,Pt(i,1023),F_XOR);
			 */
		}
		for (i = 0; i < 1024; i += 2) {
			q.y = i;
			q.x = 0;
			Jsetline(p,q);
			_line(&display,p,q,F_XOR);
			q.x = 800;
			Jsetline(p,q);
			_line(&display,p,q,F_XOR);
			/*
			segment(&display,p,Pt(0,i),F_XOR);
			segment(&display,p,Pt(800,i),F_XOR);
			 */
		}
	}
}
