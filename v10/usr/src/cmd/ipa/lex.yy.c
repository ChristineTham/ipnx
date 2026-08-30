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
# define P1 2
# define P2 4
# define P3 6

#line 3 "ipa_trans.lex"
void ipa_out();
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 6 "ipa_trans.lex"
{ BEGIN P1; }
break;
case 2:

#line 7 "ipa_trans.lex"
{ BEGIN P2; }
break;
case 3:

#line 8 "ipa_trans.lex"
{ BEGIN P3; }
break;
case 4:

#line 9 "ipa_trans.lex"
{ BEGIN 0; }
break;
case 5:

#line 10 "ipa_trans.lex"
{ BEGIN 0; }
break;
case 6:

#line 11 "ipa_trans.lex"
{ BEGIN 0; }
break;
case 7:

#line 12 "ipa_trans.lex"
ipa_out(1,1);
break;
case 8:

#line 13 "ipa_trans.lex"
ipa_out(1,3);
break;
case 9:

#line 14 "ipa_trans.lex"
{ ipa_out(1,3); ipa_out(1,66); }
break;
case 10:

#line 15 "ipa_trans.lex"
ipa_out(1,5);
break;
case 11:

#line 16 "ipa_trans.lex"
ipa_out(1,2);
break;
case 12:

#line 17 "ipa_trans.lex"
ipa_out(1,4);
break;
case 13:

#line 18 "ipa_trans.lex"
{ ipa_out(1,4); ipa_out(1,67); }
break;
case 14:

#line 19 "ipa_trans.lex"
ipa_out(1,11);
break;
case 15:

#line 20 "ipa_trans.lex"
ipa_out(1,6);
break;
case 16:

#line 21 "ipa_trans.lex"
ipa_out(1,7);
break;
case 17:

#line 22 "ipa_trans.lex"
ipa_out(1,39);
break;
case 18:

#line 23 "ipa_trans.lex"
ipa_out(1,8);
break;
case 19:

#line 24 "ipa_trans.lex"
ipa_out(1,59);
break;
case 20:

#line 25 "ipa_trans.lex"
ipa_out(1,9);
break;
case 21:

#line 26 "ipa_trans.lex"
ipa_out(1,57);
break;
case 22:

#line 27 "ipa_trans.lex"
ipa_out(1,58);
break;
case 23:

#line 28 "ipa_trans.lex"
ipa_out(1,18);
break;
case 24:

#line 29 "ipa_trans.lex"
ipa_out(1,66);
break;
case 25:

#line 30 "ipa_trans.lex"
ipa_out(1,67);
break;
case 26:

#line 31 "ipa_trans.lex"
ipa_out(1,19);
break;
case 27:

#line 32 "ipa_trans.lex"
ipa_out(1,22);
break;
case 28:

#line 33 "ipa_trans.lex"
ipa_out(1,20);
break;
case 29:

#line 34 "ipa_trans.lex"
ipa_out(1,99);
break;
case 30:

#line 35 "ipa_trans.lex"
ipa_out(1,10);
break;
case 31:

#line 36 "ipa_trans.lex"
ipa_out(1,35);
break;
case 32:

#line 37 "ipa_trans.lex"
ipa_out(1,52);
break;
case 33:

#line 38 "ipa_trans.lex"
ipa_out(1,91);
break;
case 34:

#line 39 "ipa_trans.lex"
ipa_out(2,8);
break;
case 35:

#line 40 "ipa_trans.lex"
ipa_out(1,93);
break;
case 36:

#line 41 "ipa_trans.lex"
{ ipa_out(1,92); ipa_out(2,71); }
break;
case 37:

#line 42 "ipa_trans.lex"
ipa_out(2,12);
break;
case 38:

#line 43 "ipa_trans.lex"
ipa_out(1,95);
break;
case 39:

#line 44 "ipa_trans.lex"
ipa_out(2,2);
break;
case 40:

#line 45 "ipa_trans.lex"
ipa_out(2,3);
break;
case 41:

#line 46 "ipa_trans.lex"
ipa_out(1,97);
break;
case 42:

#line 47 "ipa_trans.lex"
ipa_out(1,98);
break;
case 43:

#line 48 "ipa_trans.lex"
ipa_out(2,9);
break;
case 44:

#line 49 "ipa_trans.lex"
{ ipa_out(1,94); ipa_out(2,73); }
break;
case 45:

#line 50 "ipa_trans.lex"
{ ipa_out(1,94); ipa_out(2,71); }
break;
case 46:

#line 51 "ipa_trans.lex"
{ ipa_out(1,96); ipa_out(2,71); }
break;
case 47:

#line 52 "ipa_trans.lex"
ipa_out(2,77);
break;
case 48:

#line 53 "ipa_trans.lex"
ipa_out(2,99);
break;
case 49:

#line 54 "ipa_trans.lex"
ipa_out(1,96);
break;
case 50:

#line 55 "ipa_trans.lex"
ipa_out(1,96);
break;
case 51:

#line 56 "ipa_trans.lex"
ipa_out(2,14);
break;
case 52:

#line 57 "ipa_trans.lex"
ipa_out(2,6);
break;
case 53:

#line 58 "ipa_trans.lex"
ECHO;
break;
case 54:

#line 59 "ipa_trans.lex"
ECHO;
break;
case 55:

#line 60 "ipa_trans.lex"
ipa_out(2,78);
break;
case 56:

#line 61 "ipa_trans.lex"
ipa_out(2,79);
break;
case 57:

#line 62 "ipa_trans.lex"
ipa_out(2,76);
break;
case 58:

#line 63 "ipa_trans.lex"
ipa_out(2,74);
break;
case 59:

#line 64 "ipa_trans.lex"
  ipa_out(2,66);
break;
case 60:

#line 65 "ipa_trans.lex"
	{
		/* any member of one of the two fonts */
		ipa_out(atoi(&yytext[1]),atoi(&yytext[3]));
	}
break;
case 61:

#line 69 "ipa_trans.lex"
ECHO;
break;
case 62:

#line 70 "ipa_trans.lex"
{ 
		ipa_out(2,68);	 /* a slightly raised 'x'
					    for all characters not otherwise
					    defined */
		}
break;
case 63:

#line 75 "ipa_trans.lex"
ECHO;
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

#line 77 "ipa_trans.lex"
void
ipa_out(fontnum,charnum)
int fontnum, charnum;
{
	printf("\\f(P%d\\N'%d'\\fP",fontnum,charnum);
/* should check that charnum is in range */
}
int yyvstop[] = {
0,

63,
0,

63,
0,

62,
63,
0,

61,
62,
63,
0,

61,
0,

53,
62,
63,
0,

48,
62,
63,
0,

51,
62,
63,
0,

55,
62,
63,
0,

4,
62,
63,
0,

52,
62,
63,
0,

54,
62,
63,
0,

56,
62,
63,
0,

59,
62,
63,
0,

50,
62,
63,
0,

31,
62,
63,
0,

39,
62,
63,
0,

36,
62,
63,
0,

9,
62,
63,
0,

22,
62,
63,
0,

33,
62,
63,
0,

17,
62,
63,
0,

45,
62,
63,
0,

13,
62,
63,
0,

58,
62,
63,
0,

57,
62,
63,
0,

41,
62,
63,
0,

32,
62,
63,
0,

47,
62,
63,
0,

24,
62,
63,
0,

21,
62,
63,
0,

42,
62,
63,
0,

44,
62,
63,
0,

46,
62,
63,
0,

25,
62,
63,
0,

62,
63,
0,

40,
62,
63,
0,

37,
62,
63,
0,

11,
62,
63,
0,

49,
62,
63,
0,

12,
62,
63,
0,

35,
62,
63,
0,

20,
62,
63,
0,

14,
62,
63,
0,

30,
62,
63,
0,

34,
62,
63,
0,

10,
62,
63,
0,

18,
62,
63,
0,

15,
62,
63,
0,

16,
62,
63,
0,

38,
62,
63,
0,

7,
62,
63,
0,

19,
62,
63,
0,

23,
62,
63,
0,

8,
62,
63,
0,

43,
62,
63,
0,

26,
62,
63,
0,

28,
62,
63,
0,

29,
62,
63,
0,

27,
62,
63,
0,

5,
62,
63,
0,

6,
62,
63,
0,

1,
0,

3,
0,

2,
0,

60,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,9,	0,0,	
0,0,	0,0,	3,11,	0,0,	
0,0,	0,0,	1,9,	1,0,	
2,0,	0,0,	3,12,	3,13,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
3,14,	0,0,	3,15,	3,16,	
3,17,	0,0,	3,18,	3,19,	
3,20,	1,9,	1,9,	3,21,	
72,74,	3,11,	3,11,	44,72,	
44,72,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	3,22,	
0,0,	1,10,	2,10,	3,23,	
3,24,	3,25,	3,26,	0,0,	
3,27,	3,28,	3,29,	0,0,	
3,30,	0,0,	3,31,	3,32,	
0,0,	3,33,	0,0,	3,34,	
3,35,	0,0,	3,36,	3,37,	
3,38,	3,39,	3,40,	0,0,	
3,41,	0,0,	3,42,	3,43,	
3,44,	76,80,	0,0,	3,45,	
73,75,	0,0,	3,46,	3,47,	
3,48,	3,49,	3,50,	3,51,	
3,52,	3,53,	3,54,	10,71,	
3,55,	3,56,	3,57,	3,58,	
3,59,	3,60,	71,73,	3,61,	
3,62,	3,63,	3,64,	3,65,	
3,66,	0,0,	3,67,	3,68,	
4,14,	0,0,	4,15,	4,16,	
4,17,	0,0,	4,18,	4,19,	
4,20,	0,0,	0,0,	4,21,	
74,76,	74,76,	74,76,	74,76,	
74,76,	74,76,	74,76,	74,76,	
74,76,	74,76,	0,0,	4,22,	
75,77,	0,0,	0,0,	4,23,	
4,24,	4,25,	4,26,	75,78,	
4,27,	4,28,	4,29,	0,0,	
4,30,	0,0,	4,31,	4,32,	
0,0,	4,33,	0,0,	4,34,	
4,35,	0,0,	4,36,	4,37,	
4,38,	4,39,	4,40,	0,0,	
4,41,	0,0,	4,42,	4,43,	
4,44,	0,0,	0,0,	4,45,	
0,0,	0,0,	4,46,	4,47,	
4,48,	4,49,	4,50,	4,51,	
4,52,	4,53,	4,54,	0,0,	
4,55,	4,56,	4,57,	4,58,	
4,59,	4,60,	0,0,	4,61,	
4,62,	4,63,	4,64,	4,65,	
4,66,	5,11,	4,67,	4,68,	
0,0,	0,0,	0,0,	0,0,	
0,0,	5,12,	5,13,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	75,79,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	5,14,	
0,0,	5,15,	5,16,	5,17,	
0,0,	0,0,	5,19,	5,20,	
0,0,	0,0,	5,21,	0,0,	
5,11,	5,11,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	5,22,	0,0,	
0,0,	0,0,	5,23,	5,24,	
5,25,	5,26,	0,0,	5,27,	
5,28,	5,29,	0,0,	5,30,	
0,0,	5,31,	5,32,	0,0,	
5,33,	0,0,	5,34,	5,35,	
0,0,	5,36,	5,37,	5,38,	
5,39,	5,40,	0,0,	5,41,	
0,0,	5,42,	5,43,	5,44,	
0,0,	0,0,	5,45,	0,0,	
0,0,	5,46,	5,47,	5,48,	
5,49,	5,50,	5,51,	5,52,	
5,53,	5,54,	0,0,	5,55,	
5,56,	5,57,	5,58,	5,59,	
5,60,	0,0,	5,61,	5,62,	
5,63,	5,64,	5,65,	5,66,	
0,0,	5,67,	5,68,	0,0,	
6,14,	5,69,	6,15,	6,16,	
6,17,	0,0,	0,0,	6,19,	
6,20,	0,0,	0,0,	6,21,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	6,22,	
0,0,	0,0,	0,0,	6,23,	
6,24,	6,25,	6,26,	0,0,	
6,27,	6,28,	6,29,	0,0,	
6,30,	0,0,	6,31,	6,32,	
0,0,	6,33,	0,0,	6,34,	
6,35,	0,0,	6,36,	6,37,	
6,38,	6,39,	6,40,	0,0,	
6,41,	0,0,	6,42,	6,43,	
6,44,	0,0,	0,0,	6,45,	
0,0,	0,0,	6,46,	6,47,	
6,48,	6,49,	6,50,	6,51,	
6,52,	6,53,	6,54,	0,0,	
6,55,	6,56,	6,57,	6,58,	
6,59,	6,60,	0,0,	6,61,	
6,62,	6,63,	6,64,	6,65,	
6,66,	7,11,	6,67,	6,68,	
0,0,	0,0,	6,69,	0,0,	
0,0,	7,12,	7,13,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	7,14,	
0,0,	7,15,	7,16,	7,17,	
0,0,	0,0,	7,19,	7,20,	
0,0,	0,0,	7,21,	7,70,	
7,11,	7,11,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	7,22,	0,0,	
0,0,	0,0,	7,23,	7,24,	
7,25,	7,26,	0,0,	7,27,	
7,28,	7,29,	0,0,	7,30,	
0,0,	7,31,	7,32,	0,0,	
7,33,	0,0,	7,34,	7,35,	
0,0,	7,36,	7,37,	7,38,	
7,39,	7,40,	0,0,	7,41,	
0,0,	7,42,	7,43,	7,44,	
0,0,	0,0,	7,45,	0,0,	
0,0,	7,46,	7,47,	7,48,	
7,49,	7,50,	7,51,	7,52,	
7,53,	7,54,	0,0,	7,55,	
7,56,	7,57,	7,58,	7,59,	
7,60,	0,0,	7,61,	7,62,	
7,63,	7,64,	7,65,	7,66,	
0,0,	7,67,	7,68,	8,14,	
0,0,	8,15,	8,16,	8,17,	
0,0,	0,0,	8,19,	8,20,	
0,0,	0,0,	8,21,	8,70,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	8,22,	0,0,	
0,0,	0,0,	8,23,	8,24,	
8,25,	8,26,	0,0,	8,27,	
8,28,	8,29,	0,0,	8,30,	
0,0,	8,31,	8,32,	0,0,	
8,33,	0,0,	8,34,	8,35,	
0,0,	8,36,	8,37,	8,38,	
8,39,	8,40,	0,0,	8,41,	
0,0,	8,42,	8,43,	8,44,	
0,0,	0,0,	8,45,	0,0,	
0,0,	8,46,	8,47,	8,48,	
8,49,	8,50,	8,51,	8,52,	
8,53,	8,54,	0,0,	8,55,	
8,56,	8,57,	8,58,	8,59,	
8,60,	0,0,	8,61,	8,62,	
8,63,	8,64,	8,65,	8,66,	
0,0,	8,67,	8,68,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
-1,	0,		0,	
-2,	yysvec+1,	0,	
-5,	0,		0,	
-93,	yysvec+3,	0,	
-212,	0,		0,	
-301,	yysvec+5,	0,	
-420,	0,		0,	
-508,	yysvec+7,	0,	
0,	0,		yyvstop+1,
6,	0,		yyvstop+3,
0,	0,		yyvstop+5,
0,	0,		yyvstop+8,
0,	0,		yyvstop+12,
0,	0,		yyvstop+14,
0,	0,		yyvstop+18,
0,	0,		yyvstop+22,
0,	0,		yyvstop+26,
0,	0,		yyvstop+30,
0,	0,		yyvstop+34,
0,	0,		yyvstop+38,
0,	0,		yyvstop+42,
0,	0,		yyvstop+46,
0,	0,		yyvstop+50,
0,	0,		yyvstop+54,
0,	yysvec+10,	yyvstop+58,
0,	0,		yyvstop+62,
0,	0,		yyvstop+66,
0,	0,		yyvstop+70,
0,	0,		yyvstop+74,
0,	0,		yyvstop+78,
0,	0,		yyvstop+82,
0,	0,		yyvstop+86,
0,	0,		yyvstop+90,
0,	0,		yyvstop+94,
0,	0,		yyvstop+98,
0,	0,		yyvstop+102,
0,	0,		yyvstop+106,
0,	0,		yyvstop+110,
0,	0,		yyvstop+114,
0,	0,		yyvstop+118,
0,	0,		yyvstop+122,
0,	0,		yyvstop+126,
0,	0,		yyvstop+130,
6,	0,		yyvstop+134,
0,	0,		yyvstop+137,
0,	0,		yyvstop+141,
0,	0,		yyvstop+145,
0,	0,		yyvstop+149,
0,	0,		yyvstop+153,
0,	0,		yyvstop+157,
0,	0,		yyvstop+161,
0,	0,		yyvstop+165,
0,	0,		yyvstop+169,
0,	0,		yyvstop+173,
0,	0,		yyvstop+177,
0,	0,		yyvstop+181,
0,	0,		yyvstop+185,
0,	0,		yyvstop+189,
0,	0,		yyvstop+193,
0,	0,		yyvstop+197,
0,	0,		yyvstop+201,
0,	0,		yyvstop+205,
0,	0,		yyvstop+209,
0,	0,		yyvstop+213,
0,	0,		yyvstop+217,
0,	0,		yyvstop+221,
0,	0,		yyvstop+225,
0,	0,		yyvstop+229,
0,	0,		yyvstop+233,
0,	0,		yyvstop+237,
6,	0,		0,	
6,	0,		0,	
3,	0,		0,	
92,	0,		0,	
112,	0,		0,	
4,	yysvec+74,	0,	
0,	0,		yyvstop+241,
0,	0,		yyvstop+243,
0,	0,		yyvstop+245,
0,	0,		yyvstop+247,
0,	0,	0};
#define yytop 630
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
'0' ,'1' ,'1' ,'0' ,'0' ,'0' ,'0' ,'0' ,
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
