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

#line 2 "idlex.l"
#include "ideal.h"
#include "y.tab.h"
extern int lineno, yylval;
extern boolean flyback;

#define	BUFLEN	100

struct filenode {
	struct filenode *next;
	FILE *file;
	int lineno;
	char *name;
	char buf[BUFLEN];
	int head;
};

struct filenode *filestack = NULL;

FILE *curfile;
#undef	input
#undef	unput

boolean file_start = TRUE;
boolean just_popped = FALSE;

void filepush ();
void filepop ();
char input ();
void unput ();
# define PROGRAM 2
# define COMMENT 4
# define OUTSIDE 6
# define LIBRARY 8
# define INCLUDE 10
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;

#line 34 "idlex.l"
	int numitems, i;
	char item[5][20];
	char cmd[20];
	static int ISnest, bracenest, commnest, omode;
	if (file_start) {
		BEGIN OUTSIDE;
		ISnest = 0;
	};
	file_start = FALSE;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

#line 45 "idlex.l"
{
			BEGIN PROGRAM;
			if (!ISnest)
				printf ("%s", yytext);
			ISnest ++;
			bracenest = commnest = 0;
			}
break;
case 2:

#line 52 "idlex.l"
	{
			if (just_popped) {
				if (omode == LIBFIL)
					BEGIN LIBRARY;
				else if (omode == CHATTY)
					BEGIN INCLUDE;
				else impossible ("idlex");
				just_popped = FALSE;
			} else
				printf ("%s", yytext);
			}
break;
case 3:

#line 63 "idlex.l"
	{
			printf ("%s", yytext);
			}
break;
case 4:

#line 66 "idlex.l"
	{
			if (just_popped) {
				BEGIN PROGRAM;
				just_popped = FALSE;
			} else {
				printf ("\n");
			}
			}
break;
case 5:

#line 74 "idlex.l"
	return(yylval = BOX);
break;
case 6:

#line 75 "idlex.l"
	return(yylval = VAR);
break;
case 7:

#line 76 "idlex.l"
	return(yylval = BDLIST);
break;
case 8:

#line 77 "idlex.l"
return(yylval = BDLIST);
break;
case 9:

#line 78 "idlex.l"
	return(yylval = PUT);
break;
case 10:

#line 79 "idlex.l"
	return(yylval = CONN);
break;
case 11:

#line 80 "idlex.l"
	return(yylval = TO);
break;
case 12:

#line 81 "idlex.l"
	return(yylval = USING);
break;
case 13:

#line 82 "idlex.l"
return(yylval = CONSTRUCT);
break;
case 14:

#line 83 "idlex.l"
	return(yylval = DRAW);
break;
case 15:

#line 84 "idlex.l"
	return(yylval = OPAQUE);
break;
case 16:

#line 85 "idlex.l"
	return(yylval = LEFT);
break;
case 17:

#line 86 "idlex.l"
	return(yylval = CENTER);
break;
case 18:

#line 87 "idlex.l"
	return(yylval = RIGHT);
break;
case 19:

#line 88 "idlex.l"
	return(yylval = SPLINE);
break;
case 20:

#line 89 "idlex.l"
	return(yylval = AT);
break;
case 21:

#line 90 "idlex.l"
return(yylval = INTERIOR);
break;
case 22:

#line 91 "idlex.l"
return(yylval = EXTERIOR);
break;
case 23:

#line 92 "idlex.l"
{
			yylval = lookup(&yytext[0]);
			return(NAME);
			}
break;
case 24:

#line 96 "idlex.l"
{
			float temp;
			sscanf(yytext, "%f", &temp);
			yylval = (int) fextlgen(temp);
			return(CONST);
			}
break;
case 25:

#line 102 "idlex.l"
{
			numitems = sscanf (yytext, "%s %s %s %s %s %s",
				cmd,
				&item[0][0],
				&item[1][0],
				&item[2][0],
				&item[3][0],
				&item[4][0]
			);
			numitems --;
			for (i = 0; i < numitems; i ++)
				forget (lookup (&item[i][0]));
			}
break;
case 26:

#line 115 "idlex.l"
radflag = TRUE;
break;
case 27:

#line 116 "idlex.l"
radflag = FALSE;
break;
case 28:

#line 117 "idlex.l"
{
			omode = LIBFIL;
			BEGIN LIBRARY;
			}
break;
case 29:

#line 121 "idlex.l"
	;
break;
case 30:

#line 122 "idlex.l"
{
			idinclude (yytext, LIBFIL);
			BEGIN OUTSIDE + 1;
			}
break;
case 31:

#line 126 "idlex.l"
	{
			BEGIN PROGRAM + 1;
			}
break;
case 32:

#line 129 "idlex.l"
{
			omode = CHATTY;
			BEGIN INCLUDE;
			}
break;
case 33:

#line 133 "idlex.l"
	;
break;
case 34:

#line 134 "idlex.l"
{
			idinclude (yytext, CHATTY);
			BEGIN OUTSIDE + 1;
			}
break;
case 35:

#line 138 "idlex.l"
	{
			BEGIN PROGRAM + 1;
			}
break;
case 36:

#line 141 "idlex.l"
{
			interpret ();
			ISnest --;
			if (!ISnest)
				printf ("%s", yytext);
			if (bracenest > 0)
				fprintf (stderr, "ideal: excess {\n");
			BEGIN OUTSIDE;
			}
break;
case 37:

#line 150 "idlex.l"
	{
			sscanf (yytext, "%s", cmd);
			if (strcmp (cmd, "...libfile") && strcmp (cmd, "...include"))
				printf ("%s\n", yytext);
			else
				REJECT;
			}
break;
case 38:

#line 157 "idlex.l"
	;
break;
case 39:

#line 158 "idlex.l"
	{
			commnest = 1;
			BEGIN COMMENT;
			}
break;
case 40:

#line 162 "idlex.l"
	{
			commnest ++;
			}
break;
case 41:

#line 165 "idlex.l"
	{
			commnest --;
			if (!commnest)
				BEGIN PROGRAM;
			}
break;
case 42:

#line 170 "idlex.l"
	;
break;
case 43:

#line 171 "idlex.l"
	{
			}
break;
case 44:

#line 173 "idlex.l"
{
			if (yytext[yyleng-1] == '\\') {
				yytext[yyleng-1] = yytext[yyleng];
				yyleng --;
				yymore();
			} else {
				char *temp;
				temp = malloc((unsigned) yyleng+1);
				yytext[yyleng] = '\0';
				strcpy(temp, &yytext[1]);
				yylval = (int) temp;
				input();
				return(STRING);
			}
			}
break;
case 45:

#line 188 "idlex.l"
{
			if (yytext[yyleng-1] == '\\') {
				yytext[yyleng-1] = yytext[yyleng];
				yyleng --;
				yymore();
			} else {
				char *temp;
				temp = malloc((unsigned) yyleng+1);
				yytext[yyleng] = '\0';
				strcpy(temp, &yytext[1]);
				yylval = (int) temp;
				input();
				return(STRING);
			}
			}
break;
case 46:

#line 203 "idlex.l"
	{
			if (just_popped) {
				if (omode == LIBFIL)
					BEGIN LIBRARY;
				else if (omode == CHATTY)
					BEGIN INCLUDE;
				else impossible ("idlex");
				just_popped = FALSE;
			}
			}
break;
case 47:

#line 213 "idlex.l"
	{
			}
break;
case 48:

#line 215 "idlex.l"
	{
			bracenest ++;
			return (yylval = LBRACE);
			}
break;
case 49:

#line 219 "idlex.l"
	{
			bracenest --;
			if (bracenest < 0)
				fprintf (stderr, "ideal: excess }\n");
			return (yylval = RBRACE);
			}
break;
case 50:

#line 225 "idlex.l"
return(yytext[0]);
break;
case 51:

#line 226 "idlex.l"
	fprintf(stderr, "ideal: unknown input token %s flushed\n", &yytext[0]);
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

#line 228 "idlex.l"
void filepush (f)
FILE *f;
{
	struct filenode *newfile;
	newfile = (struct filenode *) calloc (1, sizeof (struct filenode));
	if (newfile) {
		newfile->next = filestack;
		newfile->file = curfile = f;
		newfile->head = -1;
		if (filestack)
			filestack->lineno = lineno;
		newfile->name = malloc ((unsigned)strlen(filename)+1);
		strcpy (newfile->name, filename);
		filestack = newfile;
		lineno = 1;
	} else {
		fprintf (stderr, "ideal: no room for file descriptor\n");
		exit (1);
	}
}

void filepop ()
{
	struct filenode *oldfile;
	if (filestack) {
		if (filestack->head > -1)
			fprintf (stderr, "ideal: characters ignored in file %s\n", filename);
		oldfile = filestack;
		filestack = filestack->next;
		fclose (oldfile->file);
		if (filestack) {
			curfile = filestack->file;
			lineno = filestack->lineno;
			filename = filestack->name;
		} else
			curfile = NULL;
		free ((char *)oldfile);
	} else {
		fprintf (stderr, "ideal: file stack botch\n");
		exit (1);
	}
}

int idgetc (f)
struct filenode *f;
{
	int c;
	if (!f)
		return (EOF);
	if (f->head > -1) {
		c = f->buf[f->head--];
	} else
		c = getc(f->file);
	return (c);
}

char input ()
{
	int c;
	c = 0;
	if (filestack)
		c = idgetc(filestack);
	while (c == EOF && filestack) {
		filepop();
		if (filestack) {
			c = idgetc(filestack);
			just_popped = TRUE;
		}
		else
			c = EOF;
	}
	if (c == '\n')
		lineno++;
	return ((c == EOF)?0:c);
}

void unput (c)
char c;
{
	struct filenode *f;
	if (f = filestack) {
		if (f->head < BUFLEN) {
			f->buf[++f->head] = c;
			if (c == '\n')
				-- lineno;
		} else {
			fprintf (stderr, "ideal: out of pushback space\n");
			exit (1);
		}
	}
}
int yyvstop[] = {
0,

51,
0,

46,
51,
0,

47,
0,

45,
51,
0,

38,
51,
0,

44,
51,
0,

50,
51,
0,

50,
51,
0,

50,
51,
0,

24,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

23,
51,
0,

48,
51,
0,

49,
51,
0,

37,
50,
51,
0,

42,
0,

43,
0,

42,
0,

42,
0,

3,
0,

2,
3,
0,

4,
0,

3,
0,

30,
0,

29,
0,

31,
0,

34,
0,

33,
0,

35,
0,

46,
0,

45,
0,

38,
0,

44,
0,

24,
0,

39,
0,

24,
0,

24,
0,

23,
0,

20,
23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

11,
23,
0,

23,
0,

23,
0,

37,
0,

37,
0,

24,
37,
0,

37,
0,

41,
0,

40,
0,

24,
0,

24,
0,

23,
0,

23,
0,

5,
23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

9,
23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

6,
23,
0,

37,
0,

37,
0,

37,
0,

24,
0,

23,
0,

23,
0,

10,
23,
0,

23,
0,

14,
23,
0,

23,
0,

23,
0,

16,
23,
0,

23,
0,

23,
0,

23,
0,

17,
23,
0,

23,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

24,
37,
0,

36,
0,

1,
0,

24,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

18,
23,
0,

23,
0,

12,
23,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

7,
23,
0,

23,
0,

23,
0,

23,
0,

23,
0,

15,
23,
0,

19,
23,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

23,
0,

23,
0,

23,
0,

23,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

8,
23,
0,

23,
0,

22,
23,
0,

21,
23,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

13,
23,
0,

37,
0,

25,
37,
0,

37,
0,

37,
0,

37,
0,

27,
37,
0,

32,
37,
0,

28,
37,
0,

26,
37,
0,
0};
# define YYTYPE int
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	3,13,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	3,14,	3,15,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	14,55,	
0,0,	5,41,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	5,41,	5,42,	0,0,	
0,0,	0,0,	0,0,	3,16,	
3,17,	0,0,	0,0,	0,0,	
3,18,	3,19,	14,55,	0,0,	
3,19,	0,0,	6,43,	3,20,	
3,21,	3,22,	0,0,	6,44,	
8,48,	21,60,	5,41,	49,0,	
49,0,	50,50,	53,53,	5,41,	
5,41,	57,0,	5,43,	5,41,	
0,0,	4,17,	3,23,	5,44,	
5,41,	0,0,	3,23,	3,23,	
52,0,	52,0,	0,0,	0,0,	
4,40,	4,21,	49,0,	0,0,	
50,50,	53,53,	56,0,	0,0,	
0,0,	5,41,	58,0,	0,0,	
44,86,	5,41,	5,41,	0,0,	
0,0,	43,85,	0,0,	52,0,	
0,0,	0,0,	3,24,	3,25,	
3,26,	3,27,	3,28,	0,0,	
0,0,	0,0,	3,29,	0,0,	
0,0,	3,30,	0,0,	25,66,	
3,31,	3,32,	0,0,	3,33,	
3,34,	3,35,	3,36,	3,37,	
48,87,	5,41,	25,67,	7,45,	
3,38,	9,49,	3,39,	4,24,	
4,25,	4,26,	4,27,	7,46,	
7,47,	9,50,	9,51,	4,29,	
24,65,	26,68,	4,30,	27,69,	
28,70,	4,31,	4,32,	11,52,	
4,33,	4,34,	4,35,	4,36,	
4,37,	29,71,	30,72,	11,53,	
11,54,	4,38,	31,73,	4,39,	
7,45,	32,74,	9,49,	33,75,	
34,76,	7,45,	7,45,	9,49,	
9,49,	7,45,	16,56,	9,49,	
35,77,	36,79,	7,45,	37,80,	
9,49,	66,92,	16,56,	16,56,	
11,52,	59,88,	35,78,	68,95,	
67,93,	11,52,	11,52,	67,94,	
69,96,	11,52,	70,97,	7,45,	
71,98,	9,49,	11,52,	7,45,	
7,45,	9,49,	9,49,	72,99,	
73,100,	74,101,	75,102,	16,0,	
76,103,	77,104,	79,105,	80,106,	
16,56,	16,56,	17,57,	11,52,	
16,56,	59,88,	82,0,	11,52,	
11,52,	16,56,	17,57,	17,0,	
87,110,	84,0,	18,58,	92,114,	
89,113,	93,115,	96,118,	7,45,	
95,116,	9,49,	18,58,	18,58,	
97,119,	95,117,	16,56,	98,120,	
99,121,	100,122,	16,56,	16,56,	
102,123,	103,124,	104,125,	17,57,	
83,0,	105,126,	114,138,	11,52,	
17,57,	17,57,	82,107,	108,0,	
17,57,	115,139,	117,140,	18,58,	
89,113,	17,57,	119,141,	120,142,	
18,0,	18,58,	122,143,	123,144,	
18,58,	124,145,	126,146,	127,0,	
130,0,	18,58,	16,56,	138,152,	
139,153,	108,108,	17,57,	131,0,	
140,154,	141,155,	17,57,	17,57,	
84,109,	84,109,	83,83,	132,0,	
108,132,	133,0,	18,58,	142,156,	
143,157,	108,133,	18,58,	18,58,	
20,59,	20,59,	20,59,	20,59,	
20,59,	20,59,	20,59,	20,59,	
20,59,	20,59,	145,158,	83,108,	
149,0,	151,0,	150,0,	153,164,	
154,165,	22,61,	17,57,	22,62,	
22,62,	22,62,	22,62,	22,62,	
22,62,	22,62,	22,62,	22,62,	
22,62,	132,133,	18,58,	133,133,	
155,166,	156,167,	128,0,	164,173,	
129,0,	165,174,	166,175,	167,176,	
22,63,	174,182,	148,0,	83,108,	
147,0,	189,0,	61,89,	61,89,	
61,89,	61,89,	61,89,	61,89,	
61,89,	61,89,	61,89,	61,89,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	127,147,	61,63,	
160,0,	161,0,	131,151,	130,150,	
22,63,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	61,63,	
180,0,	149,161,	150,162,	151,163,	
162,0,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	23,64,	
23,64,	23,64,	23,64,	40,81,	
63,63,	81,81,	107,0,	128,148,	
129,149,	147,159,	159,0,	40,81,	
40,0,	81,81,	81,0,	63,90,	
163,0,	63,90,	148,160,	170,0,	
63,91,	63,91,	63,91,	63,91,	
63,91,	63,91,	63,91,	63,91,	
63,91,	63,91,	168,0,	169,0,	
171,0,	160,169,	178,0,	181,0,	
40,81,	183,0,	81,81,	161,170,	
88,88,	40,81,	40,81,	81,81,	
81,81,	40,81,	187,0,	81,81,	
40,82,	172,0,	40,83,	88,111,	
81,81,	88,111,	177,0,	190,0,	
88,112,	88,112,	88,112,	88,112,	
88,112,	88,112,	88,112,	88,112,	
88,112,	88,112,	179,0,	40,81,	
162,171,	81,81,	180,186,	40,81,	
40,81,	81,81,	81,81,	40,84,	
90,91,	90,91,	90,91,	90,91,	
90,91,	90,91,	90,91,	90,91,	
90,91,	90,91,	109,109,	0,0,	
185,0,	186,0,	0,0,	0,0,	
0,0,	0,0,	109,109,	109,134,	
107,127,	0,0,	107,128,	110,110,	
0,0,	107,129,	0,0,	40,81,	
107,130,	81,81,	0,0,	110,110,	
110,135,	0,0,	107,131,	163,172,	
0,0,	0,0,	159,168,	0,0,	
0,0,	0,0,	0,0,	109,109,	
0,0,	168,177,	169,178,	0,0,	
109,109,	109,109,	170,179,	171,180,	
109,109,	0,0,	0,0,	0,0,	
110,110,	109,109,	0,0,	181,187,	
172,181,	110,110,	110,110,	0,0,	
178,184,	110,110,	183,188,	0,0,	
0,0,	177,183,	110,110,	0,0,	
0,0,	0,0,	109,109,	187,191,	
0,0,	0,0,	109,109,	109,109,	
179,185,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	110,110,	
0,0,	0,0,	0,0,	110,110,	
110,110,	111,112,	111,112,	111,112,	
111,112,	111,112,	111,112,	111,112,	
111,112,	111,112,	111,112,	185,189,	
186,190,	0,0,	0,0,	0,0,	
113,113,	0,0,	109,109,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	113,136,	
0,0,	113,136,	0,0,	110,110,	
113,137,	113,137,	113,137,	113,137,	
113,137,	113,137,	113,137,	113,137,	
113,137,	113,137,	136,137,	136,137,	
136,137,	136,137,	136,137,	136,137,	
136,137,	136,137,	136,137,	136,137,	
184,184,	0,0,	188,188,	0,0,	
0,0,	0,0,	0,0,	0,0,	
184,184,	184,0,	188,188,	188,0,	
191,191,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
191,191,	191,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	184,184,	0,0,	188,188,	
0,0,	0,0,	184,184,	184,184,	
188,188,	188,188,	184,184,	0,0,	
188,188,	191,191,	0,0,	184,184,	
0,0,	188,188,	191,191,	191,191,	
0,0,	0,0,	191,191,	0,0,	
0,0,	0,0,	0,0,	191,191,	
0,0,	0,0,	0,0,	0,0,	
184,184,	0,0,	188,188,	0,0,	
184,184,	184,184,	188,188,	188,188,	
0,0,	0,0,	0,0,	0,0,	
191,191,	0,0,	0,0,	0,0,	
191,191,	191,191,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
184,184,	0,0,	188,188,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
191,191,	0,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
0,	0,		0,	
0,	0,		0,	
-1,	0,		0,	
-30,	yysvec+3,	0,	
-20,	0,		0,	
-4,	yysvec+5,	0,	
-122,	0,		0,	
-6,	yysvec+7,	0,	
-124,	0,		0,	
0,	yysvec+9,	0,	
-142,	0,		0,	
0,	yysvec+11,	0,	
0,	0,		yyvstop+1,
10,	0,		yyvstop+3,
0,	0,		yyvstop+6,
-165,	0,		yyvstop+8,
-205,	0,		yyvstop+11,
-217,	0,		yyvstop+14,
0,	0,		yyvstop+17,
240,	0,		yyvstop+20,
11,	0,		yyvstop+23,
259,	0,		yyvstop+26,
296,	0,		yyvstop+29,
20,	yysvec+23,	yyvstop+32,
11,	yysvec+23,	yyvstop+35,
26,	yysvec+23,	yyvstop+38,
25,	yysvec+23,	yyvstop+41,
20,	yysvec+23,	yyvstop+44,
39,	yysvec+23,	yyvstop+47,
49,	yysvec+23,	yyvstop+50,
42,	yysvec+23,	yyvstop+53,
40,	yysvec+23,	yyvstop+56,
54,	yysvec+23,	yyvstop+59,
48,	yysvec+23,	yyvstop+62,
67,	yysvec+23,	yyvstop+65,
54,	yysvec+23,	yyvstop+68,
74,	yysvec+23,	yyvstop+71,
0,	0,		yyvstop+74,
0,	0,		yyvstop+77,
-418,	0,		yyvstop+80,
0,	0,		yyvstop+84,
0,	0,		yyvstop+86,
46,	0,		yyvstop+88,
46,	0,		yyvstop+90,
0,	0,		yyvstop+92,
0,	0,		yyvstop+94,
0,	0,		yyvstop+97,
47,	0,		yyvstop+99,
-46,	yysvec+9,	yyvstop+101,
48,	0,		yyvstop+103,
0,	0,		yyvstop+105,
-63,	yysvec+11,	yyvstop+107,
49,	0,		yyvstop+109,
0,	0,		yyvstop+111,
0,	yysvec+14,	yyvstop+113,
-48,	yysvec+16,	yyvstop+115,
-51,	yysvec+17,	yyvstop+117,
-47,	yysvec+18,	yyvstop+119,
108,	yysvec+20,	yyvstop+121,
0,	0,		yyvstop+123,
286,	0,		yyvstop+125,
0,	yysvec+22,	yyvstop+127,
388,	0,		0,	
0,	yysvec+23,	yyvstop+129,
0,	yysvec+23,	yyvstop+131,
65,	yysvec+23,	yyvstop+134,
63,	yysvec+23,	yyvstop+136,
69,	yysvec+23,	yyvstop+138,
87,	yysvec+23,	yyvstop+140,
70,	yysvec+23,	yyvstop+142,
72,	yysvec+23,	yyvstop+144,
93,	yysvec+23,	yyvstop+146,
99,	yysvec+23,	yyvstop+148,
81,	yysvec+23,	yyvstop+150,
95,	yysvec+23,	yyvstop+152,
92,	yysvec+23,	yyvstop+154,
81,	yysvec+23,	yyvstop+156,
0,	yysvec+23,	yyvstop+158,
97,	yysvec+23,	yyvstop+161,
89,	yysvec+23,	yyvstop+163,
-420,	0,		yyvstop+165,
-200,	yysvec+81,	yyvstop+167,
-230,	yysvec+81,	yyvstop+169,
-207,	yysvec+81,	yyvstop+172,
0,	0,		yyvstop+174,
0,	0,		yyvstop+176,
133,	0,		0,	
424,	0,		0,	
151,	yysvec+61,	yyvstop+178,
444,	0,		0,	
0,	yysvec+90,	yyvstop+180,
114,	yysvec+23,	yyvstop+182,
111,	yysvec+23,	yyvstop+184,
0,	yysvec+23,	yyvstop+186,
114,	yysvec+23,	yyvstop+189,
103,	yysvec+23,	yyvstop+191,
127,	yysvec+23,	yyvstop+193,
130,	yysvec+23,	yyvstop+195,
116,	yysvec+23,	yyvstop+197,
120,	yysvec+23,	yyvstop+199,
0,	yysvec+23,	yyvstop+201,
132,	yysvec+23,	yyvstop+204,
132,	yysvec+23,	yyvstop+206,
122,	yysvec+23,	yyvstop+208,
131,	yysvec+23,	yyvstop+210,
0,	yysvec+23,	yyvstop+212,
-412,	yysvec+81,	yyvstop+215,
-237,	yysvec+81,	yyvstop+217,
-501,	0,		yyvstop+219,
-514,	0,		0,	
537,	0,		0,	
0,	yysvec+111,	yyvstop+221,
568,	0,		0,	
127,	yysvec+23,	yyvstop+223,
149,	yysvec+23,	yyvstop+225,
0,	yysvec+23,	yyvstop+227,
134,	yysvec+23,	yyvstop+230,
0,	yysvec+23,	yyvstop+232,
140,	yysvec+23,	yyvstop+235,
141,	yysvec+23,	yyvstop+237,
0,	yysvec+23,	yyvstop+239,
141,	yysvec+23,	yyvstop+242,
143,	yysvec+23,	yyvstop+244,
151,	yysvec+23,	yyvstop+246,
0,	yysvec+23,	yyvstop+248,
159,	yysvec+23,	yyvstop+251,
-253,	yysvec+81,	yyvstop+253,
-312,	yysvec+81,	yyvstop+255,
-314,	yysvec+81,	yyvstop+257,
-254,	yysvec+81,	yyvstop+259,
-261,	yysvec+81,	yyvstop+261,
-269,	yysvec+81,	yyvstop+263,
-271,	yysvec+81,	yyvstop+265,
0,	0,		yyvstop+268,
0,	0,		yyvstop+270,
578,	0,		0,	
0,	yysvec+136,	yyvstop+272,
151,	yysvec+23,	yyvstop+274,
171,	yysvec+23,	yyvstop+276,
158,	yysvec+23,	yyvstop+278,
168,	yysvec+23,	yyvstop+280,
178,	yysvec+23,	yyvstop+282,
183,	yysvec+23,	yyvstop+284,
0,	yysvec+23,	yyvstop+286,
197,	yysvec+23,	yyvstop+289,
0,	yysvec+23,	yyvstop+291,
-322,	yysvec+81,	yyvstop+294,
-320,	yysvec+81,	yyvstop+296,
-290,	yysvec+81,	yyvstop+298,
-292,	yysvec+81,	yyvstop+300,
-291,	yysvec+81,	yyvstop+302,
0,	yysvec+23,	yyvstop+304,
189,	yysvec+23,	yyvstop+307,
187,	yysvec+23,	yyvstop+309,
209,	yysvec+23,	yyvstop+311,
210,	yysvec+23,	yyvstop+313,
0,	yysvec+23,	yyvstop+315,
0,	yysvec+23,	yyvstop+318,
-416,	yysvec+81,	yyvstop+321,
-346,	yysvec+81,	yyvstop+323,
-347,	yysvec+81,	yyvstop+325,
-382,	yysvec+81,	yyvstop+327,
-422,	yysvec+81,	yyvstop+329,
202,	yysvec+23,	yyvstop+331,
226,	yysvec+23,	yyvstop+333,
212,	yysvec+23,	yyvstop+335,
213,	yysvec+23,	yyvstop+337,
-436,	yysvec+81,	yyvstop+339,
-437,	yysvec+81,	yyvstop+341,
-425,	yysvec+81,	yyvstop+343,
-438,	yysvec+81,	yyvstop+345,
-455,	yysvec+81,	yyvstop+347,
0,	yysvec+23,	yyvstop+349,
213,	yysvec+23,	yyvstop+352,
0,	yysvec+23,	yyvstop+354,
0,	yysvec+23,	yyvstop+357,
-460,	yysvec+81,	yyvstop+360,
-440,	yysvec+81,	yyvstop+362,
-472,	yysvec+81,	yyvstop+364,
-378,	yysvec+81,	yyvstop+366,
-441,	yysvec+81,	yyvstop+368,
0,	yysvec+23,	yyvstop+370,
-443,	yysvec+81,	yyvstop+373,
-635,	0,		yyvstop+375,
-494,	yysvec+81,	yyvstop+378,
-495,	yysvec+81,	yyvstop+380,
-452,	yysvec+81,	yyvstop+382,
-637,	0,		yyvstop+384,
-323,	yysvec+81,	yyvstop+387,
-461,	yysvec+81,	yyvstop+390,
-647,	0,		yyvstop+393,
0,	0,	0};
#define yytop 748
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,'"' ,01  ,01  ,01  ,01  ,047 ,
'(' ,'(' ,'(' ,'+' ,'(' ,'+' ,'(' ,'(' ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,'(' ,'(' ,'(' ,'(' ,'(' ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'F' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'(' ,01  ,'(' ,'(' ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,'e' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,'(' ,01  ,
0};
char yyextra[] = {
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
