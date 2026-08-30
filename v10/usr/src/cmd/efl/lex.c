# include "stdio.h"
# define U(x) x
# define NLSTATE yyprevious=YYNEWLINE
# define BEGIN yybgin = yysvec + 1 +
# define INITIAL 0
# define YYLERR yysvec
# define YYSTATE (yyestate-yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,yyout)
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):efgetc)==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
# define unput(c) {yytchar= (c);if(yytchar=='\n')yylineno--;*yysptr++=yytchar;}
# define yymore() (yymorfg=1)
# define ECHO fprintf(yyout, "%s",yytext)
# define REJECT { nstr = yyreject(); goto yyfussy;}
int yyleng; extern char yytext[];
int yymorfg;
extern char *yysptr, yysbuf[];
int yytchar;
FILE *yyin = {stdin}, *yyout = {stdout};
extern int yylineno;
struct yysvf { 
	int yystoff;
	struct yysvf *yyother;
	int *yystops;};
struct yysvf *yyestate;
extern struct yysvf yysvec[], *yybgin;
# define DOTSON 2

#line 3 "lex.l"
#undef INITIAL
#include <ctype.h>
#include "defs"
#include "tokdefs"

typedef union { int ival; ptr pval; } YYSTYPE;
extern YYSTYPE yylval;
YYSTYPE prevl;
int prevv;
char *copys();
static ptr p;
static /*ptr*/ struct stentry *q;
static FILE *fd;
static int quoted, k;
static int rket	= 0;
FILE *opincl();
ptr mkdef(), mkcomm(), mkname(), mkimcon();

#define RET(x)	{ RETI(x,x);  }

#define RETL(yv,yl) {yylval=prevl=yl;igeol=comneed=0;return(prevv=yv); }
#define RETP(yv,yl) {yylval.pval=prevl.pval=yl;igeol=comneed=0;return(prevv=yv); }
#define RETI(yv,yl) {yylval.ival=prevl.ival=yl;igeol=comneed=0;return(prevv=yv); }
#define REL(n)  {  RETI(RELOP, OPREL+n);}
#define AS(n)  {  RETI(ASGNOP, OPASGN+n); }
#define RETC(x) { RETP(CONST, mkconst(x,yytext) );  }
#define RETZ(x) { yytext[yyleng-1] = '\0'; RETP(CONST, mkimcon(x,yytext) ); }

# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
if(pushlex)
	if(pushlex==1)
		{
		pushlex = 2;
		yylval.ival = 0;
		return(EOS);
		}
	else	{
		pushlex = 0;
		if(rket == 2)
			rket = 1;
		else	RETL(prevv,prevl);
		}
if(rket > 0)
	{
	if(rket==1)
		{
		rket = 2;
		RET(RBRACK);
		}
	else	{
		rket = 0;
		RET(EOS);
		}
	}
if(eofneed) return(0);
if(forcerr) return(-1);
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 40 "lex.l"
{
		   lower(yytext);
		   if(lettneed && yyleng==1)
			{ RETI(LETTER, yytext[0]); }
		   else if(defneed)
			{
			register char *q1, *q2;
			for(q2=q1=yytext+yyleng+1 ; (*q1 = efgetc)!='\n' ; ++q1)
				;
			*q1 = '\0';
			p = mkdef(yytext, q2);
			defneed = 0;
			++yylineno;
			unput('\n');
			}
		   else if(optneed)
			{ RETP(OPTNAME, (int *)copys(yytext)); }
		   else if(comneed && ( (q=name(yytext,1))==NULL || ((struct headbits *)q)->tag!=TDEFINE) )
			{ RETP(COMNAME, mkcomm(yytext) ); }
		   else if(q = name(yytext,1)) switch(((struct headbits *)q)->tag)
			{
			case TDEFINE:
				filelines[filedepth] = yylineno;
				filemacs[filedepth] = efmacp;
				pushchars[filedepth] = (yysptr>yysbuf?
						*--yysptr : -1);
				if(++filedepth >= MAXINCLUDEDEPTH)
					fatal("macro or include too deep");
				filelines[filedepth] = yylineno = 1;
				efmacp = ((struct defblock *)q->varp)->valp;
				filenames[filedepth] = NULL;
				break;	/*now process new input */

			case TSTRUCT:
				RETP(STRUCTNAME, (int *)q);

			case TNAME:
				RETP(NAME, (int *)q);

			case TKEYWORD:
				if(((struct headbits *)q)->subtype == END)
					{
					register int c;
					eofneed = YES;
					while((c=input())!=';'&&c!='\n'&&c!=EOF)
						;
					NLSTATE;
					}
				RET(((struct headbits *)q)->subtype);

			default:
				fatal1("lex: impossible type code %d", ((struct headbits *)q)->tag);
			}
		   else  RETP(NAME, mkname(yytext) );
		}
break;
case 2:

#line 96 "lex.l"
RET(COMMA);
break;
case 3:

#line 97 "lex.l"
RET(EOS);
break;
case 4:

#line 99 "lex.l"
RET(LPAR);
break;
case 5:

#line 100 "lex.l"
RET(RPAR);
break;
case 6:

#line 103 "lex.l"
case 7:

#line 104 "lex.l"
RET(LBRACK);
break;
case 8:

#line 106 "lex.l"
case 9:

#line 107 "lex.l"
{ if(iobrlevel>0) RET(RBRACK); rket = 1;  RET(EOS); }
break;
case 10:

#line 109 "lex.l"
RET(COMMA);
break;
case 11:

#line 110 "lex.l"
RET(COLON);
break;
case 12:

#line 112 "lex.l"
RET(REPOP);
break;
case 13:

#line 114 "lex.l"
case 14:

#line 115 "lex.l"
RETI(OR,OPOR);
break;
case 15:

#line 116 "lex.l"
case 16:

#line 117 "lex.l"
RETI(OR,OP2OR);
break;
case 17:

#line 118 "lex.l"
case 18:

#line 119 "lex.l"
RETI(AND,OPAND);
break;
case 19:

#line 120 "lex.l"
case 20:

#line 121 "lex.l"
RETI(AND,OP2AND);
break;
case 21:

#line 122 "lex.l"
case 22:

#line 123 "lex.l"
RETI(NOT,OPNOT);
break;
case 23:

#line 124 "lex.l"
RETI(NOT,OPNOT);
break;
case 24:

#line 126 "lex.l"
case 25:

#line 127 "lex.l"
REL(OPLT);
break;
case 26:

#line 128 "lex.l"
case 27:

#line 129 "lex.l"
REL(OPLE);
break;
case 28:

#line 130 "lex.l"
case 29:

#line 131 "lex.l"
REL(OPGT);
break;
case 30:

#line 132 "lex.l"
case 31:

#line 133 "lex.l"
REL(OPGE);
break;
case 32:

#line 134 "lex.l"
case 33:

#line 135 "lex.l"
REL(OPEQ);
break;
case 34:

#line 136 "lex.l"
case 35:

#line 137 "lex.l"
case 36:

#line 138 "lex.l"
REL(OPNE);
break;
case 37:

#line 140 "lex.l"
RET(ARROW);
break;
case 38:

#line 141 "lex.l"
RET(QUALOP);
break;
case 39:

#line 143 "lex.l"
RETI(ADDOP, OPPLUS);
break;
case 40:

#line 144 "lex.l"
RETI(ADDOP, OPMINUS);
break;
case 41:

#line 145 "lex.l"
RETI(MULTOP, OPSTAR);
break;
case 42:

#line 146 "lex.l"
RETI(MULTOP, OPSLASH);
break;
case 43:

#line 148 "lex.l"
case 44:

#line 149 "lex.l"
RETI(POWER, OPPOWER);
break;
case 45:

#line 151 "lex.l"
RETI(DOUBLEADDOP, OPPLUS);
break;
case 46:

#line 152 "lex.l"
RETI(DOUBLEADDOP, OPMINUS);
break;
case 47:

#line 154 "lex.l"
AS(OPASGN);
break;
case 48:

#line 155 "lex.l"
AS(OPPLUS);
break;
case 49:

#line 156 "lex.l"
AS(OPMINUS);
break;
case 50:

#line 157 "lex.l"
AS(OPSTAR);
break;
case 51:

#line 158 "lex.l"
AS(OPSLASH);
break;
case 52:

#line 159 "lex.l"
case 53:

#line 160 "lex.l"
AS(OPPOWER);
break;
case 54:

#line 162 "lex.l"
AS(OPAND);
break;
case 55:

#line 163 "lex.l"
AS(OP2AND);
break;
case 56:

#line 164 "lex.l"
AS(OPOR);
break;
case 57:

#line 165 "lex.l"
AS(OP2OR);
break;
case 58:

#line 167 "lex.l"
case 59:

#line 168 "lex.l"
{ yytext[yyleng-1] = '\0'; p = mkconst(TYCHAR,yytext+1);
		  RETP(CONST,p); }
break;
case 60:

#line 171 "lex.l"
{ /* nh construct */
		int i, n;  char c;
		yytext[yyleng-1] = '\0';  n = convci(yytext);
		for(i = 0; i<n ; ++i)
			if( (c=yytext[i]=input()) == '\n' || c=='\0') break;
		yytext[i] = '\0';
		p = mkconst(TYCHAR,yytext);
		((struct exprblock /*|| struct varblock */ *)p)->vtypep = mkint(i);
		RETP(CONST, p);
		}
break;
case 61:

#line 182 "lex.l"
	RETC(TYINT);
break;
case 62:

#line 184 "lex.l"
case 63:

#line 185 "lex.l"
RETC(TYREAL);
break;
case 64:

#line 187 "lex.l"
case 65:

#line 188 "lex.l"
RETC(TYREAL);
break;
case 66:

#line 190 "lex.l"
case 67:

#line 191 "lex.l"
RETC(TYLREAL);
break;
case 68:

#line 193 "lex.l"
	{ yytext[yyleng-1] = '.';
		  RETP(CONST,mkimcon(TYCOMPLEX,yytext)); }
break;
case 69:

#line 196 "lex.l"
case 70:

#line 197 "lex.l"
RETZ(TYCOMPLEX);
break;
case 71:

#line 199 "lex.l"
case 72:

#line 200 "lex.l"
RETZ(TYCOMPLEX);
break;
case 73:

#line 202 "lex.l"
case 74:

#line 203 "lex.l"
RETZ(TYLCOMPLEX);
break;
case 75:

#line 205 "lex.l"
{ if(! nocommentflag) goto litline; }
break;
case 76:

#line 207 "lex.l"
{ if(thisexec) ((struct execblock *)thisexec)->nftnst += 2;
	  if(inproc)
		{
		unput('\n');
		RETP(ESCAPE, (int *)copys(yytext));
		}

	litline:	p = (int *)mkchain( copys(yytext), CHNULL);
			if(inproc==0 && yytext[0]=='%')
				prevcomments = (int *)hookup(prevcomments, p);
			else
				comments =  (int *)hookup(comments,p);
	}
break;
case 77:

#line 221 "lex.l"
;
break;
case 78:

#line 222 "lex.l"
;
break;
case 79:

#line 223 "lex.l"
;
break;
case 80:

#line 225 "lex.l"
;
break;
case 81:

#line 227 "lex.l"
{ if(igeol) { igeol=0; prevv = NEWLINE; }
	  else if(prevv>=NAME || prevv==RPAR || prevv==RBRACK
			|| prevv== -1 || prevv==QUALOP)
		RET(EOS); }
break;
case 82:

#line 232 "lex.l"
{ char * linerr();
	  fprintf(diagfile, "Bad input character %c %s\n", yytext[0], linerr());
	  ++nerrs;
	}
break;
case 83:

#line 237 "lex.l"
{ /* Include statement */
	char *q1;
	register char *q2;
	for(q1=yytext ; *q1==' ' || *q1=='\t' ; ++q1) ;
	quoted = NO;
	for(q1 += 7 ; *q1==' ' || *q1=='\t' ||
		*q1=='\'' || *q1=='"' || *q1=='(' ; ++q1 )
			if(*q1=='"' || *q1=='\'')
				quoted = YES;
	for(q2=q1 ; *q2!='\0' &&  *q2!=' ' && *q2!='\n' &&
		*q2!='\'' && *q2!='"' && *q2!=')' ; ++q2 )
			;
	*q2 = '\0';
	if( ! quoted)
		for(k=0; (q = name(q1,1)) && ((struct headbits *)q)->tag==TDEFINE ; ++k)
			{
			if(k > MAXINCLUDEDEPTH)
				fatal1("Macros too deep for %s", yytext);
			q1 = ((struct defblock *)q->varp)->valp;
			}
	if( (fd = opincl(&q1)) == NULL)
		{
		fprintf(diagfile, "Cannot open file %s.  Stop.\n", q1);
		exit(2);
		}
	filelines[filedepth] = yylineno;
	pushchars[filedepth] = '\n';
	if(++filedepth >= MAXINCLUDEDEPTH)
		fatal("macro or include too deep");
	fileptrs[filedepth] = yyin = fd;
	filenames[filedepth] = copys(q1);
	filelines[filedepth] = yylineno = 1;
	filemacs[filedepth] = NULL;
	}
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

#line 273 "lex.l"

yywrap()
{
if(filedepth == 0)
	{
	ateof = 1;
	return(1);
	}

if(efmacp == 0)
	{
	fclose(yyin);
	cfree(filenames[filedepth]);
	}

--filedepth;
if( filemacs[filedepth] )
	efmacp = filemacs[filedepth];
else	{
	yyin = fileptrs[filedepth];
	efmacp = 0;
	}
yylineno = filelines[filedepth];
if(pushchars[filedepth] != -1)
	unput( pushchars[filedepth] );
return(0);
}



lower(s)	/* replace upper with lower case letters */
register char *s;
{
register char *t;
for(t=s ; *t ; ++t)
	if( isupper(*t) )
		*s++ = tolower(*t);
	else if(*t != '_')
		*s++ = *t;
}




setdot(k)
int k;
{
if(k)
	BEGIN DOTSON;
else	BEGIN 0;
}




FILE *opincl(namep)
char **namep;
{
#ifndef unix
	return( fopen(*namep, "r") );
#else

	/* On Unix, follow the C include conventions */
	
	register char *s, *lastslash;
	char *dir, *name, temp[100];
	int i;
	FILE *fp;
	
	name = *namep;
	if(name[0] == '/')
		return( fopen(name, "r") );
	
	dir = basefile;
	for(i = filedepth ; i>=0 ; --i)
		if( filemacs[i] == NULL)
			{
			dir = filenames[i];
			break;
			}

	lastslash = NULL;
	for(s = dir ; *s ; ++s)
		if(*s == '/')
			lastslash = s;
	if(lastslash)
		{
		*lastslash = '\0';
		sprintf(temp, "%s/%s", dir, name);
		*lastslash = '/';
		if( fp = fopen(temp, "r") )
			*namep = temp;
		}
	else
		fp = fopen(name, "r");
	
	if(fp == NULL)
		{
		sprintf(temp, "/usr/include/%s", name);
		fp = fopen(temp, "r");
		*namep = temp;
		}
	return(fp);

#endif
}

int yyvstop[] = {
0,

82,
0,

78,
82,
0,

81,
0,

79,
82,
0,

77,
82,
0,

23,
82,
0,

82,
0,

75,
82,
0,

12,
82,
0,

18,
82,
0,

82,
0,

4,
82,
0,

5,
82,
0,

41,
82,
0,

39,
82,
0,

2,
10,
82,
0,

40,
82,
0,

38,
82,
0,

42,
82,
0,

61,
82,
0,

11,
82,
0,

3,
82,
0,

25,
82,
0,

47,
82,
0,

29,
82,
0,

1,
82,
0,

6,
82,
0,

8,
82,
0,

44,
82,
0,

82,
0,

7,
82,
0,

14,
82,
0,

9,
82,
0,

22,
82,
0,

78,
82,
0,

77,
82,
0,

76,
82,
0,

1,
82,
0,

38,
82,
0,

36,
0,

59,
0,

75,
0,

20,
0,

54,
0,

58,
0,

43,
0,

50,
0,

45,
0,

48,
0,

46,
0,

49,
0,

37,
0,

63,
0,

51,
0,

62,
0,

61,
0,

60,
0,

68,
0,

27,
0,

33,
0,

31,
0,

1,
0,

53,
0,

80,
0,

56,
0,

16,
0,

35,
0,

76,
0,

1,
0,

55,
0,

52,
0,

70,
0,

62,
63,
0,

69,
0,

66,
0,

64,
0,

57,
0,

1,
0,

67,
0,

65,
0,

69,
70,
0,

73,
0,

71,
0,

1,
0,

32,
0,

30,
0,

28,
0,

26,
0,

24,
0,

34,
0,

13,
0,

74,
0,

72,
0,

66,
67,
0,

64,
65,
0,

1,
0,

17,
0,

15,
0,

21,
0,

73,
74,
0,

71,
72,
0,

1,
0,

19,
0,

1,
0,

83,
0,
0};
# define YYTYPE int
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,5,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,6,	1,7,	
45,0,	1,8,	47,0,	34,72,	
34,73,	50,0,	79,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	1,9,	1,10,	1,11,	
1,12,	1,13,	34,72,	1,14,	
1,15,	1,16,	1,17,	1,18,	
1,19,	1,20,	1,21,	1,22,	
1,23,	1,24,	0,0,	0,0,	
14,48,	19,54,	0,0,	0,0,	
0,0,	18,52,	105,127,	1,25,	
1,26,	1,27,	1,28,	1,29,	
10,44,	23,60,	1,30,	1,30,	
1,30,	1,30,	1,30,	19,55,	
1,30,	1,30,	1,30,	14,49,	
18,53,	1,30,	27,67,	1,30,	
1,30,	2,39,	1,30,	1,30,	
2,8,	1,30,	1,30,	28,68,	
29,69,	33,71,	38,76,	36,74,	
1,31,	48,88,	1,32,	1,33,	
1,34,	42,80,	39,77,	52,89,	
75,99,	106,128,	107,129,	78,100,	
2,40,	2,10,	80,101,	2,12,	
2,13,	2,41,	2,14,	108,130,	
2,16,	2,17,	2,18,	109,131,	
2,20,	2,21,	2,22,	2,23,	
21,56,	39,77,	110,132,	3,8,	
1,35,	1,36,	1,37,	1,38,	
81,102,	42,80,	2,25,	2,26,	
2,27,	2,28,	2,29,	78,100,	
21,57,	21,58,	80,101,	112,134,	
124,143,	126,145,	133,146,	3,9,	
3,10,	2,42,	3,12,	3,13,	
144,151,	3,14,	0,0,	3,16,	
3,17,	3,18,	36,75,	3,20,	
3,21,	3,43,	3,23,	83,105,	
81,102,	87,112,	39,78,	2,31,	
0,0,	2,32,	2,33,	96,120,	
0,0,	3,25,	3,26,	3,27,	
3,28,	3,29,	22,59,	22,59,	
22,59,	22,59,	22,59,	22,59,	
22,59,	22,59,	22,59,	22,59,	
0,0,	0,0,	0,0,	98,121,	
0,0,	4,39,	0,0,	83,105,	
4,8,	87,112,	39,78,	2,35,	
2,36,	2,37,	2,38,	96,120,	
82,103,	0,0,	3,31,	0,0,	
3,32,	3,33,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
4,40,	4,10,	82,104,	4,12,	
4,13,	4,41,	4,14,	98,121,	
4,16,	4,17,	4,18,	0,0,	
4,20,	4,21,	4,43,	4,23,	
59,90,	59,91,	84,106,	0,0,	
82,103,	59,92,	3,35,	3,36,	
3,37,	3,38,	4,25,	4,26,	
4,27,	4,28,	4,29,	11,45,	
0,0,	84,107,	82,104,	86,110,	
85,108,	0,0,	100,122,	11,45,	
11,0,	4,42,	93,117,	93,118,	
101,123,	86,111,	0,0,	93,119,	
59,90,	59,91,	84,106,	85,109,	
102,124,	59,92,	103,125,	104,126,	
0,0,	0,0,	111,133,	4,31,	
0,0,	4,32,	4,33,	0,0,	
11,46,	84,107,	0,0,	86,110,	
85,108,	11,45,	100,122,	0,0,	
114,135,	11,45,	93,117,	93,118,	
101,123,	86,111,	11,45,	93,119,	
12,47,	0,0,	0,0,	85,109,	
102,124,	116,136,	103,125,	104,126,	
12,47,	12,0,	111,133,	4,35,	
4,36,	4,37,	4,38,	11,45,	
11,45,	11,45,	11,45,	11,45,	
122,141,	11,45,	11,45,	11,45,	
114,135,	0,0,	11,45,	123,142,	
11,45,	11,45,	125,144,	11,45,	
11,45,	12,47,	11,45,	11,45,	
0,0,	116,136,	12,47,	0,0,	
0,0,	138,147,	12,47,	0,0,	
140,148,	11,45,	0,0,	12,47,	
0,0,	15,50,	0,0,	0,0,	
122,141,	141,149,	142,150,	0,0,	
149,152,	15,50,	15,0,	123,142,	
150,153,	0,0,	125,144,	0,0,	
12,47,	12,47,	12,47,	12,47,	
12,47,	0,0,	12,47,	12,47,	
12,47,	138,147,	0,0,	12,47,	
140,148,	12,47,	12,47,	152,154,	
12,47,	12,47,	15,50,	12,47,	
12,47,	141,149,	142,150,	15,51,	
149,152,	0,0,	0,0,	15,50,	
150,153,	63,95,	12,47,	63,95,	
15,50,	0,0,	63,96,	63,96,	
63,96,	63,96,	63,96,	63,96,	
63,96,	63,96,	63,96,	63,96,	
0,0,	0,0,	0,0,	152,154,	
0,0,	15,50,	15,50,	15,50,	
15,50,	15,50,	0,0,	15,50,	
15,50,	15,50,	0,0,	0,0,	
15,50,	0,0,	15,50,	15,50,	
0,0,	15,50,	15,50,	0,0,	
15,50,	15,50,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	24,61,	15,50,	
24,62,	24,62,	24,62,	24,62,	
24,62,	24,62,	24,62,	24,62,	
24,62,	24,62,	95,96,	95,96,	
95,96,	95,96,	95,96,	95,96,	
95,96,	95,96,	95,96,	95,96,	
24,63,	24,64,	0,0,	0,0,	
24,65,	24,66,	64,97,	0,0,	
64,97,	0,0,	0,0,	64,98,	
64,98,	64,98,	64,98,	64,98,	
64,98,	64,98,	64,98,	64,98,	
64,98,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	0,0,	
24,63,	24,64,	0,0,	0,0,	
24,65,	24,66,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
0,0,	0,0,	0,0,	0,0,	
30,70,	0,0,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
30,70,	30,70,	30,70,	30,70,	
41,79,	0,0,	0,0,	0,0,	
0,0,	90,113,	0,0,	90,113,	
41,79,	41,0,	90,114,	90,114,	
90,114,	90,114,	90,114,	90,114,	
90,114,	90,114,	90,114,	90,114,	
97,98,	97,98,	97,98,	97,98,	
97,98,	97,98,	97,98,	97,98,	
97,98,	97,98,	0,0,	0,0,	
0,0,	41,79,	0,0,	0,0,	
0,0,	0,0,	41,79,	0,0,	
0,0,	0,0,	41,79,	91,115,	
0,0,	91,115,	0,0,	41,79,	
91,116,	91,116,	91,116,	91,116,	
91,116,	91,116,	91,116,	91,116,	
91,116,	91,116,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
41,79,	41,79,	41,79,	41,79,	
41,79,	0,0,	41,79,	41,79,	
41,79,	0,0,	0,0,	41,79,	
0,0,	41,79,	41,79,	0,0,	
41,79,	41,79,	0,0,	41,79,	
41,79,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	41,79,	43,59,	
43,59,	43,59,	43,59,	43,59,	
43,59,	43,59,	43,59,	43,59,	
43,59,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
43,81,	0,0,	43,82,	0,0,	
43,83,	0,0,	43,84,	0,0,	
0,0,	0,0,	0,0,	43,85,	
0,0,	43,86,	43,87,	0,0,	
0,0,	0,0,	0,0,	61,93,	
61,93,	61,93,	61,93,	61,93,	
61,93,	61,93,	61,93,	61,93,	
61,93,	0,0,	0,0,	0,0,	
43,81,	0,0,	43,82,	0,0,	
43,83,	0,0,	43,84,	61,63,	
61,64,	0,0,	0,0,	43,85,	
61,94,	43,86,	43,87,	113,114,	
113,114,	113,114,	113,114,	113,114,	
113,114,	113,114,	113,114,	113,114,	
113,114,	115,116,	115,116,	115,116,	
115,116,	115,116,	115,116,	115,116,	
115,116,	115,116,	115,116,	0,0,	
0,0,	0,0,	0,0,	61,63,	
61,64,	117,137,	0,0,	117,137,	
61,94,	0,0,	117,138,	117,138,	
117,138,	117,138,	117,138,	117,138,	
117,138,	117,138,	117,138,	117,138,	
118,139,	0,0,	118,139,	0,0,	
0,0,	118,140,	118,140,	118,140,	
118,140,	118,140,	118,140,	118,140,	
118,140,	118,140,	118,140,	137,138,	
137,138,	137,138,	137,138,	137,138,	
137,138,	137,138,	137,138,	137,138,	
137,138,	139,140,	139,140,	139,140,	
139,140,	139,140,	139,140,	139,140,	
139,140,	139,140,	139,140,	153,154,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	153,154,	
153,155,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
153,154,	0,0,	0,0,	0,0,	
0,0,	153,154,	0,0,	0,0,	
0,0,	153,154,	0,0,	0,0,	
0,0,	0,0,	153,153,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	153,153,	
153,153,	153,153,	153,153,	153,153,	
0,0,	153,153,	153,153,	153,153,	
0,0,	0,0,	153,153,	0,0,	
153,153,	153,153,	154,154,	153,153,	
153,153,	0,0,	153,153,	153,153,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	153,153,	0,0,	154,154,	
154,154,	154,154,	154,154,	154,154,	
0,0,	154,154,	154,154,	154,154,	
0,0,	0,0,	154,154,	0,0,	
154,154,	154,154,	0,0,	154,154,	
154,154,	0,0,	154,154,	154,154,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	154,154,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
-1,	0,		0,	
-72,	yysvec+1,	0,	
-111,	yysvec+1,	0,	
-180,	yysvec+1,	0,	
0,	0,		yyvstop+1,
0,	0,		yyvstop+3,
0,	0,		yyvstop+6,
0,	0,		yyvstop+8,
0,	0,		yyvstop+11,
3,	0,		yyvstop+14,
-242,	0,		yyvstop+17,
-291,	0,		yyvstop+19,
0,	0,		yyvstop+22,
14,	0,		yyvstop+25,
-340,	0,		yyvstop+28,
0,	0,		yyvstop+30,
0,	0,		yyvstop+33,
15,	0,		yyvstop+36,
10,	0,		yyvstop+39,
0,	0,		yyvstop+42,
75,	0,		yyvstop+46,
126,	0,		yyvstop+49,
4,	0,		yyvstop+52,
388,	0,		yyvstop+55,
0,	0,		yyvstop+58,
0,	0,		yyvstop+61,
17,	0,		yyvstop+64,
26,	0,		yyvstop+67,
27,	0,		yyvstop+70,
429,	0,		yyvstop+73,
0,	0,		yyvstop+76,
0,	0,		yyvstop+79,
28,	0,		yyvstop+82,
6,	0,		yyvstop+85,
0,	0,		yyvstop+87,
30,	0,		yyvstop+90,
0,	0,		yyvstop+93,
29,	0,		yyvstop+96,
89,	0,		yyvstop+99,
0,	yysvec+39,	yyvstop+102,
-551,	0,		yyvstop+105,
19,	yysvec+30,	yyvstop+108,
599,	0,		yyvstop+111,
0,	0,		yyvstop+114,
-2,	yysvec+11,	0,	
0,	0,		yyvstop+116,
-4,	yysvec+12,	yyvstop+118,
32,	0,		yyvstop+120,
0,	0,		yyvstop+122,
-7,	yysvec+15,	0,	
0,	0,		yyvstop+124,
38,	0,		yyvstop+126,
0,	0,		yyvstop+128,
0,	0,		yyvstop+130,
0,	0,		yyvstop+132,
0,	0,		yyvstop+134,
0,	0,		yyvstop+136,
0,	0,		yyvstop+138,
160,	yysvec+22,	yyvstop+140,
0,	0,		yyvstop+142,
635,	0,		yyvstop+144,
0,	yysvec+24,	yyvstop+146,
342,	0,		0,	
419,	0,		0,	
0,	0,		yyvstop+148,
0,	0,		yyvstop+150,
0,	0,		yyvstop+152,
0,	0,		yyvstop+154,
0,	0,		yyvstop+156,
0,	yysvec+30,	yyvstop+158,
0,	0,		yyvstop+160,
0,	yysvec+34,	0,	
0,	0,		yyvstop+162,
0,	0,		yyvstop+164,
39,	0,		yyvstop+166,
0,	0,		yyvstop+168,
0,	yysvec+39,	0,	
25,	0,		0,	
-8,	yysvec+41,	yyvstop+170,
39,	yysvec+30,	yyvstop+172,
50,	0,		0,	
135,	0,		0,	
78,	0,		0,	
161,	0,		0,	
179,	0,		0,	
178,	0,		0,	
79,	0,		0,	
0,	0,		yyvstop+174,
0,	0,		yyvstop+176,
514,	0,		0,	
552,	0,		0,	
0,	0,		yyvstop+178,
186,	yysvec+61,	yyvstop+180,
0,	0,		yyvstop+183,
398,	0,		0,	
94,	yysvec+95,	yyvstop+185,
524,	0,		0,	
114,	yysvec+97,	yyvstop+187,
0,	0,		yyvstop+189,
183,	0,		0,	
180,	yysvec+30,	yyvstop+191,
196,	0,		0,	
188,	0,		0,	
185,	0,		0,	
12,	0,		0,	
55,	0,		0,	
56,	0,		0,	
65,	0,		0,	
69,	0,		0,	
76,	0,		0,	
186,	0,		0,	
93,	0,		0,	
663,	0,		0,	
211,	yysvec+113,	yyvstop+193,
673,	0,		0,	
224,	yysvec+115,	yyvstop+195,
694,	0,		0,	
709,	0,		0,	
0,	0,		yyvstop+197,
0,	0,		yyvstop+200,
0,	0,		yyvstop+202,
236,	0,		0,	
234,	yysvec+30,	yyvstop+204,
94,	0,		0,	
254,	0,		0,	
95,	0,		0,	
0,	0,		yyvstop+206,
0,	0,		yyvstop+208,
0,	0,		yyvstop+210,
0,	0,		yyvstop+212,
0,	0,		yyvstop+214,
0,	0,		yyvstop+216,
96,	0,		0,	
0,	0,		yyvstop+218,
0,	0,		yyvstop+220,
0,	0,		yyvstop+222,
719,	0,		0,	
260,	yysvec+137,	yyvstop+224,
729,	0,		0,	
263,	yysvec+139,	yyvstop+227,
260,	0,		0,	
278,	yysvec+30,	yyvstop+230,
0,	0,		yyvstop+232,
102,	0,		0,	
0,	0,		yyvstop+234,
0,	0,		yyvstop+236,
0,	0,		yyvstop+238,
0,	0,		yyvstop+241,
280,	0,		0,	
283,	yysvec+30,	yyvstop+244,
0,	0,		yyvstop+246,
302,	0,		0,	
-786,	0,		yyvstop+248,
-818,	yysvec+153,	0,	
0,	0,		yyvstop+250,
0,	0,	0};
#define yytop 913
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,'"' ,01  ,01  ,01  ,01  ,047 ,
01  ,01  ,01  ,'+' ,01  ,'+' ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'B' ,'G' ,
'H' ,'I' ,'B' ,'B' ,'L' ,'B' ,'N' ,'O' ,
'B' ,'Q' ,'R' ,'B' ,'T' ,'U' ,'B' ,'B' ,
'B' ,'B' ,'B' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'B' ,'G' ,
'H' ,'I' ,'B' ,'B' ,'L' ,'B' ,'N' ,'O' ,
'B' ,'Q' ,'R' ,'B' ,'T' ,'U' ,'B' ,'B' ,
'B' ,'B' ,'B' ,01  ,01  ,01  ,01  ,01  ,
0};
char yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
int yylineno =1;
# define YYU(x) x
# define NLSTATE yyprevious=YYNEWLINE
char yytext[YYLMAX];
struct yysvf *yylstate [YYLMAX], **yylsp, **yyolsp;
char yysbuf[YYLMAX];
char *yysptr = yysbuf;
int *yyfnd;
extern struct yysvf *yyestate;
int yyprevious = YYNEWLINE;
yylook(){
	register struct yysvf *yystate, **lsp;
	register int yyt;
	register struct yywork *yyk;
	struct yysvf *yyz;
	int yych;
	int yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	if (!yymorfg)
		yylastch = yytext;
	else {
		yymorfg=0;
		yylastch = yytext+yyleng;
		}
	for(;;){
		lsp = yylstate;
		yyestate = yystate = yybgin;
		if (yyprevious==YYNEWLINE) yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(yyout,"state %d\n",yystate-yysvec-1);
# endif
			yyt = yystate->yystoff;
			if(yyt == 0){		/* may not be any transitions */
				yyz = yystate->yyother;
				if(yyz == 0)break;
				if(yyz->yystoff == 0)break;
				}
			*yylastch++ = yych = input();
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"char ");
				allprint(yych);
				putchar('\n');
				}
# endif
			yyr = yyt;
			if ( yyt > 0){
				yyt = yyr + yych;
				yyk = yycrank + yyt;
				if (yyt <= yytop && yyk->verify+yysvec == yystate){
					if(yyk->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyk->advance+yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if(yyt < 0) {		/* r < yycrank */
				yyt = yyr = -yyt;
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"compressed state\n");
# endif
				yyt = yyt + yych;
				yyk = yycrank + yyt;
				if(yyt <= yytop && yyk->verify+yysvec == yystate){
					if(yyk->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyk->advance+yysvec;
					goto contin;
					}
				yyt = yyr + YYU(yymatch[yych]);
				yyk = yycrank + yyt;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"try fall back character ");
					allprint(YYU(yymatch[yych]));
					putchar('\n');
					}
# endif
				if(yyt <= yytop && yyk->verify+yysvec == yystate){
					if(yyk->advance+yysvec == YYLERR)	/* error transition */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyk->advance+yysvec;
					goto contin;
					}
				}
			if ((yystate = yystate->yyother) && (yyt= yystate->yystoff) != 0){
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"fall back to state %d\n",yystate-yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"state %d char ",yystate-yysvec-1);
				allprint(yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(yyout,"stopped at %d with ",*(lsp-1)-yysvec-1);
			allprint(yych);
			putchar('\n');
			}
# endif
		while (lsp-- > yylstate){
			*yylastch-- = 0;
			if (*lsp != 0 && (yyfnd= (*lsp)->yystops) && *yyfnd > 0){
				yyolsp = lsp;
				if(yyextra[*yyfnd]){		/* must backup */
					while(yyback((*lsp)->yystops,-*yyfnd) != 1 && lsp > yylstate){
						lsp--;
						unput(*yylastch--);
						}
					}
				yyprevious = YYU(*yylastch);
				yylsp = lsp;
				yyleng = yylastch-yytext+1;
				yytext[yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"\nmatch ");
					sprint(yytext);
					fprintf(yyout," action %d\n",*yyfnd);
					}
# endif
				return(*yyfnd++);
				}
			unput(*yylastch);
			}
		if (yytext[0] == 0  /* && feof(yyin) */)
			{
			yysptr=yysbuf;
			return(0);
			}
		yyprevious = yytext[0] = input();
		if (yyprevious>0)
			output(yyprevious);
		yylastch=yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
#ifdef __cplusplus
yyback(int *p, int m)
#else
yyback(p, m)
	int *p;
#endif
{
if (p==0) return(0);
while (*p)
	{
	if (*p++ == m)
		return(1);
	}
return(0);
}
	/* the following are only used in the lex library */
yyinput(){
	return(input());
	}
#ifdef __cplusplus
yyoutput(int c)
#else
yyoutput(c)
  int c;
#endif
{
	output(c);
	}
#ifdef __cplusplus
yyunput(int c)
#else
yyunput(c)
   int c;
#endif
{
	unput(c);
	}
