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

#line 2 "part.l"
#include "style.h"
#include "names.h"
#include "conp.h"
FILE *deb;
int lineflg = 0;
int nosave = 1;
int part = 0;
int barebones = 0;
int topic = 0;
int style = 1;
int pastyle = 0;
int pstyle = 0;
int sstyle = 0;
int lstyle = 0;
int rstyle = 0;
int estyle = 0;
int nstyle = 0;
int Nstyle = 0;
int sprint = 0;
int sthresh;
int lthresh;
int rthresh;
int nomin;
char s[SCHAR];
char *sptr = s;
struct ss sent[SLENG];
struct ss *sentp = sent;
float wperc();
float sperc();
float typersent();
float vperc();
int numsent = 0;
int qcount = 0;
int icount = 0;
long vowel = 0;
long numwds = 0;
long twds = 0;
long numnonf = 0;
long letnonf = 0;
int maxsent = 0;
int maxindex = 0;
int minsent = 30;
int minindex = 0;
int simple = 0;
int compound = 0;
int compdx = 0;
int prepc = 0;
int conjc = 0;
int complex = 0;
int tobe = 0;
int adj = 0;
int infin = 0;
int pron = 0;
int passive = 0;
int aux = 0;
int adv = 0;
int verbc = 0;
int tverbc = 0;
int noun = 0;
long numlet = 0;
int beg[15]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
int sleng[50];
int nsleng = 0;
int j,jj,i;
int comma = 0;
int cflg;
int question;
int quote = 0;
char *st;
int initf = 0;
int over = 1;
int nroff = 0;
int nrofflg = 0;
int leng[MAXPAR];
int sentno= 0;
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 80 "part.l"
{
collect:
	sentp->cc = sentp->ic = yytext[0];
	if(sentp->cc == NOM)
		sentp->cc = NOUN;
collect1:
	nsleng++;
	sentp->leng = yyleng-2;
	sentp++->sp = sptr;
	if(sentp >= &sent[SLENG-1]){
		if(over)fprintf(stderr,"Parts: (part.l) sentence %d too many words\n",numsent+2);
		over=0;
		sentp--;
	}
	if(sptr+yyleng >= &s[SCHAR-1]){
		if(over)fprintf(stderr,"sentence %d too many characters\n",numsent+2);
		over=0;
	}
	else {
		for(i=2;i<yyleng;i++)*sptr++=yytext[i];
		*sptr++ = '\0';
	}
	}
break;
case 2:

#line 103 "part.l"
{
	sentp->cc=END;
	sentp->ic = ';';
	goto collect1;
	}
break;
case 3:

#line 108 "part.l"
{
	comma++;
	goto collect;
	}
break;
case 4:

#line 112 "part.l"
{
	comma++;
	goto collect;
	}
break;
case 5:

#line 116 "part.l"
;
break;
case 6:

#line 117 "part.l"
{
	goto collect;
	}
break;
case 7:

#line 120 "part.l"
{
	cflg = 1;
	goto sdone;
	}
break;
case 8:

#line 124 "part.l"
{
	cflg = 0;
sdone:
	over=1;
	sentp->cc=sentp->ic=END;
	sentp++->sp = sptr;
	for(i=2;i<yyleng;i++)*sptr++=yytext[i];
	*sptr++='\0';
	if(yytext[2]=='?')question=1;
	else question=0;

fragment:
	jj=0;
	if(quote == 1 && sent[jj].cc == ED){
		sent[jj].cc = VERB;
		quote = 0;
	}
	if(sent[jj].cc=='"')jj++;
	if(sent[jj].cc==SUBCONJ){
		if(sent[jj+1].cc == ','){
			sent[jj].cc=ADV;
			jj += 2;
			comma--;
		}
		else {
			jj=scan(1,',',0);
			if(jj != -1)jj++;
			comma--;
		}
	}
	if(jj != -1){
		if(sent[jj].cc==CONJ || sent[jj].cc=='"')jj++;
		while((jj=scan(jj,END,cflg)) != -1){
			jj++;
			if(sent[jj].cc == SUBCONJ && sent[jj+1].cc == ','){
				sent[jj].cc=ADV;
				jj += 2;
				comma--;
			}
		}
	}
	st = sent[i].sp;
	if(*(st+1) == '"')
		if(*st == '?' || *st == '!')quote = 1;
	outp();
	nsleng = 0;
	if(nroff){
		if(sentno > 0){
			printf(".SL \"");
			for(i=0;i<sentno;i++)
				printf(" %d",leng[i]);
			printf("\"\n");
			sentno = 0;
		}
		printf("%s",&yytext[1]);
		nroff = 0;
	}
	sptr=s;
	sentp=sent;
	comma=0;
	}
break;
case 9:

#line 185 "part.l"
{
	if(style){
		nomin = atoi(&yytext[1]);
	}
	}
break;
case 10:

#line 190 "part.l"
{
	if(lineflg == 2){
		nrofflg=1;
		if(sentp != sent){
			sentp->cc = sentp->ic = END;
			sentp++->sp = sptr;
			*sptr++ = '.';
			*sptr++ = '\0';
			over = 1;
			nroff = 1;
			goto fragment;
		}
		if(sentno > 0){
			printf(".SL \"");
			for(i=0;i<sentno;i++)
				printf(" %d",leng[i]);
			printf("\"\n");
			sentno = 0;
		}
	}
	if(lineflg)
		printf("%s",&yytext[1]);
	}
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

#line 214 "part.l"
yywrap(){
	int ii;
	int ml,mg,lsum,gsum;
	float aindex, avl, avw;
	float cindex,kindex,findex,fgrad;
	float syl, avsy, adjs,snonf;
	FILE *io;

	if(style){
	if(numwds == 0 || numsent == 0)exit(0);
	avw = (float)(numwds)/(float)(numsent);
	avl = (float)(numlet)/(float)(numwds);
	aindex = 4.71*avl + .5*avw -21.43;
	syl = .9981*vowel-.3432*twds;
	avsy = syl/twds;
	kindex = 11.8*avsy+.39*avw-15.59;
	findex = 206.835-84.6*avsy-1.015*avw;
	if(findex < 30.)fgrad = 17.;
	else if(findex > 100.) fgrad = 4.;
	else if(findex > 70.)fgrad=(100.-findex)/10 +5.;
	else if(findex > 60.)fgrad =(70.-findex)/10+8.;
	else if(findex >50.)fgrad=(60.-findex)/5+10;
	else fgrad=(50.-findex)/6.66 +13.;
	adjs = 100 * (float)numsent/numwds;
	cindex = 5.89*avl-.3*adjs-15.8;
	if(!sprint){
	printf("readability grades:\n	(Kincaid) %4.1f  (auto) %4.1f  (Coleman-Liau) %4.1f  (Flesch) %4.1f (%4.1f)\n",kindex,aindex,cindex,fgrad,findex);
	printf("sentence info:\n");
	printf("	no. sent %d no. wds %ld\n",numsent,numwds);
	printf("	av sent leng %4.1f av word leng %4.2f\n",avw,avl);
	printf("	no. questions %d no. imperatives %d\n",qcount,icount);
	}
	else {
		printf("%4.1f %4.1f %4.1f %4.1f %4.1f\n",kindex,aindex,cindex,fgrad,
			findex);
		printf("%d %ld %4.1f %4.2f %d %d\n",numsent,numwds,avw,avl,
			qcount, icount);
	}
	if(numnonf != 0){
		snonf = (float)(letnonf)/(float)(numnonf);
	}
	mg = avw + 10.5;
	if(mg > 49)mg = 49;
	ml = avw - 4.5;
	if(ml <= 0)ml = 1;
	else if(ml > 49)ml=48;
	gsum = lsum = 0;
	for(ii=0;ii<50;ii++){
		if(ii < ml)lsum += sleng[ii];
		else if(ii > mg)gsum+= sleng[ii];
	}
	if(verbc != 0)adjs = (float)(passive)*100/(float)(verbc);
	else adjs=0;
	ii=beg[0]+beg[7]+beg[6]+beg[3]+beg[8];
	if(!sprint){
	printf("	no. content wds %ld  %4.1f%%   av leng %4.2f\n",numnonf,(float)(numnonf)*100/numwds,snonf);
	printf("	short sent (<%d)%3.0f%% (%d) long sent (>%d) %3.0f%% (%d)\n",ml,sperc(lsum),lsum,mg,sperc(gsum),gsum);
	printf("	longest sent %d wds at sent %d; shortest sent %d wds at sent %d\n",maxsent,maxindex,minsent,minindex);
	printf("sentence types:\n");
	printf("	simple %3.0f%% (%d) complex %3.0f%% (%d)\n",sperc(simple),simple,sperc(complex),complex);
	printf("	compound %3.0f%% (%d) compound-complex %3.0f%% (%d)\n",sperc(compound),compound,sperc(compdx),compdx);
	printf("word usage:\n");
	printf("	verb types as %% of total verbs\n");
	printf("	tobe %3.0f%% (%d) aux %3.0f%% (%d) inf %3.0f%% (%d)\n",vperc(tobe),tobe,vperc(aux),aux,vperc(infin),infin);
	printf("	passives as %% of non-inf verbs %3.0f%% (%d)\n",adjs,passive);
	printf("	types as %% of total\n");
	printf("	prep %3.1f%% (%d) conj %3.1f%% (%d) adv %3.1f%% (%d)\n",wperc(prepc),prepc,wperc(conjc),conjc,wperc(adv),adv);
	printf("	noun %3.1f%% (%d) adj %3.1f%% (%d) pron %3.1f%% (%d)\n",wperc(noun),noun,
		wperc(adj),adj,wperc(pron),pron);
	printf("	nominalizations %3.0f %% (%d)\n",wperc(nomin),nomin);
	printf("sentence beginnings:\n");
	printf("	subject opener: noun (%d) pron (%d) pos (%d) adj (%d) art (%d) tot %3.0f%%\n",
beg[0],beg[7],beg[6],beg[3],beg[8],sperc(ii));
	printf("	prep %3.0f%% (%d) adv %3.0f%% (%d) \n",sperc(beg[9]),beg[9],sperc(beg[4]),beg[4]);
	printf("	verb %3.0f%% (%d) ",sperc(beg[1]+beg[10]+beg[11]),beg[1]+beg[10]+beg[11]);
	printf(" sub_conj %3.0f%% (%d) conj %3.0f%% (%d)\n",sperc(beg[13]),beg[13],sperc(beg[5]),beg[5]);
	printf("	expletives %3.0f%% (%d)\n",sperc(beg[14]),beg[14]);
	}
	else {
		printf("%ld %4.1f %4.2f %d %3.0f %d %d %3.0f %d\n",numnonf,
			(float)(numnonf)*100/numwds,snonf,ml,sperc(lsum),
			lsum,mg,sperc(gsum),gsum);
		printf("%d %d %d %d\n",maxsent,maxindex,minsent,minindex);
		printf("%3.0f %d %3.0f %d %3.0f %d %3.0f %d\n",sperc(simple),simple,
		   sperc(complex),complex,sperc(compound),compound,sperc(compdx),
		   compdx);
		printf("%3.0f %d %3.0f %d %3.0f %d %3.0f %d\n",vperc(tobe),tobe,
		  vperc(aux),aux,vperc(infin),infin,adjs,passive);
		printf("%3.1f %d %3.1f %d %3.1f %d %3.1f %d %3.1f %d %3.1f %d %3.1f %d\n"
		   ,wperc(prepc),prepc,wperc(conjc),conjc,wperc(adv),adv,
		   wperc(noun),noun,wperc(adj),adj,wperc(pron),pron,
		  wperc(nomin),nomin);
		printf("%d %d %d %d %d %3.0f\n",beg[0],beg[7],beg[6],beg[3],
			beg[8],sperc(ii));
		printf("%3.0f %d %3.0f %d %3.0f %d %3.0f %d %3.0f %d %3.0f %d\n"			,sperc(beg[9]),beg[9],sperc(beg[4]),beg[4],
			sperc(beg[1]+beg[10]+beg[11]),
			beg[1]+beg[10]+beg[11],sperc(beg[13]),beg[13],
			sperc(beg[5]),beg[5],sperc(beg[14]),beg[14]);
	}
#ifdef SCATCH
	if(nosave && (fopen(SCATCH,"r")) != NULL){
	if(((io=fopen(SCATCH,"a")) != NULL)){
		fprintf(io," read %4.1f %4.1f %4.1f %4.1f %4.1f\n",kindex, aindex, cindex, findex, fgrad);
		fprintf(io," sentl %d %ld %4.2f %4.2f %d %d %ld %4.2f\n",numsent,numwds,avw,avl,qcount,icount,numnonf,snonf);
		fprintf(io," l var %d %d %d %d %d\n",ml,lsum,mg,gsum,maxsent);
		fprintf(io," t var %d %d %d %d\n",simple,complex,compound,compdx);
		fprintf(io," verbs %d %d %d %d %d %d\n",tverbc,verbc,tobe,aux,infin,passive);
		fprintf(io," ty %d %d %d %d %d %d %d\n",prepc,conjc,adv,noun,adj,pron,nomin);
		fprintf(io," beg %d %d %d %d %d %d\n",beg[0],beg[7],beg[6],beg[3],beg[8],ii);
		fprintf(io," sbeg %d %d %d %d %d %d\n",beg[9],beg[4],beg[1]+beg[10]+beg[11],beg[13],beg[5],beg[14]);
		}
	}
#endif
	}
	return(1);
}
float
wperc(a)
{
	return((float)(a)*100/numwds);
}
float
sperc(a)
{
	return((float)(a)*100/numsent);
}
float
typersent(a)
{
return((float)(a)/numsent);
}
float
vperc(a)
{
	if(tverbc == 0)return(0);
	return((float)(a)*100/tverbc);
}
main(argc,argv)
char **argv;
{
	while(--argc > 0 && (++argv)[0][0] == '-' ){
		switch(argv[0][1]){
		case 'd': nosave = 0;
			continue;
		case 'S': style=1;
			continue;
		case 'p': pastyle=style=1;
			continue;
		case 's': style = sstyle = 1;
			sthresh = atoi(*(++argv));
			argc--;
			continue;
		case 'a': pstyle=style=1;
			continue;
		case 'e': estyle = style = 1;
			continue;
		case 'E': sprint = style = 1;
			continue;
		case 'n': nstyle = style = 1;
			continue;
		case 'N': Nstyle = style = 1;
			continue;
		case 'l': style=lstyle=1;
			lthresh = atoi(*(++argv));
			argc--;
			continue;
		case 'r':
			style=rstyle=1;
			rthresh = atoi(*(++argv));
			argc--;
			continue;
		case 'P':
			part = 1;
			style = 0;
			continue;
		case 'b':		/* print bare bones info rje */
			barebones = 1;
			style = 0;
			continue;
		case 'T':		/*topic*/
			style = 0;
			topic = 1;
			continue;
		case 'L':		/*pass lineno info thru*/
			lineflg = 1;
			continue;
		case 'C':		/* pass commands thru */
			lineflg = 2;
			continue;
		default:
			fprintf(stderr,"unknown flag to part %s\n",*argv);
			exit(1);
		}
		argv++;
	}
#ifdef SNOM
	if(fopen(SNOM,"r") != NULL){
		deb = fopen(SNOM,"a");	/* SAVE NOM*/
	}
#else
	deb = NULL;
#endif
	yylex();
	if(nrofflg && sentno > 0){
		printf(".SL \"");
		for(i=0;i<sentno;i++)
			printf(" %d",leng[i]);
		printf("\"\n");
	}
}
int yyvstop[] = {
0,

5,
0,

9,
0,

9,
0,

6,
0,

3,
0,

3,
4,
0,

10,
0,

2,
9,
0,

1,
0,

8,
0,

8,
0,

7,
8,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	0,0,	4,11,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	1,3,	
4,0,	2,3,	11,0,	14,21,	
8,0,	18,0,	19,0,	20,0,	
22,0,	23,0,	25,0,	26,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	2,5,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	4,11,	2,6,	
0,0,	0,0,	0,0,	0,0,	
19,19,	0,0,	0,0,	0,0,	
0,0,	0,0,	25,26,	5,12,	
1,4,	2,7,	2,8,	6,13,	
8,15,	9,16,	10,17,	4,11,	
2,9,	2,9,	2,9,	2,9,	
2,10,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	2,9,	2,9,	
2,9,	2,9,	7,14,	12,18,	
13,19,	15,22,	16,23,	17,24,	
24,24,	0,0,	0,0,	7,0,	
12,0,	13,0,	15,0,	16,0,	
17,0,	24,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	7,14,	12,18,	13,20,	
15,22,	16,23,	17,24,	24,24,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	7,14,	12,18,	
13,19,	15,22,	16,23,	17,24,	
24,24,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
17,25,	0,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
1,	0,		0,	
3,	0,		0,	
0,	0,		yyvstop+1,
-2,	0,		0,	
1,	0,		0,	
5,	0,		0,	
-125,	0,		0,	
-6,	yysvec+4,	0,	
7,	0,		0,	
8,	0,		0,	
-4,	yysvec+4,	yyvstop+3,
-126,	0,		0,	
-127,	0,		0,	
-5,	yysvec+7,	0,	
-128,	0,		yyvstop+5,
-129,	0,		0,	
-130,	0,		0,	
-7,	yysvec+12,	yyvstop+7,
-8,	yysvec+13,	yyvstop+9,
-9,	yysvec+13,	yyvstop+11,
0,	0,		yyvstop+14,
-10,	yysvec+15,	yyvstop+16,
-11,	yysvec+16,	yyvstop+19,
-131,	0,		yyvstop+21,
-12,	yysvec+24,	yyvstop+23,
-13,	yysvec+24,	yyvstop+25,
0,	0,	0};
#define yytop 256
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,',' ,',' ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,',' ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,01  ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,01  ,
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
