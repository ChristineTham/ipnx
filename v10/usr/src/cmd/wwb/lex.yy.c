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

#line 2 "gram.l"
/* NOTICE-NOT TO BE DISCLOSED OUTSIDE BELL SYS EXCEPT UNDER WRITTEN AGRMT */
/* Writer's Workbench version 2.0, January 1981 */
#include <ctype.h>
int catch = 1;
int ct = 0;
int ret=0;
int linect = 0;
char name[50];
int i;
char *p;
FILE *fopen(), *cat;
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 15 "gram.l"
  search();
break;
case 2:

#line 16 "gram.l"
cons();
break;
case 3:

#line 17 "gram.l"
vowel();
break;
case 4:

#line 18 "gram.l"
linect = atoi(&yytext[1]);
break;
case 5:

#line 19 "gram.l"
{
		p = name;
		for(i=3;i<yyleng;i++)
			*p++ = yytext[i];
		}
break;
case 6:

#line 24 "gram.l"
      case 7:

#line 25 "gram.l"
     ;
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

#line 27 "gram.l"
cons(){
	int c;
	int f;
	char *w1;
	char w[100];
	w1 = w;
	while((c=input()) != '\t')*w1++ = c;
	if(strncmp("conj",w,4) == 0)return(ret);
	if(strncmp("prep",w,4) == 0)return(ret);
	if(strncmp("be",w,2) == 0)return(ret);
	if(strncmp("verb",w,4) == 0)return(ret);
	w1 = w;
	while((f=input()) == ' ');
	if(!isalpha(f))return(ret);
	if(isupper(f))return(ret);
	if(f == 'a'||f == 'e'||f =='i'||f =='o'||f == 'u'|| f == 'h'){
		*w1++ = f;
		while((c=input()) != '\n'){
			if(!isalpha(c))break;
			*w1++ = c;
		}
		if(w1 < &w[2])return(ret);
		*w1 = '\0';
		if(f == 'h'){
			if(hexc(w)== 0)return(ret);
		} else if(f == 'u'){
			if(uexc(w) == 1)return(ret);
		} else if(f == 'e'){
			if(w[1] == 'u')return(ret);
		} else if(f == 'o'){
			if(strncmp("one",w,3) == 0)return(ret);
			if(strncmp("once",w,4) == 0)return(ret);
		}
		ret = 1;
		if(++ct == 1)printf("Possible grammatical errors:\n");
		printf("\t\"a %s\" should be \"an %s\"",w,w);
		printf(" after line %d file %s\n",linect,name);
	}
	return(ret);
}
vowel(){
	int c,f;
	char *w1;
	char w[100];
	w1 = w;
	while((c=input()) != '\t')*w1++ = c;
	if(strncmp("conj",w,4) == 0)return(ret);
	if(strncmp("prep",w,4) == 0)return(ret);
	if(strncmp("be",w,4) == 0)return(ret);
	if(strncmp("verb",w,4) == 0)return(ret);
	w1 = w;
	while((f=input()) == ' ');
	if(!isalpha(f))return(ret);
	if(isupper(f))return(ret);
	if(f != 'a' && f != 'i' ){
		*w1++ = f;
		while((c=input()) != '\n'){
			if(!isalpha(c))break;
			*w1++ = c;
		}
		if(w1 < &w[2])return(ret);
		*w1 = '\0';
		if(f == 'h'){
			if(hexc(w))return(ret);
		}
		else if(f == 'u'){
			if(uexc(w) == 0)return(ret);
		} else if(f == 'e'){
			if(w[1] != 'u')return(ret);
		} else if(f == 'o' ){
			if( strncmp("one",w,3) != 0)return(ret);
			if(strncmp("once",w,4) != 0)return(ret);
		}
		ret = 1;
		if(++ct == 1)printf("Possible grammatical errors:\n");
		printf("\t\"an %s\" should be \"a %s\"",w,w);
		printf(" after line %d file %s\n",linect,name);
	}
	return(ret);
}
search()
{
	char *sv;
	int c;
	char *w1, *p1, *p2;
	char words[100];
	char part1[10],part2[10];
	int f;
#ifdef SPCATCH
	if(catch != 2){
		if((cat=fopen(SPCATCH,"a"))==NULL) catch=0;
		else catch = 2;
	}
#else
	catch=0;
#endif
	w1 = words;
	f = 0;
more:
	for(p1 = part1; (c= input())!= '\t';)
		*p1++ = c;
	while((c=input())!='\n')
		*w1++ = c;
	*w1++ = ' ';
	if(strncmp(part1,"adv",3) != 0)
		return(ret);

	while(1){
		for(p2=part2;(c=input())!='\t';)
			*p2++ = c;
		if(strncmp(part2,"verb",4) != 0)
			break;

		sv = w1;
		while((c=input())!='\n')
			*w1++ = c;
		if(strncmp(sv,"to",2) == 0 && w1 == sv+2)break;
		*w1++ = ' ';
		f = 1;
	}
	if(f == 0)return(ret);
	*w1 = '\0';
	if(++ct==1)printf("Possible grammatical errors:\n\n");
	printf("\tsplit infinitive: \"to %s\"",words);
	printf(" after line %d file %s\n",linect,name);
	if(catch == 2){
		fprintf(cat,"%s\n",words);
	}
	ret=1;
	return(ret);
}
hexc(w)
char *w;
{
	if(strncmp(w,"heir",4) == 0)return(1);
	if(strncmp(w,"herb",4) == 0)return(1);
	if(strncmp(w,"hour",4) == 0)return(1);
	if(strncmp(w,"honest",6) == 0)return(1);
	if(strncmp(w,"hombre",6) == 0)return(1);
	if(strncmp(w,"honor",4) == 0)return(1);
	return(0);
}
uexc(w)
char *w;
{
	int c1, c2;
	if(strncmp(w,"uni",3) == 0){
		if(*(w+3) != 'm' && *(w+3) != 'n')return(1);
		else return(0);
	}
	c1 = *(w+1);
	if(c1 == 'b' || c1 == 'k')return(1);
	c2 = *(w+2);
	if(c1 == 'r' || c1 == 's'){
		if(c2== 'a' || c2 == 'e' || c2 == 'i' || c2 == 'o' || c2 == 'u')
			return(1);
		else return(0);
	}
	if(strncmp("unanim",w,6) == 0)return(1);
	if(strncmp("unary",w,5) == 0)return(1);
	if(c1 == 't' && c2 != 't')return(1);
	return(0);
}
int yyvstop[] = {
0,

6,
0,

7,
0,

6,
0,

6,
0,

6,
0,

4,
0,

5,
0,

2,
0,

3,
0,

1,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,3,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	12,15,	1,4,	
16,18,	17,19,	20,22,	23,24,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	14,14,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
14,0,	11,14,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
2,7,	1,3,	7,10,	7,10,	
7,10,	7,10,	7,10,	7,10,	
7,10,	7,10,	7,10,	7,10,	
10,10,	10,10,	10,10,	10,10,	
10,10,	10,10,	10,10,	10,10,	
10,10,	10,10,	14,14,	0,0,	
7,11,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,5,	2,5,	
13,16,	15,17,	6,9,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
21,23,	17,20,	0,0,	5,8,	
9,13,	8,12,	18,21,	1,6,	
2,6,	0,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
-1,	0,		0,	
-2,	yysvec+1,	0,	
0,	0,		yyvstop+1,
0,	0,		yyvstop+3,
1,	0,		yyvstop+5,
1,	0,		yyvstop+7,
2,	0,		yyvstop+9,
1,	0,		0,	
2,	0,		0,	
12,	0,		yyvstop+11,
1,	0,		0,	
1,	0,		0,	
2,	0,		0,	
-22,	0,		yyvstop+13,
4,	0,		0,	
3,	0,		0,	
3,	0,		0,	
2,	0,		0,	
0,	0,		yyvstop+15,
4,	0,		0,	
1,	0,		0,	
0,	0,		yyvstop+17,
5,	0,		0,	
0,	0,		yyvstop+19,
0,	0,	0};
#define yytop 120
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
0};
char yyextra[] = {
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
