L11:	.stabs	"archosld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553298
	.data
	.comm	_nswdevt,4
	.align	2
_adkrinit:
	.long	_adkiput
	.long	_adkisrv
	.long	_adkopen
	.long	_adkclose
	.long	0x240048
	.align	2
_adkwinit:
	.long	_adkoput
	.long	_adkosrv
	.long	_adkopen
	.long	_nulldev
	.long	0x240048
	.align	2
	.globl	_adkstream
_adkstream:
	.long	_adkrinit
	.long	_adkwinit
	.comm	_adk,384
	.text
	.align	2
	.globl	_adkopen
_adkopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"adkopen",0x24,0,65,_adkopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	.data
	.align	2
L59:
	.long	0
	.text
	pushl	8(ap)
	calls	$1,_getdkmod
	movl	r0,r8
	jneq	L60
	clrl	r0
	jbr	L58
L60:
	clrl	r9
	movl	$_adk,r10
	jbr	L63
L64:
	cmpl	(r10),r11
	jneq	L65
	cvtwl	8(r10),r0
	bicl3	$-256,8(ap),r1
	cvtwl	10(r8),r2
	subl2	r2,r1
	cmpl	r0,r1
	jneq	L67
	tstl	48(r11)
	jneq	L66
L67:
	.data	1
L69:

	.byte	0x71,0x20,0x25,0x78,0x20,0x64,0x6b,0x70
	.byte	0x20,0x25,0x78,0xa,0x0
	.text
	pushl	r10
	pushl	r11
	pushl	$L69
	calls	$3,_printf
	.data	1
L71:

	.byte	0x61,0x64,0x6b,0x6f,0x70,0x65,0x6e,0x0
	.text
	pushl	$L71
	calls	$1,_panic
L66:
	movl	$1,r0
	jbr	L58
L65:
	tstl	(r10)
	jneq	L72
	tstl	r9
	jneq	L72
L73:
	movl	r10,r9
L72:
	addl2	$12,r10
L63:
	cmpl	r10,$_adk+384
	jlssu	L64
L62:
	tstl	r9
	jneq	L74
	clrl	r0
	jbr	L58
L74:
	movl	r11,(r9)
	movl	r8,4(r9)
	bicw3	$-256,8(ap),r0
	subw3	10(r8),r0,8(r9)
	bisw2	$128,26(r11)
	clrl	20(r11)
	movl	r9,48(r11)
	tstl	L59
	jneq	L75
	calls	$0,_adktimer
	movl	$1,L59
L75:
	movl	$1,r0
	jbr	L58
	.stabs	"dkm",0x40,0,40,8
	.stabs	"edkp",0x40,0,40,9
	.stabs	"dkp",0x40,0,40,10
	.stabs	"timer_on",0x26,0,4,L59
	.stabs	"q",0x40,0,40,11
L58:
	ret
	.set	L.R1,0xf00
	.set	L.SO1,0x0
L77:	.data
	.text
	.align	2
	.globl	_adkclose
_adkclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"adkclose",0x24,0,101,_adkclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	48(r11),r9
	addl3	$28,r11,r0
	movl	4(r9),r1
	cmpl	r0,4(r1)
	jneq	L79
	movl	4(r9),r0
	clrl	4(r0)
	movl	4(r9),r0
	clrw	14(r0)
L79:
	jbr	L81
L82:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L81:
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L82
L80:
	clrl	(r9)
	clrl	4(r9)
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L78:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L83:	.data
	.text
	.align	2
	.globl	_adkoput
_adkoput:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"adkoput",0x24,0,121,_adkoput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	movl	4(r9),r8
	movzbl	20(r10),r0
	jbr	L86
L87:
	movzbl	*4(r10),r0
	movl	4(r10),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl2	r1,r0
	jbr	L89
L90:
	cmpl	r11,4(r8)
	jneq	L91
	pushl	$1
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r8
	calls	$6,_adkmesg
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L84
L91:
	jbr	L88
L94:
	tstl	4(r8)
	jneq	L95
	movl	r11,4(r8)
	bisw2	$64,-2(r11)
	movw	$99,14(r8)
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r8
	calls	$6,_adkmesg
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L84
L95:
	jbr	L88
L96:
	movl	$1,-8(r11)
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L84
L97:
	cvtwl	10(r8),r0
	addl3	$3,r0,r7
	jbr	L100
L101:
	addl3	(r8),r7,r0
	tstb	(r0)
	jneq	L102
	movl	4(r10),r0
	movb	r7,4(r0)
	movl	$1,r7
	jbr	L105
L106:
	addl3	$4,4(r10),r0
	addl2	r7,r0
	clrb	(r0)
	incl	r7
L105:
	cmpl	r7,$4
	jlssu	L106
L104:
	addl3	$8,4(r10),8(r10)
	movb	$69,20(r10)
	jbr	L99
L102:
	addl2	$2,r7
L100:
	cvtwl	12(r8),r0
	cmpl	r7,r0
	jlss	L101
L99:
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L84
L107:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L84
L89:
	casel	r0,$25632,$7
L108:
	.word	L94-L108
	.word	L90-L108
	.word	L107-L108
	.word	L107-L108
	.word	L107-L108
	.word	L107-L108
	.word	L97-L108
	.word	L96-L108
	jbr	L107
L88:
	movb	$70,20(r10)
	movl	4(r10),8(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L84
L86:
	cmpl	r0,$6
	jeql	L87
L85:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	.stabs	"i",0x40,0,4,7
	.stabs	"modp",0x40,0,40,8
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L84:
	ret
	.set	L.R3,0xf80
	.set	L.SO3,0x0
L109:	.data
	.text
	.align	2
	.globl	_adkosrv
_adkosrv:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"adkosrv",0x24,0,194,_adkosrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	jbr	L112
L113:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L112:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L114
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L113
L114:
L111:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L110:
	ret
	.set	L.R4,0xc00
	.set	L.SO4,0x0
L115:	.data
	.text
	.align	2
	.globl	_adkiput
_adkiput:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"adkiput",0x24,0,208,_adkiput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	48(r11),r9
	movzbl	20(r10),r0
	jbr	L118
L119:
	addl3	$28,r11,r0
	movl	4(r9),r1
	cmpl	r0,4(r1)
	jneq	L120
	movzbl	21(r10),r0
	bicl3	$-129,r0,r8
	pushl	r10
	pushl	r11
	calls	$2,_putq
	tstl	r8
	jeql	L121
	pushl	r11
	calls	$1,_qenable
L121:
	jbr	L116
L120:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L123
	pushl	r10
	calls	$1,_freeb
	jbr	L116
L123:
	tstl	20(r11)
	jeql	L125
	pushl	r10
	pushl	r11
	calls	$2,_putq
	jbr	L116
L125:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L116
L126:
L127:
L128:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L116
L129:
	movzbl	*4(r10),r0
	jbr	L131
L132:
	movl	4(r10),r0
	movzbl	1(r0),r0
	addl2	*4(r9),r0
	cmpb	(r0),$1
	jneq	L133
	pushl	$0
	movl	4(r10),r0
	movzbl	1(r0),-(sp)
	pushl	$0
	pushl	$2
	pushl	$3
	pushl	4(r9)
	calls	$6,_adkmesg
	jbr	L134
L133:
	pushl	$0
	movl	4(r10),r0
	movzbl	1(r0),-(sp)
	pushl	$0
	pushl	$1
	pushl	$3
	pushl	4(r9)
	calls	$6,_adkmesg
L134:
	pushl	r10
	calls	$1,_freeb
	jbr	L116
L135:
	pushl	r10
	calls	$1,_freeb
	jbr	L116
L131:
	cmpl	r0,$0
	jeql	L132
	jbr	L135
L130:
L136:
	pushl	r10
	calls	$1,_freeb
	jbr	L117
L118:
	cmpl	r0,$0
	jeql	L119
	cmpl	r0,$2
	jeql	L128
	cmpl	r0,$69
	jeql	L126
	cmpl	r0,$70
	jeql	L127
	cmpl	r0,$71
	jeql	L129
	jbr	L136
L117:
	.stabs	"delim",0x40,0,4,8
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L116:
	ret
	.set	L.R5,0xf00
	.set	L.SO5,0x0
L137:	.data
	.text
	.align	2
	.globl	_adkmesg
_adkmesg:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"adkmesg",0x24,0,265,_adkmesg
	.stabs	"modp",0xa0,0,40,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"srv",0xa0,0,4,12
	.stabs	"p0",0xa0,0,4,16
	.stabs	"p1",0xa0,0,4,20
	.stabs	"p2",0xa0,0,4,24
	movl	4(ap),r11
	tstl	4(r11)
	jeql	L140
	movl	4(r11),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L139
L140:
	jbr	L138
L139:
	pushl	$16
	calls	$1,_allocb
	movl	r0,r9
	jneq	L141
	jbr	L138
L141:
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
L138:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x0
L142:	.data
	.text
	.align	2
	.globl	_adkdialin
_adkdialin:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"adkdialin",0x24,0,291,_adkdialin
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	subl3	4(r10),8(r10),r8
	cmpl	r8,$14
	jneq	L145
	movl	r10,r0
	jbr	L144
L145:
	subl3	r8,$14,r6
	movzbl	21(r10),r0
	bicl3	$-129,r0,r7
	subl3	4(r10),12(r10),r0
	cmpl	r0,$14
	jlssu	L146
	movl	r10,r9
	jbr	L147
L146:
	pushl	$14
	calls	$1,_allocb
	movl	r0,r9
	jneq	L148
	pushl	r10
	calls	$1,_freeb
	clrl	r0
	jbr	L144
L148:
	pushl	r8
	pushl	8(r9)
	pushl	4(r10)
	calls	$3,_bcopy
	addl2	r8,8(r9)
	pushl	r10
	calls	$1,_freeb
L147:
	clrl	-4(fp)
	jbr	L151
L152:
	subl3	4(r10),8(r10),r0
	cmpl	r0,r6
	jgtr	L153
	subl3	4(r10),8(r10),r0
	jbr	L154
L153:
	movl	$1,-4(fp)
	movl	r6,r0
L154:
	movl	r0,r8
	pushl	r8
	pushl	8(r9)
	pushl	4(r10)
	calls	$3,_bcopy
	addl2	r8,8(r9)
	subl2	r8,r6
	movzbl	21(r10),r0
	bicl3	$-129,r0,r7
	pushl	r10
	calls	$1,_freeb
L151:
	tstl	r7
	jneq	L155
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L152
L155:
L150:
	tstl	r6
	jneq	L156
	tstl	-4(fp)
	jneq	L156
L158:
	tstl	r7
	jeql	L156
L157:
	movl	r9,r0
	jbr	L144
L156:
	pushl	r9
	calls	$1,_freeb
	clrl	r0
	jbr	L144
	.stabs	"over",0x80,0,4,4
	.stabs	"n",0x40,0,4,6
	.stabs	"delim",0x40,0,4,7
	.stabs	"len",0x40,0,4,8
	.stabs	"nbp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L144:
	ret
	.set	L.R7,0xfc0
	.set	L.SO7,0x4
L159:	.data
	.text
	.align	2
	.globl	_adkisrv
_adkisrv:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"adkisrv",0x24,0,334,_adkisrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	48(r11),r10
	movl	4(r10),-4(fp)
	movl	-4(fp),r0
	movl	4(r0),r9
	addl3	$28,r11,r0
	movl	-4(fp),r1
	cmpl	r0,4(r1)
	jeql	L161
	jbr	L160
L161:
	jbr	L163
L164:
	movzbl	*4(r8),r0
	jbr	L166
L167:
	incl	4(r8)
	subl3	4(r8),8(r8),r0
	jgtr	L168
	bitb	$128,21(r8)
	jeql	L170
	pushl	r11
	calls	$1,_getq
	movl	r0,r8
	jneq	L168
L170:
L169:
	jbr	L160
L168:
L173:
	movzbl	21(r8),r0
	bicl3	$-129,r0,r6
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L174
	pushl	r8
	calls	$1,_free
	jbr	L176
L174:
	pushl	r8
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L176:
L172:
	tstl	r6
	jneq	L177
	pushl	r11
	calls	$1,_getq
	movl	r0,r8
	jneq	L173
L177:
L171:
	jbr	L165
L178:
	pushl	r8
	pushl	r11
	calls	$2,_adkdialin
	movl	r0,r8
	jneq	L179
	jbr	L165
L179:
	movl	4(r8),r7
	cvtwl	4(r7),r6
	tstl	r6
	jleq	L181
	movl	-4(fp),r0
	cvtwl	12(r0),r0
	movl	-4(fp),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r6,r0
	jlss	L180
L181:
	incl	_dkstat+36
	tstb	1(r7)
	jeql	L182
	pushl	$0
	pushl	r6
	pushl	$0
	pushl	$2
	pushl	$3
	pushl	-4(fp)
	calls	$6,_adkmesg
L182:
	pushl	r8
	calls	$1,_freeb
	jbr	L165
L180:
	cvtbl	1(r7),r0
	jbr	L184
L185:
	addl3	*-4(fp),r6,r0
	cvtbl	(r0),r0
	jbr	L187
L188:
	incl	_dkstat+40
L189:
	pushl	r6
	pushl	$0
	pushl	$71
	pushl	12(r9)
	calls	$4,_putctl2
	jbr	L186
L191:
L192:
	pushl	$0
	pushl	r6
	pushl	$0
	pushl	$2
	pushl	$3
	pushl	-4(fp)
	calls	$6,_adkmesg
	pushl	r6
	pushl	$0
	pushl	$71
	pushl	12(r9)
	calls	$4,_putctl2
	jbr	L186
L187:
	casel	r0,$0,$3
L193:
	.word	L192-L193
	.word	L188-L193
	.word	L191-L193
	.word	L189-L193
L194:
L186:
	jbr	L183
L195:
	addl3	*-4(fp),r6,r0
	cvtbl	(r0),r0
	jbr	L197
L198:
L199:
	pushl	r6
	pushl	$0
	pushl	$71
	pushl	12(r9)
	calls	$4,_putctl2
	jbr	L196
L200:
L201:
	incl	_dkstat+44
	jbr	L196
L197:
	casel	r0,$0,$3
L202:
	.word	L199-L202
	.word	L201-L202
	.word	L198-L202
	.word	L200-L202
L203:
L196:
	jbr	L183
L204:
	addl3	*-4(fp),r6,r0
	cvtbl	(r0),-(sp)
	pushl	r6
	pushl	$0
	pushl	$4
	pushl	$3
	pushl	-4(fp)
	calls	$6,_adkmesg
	jbr	L183
L184:
	casel	r0,$1,$2
L205:
	.word	L185-L205
	.word	L195-L205
	.word	L204-L205
L206:
L183:
	pushl	r8
	calls	$1,_freeb
	jbr	L165
L207:
	pushl	r8
	pushl	r11
	calls	$2,_adkdialin
	movl	r0,r8
	jneq	L208
	jbr	L165
L208:
	movl	4(r8),r7
	cvtwl	2(r7),r6
	tstl	r6
	jlss	L210
	movl	-4(fp),r0
	cvtwl	12(r0),r0
	movl	-4(fp),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r6,r0
	jlss	L209
L210:
	pushl	r8
	calls	$1,_free
	jbr	L165
L209:
	movl	$_adk,r10
	jbr	L213
L214:
	cmpl	4(r10),-4(fp)
	jneq	L215
	cvtwl	8(r10),r0
	cmpl	r0,r6
	jneq	L215
L216:
	bisb2	$128,21(r8)
	pushl	r8
	movl	(r10),r0
	pushl	12(r0)
	movl	(r10),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L212
L215:
	addl2	$12,r10
L213:
	cmpl	r10,$_adk+384
	jlssu	L214
L212:
	cmpl	r10,$_adk+384
	jneq	L217
	pushl	r8
	calls	$1,_free
L217:
	jbr	L165
L218:
	pushl	r8
	calls	$1,_free
	jbr	L165
L166:
	cmpl	r0,$3
	jeql	L178
	cmpl	r0,$10
	jeql	L207
	cmpl	r0,$48
	jeql	L167
	jbr	L218
L165:
L163:
	pushl	r11
	calls	$1,_getq
	movl	r0,r8
	jneq	L164
L162:
	.stabs	"i",0x40,0,4,6
	.stabs	"dialp",0x40,0,40,7
	.stabs	"bp",0x40,0,40,8
	.stabs	"listnrq",0x40,0,40,9
	.stabs	"modp",0x80,0,40,4
	.stabs	"dkp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L160:
	ret
	.set	L.R8,0xfc0
	.set	L.SO8,0x4
L219:	.data
	.text
	.align	2
	.globl	_adktimer
_adktimer:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"adktimer",0x24,0,448,_adktimer
	movl	$_dkmod,r10
	jbr	L223
L224:
	tstl	4(r10)
	jeql	L225
	cmpw	14(r10),$99
	jneq	L225
L226:
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r10
	calls	$6,_adkmesg
	cvtwl	12(r10),r0
	cvtwl	10(r10),r1
	subl2	r1,r0
	subl3	$1,r0,r11
	jbr	L229
L230:
	addl3	(r10),r11,r0
	cmpb	(r0),$2
	jneq	L231
	pushl	$0
	pushl	r11
	pushl	$0
	pushl	$1
	pushl	$3
	pushl	r10
	calls	$6,_adkmesg
L231:
	decl	r11
L229:
	tstl	r11
	jgeq	L230
L228:
L225:
	addl2	$16,r10
L223:
	addl3	_dkmodcnt,_dkmodcnt,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	$_dkmod,r0
	cmpl	r10,r0
	jlssu	L224
L222:
	pushl	$900
	pushl	$0
	pushl	$_adktimer
	calls	$3,_timeout
	.stabs	"dkp",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L220:
	ret
	.set	L.R9,0xc00
	.set	L.SO9,0x0
L233:	.data
	.stabs	"adkwinit",0x26,0,8,_adkwinit
	.stabs	"adkrinit",0x26,0,8,_adkrinit
	.text
L234:	.stabs	"archosld.c",0x94,0,462,L234
