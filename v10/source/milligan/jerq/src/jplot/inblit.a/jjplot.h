#define void int
#define ckreshape()	(P->state&(RESHAPED|MOVED))
#define MORE 0
#define QUIT 1
struct seg {
	Point j1, j2;
	char stat;
};
extern struct seg mLine[];
extern Texture t, cherries;
extern int fmode;
extern int lineth, delta, cwidth, tab;
extern Point PtCurrent, getpt();
extern Menu menu;
extern Rectangle arect;
