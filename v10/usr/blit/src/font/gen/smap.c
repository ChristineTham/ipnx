#ifndef	JERQFONT
#define	JERQFONT	"/usr/jerq/font"
#endif	JERQFONT

char tab[] = "X!=\001**\002*C\003*D\004*F\005*G\006*H\007*L\010*P\011*Q\012\
*S\013*W\014*a\015*b\016*c\017*d\020*e\021*f\022*g\023*h\024\
*i\025*k\026*l\027*m\030*n\031*o\032*p\033*q\034*r\035*s\036\
*t\037*u\040*w\041*x\042*y\043*z\044+-\045->\046..\04712\050\
14\05134\052<-\053<=\054==\055>=\056L.\057L1\060Sl\061\\-\062\
\\_\063aa\064al\065ap\066b9\067br\070bs\071bu\072bv\073bx\074\
ca\075cd\076ci\077co\100ct\101cu\102da\103dd\104de\105di\106\
eq\107es\110fa\111fe\112fm\113ga\114gr\115hc\116ib\117if\120\
ip\121is\122l.\123lb\124lc\125lf\126lh\127lk\130lt\131ma\132\
mi\133mo\134mu\135no\136ob\137or\140pd\141pl\142pp\143pt\144\
rb\145rc\146rf\147rg\150rh\151rk\152rn\153rt\154ru\155sb\156\
sl\157sp\160sq\161sr\162te\163tm\164tp\165ts\166ua\167ul\170\
vr\171~=\172~~\173";

main()
{
	int fd;
	char *f;
	char buf[256];

	tab[0] =  strlen(tab)/3;
	sprintf(buf, "%s/SMAP", JERQFONT);
	if((fd = creat(f = buf, 0664)) == -1)
	{
		perror(f);
		exit(1);
	}
	write(fd, tab, sizeof tab);
}
