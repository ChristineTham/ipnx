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
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
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

#line 2 "rewrite.l"
#include <ctype.h>
int i;
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 7 "rewrite.l"
{
	for(i=0;i<yyleng;i++)
		if(yytext[i] == '\t')break;
	while(++i<yyleng-1){
		if(islower(yytext[i]))
			putchar(toupper(yytext[i]));
		else putchar(yytext[i]);
	}
	putchar(' ');
	}
break;
case 2:

#line 17 "rewrite.l"
{
	for(i=0;i<yyleng;i++)
		if(yytext[i] == '\t')break;
	while(++i<yyleng-1){
		if(islower(yytext[i]))
			putchar(toupper(yytext[i]));
		else putchar(yytext[i]);
	}
	putchar(' ');
	}
break;
case 3:

#line 27 "rewrite.l"
{
	printf("BE");
	putchar(' ');
	}
break;
case 4:

#line 31 "rewrite.l"
{
	for(i=0;i<yyleng;i++)
		if(yytext[i] == '\t')break;
	while(++i<yyleng-1){
		if(isupper(yytext[i]))
			putchar(tolower(yytext[i]));
		else
			putchar(yytext[i]);
	}
	putchar(' ');
	}
break;
case 5:

#line 42 "rewrite.l"
{
	putchar(yytext[2]);
	putchar('\n');
	}
break;
case 6:

#line 46 "rewrite.l"
{
	printf(" ...");
	}
break;
case 7:

#line 49 "rewrite.l"
{
	putchar(yytext[0]);
	}
break;
case 8:

#line 52 "rewrite.l"
{
	printf("``");
	}
break;
case 9:

#line 55 "rewrite.l"
{
	printf(" -- ");
	}
break;
case 10:

#line 58 "rewrite.l"
{
	printf(" .\"");
	}
break;
case 11:

#line 61 "rewrite.l"
{
	putchar(yytext[0]);
	}
break;
case 12:

#line 64 "rewrite.l"
{
	printf(" ''");
	}
break;
case 13:

#line 67 "rewrite.l"
{
	putchar(yytext[0]);
	}
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */
int yyvstop[] = {
0,

7,
0,

11,
0,

5,
0,

10,
0,

4,
0,

13,
0,

1,
4,
0,

12,
0,

9,
0,

8,
0,

2,
4,
0,

6,
0,

3,
4,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	3,13,	5,16,	
6,13,	4,14,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
7,18,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	2,3,	
0,0,	0,0,	9,21,	8,20,	
2,4,	2,3,	2,3,	4,15,	
15,28,	2,5,	2,6,	2,7,	
6,17,	2,8,	2,8,	2,8,	
2,8,	2,8,	2,8,	2,8,	
2,8,	2,8,	2,8,	2,5,	
2,5,	7,19,	17,30,	16,29,	
22,35,	23,36,	26,39,	27,40,	
29,42,	14,27,	32,45,	31,42,	
33,46,	28,41,	16,29,	34,47,	
16,29,	18,31,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
16,29,	16,29,	19,32,	30,43,	
2,3,	41,52,	2,3,	31,44,	
43,53,	2,9,	2,8,	2,10,	
2,8,	2,8,	2,8,	2,8,	
2,8,	2,8,	2,8,	2,8,	
2,8,	2,8,	2,8,	2,8,	
2,8,	2,11,	2,8,	2,8,	
2,8,	2,8,	2,8,	2,12,	
2,8,	2,8,	2,8,	2,8,	
2,3,	9,22,	2,3,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	10,23,	11,24,	12,25,	
13,26,	20,33,	21,34,	24,37,	
25,38,	35,48,	13,26,	13,26,	
36,49,	20,33,	20,0,	13,26,	
37,50,	38,51,	45,54,	48,55,	
36,49,	36,0,	49,56,	50,57,	
51,58,	52,59,	53,60,	54,61,	
55,62,	58,0,	61,65,	63,66,	
57,63,	64,46,	65,68,	67,69,	
0,0,	20,33,	20,33,	0,0,	
57,63,	57,0,	0,0,	0,0,	
36,49,	36,49,	0,0,	0,0,	
20,33,	0,0,	0,0,	0,0,	
20,33,	0,0,	0,0,	36,49,	
0,0,	0,0,	0,0,	36,49,	
0,0,	13,26,	0,0,	13,26,	
57,63,	57,63,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	57,63,	
0,0,	0,0,	0,0,	57,63,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	13,26,	0,0,	13,26,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	58,64,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
64,67,	0,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
0,	0,		0,	
1,	0,		0,	
1,	0,		0,	
4,	0,		0,	
2,	0,		0,	
3,	0,		0,	
15,	0,		0,	
30,	0,		0,	
29,	0,		0,	
52,	yysvec+8,	0,	
40,	yysvec+8,	0,	
54,	yysvec+8,	0,	
122,	0,		0,	
30,	0,		0,	
35,	0,		0,	
30,	0,		0,	
53,	0,		0,	
31,	yysvec+16,	0,	
44,	0,		0,	
-156,	0,		0,	
62,	0,		0,	
55,	0,		0,	
56,	yysvec+8,	0,	
58,	yysvec+8,	0,	
46,	yysvec+8,	0,	
56,	0,		0,	
57,	0,		0,	
34,	0,		0,	
58,	0,		0,	
46,	0,		0,	
61,	0,		0,	
61,	0,		0,	
-62,	yysvec+20,	0,	
65,	0,		0,	
65,	0,		0,	
-163,	0,		0,	
56,	yysvec+8,	0,	
71,	yysvec+8,	0,	
0,	0,		yyvstop+1,
0,	0,		yyvstop+3,
54,	0,		0,	
0,	0,		yyvstop+5,
51,	0,		0,	
0,	0,		yyvstop+7,
124,	0,		0,	
0,	0,		yyvstop+9,
0,	0,		yyvstop+11,
75,	0,		0,	
-164,	yysvec+36,	0,	
166,	yysvec+8,	0,	
167,	yysvec+8,	0,	
167,	0,		0,	
168,	0,		0,	
133,	0,		0,	
170,	0,		0,	
0,	0,		yyvstop+13,
-183,	0,		0,	
-171,	yysvec+20,	0,	
0,	0,		yyvstop+16,
0,	0,		yyvstop+18,
136,	0,		0,	
0,	0,		yyvstop+20,
-173,	yysvec+57,	0,	
-175,	yysvec+20,	0,	
176,	0,		0,	
0,	0,		yyvstop+22,
-177,	yysvec+20,	0,	
0,	0,		yyvstop+25,
0,	0,		yyvstop+27,
0,	0,	0};
#define yytop 276
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'!' ,'"' ,01  ,01  ,01  ,01  ,01  ,
'"' ,'"' ,01  ,01  ,',' ,'"' ,',' ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,',' ,',' ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,'"' ,01  ,'"' ,01  ,01  ,
01  ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,'0' ,'"' ,01  ,'"' ,01  ,01  ,
0};
char yyextra[] = {
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
