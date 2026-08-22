struct arena
{
	Point psize;
	Point org;			/* old origin (for moving) */
	Rectangle v;			/* congruent to window on virtual page */
	Rectangle window;
	Rectangle vbar, vtick;
	Rectangle hbar, htick;
};
extern struct arena arena;

#define	NFONTS	50
