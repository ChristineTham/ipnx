
# line 2 "grap.y"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "grap.h"

#define	RAND_MAX 32767	/* if your rand() returns bigger, change this too */

extern int yylex(void);
extern int yyparse(void);

# define FRAME 257
# define TICKS 258
# define GRID 259
# define LABEL 260
# define COORD 261
# define LINE 262
# define ARROW 263
# define CIRCLE 264
# define DRAW 265
# define NEW 266
# define PLOT 267
# define NEXT 268
# define PIC 269
# define COPY 270
# define THRU 271
# define UNTIL 272
# define FOR 273
# define FROM 274
# define TO 275
# define BY 276
# define AT 277
# define WITH 278
# define IF 279
# define GRAPH 280
# define THEN 281
# define ELSE 282
# define DOSTR 283
# define DOT 284
# define DASH 285
# define INVIS 286
# define SOLID 287
# define TEXT 288
# define JUST 289
# define SIZE 290
# define LOG 291
# define EXP 292
# define SIN 293
# define COS 294
# define ATAN2 295
# define SQRT 296
# define RAND 297
# define MAX 298
# define MIN 299
# define INT 300
# define PRINT 301
# define SPRINTF 302
# define X 303
# define Y 304
# define SIDE 305
# define IN 306
# define OUT 307
# define OFF 308
# define UP 309
# define DOWN 310
# define ACROSS 311
# define HEIGHT 312
# define WIDTH 313
# define RADIUS 314
# define NUMBER 315
# define NAME 316
# define VARNAME 317
# define DEFNAME 318
# define STRING 319
# define ST 320
# define OR 321
# define AND 322
# define GT 323
# define LT 324
# define LE 325
# define GE 326
# define EQ 327
# define NE 328
# define UMINUS 329
# define NOT 330
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
-1, 4,
	320, 29,
	-2, 4,
-1, 53,
	320, 29,
	-2, 5,
-1, 64,
	61, 197,
	-2, 166,
-1, 142,
	320, 29,
	-2, 6,
-1, 210,
	320, 134,
	-2, 58,
-1, 241,
	323, 0,
	324, 0,
	325, 0,
	326, 0,
	327, 0,
	328, 0,
	-2, 186,
-1, 242,
	323, 0,
	324, 0,
	325, 0,
	326, 0,
	327, 0,
	328, 0,
	-2, 187,
-1, 243,
	323, 0,
	324, 0,
	325, 0,
	326, 0,
	327, 0,
	328, 0,
	-2, 188,
-1, 244,
	323, 0,
	324, 0,
	325, 0,
	326, 0,
	327, 0,
	328, 0,
	-2, 189,
-1, 245,
	323, 0,
	324, 0,
	325, 0,
	326, 0,
	327, 0,
	328, 0,
	-2, 190,
-1, 246,
	323, 0,
	324, 0,
	325, 0,
	326, 0,
	327, 0,
	328, 0,
	-2, 191,
	};
# define YYNPROD 200
# define YYLAST 1617
short yyact[]={

 263, 204, 226, 138, 137, 219, 220,  63, 143,  41,
  66,  54,  65, 296, 295, 216,  50,  50,  46, 268,
  45, 128, 231,  89,  90, 100,  59,  91, 104, 105,
 107, 106, 116,  49,  49,  60, 222, 203, 126, 275,
 113,  88, 272, 114,  98, 112,  50, 136, 131,  47,
  48, 104, 105, 107, 106, 218, 217, 118, 132, 133,
 135, 286,  50,  49, 165, 191, 166, 167,  50, 180,
  95,  96,  87, 341, 262, 101,  89,  90, 178,  49,
  91, 112, 181, 182, 112,  49, 121, 110, 184,  50,
 186, 187, 188, 342, 268,  46, 319,  45,  89,  90,
   8, 278,  91, 200, 193, 318,  49, 139, 140, 292,
  46,  58,  45, 276, 277, 198, 199, 317, 117, 282,
  57, 208, 213, 120, 323, 113, 205, 283, 104, 105,
 107, 106, 212, 215, 207, 224, 261,  63, 130, 131,
  66, 225,  65, 223, 155, 196, 232, 233, 134,  79,
  58, 235, 236, 237, 238, 239, 240, 241, 242, 243,
 244, 245, 246, 247, 248, 104, 105, 107, 106, 251,
 252, 253, 254, 255, 256, 257, 258, 259, 260,  63,
 211,  84,  66, 249,  65, 349, 264,  93, 350, 280,
 229, 227,  66, 228,  65, 230,   7, 104, 105, 107,
 106,  52, 177, 279, 113,   4, 129, 298, 176,  99,
 299,  53, 175, 174, 154, 290, 291, 195, 110, 152,
 150, 287, 151,  80, 153, 145, 146, 297, 179, 173,
 172,   3,   9,  26,  27,  28,  29,  32, 171,  33,
  42,  43,  31,  35,  19,  38,  30, 170,  36, 169,
  52,  94, 109, 168,  37,   8, 141, 142,  67,  68,
  69,  70,  71,  72,  73,  74,  75,  76, 221, 184,
 288, 155, 313, 310,  99, 315,  25,  50, 115, 147,
 189, 320,  61,  47,  64,  39, 128, 325,  40,  92,
  44,  47,  48,  78,  49,   6, 154,  77, 266,  22,
 331, 152, 150, 329, 151, 332, 153, 333, 334,  56,
 164,   5,  20, 154,  51, 338,  94, 340, 152, 150,
 343, 151,  18, 153,  17, 124, 154, 265, 347, 348,
  16, 152, 150, 225, 151,  15, 153, 354, 355,  52,
 357, 269,  14, 149,  13, 359, 214, 326, 127,  12,
  11, 365,  10, 155, 364, 194, 367, 368, 309, 369,
   2,   1, 309, 371, 205, 372, 197,  44, 225, 373,
 155, 154, 374, 375, 376, 370, 152, 150, 379, 151,
 345, 153,  44, 155, 335,  55, 205, 144,  67,  68,
  69,  70,  71,  72,  73,  74,  75,  76, 330,  50,
 154,  34, 103,  23, 250, 152, 150,  58, 151, 108,
 153,  21,  61,  47,  64, 154,  49, 344, 125, 192,
 152, 150,  58, 151,   0, 153,   0,  77, 155,   0,
  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,
  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,
   0,   0,   0, 362,  61,  47,  64, 155,   0,   0,
 363,   0,   0, 154,  61,  47,  64,   0, 152,  77,
 154,   0, 155, 153,   0, 152, 150,  58, 151,  77,
 153,  86,   0,   0,   0,   0, 154,   0,   0,   0,
 353, 152, 150,   0, 151,   0, 153,   0, 163, 162,
 156, 157, 158, 159, 160, 161,  46, 154,  45, 102,
   0,   0, 152, 150,   0, 151, 154, 153,   0,   0,
 155, 152, 150,   0, 151,   0, 153, 155, 293, 294,
   0, 154,   0,   0,   0, 366, 152, 150,   0, 151,
   0, 153,   0, 155,   0,   0,   0,   0, 154,   0,
   0,   0, 360, 152, 150,   0, 151,   0, 153, 361,
   0,  50, 154,   0, 155,   0, 352, 152, 150,   0,
 151,   0, 153, 155, 102,   0,   0,   0,  49,   0,
 163, 162, 156, 157, 158, 159, 160, 161, 155,   0,
   0,  50,   0,   0,   0,   0,   0, 163, 162, 156,
 157, 158, 159, 160, 161, 155,   0,   0,  49,   0,
 163, 162, 156, 157, 158, 159, 160, 161, 154, 155,
   0,   0, 351, 152, 150,   0, 151,   0, 153,   0,
   0,   0,   0,  88,   0, 154,  83,   0,   0,   0,
 152, 150,   0, 151,   0, 153,   0,   0,   0,   0,
   0,   0,   0, 339,   0, 163, 162, 156, 157, 158,
 159, 160, 161,   0,  87,  81,  82,  85,  89,  90,
   0,   0,  91,   0,   0, 155, 267,   0,   0,   0,
   0,   0,   0,   0, 163, 162, 156, 157, 158, 159,
 160, 161, 155,   0,   0,   0,   0,   0,   0, 163,
 162, 156, 157, 158, 159, 160, 161,   0, 337, 154,
   0,   0,   0,   0, 152, 150,   0, 151,   0, 153,
   9,  26,  27,  28,  29,  32,   0,  33,  42,  43,
  31,  35,  19,  38,   0,   0,  36,   0,   0,   0,
   0,   0,  37,   0,   0,   0,   0,   0, 312,   0,
   0,   0,   0, 378, 163, 162, 156, 157, 158, 159,
 160, 161, 377,   0,  25,  50, 155,   0,   0, 358,
 163, 162, 156, 157, 158, 159, 160, 161,  44,  47,
  48,   0,  49,   6,   0,   0, 356,   0,   0,   0,
   0, 163, 162, 156, 157, 158, 159, 160, 161,   0,
 163, 162, 156, 157, 158, 159, 160, 161,   0,   0,
   0,   0,   0,   0,   0, 163, 162, 156, 157, 158,
 159, 160, 161,   0,   0,   0,   0,   0,   0,   0,
   0,   0, 163, 162, 156, 157, 158, 159, 160, 161,
  46,   0,  45,   0,   0,   0, 163, 162, 156, 157,
 158, 159, 160, 161, 154,   0,   0,   0,   0, 152,
 150,  58, 151,   0, 153,   0,   0,   0,   0,   0,
 154,   0,   0, 328,   0, 152, 150,   0, 151, 154,
 153,   0,   0, 308, 152, 150,   0, 151, 154, 153,
   0,   0,   0, 152, 150, 307, 151,   0, 153,   0,
   0,   0, 163, 162, 156, 157, 158, 159, 160, 161,
   0, 155,   0,   0,   0,   0,   0,   0,   0, 163,
 162, 156, 157, 158, 159, 160, 161, 155,   0,   0,
   0,   0, 154,   0,   0,   0, 155, 152, 150, 306,
 151,   0, 153,   0, 154, 155,   0, 327, 305, 152,
 150,   0, 151, 154, 153,   0,   0,   0, 152, 150,
 304, 151, 154, 153,   0,   0, 303, 152, 150,   0,
 151, 154, 153,   0,   0, 302, 152, 150, 119, 151,
 154, 153,   0,   0, 301, 152, 150,   0, 151, 155,
 153,   0,   0, 163, 162, 156, 157, 158, 159, 160,
 161, 155,   0, 154,   0,   0,  97, 300, 152, 150,
 155, 151, 154, 153,   0,   0, 250, 152, 150, 155,
 151, 154, 153,   0,   0,   0, 152, 150, 155, 151,
   0, 153,   0, 154, 148,   0,   0, 155, 152, 150,
 154, 151,   0, 153,   0, 152, 150,   0, 151,   0,
 153,   0,   0,   0,   9,  26,  27,  28,  29,  32,
 155,  33,  42,  43,  31,  35,  19,  38,   0, 155,
  36,  97,   0,   0, 154,   0,  37,   0, 155, 152,
 150,   0, 151,   0, 153,   0,   0,   0,   0,   0,
 155,   0,   0,   0,   0,   0,   0, 155,  25,  50,
   0, 210,   0,   0,   0,   0,   0,   0, 311,   0,
   0,   0,  44,  47,  48,   0,  49,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 234,   0,   0,  62,
  24, 155,   0,   0,  24,  24,   0,   0, 163, 162,
 156, 157, 158, 159, 160, 161,   0,   0,   0,   0,
   0,   0,   0,   0, 163, 162, 156, 157, 158, 159,
 160, 161,   0, 163, 162, 156, 157, 158, 159, 160,
 161,   0, 163, 162, 156, 157, 158, 159, 160, 161,
   0,  24,   0,  24,   0,   0,   0,   0, 154,   0,
   0,   0,   0, 152, 150,   0, 151,   0, 153,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0, 201,   0, 163, 162, 156, 157,
 158, 159, 160, 161,   0,   0,   0,   0, 163, 162,
 156, 157, 158, 159, 160, 161,   0, 163, 162, 156,
 157, 158, 159, 160, 161, 155, 163, 162, 156, 157,
 158, 159, 160, 161,   0, 163, 162, 156, 157, 158,
 159, 160, 161,   0, 163, 162, 156, 157, 158, 159,
 160, 161,  24, 285,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0, 163, 162, 156,
 157, 158, 159, 160, 161,   0, 163, 162, 156, 157,
 158, 159, 160, 161, 202, 163, 162, 156, 157, 158,
 159, 160, 161,   0,   0,   0,   0, 163, 162, 156,
 157, 158, 159, 160, 161, 162, 156, 157, 158, 159,
 160, 161, 206,   0, 111,   0, 209,   0,   0, 122,
 123,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
 156, 157, 158, 159, 160, 161,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0, 183,   0,
   0,   0,   0, 185,   0,   0,   0,   0,   0,   0,
   0,   0,   0, 190,   0,   0,   0,   0,   0,   0,
   0,   0,   0, 270, 273,   0,   0,   0, 281,   0,
   0,   0, 284,   0,   0,   0,   0,   0, 289,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0, 321, 322,   0,
 324,   0,   0, 271, 274,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0, 346,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0, 314,   0,   0,
 316,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 336 };
short yypact[]={

 -25,-1000,-180,-1000, 797, 463,-1000,-309,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,  67,-1000,  97, 359,-233,-218,-271,
-234,  97,-156,-191,-271,-271,-267, -33,-213,-1000,
  87,-1000,-1000,-1000,-1000,-255,-268,-1000,-1000,-182,
 216, 463,-312, 797,-1000, -87,-1000,  52,-1000, 984,
-1000,-1000,-1000, -33,-1000, 139, 139, 213, 209, 207,
 198, 190, 189, 173, 172, 168, 162, 139, 359,-1000,
-239, 139, 139,-271,-1000,-1000,-1000, 139,-271, 139,
 139, 139,-233,-1000,-1000,-1000,-1000,-1000,-271,-1000,
-243,-1000,-1000, 139,-1000,-1000,-1000,-1000,-285,-1000,
-1000,-188,-1000,-1000,-271,-240, 289,-271,-140,-1000,
 139,-271,-256,-155,  72,-266, 984,-1000,-322,-213,
-1000,-1000,-282,-285, 139,-1000,-1000,-182,-1000,-1000,
 148,-297, 797,-1000,-1000, 139, 139,-119,-1000,-1000,
 139, 139, 139, 139, 139, 139, 139, 139, 139, 139,
 139, 139, 139, 139, 142, 975,  50,  50, 139, 139,
 139, 139, 139, 139, 134, 139, 139, 139,  50,-1000,
-1000, 984, 984, 139, 984, 139, 984, 984, 984,-1000,
 139,-1000,-1000, 984,-286,-188,-1000,-1000,-232,-235,
-190,-1000, 149,-271,-158,-1000,-148,-271, 996,-253,
-1000,-285,-119,-271, 139, 139,-173,-298,-298,-305,
-306,-1000,-1000,-1000, 984,-1000, 139,-1000,-1000,-1000,
-1000, 166, 984, 984,-1000, 426, 426,  50,  50,  50,
  50,1151,1151,1151,1151,1151,1151,1037,1003,-1000,
-1000, 966, 943, 934, 925, 916, 907,-1000, 895, 851,
 842, 106,-1000, 289, 833, 106,-211,-1000, 139,-1000,
-1000, 149,-271,-1000, 149,-271,-174,-186,-1000, 817,
 -33,-1000,-271,-271,-151,-271, 139,-1000,-1000,-119,
 672, 598,-1000,-1000,-1000,-1000,-1000, 984,-182, 139,
-1000,-1000,-1000,-1000, 139,-1000, 139, 139,-1000, 139,
-1000,-271,-1000, 433, 139, 378, 139,-231,-210, 139,
 363,-1000,-119,-271,-1000, 984,-1000, 139, 139,-182,
 144, 984, 581, 525, 449,-1000, 139, 139, 511, 139,
 494,-1000,-1000, 984, 139,-1000,-1000, 276, 177,-182,
 139,-1000,-1000,-1000, 259, 984, 139, 984, 139, 334,
 148,-1000, 148,-1000,-182, 984, 148,-1000, 984, 984,
-1000, 139, 139, 139, 479, 470, 289,-1000,-1000,-1000 };
short yypgo[]={

   0,   0, 419, 418, 285,1129,   2,   1, 411,1304,
 181, 288,1214, 223, 409, 403,  96, 402, 401, 978,
  57, 246,   9,   3,   4, 398, 387, 385, 366, 310,
 361, 360, 205, 311, 196, 352, 350, 349, 344, 342,
 335, 330, 324, 322, 312, 299, 298, 481, 293, 149,
 136,  74, 289, 187, 217, 145, 206, 138 };
short yyr1[]={

   0,  30,  30,  30,  31,  31,  31,  33,  32,  32,
  32,  34,  34,  34,  34,  34,  34,  34,  34,  34,
  34,  34,  34,  34,  34,  34,  34,  34,  34,  34,
  15,  15,  15,   4,   4,   4,  37,  46,  46,  46,
  47,  47,  47,  47,  27,  27,  26,  26,  26,  26,
  13,  14,  14,  19,  17,  17,  17,  17,  20,  20,
  35,  48,  48,  49,  49,  49,  49,  49,  49,  49,
  49,  49,  49,  50,  50,  51,  51,  10,  10,   6,
   6,   6,   6,   6,   7,   7,  36,  52,  52,  53,
  53,  53,  53,  53,  53,  53,  53,  53,  40,  40,
  41,  41,  41,  21,  21,  22,  22,  22,  25,  25,
  24,  24,  24,  23,  23,  38,  38,  54,  54,  55,
  55,  55,  55,  55,  55,  55,  28,  28,  28,  28,
  28,  39,  39,  39,  42,  42,  42,  18,  18,  43,
  45,  56,  56,  57,  57,  57,  44,  44,  44,  44,
   8,   8,   3,   3,   3,   3,  29,  29,  12,  12,
  16,   9,   9,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   5,  11,  11,   2,   2 };
short yyr2[]={

   0,   1,   0,   1,   1,   2,   3,   1,   1,   2,
   3,   2,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   2,   2,   0,
   1,   2,   3,   1,   2,   2,   4,   1,   2,   0,
   2,   2,   2,   2,   2,   0,   2,   2,   2,   1,
   1,   1,   0,   2,   1,   1,   1,   1,   1,   0,
   2,   1,   2,   1,   2,   2,   1,   1,   3,   1,
   2,   1,   1,   1,   3,   1,   2,  10,   7,   1,
   1,   1,   1,   0,   1,   0,   2,   1,   2,   1,
   1,   1,   1,   3,   1,   2,   1,   1,   6,   6,
   5,   5,   3,   1,   2,   2,   5,   7,   1,   3,
   1,   2,   0,   1,   3,   3,   2,   1,   2,   1,
   2,   2,   5,   5,   6,   6,   2,   2,   4,   4,
   2,   3,   4,   5,   3,   4,   4,   1,   1,   5,
   2,   1,   2,   1,   2,   2,  10,   7,  10,   7,
   4,   3,   1,   1,   3,   3,   3,   3,   4,   6,
   1,   1,   0,   1,   1,   3,   1,   3,   3,   3,
   3,   3,   2,   2,   3,   4,   4,   3,   4,   4,
   6,   4,   3,   6,   6,   4,   3,   3,   3,   3,
   3,   3,   3,   3,   2,   3,   1,   1,   1,   0 };
short yychk[]={

-1000, -30, -31, 256, -32, -33, 320, -34, 280, 257,
 -35, -36, -37, -38, -39, -40, -41, -42, -43, 269,
 -44,  -8, -45, -15,  -5, 301, 258, 259, 260, 261,
 -21, 267, 262, 264, -18, 268, 273, 279, 270,  -4,
 -11, -22, 265, 266, 315,  45,  43, 316, 317, 319,
 302, -33, -34, -32, 320, -27,  -4, -16,  44,  -1,
 -22, 315,  -5,  40, 317,  45,  43, 291, 292, 293,
 294, 295, 296, 297, 298, 299, 300, 330, -48, -49,
 -13, 306, 307, 277, -10, 308, -47, 305, 274, 309,
 310, 313, -52, -53, -13, 303, 304, -19, 277, -10,
 258, 308, -47, -17, 284, 285, 287, 286, -14, -13,
 305,  -9, 316, -22, 277, -21,  -1, 274, -20, -19,
 314, 277,  -9,  -9, -11,  -3,  -1, -29, 319, -56,
 -57, -22, 271, 272,  61, 315, 315, -24, -23, 289,
 290,  40, -32, 320, -26, 312, 313, -13, -19,  -4,
  43,  45,  42,  47,  37,  94, 323, 324, 325, 326,
 327, 328, 322, 321, -29,  -1,  -1,  -1,  40,  40,
  40,  40,  40,  40,  40,  40,  40,  40,  -1, -49,
 308,  -1,  -1,  -9,  -1,  -9,  -1,  -1,  -1, -53,
  -9, 308,  -2,  -1, -21, -54, -55, -28, 303, 304,
 291, -12,  -9, 277,  -7, -22, -12, 274,  -1, -12,
 -19, -20, -22, 277, 274,  61, 281, 322, 321, 327,
 328, -57, 318, -22,  -1, -23,  -6,  43,  45,  42,
  47, 319,  -1,  -1, -19,  -1,  -1,  -1,  -1,  -1,
  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  41,
  41,  -1,  -1,  -1,  -1,  -1,  -1,  41,  -1,  -1,
  -1, -50, -51,  -1,  -1, -50, -46, -47, 305, -55,
 -12,  -9, 274, -12,  -9, 274, 303, 304, 291,  -1,
  40, -12, 277, 275, -12, 277, 314, -22, -20, -12,
  -1,  -1, 282, -29, -29, 319, 319,  -1,  41,  44,
  41,  41,  41,  41,  44,  41,  44,  44,  41, -16,
 -22, 275, -47,  -1,  -9,  -1,  -9, 291, 291, -16,
  -1, -12, -12, 275, -12,  -1, -20, 275, 275, -24,
 -25,  -1,  -1,  -1,  -1, -51,  -9, 275,  -1, 275,
  -1, 304, 303,  -1, -16, -20, -12,  -1,  -1,  41,
  44,  41,  41,  41,  -1,  -1, 275,  -1, 275,  -1,
 276, 283, 276, 283, -24,  -1, 276,  -7,  -1,  -1,
  41,  -6,  -6,  -6,  -1,  -1,  -1, 283, 283,  -7 };
short yydef[]={

  -2,  -2,   1,   3,  -2,   0,   8,   0,   7,  45,
  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,
  22,  23,  24,  25,  26,   0,   0,   0,  52, 162,
   0,   0,   0,   0, 162, 162,   0,   0,   0,  30,
   0, 103, 137, 138,  33,   0,   0, 196, 197, 112,
   0,   0,   0,  -2,   9,  11,  31,   0, 160,  27,
  28, 163, 164,   0,  -2,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  60,  61,
  63,  66,  67, 162,  69,  71,  72,  50, 162,   0,
   0,   0,  86,  87,  89,  90,  91,  92, 162,  94,
   0,  96,  97, 199,  54,  55,  56,  57,   0,  51,
  50, 116, 161, 104, 162,   0,  85, 162,   0,  58,
   0, 162,   0,   0,   0,   0, 152, 153,   0, 140,
 141, 143,   0,   0,   0,  34,  35, 105, 110, 113,
  83,   0,  -2,  10,  44,   0,   0,   0,  49,  32,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 172, 173,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0, 194,  62,
  70,  64,  65,   0,  42,   0,  40,  41,  43,  88,
   0,  95,  53, 198,  39, 115, 117, 119, 162, 162,
   0, 131,   0, 162,   0,  84,   0, 162,   0, 102,
  -2,   0,  59, 162,   0,   0, 151,   0,   0,   0,
   0, 142, 144, 145, 195, 111,   0,  79,  80,  81,
  82,   0,  46,  47,  48, 167, 168, 169, 170, 171,
 177,  -2,  -2,  -2,  -2,  -2,  -2, 192, 193, 165,
 174,   0,   0,   0,   0,   0,   0, 182,   0,   0,
   0,  68,  73,  75,   0,  93,  36,  37,   0, 118,
 120,   0, 162, 121,   0, 162, 126, 127, 130,   0,
   0, 132, 162, 162,   0, 162,   0, 135, 136,  59,
   0,   0, 150, 154, 155, 156, 157, 114, 112,   0,
 175, 176, 178, 179,   0, 181,   0,   0, 185,   0,
  76, 162,  38,   0,   0,   0,   0,   0,   0,   0,
   0, 133,  59, 162, 100, 101, 139,   0,   0, 106,
   0, 108,   0,   0,   0,  74,   0,   0,   0,   0,
   0, 128, 129, 158,   0,  98,  99,   0,   0, 112,
   0, 180, 183, 184,  85, 122,   0, 123,   0,   0,
  83, 147,  83, 149, 107, 109,  83,  78, 124, 125,
 159,   0,   0,   0,   0,   0,  85, 146, 148,  77 };
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
# line 54 "grap.y"
{ if (codegen && !synerr) graph((char *) 0); } break;
case 2:
# line 55 "grap.y"
{ codegen = 0; } break;
case 3:
# line 56 "grap.y"
{ codegen = 0; ERROR "syntax error" WARNING; } break;
case 7:
# line 65 "grap.y"
{ graph(yypvt[-0].p); endstat(); } break;
case 9:
# line 70 "grap.y"
{ endstat(); } break;
case 10:
# line 71 "grap.y"
{ endstat(); } break;
case 11:
# line 75 "grap.y"
{ codegen = 1; } break;
case 12:
# line 76 "grap.y"
{ codegen = 1; } break;
case 13:
# line 77 "grap.y"
{ codegen = 1; } break;
case 14:
# line 78 "grap.y"
{ codegen = 1; } break;
case 16:
# line 80 "grap.y"
{ codegen = 1; } break;
case 17:
# line 81 "grap.y"
{ codegen = 1; } break;
case 18:
# line 82 "grap.y"
{ codegen = 1; } break;
case 20:
# line 84 "grap.y"
{ codegen = 1; } break;
case 21:
# line 85 "grap.y"
{ codegen = 1; pic(yypvt[-0].p); } break;
case 25:
# line 89 "grap.y"
{ codegen = 1; numlist(); } break;
case 27:
# line 91 "grap.y"
{ fprintf(stderr, "\t%g\n", yypvt[-0].f); } break;
case 28:
# line 92 "grap.y"
{ fprintf(stderr, "\t%s\n", yypvt[-0].ap->sval); freeattr(yypvt[-0].ap); } break;
case 30:
# line 97 "grap.y"
{ savenum(0, yypvt[-0].f); yyval.i = 1; } break;
case 31:
# line 98 "grap.y"
{ savenum(yypvt[-1].i, yypvt[-0].f); yyval.i = yypvt[-1].i+1; } break;
case 32:
# line 99 "grap.y"
{ savenum(yypvt[-2].i, yypvt[-0].f); yyval.i = yypvt[-2].i+1; } break;
case 34:
# line 103 "grap.y"
{ yyval.f = -yypvt[-0].f; } break;
case 35:
# line 104 "grap.y"
{ yyval.f = yypvt[-0].f; } break;
case 36:
# line 108 "grap.y"
{ label(yypvt[-2].i, yypvt[-1].ap); } break;
case 40:
# line 116 "grap.y"
{ labelmove(yypvt[-1].i, yypvt[-0].f); } break;
case 41:
# line 117 "grap.y"
{ labelmove(yypvt[-1].i, yypvt[-0].f); } break;
case 42:
# line 118 "grap.y"
{ labelmove(yypvt[-1].i, yypvt[-0].f); /* LEFT or RIGHT only */ } break;
case 43:
# line 119 "grap.y"
{ labelwid(yypvt[-0].f); } break;
case 45:
# line 124 "grap.y"
{ yyval.i = 0; } break;
case 46:
# line 127 "grap.y"
{ frameht(yypvt[-0].f); } break;
case 47:
# line 128 "grap.y"
{ framewid(yypvt[-0].f); } break;
case 48:
# line 129 "grap.y"
{ frameside(yypvt[-1].i, yypvt[-0].ap); } break;
case 49:
# line 130 "grap.y"
{ frameside(0, yypvt[-0].ap); } break;
case 52:
# line 137 "grap.y"
{ yyval.i = 0; } break;
case 53:
# line 141 "grap.y"
{ yyval.ap = makeattr(yypvt[-1].i, yypvt[-0].f, (char *) 0, 0, 0); } break;
case 59:
# line 148 "grap.y"
{ yyval.ap = makeattr(0, 0.0, (char *) 0, 0, 0); } break;
case 60:
# line 152 "grap.y"
{ ticks(); } break;
case 63:
# line 159 "grap.y"
{ tickside(yypvt[-0].i); } break;
case 64:
# line 160 "grap.y"
{ tickdir(IN, yypvt[-0].f, 1); } break;
case 65:
# line 161 "grap.y"
{ tickdir(OUT, yypvt[-0].f, 1); } break;
case 66:
# line 162 "grap.y"
{ tickdir(IN, 0.0, 0); } break;
case 67:
# line 163 "grap.y"
{ tickdir(OUT, 0.0, 0); } break;
case 68:
# line 164 "grap.y"
{ setlist(); ticklist(yypvt[-1].op, AT); } break;
case 69:
# line 165 "grap.y"
{ setlist(); ticklist(yypvt[-0].op, AT); } break;
case 70:
# line 166 "grap.y"
{ tickoff(yypvt[-1].i); } break;
case 71:
# line 167 "grap.y"
{ tickoff(LEFT|RIGHT|TOP|BOT); } break;
case 75:
# line 175 "grap.y"
{ savetick(yypvt[-0].f, (char *) 0); } break;
case 76:
# line 176 "grap.y"
{ savetick(yypvt[-1].f, yypvt[-0].ap->sval); } break;
case 77:
# line 180 "grap.y"
{ iterator(yypvt[-7].f, yypvt[-4].f, yypvt[-2].i, yypvt[-1].f, yypvt[-0].p); yyval.op = yypvt[-8].op; } break;
case 78:
# line 182 "grap.y"
{ iterator(yypvt[-4].f, yypvt[-1].f, '+', 1.0, yypvt[-0].p); yyval.op = yypvt[-5].op; } break;
case 79:
# line 185 "grap.y"
{ yyval.i = '+'; } break;
case 80:
# line 186 "grap.y"
{ yyval.i = '-'; } break;
case 81:
# line 187 "grap.y"
{ yyval.i = '*'; } break;
case 82:
# line 188 "grap.y"
{ yyval.i = '/'; } break;
case 83:
# line 189 "grap.y"
{ yyval.i = ' '; } break;
case 84:
# line 192 "grap.y"
{ yyval.p = yypvt[-0].ap->sval; } break;
case 85:
# line 193 "grap.y"
{ yyval.p = (char *) 0; } break;
case 86:
# line 197 "grap.y"
{ ticks(); } break;
case 89:
# line 204 "grap.y"
{ tickside(yypvt[-0].i); } break;
case 90:
# line 205 "grap.y"
{ tickside(BOT); } break;
case 91:
# line 206 "grap.y"
{ tickside(LEFT); } break;
case 92:
# line 207 "grap.y"
{ griddesc(yypvt[-0].ap); } break;
case 93:
# line 208 "grap.y"
{ setlist(); gridlist(yypvt[-1].op); } break;
case 94:
# line 209 "grap.y"
{ setlist(); gridlist(yypvt[-0].op); } break;
case 95:
# line 210 "grap.y"
{ gridtickoff(); } break;
case 96:
# line 211 "grap.y"
{ gridtickoff(); } break;
case 98:
# line 216 "grap.y"
{ line(yypvt[-5].i, yypvt[-3].pt, yypvt[-1].pt, yypvt[-0].ap); } break;
case 99:
# line 217 "grap.y"
{ line(yypvt[-5].i, yypvt[-2].pt, yypvt[-0].pt, yypvt[-4].ap); } break;
case 100:
# line 220 "grap.y"
{ circle(yypvt[-2].f, yypvt[-0].pt); } break;
case 101:
# line 221 "grap.y"
{ circle(yypvt[-0].f, yypvt[-2].pt); } break;
case 102:
# line 222 "grap.y"
{ circle(0.0, yypvt[-0].pt); } break;
case 104:
# line 227 "grap.y"
{ yyval.ap = addattr(yypvt[-1].ap, yypvt[-0].ap); } break;
case 105:
# line 230 "grap.y"
{ yyval.ap = makesattr(yypvt[-1].p); } break;
case 106:
# line 232 "grap.y"
{ yyval.ap = makesattr(sprntf(yypvt[-2].p, (Attr*) 0)); } break;
case 107:
# line 234 "grap.y"
{ yyval.ap = makesattr(sprntf(yypvt[-4].p, yypvt[-2].ap)); } break;
case 108:
# line 237 "grap.y"
{ yyval.ap = makefattr(NUMBER, yypvt[-0].f); } break;
case 109:
# line 238 "grap.y"
{ yyval.ap = addattr(yypvt[-2].ap, makefattr(NUMBER, yypvt[-0].f)); } break;
case 112:
# line 243 "grap.y"
{ yyval.ap = (Attr *) 0; } break;
case 113:
# line 246 "grap.y"
{ setjust(yypvt[-0].i); } break;
case 114:
# line 247 "grap.y"
{ setsize(yypvt[-1].i, yypvt[-0].f); } break;
case 115:
# line 251 "grap.y"
{ coord(yypvt[-1].op); } break;
case 116:
# line 252 "grap.y"
{ resetcoord(yypvt[-0].op); } break;
case 119:
# line 259 "grap.y"
{ coordlog(yypvt[-0].i); } break;
case 120:
# line 260 "grap.y"
{ coord_x(yypvt[-0].pt); } break;
case 121:
# line 261 "grap.y"
{ coord_y(yypvt[-0].pt); } break;
case 122:
# line 262 "grap.y"
{ coord_x(makepoint(yypvt[-3].op, yypvt[-2].f, yypvt[-0].f)); } break;
case 123:
# line 263 "grap.y"
{ coord_y(makepoint(yypvt[-3].op, yypvt[-2].f, yypvt[-0].f)); } break;
case 124:
# line 264 "grap.y"
{ coord_x(makepoint(yypvt[-3].op, yypvt[-2].f, yypvt[-0].f)); } break;
case 125:
# line 265 "grap.y"
{ coord_y(makepoint(yypvt[-3].op, yypvt[-2].f, yypvt[-0].f)); } break;
case 126:
# line 268 "grap.y"
{ yyval.i = XFLAG; } break;
case 127:
# line 269 "grap.y"
{ yyval.i = YFLAG; } break;
case 128:
# line 270 "grap.y"
{ yyval.i = XFLAG|YFLAG; } break;
case 129:
# line 271 "grap.y"
{ yyval.i = XFLAG|YFLAG; } break;
case 130:
# line 272 "grap.y"
{ yyval.i = XFLAG|YFLAG; } break;
case 131:
# line 276 "grap.y"
{ plot(yypvt[-2].ap, yypvt[-0].pt); } break;
case 132:
# line 277 "grap.y"
{ plot(yypvt[-2].ap, yypvt[-0].pt); } break;
case 133:
# line 278 "grap.y"
{ plotnum(yypvt[-3].f, yypvt[-2].p, yypvt[-0].pt); } break;
case 134:
# line 282 "grap.y"
{ drawdesc(yypvt[-2].i, yypvt[-1].op, yypvt[-0].ap, (char *) 0); } break;
case 135:
# line 283 "grap.y"
{ drawdesc(yypvt[-3].i, yypvt[-2].op, yypvt[-1].ap, yypvt[-0].ap->sval); } break;
case 136:
# line 284 "grap.y"
{ drawdesc(yypvt[-3].i, yypvt[-2].op, yypvt[-0].ap, yypvt[-1].ap->sval); } break;
case 139:
# line 292 "grap.y"
{ next(yypvt[-3].op, yypvt[-1].pt, yypvt[-0].ap); } break;
case 140:
# line 295 "grap.y"
{ copy(); } break;
case 143:
# line 302 "grap.y"
{ copyfile(yypvt[-0].ap->sval); } break;
case 144:
# line 303 "grap.y"
{ copydef(yypvt[-0].op); } break;
case 145:
# line 304 "grap.y"
{ copyuntil(yypvt[-0].ap->sval); } break;
case 146:
# line 309 "grap.y"
{ forloop(yypvt[-8].op, yypvt[-6].f, yypvt[-4].f, yypvt[-2].i, yypvt[-1].f, yypvt[-0].p); } break;
case 147:
# line 311 "grap.y"
{ forloop(yypvt[-5].op, yypvt[-3].f, yypvt[-1].f, '+', 1.0, yypvt[-0].p); } break;
case 148:
# line 313 "grap.y"
{ forloop(yypvt[-8].op, yypvt[-6].f, yypvt[-4].f, yypvt[-2].i, yypvt[-1].f, yypvt[-0].p); } break;
case 149:
# line 315 "grap.y"
{ forloop(yypvt[-5].op, yypvt[-3].f, yypvt[-1].f, '+', 1.0, yypvt[-0].p); } break;
case 150:
# line 319 "grap.y"
{ yyval.p = ifstat(yypvt[-2].f, yypvt[-1].p, yypvt[-0].p); } break;
case 151:
# line 320 "grap.y"
{ yyval.p = ifstat(yypvt[-1].f, yypvt[-0].p, (char *) 0); } break;
case 154:
# line 325 "grap.y"
{ yyval.f = yypvt[-2].f && yypvt[-0].f; } break;
case 155:
# line 326 "grap.y"
{ yyval.f = yypvt[-2].f || yypvt[-0].f; } break;
case 156:
# line 329 "grap.y"
{ yyval.f = strcmp(yypvt[-2].p,yypvt[-0].p) == 0; free(yypvt[-2].p); free(yypvt[-0].p); } break;
case 157:
# line 330 "grap.y"
{ yyval.f = strcmp(yypvt[-2].p,yypvt[-0].p) != 0; free(yypvt[-2].p); free(yypvt[-0].p); } break;
case 158:
# line 334 "grap.y"
{ yyval.pt = makepoint(yypvt[-3].op, yypvt[-2].f, yypvt[-0].f); } break;
case 159:
# line 335 "grap.y"
{ yyval.pt = makepoint(yypvt[-5].op, yypvt[-3].f, yypvt[-1].f); } break;
case 160:
# line 338 "grap.y"
{ yyval.i = ','; } break;
case 161:
# line 342 "grap.y"
{ yyval.op = yypvt[-0].op; } break;
case 162:
# line 343 "grap.y"
{ yyval.op = lookup(curr_coord, 1); } break;
case 165:
# line 349 "grap.y"
{ yyval.f = yypvt[-1].f; } break;
case 166:
# line 350 "grap.y"
{ yyval.f = getvar(yypvt[-0].op); } break;
case 167:
# line 351 "grap.y"
{ yyval.f = yypvt[-2].f + yypvt[-0].f; } break;
case 168:
# line 352 "grap.y"
{ yyval.f = yypvt[-2].f - yypvt[-0].f; } break;
case 169:
# line 353 "grap.y"
{ yyval.f = yypvt[-2].f * yypvt[-0].f; } break;
case 170:
# line 354 "grap.y"
{ if (yypvt[-0].f == 0.0) {
					ERROR "division by 0" WARNING; yypvt[-0].f = 1; }
				  yyval.f = yypvt[-2].f / yypvt[-0].f; } break;
case 171:
# line 357 "grap.y"
{ if ((long)yypvt[-0].f == 0) {
					ERROR "mod division by 0" WARNING; yypvt[-0].f = 1; }
				  yyval.f = (long)yypvt[-2].f % (long)yypvt[-0].f; } break;
case 172:
# line 360 "grap.y"
{ yyval.f = -yypvt[-0].f; } break;
case 173:
# line 361 "grap.y"
{ yyval.f = yypvt[-0].f; } break;
case 174:
# line 362 "grap.y"
{ yyval.f = yypvt[-1].f; } break;
case 175:
# line 363 "grap.y"
{ yyval.f = Log10(yypvt[-1].f); } break;
case 176:
# line 364 "grap.y"
{ yyval.f = Exp(yypvt[-1].f * log(10.0)); } break;
case 177:
# line 365 "grap.y"
{ yyval.f = pow(yypvt[-2].f, yypvt[-0].f); } break;
case 178:
# line 366 "grap.y"
{ yyval.f = sin(yypvt[-1].f); } break;
case 179:
# line 367 "grap.y"
{ yyval.f = cos(yypvt[-1].f); } break;
case 180:
# line 368 "grap.y"
{ yyval.f = atan2(yypvt[-3].f, yypvt[-1].f); } break;
case 181:
# line 369 "grap.y"
{ yyval.f = Sqrt(yypvt[-1].f); } break;
case 182:
# line 370 "grap.y"
{ yyval.f = (double)rand() / (double)RAND_MAX; } break;
case 183:
# line 371 "grap.y"
{ yyval.f = yypvt[-3].f >= yypvt[-1].f ? yypvt[-3].f : yypvt[-1].f; } break;
case 184:
# line 372 "grap.y"
{ yyval.f = yypvt[-3].f <= yypvt[-1].f ? yypvt[-3].f : yypvt[-1].f; } break;
case 185:
# line 373 "grap.y"
{ yyval.f = (long) yypvt[-1].f; } break;
case 186:
# line 374 "grap.y"
{ yyval.f = yypvt[-2].f > yypvt[-0].f; } break;
case 187:
# line 375 "grap.y"
{ yyval.f = yypvt[-2].f < yypvt[-0].f; } break;
case 188:
# line 376 "grap.y"
{ yyval.f = yypvt[-2].f <= yypvt[-0].f; } break;
case 189:
# line 377 "grap.y"
{ yyval.f = yypvt[-2].f >= yypvt[-0].f; } break;
case 190:
# line 378 "grap.y"
{ yyval.f = yypvt[-2].f == yypvt[-0].f; } break;
case 191:
# line 379 "grap.y"
{ yyval.f = yypvt[-2].f != yypvt[-0].f; } break;
case 192:
# line 380 "grap.y"
{ yyval.f = yypvt[-2].f && yypvt[-0].f; } break;
case 193:
# line 381 "grap.y"
{ yyval.f = yypvt[-2].f || yypvt[-0].f; } break;
case 194:
# line 382 "grap.y"
{ yyval.f = !(yypvt[-0].f); } break;
case 195:
# line 385 "grap.y"
{ yyval.f = setvar(yypvt[-2].op, yypvt[-0].f); } break;
case 199:
# line 395 "grap.y"
{ yyval.f = 0.0; } break;
	}
	goto yystack;  /* stack new state and value */
}
