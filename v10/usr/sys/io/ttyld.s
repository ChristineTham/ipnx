L11:	.stabs	"ttyld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553095
	.data
	.comm	_nswdevt,4
	.data
	.globl	_maptab
_maptab:
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x7c00
	.long	0x60000000
	.long	0x7d7b
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x0
	.long	0x7e005c
	.long	0x43424100
	.long	0x47464544
	.long	0x4b4a4948
	.long	0x4f4e4d4c
	.long	0x53525150
	.long	0x57565554
	.long	0x5a5958
	.long	0x0
	.data
	.align	2
_ttrinit:
	.long	_ttyldin
	.long	_ttyinsrv
	.long	_ttyopen
	.long	_ttyclose
	.long	0x3c0c00
	.align	2
_ttwinit:
	.long	_putq
	.long	_ttyosrv
	.long	_ttyopen
	.long	_ttyclose
	.long	0xc80c00
	.align	2
	.globl	_ttystream
_ttystream:
	.long	_ttrinit
	.long	_ttwinit
	.text
	.align	2
	.globl	_ttyopen
_ttyopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"ttyopen",0x24,0,47,_ttyopen
	.stabs	"qp",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	.data
L57:
	.long	0x13111c7f
	.long	0xff04
	.text
	tstl	20(r11)
	jeql	L58
	movl	$1,r0
	jbr	L56
L58:
	movl	$_ttyld,r10
	jbr	L61
L62:
	subl3	$1,_ttycnt,r0
	mull2	$14,r0
	addl2	$_ttyld,r0
	cmpl	r10,r0
	jlssu	L63
	clrl	r0
	jbr	L56
L63:
	addl2	$14,r10
L61:
	bitw	$8,2(r10)
	jneq	L62
L60:
	movw	$8,2(r10)
	movw	$24,(r10)
	clrb	4(r10)
	clrb	5(r10)
	movb	$8,6(r10)
	movb	$64,7(r10)
	addl3	$8,r10,r0
	movc3	$6,L57,(r0)
	movl	r10,20(r11)
	bisw2	$192,26(r11)
	movl	r10,48(r11)
	movl	$1,r0
	jbr	L56
	.stabs	"tchars",0x26,0,8,L57
	.stabs	"tp",0x40,0,40,10
	.stabs	"qp",0x40,0,40,11
L56:
	ret
	.set	L.R1,0xc00
	.set	L.SO1,0x0
L64:	.data
	.text
	.align	2
	.globl	_ttyclose
_ttyclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"ttyclose",0x24,0,71,_ttyclose
	.stabs	"qp",0xa0,0,40,4
	movl	4(ap),r0
	movl	20(r0),-4(fp)
	movl	-4(fp),r0
	bitw	$1,2(r0)
	jeql	L66
	pushl	$68
	movl	4(ap),r0
	pushl	40(r0)
	calls	$2,_putctl
L66:
	movl	-4(fp),r0
	clrw	2(r0)
	.stabs	"tp",0x80,0,40,4
L65:
	ret
	.set	L.R2,0x0
	.set	L.SO2,0x4
L68:	.data
	.text
	.align	2
	.globl	_ttyldin
_ttyldin:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"ttyldin",0x24,0,85,_ttyldin
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	8(ap),r11
	addl3	$28,4(ap),r8
	movl	4(ap),r0
	movl	20(r0),r10
	cvtwl	(r10),-8(fp)
	bicb2	$-128,21(r11)
	tstb	20(r11)
	jeql	L70
	movzbl	20(r11),r0
	jbr	L72
L73:
	bitw	$32,(r10)
	jeql	L74
	clrb	20(r11)
	bicb2	$-128,21(r11)
	cmpl	8(r11),12(r11)
	jgequ	L75
	movl	8(r11),r0
	incl	8(r11)
	clrb	(r0)
L75:
	jbr	L71
L74:
	pushl	$2
	pushl	4(ap)
	calls	$2,_ttysig
	pushl	r11
	calls	$1,_freeb
	jbr	L69
L78:
L79:
L80:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L69
L81:
	pushl	$1
	pushl	4(ap)
	pushl	r11
	addl3	$28,4(ap),-(sp)
	calls	$4,_ttldioc
	jbr	L69
L72:
	cmpl	r0,$1
	jeql	L73
	cmpl	r0,$2
	jeql	L78
	cmpl	r0,$6
	jeql	L81
	cmpl	r0,$69
	jeql	L79
	cmpl	r0,$70
	jeql	L80
L71:
	bisl2	$32,-8(fp)
L70:
	bitw	$1,(r10)
	jeql	L83
	bitw	$16,2(r10)
	jeql	L83
L85:
	movl	4(ap),r0
	movl	*4(ap),r1
	cmpw	24(r0),18(r1)
	jgtr	L83
L84:
	bicw2	$16,2(r10)
	cvtbl	10(r10),-(sp)
	addl3	$28,4(ap),-(sp)
	pushl	$_putq
	calls	$3,_putd
L83:
	bitl	$32,-8(fp)
	jeql	L87
	movl	4(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jneq	L88
	movl	4(ap),r0
	tstw	24(r0)
	jneq	L88
L89:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L90
L88:
	pushl	r11
	pushl	4(ap)
	calls	$2,_putq
L90:
	jbr	L69
L87:
	jbr	L92
L93:
	movl	4(r11),r0
	incl	4(r11)
	movzbl	(r0),r0
	bicl3	$-128,r0,r9
	bitw	$1,2(r10)
	jeql	L94
	cvtbl	11(r10),r0
	cmpl	r9,r0
	jneq	L96
	cmpb	11(r10),10(r10)
	jneq	L95
L96:
	bicw2	$1,2(r10)
	pushl	$68
	pushl	12(r8)
	calls	$2,_putctl
L95:
	jbr	L97
L94:
	cvtbl	11(r10),r0
	cmpl	r9,r0
	jneq	L98
	bisw2	$1,2(r10)
	pushl	$67
	pushl	12(r8)
	calls	$2,_putctl
L98:
L97:
	cvtbl	11(r10),r0
	cmpl	r9,r0
	jeql	L100
	cvtbl	10(r10),r0
	cmpl	r9,r0
	jneq	L99
L100:
	jbr	L92
L99:
	cvtbl	8(r10),r0
	cmpl	r9,r0
	jneq	L101
	pushl	$2
	pushl	4(ap)
	calls	$2,_ttysig
	jbr	L92
L101:
	cvtbl	9(r10),r0
	cmpl	r9,r0
	jneq	L102
	pushl	$3
	pushl	4(ap)
	calls	$2,_ttysig
	jbr	L92
L102:
	cmpl	r9,$13
	jneq	L103
	bitw	$16,(r10)
	jeql	L103
L104:
	movl	$10,r9
L103:
	bitw	$4,(r10)
	jeql	L105
	cmpl	r9,$65
	jlss	L105
L107:
	cmpl	r9,$90
	jgtr	L105
L106:
	addl2	$32,r9
L105:
	clrl	-4(fp)
	bitw	$2,(r10)
	jeql	L108
	movl	4(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jneq	L109
	movl	4(ap),r0
	tstw	24(r0)
	jneq	L109
L110:
	pushl	r9
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	pushl	(r1)
	calls	$3,_putd
	jbr	L111
L109:
	pushl	r9
	pushl	4(ap)
	pushl	$_putq
	calls	$3,_putd
L111:
	jbr	L112
L108:
	bitw	$2,2(r10)
	jeql	L113
	movl	$1,-4(fp)
	bisl2	$128,r9
L113:
	cmpl	r9,$92
	jneq	L114
	bisw2	$2,2(r10)
	jbr	L115
L114:
	bicw2	$2,2(r10)
	cmpl	r9,$220
	jneq	L116
	bicl2	$-128,r9
	bisw2	$2,2(r10)
L116:
	movl	4(ap),r0
	bitw	$8,26(r0)
	jeql	L118
	cmpl	r9,$10
	jneq	L117
	tstb	4(r10)
	jneq	L117
L119:
L118:
	pushl	r9
	pushl	4(ap)
	pushl	$_putq
	calls	$3,_putd
	jbr	L120
L117:
	movl	$7,r9
L120:
L115:
	bicl3	$-128,r9,r0
	cmpl	r0,$10
	jeql	L122
	cvtbl	12(r10),r0
	cmpl	r9,r0
	jeql	L122
L123:
	cvtbl	13(r10),r0
	cmpl	r9,r0
	jneq	L121
L122:
	pushl	$1
	calls	$1,_allocb
	movl	r0,r7
	jeql	L124
	bisb2	$128,21(r7)
	incb	4(r10)
	pushl	r7
	pushl	4(ap)
	calls	$2,_putq
L124:
	pushl	4(ap)
	calls	$1,_qenable
	.stabs	"bp1",0x40,0,40,7
L121:
L112:
	bitw	$1,(r10)
	jeql	L126
	bitw	$16,2(r10)
	jneq	L126
L128:
	movl	4(ap),r0
	cvtwl	24(r0),r0
	movl	*4(ap),r1
	cvtwl	16(r1),r1
	movl	*4(ap),r2
	cvtwl	18(r2),r2
	addl2	r2,r1
	divl2	$2,r1
	cmpl	r0,r1
	jlss	L126
L127:
	movl	4(ap),r0
	movl	12(r0),r0
	bisw2	$4,26(r0)
	bisw2	$16,2(r10)
	cvtbl	11(r10),-(sp)
	pushl	$0
	pushl	r8
	calls	$3,_putctl1d
L126:
	bitw	$8,(r10)
	jeql	L130
	bitw	$8,26(r8)
	jneq	L130
L131:
	bicl2	$-128,r9
	cmpl	4(r11),8(r11)
	jneq	L132
	pushl	r9
	pushl	$0
	pushl	r8
	calls	$3,_putctl1d
	jbr	L133
L132:
	pushl	r9
	pushl	r8
	pushl	*(r8)
	calls	$3,_putd
L133:
	cvtbl	7(r10),r0
	cmpl	r9,r0
	jneq	L134
	bitw	$2,(r10)
	jneq	L134
L136:
	tstl	-4(fp)
	jneq	L134
L135:
	pushl	$10
	pushl	$0
	pushl	r8
	calls	$3,_putctl1d
L134:
L130:
L92:
	cmpl	4(r11),8(r11)
	jlssu	L93
L91:
	pushl	r11
	calls	$1,_freeb
	.stabs	"flags",0x80,0,4,8
	.stabs	"escape",0x80,0,4,4
	.stabs	"wrq",0x40,0,40,8
	.stabs	"c",0x40,0,4,9
	.stabs	"tp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L69:
	ret
	.set	L.R3,0xf80
	.set	L.SO3,0x8
L137:	.data
	.text
	.align	2
	.globl	_ttyinsrv
_ttyinsrv:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"ttyinsrv",0x24,0,224,_ttyinsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L139
	jbr	L138
L139:
	bitw	$34,(r10)
	jeql	L140
	jbr	L142
L143:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L142:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L144
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L143
L144:
L141:
	jbr	L145
L140:
	jbr	L147
L148:
	pushl	$256
	calls	$1,_allocb
	movl	r0,r8
	tstl	r8
	jneq	L149
	jbr	L138
L149:
	jbr	L151
L152:
	pushl	r10
	pushl	r8
	pushl	r9
	pushl	r11
	calls	$4,_canonblock
	movl	r0,r8
	bitb	$128,21(r8)
	jeql	L153
	decb	4(r10)
	jbr	L150
L153:
L151:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L152
L150:
	pushl	r8
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L147:
	tstb	4(r10)
	jeql	L154
	tstl	4(r11)
	jneq	L148
L154:
L146:
L145:
	bitw	$1,(r10)
	jeql	L155
	bitw	$16,2(r10)
	jeql	L155
L157:
	movl	(r11),r0
	cmpw	24(r11),18(r0)
	jgtr	L155
L156:
	bicw2	$16,2(r10)
	cvtbl	10(r10),-(sp)
	addl3	$28,r11,-(sp)
	pushl	$_putq
	calls	$3,_putd
L155:
	.stabs	"bp1",0x40,0,40,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"tp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L138:
	ret
	.set	L.R4,0xf00
	.set	L.SO4,0x0
L158:	.data
	.text
	.align	2
	.globl	_canonblock
_canonblock:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"canonblock",0x24,0,264,_canonblock
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	.stabs	"bp1",0xa0,0,40,12
	.stabs	"tp",0xa0,0,40,16
	movl	4(ap),r11
	movl	8(ap),r10
	movl	12(ap),r9
	movl	16(ap),r8
	jbr	L161
L162:
	subl3	$1,12(r9),r0
	cmpl	8(r9),r0
	jlssu	L163
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	pushl	$256
	calls	$1,_allocb
	movl	r0,r9
L163:
	movl	4(r10),r0
	incl	4(r10)
	movzbl	(r0),r7
	bitl	$128,r7
	jneq	L164
	cvtbl	6(r8),r0
	cmpl	r7,r0
	jneq	L165
	cmpl	8(r9),4(r9)
	jlequ	L166
	decl	8(r9)
L166:
	jbr	L161
L165:
	cvtbl	7(r8),r0
	cmpl	r7,r0
	jneq	L167
	movl	4(r9),8(r9)
	jbr	L161
L167:
	cvtbl	12(r8),r0
	cmpl	r7,r0
	jneq	L168
	jbr	L161
L168:
	jbr	L169
L164:
	bicl2	$-128,r7
	bitw	$4,(r8)
	jeql	L170
	tstb	_maptab(r7)
	jeql	L170
L171:
	cvtbl	_maptab(r7),r7
	jbr	L172
L170:
	cvtbl	6(r8),r0
	cmpl	r7,r0
	jeql	L174
	cvtbl	7(r8),r0
	cmpl	r7,r0
	jeql	L174
L175:
	cvtbl	12(r8),r0
	cmpl	r7,r0
	jneq	L173
L174:
	jbr	L176
L173:
	movl	8(r9),r0
	incl	8(r9)
	movb	$92,(r0)
L176:
L172:
L169:
	movl	8(r9),r0
	incl	8(r9)
	movb	r7,(r0)
L161:
	cmpl	4(r10),8(r10)
	jlssu	L162
L160:
	bitb	$128,21(r10)
	jeql	L177
	bisb2	$128,21(r9)
L177:
	pushl	r10
	calls	$1,_freeb
	movl	r9,r0
	jbr	L159
	.stabs	"c",0x40,0,4,7
	.stabs	"tp",0x40,0,40,8
	.stabs	"bp1",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L159:
	ret
	.set	L.R5,0xf80
	.set	L.SO5,0x0
L178:	.data
	.text
	.align	2
	.globl	_ttyosrv
_ttyosrv:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"ttyosrv",0x24,0,308,_ttyosrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	jbr	L181
L182:
	movzbl	20(r9),r0
	jbr	L184
L185:
	pushl	r9
	calls	$1,_freeb
	jbr	L181
L186:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L187
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L179
L187:
	pushl	$0
	subl3	$28,r11,-(sp)
	pushl	r9
	pushl	r11
	calls	$4,_ttldioc
	jbr	L181
L189:
	pushl	$0
	pushl	r11
	calls	$2,_flushq
L191:
L192:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L181
L193:
L194:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L195
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L179
L195:
	bitw	$32,(r10)
	jneq	L197
	cmpb	20(r9),$1
	jneq	L196
L197:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L198
L196:
	pushl	r9
	pushl	r11
	calls	$2,_outconv
L198:
	jbr	L181
L184:
	cmpl	r0,$0
	jeql	L193
	cmpl	r0,$1
	jeql	L194
	cmpl	r0,$6
	jeql	L186
	cmpl	r0,$66
	jeql	L189
	cmpl	r0,$69
	jeql	L192
	cmpl	r0,$70
	jeql	L191
	jbr	L185
L183:
L181:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L182
L180:
	.stabs	"bp",0x40,0,40,9
	.stabs	"tp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L179:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x0
L200:	.data
	.text
	.align	2
	.globl	_outconv
_outconv:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"outconv",0x24,0,353,_outconv
	.stabs	"q",0xa0,0,40,4
	.stabs	"ibp",0xa0,0,40,8
	movl	8(ap),r11
	clrl	r9
	movl	4(ap),r0
	movl	20(r0),r10
L202:
	jbr	L204
L205:
	tstl	r9
	jeql	L207
	cmpl	8(r9),12(r9)
	jlssu	L206
L207:
	tstl	r9
	jeql	L208
	pushl	r9
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
L208:
	movl	4(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jneq	L210
	pushl	$64
	calls	$1,_allocb
	movl	r0,r9
	jneq	L209
L210:
	pushl	r11
	pushl	4(ap)
	calls	$2,_putbq
	jbr	L201
L209:
L206:
	subl3	4(r11),8(r11),r7
	subl3	8(r9),12(r9),r8
	cmpl	r8,r7
	jgeq	L211
	movl	r8,r7
L211:
	jbr	L213
L214:
	incb	5(r10)
	movl	8(r9),r0
	incl	8(r9)
	movb	r8,(r0)
	decl	r7
	jgtr	L215
	jbr	L202
L215:
L213:
	movl	4(r11),r0
	incl	4(r11)
	movzbl	(r0),r0
	bicl3	$-128,r0,r8
	cvtbl	_partab(r8),r0
	bicl3	$-64,r0,r6
	jeql	L214
L212:
	cmpl	r8,$9
	jneq	L216
	cvtwl	(r10),r0
	bicl2	$-3073,r0
	cmpl	r0,$3072
	jneq	L216
L217:
L220:
	movl	8(r9),r0
	incl	8(r9)
	movb	$32,(r0)
	incb	5(r10)
	bitb	$7,5(r10)
	jneq	L221
	jbr	L219
L221:
	cmpl	8(r9),12(r9)
	jlssu	L222
	decl	4(r11)
	jbr	L219
L222:
	jbr	L220
L219:
	jbr	L204
L216:
	cmpl	r8,$10
	jneq	L223
	bitw	$16,(r10)
	jeql	L223
L224:
	bitw	$4,2(r10)
	jneq	L225
	bisw2	$4,2(r10)
	movl	$13,r8
	cvtbl	_partab+13,r0
	bicl3	$-64,r0,r6
	decl	4(r11)
	jbr	L226
L225:
	bicw2	$4,2(r10)
L226:
L223:
	movl	8(r9),r0
	incl	8(r9)
	movb	r8,(r0)
	clrl	r7
	movl	r6,r0
	jbr	L228
L229:
	incb	5(r10)
	jbr	L227
L230:
	jbr	L227
L231:
	tstb	5(r10)
	jeql	L232
	decb	5(r10)
L232:
	jbr	L227
L233:
	cvtwl	(r10),r0
	extzv	$8,$24,r0,r0
	bicl3	$-4,r0,r6
	cmpl	r6,$1
	jneq	L234
	tstb	5(r10)
	jeql	L235
	pushl	$6
	cvtbl	5(r10),r0
	extzv	$4,$28,r0,r0
	addl3	$3,r0,-(sp)
	calls	$2,_max
	movl	r0,r7
L235:
	jbr	L237
L234:
	cmpl	r6,$2
	jneq	L238
	movl	$6,r7
L238:
L237:
	bitw	$16,(r10)
	jneq	L239
	clrb	5(r10)
L239:
	jbr	L227
L240:
	cvtwl	(r10),r0
	extzv	$10,$22,r0,r0
	bicl3	$-4,r0,r6
	cmpl	r6,$1
	jneq	L241
	cvtbl	5(r10),r0
	bisl2	$-8,r0
	subl3	r0,$1,r7
	cmpl	r7,$5
	jgeq	L242
	clrl	r7
L242:
L241:
	bisb2	$7,5(r10)
	incb	5(r10)
	jbr	L227
L243:
	bitw	$16384,(r10)
	jeql	L244
	movl	$127,r7
L244:
	jbr	L227
L245:
	cvtwl	(r10),r0
	extzv	$12,$20,r0,r0
	bicl3	$-4,r0,r6
	cmpl	r6,$1
	jneq	L246
	movl	$5,r7
	jbr	L247
L246:
	cmpl	r6,$2
	jneq	L248
	movl	$10,r7
	jbr	L249
L248:
	cmpl	r6,$3
	jneq	L250
	movl	$20,r7
L250:
L249:
L247:
	clrb	5(r10)
	jbr	L227
L228:
	casel	r0,$0,$6
L251:
	.word	L229-L251
	.word	L230-L251
	.word	L231-L251
	.word	L233-L251
	.word	L240-L251
	.word	L243-L251
	.word	L245-L251
L252:
L227:
	tstl	r7
	jeql	L253
	pushl	r9
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	pushl	r7
	pushl	$7
	movl	4(ap),r0
	pushl	12(r0)
	calls	$3,_putctl1
	clrl	r9
L253:
L204:
	cmpl	4(r11),8(r11)
	jlssu	L205
L203:
	tstl	r9
	jeql	L255
	bicb3	$-129,21(r11),r0
	bisb2	r0,21(r9)
	pushl	r9
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L256
L255:
	bitb	$128,21(r11)
	jeql	L257
	pushl	$0
	movl	4(ap),r0
	pushl	12(r0)
	calls	$2,_putctld
L257:
L256:
	pushl	r11
	calls	$1,_freeb
	.stabs	"ctype",0x40,0,4,6
	.stabs	"count",0x40,0,4,7
	.stabs	"c",0x40,0,4,8
	.stabs	"obp",0x40,0,40,9
	.stabs	"tp",0x40,0,40,10
	.stabs	"ibp",0x40,0,40,11
L201:
	ret
	.set	L.R7,0xfc0
	.set	L.SO7,0x0
L259:	.data
	.text
	.align	2
	.globl	_ttysig
_ttysig:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"ttysig",0x24,0,494,_ttysig
	.stabs	"q",0xa0,0,40,4
	.stabs	"sig",0xa0,0,4,8
	movl	4(ap),r11
	movl	20(r11),r10
	pushl	$0
	pushl	r11
	calls	$2,_flushq
	pushl	$0
	addl3	$28,r11,-(sp)
	calls	$2,_flushq
	bicw2	$2,2(r10)
	clrb	4(r10)
	pushl	$66
	pushl	12(r11)
	calls	$2,_putctl
	pushl	8(ap)
	pushl	$65
	pushl	12(r11)
	calls	$3,_putctl1
	pushl	$66
	pushl	40(r11)
	calls	$2,_putctl
	.stabs	"tp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L260:
	ret
	.set	L.R8,0xc00
	.set	L.SO8,0x0
L261:	.data
	.text
	.align	2
	.globl	_ttldioc
_ttldioc:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"ttldioc",0x24,0,509,_ttldioc
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	.stabs	"rdq",0xa0,0,40,12
	.stabs	"fromdev",0xa0,0,4,16
	movl	8(ap),r11
	addl3	$4,4(r11),r9
	movl	4(ap),r0
	movl	20(r0),r10
	movzbl	*4(r11),r0
	movl	4(r11),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl2	r1,r0
	jbr	L264
L265:
L266:
	calls	$0,_spl6
	movl	r0,-4(fp)
	bitw	$34,4(r9)
	jeql	L268
	movl	12(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jneq	L268
L269:
	pushl	12(ap)
	calls	$1,_ttyinsrv
	jbr	L271
L272:
	pushl	r8
	movl	12(ap),r0
	pushl	12(r0)
	movl	12(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
L271:
	pushl	12(ap)
	calls	$1,_getq
	movl	r0,r8
	jneq	L272
L270:
	.stabs	"bp1",0x40,0,40,8
L268:
	movb	2(r9),6(r10)
	movb	3(r9),7(r10)
	movw	4(r9),(r10)
	pushl	-4(fp)
	calls	$1,_splx
	movb	$69,20(r11)
	bitw	$34,(r10)
	jeql	L274
	movl	12(ap),r0
	bicw2	$-65344,26(r0)
	jbr	L275
L274:
	movl	12(ap),r0
	bisw2	$192,26(r0)
L275:
	bitw	$32,(r10)
	jeql	L276
	bitw	$1,2(r10)
	jeql	L276
L277:
	pushl	$68
	movl	4(ap),r0
	pushl	12(r0)
	calls	$2,_putctl
	bicw2	$1,2(r10)
L276:
	jbr	L263
L278:
	movb	6(r10),2(r9)
	movb	7(r10),3(r9)
	movw	(r10),4(r9)
	movb	$13,r0
	movb	r0,1(r9)
	movb	r0,(r9)
	addl3	$10,4(r11),8(r11)
	movb	$69,20(r11)
	jbr	L263
L279:
	addl3	$4,4(r11),r0
	addl3	$8,r10,r1
	movc3	$6,(r0),(r1)
	movl	4(r11),8(r11)
	movb	$69,20(r11)
	jbr	L263
L280:
	addl3	$8,r10,r0
	addl3	$4,4(r11),r1
	movc3	$6,(r0),(r1)
	addl3	$10,4(r11),8(r11)
	movb	$69,20(r11)
	jbr	L263
L281:
	tstl	16(ap)
	jeql	L282
	movb	$69,20(r11)
	pushl	r11
	pushl	12(ap)
	calls	$2,_qreply
	jbr	L284
L282:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
L284:
	jbr	L262
L264:
	casel	r0,$29704,$10
L285:
	.word	L278-L285
	.word	L265-L285
	.word	L266-L285
	.word	L281-L285
	.word	L281-L285
	.word	L281-L285
	.word	L281-L285
	.word	L281-L285
	.word	L281-L285
	.word	L279-L285
	.word	L280-L285
	jbr	L281
L263:
	tstl	16(ap)
	jeql	L286
	pushl	r11
	pushl	12(ap)
	calls	$2,_qreply
	jbr	L287
L286:
	pushl	r11
	pushl	4(ap)
	calls	$2,_qreply
L287:
	.stabs	"s",0x80,0,4,4
	.stabs	"sp",0x40,0,40,9
	.stabs	"tp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L262:
	ret
	.set	L.R9,0xf00
	.set	L.SO9,0x4
L288:	.data
	.stabs	"ttwinit",0x26,0,8,_ttwinit
	.stabs	"ttrinit",0x26,0,8,_ttrinit
	.text
L289:	.stabs	"ttyld.c",0x94,0,587,L289
