text
L%35:
stabs	"printf.c",0x15,0,L%35
stabs	"printf",0x12,12,printf
global	printf
printf:
link	%fp,&F%1
movm.l	&M%1,S%1(%fp)
#  line 13, file "printf.c"
pea.l	12(%fp)
mov.l	8(%fp),-(%sp)
mov.l	&_iob+12,-(%sp)
jsr	_doprnt
lea	12(%sp),%sp
L%36:
movm.l	S%1(%fp),&M%1
unlk	%fp
rts
stabs	"fmt",0x6,042,8
stabs	"x1",0x6,016,12
stabs	"printf",0x19,14,L%36
set	S%1,0
set	T%1,0
set	F%1,-4
set	M%1,0x0000
stabs	"fprintf",0x12,20,fprintf
global	fprintf
fprintf:
link	%fp,&F%2
movm.l	&M%2,S%2(%fp)
#  line 21, file "printf.c"
pea.l	16(%fp)
mov.l	12(%fp),-(%sp)
mov.l	8(%fp),-(%sp)
jsr	_doprnt
lea	12(%sp),%sp
L%38:
movm.l	S%2(%fp),&M%2
unlk	%fp
rts
stabs	"f",0x6,050,8
stabs	"_iobuf",0x21,0,0
stabs	"fmt",0x6,042,12
stabs	"x1",0x6,016,16
stabs	"fprintf",0x19,22,L%38
set	S%2,0
set	T%2,0
set	F%2,-4
set	M%2,0x0000
stabs	"sprintf",0x12,28,sprintf
global	sprintf
sprintf:
link	%fp,&F%3
movm.l	&M%3,S%3(%fp)
#  line 31, file "printf.c"
lea.l	-12+S%3(%fp),%a2
#  line 32, file "printf.c"
mov.l	8(%fp),%a0
mov.l	%a0,6(%a2)
mov.l	%a0,2(%a2)
#  line 33, file "printf.c"
mov.l	&0,%d0
mov.w	%d0,(%a2)
mov.b	%d0,10(%a2)
#  line 34, file "printf.c"
pea.l	16(%fp)
mov.l	12(%fp),-(%sp)
mov.l	%a2,-(%sp)
jsr	_doprnt
lea	12(%sp),%sp
#  line 35, file "printf.c"
mov.l	%a2,(%sp)
clr.w	-(%sp)
jsr	putc
add.l	&2,%sp
#  line 36, file "printf.c"
mov.l	2(%a2),%a0
br	L%40
stabs	"f",0x4,050,10
stabs	"_iobuf",0x21,0,0
stabs	"fake",0x5,010,12
stabs	"_iobuf",0x21,0,0
L%40:
movm.l	S%3(%fp),&M%3
unlk	%fp
rts
stabs	"buf",0x6,042,8
stabs	"fmt",0x6,042,12
stabs	"x1",0x6,016,16
stabs	"sprintf",0x19,37,L%40
set	S%3,-4
set	T%3,-16
set	F%3,-20
set	M%3,0x0400
stabs	"_doprnt",0x12,44,_doprnt
global	_doprnt
_doprnt:
link	%fp,&F%4
movm.l	&M%4,S%4(%fp)
#  line 44, file "printf.c"
mov.l	8(%fp),%a2
#  line 44, file "printf.c"
mov.l	12(%fp),%a3
#  line 50, file "printf.c"
mov.l	16(%fp),%a4
L%45:
br.b	L%46
L%20001:#  line 53, file "printf.c"
tst.w	%d2
bne.b	L%48
#  line 54, file "printf.c"
mov.l	2(%a2),%a0
br	L%42
L%48:
#  line 55, file "printf.c"
mov.l	%a2,(%sp)
mov.w	%d2,-(%sp)
jsr	putc
add.l	&2,%sp
L%46:
#  line 52, file "printf.c"
mov.b	(%a3)+,%d0
ext.w	%d0
mov.w	%d0,%d2
cmp.w	%d2,&37
bne.b	L%20001

#  line 57, file "printf.c"
mov.b	(%a3)+,%d0
ext.w	%d0
mov.w	%d0,%d2
#  line 58, file "printf.c"
cmp.w	%d2,&111
beq.b	L%50
cmp.w	%d2,&117
beq.b	L%50
cmp.w	%d2,&120
bne	L%49
L%50:
#  line 59, file "printf.c"
mov.l	%a2,(%sp)
cmp.w	%d2,&111
bne.b	L%52
mov.l	&8,%d0
br.b	L%53
L%52:
cmp.w	%d2,&120
bne.b	L%54
mov.l	&16,%d0
br.b	L%55
L%54:
mov.l	&10,%d0
L%55:
L%53:
mov.w	%d0,-(%sp)
clr.l	%d0
mov.w	(%a4),%d0
mov.l	%d0,-(%sp)
jsr	sprintn
add.l	&6,%sp
br	L%56
L%49:
#  line 60, file "printf.c"
cmp.w	%d2,&100
bne	L%57
#  line 61, file "printf.c"
mov.w	(%a4),%d0
ext.l	%d0
mov.l	%d0,%d3
#  line 62, file "printf.c"
tst.l	%d3
bge.b	L%58
#  line 63, file "printf.c"
mov.l	%a2,(%sp)
mov.w	&45,-(%sp)
jsr	putc
add.l	&2,%sp
#  line 64, file "printf.c"
mov.l	%d3,%d0
neg.l	%d0
mov.l	%d0,%d3
L%58:
#  line 66, file "printf.c"
mov.l	%a2,(%sp)
mov.w	&10,-(%sp)
mov.l	%d3,-(%sp)
jsr	sprintn
add.l	&6,%sp
br	L%59
L%57:
#  line 67, file "printf.c"
cmp.w	%d2,&115
bne	L%60
#  line 68, file "printf.c"
mov.l	(%a4),-4+S%4(%fp)
br.b	L%61
L%20003:#  line 70, file "printf.c"
mov.l	%a2,(%sp)
mov.w	%d2,-(%sp)
jsr	putc
add.l	&2,%sp
L%61:
#  line 69, file "printf.c"
mov.l	-4+S%4(%fp),%a0
add.l	&1,-4+S%4(%fp)
mov.b	(%a0),%d0
ext.w	%d0
mov.w	%d0,%d2
bne.b	L%20003

#  line 71, file "printf.c"
add.l	&2,%a4
br	L%63
L%60:
#  line 72, file "printf.c"
cmp.w	%d2,&68
bne.b	L%64
#  line 73, file "printf.c"
mov.l	%a2,(%sp)
mov.w	&10,-(%sp)
mov.l	(%a4),-(%sp)
jsr	sprintn
add.l	&6,%sp
#  line 74, file "printf.c"
add.l	&2,%a4
br	L%65
L%64:
#  line 75, file "printf.c"
cmp.w	%d2,&88
bne.b	L%66
#  line 76, file "printf.c"
mov.l	%a2,(%sp)
mov.w	&16,-(%sp)
mov.l	(%a4),-(%sp)
jsr	sprintn
add.l	&6,%sp
#  line 77, file "printf.c"
add.l	&2,%a4
br.b	L%67
L%66:
#  line 78, file "printf.c"
cmp.w	%d2,&99
bne.b	L%68
#  line 79, file "printf.c"
mov.l	%a2,(%sp)
mov.w	(%a4),-(%sp)
br.b	L%20005
L%68:
#  line 81, file "printf.c"
mov.l	%a2,(%sp)
mov.w	%d2,-(%sp)
L%20005:jsr	putc
add.l	&2,%sp

L%67:
L%65:
L%63:
L%59:
L%56:
#  line 82, file "printf.c"
add.l	&2,%a4
L%43:
br	L%45
L%44:
stabs	"c",0x4,04,2
stabs	"f",0x4,050,10
stabs	"_iobuf",0x21,0,0
stabs	"l",0x4,05,3
stabs	"s",0x5,042,4
stabs	"adx",0x4,056,12
stabs	"fmt",0x4,042,11
L%42:
movm.l	S%4(%fp),&M%4
unlk	%fp
rts
stabs	"f",0x6,050,8
stabs	"_iobuf",0x21,0,0
stabs	"fmt",0x6,042,12
stabs	"x1",0x6,056,16
stabs	"_doprnt",0x19,84,L%42
set	S%4,-20
set	T%4,-24
set	F%4,-28
set	M%4,0x1c0c
stabs	"sprintn",0x12,92,sprintn
global	sprintn
data	2
L%72:
byte	'0,'1,'2,'3,'4,'5,'6,'7
byte	'8,'9,'A,'B,'C,'D,'E,'F
byte	0x00
text
sprintn:
link	%fp,&F%5
movm.l	&M%5,S%5(%fp)
#  line 95, file "printf.c"
mov.w	12(%fp),%d0
ext.l	%d0
mov.l	%d0,(%sp)
mov.l	8(%fp),%d0
jsr	uldiv%%
mov.l	%d0,%d2
beq.b	L%71
#  line 96, file "printf.c"
mov.l	14(%fp),(%sp)
mov.w	12(%fp),-(%sp)
mov.l	%d2,-(%sp)
jsr	sprintn
add.l	&6,%sp
L%71:
#  line 97, file "printf.c"
mov.l	14(%fp),(%sp)
mov.w	12(%fp),%d0
ext.l	%d0
mov.l	%d0,-(%sp)
mov.l	8(%fp),%d0
jsr	ulrem%%
add.l	&4,%sp
mov.l	&L%72,%a1
mov.b	0(%a1,%d0.w),%d0
ext.w	%d0
mov.w	%d0,-(%sp)
jsr	putc
add.l	&2,%sp
stabs	"a",0x4,05,2
L%70:
movm.l	S%5(%fp),&M%5
unlk	%fp
rts
stabs	"n",0x6,017,8
stabs	"b",0x6,04,12
stabs	"f",0x6,050,14
stabs	"_iobuf",0x21,0,0
stabs	"sprintn",0x19,98,L%70
set	S%5,-4
set	T%5,-4
set	F%5,-8
set	M%5,0x0004
data	1
