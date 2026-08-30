
# line 2 "bc.y"
	int *getout();
	int *bundle();

# line 5 "bc.y"
typedef union  {
	int *iptr;
	char *cptr;
	int cc;
	} YYSTYPE;
# define UMINUS 257
# define LETTER 258
# define DIGIT 259
# define SQRT 260
# define LENGTH 261
# define _IF 262
# define FFF 263
# define EQ 264
# define _WHILE 265
# define _FOR 266
# define NE 267
# define LE 268
# define GE 269
# define INCR 270
# define DECR 271
# define _RETURN 272
# define _BREAK 273
# define _DEFINE 274
# define BASE 275
# define OBASE 276
# define SCALE 277
# define EQPL 278
# define EQMI 279
# define EQMUL 280
# define EQDIV 281
# define EQREM 282
# define EQEXP 283
# define _AUTO 284
# define DOT 285
# define QSTR 286

# line 29 "bc.y"
#include <stdio.h>
FILE *in;
char cary[1000], *cp = { cary };
char string[1000], *str = {string};
int crs = '0';
int rcrs = '0';  /* reset crs */
int bindx = 0;
int lev = 0;
int ln;
int *ttp;
char *ss;
int bstack[10] = { 0 };
char *numb[15] = {
  " 0", " 1", " 2", " 3", " 4", " 5",
  " 6", " 7", " 8", " 9", " 10", " 11",
  " 12", " 13", " 14" };
int *pre, *post;
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 342 "bc.y"

# define error 256

int peekc = -1;
int sargc;
int ifile;
char **sargv;

char funtab[52] = {
	01,0,02,0,03,0,04,0,05,0,06,0,07,0,010,0,011,0,012,0,013,0,014,0,015,0,016,0,017,0,
	020,0,021,0,022,0,023,0,024,0,025,0,026,0,027,0,030,0,031,0,032,0 };
char atab[52] = {
	0241,0,0242,0,0243,0,0244,0,0245,0,0246,0,0247,0,0250,0,0251,0,0252,0,0253,0,
	0254,0,0255,0,0256,0,0257,0,0260,0,0261,0,0262,0,0263,0,0264,0,0265,0,0266,0,
	0267,0,0270,0,0271,0,0272,0};
char *letr[26] = {
  "a","b","c","d","e","f","g","h","i","j",
  "k","l","m","n","o","p","q","r","s","t",
  "u","v","w","x","y","z" } ;
char *dot = { "." };
yylex(){
	int c, ch;
restart:
	c = getch();
	peekc = -1;
	while( c == ' ' || c == '\t' ) c = getch();
	if(c == '\\'){
		getch();
		goto restart;
	}
	if( c<= 'z' && c >= 'a' ) {
		/* look ahead to look for reserved words */
		peekc = getch();
		if( peekc >= 'a' && peekc <= 'z' ){ /* must be reserved word */
			if( c=='i' && peekc=='f' ){ c=_IF; goto skip; }
			if( c=='w' && peekc=='h' ){ c=_WHILE; goto skip; }
			if( c=='f' && peekc=='o' ){ c=_FOR; goto skip; }
			if( c=='s' && peekc=='q' ){ c=SQRT; goto skip; }
			if( c=='r' && peekc=='e' ){ c=_RETURN; goto skip; }
			if( c=='b' && peekc=='r' ){ c=_BREAK; goto skip; }
			if( c=='d' && peekc=='e' ){ c=_DEFINE; goto skip; }
			if( c=='s' && peekc=='c' ){ c= SCALE; goto skip; }
			if( c=='b' && peekc=='a' ){ c=BASE; goto skip; }
			if( c=='i' && peekc == 'b'){ c=BASE; goto skip; }
			if( c=='o' && peekc=='b' ){ c=OBASE; goto skip; }
			if( c=='d' && peekc=='i' ){ c=FFF; goto skip; }
			if( c=='a' && peekc=='u' ){ c=_AUTO; goto skip; }
			if( c == 'l' && peekc=='e'){ c=LENGTH; goto skip; }
			if( c == 'q' && peekc == 'u'){getout();}
			/* could not be found */
			return( error );
		skip:	/* skip over rest of word */
			peekc = -1;
			while( (ch = getch()) >= 'a' && ch <= 'z' );
			peekc = ch;
			return( c );
		}

		/* usual case; just one single letter */

		yylval.cptr = letr[c-'a'];
		return( LETTER );
	}
	if( c>= '0' && c <= '9' || c>= 'A' && c<= 'F' ){
		yylval.cc = c;
		return( DIGIT );
	}
	switch( c ){
	case '.':	return( DOT );
	case '=':
		switch( (peekc=getch())  ){
		case '=': c=EQ; goto gotit;
		case '+': c=EQPL; goto gotit;
		case '-': c=EQMI; goto gotit;
		case '*': c=EQMUL; goto gotit;
		case '/': c=EQDIV; goto gotit;
		case '%': c=EQREM; goto gotit;
		case '^': c=EQEXP; goto gotit;
		default:   return( '=' );
			  gotit:     peekc = -1; return(c);
		  }
	case '+':	return( cpeek( '+', INCR, '=',EQPL, '+' ) );
	case '-':	return( cpeek( '-', DECR,'=',EQMI, '-' ) );
	case '*':	return(cpeek( '=', EQMUL,'\0',0,'*'));
	case '%':	return(cpeek('=', EQREM,'\0',0,'%'));
	case '^':	return(cpeek('=',EQEXP,'\0',0,'^'));
	case '<':	return( cpeek( '=', LE,'\0',0, '<' ) );
	case '>':	return( cpeek( '=', GE,'\0',0, '>' ) );
	case '!':	return( cpeek( '=', NE,'\0',0, '!' ) );
	case '/':
			if((peekc=getch()) == '='){
				peekc = -1;
				return(EQDIV);
			}
		if(peekc  == '*'){
			peekc = -1;
			while((getch() != '*') || ((peekc = getch()) != '/'));
			peekc = -1;
			goto restart;
		}
		else return(c);
	case '"':	
		yylval.cptr = str;
		 while((c=getch()) != '"'){*str++ = c;
			if(str >= &string[999]){yyerror("string space exceeded");
			getout();
		}
	}
	 *str++ = '\0';
	return(QSTR);
	default:	 return( c );
	}
}

cpeek(c1,yes1,c2,yes2,none)
char c1,c2,none;
{
	int r;
	peekc = getch();
	if(peekc == c1)r=yes1;
	else if(peekc == c2)r=yes2;
	else
		return(none);
	peekc = -1;
	return(r);
}

getch(){
	int ch;
loop:
	ch = (peekc < 0) ? getc(in) : peekc;
	peekc = -1;
	if(ch != EOF)return(ch);
	if(++ifile > sargc){
		if(ifile >= sargc+2)getout();
		in = stdin;
		ln = 0;
		goto loop;
	}
	fclose(in);
	if((in = fopen(sargv[ifile],"r")) != NULL){
		ln = 0;
		ss = sargv[ifile];
		goto loop;
	}
	yyerror("cannot open input file");
}
# define b_sp_max 5000
int b_space [ b_sp_max ];
int * b_sp_nxt = { b_space };

int	bdebug = 0;
int *
bundle(a){
	int i, *p, *q;

	p = &a;
	i = *p++;
	q = b_sp_nxt;
	if( bdebug ) printf("bundle %d elements at %o\n",i,  q );
	while(i-- > 0){
		if( b_sp_nxt >= & b_space[b_sp_max] ) yyerror( "bundling space exceeded" );
		* b_sp_nxt++ = *p++;
	}
	* b_sp_nxt++ = 0;
	yyval.iptr = q;
	return( q );
}

routput(p) int *p; {
	if( bdebug ) printf("routput(%o)\n", p );
	if( p >= &b_space[0] && p < &b_space[b_sp_max]){
		/* part of a bundle */
		while( *p != 0 ) routput( *p++ );
	}
	else printf( p );	 /* character string */
}

output( p ) int *p; {
	routput( p );
	b_sp_nxt = & b_space[0];
	printf( "\n" );
	fflush(stdout);
	cp = cary;
	crs = rcrs;
}

conout( p, s ) int *p; char *s; {
	printf("[");
	routput( p );
	printf("]s%s\n", s );
	fflush(stdout);
	lev--;
}

yyerror( s ) char *s; {
	if(ifile > sargc)ss="teletype";
	printf("c[%s on line %d, %s]pc\n", s ,ln+1,ss);
	fflush(stdout);
	cp = cary;
	crs = rcrs;
	bindx = 0;
	lev = 0;
	b_sp_nxt = &b_space[0];
}

pp( s ) char *s; {
	/* puts the relevant stuff on pre and post for the letter s */

	bundle(3, "S", s, pre );
	pre = yyval.iptr;
	bundle(4, post, "L", s, "s." );
	post = yyval.iptr;
}

tp( s ) char *s; { /* same as pp, but for temps */
	bundle(3, "0S", s, pre );
	pre = yyval.iptr;
	bundle(4, post, "L", s, "s." );
	post = yyval.iptr;
}

yyinit(argc,argv) int argc; char *argv[];{
	signal( 2, (int(*)())1 );	/* ignore all interrupts */
	sargv=argv;
	sargc= -- argc;
	if(sargc == 0)in=stdin;
	else if((in = fopen(sargv[1],"r")) == NULL)
		yyerror("cannot open input file");
	ifile = 1;
	ln = 0;
	ss = sargv[1];
}
int *getout(){
	printf("q");
	fflush(stdout);
	exit();
}

int *
getf(p) char *p;{
	return(&funtab[2*(*p -0141)]);
}
int *
geta(p) char *p;{
	return(&atab[2*(*p - 0141)]);
}

main(argc, argv)
char **argv;
{
	int p[2];


	if (argc > 1 && *argv[1] == '-') {
		if((argv[1][1] == 'd')||(argv[1][1] == 'c')){
			yyinit(--argc, ++argv);
			yyparse();
			exit();
		}
		if(argv[1][1] != 'l'){
			printf("unrecognizable argument\n");
			fflush(stdout);
			exit();
		}
		argv[1] = "/usr/lib/lib.b";
	}
	pipe(p);
	if (fork()==0) {
		close(1);
		dup(p[1]);
		close(p[0]);
		close(p[1]);
		yyinit(argc, argv);
		yyparse();
		exit();
	}
	close(0);
	dup(p[0]);
	close(p[0]);
	close(p[1]);
	execl("/bin/dc", "dc", "-", 0);
	execl("/usr/bin/dc", "dc", "-", 0);
}
short yyexca[] ={
-1, 1,
	0, -1,
	59, 7,
	10, 7,
	-2, 0,
-1, 12,
	125, 7,
	59, 7,
	10, 7,
	-2, 0,
-1, 126,
	125, 7,
	59, 7,
	10, 7,
	-2, 0,
-1, 184,
	125, 7,
	59, 7,
	10, 7,
	-2, 0,
-1, 193,
	125, 7,
	59, 7,
	10, 7,
	-2, 0,
-1, 208,
	125, 7,
	59, 7,
	10, 7,
	-2, 0,
-1, 210,
	125, 7,
	59, 7,
	10, 7,
	-2, 0,
	};
# define YYNPROD 121
# define YYLAST 768
short yyact[]={

  26,  92,  31,  98,  38,  20, 142,  88,  77,  76,
  84,  43, 126,  71, 129,  33,  41,  39, 113,  40,
  34,  42, 150,  27,  90,  91,  89,  86,  87,  85,
  44,  34,  23,  26, 164, 152, 165,  43,  20, 144,
 143, 210,  41,  39,  43,  40, 101,  42,  43,  41,
  39, 131,  40,  41,  42,  31,  27,  93,  42, 208,
  34, 162,  34, 193, 127, 160,  26,  37,  44,  35,
 154,  20,  99, 155, 132, 100, 128,  97,  96,  94,
  35,  57, 184,  12,  36,  73,  18,  26,  31,  27,
  30, 111,  20,  17,  44, 214, 222,   3,   1,   0,
 203,  44,  74,  75,   0,  44,   0,  26, 117,  35,
  27,  35,  20,   0,   0,   0,  12,   0,   0,  18,
   0,  31,   0,   0,   0, 145,   0,  26, 112,   0,
  27,  43,  20,   0,   0, 213,  41,  39,   0,  40,
 191,  42,  31, 161,   0,  72, 125,   2,  26,  12,
  27,   0,  18,  20,   0,   0,  50,   0,   0,   0,
   0,   0,  31, 185,   0,   0,  32,   0, 151,   0,
  62,  27,   0,  83, 190, 192,   0, 134,   0,   0,
   0,   0,  31,   0,   0,  26,   0, 202,  44,   0,
  20, 136,   0,  83,   0,   0,  50,   0, 204,   0,
   0,   0,   0,  31,  43,   0,   0, 156,  27,  41,
  39,   0,  40,  83,  42,   0,  14, 134,   6,  32,
  28,  25,  15,  13,   0,  16,  29, 221,   0,  50,
  21,  22,   8,   7,  83,  10,  11,   9, 163,   0,
  31, 166, 168, 167, 205,  24,   5, 133,   0,  14,
  45,   6,  32,  28,  25,  15,  13,   0,  16,  29,
  62,  44,   0,  21,  22,   8,   7,  19,  10,  11,
   9,  83, 159, 215, 217, 211,   0,   0,  24,   5,
  46,  58,  14, 223,   6,  32,  28,  25,  15,  13,
 224,  16,  29,   0,   0, 186,  21,  22,   8,   7,
   0,  10,  11,   9,   0,  79,  32,  28,  25, 140,
   0,  24,   5,   0,   0, 138,   0,  21,  22,   0,
   0,   0,  81,  82,  80,  79,  32,  28,  25,  67,
   0,   0,  24,   0,   0,  63,   0,  21,  22, 209,
   0,   0,  81,  82,  80, 115,  32,  28,  25,   0,
   0,   0,  24,   0, 216,   0, 218,  21,  22,   0,
   0,   0,  81,  82,  80,   0,  79,  32,  28,  25,
   0,   0,  24,   0,   0,   0,   0,   0,  21,  22,
   0,   0,   0,  81,  82,  80,  48,  49,   0,   0,
   0,   0,   0,  24,  51,  52,  53,  54,  55,  56,
  60,  61,   0, 115,  32,  28,  25,   0,  51,  52,
  53,  54,  55,  56,   0,  21,  22,   0,   0,   0,
  81,  82,  80,  43,   0,   0,  48,  49,  41,  39,
  24,  40,   0,  42,  51,  52,  53,  54,  55,  56,
 135,   0,   0,   0,   0,   0,   0,  47,   0,   0,
  59,  64,  68,   0,   0,   0,   0,   0,   0,  48,
  49,   0,   0,   0,   0,   0,   0,  51,  52,  53,
  54,  55,  56,   0,   0,   0,   0,   0,   0, 201,
  44,   0,   0,   0, 188, 189,   0,   0,   0,   0,
  60,  61,  51,  52,  53,  54,  55,  56,  51,  52,
  53,  54,  55,  56, 188, 189,   0,   0,   0,   0,
   0,   0,  51,  52,  53,  54,  55,  56,  69,  70,
   0, 137, 139, 141,  65,  66,  51,  52,  53,  54,
  55,  56,  51,  52,  53,  54,  55,  56,  69,  70,
   4,   0,   0,   0,  65,  66,  51,  52,  53,  54,
  55,  56,  51,  52,  53,  54,  55,  56,   0,   0,
   0,  78,   0,   0,   0,   0,   0,  95,  43,   0,
   0,   0,   0,  41,  39,   0,  40,   0,  42,   0,
 102, 103, 104, 105, 106, 107, 108, 109, 110,   0,
 183, 114,   0,   0, 187,   0,   0,   0, 116, 118,
 119,   0,   0, 120, 121, 122,   0,  43, 123, 124,
   0, 182,  41,  39,  43,  40, 130,  42, 181,  41,
  39,   0,  40,   0,  42,  44,  43,   0,   0,   0,
 158,  41,  39,   0,  40, 146,  42, 148, 149,   0,
   0,  43, 212,   0,   0, 157,  41,  39,   0,  40,
   0,  42,   0,   0,   0,  43,   0,   0,   0,   0,
  41,  39,   0,  40,  44,  42,   0,   0,   0, 130,
   0,  44, 169,   0, 170, 171, 172, 173, 174, 175,
 176, 177, 178,  44, 179, 180,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 114, 170,  44,   0,
   0, 130,   0, 194, 195, 196, 197, 198, 199, 200,
  43, 153,  44,   0, 147,  41,  39,   0,  40,   0,
  42,   0,   0,   0,   0,   0,   0, 206, 207,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0, 219, 220,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  44 };
short yypact[]={

-1000,  -7,  50,-254, 167,-1000, 189,-1000,  41, 220,
 274, 268,  26,-1000,-1000,-1000,-1000,-1000,-249,-250,
 108,-248,-251,-284, -93,  39, 108,-1000,  38,  37,
-256,-1000,-1000,-1000,-1000,-1000,  31,-1000, -45, 108,
 108, 108, 108, 108, 108, 108, 108, 108,-1000,-1000,
  87,-1000,-1000,-1000,-1000,-1000,-1000,  67, 108, 108,
-1000,-1000, 108, 108, 108,-1000,-1000, 108, 108,-1000,
-1000,  21,-1000,-1000,  36, 108, -10,  34,-1000, 156,
 130, 254, 248,-252, -51,-1000,-1000,-1000, -52,-1000,
-1000,-1000, -93,-1000, 108, 673, 108, 108,-1000,-101,
-254, -58,  11,  11, -64, -64, -64, -64, 167, 618,
 167,  29,-1000,-1000, 167, 116, 604,-1000, 167, 167,
 589, 167, 167, 167, 167,-1000,  26,  25, 108,   2,
 -26, 108,-1000, 108, 108, 108, 108, 108, 108, 108,
 108, 108,-1000, 108, 108,-1000, 577,-1000, 570, 531,
  50,-1000,-1000, 234,-1000, 145,  47,-1000,-1000,-1000,
 108,  22, 108, 108, 108, 108, 108, 108, 108, 167,
 386, 167, 167, 167, 167, 167, 167, 167, 167,  94,
   7,-1000,-1000,-1000, -40,-1000, 108, 108,-1000,-1000,
-1000,-1000,  18,  26,   0, 167, 167, 167, 167, 167,
 167, 214,-1000,-1000,  10,-254, 167, 167,  26,-1000,
  26, 108, 108,-1000,  52,-1000,-1000,-1000,-1000, 167,
 167,-1000,-254,-1000,-1000 };
short yypgo[]={

   0,  98, 145,  97,  13,  95, 540,  14,  93,  91,
  18,  32,  90,  67, 440,  85,  12,  84,  82,  64 };
short yyr1[]={

   0,   1,   1,   1,  18,  18,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
  14,  14,  14,  14,  14,  14,   8,  19,   4,   4,
  16,  16,   7,   7,   7,   7,   7,   7,   7,   6,
   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,
   6,   6,   6,   6,   9,   9,  10,  10,  11,  12,
  12,  12,  15,   3,  17,  17,  17,   5,   5,  13,
  13 };
short yyr2[]={

   0,   0,   3,   8,   1,   4,   1,   0,   1,   3,
   6,   3,   6,   1,   4,   3,   1,   3,   3,   3,
   3,   3,   3,   3,   1,   1,   7,   7,   8,   4,
   1,   1,   1,   1,   1,   1,   4,   0,   1,   3,
   1,   1,   3,   3,   3,   3,   3,   3,   1,   3,
   3,   2,   3,   3,   3,   3,   4,   2,   2,   2,
   2,   5,   5,   5,   5,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   4,   3,   1,
   2,   3,   2,   1,   1,   3,   3,   6,   6,   4,
   4,   3,   1,   4,   2,   3,   3,   3,   3,   3,
   3,   1,   1,   1,   1,   3,   1,   3,   1,   1,
   1,   2,   0,   3,   0,   1,   3,   1,   3,   1,
   3 };
short yychk[]={

-1000,  -1,  -2,  -3,  -6, 286, 258, 273, 272, 277,
 275, 276, 123, 263, 256, 262, 265,  -8, 126, 274,
  45, 270, 271, -11, 285, 261,  40,  63, 260, 266,
 -12,  95, 259, -16,  10,  59, -17, -13, 258,  43,
  45,  42,  47,  37,  94,  61,  91, -14, 270, 271,
  40, 278, 279, 280, 281, 282, 283,  40,  61, -14,
 270, 271,  40,  61, -14, 270, 271,  61, -14, 270,
 271,  -4,  -2, -15, -15, -15, 258, 258,  -6, 258,
 277, 275, 276, 126, 258, 277, 275, 276, 258, 277,
 275, 276, 285, -11,  40,  -6,  40,  40, 259,  41,
  44,  91,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,
  -6,  -9,  41, -10,  -6, 258,  -6,  41,  -6,  -6,
  -6,  -6,  -6,  -6,  -6, 125, -16, -19,  40,  -7,
  -6,  61,  40,  91,  61, -14,  61, -14,  61, -14,
  61, -14, 258,  91,  91, -11,  -6,  41,  -6,  -6,
 123, -13,  93,  93,  41,  44,  91,  41,  41,  -2,
  40,  -7,  59, 264,  60,  62, 267, 269, 268,  -6,
  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,
  -6,  41,  41,  59, -18, -16,  61, -14, 270, 271,
 -10,  93,  -7,  41,  -6,  -6,  -6,  -6,  -6,  -6,
  -6,  93,  93,  93,  -4, 284,  -6,  -6,  41,  -2,
  41,  61, -14, 125,  -5, -13,  -2, -19,  -2,  -6,
  -6, -16,  44, -19, -13 };
short yydef[]={

   1,  -2,   0, 114,   6,   8,  84,  13,  16, 101,
 102, 103,  -2,  24,  25, 112, 112, 112,   0,   0,
   0,   0,   0,  79,  83,   0,   0,  92,   0,   0,
 108, 109, 110,   2,  40,  41,   0, 115, 119,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  57,  60,
   0,  30,  31,  32,  33,  34,  35,   0,   0,   0,
  65,  67,   0,   0,   0,  69,  71,   0,   0,  73,
  75,   0,  38,  37,   0,   0,  94,   0,  51,  84,
 101, 102, 103,   0,  58,  66,  70,  74,  59,  68,
  72,  76,  82,  80,   0,   0,   0,   0, 111,   0,
   0,   0,  49,  50,  52,  53,  54,  55,   9,   0,
  11,   0,  78, 104, 106,  84,   0,  15,  17,  18,
   0,  19,  20,  21,  22,  23,  -2,   0,   0,   0,
  48,   0, 113,   0,   0,   0,   0,   0,   0,   0,
   0,   0,  94,   0,   0,  81,   0,  91,   0,   0,
   0, 116, 120,  56,  77,   0,   0,  14,  90,  39,
   0,   0,   0,   0,   0,   0,   0,   0,   0,  29,
   0,  85,  86,  95,  96,  97,  98,  99, 100,   0,
   0,  89,  93,  36,  -2,   4,   0,   0,  61,  63,
 105, 107,   0,  -2,   0,  42,  43,  44,  45,  46,
  47,  56,  62,  64,   0,   0,  10,  12,  -2,  37,
  -2,   0,   0,   3,   0, 117,  26,  27,  37,  87,
  88,   5,   0,  28, 118 };
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
# line 50 "bc.y"
{
			output( yypvt[-1].iptr );
		} break;
case 3:
# line 54 "bc.y"
{	ttp=bundle( 6,pre, yypvt[-1].iptr, post ,"0",numb[lev],"Q");
			conout( ttp, yypvt[-6].iptr );
			rcrs = crs;
			output( "" );
			lev = bindx = 0;
			} break;
case 6:
# line 67 "bc.y"
{ bundle(2, yypvt[-0].iptr, "ps." ); } break;
case 7:
# line 69 "bc.y"
{ bundle(1, "" ); } break;
case 8:
# line 71 "bc.y"
{ bundle(3,"[",yypvt[-0].cc,"]P");} break;
case 9:
# line 73 "bc.y"
{ bundle(3, yypvt[-0].iptr, "s", yypvt[-2].cptr ); } break;
case 10:
# line 75 "bc.y"
{ bundle(4, yypvt[-0].iptr, yypvt[-3].iptr, ":", geta(yypvt[-5].cptr)); } break;
case 11:
# line 77 "bc.y"
{ bundle(6, "l", yypvt[-2].cptr, yypvt[-0].iptr, yypvt[-1].cptr, "s", yypvt[-2].cptr ); } break;
case 12:
# line 79 "bc.y"
{ bundle(8,yypvt[-3].iptr, ";", geta(yypvt[-5].cptr), yypvt[-0].iptr, yypvt[-1].cptr, yypvt[-3].iptr, ":", geta(yypvt[-5].cptr));} break;
case 13:
# line 81 "bc.y"
{ bundle(2, numb[lev-bstack[bindx-1]], "Q" ); } break;
case 14:
# line 83 "bc.y"
 bundle(4, yypvt[-1].iptr, post, numb[lev], "Q" ); break;
case 15:
# line 85 "bc.y"
 bundle(4, "0", post, numb[lev], "Q" ); break;
case 16:
# line 87 "bc.y"
 bundle(4,"0",post,numb[lev],"Q"); break;
case 17:
# line 89 "bc.y"
 bundle(2, yypvt[-0].iptr, "k"); break;
case 18:
# line 91 "bc.y"
 bundle(4,"K",yypvt[-0].iptr,yypvt[-1].cptr,"k"); break;
case 19:
# line 93 "bc.y"
 bundle(2,yypvt[-0].iptr, "i"); break;
case 20:
# line 95 "bc.y"
 bundle(4,"I",yypvt[-0].iptr,yypvt[-1].cptr,"i"); break;
case 21:
# line 97 "bc.y"
 bundle(2,yypvt[-0].iptr,"o"); break;
case 22:
# line 99 "bc.y"
 bundle(4,"O",yypvt[-0].iptr,yypvt[-1].cptr,"o"); break;
case 23:
# line 101 "bc.y"
{ yyval.iptr = yypvt[-1].iptr; } break;
case 24:
# line 103 "bc.y"
{ bundle(1,"fY"); } break;
case 25:
# line 105 "bc.y"
{ bundle(1,"c"); } break;
case 26:
# line 107 "bc.y"
{	conout( yypvt[-0].iptr, yypvt[-5].cptr );
			bundle(3, yypvt[-2].iptr, yypvt[-5].cptr, " " );
			} break;
case 27:
# line 111 "bc.y"
{	bundle(3, yypvt[-1].iptr, yypvt[-3].iptr, yypvt[-5].cptr );
			conout( yyval.iptr, yypvt[-5].cptr );
			bundle(3, yypvt[-3].iptr, yypvt[-5].cptr, " " );
			} break;
case 28:
# line 116 "bc.y"
{	bundle(5, yypvt[-1].iptr, yypvt[-3].iptr, "s.", yypvt[-5].iptr, yypvt[-6].cptr );
			conout( yyval.iptr, yypvt[-6].cptr );
			bundle(5, yypvt[-7].iptr, "s.", yypvt[-5].iptr, yypvt[-6].cptr, " " );
			} break;
case 29:
# line 121 "bc.y"
{	bundle(3,yypvt[-0].iptr,"S",yypvt[-2].cptr); } break;
case 30:
# line 125 "bc.y"
{ yyval.cptr = "+"; } break;
case 31:
# line 127 "bc.y"
{ yyval.cptr = "-"; } break;
case 32:
# line 129 "bc.y"
{ yyval.cptr = "*"; } break;
case 33:
# line 131 "bc.y"
{ yyval.cptr = "/"; } break;
case 34:
# line 133 "bc.y"
{ yyval.cptr = "%%"; } break;
case 35:
# line 135 "bc.y"
{ yyval.cptr = "^"; } break;
case 36:
# line 139 "bc.y"
{ yyval.iptr = yypvt[-1].iptr; } break;
case 37:
# line 143 "bc.y"
{ --bindx; } break;
case 39:
# line 148 "bc.y"
{ bundle(2, yypvt[-2].iptr, yypvt[-0].iptr ); } break;
case 40:
# line 152 "bc.y"
{ln++;} break;
case 42:
# line 157 "bc.y"
{ yyval.iptr = bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "=" ); } break;
case 43:
# line 159 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, ">" ); break;
case 44:
# line 161 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "<" ); break;
case 45:
# line 163 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "!=" ); break;
case 46:
# line 165 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "!>" ); break;
case 47:
# line 167 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "!<" ); break;
case 48:
# line 169 "bc.y"
 bundle(2, yypvt[-0].iptr, " 0!=" ); break;
case 49:
# line 173 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "+" ); break;
case 50:
# line 175 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "-" ); break;
case 51:
# line 177 "bc.y"
 bundle(3, " 0", yypvt[-0].iptr, "-" ); break;
case 52:
# line 179 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "*" ); break;
case 53:
# line 181 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "/" ); break;
case 54:
# line 183 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "%%" ); break;
case 55:
# line 185 "bc.y"
 bundle(3, yypvt[-2].iptr, yypvt[-0].iptr, "^" ); break;
case 56:
# line 187 "bc.y"
{ bundle(3,yypvt[-1].iptr, ";", geta(yypvt[-3].cptr)); } break;
case 57:
# line 189 "bc.y"
 bundle(4, "l", yypvt[-1].cptr, "d1+s", yypvt[-1].cptr ); break;
case 58:
# line 191 "bc.y"
 bundle(4, "l", yypvt[-0].cptr, "1+ds", yypvt[-0].cptr ); break;
case 59:
# line 193 "bc.y"
 bundle(4, "l", yypvt[-0].cptr, "1-ds", yypvt[-0].cptr ); break;
case 60:
# line 195 "bc.y"
 bundle(4, "l", yypvt[-1].cptr, "d1-s", yypvt[-1].cptr ); break;
case 61:
# line 197 "bc.y"
 bundle(7,yypvt[-2].iptr,";",geta(yypvt[-4].cptr),"d1+",yypvt[-2].iptr,":",geta(yypvt[-4].cptr)); break;
case 62:
# line 199 "bc.y"
 bundle(7,yypvt[-1].iptr,";",geta(yypvt[-3].cptr),"1+d",yypvt[-1].iptr,":",geta(yypvt[-3].cptr)); break;
case 63:
# line 201 "bc.y"
 bundle(7,yypvt[-2].iptr,";",geta(yypvt[-4].cptr),"d1-",yypvt[-2].iptr,":",geta(yypvt[-4].cptr)); break;
case 64:
# line 203 "bc.y"
 bundle(7,yypvt[-1].iptr,";",geta(yypvt[-3].cptr),"1-d",yypvt[-1].iptr,":",geta(yypvt[-3].cptr)); break;
case 65:
# line 205 "bc.y"
 bundle(1,"Kd1+k"); break;
case 66:
# line 207 "bc.y"
 bundle(1,"K1+dk"); break;
case 67:
# line 209 "bc.y"
 bundle(1,"Kd1-k"); break;
case 68:
# line 211 "bc.y"
 bundle(1,"K1-dk"); break;
case 69:
# line 213 "bc.y"
 bundle(1,"Id1+i"); break;
case 70:
# line 215 "bc.y"
 bundle(1,"I1+di"); break;
case 71:
# line 217 "bc.y"
 bundle(1,"Id1-i"); break;
case 72:
# line 219 "bc.y"
 bundle(1,"I1-di"); break;
case 73:
# line 221 "bc.y"
 bundle(1,"Od1+o"); break;
case 74:
# line 223 "bc.y"
 bundle(1,"O1+do"); break;
case 75:
# line 225 "bc.y"
 bundle(1,"Od1-o"); break;
case 76:
# line 227 "bc.y"
 bundle(1,"O1-do"); break;
case 77:
# line 229 "bc.y"
 bundle(4, yypvt[-1].iptr, "l", getf(yypvt[-3].cptr), "x" ); break;
case 78:
# line 231 "bc.y"
 bundle(3, "l", getf(yypvt[-2].cptr), "x" ); break;
case 79:
# line 233 "bc.y"
{ bundle(2, " ", yypvt[-0].iptr ); } break;
case 80:
# line 235 "bc.y"
{ bundle(2, " .", yypvt[-0].iptr ); } break;
case 81:
# line 237 "bc.y"
{ bundle(4, " ", yypvt[-2].iptr, ".", yypvt[-0].iptr ); } break;
case 82:
# line 239 "bc.y"
{ bundle(3, " ", yypvt[-1].iptr, "." ); } break;
case 83:
# line 241 "bc.y"
{ yyval.cptr = "l."; } break;
case 84:
# line 243 "bc.y"
 { bundle(2, "l", yypvt[-0].cptr ); } break;
case 85:
# line 245 "bc.y"
{ bundle(3, yypvt[-0].iptr, "ds", yypvt[-2].cptr ); } break;
case 86:
# line 247 "bc.y"
{ bundle(6, "l", yypvt[-2].cptr, yypvt[-0].iptr, yypvt[-1].cptr, "ds", yypvt[-2].cptr ); } break;
case 87:
# line 249 "bc.y"
 { bundle(5,yypvt[-0].iptr,"d",yypvt[-3].iptr,":",geta(yypvt[-5].cptr)); } break;
case 88:
# line 251 "bc.y"
 { bundle(9,yypvt[-3].iptr,";",geta(yypvt[-5].cptr),yypvt[-0].iptr,yypvt[-1].cptr,"d",yypvt[-3].iptr,":",geta(yypvt[-5].cptr)); } break;
case 89:
# line 253 "bc.y"
 bundle(2,yypvt[-1].iptr,"Z"); break;
case 90:
# line 255 "bc.y"
 bundle(2,yypvt[-1].iptr,"X"); break;
case 91:
# line 257 "bc.y"
 { yyval.iptr = yypvt[-1].iptr; } break;
case 92:
# line 259 "bc.y"
{ bundle(1, "?" ); } break;
case 93:
# line 261 "bc.y"
{ bundle(2, yypvt[-1].iptr, "v" ); } break;
case 94:
# line 263 "bc.y"
{ bundle(2,"L",yypvt[-0].cptr); } break;
case 95:
# line 265 "bc.y"
 bundle(2,yypvt[-0].iptr,"dk"); break;
case 96:
# line 267 "bc.y"
 bundle(4,"K",yypvt[-0].iptr,yypvt[-1].cptr,"dk"); break;
case 97:
# line 269 "bc.y"
 bundle(2,yypvt[-0].iptr,"di"); break;
case 98:
# line 271 "bc.y"
 bundle(4,"I",yypvt[-0].iptr,yypvt[-1].cptr,"di"); break;
case 99:
# line 273 "bc.y"
 bundle(2,yypvt[-0].iptr,"do"); break;
case 100:
# line 275 "bc.y"
 bundle(4,"O",yypvt[-0].iptr,yypvt[-1].cptr,"do"); break;
case 101:
# line 277 "bc.y"
 bundle(1,"K"); break;
case 102:
# line 279 "bc.y"
 bundle(1,"I"); break;
case 103:
# line 281 "bc.y"
 bundle(1,"O"); break;
case 105:
# line 286 "bc.y"
 bundle(2, yypvt[-2].iptr, yypvt[-0].iptr ); break;
case 107:
# line 290 "bc.y"
bundle(2,"l",geta(yypvt[-2].cptr)); break;
case 108:
# line 294 "bc.y"
{ *cp++ = '\0'; } break;
case 109:
# line 298 "bc.y"
{ yyval.cptr = cp; *cp++ = '_'; } break;
case 110:
# line 300 "bc.y"
{ yyval.cptr = cp; *cp++ = yypvt[-0].cc; } break;
case 111:
# line 302 "bc.y"
{ *cp++ = yypvt[-0].cc; } break;
case 112:
# line 306 "bc.y"
{ yyval.cptr = cp; *cp++ = crs++; *cp++ = '\0';
			if(crs == '[')crs+= 3;
			if(crs == 'a')crs='{';
			if(crs >= 0241){yyerror("program too big");
				getout();
			}
			bstack[bindx++] = lev++; } break;
case 113:
# line 316 "bc.y"
{	yyval.iptr = getf(yypvt[-1].cptr);
			pre = (int *)"";
			post = (int *)"";
			lev = 1;
			bstack[bindx=0] = 0;
			} break;
case 115:
# line 326 "bc.y"
{ pp( yypvt[-0].iptr ); } break;
case 116:
# line 328 "bc.y"
{ pp( yypvt[-0].iptr ); } break;
case 117:
# line 332 "bc.y"
{ tp(yypvt[-0].iptr); } break;
case 118:
# line 334 "bc.y"
{ tp(yypvt[-0].iptr); } break;
case 119:
# line 337 "bc.y"
{ yyval.cptr=yypvt[-0].cptr; } break;
case 120:
# line 339 "bc.y"
{ yyval.iptr = geta(yypvt[-2].cptr); } break;
	}
	goto yystack;  /* stack new state and value */
}
