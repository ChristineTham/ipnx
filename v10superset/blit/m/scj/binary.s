	data	1
	comm	Jdisplay,4
	comm	Drect,8
	comm	_string,176
	comm	screenre,8
	comm	diagrect,8
	comm	diagclr,2
	comm	newlnsz,2
	comm	current,4
	comm	loadpt,4
	comm	ntoload,2
	even
	global	donetest
donetest:
	text
L%68:
	stabs	"/usr/bli",0x15,0,L%68
	stabs	"t/src/ji",0x15,0,L%68
	stabs	"m/main.c",0x15,0,L%68
	data	1
	long	usualtes
	comm	snarfhug,2
	comm	selecthu,2
	comm	iodone,2
	comm	diagdone,2
	comm	scrollli,2
	comm	filedone,2
	comm	reqlimit,2
	comm	nrequest,2
	comm	reqposn,2
	text
	stabs	"main",0x12,19,main
	global	main
main:
	link	%fp,&F%1
	movm.l	&M%1,S%1(%fp)
	mov.w	&15,(%sp)
	mov.l	434,%a0
	jsr	(%a0)
	mov.l	266,%a0
	mov.b	2(%a0),%d0
	ext.w	%d0
	mov.w	%d0,newlnsz
	jsr	init
	mov.l	&_string+160,(%sp)
	jsr	zerostri
	mov.l	&diagdone,(%sp)
	jsr	waitunix
	mov.l	&0,%d2
L%83:
	mov.l	262,%a0
	mov.w	8(%a0),%d0
	and.w	&2048,%d0
	beq	L%84
	mov.w	&1,(%sp)
	mov.l	&Drect,%a0
	mov.l	4(%a0),-(%sp)
	mov.l	0(%a0),-(%sp)
	mov.l	478,%a0
	jsr	(%a0)
	add.l	&8,%sp
	jsr	closeall
	jsr	init
	mov.l	262,%a0
	and.w	&-2049,8(%a0)
L%84:
	btst	&3,%d2
	beq	L%87
	jsr	rcv
	tst.w	%d0
	beq	L%87
	mov.l	current,(%sp)
	jsr	curse
	jsr	message
	mov.l	current,(%sp)
	jsr	curse
L%87:
	btst	&2,%d2
	beq	L%90
	mov.w	mouse+8,%d0
	and.w	&7,%d0
	beq	L%90
	mov.l	current,(%sp)
	jsr	curse
	mov.w	mouse+8,(%sp)
	mov.l	mouse,-(%sp)
	jsr	buttonhi
	add.l	&4,%sp
	mov.l	current,(%sp)
	jsr	curse
L%90:
	btst	&0,%d2
	beq	L%92
	tst.l	current
	beq	L%92
	mov.l	current,(%sp)
	jsr	type
L%92:
L%81:
	mov.w	&13,(%sp)
	mov.l	474,%a0
	jsr	(%a0)
	mov.w	%d0,%d2
	br	L%83
L%82:
	stabs	"got",0x4,04,2
L%77:
	movm.l	S%1(%fp),&M%1
	unlk	%fp
	rts
	stabs	"main",0x19,47,L%77
	set	S%1,-4
	set	T%1,-4
	set	F%1,-8
	set	M%1,0x0004
	data	1
	text
	stabs	"closeall",0x12,48,closeall
	global	closeall
closeall:
	link	%fp,&F%2
	movm.l	&M%2,S%2(%fp)
	mov.l	&frame,%a2
L%97:
	cmp.l	%a2,&frame+2280
	bhs	L%96
	tst.b	34(%a2)
	beq	L%98
	mov.w	&32,(%sp)
	mov.w	&1,-(%sp)
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	setchar
	add.l	&4,%sp
L%98:
	mov.l	%a2,(%sp)
	jsr	closefra
	mov.l	%a2,(%sp)
	jsr	delobs
L%95:
	add.l	&114,%a2
	br	L%97
L%96:
	sub.l	%a0,%a0
	mov.l	%a0,current
	stabs	"t",0x4,050,10
	stabs	"Textfram",0x21,0,0
L%94:
	movm.l	S%2(%fp),&M%2
	unlk	%fp
	rts
	stabs	"closeall",0x19,57,L%94
	set	S%2,-4
	set	T%2,-4
	set	F%2,-8
	set	M%2,0x0400
	data	1
	text
	stabs	"init",0x12,58,init
	global	init
init:
	link	%fp,&F%3
	movm.l	&M%3,S%3(%fp)
	mov.l	&Drect,%a0
	mov.l	&diagrect,%a1
	mov.l	(%a0)+,(%a1)+
	mov.l	0(%a0),0(%a1)
	mov.w	diagrect+6,%d0
	mov.l	266,%a1
	mov.b	2(%a1),%d1
	ext.w	%d1
	add.w	&4,%d1
	sub.w	%d1,%d0
	sub.w	&1,%d0
	mov.w	%d0,diagrect+2
	mov.w	&2,diagclr
	add.w	&1,diagrect+2
	mov.l	&diagrect,%a0
	mov.l	4(%a0),(%sp)
	mov.l	0(%a0),-(%sp)
	jsr	newframe
	add.l	&4,%sp
	mov.l	&frame,(%sp)
	jsr	initfram
	mov.l	&frame,(%sp)
	jsr	curse
	mov.l	&Drect,%a0
	mov.l	&screenre,%a1
	mov.l	(%a0)+,(%a1)+
	mov.l	0(%a0),0(%a1)
	mov.w	diagrect+2,screenre+6
	sub.l	%a0,%a0
	mov.l	%a0,current
	sub.l	%a0,%a0
	mov.l	%a0,workfram
L%102:
	movm.l	S%3(%fp),&M%3
	unlk	%fp
	rts
	stabs	"init",0x19,70,L%102
	set	S%3,0
	set	T%3,0
	set	F%3,-4
	set	M%3,0x0000
	data	1
	text
	stabs	"seek",0x12,75,seek
	global	seek
seek:
	link	%fp,&F%4
	movm.l	&M%4,S%4(%fp)
	mov.l	8(%fp),%a2
	mov.w	14(%fp),%d3
	cmp.l	%a2,&frame
	bne	L%106
	br	L%105
L%106:
	mov.l	%a2,(%sp)
	jsr	initfram
	mov.l	%a2,(%sp)
	jsr	ontop
	lea.l	-8+S%4(%fp),%a0
	mov.l	%a2,%a1
	add.l	&8,%a1
	mov.l	(%a1)+,(%a0)+
	mov.l	0(%a1),0(%a0)
	mov.w	%d3,%d0
	sub.w	-6+S%4(%fp),%d0
	ext.l	%d0
	lsl.l	&10,%d0
	mov.w	-2+S%4(%fp),%d1
	sub.w	-6+S%4(%fp),%d1
	divs.w	%d1,%d0
	mov.w	%d0,%d2
	tst.w	%d2
	bge	L%108
	mov.l	&0,%d2
L%108:
	cmp.w	%d2,&1024
	ble	L%109
	mov.w	&1024,%d2
L%109:
	sub.l	%a0,%a0
	mov.l	%a0,(%sp)
	mov.w	&0,-(%sp)
	mov.w	%d2,-(%sp)
	mov.w	&10,-(%sp)
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	send
	add.l	&8,%sp
	mov.w	&32767,(%sp)
	mov.w	&0,-(%sp)
	mov.l	%a2,-(%sp)
	jsr	loadfile
	add.l	&6,%sp
	mov.w	&0,(%sp)
	mov.l	%a2,-(%sp)
	jsr	setsel
	add.l	&4,%sp
	stabs	"n",0x4,04,2
	stabs	"r",0x5,010,8
	stabs	"Rectangl",0x21,0,0
	stabs	"t",0x4,050,10
	stabs	"Textfram",0x21,0,0
	stabs	"y",0x4,04,3
L%105:
	movm.l	S%4(%fp),&M%4
	unlk	%fp
	rts
	stabs	"t",0x6,050,8
	stabs	"Textfram",0x21,0,0
	stabs	"pt",0x6,010,12
	stabs	"Point",0x21,0,0
	stabs	"but",0x6,04,16
	stabs	"seek",0x19,92,L%105
	set	S%4,-12
	set	T%4,-20
	set	F%4,-24
	set	M%4,0x040c
	data	1
	text
	stabs	"tellseek",0x12,95,tellseek
	global	tellseek
tellseek:
	link	%fp,&F%5
	movm.l	&M%5,S%5(%fp)
	mov.l	8(%fp),%a2
	mov.w	12(%fp),32(%a2)
	lea.l	-8+S%5(%fp),%a0
	mov.l	%a2,%a1
	add.l	&8,%a1
	mov.l	(%a1)+,(%a0)+
	mov.l	0(%a1),0(%a0)
	mov.w	-2+S%5(%fp),%d0
	ext.l	%d0
	mov.w	-6+S%5(%fp),%d1
	ext.l	%d1
	sub.l	%d1,%d0
	sub.l	&4,%d0
	mov.w	12(%fp),%d1
	ext.l	%d1
	mov.l	%d0,(%sp)
	mov.l	%d1,%d0
	jsr	lmul%%
	divs.w	&1024,%d0
	add.w	-6+S%5(%fp),%d0
	add.w	&2,%d0
	mov.w	%d0,12(%fp)
	mov.w	&1,(%sp)
	lea.l	-8+S%5(%fp),%a0
	mov.l	4(%a0),-(%sp)
	mov.l	0(%a0),-(%sp)
	jsr	Rectf
	add.l	&8,%sp
	mov.w	12(%fp),-6+S%5(%fp)
	mov.w	12(%fp),%d0
	add.w	&2,%d0
	mov.w	%d0,-2+S%5(%fp)
	add.w	&1,-8+S%5(%fp)
	sub.w	&1,-4+S%5(%fp)
	lea.l	-8+S%5(%fp),%a0
	mov.l	4(%a0),(%sp)
	mov.l	0(%a0),-(%sp)
	jsr	rXOR
	add.l	&4,%sp
	stabs	"r",0x5,010,8
	stabs	"Rectangl",0x21,0,0
	stabs	"t",0x4,050,10
	stabs	"Textfram",0x21,0,0
L%114:
	movm.l	S%5(%fp),&M%5
	unlk	%fp
	rts
	stabs	"t",0x6,050,8
	stabs	"Textfram",0x21,0,0
	stabs	"y",0x6,04,12
	stabs	"tellseek",0x19,106,L%114
	set	S%5,-4
	set	T%5,-12
	set	F%5,-16
	set	M%5,0x0400
	data	1
	text
	stabs	"usualtes",0x12,108,usualtes
	global	usualtes
usualtes:
	link	%fp,&F%6
	movm.l	&M%6,S%6(%fp)
	tst.w	inscompl
	bne	L%118
	mov.l	&1,%d0
	br	L%119
L%118:
	mov.l	&0,%d0
L%119:
	br	L%117
L%117:
	movm.l	S%6(%fp),&M%6
	unlk	%fp
	rts
	stabs	"usualtes",0x19,110,L%117
	set	S%6,0
	set	T%6,0
	set	F%6,-4
	set	M%6,0x0000
	data	1
	text
	stabs	"loadfile",0x12,114,loadfile
	global	loadfile
loadfile:
	link	%fp,&F%7
	movm.l	&M%7,S%7(%fp)
	mov.l	8(%fp),%a2
	mov.w	12(%fp),%d2
	mov.w	%d2,(%sp)
	mov.l	%a2,-(%sp)
	jsr	ptofchar
	add.l	&4,%sp
	mov.l	%d0,loadpt
	mov.w	14(%fp),reqlimit
	mov.w	14(%fp),ntoload
	clr.w	nrequest
	mov.w	%d2,reqposn
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,(%sp)
	jsr	urequest
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,(%sp)
	jsr	urequest
	mov.l	&iodone,(%sp)
	jsr	waitunix
	cmp.w	14(%fp),&32767
	bne	L%122
	clr.w	reqlimit
L%123:
	mov.w	&8,(%sp)
	mov.l	474,%a0
	jsr	(%a0)
	tst.w	%d0
	beq	L%124
	jsr	rcv
	tst.w	%d0
	beq	L%125
	jsr	message
	br	L%124
L%125:
	br	L%123
L%124:
L%122:
	stabs	"t",0x4,050,10
	stabs	"Textfram",0x21,0,0
	stabs	"posn",0x4,04,2
L%120:
	movm.l	S%7(%fp),&M%7
	unlk	%fp
	rts
	stabs	"t",0x6,050,8
	stabs	"Textfram",0x21,0,0
	stabs	"posn",0x6,04,12
	stabs	"n",0x6,04,14
	stabs	"loadfile",0x19,132,L%120
	set	S%7,-8
	set	T%7,-8
	set	F%7,-12
	set	M%7,0x0404
	data	1
	text
	stabs	"urequest",0x12,135,urequest
	global	urequest
urequest:
	link	%fp,&F%8
	movm.l	&M%8,S%8(%fp)
	mov.w	nrequest,%d0
	cmp.w	%d0,reqlimit
	bgt	L%127
	mov.w	reqlimit,%d0
	sub.w	nrequest,%d0
	mov.w	%d0,(%sp)
	mov.w	&59,-(%sp)
	jsr	min
	add.l	&2,%sp
	mov.w	%d0,%d2
	mov.w	%d2,(%sp)
	jsr	data2
	mov.l	%a0,(%sp)
	mov.w	&2,-(%sp)
	mov.w	reqposn,-(%sp)
	mov.w	&9,-(%sp)
	mov.w	8(%fp),-(%sp)
	jsr	send
	add.l	&8,%sp
	add.w	%d2,reqposn
	add.w	%d2,nrequest
L%127:
	stabs	"n",0x4,04,2
L%126:
	movm.l	S%8(%fp),&M%8
	unlk	%fp
	rts
	stabs	"f",0x6,04,8
	stabs	"urequest",0x19,143,L%126
	set	S%8,-4
	set	T%8,-4
	set	F%8,-8
	set	M%8,0x0004
	data	1
	text
	stabs	"move",0x12,147,move
	global	move
move:
	link	%fp,&F%9
	movm.l	&M%9,S%9(%fp)
	mov.l	8(%fp),%a2
	cmp.l	%a2,&frame
	bne	L%131
	br	L%130
L%131:
	mov.w	&3,(%sp)
	mov.l	%a2,-(%sp)
	jsr	selectf
	add.l	&4,%sp
	lea.l	-8+S%9(%fp),%a0
	mov.l	%a2,%a1
	add.l	&8,%a1
	mov.l	(%a1)+,(%a0)+
	mov.l	0(%a1),0(%a0)
	mov.w	14(%fp),%d0
	sub.w	-6+S%9(%fp),%d0
	sub.w	&2,%d0
	muls.w	38(%a2),%d0
	mov.w	-2+S%9(%fp),%d1
	sub.w	-6+S%9(%fp),%d1
	sub.w	&4,%d1
	divs.w	%d1,%d0
	mov.w	%d0,%d2
	tst.w	%d2
	bge	L%133
	mov.l	&0,%d2
L%133:
	tst.w	16(%fp)
	bne	L%134
	mov.w	%d2,%d0
	neg.w	%d0
	mov.w	%d0,%d2
L%134:
	mov.w	28(%a2),(%sp)
	mov.l	%a2,-(%sp)
	jsr	ptofchar
	add.l	&4,%sp
	mov.l	%d0,12(%fp)
	mov.w	%d2,(%sp)
	mov.l	%a2,-(%sp)
	jsr	scroll
	add.l	&4,%sp
	mov.l	12(%fp),(%sp)
	mov.l	%a2,-(%sp)
	jsr	charofpt
	add.l	&4,%sp
	mov.w	%d0,(%sp)
	mov.l	%a2,-(%sp)
	jsr	setsel
	add.l	&4,%sp
	mov.w	&0,(%sp)
	jsr	data2
	mov.l	%a0,(%sp)
	mov.w	&2,-(%sp)
	mov.w	28(%a2),-(%sp)
	mov.w	&6,-(%sp)
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	send
	add.l	&8,%sp
	stabs	"n",0x4,04,2
	stabs	"r",0x5,010,8
	stabs	"Rectangl",0x21,0,0
	stabs	"t",0x4,050,10
	stabs	"Textfram",0x21,0,0
L%130:
	movm.l	S%9(%fp),&M%9
	unlk	%fp
	rts
	stabs	"t",0x6,050,8
	stabs	"Textfram",0x21,0,0
	stabs	"pt",0x6,010,12
	stabs	"Point",0x21,0,0
	stabs	"but",0x6,04,16
	stabs	"move",0x19,163,L%130
	set	S%9,-8
	set	T%9,-16
	set	F%9,-20
	set	M%9,0x0404
	data	1
	even
	global	deadmous
deadmous:
	short	0
	short	0
	short	0
	short	0
	short	0
	short	12
	short	130
	short	1089
	short	65505
	short	24561
	short	16382
	short	6128
	short	992
	short	0
	short	0
	short	0
	text
	stabs	"waitunix",0x12,170,waitunix
	global	waitunix
waitunix:
	link	%fp,&F%10
	movm.l	&M%10,S%10(%fp)
	mov.l	8(%fp),%a2
	mov.l	&deadmous,(%sp)
	mov.l	302,%a0
	jsr	(%a0)
	clr.w	(%a2)
L%139:
	tst.w	(%a2)
	bne	L%140
	mov.w	&8,(%sp)
	mov.l	474,%a0
	jsr	(%a0)
	jsr	rcv
	tst.w	%d0
	beq	L%141
	jsr	message
L%141:
	br	L%139
L%140:
	sub.l	%a0,%a0
	mov.l	%a0,(%sp)
	mov.l	302,%a0
	jsr	(%a0)
	stabs	"flag",0x4,044,10
L%138:
	movm.l	S%10(%fp),&M%10
	unlk	%fp
	rts
	stabs	"flag",0x6,044,8
	stabs	"waitunix",0x19,179,L%138
	set	S%10,-4
	set	T%10,-4
	set	F%10,-8
	set	M%10,0x0400
	data	1
	text
	stabs	"message",0x12,181,message
	global	message
message:
	link	%fp,&F%11
	movm.l	&M%11,S%11(%fp)
	lcomm	L%143,2
	lcomm	L%144,2
	data	1
	even
L%145:
	short	0
	text
	clr.w	%d0
	mov.b	m,%d0
	mov.w	%d0,%d2
	mov.w	%d2,(%sp)
	jsr	frameoff
	mov.l	%a0,%a3
	clr.w	%d0
	mov.b	m+1,%d0
	mov.w	%d0,%d3
	mov.b	m+2,%d0
	ext.w	%d0
	mov.w	%d0,%d4
	mov.w	m+4,%d5
	mov.l	&m+6,%a2
	clr.b	0(%a2,%d3.w)
	clr.w	%d0
	mov.b	(%a2),%d0
	mov.b	1(%a2),%d1
	ext.w	%d1
	lsl.w	&8,%d1
	add.w	%d1,%d0
	mov.w	%d0,%d6
	mov.w	%d4,%d0
	br	L%147
L%148:
	mov.w	&0,(%sp)
	mov.l	%a2,-(%sp)
	jsr	mesg
	add.l	&4,%sp
	br	L%146
L%150:
	tst.w	%d3
	beq	L%152
	mov.l	%a3,%d0
	bne	L%151
L%152:
L%153:
	mov.w	&1,iodone
	br	L%146
L%151:
	mov.w	%d3,-4+S%11(%fp)
	mov.l	%a2,-8+S%11(%fp)
	mov.w	%d5,(%sp)
	pea.l	-8+S%11(%fp)
	mov.l	%a3,-(%sp)
	jsr	instext
	add.l	&8,%sp
	sub.w	%d3,ntoload
	mov.l	donetest,%a0
	jsr	(%a0)
	tst.w	%d0
	beq	L%155
	br	L%153
L%155:
	mov.w	%d2,(%sp)
	jsr	urequest
	br	L%146
L%156:
	mov.w	%d5,(%sp)
	jsr	keepsear
	br	L%146
L%158:
	mov.w	%d5,(%sp)
	mov.l	%a3,-(%sp)
	jsr	tellseek
	add.l	&4,%sp
	br	L%146
L%159:
	mov.w	&0,(%sp)
	mov.w	&0,-(%sp)
	mov.w	&0,-(%sp)
	mov.l	%a3,-(%sp)
	jsr	seek
	add.l	&8,%sp
	cmp.l	%a3,current
	beq	L%160
	mov.l	%a3,(%sp)
	jsr	curse
L%160:
	br	L%146
L%161:
	mov.l	%a3,(%sp)
	jsr	curse
	mov.w	%d5,L%143
	mov.w	L%143,%d0
	add.w	%d6,%d0
	mov.w	%d0,L%144
	br	L%146
L%162:
	cmp.w	%d5,&-1
	bne	L%163
	mov.l	%a3,(%sp)
	jsr	initfram
	br	L%164
L%163:
	mov.w	&3,(%sp)
	mov.l	%a3,-(%sp)
	jsr	selectf
	add.l	&4,%sp
L%164:
	tst.w	%d5
	bgt	L%165
	mov.l	%a2,(%sp)
	jsr	integer
	mov.w	%d0,(%sp)
	mov.w	&0,-(%sp)
	mov.l	%a3,-(%sp)
	jsr	loadfile
	add.l	&6,%sp
L%165:
	mov.w	L%143,28(%a3)
	mov.w	L%144,30(%a3)
	clr.w	36(%a3)
	mov.w	L%144,%d0
	mov.l	24(%a3),%a1
	cmp.w	%d0,4(%a1)
	ble	L%167
	mov.l	24(%a3),%a0
	mov.w	4(%a0),L%144
	mov.w	&1,36(%a3)
L%167:
	mov.w	&3,(%sp)
	mov.l	%a3,-(%sp)
	jsr	selectf
	add.l	&4,%sp
	mov.l	%a3,(%sp)
	jsr	curse
	br	L%146
L%168:
	mov.w	&1,scrollli
	br	L%146
L%169:
	mov.w	&1,diagdone
	br	L%146
L%170:
	cmp.w	%d2,&20
	bge	L%171
	mov.l	%a2,(%sp)
	mov.w	%d2,-(%sp)
	jsr	setname
	add.l	&2,%sp
	cmp.w	%d3,L%145
	bgt	L%173
	mov.w	L%145,(%sp)
	jsr	adjustna
L%173:
L%171:
	mov.w	%d2,filedone
	br	L%146
L%175:
	mov.w	%d5,(%sp)
	mov.l	%a3,-(%sp)
	jsr	modified
	add.l	&4,%sp
	br	L%146
L%177:
	mov.w	%d6,L%145
	mov.w	%d6,%d0
	mov.w	%d0,(%sp)
	jsr	adjustna
	br	L%146
L%178:
	sub.l	%a0,%a0
	mov.l	%a0,(%sp)
	mov.w	&0,-(%sp)
	mov.w	&1024,-(%sp)
	mov.w	&800,-(%sp)
	mov.l	%a3,-(%sp)
	jsr	charofpt
	add.l	&8,%sp
	mov.w	%d0,-(%sp)
	mov.w	&16,-(%sp)
	mov.w	&0,-(%sp)
	jsr	send
	add.l	&8,%sp
	br	L%146
L%179:
	data	2
L%180:
	byte	'u,'n,'k,'\n,0x00
	text
	mov.w	&1,(%sp)
	mov.l	&L%180,-(%sp)
	jsr	mesg
	add.l	&4,%sp
	br	L%146
L%147:
	cmp.w	%d0,&19
	bhi	L%179
	add.w	%d0,%d0
	add.w	6(%pc,%d0.w),%d0
	jmp	2(%pc,%d0.w)
L%181:
	pcrel	L%148
	pcrel	L%150
	pcrel	L%179
	pcrel	L%156
	pcrel	L%179
	pcrel	L%179
	pcrel	L%161
	pcrel	L%179
	pcrel	L%179
	pcrel	L%179
	pcrel	L%158
	pcrel	L%168
	pcrel	L%169
	pcrel	L%159
	pcrel	L%162
	pcrel	L%170
	pcrel	L%178
	pcrel	L%179
	pcrel	L%177
	pcrel	L%175
L%146:
	stabs	"numdata",0x4,04,6
	stabs	"f",0x4,04,2
	stabs	"n",0x4,04,3
	stabs	"t",0x4,050,11
	stabs	"Textfram",0x21,0,0
	stabs	"s1",0x2,04,L%143
	stabs	"s2",0x2,04,L%144
	stabs	"op",0x4,04,4
	stabs	"rcvstr",0x5,010,8
	stabs	"String",0x21,0,0
	stabs	"maxlengt",0x2,04,L%145
	stabs	"data",0x4,042,10
	stabs	"posn",0x4,04,5
L%142:
	movm.l	S%11(%fp),&M%11
	unlk	%fp
	rts
	stabs	"message",0x19,275,L%142
	set	S%11,-28
	set	T%11,-36
	set	F%11,-40
	set	M%11,0x0c7c
	data	1
	text
	stabs	"integer",0x12,278,integer
	global	integer
integer:
	link	%fp,&F%12
	movm.l	&M%12,S%12(%fp)
	mov.l	8(%fp),%a2
	clr.w	%d0
	mov.b	(%a2),%d0
	mov.b	1(%a2),%d1
	ext.w	%d1
	lsl.w	&8,%d1
	add.w	%d1,%d0
	br	L%182
	stabs	"s",0x4,042,10
L%182:
	movm.l	S%12(%fp),&M%12
	unlk	%fp
	rts
	stabs	"s",0x6,042,8
	stabs	"integer",0x19,280,L%182
	set	S%12,-4
	set	T%12,-4
	set	F%12,-8
	set	M%12,0x0400
	data	1
	even
	global	diagnewl
diagnewl:
	short	1
	text
	stabs	"mesg",0x12,284,mesg
	global	mesg
mesg:
	link	%fp,&F%13
	movm.l	&M%13,S%13(%fp)
	mov.l	8(%fp),%a2
	lea.l	-81+S%13(%fp),%a3
	mov.l	%a2,%a4
	mov.l	&frame,%a5
	tst.w	diagnewl
	beq	L%184
	mov.l	current,%a0
	cmp.l	%a0,%a5
	bne	L%185
	mov.w	diagclr,%d0
	br	L%186
L%185:
	mov.l	&2,%d0
L%186:
	mov.w	%d0,(%sp)
	mov.l	&frame,%a0
	mov.l	4(%a0),-(%sp)
	mov.l	0(%a0),-(%sp)
	jsr	Rectf
	add.l	&8,%sp
	mov.l	24(%a5),(%sp)
	jsr	zerostri
	mov.w	&0,(%sp)
	mov.l	%a5,-(%sp)
	jsr	setsel
	add.l	&4,%sp
L%184:
	clr.w	diagnewl
L%187:
	mov.b	(%a4)+,(%a3)
	beq	L%188
	add.l	&1,%a3
	br	L%187
L%188:
	tst.w	12(%fp)
	beq	L%189
	mov.l	%a2,(%sp)
	lea.l	-81+S%13(%fp),%a0
	mov.l	%a3,%d1
	sub.l	%a0,%d1
	mov.l	%d1,-(%sp)
	mov.w	28(%a5),-(%sp)
	mov.w	&1,-(%sp)
	mov.l	&frame,-(%sp)
	jsr	sendstr
	add.l	&12,%sp
L%189:
	lea.l	-81+S%13(%fp),%a0
	cmp.l	%a3,%a0
	bls	L%191
	cmp.b	-1(%a3),&10
	bne	L%191
	mov.w	&1,diagnewl
	clr.b	-(%a3)
L%191:
	mov.l	%a3,%d0
	lea.l	-81+S%13(%fp),%a1
	mov.l	%a1,%d1
	sub.w	%d1,%d0
	mov.w	%d0,%d2
	mov.w	%d2,-86+S%13(%fp)
	lea.l	-81+S%13(%fp),%a0
	mov.l	%a0,-90+S%13(%fp)
	mov.w	28(%a5),(%sp)
	pea.l	-90+S%13(%fp)
	mov.l	%a5,-(%sp)
	jsr	instext
	add.l	&8,%sp
	mov.w	28(%a5),%d0
	add.w	%d2,%d0
	mov.w	%d0,(%sp)
	mov.l	%a5,-(%sp)
	jsr	setsel
	add.l	&4,%sp
	lea.l	-81+S%13(%fp),%a0
	cmp.l	%a3,%a0
	bls	L%192
	tst.w	12(%fp)
	bne	L%192
	mov.l	&frame,%a0
	mov.l	4(%a0),(%sp)
	mov.l	0(%a0),-(%sp)
	jsr	rXOR
	add.l	&4,%sp
	mov.w	&10,(%sp)
	mov.l	390,%a0
	jsr	(%a0)
	mov.l	&frame,%a0
	mov.l	4(%a0),(%sp)
	mov.l	0(%a0),-(%sp)
	jsr	rXOR
	add.l	&4,%sp
L%192:
	stabs	"i",0x4,04,2
	stabs	"p",0x4,042,11
	stabs	"q",0x4,042,12
	stabs	"s",0x4,042,10
	stabs	"t",0x4,050,13
	stabs	"Textfram",0x21,0,0
	stabs	"buf",0x5,0142,81
	stabs	"diagstr",0x5,010,90
	stabs	"String",0x21,0,0
L%183:
	movm.l	S%13(%fp),&M%13
	unlk	%fp
	rts
	stabs	"s",0x6,042,8
	stabs	"sendit",0x6,04,12
	stabs	"mesg",0x19,313,L%183
	set	S%13,-20
	set	T%13,-110
	set	F%13,-114
	set	M%13,0x3c04
	data	1
	text
	stabs	"sendstr",0x12,328,sendstr
	global	sendstr
sendstr:
	link	%fp,&F%14
	movm.l	&M%14,S%14(%fp)
	mov.w	16(%fp),%d2
	mov.l	18(%fp),%a2
L%196:
	mov.w	%d2,%d3
	cmp.w	%d3,&59
	bls	L%197
	mov.l	&59,%d3
L%197:
	mov.l	%a2,(%sp)
	mov.w	%d3,-(%sp)
	mov.w	14(%fp),-(%sp)
	mov.w	12(%fp),-(%sp)
	mov.l	8(%fp),%a0
	mov.b	34(%a0),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	send
	add.l	&8,%sp
	add.w	%d3,14(%fp)
	clr.l	%d0
	mov.w	%d3,%d0
	add.l	%d0,%a2
	sub.w	%d3,%d2
L%195:
	tst.w	%d2
	bgt	L%196
L%194:
	stabs	"d",0x4,042,10
	stabs	"n",0x4,04,2
	stabs	"m",0x4,016,3
L%193:
	movm.l	S%14(%fp),&M%14
	unlk	%fp
	rts
	stabs	"f",0x6,050,8
	stabs	"Textfram",0x21,0,0
	stabs	"op",0x6,04,12
	stabs	"posn",0x6,04,14
	stabs	"n",0x6,04,16
	stabs	"d",0x6,042,18
	stabs	"sendstr",0x19,338,L%193
	set	S%14,-12
	set	T%14,-12
	set	F%14,-16
	set	M%14,0x040c
	data	1
	text
	stabs	"scrollte",0x12,340,scrollte
	global	scrollte
scrollte:
	link	%fp,&F%15
	movm.l	&M%15,S%15(%fp)
	tst.w	ntoload
	bgt	L%200
	mov.l	&1,%d0
	br	L%201
L%200:
	mov.l	&0,%d0
L%201:
	br	L%199
L%199:
	movm.l	S%15(%fp),&M%15
	unlk	%fp
	rts
	stabs	"scrollte",0x19,342,L%199
	set	S%15,0
	set	T%15,0
	set	F%15,-4
	set	M%15,0x0000
	data	1
	text
	stabs	"scroll",0x12,346,scroll
	global	scroll
scroll:
	link	%fp,&F%16
	movm.l	&M%16,S%16(%fp)
	mov.l	8(%fp),%a2
	mov.w	12(%fp),%d2
	tst.w	%d2
	beq	L%204
	cmp.l	%a2,&frame
	bne	L%203
L%204:
	mov.l	&0,%d0
	br	L%202
L%203:
	sub.l	%a0,%a0
	mov.l	%a0,(%sp)
	mov.w	&0,-(%sp)
	mov.w	%d2,-(%sp)
	mov.w	&11,-(%sp)
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	send
	add.l	&8,%sp
	mov.l	&scrollli,(%sp)
	jsr	waitunix
	mov.w	m+4,%d3
	tst.w	%d3
	ble	L%205
	clr.w	28(%a2)
	mov.l	24(%a2),%a0
	cmp.w	%d3,4(%a0)
	ble	L%206
	mov.l	24(%a2),%a0
	mov.w	4(%a0),30(%a2)
	br	L%207
L%206:
	mov.w	%d3,30(%a2)
L%207:
	clr.w	36(%a2)
	mov.w	&2,(%sp)
	mov.l	%a2,-(%sp)
	jsr	deltext
	add.l	&4,%sp
	br	L%209
L%205:
	mov.w	&0,(%sp)
	mov.l	%a2,-(%sp)
	jsr	setsel
	add.l	&4,%sp
	mov.l	&scrollte,donetest
	mov.w	%d3,%d0
	neg.w	%d0
	mov.w	%d0,(%sp)
	mov.w	&0,-(%sp)
	mov.l	%a2,-(%sp)
	jsr	loadfile
	add.l	&6,%sp
	mov.l	&usualtes,donetest
L%209:
	mov.w	%d3,%d0
	br	L%202
	stabs	"t",0x4,050,10
	stabs	"Textfram",0x21,0,0
	stabs	"nchars",0x4,04,3
	stabs	"nlines",0x4,04,2
L%202:
	movm.l	S%16(%fp),&M%16
	unlk	%fp
	rts
	stabs	"t",0x6,050,8
	stabs	"Textfram",0x21,0,0
	stabs	"nlines",0x6,04,12
	stabs	"scroll",0x19,368,L%202
	set	S%16,-12
	set	T%16,-12
	set	F%16,-16
	set	M%16,0x040c
	data	1
	text
	stabs	"data2",0x12,370,data2
	global	data2
data2:
	link	%fp,&F%17
	movm.l	&M%17,S%17(%fp)
	lcomm	L%211,2
	mov.b	9(%fp),L%211
	mov.w	8(%fp),%d0
	asr.w	&8,%d0
	mov.b	%d0,L%211+1
	mov.l	&L%211,%a0
	br	L%210
	stabs	"x",0x2,0142,L%211
L%210:
	movm.l	S%17(%fp),&M%17
	unlk	%fp
	rts
	stabs	"n",0x6,04,8
	stabs	"data2",0x19,375,L%210
	set	S%17,0
	set	T%17,0
	set	F%17,-4
	set	M%17,0x0000
	data	1
	text
	stabs	"Send",0x12,381,Send
	global	Send
Send:
	link	%fp,&F%18
	movm.l	&M%18,S%18(%fp)
	mov.w	8(%fp),%d2
	mov.w	10(%fp),%d3
	mov.w	12(%fp),%d4
	mov.l	14(%fp),%a2
	mov.l	%a2,(%sp)
	mov.w	%d4,-(%sp)
	mov.w	%d3,-(%sp)
	mov.w	%d2,-(%sp)
	mov.l	current,%a0
	mov.b	34(%a0),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	send
	add.l	&8,%sp
	stabs	"n",0x4,04,4
	stabs	"s",0x4,042,10
	stabs	"op",0x4,04,2
	stabs	"posn",0x4,04,3
L%213:
	movm.l	S%18(%fp),&M%18
	unlk	%fp
	rts
	stabs	"op",0x6,04,8
	stabs	"posn",0x6,04,10
	stabs	"n",0x6,04,12
	stabs	"s",0x6,042,14
	stabs	"Send",0x19,383,L%213
	set	S%18,-16
	set	T%18,-16
	set	F%18,-20
	set	M%18,0x041c
	data	1
