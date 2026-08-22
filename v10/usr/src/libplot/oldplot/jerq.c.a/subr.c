extern float obotx;
extern float oboty;
extern float boty;
extern float botx;
extern float scalex;
extern float scaley;
xsc(xi, s)
	register char *s;
{
	int xa;
	xa = (xi-obotx)*scalex+botx;
	s[0]=(xa&077)+32;
	s[1]=((xa>>6)&077)+32;
}
ysc(yi, s)
	register char *s;
{
	int ya;
	ya = (yi-oboty)*scaley+boty;
	s[0]=(ya&077)+32;
	s[1]=((ya>>6)&077)+32;
}
