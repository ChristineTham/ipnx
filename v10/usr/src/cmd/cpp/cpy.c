
# line 2 "cpy.y"
/*#ident	"@(#)cpp:common/cpy.y	1.5"*/

# line 5 "cpy.y"
# define number 257
# define stop 258
# define DEFINED 259
# define EQ 260
# define NE 261
# define LE 262
# define GE 263
# define LS 264
# define RS 265
# define ANDAND 266
# define OROR 267
# define UMINUS 268
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 98 "cpy.y"

extern short  yyexca[];
# define YYNPROD 30
# define YYLAST 363
extern short  yyact[];
extern short  yypact[];
extern short  yypgo[];
extern short  yyr1[];
extern short  yyr2[];
extern short  yychk[];
extern short  yydef[];
# ifdef YYDEBUG
# include "y.debug"
# endif

# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)

/*	parser for yacc output	*/

#ifdef YYDEBUG
int yydebug = 0; /* 1 for debugging */
#endif
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */

yyparse()
{	short yys[YYMAXDEPTH];
	int yyj, yym;
	register YYSTYPE *yypvt;
	register int yystate, yyn;
	register short *yyps;
	register YYSTYPE *yypv;
	register short *yyxi;

	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];

yystack:    /* put a state and value onto the stack */
#ifdef YYDEBUG
	if(yydebug >= 3)
		if(yychar < 0 || yytoknames[yychar] == 0)
			printf("char %d in %s", yychar, yystates[yystate]);
		else
			printf("%s in %s", yytoknames[yychar], yystates[yystate]);
#endif
	if( ++yyps >= &yys[YYMAXDEPTH] ) { 
		yyerror( "yacc stack overflow" ); 
		return(1); 
	}
	*yyps = yystate;
	++yypv;
	*yypv = yyval;
yynewstate:
	yyn = yypact[yystate];
	if(yyn <= YYFLAG) goto yydefault; /* simple state */
	if(yychar<0) {
		yychar = yylex();
#ifdef YYDEBUG
		if(yydebug >= 2) {
			if(yychar <= 0)
				printf("lex EOF\n");
			else if(yytoknames[yychar])
				printf("lex %s\n", yytoknames[yychar]);
			else
				printf("lex (%c)\n", yychar);
		}
#endif
		if(yychar < 0)
			yychar = 0;
	}
	if((yyn += yychar) < 0 || yyn >= YYLAST)
		goto yydefault;
	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
	}
yydefault:
	/* default state action */
	if( (yyn=yydef[yystate]) == -2 ) {
		if(yychar < 0) {
			yychar = yylex();
#ifdef YYDEBUG
			if(yydebug >= 2)
				if(yychar < 0)
					printf("lex EOF\n");
				else
					printf("lex %s\n", yytoknames[yychar]);
#endif
			if(yychar < 0)
				yychar = 0;
		}
		/* look through exception table */
		for(yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate);
			yyxi += 2 ) ; /* VOID */
		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
		}
		if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
	}
	if( yyn == 0 ){ /* error */
		/* error ... attempt to resume parsing */
		switch( yyerrflag ){
		case 0:   /* brand new error */
#ifdef YYDEBUG
			yyerror("syntax error\n%s", yystates[yystate]);
			if(yytoknames[yychar])
				yyerror("saw %s\n", yytoknames[yychar]);
			else if(yychar >= ' ' && yychar < '\177')
				yyerror("saw `%c'\n", yychar);
			else if(yychar == 0)
				yyerror("saw EOF\n");
			else
				yyerror("saw char 0%o\n", yychar);
#else
			yyerror( "syntax error" );
#endif
yyerrlab:
			++yynerrs;
		case 1:
		case 2: /* incompletely recovered error ... try again */
			yyerrflag = 3;
			/* find a state where "error" is a legal shift action */
			while ( yyps >= yys ) {
				yyn = yypact[*yyps] + YYERRCODE;
				if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
					yystate = yyact[yyn];  /* simulate a shift of "error" */
					goto yystack;
				}
				yyn = yypact[*yyps];
				/* the current yyps has no shift onn "error", pop stack */
#ifdef YYDEBUG
				if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
#endif
				--yyps;
				--yypv;
			}
			/* there is no state on the stack with an error shift ... abort */
yyabort:
			return(1);
		case 3:  /* no shift yet; clobber input char */
#ifdef YYDEBUG
			if( yydebug ) {
				printf("error recovery discards ");
				if(yytoknames[yychar])
					printf("%s\n", yytoknames[yychar]);
				else if(yychar >= ' ' && yychar < '\177')
					printf("`%c'\n", yychar);
				else if(yychar == 0)
					printf("EOF\n");
				else
					printf("char 0%o\n", yychar);
			}
#endif
			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */
		}
	}
	/* reduction by production yyn */
#ifdef YYDEBUG
	if(yydebug) {	char *s;
		printf("reduce %d in:\n\t", yyn);
		for(s = yystates[yystate]; *s; s++) {
			putchar(*s);
			if(*s == '\n' && *(s+1))
				putchar('\t');
		}
	}
#endif
	yyps -= yyr2[yyn];
	yypvt = yypv;
	yypv -= yyr2[yyn];
	yyval = yypv[1];
	yym=yyn;
	/* consult goto table to find next state */
	yyn = yyr1[yyn];
	yyj = yypgo[yyn] + *yyps + 1;
	if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn ) yystate = yyact[yypgo[yyn]];
	switch(yym){
		
case 1:
# line 24 "cpy.y"
{return(yypvt[-1]);} break;
case 2:
# line 28 "cpy.y"
{yyval = yypvt[-2] * yypvt[-0];} break;
case 3:
# line 30 "cpy.y"
{
			if (yypvt[-0] == 0) {
				ppwarn("division by zero");
				yyval = 0;
			}
			else
				yyval = yypvt[-2] / yypvt[-0];
		} break;
case 4:
# line 39 "cpy.y"
{
			if (yypvt[-0] == 0) {
				ppwarn("remainder by zero");
				yyval = 0;
			}
			else
				yyval = yypvt[-2] % yypvt[-0];
		} break;
case 5:
# line 48 "cpy.y"
{yyval = yypvt[-2] + yypvt[-0];} break;
case 6:
# line 50 "cpy.y"
{yyval = yypvt[-2] - yypvt[-0];} break;
case 7:
# line 52 "cpy.y"
{yyval = yypvt[-2] << yypvt[-0];} break;
case 8:
# line 54 "cpy.y"
{yyval = yypvt[-2] >> yypvt[-0];} break;
case 9:
# line 56 "cpy.y"
{yyval = yypvt[-2] < yypvt[-0];} break;
case 10:
# line 58 "cpy.y"
{yyval = yypvt[-2] > yypvt[-0];} break;
case 11:
# line 60 "cpy.y"
{yyval = yypvt[-2] <= yypvt[-0];} break;
case 12:
# line 62 "cpy.y"
{yyval = yypvt[-2] >= yypvt[-0];} break;
case 13:
# line 64 "cpy.y"
{yyval = yypvt[-2] == yypvt[-0];} break;
case 14:
# line 66 "cpy.y"
{yyval = yypvt[-2] != yypvt[-0];} break;
case 15:
# line 68 "cpy.y"
{yyval = yypvt[-2] & yypvt[-0];} break;
case 16:
# line 70 "cpy.y"
{yyval = yypvt[-2] ^ yypvt[-0];} break;
case 17:
# line 72 "cpy.y"
{yyval = yypvt[-2] | yypvt[-0];} break;
case 18:
# line 74 "cpy.y"
{yyval = yypvt[-2] && yypvt[-0];} break;
case 19:
# line 76 "cpy.y"
{yyval = yypvt[-2] || yypvt[-0];} break;
case 20:
# line 78 "cpy.y"
{yyval = yypvt[-4] ? yypvt[-2] : yypvt[-0];} break;
case 21:
# line 80 "cpy.y"
{yyval = yypvt[-0];} break;
case 22:
# line 82 "cpy.y"
{yyval = yypvt[-0];} break;
case 23:
# line 85 "cpy.y"
{yyval = -yypvt[-0];} break;
case 24:
# line 87 "cpy.y"
{yyval = !yypvt[-0];} break;
case 25:
# line 89 "cpy.y"
{yyval = ~yypvt[-0];} break;
case 26:
# line 91 "cpy.y"
{yyval = yypvt[-1];} break;
case 27:
# line 93 "cpy.y"
{yyval= yypvt[-1];} break;
case 28:
# line 95 "cpy.y"
{yyval = yypvt[-0];} break;
case 29:
# line 97 "cpy.y"
{yyval= yypvt[-0];} break;
	}
	goto yystack;  /* stack new state and value */
}
