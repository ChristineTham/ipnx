static	char *sccsid = "@(#)rec.c	1.1 (Berkeley) 3/2/81";
/* Copyright (c) 1979 Regents of the University of California */
#
/*
 * pxp - Pascal execution profiler
 *
 * Bill Joy UCB
 * Version 1.2 January 1979
 */

#include "0.h"

tyrec(r, p0)
	int *r, p0;
{

	if (r != NIL)
		setinfo(r[1]);
	if (p0 == NIL) {
		ppgoin(DECL);
		ppnl();
		indent();
		ppkw("record");
		ppspac();
	} else {
		ppspac();
		ppbra("(");
	}
	ppgoin(DECL);
	if (r) {
		field(r[2], r[3]);
		variant(r[3]);
	}
	if (r != NIL)
		setinfo(r[1]);
	putcml();
	ppgoout(DECL);
	if (p0 == NIL) {
		ppnl();
		indent();
		ppkw("end");
		ppgoout(DECL);
	} else {
		ppitem();
		ppket(")");
	}
}

field(r, v)
	int *r, *v;
{
	register int *fp, *tp, *ip;

	fp = r;
	if (fp != NIL)
		for (;;) {
			tp = (int *)fp[1];
			if (tp != NIL) {
				setline(tp[1]);
				ip = (int *)tp[2];
				ppitem();
				if (ip != NIL)
					for (;;) {
						ppid(ip[1]);
						ip = (int *)ip[2];
						if (ip == NIL)
							break;
						ppsep(", ");
					}
				else
					ppid("{field id list}");
				ppsep(":");
				gtype(tp[3]);
				setinfo(tp[1]);
				putcm();
			}
			fp = (int *)fp[2];
			if (fp == NIL)
				break;
			ppsep(";");
		}
	if (v != NIL && r != NIL)
		ppsep(";");
}

variant(r)
	register int *r;
{
	register int *v, *vc;

	if (r == NIL)
		return;
	setline(r[1]);
	ppitem();
	ppkw("case");
	v = (int *)r[2];
	if (v != NIL) {
		ppspac();
		ppid(v);
		ppsep(":");
	}
	gtype(r[3]);
	ppspac();
	ppkw("of");
	for (vc = (int *)r[4]; vc != NIL;) {
		v = (int *)vc[1];
		if (v == NIL)
			continue;
		ppgoin(DECL);
		setline(v[1]);
		ppnl();
		indent();
		ppbra(NIL);
		v = (int *)v[2];
		if (v != NIL) {
			for (;;) {
				gconst(v[1]);
				v = (int *)v[2];
				if (v == NIL)
					break;
				ppsep(", ");
			}
		} else
			ppid("{case label list}");
		ppket(":");
		v = (int *)vc[1];
		tyrec(v[3], 1);
		setinfo(v[1]);
		putcml();
		ppgoout(DECL);
		vc = (int *)vc[2];
		if (vc == NIL)
			break;
		ppsep(";");
	}
	setinfo(r[1]);
	putcm();
}
