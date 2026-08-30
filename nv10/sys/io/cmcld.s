L11:	.stabs	"cmcld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553093
	.data
	.comm	_nswdevt,4
	.align	2
_rdkrinit:
	.long	_rdkiput
	.long	0
	.long	_rdkopen
	.long	_rdkclose
	.long	0x240048
	.align	2
_rdkwinit:
	.long	_rdkoput
	.long	_rdkosrv
	.long	_rdkopen
	.long	_nulldev
	.long	0x240048
	.align	2
	.globl	_rdkstream
_rdkstream:
	.long	_rdkrinit
	.long	_rdkwinit
	.comm	_rdk,384
	.text
	.align	2
	.globl	_rdkopen
_rdkopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"rdkopen",0x24,0,64,_rdkopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	.data
	.align	2
L58:
	.long	0
	.text
	pushl	8(ap)
	calls	$1,_getdkmod
	movl	r0,r8
	jneq	L59
	clrl	r0
	jbr	L57
L59:
	clrl	r9
	movl	$_rdk,r10
	jbr	L62
L63:
	cmpl	(r10),r11
	jneq	L64
	cvtwl	8(r10),r0
	bicl3	$-256,8(ap),r1
	cvtwl	10(r8),r2
	subl2	r2,r1
	cmpl	r0,r1
	jneq	L66
	tstl	48(r11)
	jneq	L65
L66:
	.data	1
L68:

	.byte	0x71,0x20,0x25,0x78,0x20,0x64,0x6b,0x70
	.byte	0x20,0x25,0x78,0xa,0x0
	.text
	pushl	r10
	pushl	r11
	pushl	$L68
	calls	$3,_printf
	.data	1
L70:

	.byte	0x72,0x64,0x6b,0x6f,0x70,0x65,0x6e,0x0
	.text
	pushl	$L70
	calls	$1,_panic
L65:
	movl	$1,r0
	jbr	L57
L64:
	tstl	(r10)
	jneq	L71
	tstl	r9
	jneq	L71
L72:
	movl	r10,r9
L71:
	addl2	$12,r10
L62:
	cmpl	r10,$_rdk+384
	jlssu	L63
L61:
	tstl	r9
	jneq	L73
	clrl	r0
	jbr	L57
L73:
	movl	r11,(r9)
	movl	r8,4(r9)
	bicw3	$-256,8(ap),r0
	subw3	10(r8),r0,8(r9)
	bisw2	$128,26(r11)
	clrl	20(r11)
	movl	r9,48(r11)
	tstl	L58
	jneq	L74
	calls	$0,_dktimer
	movl	$1,L58
L74:
	movl	$1,r0
	jbr	L57
	.stabs	"dkm",0x40,0,40,8
	.stabs	"edkp",0x40,0,40,9
	.stabs	"dkp",0x40,0,40,10
	.stabs	"timer_on",0x26,0,4,L58
	.stabs	"q",0x40,0,40,11
L57:
	ret
	.set	L.R1,0xf00
	.set	L.SO1,0x0
L76:	.data
	.text
	.align	2
	.globl	_rdkclose
_rdkclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"rdkclose",0x24,0,100,_rdkclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	48(r11),r9
	addl3	$28,r11,r0
	movl	4(r9),r1
	cmpl	r0,4(r1)
	jneq	L78
	movl	4(r9),r0
	clrl	4(r0)
	movl	4(r9),r0
	clrw	14(r0)
L78:
	jbr	L80
L81:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L80:
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L81
L79:
	clrl	(r9)
	clrl	4(r9)
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L77:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L82:	.data
	.text
	.align	2
	.globl	_rdkoput
_rdkoput:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"rdkoput",0x24,0,120,_rdkoput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	movl	4(r9),r8
	movzbl	20(r10),r0
	jbr	L85
L86:
	movzbl	*4(r10),r0
	movl	4(r10),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl2	r1,r0
	jbr	L88
L89:
	cmpl	r11,4(r8)
	jneq	L90
	pushl	$1
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r8
	calls	$6,_dkmesg
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L83
L90:
	jbr	L87
L93:
	tstl	4(r8)
	jneq	L94
	movl	r11,4(r8)
	movw	$99,14(r8)
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r8
	calls	$6,_dkmesg
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L83
L94:
	jbr	L87
L95:
	movl	$1,-8(r11)
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L83
L96:
	cvtwl	10(r8),r0
	addl3	$3,r0,r7
	jbr	L99
L100:
	addl3	(r8),r7,r0
	tstb	(r0)
	jneq	L101
	movl	4(r10),r0
	movb	r7,4(r0)
	movl	$1,r7
	jbr	L104
L105:
	addl3	$4,4(r10),r0
	addl2	r7,r0
	clrb	(r0)
	incl	r7
L104:
	cmpl	r7,$4
	jlssu	L105
L103:
	addl3	$8,4(r10),8(r10)
	movb	$69,20(r10)
	jbr	L98
L101:
	addl2	$2,r7
L99:
	cvtwl	12(r8),r0
	cmpl	r7,r0
	jlss	L100
L98:
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L83
L106:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L83
L88:
	casel	r0,$25632,$7
L107:
	.word	L93-L107
	.word	L89-L107
	.word	L106-L107
	.word	L106-L107
	.word	L106-L107
	.word	L106-L107
	.word	L96-L107
	.word	L95-L107
	jbr	L106
L87:
	movb	$70,20(r10)
	movl	4(r10),8(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L83
L85:
	cmpl	r0,$6
	jeql	L86
L84:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	.stabs	"i",0x40,0,4,7
	.stabs	"modp",0x40,0,40,8
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L83:
	ret
	.set	L.R3,0xf80
	.set	L.SO3,0x0
L108:	.data
	.text
	.align	2
	.globl	_rdkosrv
_rdkosrv:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"rdkosrv",0x24,0,192,_rdkosrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	jbr	L111
L112:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L111:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L113
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L112
L113:
L110:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L109:
	ret
	.set	L.R4,0xc00
	.set	L.SO4,0x0
L114:	.data
	.text
	.align	2
	.globl	_rdkiput
_rdkiput:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"rdkiput",0x24,0,206,_rdkiput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	48(r11),r9
	movzbl	20(r10),r0
	jbr	L117
L118:
	addl3	$28,r11,r0
	movl	4(r9),r1
	cmpl	r0,4(r1)
	jneq	L120
	pushl	r10
	pushl	4(r9)
	calls	$2,_dklstnr
	tstl	r0
	jeql	L120
L121:
	jbr	L115
L120:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L122
	pushl	r10
	calls	$1,_freeb
	jbr	L115
L122:
	bisb2	$128,21(r10)
	tstl	20(r11)
	jeql	L124
	pushl	r10
	pushl	r11
	calls	$2,_putq
	jbr	L115
L124:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L115
L125:
L126:
L127:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L115
L128:
	movzbl	*4(r10),r0
	jbr	L130
L131:
	movl	4(r10),r0
	movzbl	1(r0),r0
	addl2	*4(r9),r0
	cmpb	(r0),$1
	jneq	L132
	pushl	$0
	movl	4(r10),r0
	movzbl	1(r0),-(sp)
	pushl	$0
	pushl	$2
	pushl	$3
	pushl	4(r9)
	calls	$6,_dkmesg
	jbr	L133
L132:
	pushl	$0
	movl	4(r10),r0
	movzbl	1(r0),-(sp)
	pushl	$0
	pushl	$1
	pushl	$3
	pushl	4(r9)
	calls	$6,_dkmesg
L133:
	pushl	r10
	calls	$1,_freeb
	jbr	L115
L134:
	pushl	r10
	calls	$1,_freeb
	jbr	L115
L130:
	cmpl	r0,$0
	jeql	L131
	jbr	L134
L129:
L135:
	pushl	r10
	calls	$1,_freeb
	jbr	L116
L117:
	cmpl	r0,$0
	jeql	L118
	cmpl	r0,$2
	jeql	L127
	cmpl	r0,$69
	jeql	L125
	cmpl	r0,$70
	jeql	L126
	cmpl	r0,$71
	jeql	L128
	jbr	L135
L116:
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L115:
	ret
	.set	L.R5,0xe00
	.set	L.SO5,0x0
L136:	.data
	.text
	.align	2
	.globl	_dkmesg
_dkmesg:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"dkmesg",0x24,0,257,_dkmesg
	.stabs	"modp",0xa0,0,40,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"srv",0xa0,0,4,12
	.stabs	"p0",0xa0,0,4,16
	.stabs	"p1",0xa0,0,4,20
	.stabs	"p2",0xa0,0,4,24
	movl	4(ap),r11
	tstl	4(r11)
	jeql	L139
	movl	4(r11),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L138
L139:
	jbr	L137
L138:
	pushl	$16
	calls	$1,_allocb
	movl	r0,r9
	jneq	L140
	jbr	L137
L140:
	movl	8(r9),r10
	movl	4(r11),r0
	movl	20(r0),r0
	movw	8(r0),(r10)
	movb	8(ap),2(r10)
	movb	12(ap),3(r10)
	movw	16(ap),4(r10)
	movw	20(ap),6(r10)
	movw	24(ap),8(r10)
	addl2	$16,8(r9)
	bisb2	$128,21(r9)
	pushl	r9
	movl	4(r11),r0
	pushl	12(r0)
	movl	4(r11),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	.stabs	"bp",0x40,0,40,9
	.stabs	"dp",0x40,0,40,10
	.stabs	"modp",0x40,0,40,11
L137:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x0
L141:	.data
	.text
	.align	2
	.globl	_dklstnr
_dklstnr:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"dklstnr",0x24,0,283,_dklstnr
	.stabs	"modp",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	8(ap),r11
	movl	4(ap),r0
	movl	4(r0),r8
	movl	4(r11),r10
	cvtbl	(r10),r0
	jbr	L144
L145:
	cvtwl	4(r10),r9
	tstl	r9
	jleq	L147
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r9,r0
	jlss	L146
L147:
	incl	_dkstat+36
	tstb	1(r10)
	jeql	L148
	pushl	$0
	pushl	r9
	pushl	$0
	pushl	$2
	pushl	$3
	pushl	4(ap)
	calls	$6,_dkmesg
L148:
	pushl	r11
	calls	$1,_freeb
	movl	$1,r0
	jbr	L142
L146:
	cvtbl	1(r10),r0
	jbr	L150
L151:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),r0
	jbr	L153
L154:
	incl	_dkstat+40
L155:
	pushl	r9
	pushl	$0
	pushl	$71
	pushl	12(r8)
	calls	$4,_putctl2
	jbr	L152
L157:
L158:
	pushl	$0
	pushl	r9
	pushl	$0
	pushl	$2
	pushl	$3
	pushl	4(ap)
	calls	$6,_dkmesg
	pushl	r9
	pushl	$0
	pushl	$71
	pushl	12(r8)
	calls	$4,_putctl2
	jbr	L152
L153:
	casel	r0,$0,$3
L159:
	.word	L158-L159
	.word	L154-L159
	.word	L157-L159
	.word	L155-L159
L160:
L152:
	jbr	L149
L161:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),r0
	jbr	L163
L164:
L165:
	pushl	r9
	pushl	$0
	pushl	$71
	pushl	12(r8)
	calls	$4,_putctl2
	jbr	L162
L166:
L167:
	incl	_dkstat+44
	jbr	L162
L163:
	casel	r0,$0,$3
L168:
	.word	L165-L168
	.word	L167-L168
	.word	L164-L168
	.word	L166-L168
L169:
L162:
	jbr	L149
L170:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),-(sp)
	pushl	r9
	pushl	$0
	pushl	$4
	pushl	$3
	pushl	4(ap)
	calls	$6,_dkmesg
	jbr	L149
L150:
	casel	r0,$1,$2
L171:
	.word	L151-L171
	.word	L161-L171
	.word	L170-L171
L172:
L149:
	pushl	r11
	calls	$1,_freeb
	movl	$1,r0
	jbr	L142
L173:
	cvtwl	2(r10),r9
	tstl	r9
	jlss	L175
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r9,r0
	jlss	L174
L175:
	clrl	r0
	jbr	L142
L174:
	movl	$_rdk,r7
	jbr	L178
L179:
	cmpl	4(r7),4(ap)
	jneq	L180
	cvtwl	8(r7),r0
	cmpl	r0,r9
	jneq	L180
L181:
	bisb2	$128,21(r11)
	pushl	r11
	movl	(r7),r0
	pushl	12(r0)
	movl	(r7),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	movl	$1,r0
	jbr	L142
L180:
	addl2	$12,r7
L178:
	cmpl	r7,$_rdk+384
	jlssu	L179
L177:
	clrl	r0
	jbr	L142
L182:
	clrl	r0
	jbr	L142
L144:
	casel	r0,$3,$7
L183:
	.word	L145-L183
	.word	L182-L183
	.word	L182-L183
	.word	L182-L183
	.word	L182-L183
	.word	L182-L183
	.word	L182-L183
	.word	L173-L183
	jbr	L182
L143:
	.stabs	"dkp",0x40,0,40,7
	.stabs	"listnrq",0x40,0,40,8
	.stabs	"i",0x40,0,4,9
	.stabs	"dialp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L142:
	ret
	.set	L.R7,0xf80
	.set	L.SO7,0x0
L184:	.data
	.text
	.align	2
	.globl	_dktimer
_dktimer:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"dktimer",0x24,0,366,_dktimer
	movl	$_dkmod,r10
	jbr	L188
L189:
	tstl	4(r10)
	jeql	L190
	cmpw	14(r10),$99
	jneq	L190
L191:
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r10
	calls	$6,_dkmesg
	cvtwl	12(r10),r0
	cvtwl	10(r10),r1
	subl2	r1,r0
	subl3	$1,r0,r11
	jbr	L194
L195:
	addl3	(r10),r11,r0
	cmpb	(r0),$2
	jneq	L196
	pushl	$0
	pushl	r11
	pushl	$0
	pushl	$1
	pushl	$3
	pushl	r10
	calls	$6,_dkmesg
L196:
	decl	r11
L194:
	tstl	r11
	jgeq	L195
L193:
L190:
	addl2	$16,r10
L188:
	addl3	_dkmodcnt,_dkmodcnt,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	$_dkmod,r0
	cmpl	r10,r0
	jlssu	L189
L187:
	pushl	$900
	pushl	$0
	pushl	$_dktimer
	calls	$3,_timeout
	.stabs	"dkp",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L185:
	ret
	.set	L.R8,0xc00
	.set	L.SO8,0x0
L198:	.data
	.stabs	"rdkwinit",0x26,0,8,_rdkwinit
	.stabs	"rdkrinit",0x26,0,8,_rdkrinit
	.text
L199:	.stabs	"cmcld.c",0x94,0,380,L199
