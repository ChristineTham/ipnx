# define OR 257
# define AND 258
# define ADD 259
# define SUBT 260
# define MULT 261
# define DIV 262
# define REM 263
# define EQ 264
# define GT 265
# define GEQ 266
# define LT 267
# define LEQ 268
# define NEQ 269
# define A_STRING 270
# define SUBSTR 271
# define LENGTH 272
# define INDEX 273
# define NOARG 274
# define MATCH 275
# define MCH 276

# line 18 "expr.y"
#define YYSTYPE charp

typedef char *charp;
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

# line 55 "expr.y"

/*	expression command */
#include <stdio.h>
/* get rid of yacc debug printf's */
#define printf
#define ESIZE	512
#define error(c)	errxx(c)
#define EQL(x,y) !strcmp(x,y)
long atol();
char *ltoa();
char	**Av;
int	Ac;
int	Argi;

char Mstring[1][128];
char *malloc();
extern int nbra;

main(argc, argv) char **argv; {
	Ac = argc;
	Argi = 1;
	Av = argv;
	yyparse();
}

char *operator[] = { "|", "&", "+", "-", "*", "/", "%", ":",
	"=", "==", "<", "<=", ">", ">=", "!=",
	"match", "substr", "length", "index", "\0" };
int op[] = { OR, AND, ADD,  SUBT, MULT, DIV, REM, MCH,
	EQ, EQ, LT, LEQ, GT, GEQ, NEQ,
	MATCH, SUBSTR, LENGTH, INDEX };
yylex() {
	register char *p;
	register i;

	if(Argi >= Ac) return NOARG;

	p = Av[Argi++];

	if(*p == '(' || *p == ')')
		return (int)*p;
	for(i = 0; *operator[i]; ++i)
		if(EQL(operator[i], p))
			return op[i];

	yylval = p;
	return A_STRING;
}

char *rel(op, r1, r2) register char *r1, *r2; {
	register i;

	if(ematch(r1, "-\\{0,1\\}[0-9]*$") && ematch(r2, "-\\{0,1\\}[0-9]*$"))
		i = atol(r1) - atol(r2);
	else
		i = strcmp(r1, r2);
	switch(op) {
	case EQ: i = i==0; break;
	case GT: i = i>0; break;
	case GEQ: i = i>=0; break;
	case LT: i = i<0; break;
	case LEQ: i = i<=0; break;
	case NEQ: i = i!=0; break;
	}
	return i? "1": "0";
}

char *arith(op, r1, r2) char *r1, *r2; {
	long i1, i2;
	register char *rv;

	if(!(ematch(r1, "-\\{0,1\\}[0-9]*$") && ematch(r2, "-\\{0,1\\}[0-9]*$")))
		yyerror("non-numeric argument");
	i1 = atol(r1);
	i2 = atol(r2);

	switch(op) {
	case ADD: i1 = i1 + i2; break;
	case SUBT: i1 = i1 - i2; break;
	case MULT: i1 = i1 * i2; break;
	case DIV: i1 = i1 / i2; break;
	case REM: i1 = i1 % i2; break;
	}
	rv = malloc(16);
	strcpy(rv, ltoa(i1));
	return rv;
}
char *conj(op, r1, r2) char *r1, *r2; {
	register char *rv;

	switch(op) {

	case OR:
		if(EQL(r1, "0")
		|| EQL(r1, ""))
			if(EQL(r2, "0")
			|| EQL(r2, ""))
				rv = "0";
			else
				rv = r2;
		else
			rv = r1;
		break;
	case AND:
		if(EQL(r1, "0")
		|| EQL(r1, ""))
			rv = "0";
		else if(EQL(r2, "0")
		|| EQL(r2, ""))
			rv = "0";
		else
			rv = r1;
		break;
	}
	return rv;
}

char *substr(v, s, w) char *v, *s, *w; {
register si, wi;
register char *res;

	si = atol(s);
	wi = atol(w);
	while(--si) if(*v) ++v;

	res = v;

	while(wi--) if(*v) ++v;

	*v = '\0';
	return res;
}

char *length(s) register char *s; {
	register i = 0;
	register char *rv;

	while(*s++) ++i;

	rv = malloc(8);
	strcpy(rv, ltoa((long)i));
	return rv;
}

char *index(s, t) char *s, *t; {
	register i, j;
	register char *rv;

	for(i = 0; s[i] ; ++i)
		for(j = 0; t[j] ; ++j)
			if(s[i]==t[j]) {
				strcpy(rv=malloc(8), ltoa((long)++i));
				return rv;
			}
	return "0";
}

char *match(s, p)
{
	register char *rv;

	strcpy(rv=malloc(8), ltoa((long)ematch(s, p)));
	if(nbra) {
		rv = malloc(strlen(Mstring[0])+1);
		strcpy(rv, Mstring[0]);
	}
	return rv;
}

#define INIT	register char *sp = instring;
#define GETC()		(*sp++)
#define PEEKC()		(*sp)
#define UNGETC(c)	(--sp)
#define RETURN(c)	return
#define ERROR(c)	errxx(c)


ematch(s, p)
char *s;
register char *p;
{
	static char expbuf[ESIZE];
	char *compile();
	register num;
	extern char *braslist[], *braelist[], *loc2;

	compile(p, expbuf, &expbuf[ESIZE], 0);
	if(nbra > 1)
		yyerror("Too many '\\('s");
	if(advance(s, expbuf)) {
		if(nbra == 1) {
			p = braslist[0];
			num = braelist[0] - p;
			strncpy(Mstring[0], p, num);
			Mstring[0][num] = '\0';
		}
		return(loc2-s);
	}
	return(0);
}

errxx(c)
{
	yyerror("RE error");
}

#include  "regexp.h"
yyerror(s)

{
	write(2, "expr: ", 6);
	prt(2, s);
	exit(2);
}
prt(fd, s)
char *s;
{
	write(fd, s, strlen(s));
	write(fd, "\n", 1);
}
char *ltoa(l)
long l;
{
	static char str[20];
	register char *sp = &str[18];
	register i;
	register neg = 0;

	if(l < 0)
		++neg, l *= -1;
	str[19] = '\0';
	do {
		i = l % 10;
		*sp-- = '0' + i;
		l /= 10;
	} while(l);
	if(neg)
		*sp-- = '-';
	return ++sp;
}
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 22
# define YYLAST 270
short yyact[]={

   3,  10,  11,  18,  19,  20,  21,  22,  12,  13,
  14,  15,  16,  17,  23,   1,   0,   0,   9,   0,
  23,  43,  11,  18,  19,  20,  21,  22,  12,  13,
  14,  15,  16,  17,   3,  18,  19,  20,  21,  22,
  23,  18,  19,  20,  21,  22,  12,  13,  14,  15,
  16,  17,  23,  20,  21,  22,   0,   0,  23,   2,
   0,   0,   0,  24,  25,  26,  27,  28,  23,   0,
  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,
  39,  40,  41,  42,   0,  44,  45,   0,  46,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,  47,   0,   0,   0,   0,
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
   0,   0,   0,   0,   0,   0,   0,  10,  11,  18,
  19,  20,  21,  22,  12,  13,  14,  15,  16,  17,
   8,   5,   6,   7,   0,   4,  23,  10,  11,  18,
  19,  20,  21,  22,  12,  13,  14,  15,  16,  17,
   0,   0,   0,   0,   0,   0,  23,   0,   0,   0,
   0,   0,   0,   0,   8,   5,   6,   7,   0,   4 };
short yypact[]={

  -6,-1000,-256,  -6,  -6,  -6,  -6,  -6,-1000,-1000,
  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,
  -6,  -6,  -6,  -6, -20, -40, -40,-1000, -40,-236,
-218,-224,-224,-224,-224,-224,-224,-208,-208,-262,
-262,-262,-1000,-1000,-1000, -40,-1000,-1000 };
short yypgo[]={

   0,  15,  59 };
short yyr1[]={

   0,   1,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2 };
short yyr2[]={

   0,   2,   3,   3,   3,   3,   3,   3,   3,   3,
   3,   3,   3,   3,   3,   3,   3,   3,   4,   2,
   3,   1 };
short yychk[]={

-1000,  -1,  -2,  40, 275, 271, 272, 273, 270, 274,
 257, 258, 264, 265, 266, 267, 268, 269, 259, 260,
 261, 262, 263, 276,  -2,  -2,  -2,  -2,  -2,  -2,
  -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,
  -2,  -2,  -2,  41,  -2,  -2,  -2,  -2 };
short yydef[]={

   0,  -2,   0,   0,   0,   0,   0,   0,  21,   1,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  19,   0,   3,
   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,
  14,  15,  16,   2,  17,   0,  20,  18 };
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
# line 27 "expr.y"
 {
			prt(1, yypvt[-1]);
			exit((!strcmp(yypvt[-1],"0")||!strcmp(yypvt[-1],"\0"))? 1: 0);
			} break;
case 2:
# line 34 "expr.y"
 { yyval = yypvt[-1]; } break;
case 3:
# line 35 "expr.y"
 { yyval = conj(OR, yypvt[-2], yypvt[-0]); } break;
case 4:
# line 36 "expr.y"
 { yyval = conj(AND, yypvt[-2], yypvt[-0]); } break;
case 5:
# line 37 "expr.y"
 { yyval = rel(EQ, yypvt[-2], yypvt[-0]); } break;
case 6:
# line 38 "expr.y"
 { yyval = rel(GT, yypvt[-2], yypvt[-0]); } break;
case 7:
# line 39 "expr.y"
 { yyval = rel(GEQ, yypvt[-2], yypvt[-0]); } break;
case 8:
# line 40 "expr.y"
 { yyval = rel(LT, yypvt[-2], yypvt[-0]); } break;
case 9:
# line 41 "expr.y"
 { yyval = rel(LEQ, yypvt[-2], yypvt[-0]); } break;
case 10:
# line 42 "expr.y"
 { yyval = rel(NEQ, yypvt[-2], yypvt[-0]); } break;
case 11:
# line 43 "expr.y"
 { yyval = arith(ADD, yypvt[-2], yypvt[-0]); } break;
case 12:
# line 44 "expr.y"
 { yyval = arith(SUBT, yypvt[-2], yypvt[-0]); } break;
case 13:
# line 45 "expr.y"
 { yyval = arith(MULT, yypvt[-2], yypvt[-0]); } break;
case 14:
# line 46 "expr.y"
 { yyval = arith(DIV, yypvt[-2], yypvt[-0]); } break;
case 15:
# line 47 "expr.y"
 { yyval = arith(REM, yypvt[-2], yypvt[-0]); } break;
case 16:
# line 48 "expr.y"
 { yyval = match(yypvt[-2], yypvt[-0]); } break;
case 17:
# line 49 "expr.y"
 { yyval = match(yypvt[-1], yypvt[-0]); } break;
case 18:
# line 50 "expr.y"
 { yyval = substr(yypvt[-2], yypvt[-1], yypvt[-0]); } break;
case 19:
# line 51 "expr.y"
 { yyval = length(yypvt[-0]); } break;
case 20:
# line 52 "expr.y"
 { yyval = index(yypvt[-1], yypvt[-0]); } break;
	}
	goto yystack;  /* stack new state and value */
}
