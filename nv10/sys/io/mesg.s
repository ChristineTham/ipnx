L11:	.stabs	"mesg.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553095
	.data
	.comm	_nswdevt,4
	.align	2
	.globl	_msgrinit
_msgrinit:
	.long	_msctodput
	.long	_msctodsrv
	.long	_msgopen
	.long	_msgclose
	.long	0x410080
	.align	2
	.globl	_msgwinit
_msgwinit:
	.long	_msdtocput
	.long	_msdtocsrv
	.long	_msgopen
	.long	_msgclose
	.long	0x410080
	.align	2
	.globl	_msgstream
_msgstream:
	.long	_msgrinit
	.long	_msgwinit
	.align	2
	.globl	_rmsgrinit
_rmsgrinit:
	.long	_msdtocput
	.long	_msdtocsrv
	.long	_rmsgopen
	.long	_rmsgclose
	.long	0x410080
	.align	2
	.globl	_rmsgwinit
_rmsgwinit:
	.long	_msctodput
	.long	_msctodsrv
	.long	_rmsgopen
	.long	_rmsgclose
	.long	0x410080
	.align	2
	.globl	_rmsgstream
_rmsgstream:
	.long	_rmsgrinit
	.long	_rmsgwinit
	.text
	.align	2
	.globl	_msgopen
_msgopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"msgopen",0x24,0,36,_msgopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	tstl	48(r11)
	jeql	L61
	movl	$1,r0
	jbr	L60
L61:
	movl	$_mesg,r10
	movl	_msgcnt,r9
	jbr	L64
L65:
	tstl	r9
	jgtr	L66
	clrl	r0
	jbr	L60
L66:
	addl2	$8,r10
	movl	r9,r0
	decl	r9
L64:
	bitb	$1,1(r10)
	jneq	L65
L63:
	movb	$3,1(r10)
	clrw	2(r10)
	movl	r10,48(r11)
	bisw2	$320,54(r11)
	bisw2	$128,26(r11)
	movl	$1,r0
	jbr	L60
	.stabs	"i",0x40,0,4,9
	.stabs	"mp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L60:
	ret
	.set	L.R1,0xe00
	.set	L.SO1,0x0
L67:	.data
	.text
	.align	2
	.globl	_rmsgopen
_rmsgopen:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"rmsgopen",0x24,0,56,_rmsgopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	tstl	20(r11)
	jeql	L69
	movl	$1,r0
	jbr	L68
L69:
	movl	$_mesg,r10
	movl	_msgcnt,r9
	jbr	L72
L73:
	tstl	r9
	jgtr	L74
	clrl	r0
	jbr	L68
L74:
	addl2	$8,r10
	movl	r9,r0
	decl	r9
L72:
	bitb	$1,1(r10)
	jneq	L73
L71:
	movb	$3,1(r10)
	clrw	2(r10)
	movl	r10,20(r11)
	bisw2	$256,54(r11)
	bisw2	$192,26(r11)
	movl	$1,r0
	jbr	L68
	.stabs	"i",0x40,0,4,9
	.stabs	"mp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L68:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L75:	.data
	.text
	.align	2
	.globl	_msgclose
_msgclose:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"msgclose",0x24,0,75,_msgclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	pushl	48(r11)
	calls	$1,_msgbclose
	.stabs	"q",0x40,0,40,11
L76:
	ret
	.set	L.R3,0x800
	.set	L.SO3,0x0
L78:	.data
	.text
	.align	2
	.globl	_rmsgclose
_rmsgclose:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"rmsgclose",0x24,0,81,_rmsgclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	pushl	20(r11)
	calls	$1,_msgbclose
	.stabs	"q",0x40,0,40,11
L79:
	ret
	.set	L.R4,0x800
	.set	L.SO4,0x0
L80:	.data
	.text
	.align	2
	.globl	_msgbclose
_msgbclose:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"msgbclose",0x24,0,87,_msgbclose
	.stabs	"p",0xa0,0,40,4
	movl	4(ap),r11
	tstl	r11
	jneq	L82
	jbr	L81
L82:
	clrb	1(r11)
	tstl	4(r11)
	jeql	L83
	pushl	4(r11)
	calls	$1,_freeb
L83:
	clrl	4(r11)
	.stabs	"p",0x40,0,40,11
L81:
	ret
	.set	L.R5,0x800
	.set	L.SO5,0x0
L85:	.data
	.text
	.align	2
	.globl	_msctodput
_msctodput:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"msctodput",0x24,0,99,_msctodput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	bitw	$16,26(r11)
	jeql	L87
	addl3	$28,r11,r0
	jbr	L88
L87:
	subl3	$28,r11,r0
L88:
	movl	20(r0),r9
	pushl	r11
	calls	$1,_backq
	movl	r0,r8
	bitb	$2,1(r9)
	jeql	L89
	bitw	$128,26(r8)
	jneq	L90
	bicb2	$2,1(r9)
	pushl	$11
	pushl	r11
	calls	$2,_putctl
L90:
	jbr	L92
L89:
	bitw	$128,26(r8)
	jeql	L93
	bisb2	$2,1(r9)
	pushl	$10
	pushl	r11
	calls	$2,_putctl
L93:
L92:
	cmpb	20(r10),$67
	jneq	L94
	pushl	r10
	calls	$1,_freeb
	bisb2	$8,1(r9)
	jbr	L86
L94:
	cmpb	20(r10),$64
	jlssu	L95
	cmpb	20(r10),$68
	jneq	L96
	pushl	r10
	calls	$1,_freeb
	jbr	L97
L96:
	bitb	$16,1(r9)
	jeql	L98
	cmpb	20(r10),$69
	jeql	L100
	cmpb	20(r10),$70
	jneq	L98
L100:
L99:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	bicb2	$16,1(r9)
	jbr	L86
L98:
	pushl	r10
	pushl	r11
	calls	$2,_putq
L97:
	bicb2	$8,1(r9)
	pushl	r11
	calls	$1,_qenable
	jbr	L86
L95:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	jbr	L86
	.stabs	"bq",0x40,0,40,8
	.stabs	"mp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L86:
	ret
	.set	L.R6,0xf00
	.set	L.SO6,0x0
L102:	.data
	.text
	.align	2
	.globl	_msctodsrv
_msctodsrv:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"msctodsrv",0x24,0,143,_msctodsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	bitw	$16,26(r11)
	jeql	L104
	addl3	$28,r11,r0
	jbr	L105
L104:
	subl3	$28,r11,r0
L105:
	movl	20(r0),r8
L108:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L110
	bitb	$8,1(r8)
	jeql	L109
L110:
	jbr	L103
L109:
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L111
	jbr	L103
L111:
	pushl	$4
	calls	$1,_allocb
	movl	r0,r9
	jneq	L112
	pushl	r10
	pushl	r11
	calls	$2,_putbq
	jbr	L103
L112:
	movl	8(r9),r0
	movb	$229,1(r0)
	movzbl	20(r10),r7
	movb	r7,*8(r9)
	subl3	4(r10),8(r10),r6
	movl	8(r9),r0
	movb	r6,2(r0)
	movl	8(r9),r0
	extzv	$8,$24,r6,r1
	movb	r1,3(r0)
	addl2	$4,8(r9)
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	clrb	20(r10)
	movzbl	21(r10),r0
	bicl3	$-129,r0,-4(fp)
	bisb2	$128,21(r10)
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	tstl	-4(fp)
	jeql	L114
	pushl	$4
	calls	$1,_allocb
	movl	r0,r9
	jneq	L115
	jbr	L103
L115:
	movl	8(r9),r0
	movb	$229,1(r0)
	movb	$3,*8(r9)
	movl	8(r9),r0
	clrb	2(r0)
	movl	8(r9),r0
	clrb	3(r0)
	addl2	$4,8(r9)
	bisb2	$128,21(r9)
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L114:
	cmpl	r7,$2
	jneq	L116
	pushl	$2
	pushl	12(r11)
	calls	$2,_putctl
L116:
	jbr	L108
L107:
	.stabs	"d",0x80,0,4,4
	.stabs	"size",0x40,0,4,6
	.stabs	"type",0x40,0,4,7
	.stabs	"mp",0x40,0,40,8
	.stabs	"hbp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L103:
	ret
	.set	L.R7,0xfc0
	.set	L.SO7,0x4
L117:	.data
	.text
	.align	2
	.globl	_msdtocput
_msdtocput:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"msdtocput",0x24,0,188,_msdtocput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movzbl	20(r10),r0
	jbr	L120
L121:
	pushl	r10
	calls	$1,_freeb
	jbr	L118
L122:
	pushl	$1
	bitw	$16,26(r11)
	jeql	L124
	addl3	$28,r11,-(sp)
	jbr	L125
L124:
	subl3	$28,r11,-(sp)
L125:
	calls	$2,_flushq
L126:
L127:
L128:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L118
L129:
L130:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	pushl	r11
	calls	$1,_qenable
	jbr	L118
L120:
	cmpl	r0,$0
	jeql	L129
	cmpl	r0,$2
	jeql	L128
	cmpl	r0,$6
	jeql	L130
	cmpl	r0,$66
	jeql	L122
	cmpl	r0,$69
	jeql	L126
	cmpl	r0,$70
	jeql	L127
	jbr	L121
L119:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L118:
	ret
	.set	L.R8,0xc00
	.set	L.SO8,0x0
L131:	.data
	.text
	.align	2
	.globl	_msdtocsrv
_msdtocsrv:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"msdtocsrv",0x24,0,213,_msdtocsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r9
L135:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L136
	jbr	L132
L136:
	tstw	2(r9)
	jneq	L137
	pushl	$1
	pushl	$0
	pushl	$4
	pushl	r11
	calls	$4,_msgcollect
	movl	r0,r10
	tstl	r10
	jneq	L138
	jbr	L132
L138:
	movl	4(r10),r0
	movzbw	2(r0),2(r9)
	movl	4(r10),r0
	movzbl	3(r0),r0
	ashl	$8,r0,r1
	movw	r1,r0
	addw2	r0,2(r9)
	movb	*4(r10),(r9)
	cmpb	(r9),$9
	jneq	L139
	clrb	(r9)
L139:
	tstw	2(r9)
	jgeq	L140
	clrw	2(r9)
L140:
	tstw	2(r9)
	jneq	L141
	movb	(r9),20(r10)
	movl	8(r10),4(r10)
	cmpb	20(r10),$3
	jneq	L142
	tstl	4(r9)
	jeql	L143
	pushl	r10
	calls	$1,_freeb
	movl	4(r9),r10
	clrl	4(r9)
	bisb2	$128,21(r10)
L143:
	clrb	20(r10)
	bisb2	$128,21(r10)
	jbr	L144
L142:
	cmpb	20(r10),$10
	jneq	L145
	bisw2	$128,26(r11)
	jbr	L146
L145:
	cmpb	20(r10),$11
	jneq	L147
	bicw2	$-65408,26(r11)
L147:
L146:
L144:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L133
L141:
	pushl	r10
	calls	$1,_freeb
L137:
	pushl	$0
	tstb	(r9)
	jneq	L148
	movl	$1,-(sp)
	jbr	L149
L148:
	clrl	-(sp)
L149:
	cvtwl	2(r9),-(sp)
	pushl	r11
	calls	$4,_msgcollect
	movl	r0,r10
	tstl	r10
	jneq	L150
	jbr	L132
L150:
	tstl	4(r9)
	jeql	L151
	pushl	4(r9)
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	clrl	4(r9)
L151:
	movb	(r9),20(r10)
	cmpb	20(r10),$3
	jneq	L152
	clrb	20(r10)
	bisb2	$128,21(r10)
L152:
	subw3	4(r10),8(r10),r0
	subw2	r0,2(r9)
	tstb	20(r10)
	jneq	L153
	bitb	$128,21(r10)
	jneq	L153
L155:
	bitw	$128,26(r11)
	jeql	L153
L154:
	movl	r10,4(r9)
	jbr	L156
L153:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L156:
L133:
	jbr	L135
L134:
	.stabs	"mp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L132:
	ret
	.set	L.R9,0xe00
	.set	L.SO9,0x0
L157:	.data
	.comm	_ms_badmag,4
	.text
	.align	2
	.globl	_msgcollect
_msgcollect:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"msgcollect",0x24,0,278,_msgcollect
	.stabs	"q",0xa0,0,40,4
	.stabs	"size",0xa0,0,4,8
	.stabs	"isdata",0xa0,0,4,12
	.stabs	"findmag",0xa0,0,4,16
	movl	4(ap),r11
	movl	20(r11),r7
	tstl	16(ap)
	jneq	L160
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L161
	clrl	r0
	jbr	L159
L161:
	jbr	L162
L160:
	jbr	L164
L165:
	tstb	20(r9)
	jeql	L166
	cmpb	20(r9),$6
	jneq	L167
	bisb2	$16,1(r7)
L167:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L164
L166:
	jbr	L169
L170:
	movl	4(r9),r0
	movzbl	1(r0),r0
	cmpl	r0,$229
	jneq	L171
	jbr	L172
L171:
	incl	4(r9)
	incl	_ms_badmag
L169:
	subl3	$1,8(r9),r0
	cmpl	4(r9),r0
	jlssu	L170
L168:
	pushl	r9
	calls	$1,_freeb
L164:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L165
L163:
	tstl	r9
	jneq	L173
	clrl	r0
	jbr	L159
L173:
L162:
L172:
	pushl	8(ap)
	calls	$1,_allocb
	movl	r0,r10
	tstl	r10
	jneq	L174
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	clrl	r0
	jbr	L159
L174:
	subl3	8(r10),12(r10),r0
	cmpl	8(ap),r0
	jleq	L175
	subl3	8(r10),12(r10),8(ap)
L175:
	jbr	L177
L178:
	tstb	20(r9)
	jeql	L179
	cmpb	20(r9),$6
	jneq	L180
	bisb2	$16,1(r7)
L180:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L181
	jbr	L176
L181:
	jbr	L177
L179:
	subl3	4(r9),8(r9),r8
	cmpl	r8,8(ap)
	jleq	L182
	pushl	8(ap)
	pushl	8(r10)
	pushl	4(r9)
	calls	$3,_bcopy
	addl2	8(ap),8(r10)
	addl2	8(ap),4(r9)
	clrl	8(ap)
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L176
L182:
	pushl	r8
	pushl	8(r10)
	pushl	4(r9)
	calls	$3,_bcopy
	subl2	r8,8(ap)
	addl2	r8,8(r10)
	pushl	r9
	calls	$1,_freeb
	tstl	8(ap)
	jneq	L184
	jbr	L176
L184:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L185
	jbr	L176
L185:
L177:
	tstl	8(ap)
	jneq	L178
L176:
	cmpl	4(r10),8(r10)
	jlssu	L186
	pushl	r10
	calls	$1,_freeb
	clrl	r0
	jbr	L159
L186:
	tstl	8(ap)
	jeql	L188
	tstl	12(ap)
	jeql	L187
L188:
	movl	r10,r0
	jbr	L159
L187:
	pushl	r10
	pushl	r11
	calls	$2,_putbq
	clrl	r0
	jbr	L159
	.stabs	"mp",0x40,0,40,7
	.stabs	"ninb",0x40,0,4,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"nbp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L159:
	ret
	.set	L.R10,0xf80
	.set	L.SO10,0x0
L189:	.data
	.text
L190:	.stabs	"mesg.c",0x94,0,352,L190
