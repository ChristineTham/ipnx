extern float botx;
extern float boty;
extern float obotx;
extern float oboty;
extern float scalex;
extern float scaley;
extern float sidex;
extern float sidey;
extern int scaleflag;
space(x0,y0,x1,y1){
	botx = 0.;
	boty = 0.;
	obotx = x0;
	oboty = y0;
	if(scaleflag)
		return;
	scalex = sidex/(x1-x0);
	scaley = sidey/(y1-y0);
}
