
# line 2 "hoc.y"
#include "hoc.h"
#define	code2(c1,c2)	code(c1); code(c2)
#define	code3(c1,c2,c3)	code(c1); code(c2); code(c3)

# line 6 "hoc.y"
typedef union  {
	Symbol	*sym;	/* symbol table pointer */
	Inst	*inst;	/* machine instruction */
	int	narg;	/* number of arguments */
} YYSTYPE;
# define NUMBER 257
# define STRING 258
# define PRINT 259
# define VAR 260
# define BLTIN 261
# define UNDEF 262
# define WHILE 263
# define FOR 264
# define IF 265
# define ELSE 266
# define FUNCTION 267
# define PROCEDURE 268
# define RETURN 269
# define FUNC 270
# define PROC 271
# define READ 272
# define ARG 273
# define ADDEQ 274
# define SUBEQ 275
# define MULEQ 276
# define DIVEQ 277
# define MODEQ 278
# define OR 279
# define AND 280
# define GT 281
# define GE 282
# define LT 283
# define LE 284
# define EQ 285
# define NE 286
# define UNARYMINUS 287
# define NOT 288
# define INC 289
# define DEC 290
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 136 "hoc.y"

	/* end of grammar */
#include <stdio.h>
#include <ctype.h>
char	*progname;
int	lineno = 1;
#include <signal.h>
#include <setjmp.h>
#include <errno.h>
jmp_buf	begin;
int	indef;
char	*infile;	/* input file name */
FILE	*fin;		/* input file pointer */
char	**gargv;	/* global argument list */
extern	errno;
int	gargc;

int c = '\n';	/* global for use by warning() */

yylex()		/* hoc6 */
{
	while ((c=getc(fin)) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '\\') {
		c = getc(fin);
		if (c == '\n') {
			lineno++;
			return yylex();
		}
	}
	if (c == '#') {		/* comment */
		while ((c=getc(fin)) != '\n' && c != EOF)
			;
		if (c == '\n')
			lineno++;
		return c;
	}
	if (c == '.' || isdigit(c)) {	/* number */
		double d;
		ungetc(c, fin);
		fscanf(fin, "%lf", &d);
		yylval.sym = install("", NUMBER, d);
		return NUMBER;
	}
	if (isalpha(c) || c == '_') {
		Symbol *s;
		char sbuf[100], *p = sbuf;
		do {
			if (p >= sbuf + sizeof(sbuf) - 1) {
				*p = '\0';
				execerror("name too long", sbuf);
			}
			*p++ = c;
		} while ((c=getc(fin)) != EOF && (isalnum(c) || c == '_'));
		ungetc(c, fin);
		*p = '\0';
		if ((s=lookup(sbuf)) == 0)
			s = install(sbuf, UNDEF, 0.0);
		yylval.sym = s;
		return s->type == UNDEF ? VAR : s->type;
	}
	if (c == '$') {	/* argument? */
		int n = 0;
		while (isdigit(c=getc(fin)))
			n = 10 * n + c - '0';
		ungetc(c, fin);
		if (n == 0)
			execerror("strange $...", (char *)0);
		yylval.narg = n;
		return ARG;
	}
	if (c == '"') {	/* quoted string */
		char sbuf[100], *p, *emalloc();
		for (p = sbuf; (c=getc(fin)) != '"'; p++) {
			if (c == '\n' || c == EOF)
				execerror("missing quote", "");
			if (p >= sbuf + sizeof(sbuf) - 1) {
				*p = '\0';
				execerror("string too long", sbuf);
			}
			*p = backslash(c);
		}
		*p = 0;
		yylval.sym = (Symbol *)emalloc(strlen(sbuf)+1);
		strcpy(yylval.sym, sbuf);
		return STRING;
	}
	switch (c) {
	case '+':	return follow('+', INC, follow('=', ADDEQ, '+'));
	case '-':	return follow('-', DEC, follow('=', SUBEQ, '-'));
	case '*':	return follow('=', MULEQ, '*');
	case '/':	return follow('=', DIVEQ, '/');
	case '%':	return follow('=', MODEQ, '%');
	case '>':	return follow('=', GE, GT);
	case '<':	return follow('=', LE, LT);
	case '=':	return follow('=', EQ, '=');
	case '!':	return follow('=', NE, NOT);
	case '|':	return follow('|', OR, '|');
	case '&':	return follow('&', AND, '&');
	case '\n':	lineno++; return '\n';
	default:	return c;
	}
}

backslash(c)	/* get next char with \'s interpreted */
	int c;
{
	char *strchr();	/* `index()' in some systems */
	static char transtab[] = "b\bf\fn\nr\rt\t";
	if (c != '\\')
		return c;
	c = getc(fin);
	if (islower(c) && strchr(transtab, c))
		return strchr(transtab, c)[1];
	return c;
}

follow(expect, ifyes, ifno)	/* look ahead for >=, etc. */
{
	int c = getc(fin);

	if (c == expect)
		return ifyes;
	ungetc(c, fin);
	return ifno;
}

defnonly(s)	/* warn if illegal definition */
	char *s;
{
	if (!indef)
		execerror(s, "used outside definition");
}

yyerror(s)	/* report compile-time error */
	char *s;
{
/*rob
	warning(s, (char *)0);
	longjmp(begin, 0);
rob*/
	execerror(s, (char *)0);
}

execerror(s, t)	/* recover from run-time error */
	char *s, *t;
{
	warning(s, t);
	fseek(fin, 0L, 2);		/* flush rest of file */
	longjmp(begin, 0);
}

fpecatch()	/* catch floating point exceptions */
{
	execerror("floating point exception", (char *) 0);
}

intcatch()	/* catch interrupts */
{
	execerror("interrupt", (char *) 0);
}

main(argc, argv)	/* hoc6 */
	char *argv[];
{
	int i, fpecatch();
	static int first = 1;

	progname = argv[0];
	init();
	if (argc == 1) {	/* fake an argument list */
		static char *stdinonly[] = { "-" };

		gargv = stdinonly;
		gargc = 1;
	} else if (first) {	/* for interrupts */
		first = 0;
		gargv = argv+1;
		gargc = argc-1;
	}
	while (moreinput())
		run();
	signal(SIGINT, SIG_IGN);
	return 0;
}

moreinput()
{
	if (gargc-- <= 0)
		return 0;
	if (fin && fin != stdin)
		fclose(fin);
	infile = *gargv++;
	lineno = 1;
	if (strcmp(infile, "-") == 0) {
		fin = stdin;
		infile = 0;
	} else if ((fin=fopen(infile, "r")) == NULL) {
		fprintf(stderr, "%s: can't open %s\n", progname, infile);
		return moreinput();
	}
	return 1;
}

run()	/* execute until EOF */
{
	setjmp(begin);
	signal(SIGINT, intcatch);
	signal(SIGFPE, fpecatch);
	for (initcode(); yyparse(); initcode())
		execute(progbase);
}

warning(s, t)	/* print warning message */
	char *s, *t;
{
	fprintf(stderr, "%s: %s", progname, s);
	if (t)
		fprintf(stderr, " %s", t);
	if (infile)
		fprintf(stderr, " in %s", infile);
	fprintf(stderr, " near line %d\n", lineno);
	while (c != '\n' && c != EOF)
		if((c = getc(fin)) == '\n')	/* flush rest of input line */
			lineno++;
		else if (c == EOF && errno == EINTR) {
			clearerr(stdin);	/* ick! */
			errno = 0;
		}
}
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 81
# define YYLAST 589
short yyact[]={

   2,  55, 156,  51, 126,  86,  85, 131,   5,  63,
  52,  53,  40, 153, 136,  39, 116, 157, 148, 152,
  37, 144, 117,  39, 142,  38, 141, 140,  37,  35,
  23,  36,  39,  38, 122,  24, 130,  37,  35, 139,
  36, 143,  38, 137, 144, 135, 129, 125, 115,  81,
  80,  77,  76,  75,  71,  49,  33,  39,  32,  31,
  50, 128,  37,  35,  23,  36,  70,  38,   4,  24,
  54, 102,  40, 101,   3,  79,   1,  17,  16,  15,
  40,  78,  72,   0,   0,   0,   0, 123,   0,  40,
   0,   0,   0,   0,   0,   0,   0,   0,  23, 119,
 120,   0,   0,  24,   0,   0,   0,   0,   0,   0,
   0,   0,   0,  18,  40,   0,   0,  23,   0,   0,
   0,  34,  24,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0, 138,   0,   0,  23,   0,   0,   0,
   0,  24,   0,   0, 145,   0, 147,  18,  39, 121,
 149, 150,   0,  37,  35,  23,  36,   0,  38, 146,
  24,   0,   0,   0,  39, 158, 159, 154,   0,  37,
  35,   0,  36,   0,  38,   0, 155,  39, 160, 161,
   0,  18,  37,  35,  39,  36,   0,  38,   0,  37,
  35,   0,  36,   0,  38,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,  40,   0,   0,   0,   0,
   0,   0,   0,   0,  56,  57,  58,  59,  60,   0,
   0,  40,  64,  65,  66,  67,  68,   0,   0,  61,
  62,   0,   0,   0,  40,   0,   0,   0,   0,   0,
   0,  40,   0,   0,   0,   0,   7,  19,   0,  14,
  10,  22,   0,  28,  29,  30,   0,  20,  13,  12,
   8,   9,  21,  11,   0,  48,  47,  41,  42,  43,
  44,  45,  46,   0,   0,   0,   0,   0,  25,  26,
  27,  19,   0,  14,  10,  22,   0,  28,  29,  30,
   0,  20,  13,  12,   0,   0,  21,  11,   0,  48,
  47,  41,  42,  43,  44,  45,  46,   0,   0,   0,
   0,   0,  25,  26,  27,  19,   0,  14,  10,  22,
   0,  28,  29,  30,   0,  20,  13,  12,   0,   0,
  21,  11,   0,   0,  19, 134,   0,  10,  22,   0,
   0,   0,   0,   0,  20,   0,  25,  26,  27,  21,
  11,   0,   0,  19,  74,   0,  10,  22,   0,   0,
   0,   0,   0,  20,   0,  25,  26,  27,  21,  11,
   0,   0,  19,   0,   0,  10,  22,   0,   0,   0,
   0,   0,  20,   0,  25,  26,  27,  21,  11,   0,
  48,  47,  41,  42,  43,  44,  45,  46,   0,   0,
   0,   0,   0,  25,  26,  27,  48,  47,  41,  42,
  43,  44,  45,  46,   0,   0,   0,   0,   0,   0,
  47,  41,  42,  43,  44,  45,  46,   0,  41,  42,
  43,  44,  45,  46, 124,   0,   6,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  69,   0,  73,
   0,   0,   0,   0,   0,   0,   0,   0,  82,  83,
  84,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  87,  88,  89,  90,  91,  92,  93,  94,  95,  96,
  97,  98,  99, 100,   0,   0,   0,   0,   0,   0,
 103, 104, 105, 106, 107, 108,   0,   0, 109, 110,
 111, 112, 113, 114,   0,   0,   0,   0,   0,   0,
 118, 118, 118,   0,   0,   0, 127,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
 132, 133,   0,   0,   0,   0,   0,   0,   0,   0,
 132,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 118,   0,   0,   0,   0,   0,   0,   0, 151,
   0,   0,   0,   0,   0,   0,   0,   0, 118 };
short yypact[]={

-1000, -10,-1000,  49,  48,  46, 111,  45,-257,-257,
 -60, -52, 115,-1000,  96,  13,  12,  11,-1000,-1000,
-1000,  10,   9, 115, 115, 115,-254,-255,-1000,-1000,
-1000,-1000,-1000,-1000,-1000, 115, 115, 115, 115, 115,
 115, 115, 115, 115, 115, 115, 115, 115, 115,-1000,
-1000,-1000,-1000,-1000,-1000, 115, 115, 115, 115, 115,
 115,-1000,-1000, 115, 115, 115, 115, 115, 115, 127,
-1000,   8, -28, 127,-1000, 115, 115, 115,  24,   7,
-256, 115,  20, -82, -82,-1000,-1000, -22, -22, -82,
 -82, -82, -82,  -5,  -5,  -5,  -5,  -5,  -5, 147,
 140,   6,  -4, 127, 127, 127, 127, 127, 127, 127,
 127, 127, 127, 127, 127, 115,  77,   4, 127, -45,
   2,-1000,-1000,-1000, 127, 115,  -2, -14,-1000, -15,
 -17,   0, 127, 127,-1000,  58, 115,  58, -23,-1000,
-1000,  58,  58,-1000, 115,-1000, -46,-1000,-1000,-1000,
-1000, 127,-1000, 115,-264, -24,  58,  58,-1000,-1000,
-1000,-1000 };
short yypgo[]={

   0, 434,   8,  66,  82,  81,  22,  79,  78,  77,
  54,  19,  60,   7,  76,  74,  73,  71 };
short yyr1[]={

   0,  14,  14,  14,  14,  14,  14,  14,   3,   3,
   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   6,   7,   8,   9,  10,  11,   5,   5,   5,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   4,   4,   4,
   4,  16,  15,  17,  15,  12,  12,  12,  13,  13,
  13 };
short yyr2[]={

   0,   0,   2,   3,   3,   3,   3,   3,   3,   3,
   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,
   1,   1,   2,   5,   2,   6,  10,   6,   9,   3,
   1,   1,   1,   1,   0,   0,   0,   2,   2,   1,
   1,   1,   1,   5,   4,   4,   3,   3,   3,   3,
   3,   3,   3,   2,   3,   3,   3,   3,   3,   3,
   3,   3,   2,   2,   2,   2,   2,   1,   1,   3,
   3,   0,   6,   0,   6,   1,   1,   1,   0,   1,
   3 };
short yychk[]={

-1000, -14,  10, -15,  -3,  -2,  -1, 256, 270, 271,
 260, 273, 269, 268, 259,  -7,  -8,  -9, 123, 257,
 267, 272, 261,  40,  45, 288, 289, 290, 263, 264,
 265,  10,  10,  10,  10,  43,  45,  42,  47,  37,
  94, 281, 282, 283, 284, 285, 286, 280, 279,  10,
 -12, 260, 267, 268, -12,  61, 274, 275, 276, 277,
 278, 289, 290,  61, 274, 275, 276, 277, 278,  -1,
  -3, -10,  -4,  -1, 258,  40,  40,  40,  -5, -10,
  40,  40,  -1,  -1,  -1, 260, 260,  -1,  -1,  -1,
  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
  -1, -16, -17,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
  -1,  -1,  -1,  -1,  -1,  40,  44,  -6,  -1,  -6,
  -6, 125,  10,  -2,  -1,  40, 260,  -1,  41,  40,
  40, -13,  -1,  -1, 258,  41,  59,  41, -13,  41,
  41,  41,  41,  41,  44,  -2,  -6,  -2,  41,  -2,
  -2,  -1, -11,  59, -11,  -6, 266,  41,  -2,  -2,
 -11, -11 };
short yydef[]={

   1,  -2,   2,   0,  42,   0,   0,   0,   0,   0,
  40,  41,  21,  34,   0,   0,   0,   0,  36,  39,
  34,   0,   0,   0,   0,   0,   0,   0,  31,  32,
  33,   3,   4,   5,   6,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   7,
  71,  75,  76,  77,  73,   0,   0,   0,   0,   0,
   0,  65,  66,   0,   0,   0,   0,   0,   0,  22,
  42,   0,  24,  67,  68,   0,   0,   0,   0,   0,
   0,   0,   0,  53,  62,  63,  64,  47,  48,  49,
  50,  51,  52,  54,  55,  56,  57,  58,  59,  60,
  61,   0,   0,   8,   9,  10,  11,  12,  13,  14,
  15,  16,  17,  18,  19,  78,   0,   0,  30,   0,
   0,  29,  37,  38,  20,  78,   0,   0,  46,   0,
   0,   0,  79,  69,  70,   0,   0,   0,   0,  44,
  45,   0,   0,  23,   0,  35,   0,  35,  43,  72,
  74,  80,  25,   0,  27,   0,   0,   0,  35,  35,
  28,  26 };
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
		
case 4:
# line 30 "hoc.y"
{ code2(xpop, STOP); return 1; } break;
case 5:
# line 31 "hoc.y"
{ code(STOP); return 1; } break;
case 6:
# line 32 "hoc.y"
{ code2(print, STOP); return 1; } break;
case 7:
# line 33 "hoc.y"
{ yyerrok; } break;
case 8:
# line 35 "hoc.y"
{ code3(varpush,(Inst)yypvt[-2].sym,assign); yyval.inst=yypvt[-0].inst; } break;
case 9:
# line 36 "hoc.y"
{ code3(varpush,(Inst)yypvt[-2].sym,addeq); yyval.inst=yypvt[-0].inst; } break;
case 10:
# line 37 "hoc.y"
{ code3(varpush,(Inst)yypvt[-2].sym,subeq); yyval.inst=yypvt[-0].inst; } break;
case 11:
# line 38 "hoc.y"
{ code3(varpush,(Inst)yypvt[-2].sym,muleq); yyval.inst=yypvt[-0].inst; } break;
case 12:
# line 39 "hoc.y"
{ code3(varpush,(Inst)yypvt[-2].sym,diveq); yyval.inst=yypvt[-0].inst; } break;
case 13:
# line 40 "hoc.y"
{ code3(varpush,(Inst)yypvt[-2].sym,modeq); yyval.inst=yypvt[-0].inst; } break;
case 14:
# line 41 "hoc.y"
{ defnonly("$"); code2(argassign,(Inst)yypvt[-2].narg); yyval.inst=yypvt[-0].inst;} break;
case 15:
# line 42 "hoc.y"
{ defnonly("$"); code2(argaddeq,(Inst)yypvt[-2].narg); yyval.inst=yypvt[-0].inst;} break;
case 16:
# line 43 "hoc.y"
{ defnonly("$"); code2(argsubeq,(Inst)yypvt[-2].narg); yyval.inst=yypvt[-0].inst;} break;
case 17:
# line 44 "hoc.y"
{ defnonly("$"); code2(argmuleq,(Inst)yypvt[-2].narg); yyval.inst=yypvt[-0].inst;} break;
case 18:
# line 45 "hoc.y"
{ defnonly("$"); code2(argdiveq,(Inst)yypvt[-2].narg); yyval.inst=yypvt[-0].inst;} break;
case 19:
# line 46 "hoc.y"
{ defnonly("$"); code2(argmodeq,(Inst)yypvt[-2].narg); yyval.inst=yypvt[-0].inst;} break;
case 20:
# line 48 "hoc.y"
{ code(xpop); } break;
case 21:
# line 49 "hoc.y"
{ defnonly("return"); code(procret); } break;
case 22:
# line 51 "hoc.y"
{ defnonly("return"); yyval.inst=yypvt[-0].inst; code(funcret); } break;
case 23:
# line 53 "hoc.y"
{ yyval.inst = yypvt[-3].inst; code3(call, (Inst)yypvt[-4].sym, (Inst)yypvt[-1].narg); } break;
case 24:
# line 54 "hoc.y"
{ yyval.inst = yypvt[-0].inst; } break;
case 25:
# line 55 "hoc.y"
{
		(yypvt[-5].inst)[1] = (Inst)yypvt[-1].inst;	/* body of loop */
		(yypvt[-5].inst)[2] = (Inst)yypvt[-0].inst; } break;
case 26:
# line 58 "hoc.y"
{
		(yypvt[-9].inst)[1] = (Inst)yypvt[-5].inst;	/* condition */
		(yypvt[-9].inst)[2] = (Inst)yypvt[-3].inst;	/* post loop */
		(yypvt[-9].inst)[3] = (Inst)yypvt[-1].inst;	/* body of loop */
		(yypvt[-9].inst)[4] = (Inst)yypvt[-0].inst; } break;
case 27:
# line 63 "hoc.y"
{	/* else-less if */
		(yypvt[-5].inst)[1] = (Inst)yypvt[-1].inst;	/* thenpart */
		(yypvt[-5].inst)[3] = (Inst)yypvt[-0].inst; } break;
case 28:
# line 66 "hoc.y"
{	/* if with else */
		(yypvt[-8].inst)[1] = (Inst)yypvt[-4].inst;	/* thenpart */
		(yypvt[-8].inst)[2] = (Inst)yypvt[-1].inst;	/* elsepart */
		(yypvt[-8].inst)[3] = (Inst)yypvt[-0].inst; } break;
case 29:
# line 70 "hoc.y"
{ yyval.inst = yypvt[-1].inst; } break;
case 30:
# line 72 "hoc.y"
{ code(STOP); } break;
case 31:
# line 74 "hoc.y"
{ yyval.inst = code3(whilecode,STOP,STOP); } break;
case 32:
# line 76 "hoc.y"
{ yyval.inst = code(forcode); code3(STOP,STOP,STOP); code(STOP); } break;
case 33:
# line 78 "hoc.y"
{ yyval.inst = code(ifcode); code3(STOP,STOP,STOP); } break;
case 34:
# line 80 "hoc.y"
{ yyval.inst = progp; } break;
case 35:
# line 82 "hoc.y"
{ code(STOP); yyval.inst = progp; } break;
case 36:
# line 84 "hoc.y"
{ yyval.inst = progp; } break;
case 39:
# line 88 "hoc.y"
{ yyval.inst = code2(constpush, (Inst)yypvt[-0].sym); } break;
case 40:
# line 89 "hoc.y"
{ yyval.inst = code3(varpush, (Inst)yypvt[-0].sym, eval); } break;
case 41:
# line 90 "hoc.y"
{ defnonly("$"); yyval.inst = code2(arg, (Inst)yypvt[-0].narg); } break;
case 43:
# line 93 "hoc.y"
{ yyval.inst = yypvt[-3].inst; code3(call,(Inst)yypvt[-4].sym,(Inst)yypvt[-1].narg); } break;
case 44:
# line 94 "hoc.y"
{ yyval.inst = code2(varread, (Inst)yypvt[-1].sym); } break;
case 45:
# line 95 "hoc.y"
{ yyval.inst=yypvt[-1].inst; code2(bltin, (Inst)yypvt[-3].sym->u.ptr); } break;
case 46:
# line 96 "hoc.y"
{ yyval.inst = yypvt[-1].inst; } break;
case 47:
# line 97 "hoc.y"
{ code(add); } break;
case 48:
# line 98 "hoc.y"
{ code(sub); } break;
case 49:
# line 99 "hoc.y"
{ code(mul); } break;
case 50:
# line 100 "hoc.y"
{ code(div); } break;
case 51:
# line 101 "hoc.y"
{ code(mod); } break;
case 52:
# line 102 "hoc.y"
{ code (power); } break;
case 53:
# line 103 "hoc.y"
{ yyval.inst=yypvt[-0].inst; code(negate); } break;
case 54:
# line 104 "hoc.y"
{ code(gt); } break;
case 55:
# line 105 "hoc.y"
{ code(ge); } break;
case 56:
# line 106 "hoc.y"
{ code(lt); } break;
case 57:
# line 107 "hoc.y"
{ code(le); } break;
case 58:
# line 108 "hoc.y"
{ code(eq); } break;
case 59:
# line 109 "hoc.y"
{ code(ne); } break;
case 60:
# line 110 "hoc.y"
{ code(and); } break;
case 61:
# line 111 "hoc.y"
{ code(or); } break;
case 62:
# line 112 "hoc.y"
{ yyval.inst = yypvt[-0].inst; code(not); } break;
case 63:
# line 113 "hoc.y"
{ yyval.inst = code2(preinc,(Inst)yypvt[-0].sym); } break;
case 64:
# line 114 "hoc.y"
{ yyval.inst = code2(predec,(Inst)yypvt[-0].sym); } break;
case 65:
# line 115 "hoc.y"
{ yyval.inst = code2(postinc,(Inst)yypvt[-1].sym); } break;
case 66:
# line 116 "hoc.y"
{ yyval.inst = code2(postdec,(Inst)yypvt[-1].sym); } break;
case 67:
# line 118 "hoc.y"
{ code(prexpr); } break;
case 68:
# line 119 "hoc.y"
{ yyval.inst = code2(prstr, (Inst)yypvt[-0].sym); } break;
case 69:
# line 120 "hoc.y"
{ code(prexpr); } break;
case 70:
# line 121 "hoc.y"
{ code2(prstr, (Inst)yypvt[-0].sym); } break;
case 71:
# line 123 "hoc.y"
{ yypvt[-0].sym->type=FUNCTION; indef=1; } break;
case 72:
# line 124 "hoc.y"
{ code(procret); define(yypvt[-4].sym); indef=0; } break;
case 73:
# line 125 "hoc.y"
{ yypvt[-0].sym->type=PROCEDURE; indef=1; } break;
case 74:
# line 126 "hoc.y"
{ code(procret); define(yypvt[-4].sym); indef=0; } break;
case 78:
# line 132 "hoc.y"
{ yyval.narg = 0; } break;
case 79:
# line 133 "hoc.y"
{ yyval.narg = 1; } break;
case 80:
# line 134 "hoc.y"
{ yyval.narg = yypvt[-2].narg + 1; } break;
	}
	goto yystack;  /* stack new state and value */
}
