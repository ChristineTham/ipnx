#include	<jerq.h>
#include	<jerqio.h>
#include	<font.h>

Font *f;
Font nf;
int x[600];

main()
{
	register z;
	extern putchar(), getchar();
	Rectangle r;

	if((f = infont(getchar)) == (Font *)0)
	{
		fprintf(stderr, "infont failed\n");
		exit(0);
	}
	nf = *f;
	nf.n = -1;
	nf.info[0].x = 0;
	nf.bits = balloc(Rect(0, 0, 3000, f->height));
	ddo(0, ' ');
	ddo(69-1, '!');
	ddo(77-1, '$');
	ddo(78-1, '%');
	ddo(53-1, '&');
	ddo(73-1, '\'');
	ddo(70-1, '(');
	ddo(71-1, ')');
	ddo(82-1, '*');
	ddo(65-1, ',');
	ddo(72-1, '-');
	ddo(64-1, '.');
	ddo(79-1, '/');
	ddo(63-1, '0');
	ddo(54-1, '1');
	ddo(55-1, '2');
	ddo(56-1, '3');
	ddo(57-1, '4');
	ddo(58-1, '5');
	ddo(59-1, '6');
	ddo(60-1, '7');
	ddo(61-1, '8');
	ddo(62-1, '9');
	ddo(66-1, ':');
	ddo(67-1, ';');
	ddo(68-1, '?');
	ddo(27-1, 'A');
	ddo(28-1, 'B');
	ddo(29-1, 'C');
	ddo(30-1, 'D');
	ddo(31-1, 'E');
	ddo(32-1, 'F');
	ddo(33-1, 'G');
	ddo(34-1, 'H');
	ddo(35-1, 'I');
	ddo(36-1, 'J');
	ddo(37-1, 'K');
	ddo(38-1, 'L');
	ddo(39-1, 'M');
	ddo(40-1, 'N');
	ddo(41-1, 'O');
	ddo(42-1, 'P');
	ddo(43-1, 'Q');
	ddo(44-1, 'R');
	ddo(45-1, 'S');
	ddo(46-1, 'T');
	ddo(47-1, 'U');
	ddo(48-1, 'V');
	ddo(49-1, 'W');
	ddo(50-1, 'X');
	ddo(51-1, 'Y');
	ddo(52-1, 'Z');
	ddo(80-1, '[');
	ddo(81-1, ']');
	ddo(74-1, '`');
	ddo(1-1, 'a');
	ddo(2-1, 'b');
	ddo(3-1, 'c');
	ddo(4-1, 'd');
	ddo(5-1, 'e');
	ddo(6-1, 'f');
	ddo(7-1, 'g');
	ddo(8-1, 'h');
	ddo(9-1, 'i');
	ddo(10-1, 'j');
	ddo(11-1, 'k');
	ddo(12-1, 'l');
	ddo(13-1, 'm');
	ddo(14-1, 'n');
	ddo(15-1, 'o');
	ddo(16-1, 'p');
	ddo(17-1, 'q');
	ddo(18-1, 'r');
	ddo(19-1, 's');
	ddo(20-1, 't');
	ddo(21-1, 'u');
	ddo(22-1, 'v');
	ddo(23-1, 'w');
	ddo(24-1, 'x');
	ddo(25-1, 'y');
	ddo(26-1, 'z');
	ddo(-1, 127);
	r.origin.x = r.origin.y = 0;
	r.corner.y = f->height;
	r.corner.x = nf.info[127].x;
	bitblt(nf.bits, r, f->bits, Pt(0,0), F_STORE);
	nf.bits->rect = r;
	if((z = r.corner.x) & ~WORDMASK)
	{
		z |= WORDMASK;
		z++;
	}
	nf.bits->width = z >> WORDSHIFT;
	bitblt(f->bits, r, nf.bits, Pt(0, 0), F_STORE);
	outfont(&nf, putchar);
	ffree(f);
	exit();
}

ddo(from, to)
{
	register Fontchar *ff, *ft;

	while(++(nf.n) != to)
	{
		ff = &(nf.info[nf.n]);
		(ff+1)->x = ff->x;
		ff->width = ff->left = ff->top = ff->bottom = 0;
	}
	if(from == -1)
	{
		nf.n--;
		return;
	}
	if(to == ' ')
	{
		ff = &(nf.info[nf.n]);
		ff->width = 12;
		ff->top = 0;
		ff->bottom = f->height;
		ff->left = 0;
		(ff+1)->x = ff->x + ff->width;
		rectf(nf.bits, Rect(ff->x, 0, (ff+1)->x, f->height), F_CLR);
		return;
	}
	ff = &(nf.info[nf.n]);
	ft = &(f->info[from]);
	ff->width = ft->width;
	ff->top = ft->top;
	ff->bottom = ft->bottom;
	ff->left = ft->left;
	(ff+1)->x = ff->x + (ft+1)->x - ft->x;
	bitblt(f->bits, Rect(ft->x, 0, (ft+1)->x, f->height), nf.bits, Pt(ff->x, 0),
		F_STORE);
	bitblt(f->bits, Rect(ft->x, 0, (ft+1)->x, f->height), &display, Drect.origin,
		F_STORE);
}
