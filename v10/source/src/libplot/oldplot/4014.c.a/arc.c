#include <math.h>
#include <stdio.h>
#define DX 10
#define sqr(x) ((long int)(x)*(x))
arc(x, y, x0, y0, x1, y1)
{
	/* based on Bresenham, CACM, Feb 77, pp 102-3 */
	/* by Chris Van Wyk */
	/* capitalized vars are an internal reference frame */
	long dotcount = 0;
	int	xs, ys, xt, yt, Xs, Ys, qs, Xt, Yt, qt,
	M1x, M1y, M2x, M2y, M3x, M3y,
	Q, mymove, Xc, Yc;
	long int	delta;
	float	xc, yc;
	float	radius, slope;
	float	xstep, ystep;
	/* a circular arc; radius is computed from center and first point */
	xstep = ystep = 1;
	radius = sqrt((float)sqr(x0 - x) + sqr(y0 - y));


	xc = x0;
	yc = y0;
	/* now, use start and end point locations to figure out
   the angle at which start and end happen; use these
   angles with known radius to figure out where start
   and end should be */
	slope = atan2((double)(y0 - y), (double)(x0 - x)
	    );
	if ((slope == 0.0)
	     && (x0 < x)
	    )
		slope = 3.14159265;
	x0 = x + radius * cos(slope)
	 + 0.5;
	y0 = y + radius * sin(slope)
	 + 0.5;
	slope = atan2((double)(y1 - y), (double)(x1 - x)
	    );
	if ((slope == 0.0)
	     && (x1 < x)
	    )
		slope = 3.14159265;
	x1 = x + radius * cos(slope)
	 + 0.5;
	y1 = y + radius * sin(slope)
	 + 0.5;
	/* step 2: translate to zero-centered circle */
	xs = x0 - x;
	ys = y0 - y;
	xt = x1 - x;
	yt = y1 - y;
	/* step 3: normalize to first quadrant */
	if (xs < 0)
		if (ys < 0) {
			Xs = abs(ys);
			Ys = abs(xs);
			qs = 3;
			M1x = 0;
			M1y = -1;
			M2x = 1;
			M2y = -1;
			M3x = 1;
			M3y = 0;
		} 
		else {
			Xs = abs(xs);
			Ys = abs(ys);
			qs = 2;
			M1x = -1;
			M1y = 0;
			M2x = -1;
			M2y = -1;
			M3x = 0;
			M3y = -1;
		} 
	else if (ys < 0) {
		Xs = abs(xs);
		Ys = abs(ys);
		qs = 0;
		M1x = 1;
		M1y = 0;
		M2x = 1;
		M2y = 1;
		M3x = 0;
		M3y = 1;
	} else {
		Xs = abs(ys);
		Ys = abs(xs);
		qs = 1;
		M1x = 0;
		M1y = 1;
		M2x = -1;
		M2y = 1;
		M3x = -1;
		M3y = 0;
	}


	Xc = Xs;
	Yc = Ys;
	if (xt < 0)
		if (yt < 0) {
			Xt = abs(yt);
			Yt = abs(xt);
			qt = 3;
		} 
		else {
			Xt = abs(xt);
			Yt = abs(yt);
			qt = 2;
		} 
	else if (yt < 0) {
		Xt = abs(xt);
		Yt = abs(yt);
		qt = 0;
	} else {
		Xt = abs(yt);
		Yt = abs(xt);
		qt = 1;
	}


	/* step 4: calculate number of quadrant crossings */
	if (((4 + qt - qs)
	     % 4 == 0)
	     && (Xt <= Xs)
	     && (Yt >= Ys)
	    )
		Q = 3;
	else
		Q = (4 + qt - qs) % 4 - 1;
	/* step 5: calculate initial decision difference */
	delta = sqr(Xs + 1)
	 + sqr(Ys - 1)
	-sqr(xs)
	-sqr(ys);
	/* here begins the work of drawing
   we hope it ends here too */
	move ((int)xc, (int)yc);
	while ((Q >= 0)
	     || ((Q > -2)
	     && ((Xt > Xc)
	     && (Yt < Yc)
	    )
	    )
	    ) {
		if (dotcount++ % DX == 0) 
			cont((int)xc, (int)yc);
		if (Yc < 0.5) {
			/* reinitialize */
			Xs = Xc = 0;
			Ys = Yc = sqrt((float)(sqr(xs) + sqr(ys)));
			delta = sqr(Xs + 1) + sqr(Ys - 1) - sqr(xs) - sqr(ys);
			Q--;
			M1x = M3x;
			M1y = M3y;
			 {
				int	T;
				T = M2y;
				M2y = M2x;
				M2x = -T;
				T = M3y;
				M3y = M3x;
				M3x = -T;
			}
		} else {
			if (delta <= 0)
				if (2 * delta + 2 * Yc - 1 <= 0)
					mymove = 1;
				else
					mymove = 2;
			else if (2 * delta - 2 * Xc - 1 <= 0)
				mymove = 2;
			else
				mymove = 3;
			switch (mymove) {
			case 1:
				Xc++;
				delta += 2 * Xc + 1;
				xc += M1x * xstep;
				yc += M1y * ystep;
				break;
			case 2:
				Xc++;
				Yc--;
				delta += 2 * Xc - 2 * Yc + 2;
				xc += M2x * xstep;
				yc += M2y * ystep;
				break;
			case 3:
				Yc--;
				delta -= 2 * Yc + 1;
				xc += M3x * xstep;
				yc += M3y * ystep;
				break;
			}
		}
	}
	cont (x1, y1);


}
