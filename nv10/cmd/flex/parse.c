# define CHAR 257
# define NUMBER 258
# define SECTEND 259
# define SCDECL 260
# define XSCDECL 261
# define WHITESPACE 262
# define NAME 263
# define PREVCCL 264
# define EOF_OP 265

# line 30 "parse.y"

#include "flexdef.h"

#ifndef lint

static char copyright[] =
    "@(#) Copyright (c) 1989 The Regents of the University of California.\n";
static char CR_continuation[] = "@(#) All rights reserved.\n";

static char rcsid[] =
    "@(#) $Header: parse.y,v 2.1 89/06/20 17:23:54 vern Exp $ (LBL)";

#endif

int pat, scnum, eps, headcnt, trailcnt, anyccl, lastchar, i, actvp, rulelen;
int trlcontxt, xcluflg, cclsorted, varlength, variable_trail_rule;
char clower();

static int madeany = false;  /* whether we've made the '.' character class */
int previous_continued_action;	/* whether the previous rule's action was '|' */

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

# line 595 "parse.y"



/* build_eof_action - build the "<<EOF>>" action for the active start
 *                    conditions
 */

build_eof_action()

    {
    register int i;

    for ( i = 1; i <= actvp; ++i )
	{
	if ( sceof[actvsc[i]] )
	    lerrsf( "multiple <<EOF>> rules for start condition %s",
		    scname[actvsc[i]] );

	else
	    {
	    sceof[actvsc[i]] = true;
	    fprintf( temp_action_file, "case YY_STATE_EOF(%s):\n",
		     scname[actvsc[i]] );
	    }
	}

    line_directive_out( temp_action_file );
    }


/* synerr - report a syntax error
 *
 * synopsis
 *    char str[];
 *    synerr( str );
 */

synerr( str )
char str[];

    {
    syntaxerror = true;
    fprintf( stderr, "Syntax error at line %d: %s\n", linenum, str );
    }


/* yyerror - eat up an error message from the parser
 *
 * synopsis
 *    char msg[];
 *    yyerror( msg );
 */

yyerror( msg )
char msg[];

    {
    }
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 2,
	259, 4,
	260, 4,
	261, 4,
	-2, 0,
-1, 13,
	0, 1,
	-2, 0,
	};
# define YYNPROD 53
# define YYLAST 258
short yyact[]={

  30,  73,  30,  58,  30,  34,  31,  12,  31,  79,
  31,  47,  27,  16,  27,  77,  27,  69,  46,  66,
  15,   7,   8,   9,  65,  80,  23,   4,  74,  44,
  68,  81,  57,  50,  51,  41,  43,  26,  64,  56,
  43,  76,  25,  36,  10,  20,  54,  28,  24,  45,
  18,  17,  14,   6,  52,  13,  63,  33,  11,  33,
  19,  33,  37,  49,  38,  40,   5,  48,   3,   2,
   1,   0,   0,   0,  60,   0,  61,  55,   0,   0,
   0,   0,   0,  59,   0,  62,  49,   0,   0,   0,
   0,   0,   0,   0,   0,  72,   0,  71,   0,   0,
  49,   0,   0,   0,   0,   0,   0,   0,   0,  75,
   0,   0,   0,  42,  53,   0,   0,  42,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,  70,
   0,  70,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,  22,  32,   0,  32,   0,  32,   0,   0,
  29,  21,  29,  39,  29,   0,   0,   0,   0,   0,
   0,   0,  67,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  35 };
short yypact[]={

-1000,-1000,-229,-238,  34,-1000,-255,-1000,-1000,-1000,
-1000,-1000,-243, -34,  -5,-1000,-1000,  33, -32, -30,
  -7,-1000,-1000,-245, -30, -30,  -9,-1000,-1000,-1000,
-1000, -30,-1000, -62,-1000,-260,-1000, -30,  -7,-1000,
  -7,-1000, -30,-1000,-1000,  -6,-1000,-1000, -30,  -9,
-1000,-1000,-1000,-234, -15, -11, -76,-1000,-1000,  -7,
-1000,-1000, -30,-1000,-262, -16,-1000,-1000,-1000,-1000,
  -4, -78,-1000,-1000,-116,-1000,-232,-1000, -94,-1000,
-1000,-1000 };
short yypgo[]={

   0,  70,  69,  68,  66,  58,  55,  53,  52,  51,
  50,  45,  35,  49,  42,  48,  37,  47,  46,  39 };
short yyr1[]={

   0,   1,   2,   3,   3,   3,   4,   7,   7,   8,
   8,   8,   5,   5,   6,   9,   9,   9,   9,   9,
   9,   9,  10,  13,  13,  13,  12,  12,  11,  11,
  11,  15,  14,  14,  16,  16,  16,  16,  16,  16,
  16,  16,  16,  16,  16,  16,  17,  17,  19,  19,
  19,  18,  18 };
short yyr2[]={

   0,   5,   0,   5,   0,   2,   1,   1,   1,   3,
   1,   1,   4,   0,   0,   4,   3,   3,   2,   2,
   1,   1,   3,   3,   1,   1,   1,   0,   3,   2,
   1,   2,   2,   1,   2,   2,   2,   6,   5,   4,
   1,   1,   1,   3,   3,   1,   3,   4,   4,   2,
   0,   2,   0 };
short yychk[]={

-1000,  -1,  -2,  -3, 256,  -4,  -7, 259, 260, 261,
  10,  -5, 262,  -6,  -8, 263, 256,  -9, -10,  94,
 -11, 265, 256,  60, -15, -14, -16,  46, -17, 264,
  34,  40, 257,  91,  10, 262,  10,  94, -11, 265,
 -11, -12, 124,  47,  36, -13, 263, 256, -14, -16,
  42,  43,  63, 123, -18, -11, -19,  94, 263, -11,
 -12, -12, -14,  62,  44, 258,  34, 257,  41,  93,
 257, -19, -12, 263,  44, 125,  45,  93, 258, 125,
 257, 125 };
short yydef[]={

   2,  -2,  -2,   0,   0,  13,   0,   6,   7,   8,
   5,  14,   0,  -2,   0,  10,  11,   0,   0,   0,
  27,  20,  21,   0,   0,  30,  33,  40,  41,  42,
  52,   0,  45,  50,   3,   0,  12,   0,  27,  19,
  27,  18,   0,  31,  26,   0,  24,  25,  29,  32,
  34,  35,  36,   0,   0,   0,   0,  50,   9,  27,
  16,  17,  28,  22,   0,   0,  43,  51,  44,  46,
  49,   0,  15,  23,   0,  39,   0,  47,   0,  38,
  48,  37 };
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
# line 55 "parse.y"
{ /* add default rule */
			int def_rule;

			pat = cclinit();
			cclnegate( pat );

			def_rule = mkstate( -pat );

			finish_rule( def_rule, false, 0, 0 );

			for ( i = 1; i <= lastsc; ++i )
			    scset[i] = mkbranch( scset[i], def_rule );

			if ( spprdflt )
			    fputs( "YY_FATAL_ERROR( \"flex scanner jammed\" )",
				   temp_action_file );
			else
			    fputs( "ECHO", temp_action_file );

			fputs( ";\n\tYY_BREAK\n", temp_action_file );
			} break;
case 2:
# line 79 "parse.y"
{
			/* initialize for processing rules */

			/* create default DFA start condition */
			scinstal( "INITIAL", false );
			} break;
case 5:
# line 90 "parse.y"
{ synerr( "unknown error processing section 1" ); } break;
case 7:
# line 97 "parse.y"
{
			/* these productions are separate from the s1object
			 * rule because the semantics must be done before
			 * we parse the remainder of an s1object
			 */

			xcluflg = false;
			} break;
case 8:
# line 107 "parse.y"
{ xcluflg = true; } break;
case 9:
# line 111 "parse.y"
{ scinstal( nmstr, xcluflg ); } break;
case 10:
# line 114 "parse.y"
{ scinstal( nmstr, xcluflg ); } break;
case 11:
# line 117 "parse.y"
{ synerr( "bad start condition list" ); } break;
case 14:
# line 125 "parse.y"
{
			/* initialize for a parse of one rule */
			trlcontxt = variable_trail_rule = varlength = false;
			trailcnt = headcnt = rulelen = 0;
			current_state_type = STATE_NORMAL;
			previous_continued_action = continued_action;
			new_rule();
			} break;
case 15:
# line 136 "parse.y"
{
			pat = link_machines( yypvt[-1], yypvt[-0] );
			finish_rule( pat, variable_trail_rule,
				     headcnt, trailcnt );

			for ( i = 1; i <= actvp; ++i )
			    scbol[actvsc[i]] =
				mkbranch( scbol[actvsc[i]], pat );

			if ( ! bol_needed )
			    {
			    bol_needed = true;

			    if ( performance_report )
				fprintf( stderr,
			"'^' operator results in sub-optimal performance\n" );
			    }
			} break;
case 16:
# line 156 "parse.y"
{
			pat = link_machines( yypvt[-1], yypvt[-0] );
			finish_rule( pat, variable_trail_rule,
				     headcnt, trailcnt );

			for ( i = 1; i <= actvp; ++i )
			    scset[actvsc[i]] = 
				mkbranch( scset[actvsc[i]], pat );
			} break;
case 17:
# line 167 "parse.y"
{
			pat = link_machines( yypvt[-1], yypvt[-0] );
			finish_rule( pat, variable_trail_rule,
				     headcnt, trailcnt );

			/* add to all non-exclusive start conditions,
			 * including the default (0) start condition
			 */

			for ( i = 1; i <= lastsc; ++i )
			    if ( ! scxclu[i] )
				scbol[i] = mkbranch( scbol[i], pat );

			if ( ! bol_needed )
			    {
			    bol_needed = true;

			    if ( performance_report )
				fprintf( stderr,
			"'^' operator results in sub-optimal performance\n" );
			    }
			} break;
case 18:
# line 191 "parse.y"
{
			pat = link_machines( yypvt[-1], yypvt[-0] );
			finish_rule( pat, variable_trail_rule,
				     headcnt, trailcnt );

			for ( i = 1; i <= lastsc; ++i )
			    if ( ! scxclu[i] )
				scset[i] = mkbranch( scset[i], pat );
			} break;
case 19:
# line 202 "parse.y"
{ build_eof_action(); } break;
case 20:
# line 205 "parse.y"
{
			/* this EOF applies only to the INITIAL start cond. */
			actvsc[actvp = 1] = 1;
			build_eof_action();
			} break;
case 21:
# line 212 "parse.y"
{ synerr( "unrecognized rule" ); } break;
case 23:
# line 219 "parse.y"
{
			if ( (scnum = sclookup( nmstr )) == 0 )
			    lerrsf( "undeclared start condition %s", nmstr );

			else
			    actvsc[++actvp] = scnum;
			} break;
case 24:
# line 228 "parse.y"
{
			if ( (scnum = sclookup( nmstr )) == 0 )
			    lerrsf( "undeclared start condition %s", nmstr );
			else
			    actvsc[actvp = 1] = scnum;
			} break;
case 25:
# line 236 "parse.y"
{ synerr( "bad start condition list" ); } break;
case 26:
# line 240 "parse.y"
{
			if ( trlcontxt )
			    {
			    synerr( "trailing context used twice" );
			    yyval = mkstate( SYM_EPSILON );
			    }
			else
			    {
			    trlcontxt = true;

			    if ( ! varlength )
				headcnt = rulelen;

			    ++rulelen;
			    trailcnt = 1;

			    eps = mkstate( SYM_EPSILON );
			    yyval = link_machines( eps, mkstate( '\n' ) );
			    }
			} break;
case 27:
# line 262 "parse.y"
{
		        yyval = mkstate( SYM_EPSILON );

			if ( trlcontxt )
			    {
			    if ( varlength && headcnt == 0 )
				/* both head and trail are variable-length */
				variable_trail_rule = true;
			    else
				trailcnt = rulelen;
			    }
		        } break;
case 28:
# line 277 "parse.y"
{
			varlength = true;

			yyval = mkor( yypvt[-2], yypvt[-0] );
			} break;
case 29:
# line 284 "parse.y"
{
			if ( transchar[lastst[yypvt[-0]]] != SYM_EPSILON )
			    /* provide final transition \now/ so it
			     * will be marked as a trailing context
			     * state
			     */
			    yypvt[-0] = link_machines( yypvt[-0], mkstate( SYM_EPSILON ) );

			mark_beginning_as_normal( yypvt[-0] );
			current_state_type = STATE_NORMAL;

			if ( previous_continued_action )
			    {
			    /* we need to treat this as variable trailing
			     * context so that the backup does not happen
			     * in the action but before the action switch
			     * statement.  If the backup happens in the
			     * action, then the rules "falling into" this
			     * one's action will *also* do the backup,
			     * erroneously.
			     */
			    if ( ! varlength || headcnt != 0 )
				{
				fprintf( stderr,
    "flex: warning - trailing context rule at line %d made variable because\n",
					 linenum );
				fprintf( stderr,
					 "      of preceding '|' action\n" );
				}

			    /* mark as variable */
			    varlength = true;
			    headcnt = 0;
			    }

			if ( varlength && headcnt == 0 )
			    { /* variable trailing context rule */
			    /* mark the first part of the rule as the accepting
			     * "head" part of a trailing context rule
			     */
			    /* by the way, we didn't do this at the beginning
			     * of this production because back then
			     * current_state_type was set up for a trail
			     * rule, and add_accept() can create a new
			     * state ...
			     */
			    add_accept( yypvt[-1], num_rules | YY_TRAILING_HEAD_MASK );
			    }

			yyval = link_machines( yypvt[-1], yypvt[-0] );
			} break;
case 30:
# line 337 "parse.y"
{ yyval = yypvt[-0]; } break;
case 31:
# line 342 "parse.y"
{
			/* this rule is separate from the others for "re" so
			 * that the reduction will occur before the trailing
			 * series is parsed
			 */

			if ( trlcontxt )
			    synerr( "trailing context used twice" );
			else
			    trlcontxt = true;

			if ( varlength )
			    /* we hope the trailing context is fixed-length */
			    varlength = false;
			else
			    headcnt = rulelen;

			rulelen = 0;

			current_state_type = STATE_TRAILING_CONTEXT;
			yyval = yypvt[-1];
			} break;
case 32:
# line 367 "parse.y"
{
			/* this is where concatenation of adjacent patterns
			 * gets done
			 */
			yyval = link_machines( yypvt[-1], yypvt[-0] );
			} break;
case 33:
# line 375 "parse.y"
{ yyval = yypvt[-0]; } break;
case 34:
# line 379 "parse.y"
{
			varlength = true;

			yyval = mkclos( yypvt[-1] );
			} break;
case 35:
# line 386 "parse.y"
{
			varlength = true;

			yyval = mkposcl( yypvt[-1] );
			} break;
case 36:
# line 393 "parse.y"
{
			varlength = true;

			yyval = mkopt( yypvt[-1] );
			} break;
case 37:
# line 400 "parse.y"
{
			varlength = true;

			if ( yypvt[-3] > yypvt[-1] || yypvt[-3] < 0 )
			    {
			    synerr( "bad iteration values" );
			    yyval = yypvt[-5];
			    }
			else
			    {
			    if ( yypvt[-3] == 0 )
				yyval = mkopt( mkrep( yypvt[-5], yypvt[-3], yypvt[-1] ) );
			    else
				yyval = mkrep( yypvt[-5], yypvt[-3], yypvt[-1] );
			    }
			} break;
case 38:
# line 418 "parse.y"
{
			varlength = true;

			if ( yypvt[-2] <= 0 )
			    {
			    synerr( "iteration value must be positive" );
			    yyval = yypvt[-4];
			    }

			else
			    yyval = mkrep( yypvt[-4], yypvt[-2], INFINITY );
			} break;
case 39:
# line 432 "parse.y"
{
			/* the singleton could be something like "(foo)",
			 * in which case we have no idea what its length
			 * is, so we punt here.
			 */
			varlength = true;

			if ( yypvt[-1] <= 0 )
			    {
			    synerr( "iteration value must be positive" );
			    yyval = yypvt[-3];
			    }

			else
			    yyval = link_machines( yypvt[-3], copysingl( yypvt[-3], yypvt[-1] - 1 ) );
			} break;
case 40:
# line 450 "parse.y"
{
			if ( ! madeany )
			    {
			    /* create the '.' character class */
			    anyccl = cclinit();
			    ccladd( anyccl, '\n' );
			    cclnegate( anyccl );

			    if ( useecs )
				mkeccl( ccltbl + cclmap[anyccl],
					ccllen[anyccl], nextecm,
					ecgroup, CSIZE );
			    
			    madeany = true;
			    }

			++rulelen;

			yyval = mkstate( -anyccl );
			} break;
case 41:
# line 472 "parse.y"
{
			if ( ! cclsorted )
			    /* sort characters for fast searching.  We use a
			     * shell sort since this list could be large.
			     */
			    cshell( ccltbl + cclmap[yypvt[-0]], ccllen[yypvt[-0]] );

			if ( useecs )
			    mkeccl( ccltbl + cclmap[yypvt[-0]], ccllen[yypvt[-0]],
				    nextecm, ecgroup, CSIZE );
				     
			++rulelen;

			yyval = mkstate( -yypvt[-0] );
			} break;
case 42:
# line 489 "parse.y"
{
			++rulelen;

			yyval = mkstate( -yypvt[-0] );
			} break;
case 43:
# line 496 "parse.y"
{ yyval = yypvt[-1]; } break;
case 44:
# line 499 "parse.y"
{ yyval = yypvt[-1]; } break;
case 45:
# line 502 "parse.y"
{
			++rulelen;

			if ( yypvt[-0] == '\0' )
			    synerr( "null in rule" );

			if ( caseins && yypvt[-0] >= 'A' && yypvt[-0] <= 'Z' )
			    yypvt[-0] = clower( yypvt[-0] );

			yyval = mkstate( yypvt[-0] );
			} break;
case 46:
# line 516 "parse.y"
{ yyval = yypvt[-1]; } break;
case 47:
# line 519 "parse.y"
{
			/* *Sigh* - to be compatible Unix lex, negated ccls
			 * match newlines
			 */
#ifdef NOTDEF
			ccladd( yypvt[-1], '\n' ); /* negated ccls don't match '\n' */
			cclsorted = false; /* because we added the newline */
#endif
			cclnegate( yypvt[-1] );
			yyval = yypvt[-1];
			} break;
case 48:
# line 533 "parse.y"
{
			if ( yypvt[-2] > yypvt[-0] )
			    synerr( "negative range in character class" );

			else
			    {
			    if ( caseins )
				{
				if ( yypvt[-2] >= 'A' && yypvt[-2] <= 'Z' )
				    yypvt[-2] = clower( yypvt[-2] );
				if ( yypvt[-0] >= 'A' && yypvt[-0] <= 'Z' )
				    yypvt[-0] = clower( yypvt[-0] );
				}

			    for ( i = yypvt[-2]; i <= yypvt[-0]; ++i )
			        ccladd( yypvt[-3], i );

			    /* keep track if this ccl is staying in alphabetical
			     * order
			     */
			    cclsorted = cclsorted && (yypvt[-2] > lastchar);
			    lastchar = yypvt[-0];
			    }
			
			yyval = yypvt[-3];
			} break;
case 49:
# line 561 "parse.y"
{
			if ( caseins )
			    if ( yypvt[-0] >= 'A' && yypvt[-0] <= 'Z' )
				yypvt[-0] = clower( yypvt[-0] );

			ccladd( yypvt[-1], yypvt[-0] );
			cclsorted = cclsorted && (yypvt[-0] > lastchar);
			lastchar = yypvt[-0];
			yyval = yypvt[-1];
			} break;
case 50:
# line 573 "parse.y"
{
			cclsorted = true;
			lastchar = 0;
			yyval = cclinit();
			} break;
case 51:
# line 581 "parse.y"
{
			if ( caseins )
			    if ( yypvt[-0] >= 'A' && yypvt[-0] <= 'Z' )
				yypvt[-0] = clower( yypvt[-0] );

			++rulelen;

			yyval = link_machines( yypvt[-1], mkstate( yypvt[-0] ) );
			} break;
case 52:
# line 592 "parse.y"
{ yyval = mkstate( SYM_EPSILON ); } break;
	}
	goto yystack;  /* stack new state and value */
}
