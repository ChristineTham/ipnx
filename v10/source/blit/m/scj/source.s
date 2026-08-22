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
L%82:
	mov.l	262,%a0
	mov.w	8(%a0),%d0
	and.w	&2048,%d0
	beq	L%83
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
L%83:
	btst	&3,%d2
	beq	L%86
	jsr	rcv
	tst.w	%d0
	beq	L%86
	mov.l	current,(%sp)
	jsr	curse
	jsr	message
	mov.l	current,(%sp)
	jsr	curse
L%86:
	btst	&2,%d2
	beq	L%89
	mov.w	mouse+8,%d0
	and.w	&7,%d0
	beq	L%89
	mov.l	current,(%sp)
	jsr	curse
	mov.w	mouse+8,(%sp)
	mov.l	mouse,-(%sp)
	jsr	buttonhi
	add.l	&4,%sp
	mov.l	current,(%sp)
	jsr	curse
L%89:
	btst	&0,%d2
	beq	L%91
	tst.l	current
	beq	L%91
	mov.l	current,(%sp)
	jsr	type
L%91:
L%80:
	mov.w	&13,(%sp)
	mov.l	474,%a0
	jsr	(%a0)
	mov.w	%d0,%d2
	br	L%82
L%81:
L%76:
	movm.l	S%1(%fp),&M%1
	unlk	%fp
	rts
	set	S%1,-4
	set	T%1,-4
	set	F%1,-8
	set	M%1,04
	data	1
	text
	global	closeall
closeall:
	link	%fp,&F%2
	movm.l	&M%2,S%2(%fp)
	mov.l	&frame,%a2
L%96:
	cmp.l	%a2,&frame+2280
	bhs	L%95
	tst.b	34(%a2)
	beq	L%97
	mov.w	&32,(%sp)
	mov.w	&1,-(%sp)
	mov.b	34(%a2),%d0
	ext.w	%d0
	mov.w	%d0,-(%sp)
	jsr	setchar
	add.l	&4,%sp
L%97:
	mov.l	%a2,(%sp)
	jsr	closefra
	mov.l	%a2,(%sp)
	jsr	delobs
L%94:
	add.l	&114,%a2
	br	L%96
L%95:
	sub.l	%a0,%a0
	mov.l	%a0,current
L%93:
	movm.l	S%2(%fp),&M%2
	unlk	%fp
	rts
	set	S%2,-4
	set	T%2,-4
	set	F%2,-8
	set	M%2,02000
	data	1
	text
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
L%101:
	movm.l	S%3(%fp),&M%3
	unlk	%fp
	rts
	set	S%3,0
	set	T%3,0
	set	F%3,-4
	set	M%3,00
	data	1
	text
	global	seek
seek:
	link	%fp,&F%4
	movm.l	&M%4,S%4(%fp)
	mov.l	8(%fp),%a2
	mov.w	14(%fp),%d3
	cmp.l	%a2,&frame
	bne	L%105
	br	L%104
L%105:
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
	bge	L%107
	mov.l	&0,%d2
L%107:
	cmp.w	%d2,&1024
	ble	L%108
	mov.w	&1024,%d2
L%108:
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
L%104:
	movm.l	S%4(%fp),&M%4
	unlk	%fp
	rts
	set	S%4,-12
	set	T%4,-20
	set	F%4,-24
	set	M%4,02014
	data	1
	text
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
L%113:
	movm.l	S%5(%fp),&M%5
	unlk	%fp
	rts
	set	S%5,-4
	set	T%5,-12
	set	F%5,-16
	set	M%5,02000
	data	1
	text
	global	usualtes
usualtes:
	link	%fp,&F%6
	movm.l	&M%6,S%6(%fp)
	tst.w	inscompl
	bne	L%117
	mov.l	&1,%d0
	br	L%118
L%117:
	mov.l	&0,%d0
L%118:
	br	L%116
L%116:
	movm.l	S%6(%fp),&M%6
	unlk	%fp
	rts
	set	S%6,0
	set	T%6,0
	set	F%6,-4
	set	M%6,00
	data	1
	text
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
	bne	L%121
	clr.w	reqlimit
L%122:
	mov.w	&8,(%sp)
	mov.l	474,%a0
	jsr	(%a0)
	tst.w	%d0
	beq	L%123
	jsr	rcv
	tst.w	%d0
	beq	L%124
	jsr	message
	br	L%123
L%124:
	br	L%122
L%123:
L%121:
L%119:
	movm.l	S%7(%fp),&M%7
	unlk	%fp
	rts
	set	S%7,-8
	set	T%7,-8
	set	F%7,-12
	set	M%7,02004
	data	1
	text
	global	urequest
urequest:
	link	%fp,&F%8
	movm.l	&M%8,S%8(%fp)
	mov.w	nrequest,%d0
	cmp.w	%d0,reqlimit
	bgt	L%126
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
L%126:
L%125:
	movm.l	S%8(%fp),&M%8
	unlk	%fp
	rts
	set	S%8,-4
	set	T%8,-4
	set	F%8,-8
	set	M%8,04
	data	1
	text
	global	move
move:
	link	%fp,&F%9
	movm.l	&M%9,S%9(%fp)
	mov.l	8(%fp),%a2
	cmp.l	%a2,&frame
	bne	L%130
	br	L%129
L%130:
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
	bge	L%132
	mov.l	&0,%d2
L%132:
	tst.w	16(%fp)
	bne	L%133
	mov.w	%d2,%d0
	neg.w	%d0
	mov.w	%d0,%d2
L%133:
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
L%129:
	movm.l	S%9(%fp),&M%9
	unlk	%fp
	rts
	set	S%9,-8
	set	T%9,-16
	set	F%9,-20
	set	M%9,02004
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
	global	waitunix
waitunix:
	link	%fp,&F%10
	movm.l	&M%10,S%10(%fp)
	mov.l	8(%fp),%a2
	mov.l	&deadmous,(%sp)
	mov.l	302,%a0
	jsr	(%a0)
	clr.w	(%a2)
L%138:
	tst.w	(%a2)
	bne	L%139
	mov.w	&8,(%sp)
	mov.l	474,%a0
	jsr	(%a0)
	jsr	rcv
	tst.w	%d0
	beq	L%140
	jsr	message
L%140:
	br	L%138
L%139:
	sub.l	%a0,%a0
	mov.l	%a0,(%sp)
	mov.l	302,%a0
	jsr	(%a0)
L%137:
	movm.l	S%10(%fp),&M%10
	unlk	%fp
	rts
	set	S%10,-4
	set	T%10,-4
	set	F%10,-8
	set	M%10,02000
	data	1
	text
	global	message
message:
	link	%fp,&F%11
	movm.l	&M%11,S%11(%fp)
	lcomm	L%142,2
	lcomm	L%143,2
	data	1
	even
L%144:
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
	br	L%146
L%147:
	mov.w	&0,(%sp)
	mov.l	%a2,-(%sp)
	jsr	mesg
	add.l	&4,%sp
	br	L%145
L%149:
	tst.w	%d3
	beq	L%151
	mov.l	%a3,%d0
	bne	L%150
L%151:
L%152:
	mov.w	&1,iodone
	br	L%145
L%150:
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
	beq	L%154
	br	L%152
L%154:
	mov.w	%d2,(%sp)
	jsr	urequest
	br	L%145
L%155:
	mov.w	%d5,(%sp)
	jsr	keepsear
	br	L%145
L%157:
	mov.w	%d5,(%sp)
	mov.l	%a3,-(%sp)
	jsr	tellseek
	add.l	&4,%sp
	br	L%145
L%158:
	mov.w	&0,(%sp)
	mov.w	&0,-(%sp)
	mov.w	&0,-(%sp)
	mov.l	%a3,-(%sp)
	jsr	seek
	add.l	&8,%sp
	cmp.l	%a3,current
	beq	L%159
	mov.l	%a3,(%sp)
	jsr	curse
L%159:
	br	L%145
L%160:
	mov.l	%a3,(%sp)
	jsr	curse
	mov.w	%d5,L%142
	mov.w	L%142,%d0
	add.w	%d6,%d0
	mov.w	%d0,L%143
	br	L%145
L%161:
	cmp.w	%d5,&-1
	bne	L%162
	mov.l	%a3,(%sp)
	jsr	initfram
	br	L%163
L%162:
	mov.w	&3,(%sp)
	mov.l	%a3,-(%sp)
	jsr	selectf
	add.l	&4,%sp
L%163:
	tst.w	%d5
	bgt	L%164
	mov.l	%a2,(%sp)
	jsr	integer
	mov.w	%d0,(%sp)
	mov.w	&0,-(%sp)
	mov.l	%a3,-(%sp)
	jsr	loadfile
	add.l	&6,%sp
L%164:
	mov.w	L%142,28(%a3)
	mov.w	L%143,30(%a3)
	clr.w	36(%a3)
	mov.w	L%143,%d0
	mov.l	24(%a3),%a1
	cmp.w	%d0,4(%a1)
	ble	L%166
	mov.l	24(%a3),%a0
	mov.w	4(%a0),L%143
	mov.w	&1,36(%a3)
L%166:
	mov.w	&3,(%sp)
	mov.l	%a3,-(%sp)
	jsr	selectf
	add.l	&4,%sp
	mov.l	%a3,(%sp)
	jsr	curse
	br	L%145
L%167:
	mov.w	&1,scrollli
	br	L%145
L%168:
	mov.w	&1,diagdone
	br	L%145
L%169:
	cmp.w	%d2,&20
	bge	L%170
	mov.l	%a2,(%sp)
	mov.w	%d2,-(%sp)
	jsr	setname
	add.l	&2,%sp
	cmp.w	%d3,L%144
	bgt	L%172
	mov.w	L%144,(%sp)
	jsr	adjustna
L%172:
L%170:
	mov.w	%d2,filedone
	br	L%145
L%174:
	mov.w	%d5,(%sp)
	mov.l	%a3,-(%sp)
	jsr	modified
	add.l	&4,%sp
	br	L%145
L%176:
	mov.w	%d6,L%144
	mov.w	%d6,%d0
	mov.w	%d0,(%sp)
	jsr	adjustna
	br	L%145
L%177:
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
	br	L%145
L%178:
	data	2
L%179:
	byte	0165,0156,0153,012,00
	text
	mov.w	&1,(%sp)
	mov.l	&L%179,-(%sp)
	jsr	mesg
	add.l	&4,%sp
	br	L%145
L%146:
	cmp.w	%d0,&19
	bhi	L%178
	add.w	%d0,%d0
	mov.w	6(%pc,%d0.w),%d0
	jmp	2(%pc,%d0.w)
L%180:
	short	L%147-L%180
	short	L%149-L%180
	short	L%178-L%180
	short	L%155-L%180
	short	L%178-L%180
	short	L%178-L%180
	short	L%160-L%180
	short	L%178-L%180
	short	L%178-L%180
	short	L%178-L%180
	short	L%157-L%180
	short	L%167-L%180
	short	L%168-L%180
	short	L%158-L%180
	short	L%161-L%180
	short	L%169-L%180
	short	L%177-L%180
	short	L%178-L%180
	short	L%176-L%180
	short	L%174-L%180
L%145:
L%141:
	movm.l	S%11(%fp),&M%11
	unlk	%fp
	rts
	set	S%11,-28
	set	T%11,-36
	set	F%11,-40
	set	M%11,06174
	data	1
	text
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
	br	L%181
L%181:
	movm.l	S%12(%fp),&M%12
	unlk	%fp
	rts
	set	S%12,-4
	set	T%12,-4
	set	F%12,-8
	set	M%12,02000
	data	1
	even
	global	diagnewl
diagnewl:
	short	1
	text
	global	mesg
mesg:
	link	%fp,&F%13
	movm.l	&M%13,S%13(%fp)
	mov.l	8(%fp),%a2
	lea.l	-81+S%13(%fp),%a3
	mov.l	%a2,%a4
	mov.l	&frame,%a5
	tst.w	diagnewl
	beq	L%183
	mov.l	current,%a0
	cmp.l	%a0,%a5
	bne	L%184
	mov.w	diagclr,%d0
	br	L%185
L%184:
	mov.l	&2,%d0
L%185:
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
L%183:
	clr.w	diagnewl
L%186:
	mov.b	(%a4)+,(%a3)
	beq	L%187
	add.l	&1,%a3
	br	L%186
L%187:
	tst.w	12(%fp)
	beq	L%188
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
L%188:
	lea.l	-81+S%13(%fp),%a0
	cmp.l	%a3,%a0
	bls	L%190
	cmp.b	-1(%a3),&10
	bne	L%190
	mov.w	&1,diagnewl
	clr.b	-(%a3)
L%190:
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
	bls	L%191
	tst.w	12(%fp)
	bne	L%191
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
L%191:
L%182:
	movm.l	S%13(%fp),&M%13
	unlk	%fp
	rts
	set	S%13,-20
	set	T%13,-110
	set	F%13,-114
	set	M%13,036004
	data	1
	text
	global	sendstr
sendstr:
	link	%fp,&F%14
	movm.l	&M%14,S%14(%fp)
	mov.w	16(%fp),%d2
	mov.l	18(%fp),%a2
L%195:
	mov.w	%d2,%d3
	cmp.w	%d3,&59
	bls	L%196
	mov.l	&59,%d3
L%196:
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
L%194:
	tst.w	%d2
	bgt	L%195
L%193:
L%192:
	movm.l	S%14(%fp),&M%14
	unlk	%fp
	rts
	set	S%14,-12
	set	T%14,-12
	set	F%14,-16
	set	M%14,02014
	data	1
	text
	global	scrollte
scrollte:
	link	%fp,&F%15
	movm.l	&M%15,S%15(%fp)
	tst.w	ntoload
	bgt	L%199
	mov.l	&1,%d0
	br	L%200
L%199:
	mov.l	&0,%d0
L%200:
	br	L%198
L%198:
	movm.l	S%15(%fp),&M%15
	unlk	%fp
	rts
	set	S%15,0
	set	T%15,0
	set	F%15,-4
	set	M%15,00
	data	1
	text
	global	scroll
scroll:
	link	%fp,&F%16
	movm.l	&M%16,S%16(%fp)
	mov.l	8(%fp),%a2
	mov.w	12(%fp),%d2
	tst.w	%d2
	beq	L%203
	cmp.l	%a2,&frame
	bne	L%202
L%203:
	mov.l	&0,%d0
	br	L%201
L%202:
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
	ble	L%204
	clr.w	28(%a2)
	mov.l	24(%a2),%a0
	cmp.w	%d3,4(%a0)
	ble	L%205
	mov.l	24(%a2),%a0
	mov.w	4(%a0),30(%a2)
	br	L%206
L%205:
	mov.w	%d3,30(%a2)
L%206:
	clr.w	36(%a2)
	mov.w	&2,(%sp)
	mov.l	%a2,-(%sp)
	jsr	deltext
	add.l	&4,%sp
	br	L%208
L%204:
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
L%208:
	mov.w	%d3,%d0
	br	L%201
L%201:
	movm.l	S%16(%fp),&M%16
	unlk	%fp
	rts
	set	S%16,-12
	set	T%16,-12
	set	F%16,-16
	set	M%16,02014
	data	1
	text
	global	data2
data2:
	link	%fp,&F%17
	movm.l	&M%17,S%17(%fp)
	lcomm	L%210,2
	mov.b	9(%fp),L%210
	mov.w	8(%fp),%d0
	asr.w	&8,%d0
	mov.b	%d0,L%210+1
	mov.l	&L%210,%a0
	br	L%209
L%209:
	movm.l	S%17(%fp),&M%17
	unlk	%fp
	rts
	set	S%17,0
	set	T%17,0
	set	F%17,-4
	set	M%17,00
	data	1
	text
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
L%212:
	movm.l	S%18(%fp),&M%18
	unlk	%fp
	rts
	set	S%18,-16
	set	T%18,-16
	set	F%18,-20
	set	M%18,02034
	data	1
