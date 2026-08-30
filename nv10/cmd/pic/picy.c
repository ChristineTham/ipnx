
# line 2 "picy.y"
#include <stdio.h>
#include "pic.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

YYSTYPE	y;

extern	void	yyerror(char *);
extern	int	yylex(void);
# define BOX 1
# define LINE 2
# define ARROW 3
# define CIRCLE 4
# define ELLIPSE 5
# define ARC 6
# define SPLINE 7
# define BLOCK 8
# define TEXT 9
# define TROFF 10
# define MOVE 11
# define BLOCKEND 12
# define PLACE 13
# define PRINT 270
# define RESET 271
# define THRU 272
# define UNTIL 273
# define FOR 274
# define IF 275
# define COPY 276
# define THENSTR 277
# define ELSESTR 278
# define DOSTR 279
# define PLACENAME 280
# define VARNAME 281
# define SPRINTF 282
# define DEFNAME 283
# define ATTR 284
# define TEXTATTR 285
# define LEFT 286
# define RIGHT 287
# define UP 288
# define DOWN 289
# define FROM 290
# define TO 291
# define AT 292
# define BY 293
# define WITH 294
# define HEAD 295
# define CW 296
# define CCW 297
# define THEN 298
# define HEIGHT 299
# define WIDTH 300
# define RADIUS 301
# define DIAMETER 302
# define LENGTH 303
# define SIZE 304
# define CORNER 305
# define HERE 306
# define LAST 307
# define NTH 308
# define SAME 309
# define BETWEEN 310
# define AND 311
# define EAST 312
# define WEST 313
# define NORTH 314
# define SOUTH 315
# define NE 316
# define NW 317
# define SE 318
# define SW 319
# define START 320
# define END 321
# define DOTX 322
# define DOTY 323
# define DOTHT 324
# define DOTWID 325
# define DOTRAD 326
# define NUMBER 327
# define LOG 328
# define EXP 329
# define SIN 330
# define COS 331
# define ATAN2 332
# define SQRT 333
# define RAND 334
# define MIN 335
# define MAX 336
# define INT 337
# define DIR 338
# define DOT 339
# define DASH 340
# define CHOP 341
# define FILL 342
# define NOEDGE 343
# define ST 344
# define OROR 345
# define ANDAND 346
# define GT 347
# define LT 348
# define LE 349
# define GE 350
# define EQ 351
# define NEQ 352
# define UMINUS 353
# define NOT 354
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256
short yyexca[] ={
-1, 0,
	0, 2,
	-2, 0,
-1, 1,
	0, -1,
	-2, 0,
-1, 204,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 158,
-1, 211,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 157,
-1, 212,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 159,
-1, 213,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 160,
-1, 214,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 161,
-1, 215,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 162,
-1, 262,
	322, 112,
	323, 112,
	324, 112,
	325, 112,
	326, 112,
	-2, 85,
-1, 268,
	347, 0,
	348, 0,
	349, 0,
	350, 0,
	351, 0,
	352, 0,
	-2, 158,
	};
# define YYNPROD 177
# define YYLAST 1647
short yyact[]={

 171, 196, 197, 123, 123, 124, 124,  41, 125, 168,
 123,  42, 124,  38, 130, 131, 132, 133, 134, 123,
 280, 124, 314, 244, 161, 136, 136,  35, 232, 113,
 230, 165,  91, 332, 111, 109, 193, 110,  40, 112,
  35, 104,  95,  96,  35,  65,  66,  68, 282, 126,
 129,  68, 163, 190, 249, 150, 285, 286,  93, 283,
 284, 228, 229,  48,  89,  70, 285, 140, 144, 145,
 141, 142, 143, 146, 248, 283, 298, 228, 226, 267,
 194, 121, 113, 188,  82,  40, 121, 111, 109, 225,
 110, 123, 112, 124, 198, 137,  16,  20,  21,  17,
  18,  19,  22,  84,  35,  25,  23, 202, 204, 104,
 206, 207, 208, 209, 210, 211, 212, 213, 214, 215,
 216, 217, 218,  49, 219, 222,  67, 297,  48, 257,
 296, 335, 333,  32, 334,  49, 336, 244, 233, 121,
  48, 140, 144, 145, 141, 142, 143, 146, 246, 147,
 231, 310, 234, 235, 236, 237, 238, 239,  80, 241,
 242, 243, 113, 123, 273, 124, 331, 111, 109,  35,
 110, 250, 112, 251, 104, 104, 104, 104, 104, 240,
 169,  52, 259, 260, 261, 263,  33, 189, 123, 160,
 124, 159, 164, 265, 266, 317, 268, 158, 318, 113,
  93, 157, 264, 156, 111,  48, 155, 113,  35, 112,
  83, 227, 111, 109, 309, 110, 154, 112,  27, 121,
 271, 276, 153, 272, 278, 152, 151,  97,  69,   1,
   4,   5, 113,  37,   2,  26,   6, 111, 109,  49,
 110,  39, 112,  12,  48,  13, 167, 162, 140, 144,
 145, 141, 142, 143, 146, 148, 121,  14, 245, 247,
 302,  81,  88,  90, 121, 192,   0,   0,   0,   0,
  37,  99,  93, 303, 104, 104, 306,  48, 308,   0,
   0,   0, 135,  49, 135, 135,   0, 274,  48, 121,
   0,   0, 311,   0, 312, 313,   0,   0,  51,  46,
  36, 315, 316,  86,  87, 201,   0, 319, 320, 166,
 321, 122,  37,  36,   0,   0,  93,  36,   0, 329,
  80,  48,   0,  65,  66,  68,  53,   0,   0,   0,
   0, 200,   0, 338,   0,   0,   0,   0, 339, 114,
 195, 115, 116, 117, 118,  45,  55,  56,  57,  58,
  59,  60,  61,  63,  62,  64, 130, 131, 132, 133,
 134, 337,   0,  51,  46,  10,  11,   0,   0,  30,
  31,  29,  54, 149, 223, 102,  46,  36, 147,  48,
   0,   0,   0, 164,   0,   0,   0, 220, 256,  66,
  68,  53,  48,   0,   0,   0,   0,   0,   0, 113,
  65,  66,  68,  53, 111, 109, 106, 110, 281, 112,
  45,  55,  56,  57,  58,  59,  60,  61,  63,  62,
  64,   0,  45,  55,  56,  57,  58,  59,  60,  61,
  63,  62,  64,   9,   0,   0,   0,  54, 162, 100,
  51,  46,  36,   0, 170, 179,   0, 139,   0,  54,
 173, 174, 175, 176, 177, 180, 121,   0,   0,   0,
   0,   0,   0,   0,   0,  65,  66,  68,  53, 178,
 120, 119, 114, 195, 115, 116, 117, 118,   0,  51,
  46,  36,   0,   0,   0,   0,   0,  45,  55,  56,
  57,  58,  59,  60,  61,  63,  62,  64, 172, 181,
 182, 183, 184, 185,  65,  66,  68,  53,   0,   0,
   0,   0,  51,  46,  54, 120, 119, 114, 195, 115,
 116, 117, 118,  51,  46,   0,  45,  55,  56,  57,
  58,  59,  60,  61,  63,  62,  64,  65,  66,  68,
  53, 119, 114, 195, 115, 116, 117, 118,  65,  66,
  68,  53,   0,  54, 149,   0, 262,  46,   0,  45,
  55,  56,  57,  58,  59,  60,  61,  63,  62,  64,
  45,  55,  56,  57,  58,  59,  60,  61,  63,  62,
  64,  65,  66,  68,  53,   0,  54,   0, 113,   0,
   0,   0, 227, 111, 109, 106, 110,  54, 112,   0,
   0,   0,   0,  45,  55,  56,  57,  58,  59,  60,
  61,  63,  62,  64,  51,  46, 113,   0,   0,   0,
   0, 111, 109,   0, 110,   0, 112,  51,  46,   0,
  54,   0,   0,   0,   0,   0,   0,   0, 113,  65,
  66,  68,  53, 111, 109, 121, 110,   0, 112,   0,
   0,   0,  65,  66,  68,  53,   0,   0,   0,   0,
   0,  45,  55,  56,  57,  58,  59,  60,  61,  63,
  62,  64, 108, 121,  45,  55,  56,  57,  58,  59,
  60,  61,  63,  62,  64,   0, 113,   0,  54,   0,
 227, 111, 109, 307, 110, 121, 112,   0,   0,   0,
   0,  54,   0,   0,   0,   0, 105, 120, 119, 114,
 107, 115, 116, 117, 118, 113,   0,   0,   0,   0,
 111, 109, 106, 110, 113, 112,   0,   0,   0, 111,
 109,   0, 110,   0, 112,   0, 113,   0,   0,   0,
   0, 111, 109, 121, 110, 113, 112,   0,   0, 330,
 111, 109,   0, 110, 113, 112,   0,   0, 324, 111,
 109,   0, 110, 113, 112,   0,   0, 323, 111, 109,
   0, 110, 121, 112, 113,   0,   0,   0, 322, 111,
 109, 121, 110,   0, 112,   0, 113,   0,   0,   0,
   0, 111, 109, 121, 110,   0, 112,   0, 113,   0,
   0,   0, 121, 111, 109,   0, 110,   0, 112, 113,
   0, 121,   0, 295, 111, 109,   0, 110, 113, 112,
 121,   0,   0, 111, 109, 294, 110, 113, 112,   0,
   0, 121, 111, 109, 293, 110, 113, 112,   0,   0,
 292, 111, 109, 121, 110,   0, 112, 140, 144, 145,
 141, 142, 143, 146, 138, 121,   0, 113, 328,   0,
   0, 108, 111, 109, 291, 110, 121, 112,   0,   0,
   0,   0, 327,   0,   0, 121,   0, 113,   0,   0,
 326, 290, 111, 109, 121, 110,   0, 112,   0,   0,
   0,   0,   0, 121, 325,   0, 120, 119, 114, 107,
 115, 116, 117, 118,   0, 113,   0,   0,   0, 289,
 111, 109,   0, 110, 121, 112,   0,   0,   0,   0,
   0,   0,   0,   0, 120, 119, 114, 195, 115, 116,
 117, 118, 113,   0, 121,   0, 288, 111, 109,   0,
 110,   0, 112,   0,   0,   0, 120, 119, 114, 195,
 115, 116, 117, 118,   0, 113,   0,   0,   0, 287,
 111, 109, 121, 110, 113, 112, 341,   0,   0, 111,
 109, 277, 110,   0, 112,   0,   0,   0, 340, 186,
  24,   0,  24,   0,   0,   0,  24,   0, 108, 121,
   0,   0,   0,   0, 120, 119, 114, 195, 115, 116,
 117, 118,   0,   0,   0,   0,  24,   0,   0,   0,
   0,   0, 121,   0,   0,   0,   0,   0,   0,  24,
  24, 121,   0, 120, 119, 114, 107, 115, 116, 117,
 118,   0, 120, 119, 114, 195, 115, 116, 117, 118,
 301,   0,   0,   0, 120, 119, 114, 195, 115, 116,
 117, 118, 300, 120, 119, 114, 195, 115, 116, 117,
 118,  24, 120, 119, 114, 195, 115, 116, 117, 118,
   0, 120, 119, 114, 195, 115, 116, 117, 118,   0,
  24,   0, 120, 119, 114, 195, 115, 116, 117, 118,
   0,   0,   0,   0, 120, 119, 114, 195, 115, 116,
 117, 118,   0,   0,   0,   0, 120, 119, 114, 195,
 115, 116, 117, 118,   0,   0,   0, 120, 119, 114,
 195, 115, 116, 117, 118,   0, 120, 119, 114, 195,
 115, 116, 117, 118,   0, 120, 119, 114, 195, 115,
 116, 117, 118,   0, 120, 119, 114, 195, 115, 116,
 117, 118, 113, 139,   0,   0,   0, 111, 109, 275,
 110,   0, 112,   0,   0, 120, 119, 114, 195, 115,
 116, 117, 118, 113,   0,   0,   0, 227, 111, 109,
   0, 110,   0, 112,   0, 120, 119, 114, 195, 115,
 116, 117, 118,   0,   0,   0,   0,   0, 113,   0,
   0,   0,   0, 111, 109,   0, 110,   0, 112, 121,
   0,   0,   0, 120, 119, 114, 195, 115, 116, 117,
 118,   0,   0,  16,  20,  21,  17,  18,  19,  22,
 121,  35,  25,  23,   0,   0,   0,   0,   0,   0,
 120, 119, 114, 195, 115, 116, 117, 118,  16,  20,
  21,  17,  18,  19,  22, 121,  35,  25,  23,   0,
   0,   0,   0, 120, 119, 114, 195, 115, 116, 117,
 118,   0, 120, 119, 114, 195, 115, 116, 117, 118,
   0,   0,   0,  16,  20,  21,  17,  18,  19,  22,
   0,  35,  25,  23,   0,   0,   0,   0,  16,  20,
  21,  17,  18,  19,  22,  71,  35,  25,  23,   0,
   0, 113,   0,  33,   0, 187, 111, 109, 106, 110,
   0, 112,   0,  72,  73,  74,  75,  76,  77,  78,
  79,   0,   0,   0,  47,   8,   0,   8,  33,   0,
   0,   8,   0,   0,   0,  27,   0,   0,   0,   0,
   0,   0,   0,  34,   0,   0,   0,   0,   0,   0,
   0,   8,   0,   0,  44,  94,   0,   0, 121,   0,
  27,  43,  98,  33,   8, 103,  50,   0,   0,   0,
   0,   0,   0,  85,   0,  92,   0,   0,  33,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,  27,  50,   0,   0,   0,
   0,   0, 101,   0,   0, 128,   8,   0,   0,   0,
  27, 127,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   8,   0,  85,   0,   0,
   0, 191,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 199,   0,   0,   0,   0,   0,   0,   0,   0,
 120, 119, 114, 195, 115, 116, 117, 118,   0,   0,
   0,   0,   0,  50,  50,   0,   0,   0,   0, 203,
 205, 120, 119, 114, 195, 115, 116, 117, 118, 221,
 224,   0,  10,  11,   0,   0,  30,  31,  29,   0,
   0,   0,   7,  28,  36,   0, 120, 119, 114, 195,
 115, 116, 117, 118,   0,   0,   0,  10,  11,   0,
   0,  30,  31,  29,   0,   0,   0,   7,  28,  36,
   0,   0,   0,   0,   0,   0,   0,   0,   3,  50,
  50,  50,  50,  50,   0, 252, 253, 254, 255, 258,
 269, 270,  10,  11,   0,   0,  30,  31,  29,   0,
   9,   0,   7,  28,  36,   0,  15,  10,  11,   0,
 299,  30,  31,  29,   0,   0,   0,   7,  28,  36,
   0,   0,   0,   0, 108,   9,   0,   0,   0,   0,
   0,  15, 279,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   9,   0,   0,   0,   0,   0,  15,   0,   0,   0,
   0,   0,   0,   0,   0,   9,   0,   0,   0,  50,
  50,  15,   0,   0,   0, 304, 305 };
short yypact[]={

1282,-1000,1297,-1000,-1000,-331,1297,  27,-337,-1000,
 199,-216,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,  35,-1000,1297,-1000,  23,  31,
-217,  18,-243,-1000,-242,-1000, 187,-1000,-1000,1247,
  95,-1000, 362, -33,-336,-1000,  23,-1000, 232, 243,
-308, -21, 846, 247, 232, 186, 185, 182, 176, 166,
 163, 161, 157, 151, 149,-256,-1000,-274,-1000, -35,
-1000, 160, 160, 160, 160, 160, 160, 160, 160, 160,
-243,1222, 232,  31,-1000,-1000,-230,  35, -25,-1000,
-197,1161,-350, 232,-308,-1000,-1000,  35,-1000,-1000,
1297, -39, -20,-337, 678,-1000, 232, 243, 243, 232,
 232, 232, 232, 232, 232, 232, 232, 232, 232, 232,
 232, 232,-1000, 347, 334,-1000, -13,  48,  34, 551,
-1000,-1000,-1000,-1000,-1000,-1000,-219,-275, 104,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-277,  92,-1000,
 -13, 232, 232, 232, 232, 232, 232, 138, 232, 232,
 232,  91, 140,  66,-1000,-1000,-1000,-1000,-227,-1000,
 232,1161, 232, 243, 243, 243, 243,  83,-1000,-1000,
-1000, 232, 232, 276, 232,-1000,  35,-1000,1161,-1000,
-1000,-1000, 232, 232,-199, 232,  35,  35,1136, 179,
-1000,-1000,1161, 120,1274, -24, 162, 162, -13, -13,
 -13,  45,  45,  45,  45,  45,  -8, 195, -13,1115,
 232,-308, 927, 232,-308,-1000,-260,-1000,-1000,-1000,
-1000,-221,-1000,-224, 918, 895, 868, 840, 820, 799,
-1000, 790, 781, 772,-203,-1000,  84,-1000,  81,-1000,
1161,1161, 145, 145, 145, 145,-256,-204, 145,1161,
1161,1161, -21,1161,-1000, 761, 749,-1000,  45,-1000,
-1000,-1000, 232, 243, 243, 232, 649, 232, 170, 110,
 -23, 140,  66,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000, 232,-1000, 232, 232,-1000,-205,-214,-283, 160,
 232, 232, 154,1161, -40, 145,1161, 232,1161, 232,
-1000, 737, 726, 717,-1000, 601, 579,-1000, 232,-1000,
 708, 125,-1000,-1000,-1000,  89,-1000,  89,-1000,1161,
-1000,-1000, 232,-1000,-1000,-1000,-1000, 232, 699, 687,
-1000,-1000 };
short yypgo[]={

   0,   0, 263,1334, 262,1353,  33, 260, 257, 245,
 243, 236, 230, 234,1371, 235, 231,1365, 126, 979,
 133, 181,  95, 229, 228, 210, 103,1305, 202, 180 };
short yyr1[]={

   0,  23,  23,  23,  13,  13,  12,  12,  12,  12,
  12,  12,  12,  12,  12,  12,  12,  12,  12,  12,
  12,  24,  24,  24,  24,   3,  10,  25,  25,  26,
  26,  26,   9,   9,   9,   9,   8,   8,   2,   2,
   2,   4,   6,   6,   6,   6,   6,  11,  16,  16,
  16,  16,  16,  16,  16,  16,  16,  16,  28,  16,
  15,  27,  27,  29,  29,  29,  29,  29,  29,  29,
  29,  29,  29,  29,  29,  29,  29,  29,  29,  29,
  29,  29,  29,  29,  29,  29,  29,  29,  29,  29,
  19,  19,  20,  20,  20,   5,   5,   5,   7,   7,
  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,
  14,  14,  17,  17,  17,  17,  17,  17,  17,  17,
  17,  17,  17,  17,  17,  18,  18,  18,  21,  21,
  21,  22,  22,  22,  22,  22,  22,  22,  22,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1 };
short yyr2[]={

   0,   1,   0,   1,   1,   2,   2,   3,   3,   4,
   4,   2,   1,   3,   3,   3,   3,   1,   1,   1,
   1,   0,   1,   2,   3,   3,   2,   1,   2,   1,
   2,   2,  10,   7,  10,   7,   4,   3,   1,   3,
   3,   1,   1,   1,   1,   1,   0,   1,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   1,   0,   5,
   1,   2,   0,   2,   1,   1,   2,   1,   2,   2,
   2,   2,   2,   3,   4,   2,   1,   1,   1,   2,
   1,   2,   1,   2,   1,   2,   2,   1,   1,   1,
   1,   2,   1,   2,   2,   1,   4,   6,   1,   3,
   1,   3,   3,   5,   5,   7,   7,   3,   3,   5,
   6,   5,   1,   2,   2,   1,   2,   3,   3,   2,
   3,   3,   1,   2,   2,   4,   4,   3,   2,   2,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   3,   3,   3,   3,   3,   2,   3,   2,
   2,   2,   2,   2,   3,   4,   4,   3,   3,   3,
   3,   3,   3,   3,   3,   2,   4,   4,   3,   4,
   4,   6,   4,   3,   6,   6,   4 };
short yychk[]={

-1000, -23, -13, 256, -12, -16, -11, 280,  -3, 338,
 270, 271, -10,  -9,  -8, 344,   1,   4,   5,   6,
   2,   3,   7,  11, -19,  10, -15, 123, 281, 276,
 274, 275, -20,  91,  -5,   9, 282, -12, 344, -13,
  58, 344,  -1, -14,  -5, 327, 281,  -3,  45,  40,
 -17, 280, -21, 308, 354, 328, 329, 330, 331, 332,
 333, 334, 336, 335, 337, 305, 306, -18, 307, -24,
 281, -27, -27, -27, -27, -27, -27, -27, -27, -27,
 -20, -13,  61, -25, -26,  -5, 272, 273,  -4, 281,
  -2,  -1,  -5,  40, -17, 285, 285,  40, 125, -12,
 344, -14, 280,  -3,  -1, 344,  44, 348, 310,  43,
  45,  42,  47,  37, 347, 349, 350, 351, 352, 346,
 345,  94, 344,  43,  45, 344,  -1, -14, -17,  -1,
 322, 323, 324, 325, 326, 305,  46, -22,   8, 307,
   1,   4,   5,   6,   2,   3,   7, -22,   8, 307,
  -1,  40,  40,  40,  40,  40,  40,  40,  40,  40,
  40, 280, -21, 308, -18, 305, 344, 281,  44, -29,
 284,  -1, 338, 290, 291, 292, 293, 294, 309, 285,
 295, 339, 340, 341, 342, 343, -19,  93,  -1, -26,
 283,  -5, 290,  61, 277, 348, 351, 352,  -1,  -5,
 -12, 344,  -1, -14,  -1, -14,  -1,  -1,  -1,  -1,
  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
  40, -17,  -1,  40, -17,  41,  44,  41, 280, 281,
 305,  46, 305,  46,  -1,  -1,  -1,  -1,  -1,  -1,
  41,  -1,  -1,  -1,  46, -22,   8, -22,   8, 281,
  -1,  -1, -14, -14, -14, -14, 305,  46, -14,  -1,
  -1,  -1, 280,  -1, -28,  -1,  -1, 278,  -1,  -5,
  -5,  41,  44,  44, 311,  44,  -1,  44,  -1, -17,
 280, -21, 308, 280, 281, 280, 281,  41,  41,  41,
  41,  44,  41,  44,  44,  41,  46,  46, 280, -27,
 291, 291,  -7,  -1, -14, -14,  -1,  44,  -1,  44,
  41,  -1,  -1,  -1, 305,  -1,  -1,  41,  44, 347,
  -1,  -1,  41,  41,  41, 293, 279, 293, 279,  -1,
  41,  41,  -6,  43,  45,  42,  47,  -6,  -1,  -1,
 279, 279 };
short yydef[]={

  -2,  -2,   1,   3,   4,   0,   0,   0,   0,  12,
   0,  21,  17,  18,  19,  20,  62,  62,  62,  62,
  62,  62,  62,  62,  62,  57,   0,  47,   0,   0,
   0,   0,  90,  60,  92,  95,   0,   5,   6,   0,
   0,  11,   0,   0,   0, 139, 140, 141,   0,   0,
 100, 112,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 115, 122, 130,   0,
  22,  48,  49,  50,  51,  52,  53,  54,  55,  56,
  91,   0,   0,  26,  27,  29,   0,   0,   0,  41,
   0,  38,   0,   0,   0,  94,  93,   0,   7,   8,
  20,   0, 112, 141,   0,  13,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,  14,   0,   0,  15, 147,   0, 100,   0,
 149, 150, 151, 152, 153, 113,   0, 116, 138, 128,
 131, 132, 133, 134, 135, 136, 137, 119, 138, 129,
 165,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 114,   0,   0, 124, 123,  16,  23,   0,  61,
  64,  65,  67,   0,   0,   0,   0,   0,  76,  77,
  78,  80,  82,  84,  87,  88,  89,  58,  25,  28,
  30,  31,   0,   0,  37,   0,   0,   0,   0,   0,
   9,  10, 102,   0,  -2,   0, 142, 143, 144, 145,
 146,  -2,  -2,  -2,  -2,  -2, 163, 164, 168,   0,
   0, 107,   0,   0, 108, 101,   0, 148, 127, 154,
 117,   0, 120,   0,   0,   0,   0,   0,   0,   0,
 173,   0,   0,   0,   0, 118, 138, 121, 138,  24,
  63,  66,  68,  69,  70,  71,  72,   0,  75,  79,
  81,  83,  -2,  86,  62,   0,   0,  36,  -2,  39,
  40,  96,   0,   0,   0,   0,   0,   0,   0,   0,
 112,   0,   0, 125, 155, 126, 156, 166, 167, 169,
 170,   0, 172,   0,   0, 176,   0,   0,  73,  59,
   0,   0,   0,  98,   0, 111, 103,   0, 104,   0,
 109,   0,   0,   0,  74,   0,   0,  97,   0, 110,
   0,   0, 171, 174, 175,  46,  33,  46,  35,  99,
 105, 106,   0,  42,  43,  44,  45,   0,   0,   0,
  32,  34 };
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
# line 68 "picy.y"
{ ERROR "syntax error" WARNING; } break;
case 6:
# line 77 "picy.y"
{ codegen = 1; makeiattr(0, 0); } break;
case 7:
# line 78 "picy.y"
{ rightthing(yypvt[-2].o, '}'); yyval.o = yypvt[-1].o; } break;
case 8:
# line 79 "picy.y"
{ y.o=yypvt[-0].o; makevar(yypvt[-2].p,PLACENAME,y); yyval.o = yypvt[-0].o; } break;
case 9:
# line 80 "picy.y"
{ y.o=yypvt[-0].o; makevar(yypvt[-3].p,PLACENAME,y); yyval.o = yypvt[-0].o; } break;
case 10:
# line 81 "picy.y"
{ y.o=yypvt[-1].o; makevar(yypvt[-3].p,PLACENAME,y); yyval.o = yypvt[-1].o; } break;
case 11:
# line 82 "picy.y"
{ y.f = yypvt[-1].f; yyval.o = y.o; yyval.o = makenode(PLACE, 0); } break;
case 12:
# line 83 "picy.y"
{ setdir(yypvt[-0].i); yyval.o = makenode(PLACE, 0); } break;
case 13:
# line 84 "picy.y"
{ printexpr(yypvt[-1].f); yyval.o = makenode(PLACE, 0); } break;
case 14:
# line 85 "picy.y"
{ printpos(yypvt[-1].o); yyval.o = makenode(PLACE, 0); } break;
case 15:
# line 86 "picy.y"
{ printf("%s\n", yypvt[-1].p); free(yypvt[-1].p); yyval.o = makenode(PLACE, 0); } break;
case 16:
# line 87 "picy.y"
{ resetvar(); makeiattr(0, 0); yyval.o = makenode(PLACE, 0); } break;
case 22:
# line 96 "picy.y"
{ makevattr(yypvt[-0].p); } break;
case 23:
# line 97 "picy.y"
{ makevattr(yypvt[-0].p); } break;
case 24:
# line 98 "picy.y"
{ makevattr(yypvt[-0].p); } break;
case 25:
# line 102 "picy.y"
{ yyval.f=y.f=yypvt[-0].f; makevar(yypvt[-2].p,VARNAME,y); checkscale(yypvt[-2].p); } break;
case 26:
# line 106 "picy.y"
{ copy(); } break;
case 29:
# line 113 "picy.y"
{ copyfile(yypvt[-0].p); } break;
case 30:
# line 114 "picy.y"
{ copydef(yypvt[-0].st); } break;
case 31:
# line 115 "picy.y"
{ copyuntil(yypvt[-0].p); } break;
case 32:
# line 120 "picy.y"
{ forloop(yypvt[-8].p, yypvt[-6].f, yypvt[-4].f, yypvt[-2].i, yypvt[-1].f, yypvt[-0].p); } break;
case 33:
# line 122 "picy.y"
{ forloop(yypvt[-5].p, yypvt[-3].f, yypvt[-1].f, '+', 1.0, yypvt[-0].p); } break;
case 34:
# line 124 "picy.y"
{ forloop(yypvt[-8].p, yypvt[-6].f, yypvt[-4].f, yypvt[-2].i, yypvt[-1].f, yypvt[-0].p); } break;
case 35:
# line 126 "picy.y"
{ forloop(yypvt[-5].p, yypvt[-3].f, yypvt[-1].f, '+', 1.0, yypvt[-0].p); } break;
case 36:
# line 130 "picy.y"
{ ifstat(yypvt[-2].f, yypvt[-1].p, yypvt[-0].p); } break;
case 37:
# line 131 "picy.y"
{ ifstat(yypvt[-1].f, yypvt[-0].p, (char *) 0); } break;
case 39:
# line 135 "picy.y"
{ yyval.f = strcmp(yypvt[-2].p,yypvt[-0].p) == 0; free(yypvt[-2].p); free(yypvt[-0].p); } break;
case 40:
# line 136 "picy.y"
{ yyval.f = strcmp(yypvt[-2].p,yypvt[-0].p) != 0; free(yypvt[-2].p); free(yypvt[-0].p); } break;
case 41:
# line 140 "picy.y"
{ y.f = 0; makevar(yypvt[-0].p, VARNAME, y); } break;
case 42:
# line 143 "picy.y"
{ yyval.i = '+'; } break;
case 43:
# line 144 "picy.y"
{ yyval.i = '-'; } break;
case 44:
# line 145 "picy.y"
{ yyval.i = '*'; } break;
case 45:
# line 146 "picy.y"
{ yyval.i = '/'; } break;
case 46:
# line 147 "picy.y"
{ yyval.i = ' '; } break;
case 47:
# line 152 "picy.y"
{ yyval.o = leftthing('{'); } break;
case 48:
# line 156 "picy.y"
{ yyval.o = boxgen(); } break;
case 49:
# line 157 "picy.y"
{ yyval.o = circgen(yypvt[-1].i); } break;
case 50:
# line 158 "picy.y"
{ yyval.o = circgen(yypvt[-1].i); } break;
case 51:
# line 159 "picy.y"
{ yyval.o = arcgen(yypvt[-1].i); } break;
case 52:
# line 160 "picy.y"
{ yyval.o = linegen(yypvt[-1].i); } break;
case 53:
# line 161 "picy.y"
{ yyval.o = linegen(yypvt[-1].i); } break;
case 54:
# line 162 "picy.y"
{ yyval.o = linegen(yypvt[-1].i); } break;
case 55:
# line 163 "picy.y"
{ yyval.o = movegen(); } break;
case 56:
# line 164 "picy.y"
{ yyval.o = textgen(); } break;
case 57:
# line 165 "picy.y"
{ yyval.o = troffgen(yypvt[-0].p); } break;
case 58:
# line 166 "picy.y"
{ yyval.o=rightthing(yypvt[-2].o,']'); } break;
case 59:
# line 167 "picy.y"
{ yyval.o = blockgen(yypvt[-4].o, yypvt[-1].o); } break;
case 60:
# line 171 "picy.y"
{ yyval.o = leftthing('['); } break;
case 63:
# line 180 "picy.y"
{ makefattr(yypvt[-1].i, !DEFAULT, yypvt[-0].f); } break;
case 64:
# line 181 "picy.y"
{ makefattr(yypvt[-0].i, DEFAULT, 0.0); } break;
case 65:
# line 182 "picy.y"
{ makefattr(curdir(), !DEFAULT, yypvt[-0].f); } break;
case 66:
# line 183 "picy.y"
{ makefattr(yypvt[-1].i, !DEFAULT, yypvt[-0].f); } break;
case 67:
# line 184 "picy.y"
{ makefattr(yypvt[-0].i, DEFAULT, 0.0); } break;
case 68:
# line 185 "picy.y"
{ makeoattr(yypvt[-1].i, yypvt[-0].o); } break;
case 69:
# line 186 "picy.y"
{ makeoattr(yypvt[-1].i, yypvt[-0].o); } break;
case 70:
# line 187 "picy.y"
{ makeoattr(yypvt[-1].i, yypvt[-0].o); } break;
case 71:
# line 188 "picy.y"
{ makeoattr(yypvt[-1].i, yypvt[-0].o); } break;
case 72:
# line 189 "picy.y"
{ makeiattr(WITH, yypvt[-0].i); } break;
case 73:
# line 190 "picy.y"
{ makeoattr(PLACE, getblock(getlast(1,BLOCK), yypvt[-0].p)); } break;
case 74:
# line 192 "picy.y"
{ makeoattr(PLACE, getpos(getblock(getlast(1,BLOCK), yypvt[-1].p), yypvt[-0].i)); } break;
case 75:
# line 193 "picy.y"
{ makeoattr(PLACE, yypvt[-0].o); } break;
case 76:
# line 194 "picy.y"
{ makeiattr(SAME, yypvt[-0].i); } break;
case 77:
# line 195 "picy.y"
{ maketattr(yypvt[-0].i, (char *) 0); } break;
case 78:
# line 196 "picy.y"
{ makeiattr(HEAD, yypvt[-0].i); } break;
case 79:
# line 197 "picy.y"
{ makefattr(DOT, !DEFAULT, yypvt[-0].f); } break;
case 80:
# line 198 "picy.y"
{ makefattr(DOT, DEFAULT, 0.0); } break;
case 81:
# line 199 "picy.y"
{ makefattr(DASH, !DEFAULT, yypvt[-0].f); } break;
case 82:
# line 200 "picy.y"
{ makefattr(DASH, DEFAULT, 0.0); } break;
case 83:
# line 201 "picy.y"
{ makefattr(CHOP, !DEFAULT, yypvt[-0].f); } break;
case 84:
# line 202 "picy.y"
{ makefattr(CHOP, DEFAULT, 0.0); } break;
case 85:
# line 203 "picy.y"
{ makeattr(CHOP, PLACENAME, getvar(yypvt[-0].p)); } break;
case 86:
# line 204 "picy.y"
{ makefattr(FILL, !DEFAULT, yypvt[-0].f); } break;
case 87:
# line 205 "picy.y"
{ makefattr(FILL, DEFAULT, 0.0); } break;
case 88:
# line 206 "picy.y"
{ makeiattr(NOEDGE, 0); } break;
case 92:
# line 215 "picy.y"
{ maketattr(CENTER, yypvt[-0].p); } break;
case 93:
# line 216 "picy.y"
{ maketattr(yypvt[-0].i, yypvt[-1].p); } break;
case 94:
# line 217 "picy.y"
{ addtattr(yypvt[-0].i); } break;
case 96:
# line 221 "picy.y"
{ yyval.p = sprintgen(yypvt[-1].p); } break;
case 97:
# line 222 "picy.y"
{ yyval.p = sprintgen(yypvt[-3].p); } break;
case 98:
# line 226 "picy.y"
{ exprsave(yypvt[-0].f); yyval.i = 0; } break;
case 99:
# line 227 "picy.y"
{ exprsave(yypvt[-0].f); } break;
case 101:
# line 232 "picy.y"
{ yyval.o = yypvt[-1].o; } break;
case 102:
# line 233 "picy.y"
{ yyval.o = makepos(yypvt[-2].f, yypvt[-0].f); } break;
case 103:
# line 234 "picy.y"
{ yyval.o = fixpos(yypvt[-4].o, yypvt[-2].f, yypvt[-0].f); } break;
case 104:
# line 235 "picy.y"
{ yyval.o = fixpos(yypvt[-4].o, -yypvt[-2].f, -yypvt[-0].f); } break;
case 105:
# line 236 "picy.y"
{ yyval.o = fixpos(yypvt[-6].o, yypvt[-3].f, yypvt[-1].f); } break;
case 106:
# line 237 "picy.y"
{ yyval.o = fixpos(yypvt[-6].o, -yypvt[-3].f, -yypvt[-1].f); } break;
case 107:
# line 238 "picy.y"
{ yyval.o = addpos(yypvt[-2].o, yypvt[-0].o); } break;
case 108:
# line 239 "picy.y"
{ yyval.o = subpos(yypvt[-2].o, yypvt[-0].o); } break;
case 109:
# line 240 "picy.y"
{ yyval.o = makepos(getcomp(yypvt[-3].o,DOTX), getcomp(yypvt[-1].o,DOTY)); } break;
case 110:
# line 241 "picy.y"
{ yyval.o = makebetween(yypvt[-5].f, yypvt[-3].o, yypvt[-1].o); } break;
case 111:
# line 242 "picy.y"
{ yyval.o = makebetween(yypvt[-4].f, yypvt[-2].o, yypvt[-0].o); } break;
case 112:
# line 246 "picy.y"
{ y = getvar(yypvt[-0].p); yyval.o = y.o; } break;
case 113:
# line 247 "picy.y"
{ y = getvar(yypvt[-1].p); yyval.o = getpos(y.o, yypvt[-0].i); } break;
case 114:
# line 248 "picy.y"
{ y = getvar(yypvt[-0].p); yyval.o = getpos(y.o, yypvt[-1].i); } break;
case 115:
# line 249 "picy.y"
{ yyval.o = gethere(); } break;
case 116:
# line 250 "picy.y"
{ yyval.o = getlast(yypvt[-1].i, yypvt[-0].i); } break;
case 117:
# line 251 "picy.y"
{ yyval.o = getpos(getlast(yypvt[-2].i, yypvt[-1].i), yypvt[-0].i); } break;
case 118:
# line 252 "picy.y"
{ yyval.o = getpos(getlast(yypvt[-1].i, yypvt[-0].i), yypvt[-2].i); } break;
case 119:
# line 253 "picy.y"
{ yyval.o = getfirst(yypvt[-1].i, yypvt[-0].i); } break;
case 120:
# line 254 "picy.y"
{ yyval.o = getpos(getfirst(yypvt[-2].i, yypvt[-1].i), yypvt[-0].i); } break;
case 121:
# line 255 "picy.y"
{ yyval.o = getpos(getfirst(yypvt[-1].i, yypvt[-0].i), yypvt[-2].i); } break;
case 123:
# line 257 "picy.y"
{ yyval.o = getpos(yypvt[-1].o, yypvt[-0].i); } break;
case 124:
# line 258 "picy.y"
{ yyval.o = getpos(yypvt[-0].o, yypvt[-1].i); } break;
case 125:
# line 262 "picy.y"
{ yyval.o = getblock(getlast(yypvt[-3].i,yypvt[-2].i), yypvt[-0].p); } break;
case 126:
# line 263 "picy.y"
{ yyval.o = getblock(getfirst(yypvt[-3].i,yypvt[-2].i), yypvt[-0].p); } break;
case 127:
# line 264 "picy.y"
{ y = getvar(yypvt[-2].p); yyval.o = getblock(y.o, yypvt[-0].p); } break;
case 128:
# line 268 "picy.y"
{ yyval.i = yypvt[-1].i + 1; } break;
case 129:
# line 269 "picy.y"
{ yyval.i = yypvt[-1].i; } break;
case 130:
# line 270 "picy.y"
{ yyval.i = 1; } break;
case 140:
# line 286 "picy.y"
{ yyval.f = getfval(yypvt[-0].p); } break;
case 142:
# line 288 "picy.y"
{ yyval.f = yypvt[-2].f + yypvt[-0].f; } break;
case 143:
# line 289 "picy.y"
{ yyval.f = yypvt[-2].f - yypvt[-0].f; } break;
case 144:
# line 290 "picy.y"
{ yyval.f = yypvt[-2].f * yypvt[-0].f; } break;
case 145:
# line 291 "picy.y"
{ if (yypvt[-0].f == 0.0) {
					ERROR "division by 0" WARNING; yypvt[-0].f = 1; }
				  yyval.f = yypvt[-2].f / yypvt[-0].f; } break;
case 146:
# line 294 "picy.y"
{ if ((long)yypvt[-0].f == 0) {
					ERROR "mod division by 0" WARNING; yypvt[-0].f = 1; }
				  yyval.f = (long)yypvt[-2].f % (long)yypvt[-0].f; } break;
case 147:
# line 297 "picy.y"
{ yyval.f = -yypvt[-0].f; } break;
case 148:
# line 298 "picy.y"
{ yyval.f = yypvt[-1].f; } break;
case 149:
# line 299 "picy.y"
{ yyval.f = getcomp(yypvt[-1].o, yypvt[-0].i); } break;
case 150:
# line 300 "picy.y"
{ yyval.f = getcomp(yypvt[-1].o, yypvt[-0].i); } break;
case 151:
# line 301 "picy.y"
{ yyval.f = getcomp(yypvt[-1].o, yypvt[-0].i); } break;
case 152:
# line 302 "picy.y"
{ yyval.f = getcomp(yypvt[-1].o, yypvt[-0].i); } break;
case 153:
# line 303 "picy.y"
{ yyval.f = getcomp(yypvt[-1].o, yypvt[-0].i); } break;
case 154:
# line 304 "picy.y"
{ y = getvar(yypvt[-2].p); yyval.f = getblkvar(y.o, yypvt[-0].p); } break;
case 155:
# line 305 "picy.y"
{ yyval.f = getblkvar(getlast(yypvt[-3].i,yypvt[-2].i), yypvt[-0].p); } break;
case 156:
# line 306 "picy.y"
{ yyval.f = getblkvar(getfirst(yypvt[-3].i,yypvt[-2].i), yypvt[-0].p); } break;
case 157:
# line 307 "picy.y"
{ yyval.f = yypvt[-2].f > yypvt[-0].f; } break;
case 158:
# line 308 "picy.y"
{ yyval.f = yypvt[-2].f < yypvt[-0].f; } break;
case 159:
# line 309 "picy.y"
{ yyval.f = yypvt[-2].f <= yypvt[-0].f; } break;
case 160:
# line 310 "picy.y"
{ yyval.f = yypvt[-2].f >= yypvt[-0].f; } break;
case 161:
# line 311 "picy.y"
{ yyval.f = yypvt[-2].f == yypvt[-0].f; } break;
case 162:
# line 312 "picy.y"
{ yyval.f = yypvt[-2].f != yypvt[-0].f; } break;
case 163:
# line 313 "picy.y"
{ yyval.f = yypvt[-2].f && yypvt[-0].f; } break;
case 164:
# line 314 "picy.y"
{ yyval.f = yypvt[-2].f || yypvt[-0].f; } break;
case 165:
# line 315 "picy.y"
{ yyval.f = !(yypvt[-0].f); } break;
case 166:
# line 316 "picy.y"
{ yyval.f = Log10(yypvt[-1].f); } break;
case 167:
# line 317 "picy.y"
{ yyval.f = Exp(yypvt[-1].f * log(10.0)); } break;
case 168:
# line 318 "picy.y"
{ yyval.f = pow(yypvt[-2].f, yypvt[-0].f); } break;
case 169:
# line 319 "picy.y"
{ yyval.f = sin(yypvt[-1].f); } break;
case 170:
# line 320 "picy.y"
{ yyval.f = cos(yypvt[-1].f); } break;
case 171:
# line 321 "picy.y"
{ yyval.f = atan2(yypvt[-3].f, yypvt[-1].f); } break;
case 172:
# line 322 "picy.y"
{ yyval.f = Sqrt(yypvt[-1].f); } break;
case 173:
# line 323 "picy.y"
{ yyval.f = (float)rand() / 32767.0; /* might be 2^31-1 */ } break;
case 174:
# line 324 "picy.y"
{ yyval.f = yypvt[-3].f >= yypvt[-1].f ? yypvt[-3].f : yypvt[-1].f; } break;
case 175:
# line 325 "picy.y"
{ yyval.f = yypvt[-3].f <= yypvt[-1].f ? yypvt[-3].f : yypvt[-1].f; } break;
case 176:
# line 326 "picy.y"
{ yyval.f = (long) yypvt[-1].f; } break;
	}
	goto yystack;  /* stack new state and value */
}
