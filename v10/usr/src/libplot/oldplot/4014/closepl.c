#include <stdio.h>
extern float obotx;
extern float oboty;
extern float scalex;
extern float sidex;
closepl(){
	move((int)(obotx+sidex/scalex+.5), (int)oboty);
	putch(037);
	fflush(stdout);
}
