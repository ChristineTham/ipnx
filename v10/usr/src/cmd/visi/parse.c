
# line 2 "parse.y"
/*
 *      parse.y 1.7
 *
 *	Parser Description File for Spreadsheet Program `vis'
 *
 *      A. F. Gettier
 *      Bell Laboratories
 *      Update made 11/15/82 10:51:06
 *      Retrieved 11/15/82 13:22:37
 */

#include	<stdio.h>
#include	<math.h>
#include	"curses.h"
#include	"vis.h"

extern struct qheader	Fixup;

int	Inrow, Incol;

# line 25 "parse.y"
typedef union  {
	char	*sval;
	double	dval;
	int	ival;
	struct vdef	vval;
	struct node	nval;
	struct range	rval;
	struct colstat  cval;
} YYSTYPE;
# define EXPON 257
# define UMINUS 258
# define PI 259
# define ABS 260
# define ACOS 261
# define ASIN 262
# define ATAN 263
# define ATAN2 264
# define COS 265
# define EXP 266
# define GAMMA 267
# define HYPOT 268
# define INT 269
# define LOG 270
# define POW 271
# define SIN 272
# define SQRT 273
# define COL 274
# define DUP 275
# define DUPLICATE 276
# define EDIT 277
# define POSITION 278
# define REDRAW 279
# define REFRESH 280
# define REP 281
# define REPLICATE 282
# define ROW 283
# define SCALE 284
# define SHIFT 285
# define SLIDE 286
# define SHELL 287
# define SH 288
# define WIDTH 289
# define QUIT 290
# define TERM 291
# define LIST 292
# define ERROR 293
# define ZERO 294
# define THRU 295
# define AT 296
# define DEBUG 297
# define VER 298
# define UP 299
# define DOWN 300
# define LEFT 301
# define RIGHT 302
# define HELP 303
# define STR 304
# define LETTERS 305
# define READ 306
# define WRITE 307
# define COPY 308
# define NUMBER 309
# define FUNC 310
# define AVARIABLE 311
# define VARIABLE 312
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 540 "parse.y"


char *
getfn()
{
	static char	chrbuf[64];
	char		*tbuf;
	move( 22, 0 );
	printw("Enter File Name:  " );
	refresh();


	tbuf = chrbuf;
	loop {
		*tbuf = getch();
		addch( *tbuf );
		refresh();
		if ( *(tbuf++) == '\n' ) break;
	}
	 *(--tbuf) = '\0';

	return( chrbuf );
}

colval( string )
char	*string;
{
	int	i;
	i = -1;
	while ( *string != '\0' ) {
		i = (i + 1) * 26 + *string - 'A';
		string++;
	}
	return( i );
}
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 52
# define YYLAST 315
short yyact[]={

  25,  57,  30,  90,  59,  89,  58,  88,  40,  39,
  43,  73,  75,  71,  42,  45,  46,  47,  48,   7,
   6,   8,  70,  13,  14,  16,  15,  69,  17,  18,
  76,  20,  19,  22,  11,  67,  10,  68,  24, 106,
 105,   5,  21,  80,  78, 104,  79,   9,  81, 103,
  12,  23,   4,  94,  93,   3,  72,  55,  54,  53,
  51,  50,  49,  38,  37,  36,  35,  34,  33,  32,
  28,  27, 107,  80,  78, 108,  79,  82,  81,  80,
  78,  56,  79,  80,  81, 112,  80,  78,  81,  79,
  87,  81,  80,  78, 109,  79,  26,  81, 100,  80,
  78,  29,  79,  86,  81,  41,   2,  44,  74,  31,
   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  52,   0,
 113,   0,   0,   0,   0,   0,   0,   0,   0,  83,
  84,  85,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  95,  96,  97,  98,  99,   0,   0,   0, 101, 102,
   0,   0,  91,  92,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
 110, 111,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,  62,   0,   0,   0,  61,
   0,   0,   0,   0,  63,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  82,   0,
   0,   0,   0,   0,   0,  65,   0,   0,   0,   0,
  66,  60,   0,  64,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  82,   0,
   0,   0,  77,   0,  82,   0,   0,   0,  82,   0,
   0,  82,   0,   0,   0,   0,   0,  82,   0,   0,
   0,   0,   0,   0,  82 };
short yypact[]={

-1000,-256,-1000,  35,-220,-221,-310,-310,-222,-223,
-224,-225,-226,-227,-228,-303,-304,-295,-284,-229,
-230,-231,-295,-232,-233,-234, -39,-1000,-1000,-261,
-258,-269,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-274,
-283,-1000,-235,-298,-279,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,   1, -39, -39, -39,
  63,  -1,-1000,-1000,-1000,-1000,-1000,-305,-307,-309,
-310,-310,-1000,-237,-1000,-1000,-238,-1000, -39, -39,
 -39, -39, -39,  57,-1000,-1000, -39, -39,-242,-1000,
-246,-251,-252,-1000,-1000,  41,  41,-180,-180,-1000,
-1000,  31,  50,-1000,-1000,-1000,-1000,-1000, -39, -39,
  44,  37,-1000,-1000 };
short yypgo[]={

   0, 110, 108, 107,  81, 101, 105, 106 };
short yyr1[]={

   0,   1,   1,   7,   7,   7,   7,   7,   7,   7,
   7,   7,   7,   7,   7,   7,   7,   7,   7,   7,
   7,   7,   7,   7,   7,   7,   4,   4,   4,   4,
   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,
   4,   4,   5,   5,   3,   3,   3,   3,   2,   2,
   6,   6 };
short yyr2[]={

   0,   0,   2,   4,   2,   2,   5,   5,   2,   2,
   2,   2,   2,   2,   2,   5,   5,   2,   3,   2,
   2,   2,   2,   2,   2,   2,   3,   3,   3,   3,
   3,   3,   2,   2,   4,   6,   6,   1,   1,   1,
   1,   1,   3,   1,   1,   1,   1,   1,   1,   2,
   2,   3 };
short yychk[]={

-1000,  -1,  -7, 311, 308, 297, 276, 275, 277, 303,
 292, 290, 306, 279, 280, 282, 281, 284, 285, 288,
 287, 298, 289, 307, 294, 256,  61, 291, 291,  -5,
 312,  -5, 291, 291, 291, 291, 291, 291, 291, 312,
 312,  -6, 309, 305,  -3, 299, 300, 301, 302, 291,
 291, 291,  -6, 291, 291, 291,  -4,  40,  45,  43,
 310, 278, 274, 283, 312, 304, 309, 296, 295, 296,
 296, 296, 291, 309,  -2, 291, 309, 291,  43,  45,
  42,  47, 257,  -4,  -4,  -4,  40,  91, 312, 312,
 312,  -5,  -5, 291, 291,  -4,  -4,  -4,  -4,  -4,
  41,  -4,  -4, 291, 291, 291, 291,  41,  44,  44,
  -4,  -4,  41,  93 };
short yydef[]={

   1,  -2,   2,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   4,   5,   0,
  43,   0,   8,   9,  10,  11,  12,  13,  14,   0,
   0,  17,   0,   0,   0,  44,  45,  46,  47,  19,
  20,  21,  22,  23,  24,  25,   0,   0,   0,   0,
   0,   0,  37,  38,  39,  40,  41,   0,   0,   0,
   0,   0,  50,   0,  18,  48,   0,   3,   0,   0,
   0,   0,   0,   0,  32,  33,   0,   0,   0,  42,
   0,   0,   0,  51,  49,  27,  28,  29,  30,  31,
  26,   0,   0,   6,   7,  15,  16,  34,   0,   0,
   0,   0,  35,  36 };
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
# line 63 "parse.y"
{
		struct node	*nt;
		/*
		 *	Get the Target Node
		 */
		nt = getnode( yypvt[-3].vval.row, yypvt[-3].vval.col );
		/*
		 *	Assign the String
		 */
		if ( nt->def != 0 )
			free( nt->def );
		nt->def = yypvt[-3].vval.tval;
		/*
		 *	Was the Old Value a String?
		 */
		if ( nt->type == STRING ) {
			free( nt->svalue );
			nt->svalue = 0;
		}
		/*
		 *	Do the assignment
		 */
		switch ( yypvt[-1].nval.type ) {
		case NUM:
			if ( nt->type != NUM || nt->value != yypvt[-1].nval.value ) {
				struct qheader	*y;
				struct node	*x;
				y = qcopy( &(nt->depend) );
				while ( (x=qread( y ) ) != 0 )
					qadd( &Fixup, x );
				nt->value = yypvt[-1].nval.value;
				free( (char *)y );
			}
			nt->type = yypvt[-1].nval.type;
			break;
			
		case STRING:
			nt->svalue = yypvt[-1].nval.svalue;
			nt->type = yypvt[-1].nval.type;
			break;
		default:
			nt->type = UNRES;
		}
		prnode( nt );
	    } break;
case 4:
# line 109 "parse.y"
{
		FILE	*fp;
		char	*fn;
		if ( yypvt[-1].sval == 0 )
			fn = getfn();
		else
			fn = yypvt[-1].sval;
		if ( (fp=fopen( fn, "w" )) == 0 ) {
			char	errbuf[64];
			(void)sprintf( errbuf, "Cannot open '%s'", fn );
			yyerror( errbuf );
			lexinit();
		}
		else {
			move( LINES-2, 0 );
			printw( "Copying Screen Image to File '%s'", fn );
			clrtoeol();
			refresh();
			copyfile( fp );
			(void)fclose( fp );
		}
	    } break;
case 5:
# line 132 "parse.y"
{
/*
		yydebug = 1 - yydebug;
*/
	    } break;
case 6:
# line 138 "parse.y"
{
		duplicate( yypvt[-3].rval.fromrow, yypvt[-3].rval.fromcol, yypvt[-3].rval.torow, yypvt[-3].rval.tocol,
		    yypvt[-1].nval.row, yypvt[-1].nval.col );
	    } break;
case 7:
# line 143 "parse.y"
{
		duplicate( yypvt[-3].rval.fromrow, yypvt[-3].rval.fromcol, yypvt[-3].rval.torow, yypvt[-3].rval.tocol,
		    yypvt[-1].nval.row, yypvt[-1].nval.col );
	    } break;
case 8:
# line 148 "parse.y"
{
		editfile();
	    } break;
case 9:
# line 152 "parse.y"
{
		listhelp();
	    } break;
case 10:
# line 156 "parse.y"
{
		listfile();
	    } break;
case 11:
# line 160 "parse.y"
{
		quit();
	    } break;
case 12:
# line 164 "parse.y"
{
		FILE	*fp;
		char	*fn;
		if ( yypvt[-1].sval == 0 )
			fn = getfn();
		else
			fn = yypvt[-1].sval;
		if ( (fp=fopen( fn, "r" )) == 0 ) {
			char	errbuf[64];
			(void)sprintf( errbuf, "Cannot open '%s'", fn );
			yyerror( errbuf );
			lexinit();
		}
		else {
			move( LINES-2, 0 );
			printw( "Reading from File '%s'", fn );
			clrtoeol();
			refresh();
			readfile( fp );
		}
	    } break;
case 13:
# line 186 "parse.y"
{
		wrefresh( curscr );
	    } break;
case 14:
# line 190 "parse.y"
{
		wrefresh( curscr );
	    } break;
case 15:
# line 194 "parse.y"
{
		replicate( yypvt[-3].nval.row, yypvt[-3].nval.col, yypvt[-1].rval.fromrow, yypvt[-1].rval.fromcol, yypvt[-1].rval.torow,
		    yypvt[-1].rval.tocol );
	    } break;
case 16:
# line 199 "parse.y"
{
		replicate( yypvt[-3].nval.row, yypvt[-3].nval.col, yypvt[-1].rval.fromrow, yypvt[-1].rval.fromcol, yypvt[-1].rval.torow,
		    yypvt[-1].rval.tocol );
	    } break;
case 17:
# line 204 "parse.y"
{
		if ( yypvt[-0].cval.colnum < 0 )
			setscale( yypvt[-0].cval.number );
		else
			isetscale( yypvt[-0].cval.colnum, yypvt[-0].cval.number );
	    } break;
case 18:
# line 211 "parse.y"
{
		switch( yypvt[-1].ival ) {
		case 1:
			scrup( yypvt[-0].ival );
			break;
		case 2:
			scrdown( yypvt[-0].ival );
			break;
		case 3:
			scrleft( yypvt[-0].ival );
			break;
		case 4:
			scrright( yypvt[-0].ival );
		}
	    } break;
case 19:
# line 227 "parse.y"
{
		move( LINES-1, 0 );
		clrtoeol();
		refresh();
		resetty();
		(void)system( "/bin/sh" );
		noecho();
		crmode();
		wrefresh( curscr );
	    } break;
case 20:
# line 238 "parse.y"
{
		move( LINES-1, 0 );
		clrtoeol();
		refresh();
		resetty();
		(void)system( "/bin/sh" );
		noecho();
		crmode();
		wrefresh( curscr );
	    } break;
case 21:
# line 249 "parse.y"
{
		yyerror("VIS 1.7 11/15/82");
	    } break;
case 22:
# line 253 "parse.y"
{
		if ( yypvt[-0].cval.colnum < 0 )
			setwidth( yypvt[-0].cval.number );
		else
			isetwidth( yypvt[-0].cval.colnum, yypvt[-0].cval.number );
	    } break;
case 23:
# line 260 "parse.y"
{
		FILE	*fp;
		char	*fn;
		if ( yypvt[-1].sval == 0 )
			fn = getfn();
		else
			fn = yypvt[-1].sval;
		if ( (fp=fopen( fn, "w" )) == 0 ) {
			char	errbuf[64];
			(void)sprintf( errbuf, "Cannot open '%s'", fn );
			yyerror( errbuf );
			lexinit();
		}
		else {
			move( LINES-2, 0 );
			printw( "Writing to File '%s'", fn );
			clrtoeol();
			refresh();

			dumpfile( fp );

			(void)fclose( fp );
		}
	    } break;
case 24:
# line 285 "parse.y"
{
		/*
		 *	zero out the current definitions
		 */
		zerodef();
		zeroscreen();
	    } break;
case 26:
# line 295 "parse.y"
{
		yyval.nval = yypvt[-1].nval;
	    } break;
case 27:
# line 299 "parse.y"
{
		yyval.nval = mathop( &(yypvt[-2].nval), &(yypvt[-0].nval) );
		if ( yyval.nval.type == NUM )  yyval.nval.value = yypvt[-2].nval.value + yypvt[-0].nval.value;
	    } break;
case 28:
# line 304 "parse.y"
{
		yyval.nval = mathop( &(yypvt[-2].nval), &(yypvt[-0].nval) );
		if ( yyval.nval.type == NUM )  yyval.nval.value = yypvt[-2].nval.value - yypvt[-0].nval.value;
	    } break;
case 29:
# line 309 "parse.y"
{
		yyval.nval = mathop( &(yypvt[-2].nval), &(yypvt[-0].nval) );
		if ( yyval.nval.type == NUM )  yyval.nval.value = yypvt[-2].nval.value * yypvt[-0].nval.value;
	    } break;
case 30:
# line 314 "parse.y"
{
		yyval.nval = mathop( &(yypvt[-2].nval), &(yypvt[-0].nval) );
		if ( yyval.nval.type == NUM ) {
			if ( yypvt[-0].nval.value == 0 ) yyval.nval.value = BIG;
			else yyval.nval.value = yypvt[-2].nval.value / yypvt[-0].nval.value;
		}
	    } break;
case 31:
# line 322 "parse.y"
{
		yyval.nval = mathop( &(yypvt[-2].nval), &(yypvt[-0].nval) );
		if ( yyval.nval.type == NUM )  yyval.nval.value = pow( yypvt[-2].nval.value, yypvt[-0].nval.value );
	    } break;
case 32:
# line 327 "parse.y"
{
		yyval.nval = yypvt[-0].nval;
		yyval.nval.value = - yypvt[-0].nval.value;
	    } break;
case 33:
# line 332 "parse.y"
{
		yyval.nval = yypvt[-0].nval;
	    } break;
case 34:
# line 336 "parse.y"
{
		double	xval;
		yyval.nval = mathop( &(yypvt[-1].nval), &(yypvt[-1].nval) );
		if ( yyval.nval.type == NUM ) {
			xval = yypvt[-1].nval.value;
			switch( yypvt[-3].ival ) {
			case ABS:
				if ( xval < 0 )  yyval.nval.value = -xval;
				else yyval.nval.value = xval;
				break;
			case ACOS:
				yyval.nval.value = acos( xval );
				break;
			case ASIN:
				yyval.nval.value = asin( xval );
				break;
			case ATAN:
				yyval.nval.value = atan( xval );
				break;
			case COS:
				yyval.nval.value = cos( xval );
				break;
			case EXP:
				yyval.nval.value = exp( xval );
				break;
			case GAMMA:
				yyval.nval.value = gamma( xval );
				break;
			case INT:
				yyval.nval.value = (double)((int)xval);
				break;
			case LOG:
				yyval.nval.value = log( xval );
				break;
			case SIN:
				yyval.nval.value = sin( xval );
				break;
			case SQRT:
				yyval.nval.value = sqrt( xval );
				break;
			default:
				lexinit();
				unput( '\n' );
				yyerror( "Incorrect Function Call" );
			}
		}
	    } break;
case 35:
# line 384 "parse.y"
{
		double	xval, yval;
		yyval.nval = mathop( &(yypvt[-3].nval), &(yypvt[-1].nval) );
		if ( yyval.nval.type == NUM ) {
			xval = yypvt[-3].nval.value;
			yval = yypvt[-1].nval.value;
			switch( yypvt[-5].ival ) {
			case ATAN2:
				yyval.nval.value = atan2( xval, yval );
				break;
			case HYPOT:
				yyval.nval.value = hypot( xval, yval );
				break;
			case POW:
				yyval.nval.value = pow( xval, yval );
				break;
			default:
				lexinit();
				unput( '\n' );
				yyerror( "Incorrect Function Call" );
			}
		}
	    } break;
case 36:
# line 408 "parse.y"
{
		struct node	*n;
		yyval.nval = mathop( &(yypvt[-3].nval), &(yypvt[-1].nval) );
		if ( yyval.nval.type == NUM ) {
			int	i, j;
			i = (int)yypvt[-3].nval.value-1;
			j = (int)yypvt[-1].nval.value-1;
			if ( i < 0 || j < 0 ) {
				char	bfr[128];
				lexinit();
				(void)sprintf( bfr,
				    "Illegal Request for Position[ %d, %d ]",
				    i+1, j+1 );
				yyerror( bfr );
				yyval.nval.type = UNDEF;
				unput( '\n' );
			}
			else {
				n = getnode( i, j );
				prnode( n );
				qadd( &(n->depend), getnode( Inrow, Incol ) );
				yyval.nval = *n;
				if ( yyval.nval.type == STRING )
					yyval.nval.svalue = copystr( yyval.nval.svalue );
				yyval.nval.row = -1;
				yyval.nval.col = -1;
			}
		}
		else
			yyval.nval.type = UNRES;
	    } break;
case 37:
# line 440 "parse.y"
{
		yyval.nval.svalue = 0;
		yyval.nval.def = 0;
		yyval.nval.type = NUM;
		yyval.nval.value = (float)(Incol + 1);
		yyval.nval.row = -1;
		yyval.nval.col = -1;
	    } break;
case 38:
# line 449 "parse.y"
{
		yyval.nval.svalue = 0;
		yyval.nval.def = 0;
		yyval.nval.type = NUM;
		yyval.nval.value = (float)(Inrow+1);
		yyval.nval.row = -1;
		yyval.nval.col = -1;
	    } break;
case 39:
# line 458 "parse.y"
{
		struct node	*x;
		x = getnode( yypvt[-0].nval.row, yypvt[-0].nval.col );
		yyval.nval = *x;
		/*  If it is a string, patch it up  */
		if ( x->type == STRING ) {
			yyval.nval.svalue = copystr( x->svalue );
			yyval.nval.row = yyval.nval.col = (-1);
		}
		/*  Mark The Screen That it is Undef  */
		if ( x->type == UNDEF )  prnode( x );
		/*  Set up the Dependency List  */
		(void)qadd( &(x->depend), getnode( Inrow, Incol ) );
	    } break;
case 40:
# line 473 "parse.y"
{
		yyval.nval.row = -1;
		yyval.nval.col = -1;
		yyval.nval.type = STRING;
		yyval.nval.svalue = yypvt[-0].sval;
	    } break;
case 41:
# line 480 "parse.y"
{
		yyval.nval.row = -1;
		yyval.nval.col = -1;
		yyval.nval.type = NUM;
		yyval.nval.value = yypvt[-0].dval;
		yyval.nval.svalue = 0;
		yyval.nval.def = 0;
	    } break;
case 42:
# line 490 "parse.y"
{
		yyval.rval.fromrow = yypvt[-2].nval.row;
		yyval.rval.fromcol = yypvt[-2].nval.col;
		yyval.rval.torow = yypvt[-0].nval.row;
		yyval.rval.tocol = yypvt[-0].nval.col;
	    } break;
case 43:
# line 497 "parse.y"
{
		yyval.rval.fromrow = yyval.rval.torow = yypvt[-0].nval.row;
		yyval.rval.fromcol = yyval.rval.tocol = yypvt[-0].nval.col;
	    } break;
case 44:
# line 503 "parse.y"
{
		yyval.ival = 1;
	    } break;
case 45:
# line 507 "parse.y"
{
		yyval.ival = 2;
	    } break;
case 46:
# line 511 "parse.y"
{
		yyval.ival = 3;
	    } break;
case 47:
# line 515 "parse.y"
{
		yyval.ival = 4;
	    } break;
case 48:
# line 520 "parse.y"
{
		yyval.ival = 1;
	    } break;
case 49:
# line 524 "parse.y"
{
		yyval.ival = (int)yypvt[-1].dval;
	    } break;
case 50:
# line 529 "parse.y"
{
		yyval.cval.colnum = -1;
		yyval.cval.number = (int)yypvt[-1].dval;
	    } break;
case 51:
# line 534 "parse.y"
{
		yyval.cval.colnum = colval( foldup( yypvt[-2].sval ) );
		yyval.cval.number = (int)yypvt[-1].dval;
		free( yypvt[-2].sval );
	    } break;
	}
	goto yystack;  /* stack new state and value */
}
