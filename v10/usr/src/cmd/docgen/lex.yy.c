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

#line 2 "trans.l"
#include <sys/types.h>
#include <pwd.h>
#include <sys/stat.h>
#include <time.h>
#include <libc.h>
#include "header.h"

#define DATE DOCNUM+6
#define SEQNUM DOCNUM+13
#define TYPE DOCNUM+15
#define SOFT DOCNUM+17
struct passwd *getpwuid(), *ps;
int soft;
char *p, *s1, *s2;
int type, ci=0, pm=0, rl=0;
char buf[HEADSIZE];
char *co = &buf[CO];
char *dept = &buf[DOCNUM], *date = &buf[DATE], *seqnum = &buf[SEQNUM];
char *stype = &buf[TYPE], *ssoft = &buf[SOFT];
char *machine = buf;
char *login = &buf[ULOG], *timestamp = &buf[TIMESTAMP];
char *version = &buf[VERSION];
char *pages = &buf[PAGES];
int more = 1;
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 28 "trans.l"
;
break;
case 2:

#line 29 "trans.l"
{
	printf(".TL\n");
	}
break;
case 3:

#line 32 "trans.l"
;
break;
case 4:

#line 33 "trans.l"
{
	yytext[yyleng] = '\0';
	p = strtok(&yytext[3], " \n");
	printf(".AU %s", p);
	if (*p == '"') {
		p = strtok((char *)0, "\"");
		printf(" %s", p);
	}
	p = strtok((char *)0, "\n");
	printf(" \"\"%s\n", p);
	}
break;
case 5:

#line 44 "trans.l"
{
	yytext[yyleng] = '\0';
	printf(".rP %s\n",&yytext[3]);
	}
break;
case 6:

#line 48 "trans.l"
{
	printf(".AS\n");
	}
break;
case 7:

#line 51 "trans.l"
{
	printf(".AE\n");
	}
break;
case 8:

#line 54 "trans.l"
{
	printf(".OK %s\n",&yytext[3]);
	}
break;
case 9:

#line 57 "trans.l"
{
	for(p = &yytext[3]; *p == ' ';p++);
	if(*p == 'I')type=2;
	else if(*(p+1) == 'M')type=1;
	else type=3;
	*stype = *p;
	*(stype+1) = *(p+1);
	while(*p != ' '){
		if(*p == '\n'){
			soft=0;
			break;
		}
		p++;
	}
	if(*p == ' ')
		if(*++p == 'y')
			soft=1;
	printf(".MT %d\n",type);
	if(soft){
		*ssoft = 'S';
		printf(".sF\n");
	}
	}
break;
case 10:

#line 80 "trans.l"
{
	for(p = &yytext[3]; *p == ' ';p++);
	if(*p == '1') {
		type=1;
		*stype = 'T';
		*(stype+1) = 'M';
	} else if(*p == '2') {
		type=2;
		*stype = 'I';
		*(stype+1) = 'M';
	} else type=3;
	printf(".MT %d\n",type);
	}
break;
case 11:

#line 93 "trans.l"
{
	soft = 1;
	*ssoft = 'S';
	printf(".sF\n");
	}
break;
case 12:

#line 98 "trans.l"
{
	p = strtok(&yytext[3], "- \n\"");
	if(p != 0){
		sprintf(dept,"%s-",p);
		printf(".dN %s-",p);
		type = 1;
	}
	p = strtok((char *)0, "- \n\"");
	if(p != 0){
		sprintf(date,"%s-",p);
		printf("%s-",p);
	}
	p = strtok((char *)0, "- \n\"");
	if(p != 0){
		*seqnum = *p;
		*(seqnum+1) = *(p+1);
		printf("%s\n",p);
	}
	else if(type) printf("\n");
	p = strtok((char *)0, " \n\"");
	if(p != 0)
		printf(".fC %s\n",p);
	p = strtok((char *)0, " \n\"");
	if(p != 0)
		printf(".wP %s\n",p);
	}
break;
case 13:

#line 124 "trans.l"
{
	printf(".mE %s\n",&yytext[3]);
	}
break;
case 14:

#line 127 "trans.l"
{
	printf(".eD %s'n",&yytext[3]);
	}
break;
case 15:

#line 130 "trans.l"
{
	pm=1;
	printf(".PM %s\n",&yytext[3]);
	}
break;
case 16:

#line 134 "trans.l"
{
	rl=1;
	if(yyleng>3){
		p=&yytext[3];
		while(*p == ' ')p++;
		if(*p == '\"')p++;
		if(*p == 'n')printf(".fA n\n");
		else printf(".fA y\n");
	}
	else printf(".fA y\n");
	}
break;
case 17:

#line 145 "trans.l"
{
	printf(".gS\n");
	}
break;
case 18:

#line 148 "trans.l"
{
/*	ci = 1;		gone away
	if(yyleng == 3)
		printf(".cI n\n");
	else {
		p = &yytext[3];
		while(*p == ' ')p++;
		if(*p == '\n' || *p == 'n')
			printf(".cI n\n");
		else if(*p == '\"')p++;
		if(*p == 'y')
			printf(".cI y\n");
		else if(*p == '\"' || *p == 'n')
			printf(".cI n\n");
		else	fprintf(stderr,".CI unknown argument %c\n",*p);
	}*/
	}
break;
case 19:

#line 165 "trans.l"
{
/*	if(!ci){
		printf(".cI n\n");
		ci = 1;
	}*/
	if(!rl){
		printf(".fA y\n");
		rl = 1;
	}
	printf(".cC\n");
	}
break;
case 20:

#line 176 "trans.l"
{
	printf(".cE\n");
	}
break;
case 21:

#line 179 "trans.l"
{
/*	if(!ci){
		printf(".cI n\n");
		ci = 1;
	}*/
	if(!rl){
		printf(".fA y\n");
		rl = 1;
	}
	printf(".cS\n");
	}
break;
case 22:

#line 190 "trans.l"
{
	ECHO;
	printf("\n");
	return(0);
	}
break;
case 23:

#line 195 "trans.l"
{
/*	if(!ci){
		printf(".cI n\n");
		ci = 1;
	}*/
	if(!rl){
		printf(".fA y\n");
		rl = 1;
	}
	p = s1 = &yytext[3];
	while(*s1 == ' ')s1++;
	while(*s1 != ' ')s1++;
	while(*s1 == ' ')s1++;
	while(*s1 != ' ')s1++;
	*s1 = '\0';
	s1++;
	printf(".CS %s \"\" %s\n", p, s1);
	return(0);
	}
break;
case 24:

#line 214 "trans.l"
{
	ECHO;
	printf("\n");
	}
break;
case 25:

#line 218 "trans.l"
;
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

#line 220 "trans.l"
char *header="/tmp/            ";
char *dest = "mhuxd!/usr/spool/uucppublic/doc.mcs";
char *dco = "BL";
main(argc, argv)
char *argv[];
{
	FILE *inp;
	char *filename, *name, *cover, *pid;
	int nuchars, npid, uid, days;
	long mtime;
	if(argc < 3){
		fprintf(stderr,"file name must be supplied to sendcover\n");
		exit(1);
	}
	if((inp=fopen("/etc/whoami","r")) == NULL){
		fprintf(stderr,"can't open /etc/whoami\n");
		exit(1);
	}
	nuchars = fread(machine, sizeof(char), 10, inp);
	nuchars -= 1;
	if(nuchars < 5)pid = machine + nuchars +1;
	else pid = machine + 6;
	cover = pid + 5;
	fclose(inp);
	*(pid-1) = '.';
	npid = getpid();
	sprintf(pid,"%05d",npid);
	*cover = 'c';
	sprintf(&header[5],"%s",machine);
	uid = getuid();
	if ((ps = getpwuid(uid)) == NULL){
		fprintf(stderr, "login not found");
		exit(1);
	}
	strcpy (login,ps->pw_name);
	sprintf(version,"030388L");	/*version*/
	strcpy(co, dco);	/*company name=BL*/
	name = argv[1];
	argc--; argv++;
	if(freopen(argv[1],"r",stdin)==NULL) {
		fprintf(stderr,"%s: cannot open\n", argv[1]);
		exit(1);
	}
	if(freopen(header,"w",stdout)== NULL){
		fprintf(stderr,"%s: cannot open\n",header);
		exit(1);
	}
	if((nuchars = fwrite(buf,sizeof(char),HEADSIZE,stdout)) != HEADSIZE){
		fprintf(stderr,"wrong number of characters written %d\n",nuchars);
			exit(1);
	}
	filename = argv[1];
	mtime = getstamp(filename);
	sprintf(timestamp,"%ld",mtime);
	argv++;
	sprintf(pages,"TP%s",argv[1]);
	yylex();
	rewind(stdout);
	for(p=buf; p < &buf[HEADSIZE-1]; p++)
		if(*p == '\0')*p = ' ';
	*p = '\n';
	if((nuchars = fwrite(buf,sizeof(char),HEADSIZE,stdout)) != HEADSIZE){
		fprintf(stderr,"wrong number of characters written %d\n",nuchars);
			exit(1);
	}
	*(cover+1) = '\0';
	if((inp=fopen(name,"a")) == NULL){
		fprintf(stderr,"can't open tmp file %s\n",name);
		exit(1);
	}
	fprintf(inp,"cd /tmp; uucp -m -C %s %s; rm %s\n",machine,dest,machine);
	fclose(inp);
}	
int yyvstop[] = {
0,

24,
0,

24,
0,

24,
0,

25,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

24,
0,

4,
24,
0,

5,
24,
0,

20,
24,
0,

18,
24,
0,

19,
24,
0,

22,
24,
0,

21,
24,
0,

3,
24,
0,

14,
24,
0,

17,
24,
0,

8,
24,
0,

10,
24,
0,

13,
24,
0,

12,
24,
0,

15,
24,
0,

16,
24,
0,

6,
24,
0,

23,
24,
0,

7,
24,
0,

2,
24,
0,

9,
24,
0,

11,
24,
0,

1,
24,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,3,	0,0,	
5,3,	6,3,	8,3,	11,3,	
9,3,	10,3,	13,3,	1,4,	
3,0,	5,0,	6,0,	8,0,	
11,0,	9,0,	10,0,	13,0,	
7,3,	12,3,	15,3,	17,3,	
18,3,	14,3,	20,20,	19,3,	
21,21,	7,0,	12,0,	15,0,	
17,0,	18,0,	14,0,	20,0,	
19,0,	21,0,	22,0,	23,23,	
24,24,	25,25,	26,26,	27,27,	
16,3,	28,28,	29,0,	2,5,	
23,0,	24,0,	25,0,	26,0,	
27,0,	16,0,	28,0,	30,30,	
31,31,	32,32,	33,33,	36,0,	
34,34,	38,0,	39,0,	0,0,	
30,0,	31,0,	32,0,	33,0,	
5,6,	34,0,	5,7,	5,8,	
5,9,	35,35,	5,10,	9,28,	
6,20,	0,0,	5,11,	0,0,	
5,12,	5,13,	35,0,	5,14,	
6,21,	5,15,	5,16,	5,17,	
7,22,	8,27,	37,37,	10,29,	
7,23,	11,30,	13,33,	17,39,	
19,41,	15,35,	7,24,	37,0,	
0,0,	18,33,	7,25,	5,18,	
12,31,	7,26,	14,34,	40,40,	
16,36,	12,32,	16,37,	17,40,	
16,38,	41,41,	42,42,	0,0,	
40,0,	0,0,	5,19,	0,0,	
0,0,	0,0,	41,0,	42,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	19,42,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
-1,	0,		yyvstop+1,
-1,	yysvec+1,	yyvstop+3,
-2,	yysvec+1,	yyvstop+5,
0,	0,		yyvstop+7,
-3,	0,		yyvstop+9,
-4,	0,		yyvstop+11,
-19,	0,		yyvstop+13,
-5,	0,		yyvstop+15,
-7,	0,		yyvstop+17,
-8,	0,		yyvstop+19,
-6,	0,		yyvstop+21,
-20,	0,		yyvstop+23,
-9,	0,		yyvstop+25,
-24,	0,		yyvstop+27,
-21,	0,		yyvstop+29,
-43,	0,		yyvstop+31,
-22,	0,		yyvstop+33,
-23,	0,		yyvstop+35,
-26,	0,		yyvstop+37,
-25,	0,		yyvstop+39,
-27,	0,		yyvstop+42,
-28,	yysvec+1,	yyvstop+45,
-38,	0,		yyvstop+48,
-39,	0,		yyvstop+51,
-40,	0,		yyvstop+54,
-41,	0,		yyvstop+57,
-42,	0,		yyvstop+60,
-44,	0,		yyvstop+63,
-36,	yysvec+1,	yyvstop+66,
-54,	0,		yyvstop+69,
-55,	0,		yyvstop+72,
-56,	0,		yyvstop+75,
-57,	0,		yyvstop+78,
-59,	0,		yyvstop+81,
-72,	0,		yyvstop+84,
-49,	yysvec+1,	yyvstop+87,
-89,	0,		yyvstop+90,
-51,	yysvec+1,	yyvstop+93,
-52,	yysvec+1,	yyvstop+96,
-106,	0,		yyvstop+99,
-112,	0,		yyvstop+102,
-113,	0,		yyvstop+105,
0,	0,	0};
#define yytop 137
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
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
