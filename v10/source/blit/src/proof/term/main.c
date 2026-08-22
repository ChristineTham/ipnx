#include <jerq.h>
#include "layer.h"
#include "font.h"
#include "../comm.h"
#include "term.h"

#ifdef	MPX
#else	MPX
#undef	transform
#define transform(p)	p
#endif	MPX

struct arena arena;
Font *curfont;
extern Point fudge;
extern curpage;

main()
{
#ifdef	MPX
	P->state &= ~RESHAPED|MOVED;
#else
	Drect = inset(display.rect, 2);
#endif	MPX

	term();
}

inchar()
{
	register c;

	while((c = rcvchar()) == -1);
	return(c&0377);
}

sendn(c)
{
	send(c >> 8);
	send(c);
}

send(c)
{
	char cc = c;

	sendnchars(1, &cc);
}

static Texture vstripe =
{
	0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0,
	0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0, 0xf0f0
};

static Texture hstripe =
{
	0xffff, 0xffff, 0xffff, 0xffff, 0x0000, 0x0000, 0x0000, 0x0000,
	0xffff, 0xffff, 0xffff, 0xffff, 0x0000, 0x0000, 0x0000, 0x0000,
};

#define	SBAR	10	/* scroll bars are SBAR-2 wide */

artdeco(bars)
{
	arena.org = Drect.origin;
	if(bars)
	{
		arena.psize.x = 850;	/* 8.5 inches */
		arena.psize.y = 1100;	/* by 11 inches */
		arena.window = Drect;
		arena.window.origin.x += SBAR;
		arena.window.corner.y -= SBAR;
		arena.v = rsubp(arena.window, arena.window.origin);
		arena.vbar.origin = add(arena.window.origin, Pt(-(SBAR-1), 1));
		arena.vbar.corner.x = arena.vbar.origin.x + (SBAR-2);
		arena.vbar.corner.y = arena.window.corner.y - 1;
		arena.hbar.corner = add(arena.window.corner, Pt(-1, (SBAR-1)));
		arena.hbar.origin.x = arena.window.origin.x + 1;
		arena.hbar.origin.y = arena.window.corner.y + 1;
		calcticks();
		xor(arena.hbar);
		xor(arena.vbar);
		xor(arena.htick);
		xor(arena.vtick);
	}
	texture(&display, Rect(display.rect.origin.x, display.rect.origin.y,
		display.rect.corner.x, Drect.origin.y), &vstripe, F_XOR);
	texture(&display, Rect(display.rect.origin.x, Drect.origin.y,
		Drect.origin.x, Drect.corner.y), &hstripe, F_XOR);
	texture(&display, Rect(Drect.corner.x, Drect.origin.y,
		display.rect.corner.x, Drect.corner.y), &hstripe, F_XOR);
	texture(&display, Rect(display.rect.origin.x, Drect.corner.y,
		display.rect.corner.x, display.rect.corner.y), &vstripe, F_XOR);
}


char *b3m[] =
{
	"more",
	"goto page",
	"scale mode",
	"canonical shape",
	"quit",
	"exit",
	NULL
};
static Menu menu = { b3m };
Texture ok = {
	 0x1C44, 0x2248, 0x2250, 0x2270, 0x2248, 0x1C44, 0x0000, 0x0380,
	 0x0440, 0x0440, 0x0080, 0x0100, 0x0100, 0x0100, 0x0000, 0x0100,
};

minkbd()
{
	register w, ret;
	Texture *t;

	while(w = wait(KBD|MOUSE|RCV))
	{
		if(w&KBD)
			return(kbdchar());
		else if(w&RCV)
			return(rcvchar());
		else
		{
			if(!button123())
				continue;
			if(w = scroll(mouse.xy))
				return(w);
			if(button3())
			{
				t = cursswitch((Texture *)0);
				switch(w = menuhit(&menu, 3))
				{
				case -1:
					break;
				case 5:
					(void)cursswitch(&ok);
					while(!button123()) sleep(1);
					w = button3();
					while(button123()) sleep(1);
					(void) cursswitch((Texture *)0);
					if(w)
					{
						ret = 'x';
						goto done;
					}
					else
						continue;
				case 2:
					ret = b3m[2][0];
					goto done;
				default:
					ret = "\rpscq"[w];
					goto done;
				}
			}
			else
			{
				while(button123())
					sleep(1);
			}
		}
	}
done:
	(void)cursswitch(t);
	return(ret);
}
Texture tslice = {
	 0x7FE0, 0x4030, 0x4028, 0x5564, 0x4022, 0x413F, 0x4101, 0x47C1,
	 0x4101, 0x4101, 0x4001, 0x5555, 0x4001, 0x4001, 0x4001, 0x7FFF,
};
Texture tpage = {
	 0x7FE0, 0x4030, 0x4028, 0x4024, 0x4022, 0x413F, 0x4101, 0x47C1,
	 0x4101, 0x4101, 0x4001, 0x4001, 0x4001, 0x4001, 0x4001, 0x7FFF,
};

user(slice, page)
{
	char buf[40];
	register char *s;
	int i;
	extern curpage;
	Texture *t;

	t = cursswitch(slice? &tslice:&tpage);
again:
	i = minkbd();
	treshape();	/* most likelyspot for reshape */
	switch(i)
	{
	default:
		*((char *)(384*1024L+062)) = 2;	/* beep */
		goto again;
	case 0177:
	case 04:
	case 'q':
	quit:
		send(C_EXIT);
		return(1);
		break;
	case 'x':
		send(C_EXIT);
		bye();
		break;
	case 'a':
		if(!slice && (page == -1)) goto quit;
		break;
	case 's':
	case 'w':
		b3m[2] = i == 's'? "scale mode":"window mode";
		setshrink(i == 's');
		break;
	case 'c':
#ifdef	MPX
		resize();
#endif
		goto again;
	case 'p':
		strcpy(buf, "Page ");
		edit(buf);
		for(s = buf; *s != ' '; s++);
		while(*s == ' ') s++;
		i = 0;
		while((*s >= '0') && (*s <= '9'))
			i = 10*i + *s++ - '0';
		if(i == 0)
			if(*s == '$')
				i = -1;
		tseek(i);
		break;
	case '\r':
	case '\n':
		if(slice)
		{
			i = arena.window.corner.y - arena.window.origin.y;
			arena.v.origin.y = arena.v.corner.y;
			arena.v.corner.y = min(arena.v.origin.y+i, arena.psize.y);
			stipple(arena.window);
		}
		else
		{
			stipple(arena.window);
			arena.v.origin.y = 0;
			arena.v.corner.y = arena.v.origin.y + arena.window.corner.y
				- arena.window.origin.y;
;
			if(page == -1)
				goto quit;
		}
		doticks();
		break;
	}
	(void)cursswitch(t);
	return(0);
}

inkbd()
{
	wait(RCV|KBD);
	return((own()&KBD)? kbdchar():rcvchar());
}

edit(s)
	char *s;
{
	char buf[40];
	Point p;
	int c;
	register i;

	strcpy(buf, s);
	p = mouse.xy;
	disp(buf, p);
	for(i = strlen(buf); (c = inkbd()) != '\r';)
	{
		disp(buf, p);
		p = mouse.xy;
		switch(c)
		{
		case '\b':
			if((buf[i] != ' ') && (i > 0))
				buf[--i] = 0;
			break;
		case '@':
			while(buf[i] != ' ') i--;
			buf[++i] = 0;
			break;
		default:
			buf[i++] = c;
			buf[i] = 0;
			break;
		}
		disp(buf, p);
	}
	disp(buf, p);
	strcpy(s, buf);
}

disp(s, p)
	char *s;
	Point p;
{
	string(&defont, "\001", &display,
		string(&defont, s, &display, p, F_XOR), F_XOR);
}
