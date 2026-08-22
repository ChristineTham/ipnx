typedef struct Fontchar
{
	short x;		/* x position of left edge */
	char top;		/* blank space above bits */
	char bottom;		/* y of bottom scan line */
	char left;
	char width;
} Fontchar;

typedef struct Font
{
	short n;		/* number of chars in font */
	short height;		/* number of rasters stored for font */
	short ascent;		/* distance from baseline to top of font */
	long unused;
	Bitmap *strike;			/* where the characters are */
	Fontchar info[130]; 		/* start of fchar array */
} Font;

typedef struct OFont
{
	short n;		/* number of chars in font */
	char height;		/* number of rasters stored for font */
	char ascent;		/* distance from baseline to top of font */
	long unused;
	Bitmap *strike;			/* where the characters are */
	Fontchar info[130]; 		/* start of fchar array */
} OFont;

#define RES	972		/* Mergenthaler resolution */

int thresh,scale,space,fontnum;
int oldy,fflag,area;
Rectangle MBB;
extern Font *font[];

int (*cont)(),(*move)();
extern Rectangle pttorect(),mbbx(),mbby(),mbbpt();
