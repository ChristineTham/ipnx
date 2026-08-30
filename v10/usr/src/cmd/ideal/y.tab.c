
# line 2 "idyac.y"
#include "ideal.h"

extern BOXPTR boxlist;

yyerror (message)
char *message;
{
	fprintf (stderr, "ideal: ");
	fprintf (stderr, "%s ", message);
	fprintf (stderr, "near line %d in file %s\n",
		lineno,
		filename
	);
}
# define BOX 257
# define VAR 258
# define BDLIST 259
# define PUT 260
# define CONN 261
# define TO 262
# define USING 263
# define CONSTRUCT 264
# define DRAW 265
# define OPAQUE 266
# define LEFT 267
# define CENTER 268
# define RIGHT 269
# define AT 270
# define NAME 271
# define CONST 272
# define STRING 273
# define LINE 274
# define CIRCLE 275
# define ARC 276
# define SPLINE 277
# define PATH 278
# define INTERIOR 279
# define EXTERIOR 280
# define LBRACE 281
# define RBRACE 282
# define ELEWISE 283
# define UMINUS 284
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
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 66
# define YYLAST 263
short yyact[]={

  42,  78,  79,  42,   9,  38,  83, 101,  38,  81,
  80,   6, 114, 105,  77,   5,  69,  60, 111,  23,
  42,  65,  63,  42,  64,  38,  66,  96,  38,   6,
 109, 108,  82,  43, 107, 106, 107,  44,  67,  23,
  26, 132,  40,  65,  63,  48,  64,  49,  66,  68,
  65,  63,  99,  64,  39,  66,  58,  39,   4,  57,
  28,  65,  61,  72,   8,  56,  66,  73,  55,  73,
  67,  75,  54,  53,  39,  52,  51,  39,  75,  85,
  86,  71,  72,  87,  47, 117, 120,  70,  73, 117,
  88,  89,  67,  90, 112,  65,  63, 113,  64,  67,
  66, 131,  91,  92,  93,  94,  95,  97,  98, 100,
  67,  59,  50, 100,  65,  63, 104,  64,  74,  66,
 130,  65,  63, 110,  64, 103,  66,  62,  65,  63,
 134,  64, 102,  66, 136,  12,  22, 115,  65,  63,
 116,  64,   3,  66,  67,   7,  46, 121, 122, 123,
 124,  21, 125,  20, 126,  19,  84, 127, 128,  18,
 118, 119,  17,  67,  65,  63,  16,  64,  15,  66,
  67,  14,  13, 133,  10, 135,   2,  67,   1,   0,
 129,   0,   0,   0,   0,   0,   0,  67,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,  67,   0,   0,  24,   0,  25,  27,
  43,  30,   0,   0,  44,  31,  32,  33,  34,  36,
   9,  29,  41,  35,  76,  41,  24,  37,  25,  27,
  43,  30,  45,   0,  44,  31,  32,  33,  34,  36,
   6,  29,  41,  35,  76,  41,   0,  37,   0,   0,
   0,   0,  11 };
short yypact[]={

-242,-1000,-242,-1000,-1000,-260,-277,-1000,-1000, -20,
 -40,-1000,-1000,  25, -14,  17,-1000,  16,  14,  13,
   9,   6,   0,-1000,  -3,-254,   1, -12,-255,  23,
 -37,-257,-278,-263,-264,-238,-267, -37, -37, -37,
-1000,-1000, -37,-1000,-1000,-1000,-1000,-1000,-1000, -37,
 -37,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,  49,
-1000, -37, -37, -37, -37, -17, -37, -37, -37, -51,
-1000,-227, -37,-258,-228, 122,  42,-1000,-1000,-1000,
-239,-240, -37,-252,-226,-1000, 122,  53, 122, 122,
-259, 122, 122,  19,  19, -53, -37, -53,  96,  41,
 122,-260,-260,  45,-1000,  21, -37, -37, -37, -37,
 122, -37,-1000, -37,-1000, -53, -37, -37,-1000,-1000,
-1000, -21, 122, 122, 122, 122,  79,   8, 122, -19,
-1000,-1000, -37,  86, -37,  72,-1000 };
short yypgo[]={

   0, 178, 176, 142,  58, 174, 135, 172, 171, 168,
 166, 162, 159, 155, 153, 151, 136, 111,  40,  52,
  60, 118,  42 };
short yyr1[]={

   0,   1,   1,   2,   2,   3,   3,   4,   4,   5,
   5,   6,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   6,   7,  17,  17,   8,   8,   8,   8,
   9,  19,  19,  10,  10,  10,  20,  20,  11,  12,
  13,  14,  14,  14,  15,  15,  15,  15,  16,  21,
  21,  18,  18,  18,  18,  18,  18,  18,  18,  18,
  18,  18,  18,  18,  22,  22 };
short yyr2[]={

   0,   1,   0,   1,   2,   1,   2,   4,   3,   1,
   2,   2,   2,   2,   1,   2,   2,   2,   2,   2,
   2,   1,   2,   2,   1,   3,   3,   3,   3,   3,
   3,   1,   3,   4,   2,   4,   1,   1,   2,  10,
   2,   1,   2,   2,   4,   4,   3,   4,   2,   1,
   3,   2,   3,   3,   3,   3,   4,   2,   1,   1,
   3,   5,   4,   6,   1,   3 };
short yychk[]={

-1000,  -1,  -2,  -3,  -4, 257, 271,  -3,  -4, 281,
  -5, 282,  -6,  -7,  -8,  -9, -10, -11, -12, -13,
 -14, -15, -16,  59, 256, 258, -18, 259, -20, 271,
 261, 265, 266, 267, 268, 273, 269, 277,  45,  94,
 -22, 272,  40, 260, 264, 282,  -6,  59,  59,  61,
 126,  59,  59,  59,  59,  59,  59,  59,  59, -17,
 271,  61, 126,  43,  45,  42,  47,  91,  61, 271,
  -4,  58,  40,  46, -21, -18, 271, 271, 279, 280,
 273, 273, 270, 273, -21, -18, -18, -18, -18, -18,
  44, -18, -18, -18, -18, -18,  44, -18, -18, -19,
 -18,  58, -20, -19, -22, 271, 263, 262, 270, 270,
 -18, 270,  41,  44, 271, -18,  44,  44,  -4,  -4,
  41, -18, -18, -18, -18, -18, -18, -18, -18,  -4,
  41,  93,  60, -18,  44, -18,  62 };
short yydef[]={

   2,  -2,   1,   3,   5,   0,   0,   4,   6,   0,
   0,   8,   9,   0,   0,   0,  14,   0,   0,   0,
   0,   0,   0,  21,   0,   0,   0,   0,   0,  64,
   0,   0,  41,   0,   0,   0,   0,   0,   0,   0,
  58,  59,   0,  36,  37,   7,  10,  11,  12,   0,
   0,  13,  15,  16,  17,  18,  19,  20,  22,  23,
  24,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  34,   0,   0,   0,  38,  49,  64,  40,  42,  43,
   0,   0,   0,   0,  48,  51,  57,   0,  28,  29,
   0,  26,  27,  52,  53,  54,   0,  55,   0,  30,
  31,   0,   0,   0,  65,  64,   0,   0,   0,   0,
  46,   0,  60,   0,  25,  56,   0,   0,  33,  35,
  62,   0,  50,  44,  45,  47,   0,   0,  32,   0,
  61,  63,   0,   0,   0,   0,  39 };
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
# line 37 "idyac.y"
{
		forget (((BOXPTR)yypvt[-0])->name);
		((BOXPTR) yypvt[-0])->next = boxlist;
		boxlist = (BOXPTR) yypvt[-0];
	} break;
case 4:
# line 42 "idyac.y"
{
		forget (((BOXPTR)yypvt[-0])->name);
		((BOXPTR)yypvt[-0])->next = boxlist;
		boxlist = (BOXPTR) yypvt[-0];
	} break;
case 5:
# line 49 "idyac.y"
{yyval = yypvt[-0];} break;
case 6:
# line 50 "idyac.y"
{yyval = yypvt[-0];} break;
case 7:
# line 53 "idyac.y"
{yyval = (int) boxgen (yypvt[-3], (STMTPTR) yypvt[-1]);} break;
case 8:
# line 54 "idyac.y"
{yyval = (int) boxgen (yypvt[-2], (STMTPTR) NULL);} break;
case 9:
# line 57 "idyac.y"
{yyval = yypvt[-0];} break;
case 10:
# line 58 "idyac.y"
{
		if (yypvt[-0]) {
			((STMTPTR)yypvt[-0])->next = (STMTPTR)yypvt[-1];
			yyval = yypvt[-0];
		} else
			yyval = yypvt[-1];
	} break;
case 11:
# line 67 "idyac.y"
{yyval = (int) stmtgen (VAR, (char *) yypvt[-1]);} break;
case 12:
# line 68 "idyac.y"
{yyval = (int) stmtgen ('=', (char *) yypvt[-1]);} break;
case 13:
# line 69 "idyac.y"
{yyval = (int) stmtgen (BDLIST, (char *) yypvt[-1]);} break;
case 14:
# line 70 "idyac.y"
{yyval = (int) stmtgen (PUT, (char *) yypvt[-0]);} break;
case 15:
# line 71 "idyac.y"
{yyval = (int) stmtgen (CONN, (char *) yypvt[-1]);} break;
case 16:
# line 72 "idyac.y"
{if (yypvt[-1]) {
				yyval = (int) stmtgen (USING, (char *) yypvt[-1]);
			} else {
				yyval = (int) NULL;
			}
		} break;
case 17:
# line 78 "idyac.y"
{yyval = (int) stmtgen (DRAW, (char *) yypvt[-1]);} break;
case 18:
# line 79 "idyac.y"
{yyval = (int) stmtgen (OPAQUE, (char *) yypvt[-1]);} break;
case 19:
# line 80 "idyac.y"
{yyval = (int) stmtgen (STRING, (char *) yypvt[-1]);} break;
case 20:
# line 81 "idyac.y"
{yyval = (int) stmtgen (SPLINE, (char *) yypvt[-1]);} break;
case 21:
# line 82 "idyac.y"
{yyval = (int) NULL;} break;
case 22:
# line 83 "idyac.y"
{fprintf (stderr, "ideal: syntax error near line %d in file %s\n",
				lineno, filename);
			yyerrok;
			yyval = NULL;
	} break;
case 23:
# line 90 "idyac.y"
{yyval = (int) yypvt[-0];} break;
case 24:
# line 93 "idyac.y"
{yyval = (int) namegen (yypvt[-0]);} break;
case 25:
# line 94 "idyac.y"
{
		NAMEPTR temp;
		temp = (NAMEPTR) namegen (yypvt[-0]);
		temp->next = (NAMEPTR)yypvt[-2];
		yyval = (int) temp;
	} break;
case 26:
# line 102 "idyac.y"
{yyval = (int) intlgen ('=', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 27:
# line 103 "idyac.y"
{yyval = (int) intlgen ('~', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 28:
# line 104 "idyac.y"
{yyval = (int) intlgen ('=', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 29:
# line 105 "idyac.y"
{yyval = (int) intlgen ('~', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 30:
# line 108 "idyac.y"
{yyval = (int) yypvt[-0];} break;
case 31:
# line 111 "idyac.y"
{yyval = (int) exprgen ((EXPR) yypvt[-0]);} break;
case 32:
# line 112 "idyac.y"
{
		EXPRPTR temp;
		temp = (EXPRPTR) exprgen ((EXPR) yypvt[-0]);
		temp->next = (EXPRPTR)yypvt[-2];
		yyval = (int) temp;
	} break;
case 33:
# line 120 "idyac.y"
{yyval = (int) putgen (yypvt[-2], (BOXPTR) yypvt[-0], yypvt[-3]);} break;
case 34:
# line 121 "idyac.y"
{yyval = (int) putgen (NULL, (BOXPTR) yypvt[-0], yypvt[-1]);} break;
case 35:
# line 122 "idyac.y"
{yyval = (int) putgen (yypvt[-3], (BOXPTR) yypvt[-0], yypvt[-1]);} break;
case 36:
# line 125 "idyac.y"
{yyval = yypvt[-0];} break;
case 37:
# line 126 "idyac.y"
{yyval = yypvt[-0];} break;
case 38:
# line 129 "idyac.y"
{yyval = (int) yypvt[-0];} break;
case 39:
# line 133 "idyac.y"
{if (!((EXPRPTR) yypvt[-8])->next || ((EXPRPTR) yypvt[-8])->next->next) {
			fprintf (stderr, "ideal: improper pen statement\n   >>>pen ignored\n");
			yyval = (int) NULL;
		} else {
			yyval = (int) pengen (
				((EXPRPTR) yypvt[-8])->next->expr,
				((EXPRPTR) yypvt[-8])->expr,
				(EXPR) yypvt[-6],
				(EXPR) yypvt[-3],
				(EXPR) yypvt[-1],
				(BOXPTR) yypvt[-5]
			);
			tryfree(((EXPRPTR) yypvt[-8])->next);
			tryfree((EXPRPTR) yypvt[-8]);
		}
	} break;
case 40:
# line 151 "idyac.y"
{yyval = (int) miscgen (yypvt[-0]);} break;
case 41:
# line 154 "idyac.y"
{yyval = (int) miscgen (INTERIOR);} break;
case 42:
# line 155 "idyac.y"
{yyval = (int) miscgen (INTERIOR);} break;
case 43:
# line 156 "idyac.y"
{yyval = (int) miscgen (EXTERIOR);} break;
case 44:
# line 159 "idyac.y"
{yyval = (int) strgen (LEFT, (char *) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 45:
# line 160 "idyac.y"
{yyval = (int) strgen (CENTER, (char *) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 46:
# line 161 "idyac.y"
{yyval = (int) strgen (CENTER, (char *) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 47:
# line 162 "idyac.y"
{yyval = (int) strgen (RIGHT, (char *) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 48:
# line 165 "idyac.y"
{yyval = (int) yypvt[-0];} break;
case 49:
# line 167 "idyac.y"
{yyval = (int) exprgen ((EXPR) yypvt[-0]);} break;
case 50:
# line 168 "idyac.y"
{
		EXPRPTR temp;
		temp = (EXPRPTR) exprgen ((EXPR) yypvt[-0]);
		temp->next = (EXPRPTR) yypvt[-2];
		yyval = (int) temp;
	} break;
case 51:
# line 177 "idyac.y"
{yyval = (int) intlgen ('-', (EXPR) NULL, (EXPR) yypvt[-0]);} break;
case 52:
# line 178 "idyac.y"
{yyval = (int) intlgen ('+', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 53:
# line 179 "idyac.y"
{yyval = (int) intlgen ('-', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 54:
# line 180 "idyac.y"
{yyval = (int) intlgen ('*', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 55:
# line 181 "idyac.y"
{yyval = (int) intlgen ('/', (EXPR) yypvt[-2], (EXPR) yypvt[-0]);} break;
case 56:
# line 183 "idyac.y"
{yyval = (int) intlgen (ELEWISE, (EXPR) yypvt[-3], (EXPR) yypvt[-0]);} break;
case 57:
# line 184 "idyac.y"
{yyval = (int) intlgen ('^', (EXPR) NULL, (EXPR) yypvt[-0]);} break;
case 58:
# line 185 "idyac.y"
{yyval = (int) extlgen ((NAMEPTR) yypvt[-0]);} break;
case 59:
# line 186 "idyac.y"
{yyval = yypvt[-0];} break;
case 60:
# line 187 "idyac.y"
{yyval = yypvt[-1];} break;
case 61:
# line 188 "idyac.y"
{yyval = (int) intlgen (',', (EXPR) yypvt[-3], (EXPR) yypvt[-1]);} break;
case 62:
# line 189 "idyac.y"
{yyval = (int) intlgen (NAME, (EXPR) yypvt[-3], (EXPR) yypvt[-1]);} break;
case 63:
# line 190 "idyac.y"
{
		yyval = (int) bracket (
			(EXPR) yypvt[-5],
			(EXPR) yypvt[-3],
			(EXPR) yypvt[-1]
		);
	} break;
case 64:
# line 199 "idyac.y"
{yyval = (int) namegen (yypvt[-0]);} break;
case 65:
# line 200 "idyac.y"
{
		NAMEPTR temp;
		temp = (NAMEPTR) namegen(yypvt[-2]);
		temp->next = (NAMEPTR)yypvt[-0];
		yyval = (int) temp;
	} break;
	}
	goto yystack;  /* stack new state and value */
}
