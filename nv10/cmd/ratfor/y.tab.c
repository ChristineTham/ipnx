
# line 2 "r.g"
extern int transfer;
extern	int	indent;
extern	int	f77;
# define IF 257
# define ELSE 258
# define FOR 259
# define WHILE 260
# define BREAK 261
# define NEXT 262
# define DIGITS 263
# define DO 264
# define GOK 265
# define DEFINE 266
# define INCLUDE 267
# define REPEAT 268
# define UNTIL 269
# define RETURN 270
# define SWITCH 271
# define CASE 272
# define DEFAULT 273
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

# line 67 "r.g"

short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 46,
	272, 27,
	273, 27,
	125, 27,
	-2, 0,
-1, 49,
	125, 25,
	-2, 0,
	};
# define YYNPROD 36
# define YYLAST 229
short yyact[]={

  14,  32,  45,  32,  47,  40,  41,  39,   1,  30,
   2,  31,  44,  42,  26,  27,  14,  33,  34,  35,
  29,  19,  36,  16,  37,  11,   8,  38,   7,   6,
  28,   5,   4,   3,   0,   0,   0,   0,   0,  43,
  46,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,  49,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,  15,   0,  48,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  15,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  17,  18,   0,
  21,  20,   9,  10,  24,  23,  12,   0,   0,  22,
   0,  13,  25,  17,  18,   0,  21,  20,   9,  10,
  24,  23,  12,   0,   0,  22,   0,  13,  25 };
short yypact[]={

-1000, -43,-1000, -43, -43,-269, -43, -43, -43,-1000,
-1000, -43,-1000,-1000,-1000,-1000, -43,-1000,-1000,-116,
-1000,-1000,-1000,-1000,-1000,-1000,-253,-1000,-119,-271,
-1000,-1000,-1000,-1000,-1000,-265,-1000, -59,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000, -43,-1000,-1000, -43 };
short yypgo[]={

   0,   8,  10,  33,  32,  31,  30,  29,  28,  26,
  25,  23,  21,  20,  13,   9,  12,  11 };
short yyr1[]={

   0,   1,   1,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   5,
  12,   6,   6,  13,  13,  14,  16,  15,  17,  11,
   3,   4,   7,   8,   9,  10 };
short yyr2[]={

   0,   2,   0,   2,   2,   3,   2,   2,   3,   2,
   1,   1,   2,   1,   1,   1,   3,   2,   1,   2,
   1,   1,   2,   1,   2,   2,   1,   2,   1,   1,
   1,   3,   1,   1,   1,   1 };
short yychk[]={

-1000,  -1,  -2,  -3,  -4,  -5,  -7,  -8,  -9, 261,
 262, -10, 265, 270,  59, 123, -11, 256, 257, -12,
 260, 259, 268, 264, 263, 271,  -2,  -2,  -6, -13,
 -15, -17, 272,  -2,  -2,  -2,  -2,  -1,  -2, 123,
 258, 125, -14, -15, -16, 273,  -1, 269, 125,  -1 };
short yydef[]={

   2,  -2,   1,   0,   0,   0,   0,   0,   0,  10,
  11,   0,  13,  14,  15,   2,   0,  18,  30,   0,
  32,  33,  34,  35,  29,  20,   3,   4,   0,  21,
  23,   2,  28,   6,   7,   9,  12,   0,  17,  19,
  31,   5,  22,  24,   2,  26,  -2,   8,  16,  -2 };
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
		
case 3:
# line 18 "r.g"
{ indent--; if (f77) endif(); else outcont(yypvt[-1]); } break;
case 4:
# line 19 "r.g"
{ indent--; if (f77) endif(); else outcont(yypvt[-1]+1); } break;
case 5:
# line 20 "r.g"
{ endsw(yypvt[-2], yypvt[-1]); } break;
case 6:
# line 21 "r.g"
{ whilestat(yypvt[-1]); } break;
case 7:
# line 22 "r.g"
{ forstat(yypvt[-1]); } break;
case 8:
# line 23 "r.g"
{ untils(yypvt[-2],1); } break;
case 9:
# line 24 "r.g"
{ untils(yypvt[-1],0); } break;
case 10:
# line 25 "r.g"
{ breakcode(); } break;
case 11:
# line 26 "r.g"
{ nextcode(); } break;
case 12:
# line 27 "r.g"
{ dostat(yypvt[-1]); } break;
case 13:
# line 28 "r.g"
{ gokcode(yypvt[-0]); } break;
case 14:
# line 29 "r.g"
{ retcode(); } break;
case 18:
# line 33 "r.g"
{ errcode(); yyclearin; } break;
case 20:
# line 37 "r.g"
{ swcode(); } break;
case 21:
# line 39 "r.g"
{ yyval = 0; } break;
case 22:
# line 40 "r.g"
{ yyval = 1; } break;
case 26:
# line 47 "r.g"
{ getdefault(); } break;
case 28:
# line 51 "r.g"
{ getcase(); } break;
case 29:
# line 53 "r.g"
{ transfer = 0; outcode(yypvt[-0]); } break;
case 30:
# line 55 "r.g"
{ ifcode(); } break;
case 31:
# line 57 "r.g"
{ elsecode(yypvt[-2]); } break;
case 32:
# line 59 "r.g"
{ whilecode(); } break;
case 33:
# line 61 "r.g"
{ forcode(); } break;
case 34:
# line 63 "r.g"
{ repcode(); } break;
case 35:
# line 65 "r.g"
{ docode(); } break;
	}
	goto yystack;  /* stack new state and value */
}
