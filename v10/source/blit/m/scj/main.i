# 1 "/usr/blit/src/jim/main.c"

# 1 "/usr/blit/src/jim/r.h"

# 1 "/usr/blit/src/jim/frame/frame.h"

# 1 "/usr/blit/include/jerq.h"



typedef struct Point{
	short x;
	short y;
}Point;
typedef struct Rectangle{
	Point origin;
	Point corner;
}Rectangle;
typedef short Word;
typedef unsigned short UWord;
typedef struct Bitmap{
	Word	*base;		
	unsigned width;		
	Rectangle rect;		
	char *_null;		
}Bitmap;
typedef struct Menu{
	char **item;		
	short n;		
	short lasty;
	Bitmap *b;		
} Menu;
typedef struct Texture{
	Word bits[16];
}Texture;
typedef int Code;









extern struct Mouse{
	Point	xy,jxy;
	short	buttons;
}mouse;













extern short topbits[], botbits[];
extern Rectangle Jrect;
extern Bitmap display;








Point add(), sub(), mul(), div(), jstring(), string();
Rectangle rsubp(), raddp(), inset();
Word *addr();



char *alloc(), *gcalloc();
Bitmap *balloc();
Texture *cursswitch();










# 1 "/usr/blit/include/mpx.h"




# 1 "/usr/blit/include/layer.h"


typedef struct Obscured{
	Rectangle rect;	
	Bitmap *bmap;	
	struct Layer *lobs;	
	struct Obscured *next;	
	struct Obscured *prev;
}Obscured;

typedef struct Layer{
	
	Word *base;
	unsigned width;
	Rectangle rect;	
	struct Obscured *obs;	
	struct Layer *front;	
	struct Layer *back;	
}Layer;

Rectangle rsubp();
Layer *newlayer();
# 25 "/usr/blit/include/layer.h"


# 5 "/usr/blit/include/mpx.h"



# 1 "/usr/blit/include/jerqproc.h"

# 1 "/usr/blit/include/tty.h"





struct ttychars {
	char	flags0;		
	char	flags1;		
	char	erase;		
	char	kill;		
	char	intrc;		
	char	quitc;		
	char	startc;		
	char	stopc;		
	char	eofc;		
	char	brkc;		
};



struct ttycmesg {
	char		cmd;		
	char		chan;		
	struct ttychars	ttychars;
};







# 2 "/usr/blit/include/jerqproc.h"






struct cbuf {	
	struct	cbuf *next;
	short	word;
};
struct clist {
	struct	cbuf *c_tail;
	struct	cbuf *c_head;
	short	c_cc;
	short	state;
};


typedef struct Proc{
	long		*sp;		
	int		(*fcn)();	
	int		state;		
	Layer		*layer;		
	Rectangle 	rect;		
	struct clist	kbdqueue;	
	long		traploc;	
	short		traptype;	
	int		nticks;		
	Point		curpt;		
	Texture		*cursor;	
	short		inhibited;	
	short		nchars;		
	unsigned char	cbuf[64	*3];	
	unsigned char	*cbufpin;	
	unsigned char	*cbufpout;	
	struct ttychars ttychars;	
	char		stack[2048];	
}Proc;



# 46 "/usr/blit/include/jerqproc.h"




# 79 "/usr/blit/include/jerqproc.h"




# 8 "/usr/blit/include/mpx.h"






Bitmap *Jdisplayp;

typedef int (*ptr_fint)();












































































































# 86 "/usr/blit/include/jerq.h"
Rectangle Drect;
# 99 "/usr/blit/include/jerq.h"

# 110 "/usr/blit/include/jerq.h"

# 2 "/usr/blit/src/jim/frame/frame.h"

# 1 "/usr/blit/include/font.h"















typedef struct Fontchar
{
	short x;		
	unsigned char top;	
	unsigned char bottom;	
	char left;		
	unsigned char width;	
} Fontchar;

typedef struct Font
{
	short n;		
	char height;		
	char ascent;		
	long unused;		
	Bitmap *bits;		
	Fontchar info[1];		
} Font;



extern Font *infont();		
extern Font *getfont();		



# 44 "/usr/blit/include/font.h"


# 3 "/usr/blit/src/jim/frame/frame.h"


typedef struct String{
	char *s;	
	short n;	
	short size;	
} String;

typedef unsigned char Nchar;	
typedef struct Textframe{
	Rectangle rect;		
	Rectangle scrollrect;	
	Rectangle totalrect;	
	String 	*str;		
	int	s1, s2;		
	int	scrolly;	
	char	file;		
	char	obscured;	
	int	selecthuge;	
	int	nlines;		
	Nchar	cpl[(1024/14)	];	
} Textframe;




extern Textframe frame[20	];



String _string[(20	 + 2)];



extern Textframe *current,*newframe();
extern Rectangle canon();
extern Point nullpoint,toscreen(),ptofchar(), startline();
extern void oprectf();
extern short newlnsz;
extern Point endpoint;	
extern complete;	
extern inscomplete;	
extern F_rectf;		
extern void opnull();	
extern void opdraw();	





# 2 "/usr/blit/src/jim/r.h"

# 1 "/usr/blit/src/jim/msgs.h"












typedef struct Message{
	unsigned char	file;
	unsigned char	nbytes;
	char		op;
	short		posn;
	char		data[59	+1];	
}Message;
char *data2();























# 3 "/usr/blit/src/jim/r.h"

# 1 "/usr/blit/src/jim/menu.h"






















# 4 "/usr/blit/src/jim/r.h"
extern Rectangle diagrect;
extern int diagclr;
extern short newlnsz;
extern Textframe *current;	
extern Textframe *workframe;	
extern int diagdone;
extern int diagnewline;
extern int snarfhuge;






Textframe *frameoffile(), *pttoframe();
char *GCalloc();

Rectangle screenrect;


# 2 "/usr/blit/src/jim/main.c"
extern Message m;
Rectangle diagrect;
int diagclr;
short newlnsz;
Textframe *current;
int usualtest();
Point loadpt;	
int ntoload;	
int (*donetest)()=usualtest;	
int snarfhuge, selecthuge;



int iodone, diagdone, scrolllines, filedone;
int reqlimit, nrequested, reqposn;

main()
{
	register got;
				(*	((int (*)())((ptr_fint *)0406)[ 43]))(1|4|8|2)	;
	newlnsz=(*((Font *)((ptr_fint *)0406)[1])).height;
	init();
	zerostring((	(&_string[20	+0])));
	waitunix(&diagdone);	
	for(got=0; ; got=				(*	((int (*)())((ptr_fint *)0406)[ 53]))(4|1|8)	){
		if((*((struct Proc **)0406))->state&2048	){
					(*	((void (*)())((ptr_fint *)0406)[ 54]))(Drect, 1)	;
			closeall();
			init();
			(*((struct Proc **)0406))->state&=~2048	;
		}
		
		if((got&8) && rcv()){
			curse(current);
			(void)message();
			curse(current);
		}
		if((got&4) && 	(mouse.buttons&07)){
			curse(current);
			buttonhit(mouse.xy, mouse.buttons);
			curse(current);
		}
		if((got&1) && current)	
			type(current);	
	}
}
closeall(){
	register Textframe *t;
	for(t=frame; t<&frame[20	]; t++){
		if(t->file)
			setchar(t->file, 	1, ' ');
		closeframe(t);
		delobs(t);
	}
	current=0;
}
init(){
	diagrect=Drect;
	diagrect.origin.y=diagrect.corner.y-((*((Font *)((ptr_fint *)0406)[1])).height+2*2	)-1;
	diagclr=((Code) 2)	;
	diagrect.origin.y++;
	(void)newframe(diagrect);	
	initframe((&frame[0])	);
	curse((&frame[0])	);
	screenrect=Drect;
	screenrect.corner.y=diagrect.origin.y;
	current=0;
	workframe=0;
}

seek(t, pt, but)
	register Textframe *t;
	Point pt;
{
	Rectangle r;
	register n;
	register y=pt.y;
	if(t==(&frame[0])	)
		return;
	initframe(t);
	ontop(t);
	r=t->scrollrect;
	n=	((short)((y-r.origin.y)*((long) 1024)/( r.corner.y-r.origin.y)));
	if(n<0)
		n=0;
	if(n>1024)
		n=1024;
	send(t->file, 	10	, n, 0, (char *)0);
	loadfile(t, 0, 32767);
	setsel(t, 0);
}
tellseek(t, y)
	register Textframe *t;
{
	Rectangle r;
	t->scrolly=y;
	r=t->scrollrect;
	y=	((short)((y)*((long) r.corner.y-r.origin.y-2*2	)/( 1024)))+r.origin.y+2	;
	Rectf(r, ((Code) 1)	);
	r.origin.y=y;
	r.corner.y=y+2;
	r.origin.x++;
	r.corner.x--;
	rXOR(r);
}
usualtest()
{
	return(!inscomplete);
}
loadfile(t, posn, n)
	register Textframe *t;
	register posn;
{
	loadpt=ptofchar(t, posn);
	reqlimit=n;
	ntoload=n;
	nrequested=0;
	reqposn=posn;
	urequest(t->file);
	urequest(t->file);	
	waitunix(&iodone);
	if(n==32767){	
		reqlimit=0;
		while(				(*	((int (*)())((ptr_fint *)0406)[ 53]))(8)	){
			if(rcv()){
				message();
				break;
			}
		}
	}
}
urequest(f)
	int f;
{
	register n;
	if(nrequested <= reqlimit){
		n=min(59	, reqlimit-nrequested);
		send(f, 9	, reqposn, 2, data2(n));
		reqposn+=n;
		nrequested+=n;
	}
}
move(t, pt, but)
	register Textframe *t;
	Point pt;
{
	Rectangle r;
	register n;
	if(t==(&frame[0])	)
		return;
	selectf(t, ((Code) 3)	);
	r=t->scrollrect;
	n=	((short)((pt.y-r.origin.y-2	)*((long) t->nlines)/( r.corner.y-r.origin.y-2*2	)));
	if(n<0)
		n=0;
	if(but==	0)	
		n= -n;
	pt=ptofchar(t, t->s1);
	(void)scroll(t, n);
	setsel(t, charofpt(t, pt));
	send(t->file, 6	, t->s1, 2, data2(0));
}
Texture deadmouse = {
	 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x000C, 0x0082, 0x0441,
	 0xFFE1, 0x5FF1, 0x3FFE, 0x17F0, 0x03E0, 0x0000, 0x0000, 0x0000,
};
waitunix(flag)
	register *flag;
{
			(*	((Texture * (*)())((ptr_fint *)0406)[ 10]))(&deadmouse)	;
	*flag=0;
	while(*flag==0){
						(*	((int (*)())((ptr_fint *)0406)[ 53]))(8)	;
		if(rcv())
			message();
	}
			(*	((Texture * (*)())((ptr_fint *)0406)[ 10]))((Texture *) 0)	;
}
message()
{
	register f, n, op, posn;
	register char *data;
	static s1, s2;
	String rcvstr;
	register Textframe *t;
	register numdata;
	static maxlength=0;	
	f=m.file;
	t=frameoffile(f);
	n=m.nbytes;
	op=m.op;
	posn=m.posn;
	data=m.data;
	data[n]=0;
	numdata=((unsigned char)data[0])+(data[1]<<8);
	switch(op){
	case 0	:
		mesg(data, 0);
		break;
	case 1	:	
		if(n==0 || t==0){	
	    Done:
			iodone=1;
			break;
		}
		rcvstr.n=n;
		rcvstr.s=data;
		instext(t, &rcvstr, posn);
		ntoload-=n;
		if((*donetest)())
			goto Done;
		urequest(f);
		break;
	case 3	:
		keepsearch(posn);
		break;
	case 	10	:
		tellseek(t, posn);
		break;
	case 	13	:
		seek(t, 	(short)(0), (short)( 0), 0);
		if(t!=current)
			curse(t);
		break;
	case 6	:
		curse(t);
		s1=posn;
		s2=s1+numdata;
		break;
	case 	14	:
		if(posn==-1)	
			initframe(t);
		else
			selectf(t, ((Code) 3)	);
		if(posn<=0)	
			loadfile(t, 0, integer(data));
		
		t->s1=s1;
		t->s2=s2;
		t->selecthuge=0;
		if(s2>t->str->n){
			s2=t->str->n;
			t->selecthuge=1;
		}
		selectf(t, ((Code) 3)	);
		curse(t);
		break;
	case 11	:
		scrolllines=1;
		break;
	case 	12	:
		diagdone=1;
		break;
	case 15	:
		if(f<20	){	
			setname(f, data);
			if(n<=maxlength)
				adjustnames(maxlength);
		}
		filedone=f;
		break;
	case 19	:
		modified(t, posn);
		break;
	case 18	:
		adjustnames(maxlength=numdata);
		break;
	case 16	:
		send(0, 16	, charofpt(t, 	(short)(800), (short)( 1024)), 0, (char *)0);
		break;
	default:
		mesg("unk\n", 1);
	}
}
integer(s)
	register char *s;
{
	return (unsigned char)s[0]+(s[1]<<8);
}
int diagnewline=1;
mesg(s, sendit)
	register char *s;
{
	char buf[80+1];
	register char *p=buf, *q=s;
	String diagstr;
	register Textframe *t=(&frame[0])	;
	register i;
	if(diagnewline){	
		Rectf((&frame[0])	->rect, current==t? diagclr: ((Code) 2)	);
		zerostring(t->str);
		setsel(t, 0);
	}
	diagnewline=0;
	while(*p= *q++)
		p++;
	if(sendit)
		sendstr((&frame[0])	, 1	, t->s1, p-buf, s);
	if(p>&buf[0] && p[-1]=='\n'){
		diagnewline=1;
		*--p=0;
	}
	diagstr.n=i=p-buf;
	diagstr.s=buf;
	instext(t, &diagstr, t->s1);
	setsel(t, t->s1+i);
	if(p>&buf[0] && sendit==0){
		rXOR((&frame[0])	->rect);
				(*	((void (*)())((ptr_fint *)0406)[ 32]))(10)		;
		rXOR((&frame[0])	->rect);
	}
}










sendstr(f, op, posn, n, d)
	Textframe *f;
	register n;
	register char *d;
{
	register unsigned m;
	do{
		if((m=n)>59	)
			m=59	;
		send(f->file, op, posn, m, d);
		posn+=m;
		d+=m;
		n-=m;
	}while(n > 0);
}
scrolltest()
{
	return(ntoload<=0);
}
scroll(t, nlines)
	register Textframe *t;
	register nlines;
{
	register nchars;
	if(nlines==0 || t==(&frame[0])	)
		return 0;
	send(t->file, 11	, nlines, 0, (char *)0);
	waitunix(&scrolllines);
	nchars=m.posn;
	if(nchars>0){	
		t->s1=0;
		if(nchars>t->str->n)
			t->s2=t->str->n;
		else
			t->s2=nchars;
		t->selecthuge=0;
		deltext(t, ((Code) 2)	);
	}else{	
		setsel(t, 0);
		donetest=scrolltest;
		loadfile(t, 0, -nchars);
		donetest=usualtest;
	}
	return nchars;
}
char *
data2(n){
	static char x[2];
	x[0]=n;
	x[1]=n>>8;
	return x;
}
Send(op, posn, n, s)
	register op;
	register posn;
	register n;
	register char *s;
{
	send(current->file, op, posn, n, s);
}
