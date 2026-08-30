
# line 2 "kas0.y"
typedef union  {
	int	ival;
	struct exp *expr;
	struct symtab *sym;
	char *str;
	} YYSTYPE;
# define NOCHAR 257
# define NL 258
# define CM 259
# define SEMI 260
# define COLON 261
# define LP 262
# define RP 263
# define PLUS 264
# define MINUS 265
# define MUL 266
# define DIV 267
# define NOT 268
# define POP 269
# define BAR 270
# define INC 271
# define AND 272
# define XOR 273
# define LS 274
# define RS 275
# define INT 276
# define DNAME 277
# define UNAME 278
# define TNAME 279
# define PAGE 280
# define STR 281
# define REG 282
# define BRG 283
# define MEM 284
# define MAR 285
# define REGL 286
# define REGH 287
# define PC 288
# define PCR 289
# define MVINS 290
# define SFINS 291
# define DFINS 292
# define BRINS 293
# define JMPINS 294
# define SEG 295
# define ORG 296
# define DATA 297
# define DEBUG 298

# line 33 "kas0.y"
#include <stdio.h>
#include "kas.h"
struct	exp	explist[10];
struct	exp	*xp = { explist};
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;

# line 41 "kas0.y"
	int	dinc;
	int	nlf;
# define YYERRCODE 256

# line 394 "kas0.y"


yyerror(s, a)
char *s;
{
	anyerrs++;
	if (infile)
		fprintf(stderr, "%s:", infile);
	fprintf(stderr, "%d:", lineno);
	fprintf(stderr, s, a);
	fprintf(stderr, "\n");
}

#include "kas0.yl"
short yyexca[] ={
-1, 1,
	0, -1,
	258, 8,
	260, 8,
	276, 8,
	278, 8,
	290, 8,
	291, 8,
	292, 8,
	293, 8,
	294, 8,
	295, 8,
	296, 8,
	297, 8,
	-2, 0,
	};
# define YYNPROD 96
# define YYLAST 375
short yyact[]={

  13,  39,  14,   5,  41,  48,  49,  40,  57, 145,
 104, 139, 168, 153, 130,  47,  46,  52,  12, 143,
  11,  91,  48,  49, 101, 102, 103, 144, 138, 164,
  93,  94,  15,  16,  17,  18,  19,  20,  21,  23,
  39, 142, 134,  41, 137,   7,  40,  32,  47,  46,
  36,  37, 131,  26,  47,  46,  36,  37,  27, 115,
  34,  48,  49,  50,  43,  44,  51, 107,  13, 162,
  14, 115, 109, 110, 111, 114, 112, 113,  30, 116,
 161,  78,  79,  29, 109, 110, 111, 114, 112, 113,
  39, 116, 108,  41, 163,  60,  40,  57,  41, 152,
 133,  40,  57, 132,  47,  46,  36,  37, 105,  47,
  46,  36,  37,  67,  56,  98,  68,  41,  87,  81,
  40,  57,  76,  77,  78,  79,  80,  65,  47,  46,
  36,  37,  13,  38,  14,  13, 149,  14,  76,  77,
  78,  79, 100,  63,  71, 106,  73,  72,  74,  75,
 128,  76,  77,  78,  79,  99,  62,  71,  70,  73,
  72,  74,  75,  76,  77,  78,  79,  90,  22,  71,
  10,  73,  72,  74,  75,  76,  77,  78,  79,   3,
   2,  71,   1,  73,  72,  74,  75,  39,   4,   6,
  41,  35,  45,  40,  57,  76,  77,  78,  79, 151,
   9,  47,  46,  73,  31,  74,  75,  76,  77,  78,
  79,  13,  85,  14,   8,   0,  92,  74,  75,  24,
  25,   0,   0,  55,  59,  28, 126, 127,  97,   0,
  82, 129,  42,   0,  53, 158,   0,  66,   0,   0,
   0,   0, 135,   0,   0,   0,  33,   0,   0,  54,
  58,   0,  61,  64,   0,   0,   0, 169,   0,   0,
   0, 140,   0,  69,   0,   0,   0,  86,   0,  88,
  89,  83,  84,  95,  96,   0,   0,   0,   0,   0,
 156,   0,   0,   0,   0,   0,   0,   0,  69,   0,
   0,   0,   0,   0,   0, 159, 166,   0,   0,   0,
   0,   0, 117, 118, 119, 120, 121, 122, 123, 124,
 125,   0,   0,   0, 136,   0,   0,   0,   0,   0,
   0, 141,   0,   0,   0,   0,   0,   0,   0,  64,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 146, 147,   0, 148, 150,   0,   0,   0, 155,
 154,   0,   0,   0,   0, 157,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 160, 167,   0,   0,
   0,   0,   0,   0, 165 };
short yypact[]={

-1000,-253,-1000,-258,-190,-190,-223,-1000,-1000,-1000,
-190,-178,-183,-1000,-1000,-222,-265,-278,-148,-167,
-1000, -75, -75,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-132,-172,-101,-133,-140,-1000,-1000,-1000, -75,
 -75, -75,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000, -47,-141,-126,-190,-261, -75,-126,-190,
-261, -89,-144,-1000, -89,-259,-151,-1000,-1000,-1000,
-198, -75, -75, -75, -75, -75, -75, -75, -75, -75,
-198,-198,-113,-1000,-1000,-198,-1000,-268,-1000,-1000,
-211,-1000,-1000,-156,-159,-1000,-1000,-221, -75,-190,
-226,-1000,-1000,-243,-274,-259,-190,-1000,-229,-1000,
-256,-1000,-1000,-1000,-244,-276,-1000, -69, -69, -57,
-142,-142,-185,-185,-1000,-1000,-190,-190,-1000,-190,
-123,-160,-269,-278,-190,-1000,-1000,-259,-1000,-1000,
-190,-1000,-210,-1000,-1000,-1000,-1000,-1000,-1000,-198,
-1000,-190,-200,-1000,-165,-1000,-1000,-1000,-241,-190,
-1000,-1000,-228,-270,-210,-1000,-1000,-1000,-1000,-1000 };
short yypgo[]={

   0, 204, 200, 167, 199, 145,  92, 142, 155, 192,
 191, 216, 230, 133, 189, 188, 182, 180, 179, 214,
 170, 168, 156, 143 };
short yyr1[]={

   0,  16,  16,  17,  17,  17,  17,  17,  18,  18,
  18,  19,  19,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   3,   3,
   3,   3,   4,   4,   4,   4,   1,   1,   5,   5,
   5,   5,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   8,   8,   7,   7,   7,   7,   7,  10,
  10,  10,  10,  11,  11,   9,   9,   9,   9,  12,
  12,  12,  12,  12,  12,  12,  12,  12,  12,  12,
  12,  12,  12,  13,  13,  20,  20,  20,  21,  22,
  22,  23,  15,  15,  15,  14 };
short yyr2[]={

   0,   0,   2,   2,   2,   3,   2,   2,   0,   3,
   3,   1,   1,   5,   6,   5,   5,   5,   5,   3,
   7,   5,   3,   3,   6,   3,   3,   5,   1,   1,
   3,   5,   0,   2,   3,   3,   1,   1,   1,   1,
   3,   5,   1,   1,   1,   1,   1,   2,   1,   2,
   2,   1,   1,   3,   1,   1,   1,   2,   2,   1,
   1,   1,   1,   1,   1,   1,   2,   1,   2,   1,
   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,
   2,   2,   2,   1,   1,   1,   2,   2,   1,   1,
   3,   1,   1,   2,   2,   1 };
short yychk[]={

-1000, -16, -17, -18, -15, 256, -14, 298, -19,  -2,
 -20, 278, 276, 258, 260, 290, 291, 292, 293, 294,
 295, 296, -21, 297, -19, -19, 276, 281, -19, 261,
 261,  -1, 269, -12, 282, -10, 278, 279, -13, 262,
 268, 265, -11, 286, 287,  -9, 277, 276, 283, 284,
 285, 288, 282, -11, -12,  -1, 262, 269, -12,  -1,
 262, -12, -22, -23, -12, 259,  -1, 285, 288, -12,
 259, 270, 273, 272, 274, 275, 264, 265, 266, 267,
 259, 259, -12, -12, -12, 259, -19, 259, -19, -19,
  -3, 282, -11, 291, 292, -19, -19,  -3, 259,  -8,
  -7, 283, 284, 285, 269, 259,  -5, 265,  -6, 282,
 283, 284, 286, 287, 285, 269, 289, -12, -12, -12,
 -12, -12, -12, -12, -12, -12,  -5,  -5, 263,  -5,
 282, 263, 259, 259, 263, -23, -19, 270, 271, 285,
  -8, -19, 270, 275, 271, 285, -19, -19, -19, 259,
 -19,  -4, 259, 282, -11, -19,  -7, -19,  -6,  -5,
 -19, 280, 269, 259, 270, -19, -13,  -1, 282,  -6 };
short yydef[]={

   1,  -2,   2,   0,   0,   0,  92,  95,   3,   4,
   0,   0,   0,  11,  12,   0,   0,   0,   0,   0,
  85,   0,   0,  88,   6,   7,  93,  94,   5,   9,
  10,   0,   0,   0,   0,   0,  36,  37,  69,   0,
   0,   0,  59,  60,  61,  62,  83,  84,  63,  64,
  65,  67,   0,   0,   0,   0,   0,   0,   0,   0,
   0,  86,  87,  89,  91,   0,   0,  66,  68,  81,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,  80,  82,   0,  19,   0,  22,  23,
   0,  28,  29,   0,   0,  25,  26,   0,   0,   0,
  52,  54,  55,  56,   0,   0,   0,  38,  39,  42,
  43,  44,  45,  46,  48,   0,  51,  71,  72,  73,
  74,  75,  76,  77,  78,  79,   0,   0,  70,   0,
   0,  32,   0,   0,   0,  90,  13,   0,  57,  58,
   0,  15,   0,  47,  49,  50,  16,  17,  18,   0,
  21,   0,   0,  30,   0,  27,  53,  14,  40,   0,
  24,  33,   0,   0,   0,  20,  34,  35,  31,  41 };
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
		
case 2:
# line 45 "kas0.y"
 {
		xp = explist;
		if (nlf)
			lineno++;
	} break;
case 4:
# line 53 "kas0.y"
 {
		putins(yypvt[-0].ival);
	} break;
case 6:
# line 57 "kas0.y"
 {
		debug(yypvt[-1].expr->xvalue, yypvt[-1].expr->xtype);
	} break;
case 7:
# line 60 "kas0.y"
 {
		yyerrok;
	} break;
case 9:
# line 66 "kas0.y"
 {
		yypvt[-1].sym->type = dot->type;
		backup(yypvt[-1].sym,dot->value);
	} break;
case 10:
# line 70 "kas0.y"
 {
		if (yypvt[-1].ival<0 || yypvt[-1].ival>9) {
			yyerror("illegal numeric label");
		} else {
			loclab[yypvt[-1].ival].name[0] = 1;
			backup(&loclab[yypvt[-1].ival], dot->value);
			loclab[yypvt[-1].ival].type = dot->value;
			loclab[yypvt[-1].ival].value = 0;
		}
	} break;
case 11:
# line 82 "kas0.y"
 {
		nlf = 1;
	} break;
case 12:
# line 85 "kas0.y"
 {
		nlf = 0;
	} break;
case 13:
# line 90 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|yypvt[-1].ival;
		reloc[dot->value] = yypvt[-3].sym->value;
		yypvt[-3].sym->value = dot->value|RLCMV;
	} break;
case 14:
# line 95 "kas0.y"
 {
		yyval.ival = yypvt[-5].sym->value|yypvt[-1].ival;
		reloc[dot->value] = yypvt[-3].sym->value;
		yypvt[-3].sym->value = dot->value|RLCPOP;
	} break;
case 15:
# line 100 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|cksrc(yypvt[-3].expr->xvalue&0377, yypvt[-1].ival);
	} break;
case 16:
# line 103 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|SRCBRG|SELA|ckreg(yypvt[-3].sym->value, yypvt[-1].ival);
	} break;
case 17:
# line 106 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|yypvt[-3].ival|yypvt[-1].ival;
	} break;
case 18:
# line 109 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|SRCBRG|ckreg(yypvt[-3].sym->value, yypvt[-1].ival);
	} break;
case 19:
# line 112 "kas0.y"
 {
		yyval.ival = yypvt[-2].sym->value|SRCBRG|yypvt[-1].sym->value|DSTREG;
	} break;
case 20:
# line 115 "kas0.y"
 {
		yyval.ival = yypvt[-6].sym->value|yypvt[-5].ival|ckreg(yypvt[-3].sym->value, yypvt[-1].ival);
	} break;
case 21:
# line 118 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|yypvt[-3].ival|yypvt[-1].sym->value|DSTREG;
	} break;
case 22:
# line 121 "kas0.y"
 {
		yyval.ival = yypvt[-2].sym->value|(yypvt[-1].expr->xvalue&0377)|((yypvt[-1].expr->xvalue&01400)<<3);
		if ((dot->value&~01777) != (yypvt[-1].expr->xvalue&~01777))
			yyerror("branch out of range");
	} break;
case 23:
# line 126 "kas0.y"
 {
		yyval.ival = yypvt[-2].sym->value;
		reloc[dot->value] = yypvt[-1].sym->value;
		yypvt[-1].sym->value = dot->value|RLCBR;
	} break;
case 24:
# line 131 "kas0.y"
 {
		yyval.ival = yypvt[-5].sym->value|yypvt[-3].ival|yypvt[-1].ival;
	} break;
case 25:
# line 134 "kas0.y"
 {
		yyval.ival = yypvt[-2].sym->value|(yypvt[-1].expr->xvalue&0377);
	} break;
case 26:
# line 137 "kas0.y"
 {
		yyval.ival = yypvt[-2].sym->value;
		reloc[dot->value] = yypvt[-1].sym->value;
		yypvt[-1].sym->value = dot->value|RLCMV;
	} break;
case 27:
# line 142 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|yypvt[-2].ival;
	} break;
case 28:
# line 147 "kas0.y"
 {
		yyval.ival = yypvt[-0].sym->value|SRCBRG|SELA;
	} break;
case 29:
# line 150 "kas0.y"
 {
		yyval.ival = yypvt[-0].ival|SELB;
	} break;
case 30:
# line 153 "kas0.y"
 {
		yyval.ival = yypvt[-2].sym->value|yypvt[-0].sym->value|SRCBRG;
	} break;
case 31:
# line 156 "kas0.y"
 {
		yyval.ival = yypvt[-4].sym->value|yypvt[-2].ival|yypvt[-0].sym->value;
	} break;
case 32:
# line 161 "kas0.y"
 {
		yyval.ival = 0;
	} break;
case 33:
# line 164 "kas0.y"
 {
		yyval.ival = yypvt[-0].sym->value;
	} break;
case 34:
# line 167 "kas0.y"
 {
		yyval.ival = (yypvt[-0].expr->xvalue&01400)<<3;
	} break;
case 35:
# line 170 "kas0.y"
 {
		yyval.ival = 0;
		reloc[dot->value] = yypvt[-0].sym->value;
		yypvt[-0].sym->value = dot->value|RLCPG;
	} break;
case 38:
# line 182 "kas0.y"
 {
		yyval.ival = 0;
	} break;
case 40:
# line 186 "kas0.y"
 {
		yyval.ival = ckdst(yypvt[-2].ival, yypvt[-0].ival);
	} break;
case 41:
# line 189 "kas0.y"
 {
		yyval.ival = ckdst(ckdst(yypvt[-4].ival, yypvt[-2].ival), yypvt[-0].ival);
	} break;
case 42:
# line 194 "kas0.y"
 {
		yyval.ival = yypvt[-0].sym->value|DSTREG;
	} break;
case 43:
# line 197 "kas0.y"
 {
		yyval.ival = DSTBRG;
	} break;
case 44:
# line 200 "kas0.y"
 {
		yyval.ival = DSTMEM;
	} break;
case 45:
# line 203 "kas0.y"
 {
		yyval.ival = yypvt[-0].sym->value|DSTREGL;
	} break;
case 46:
# line 206 "kas0.y"
 {
		yyval.ival = yypvt[-0].sym->value|DSTREGH;
	} break;
case 47:
# line 209 "kas0.y"
 {
		yyval.ival = DSTBGRS;
	} break;
case 48:
# line 212 "kas0.y"
 {
		yyval.ival = DSTMAR;
	} break;
case 49:
# line 215 "kas0.y"
 {
		yyval.ival = DSTMARI;
	} break;
case 50:
# line 218 "kas0.y"
 {
		yyval.ival = DSTMARP;
	} break;
case 51:
# line 221 "kas0.y"
 {
		yyval.ival = DSTPCH|DSTREGH;
	} break;
case 53:
# line 227 "kas0.y"
 {
		yyval.ival = ckdst(yypvt[-2].ival, yypvt[-0].ival);
	} break;
case 54:
# line 232 "kas0.y"
 {
		yyval.ival = DSTBRG;
	} break;
case 55:
# line 235 "kas0.y"
 {
		yyval.ival = DSTMEM;
	} break;
case 56:
# line 238 "kas0.y"
 {
		yyval.ival = DSTMAR;
	} break;
case 57:
# line 241 "kas0.y"
 {
		yyval.ival = DSTMARI;
	} break;
case 58:
# line 244 "kas0.y"
 {
		yyval.ival = DSTMARP;
	} break;
case 59:
# line 249 "kas0.y"
 {
		yyval.ival = yypvt[-0].ival|SELB;
	} break;
case 60:
# line 252 "kas0.y"
 {
		yyval.ival = (yypvt[-0].sym->value<<4)|SRCREGL;
	} break;
case 61:
# line 255 "kas0.y"
 {
		yyval.ival = (yypvt[-0].sym->value<<4)|SRCREGH;
	} break;
case 62:
# line 258 "kas0.y"
 {
		yyval.ival = (yypvt[-0].ival<<4)|SRCREGH;
	} break;
case 63:
# line 263 "kas0.y"
 {
		yyval.ival = SRCBRG;
	} break;
case 64:
# line 266 "kas0.y"
 {
		yyval.ival = SRCMEM;
	} break;
case 65:
# line 271 "kas0.y"
 {
		yyval.ival = SRCMARL;
	} break;
case 66:
# line 274 "kas0.y"
 {
		yyval.ival = SRCMARH;
	} break;
case 67:
# line 277 "kas0.y"
 {
		yyval.ival = SRCPCL;
	} break;
case 68:
# line 280 "kas0.y"
 {
		yyval.ival = SRCPCH;
	} break;
case 70:
# line 286 "kas0.y"
 {
		yyval.expr = yypvt[-1].expr;
	} break;
case 71:
# line 289 "kas0.y"
 {
		yypvt[-2].expr->xvalue |= yypvt[-0].expr->xvalue;
	} break;
case 72:
# line 292 "kas0.y"
 {
		yypvt[-2].expr->xvalue ^= yypvt[-0].expr->xvalue;
	} break;
case 73:
# line 295 "kas0.y"
 {
		yypvt[-2].expr->xvalue &= yypvt[-0].expr->xvalue;
	} break;
case 74:
# line 298 "kas0.y"
 {
		yypvt[-2].expr->xvalue <<= yypvt[-0].expr->xvalue;
	} break;
case 75:
# line 301 "kas0.y"
 {
		yypvt[-2].expr->xvalue >>= yypvt[-0].expr->xvalue;
	} break;
case 76:
# line 304 "kas0.y"
 {
		yypvt[-2].expr->xvalue += yypvt[-0].expr->xvalue;
	} break;
case 77:
# line 307 "kas0.y"
 {
		yypvt[-2].expr->xvalue -= yypvt[-0].expr->xvalue;
	} break;
case 78:
# line 310 "kas0.y"
 {
		yypvt[-2].expr->xvalue *= yypvt[-0].expr->xvalue;
	} break;
case 79:
# line 313 "kas0.y"
 {
		yypvt[-2].expr->xvalue /= yypvt[-0].expr->xvalue;
	} break;
case 80:
# line 316 "kas0.y"
 {
		yypvt[-0].expr->xvalue = ~yypvt[-0].expr->xvalue;
		yyval.expr = yypvt[-0].expr;
	} break;
case 81:
# line 320 "kas0.y"
 {
		yypvt[-0].expr->xvalue = (yypvt[-0].expr->xvalue>>8)&0377;
		yyval.expr = yypvt[-0].expr;
	} break;
case 82:
# line 324 "kas0.y"
 {
		yypvt[-0].expr->xvalue = -yypvt[-0].expr->xvalue;
		yyval.expr = yypvt[-0].expr;
	} break;
case 83:
# line 330 "kas0.y"
 {
		yyval.expr = xp++;
		yyval.expr->xtype = XABS;
		yyval.expr->xvalue = yypvt[-0].sym->value;
	} break;
case 84:
# line 335 "kas0.y"
 {
		yyval.expr = xp++;
		yyval.expr->xtype = XABS;
		yyval.expr->xvalue = yypvt[-0].ival;
	} break;
case 85:
# line 342 "kas0.y"
 {
		if (dot->type==XTEXT)
			textsv = dot->value;
		else	datasv = dot->value;
		dot->type = yypvt[-0].sym->value;
		if (dot->type==XTEXT)
			dot->value = textsv;
		else	dot->value = datasv;
	} break;
case 86:
# line 351 "kas0.y"
 {
		if (yypvt[-0].expr->xvalue<0 || yypvt[-0].expr->xvalue>=NKMCI)
			yyerror("illegal org value");
		else	dot->value = yypvt[-0].expr->xvalue;
	} break;
case 88:
# line 359 "kas0.y"
 {
		if (dot->type != XDATA) {
			yyerror("no data in text");
		}
		dinc = yypvt[-0].sym->value;
	} break;
case 91:
# line 371 "kas0.y"
 {
		putdat(yypvt[-0].expr->xvalue&0377);
		if (dinc==2)
			putdat((yypvt[-0].expr->xvalue>>8)&0377);
		xp = explist;
	} break;
case 93:
# line 380 "kas0.y"
 {
		yypvt[-1].expr->xtype = yypvt[-0].ival;
	} break;
case 94:
# line 383 "kas0.y"
 {
		yypvt[-1].expr->xtype = (int)yypvt[-0].str;
	} break;
case 95:
# line 388 "kas0.y"
 {
		yyval.expr = xp++;
		yyval.expr->xvalue = yypvt[-0].sym->value;
		yyval.expr->xtype = 0;
	} break;
	}
	goto yystack;  /* stack new state and value */
}
