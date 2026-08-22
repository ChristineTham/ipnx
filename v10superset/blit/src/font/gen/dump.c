#include	<jerq.h>
#include	<jerqio.h>
#include	<font.h>

main()
{
	register Font *f;
	register Fontchar *i;
	register x;

	jinit();
	if((f = getfont("agh")) == (Font *)0)
	{
		printf("infont failed\n");
		exit(1);
	}
	dump(f);
	printf("%d chars in font\n", f->n+1);
	printf("height=%d, ascent=%d\n", f->height, f->ascent);
	for(x = 0; x <= f->n+1; x++)
	{
		i = &(f->info[x]);
		printf("[%d] x=%d top=%d bottom=%d left=%d width=%d\n", x,
			i->x, i->top, i->bottom, i->left, i->width);
	}
	printf("bits: wid=%d rect=(%d,%d)-(%d,%d)\n", (f->bits)->width,
		(f->bits)->rect);
	exit(0);
}

dump(w)
	Word *w;
{
	register i;

	for(i = 0; i < 18; i++)
	{
		printf("0%o ", *w++);
		if((i%8) == 7)
			printf("\n");
	}
}
