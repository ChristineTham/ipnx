#define SCX(A) ((A - e1->xmin)*e1->scalex  + e1->left)+.5
#define SCY(A) ((A - e1->ymin)*e1->scaley + e1->bottom)+.5
#define unorm(y)	(double)(e1->sidey - y)
extern struct penvir {
	double left, bottom;
	double xmin, ymin;
	double scalex, scaley;
	double sidex, sidey;
	double copyx, copyy;
	double quantum;
	double grade;
	int pgap;
	double pslant;
	int pmode, foregr, backgr;
} *e0, *e1, *esave;
#define RADIAN 57.3
#define ZERO 0
#define RED 1
#define GREEN 2
#define YELLOW 3
#define BLUE 4
#define MAGENTA 5
#define CYAN 6
#define WHITE 7
double atof();
#define FORE  02
#define FOREARG 6
#define STRT	0100000
#define STRTARG 8
#define BACK 04
#define BACKARG 6
#define RESET 02400
#define SET 04002
#define WT	06013
#define WV	07001
#define WIN	0100
#define MAXX	619
#define MAXY	511
#define VOUT 8
#define TBASE 14
#define FILL 04402
#define FILL2 0104
#define LAM 01400
#define FOUT 14
#define RAMTEK "/dev/ramtek"
int Rfd;
extern short buf[];
struct seg {
	int x, y, X, Y;
	char stat;
};
