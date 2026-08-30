L11:	.stabs	"xttyld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553095
	.data
	.comm	_nswdevt,4
	.align	2
_rinit:
	.long	_putq
	.long	_rsrv
	.long	_open
	.long	_close
	.long	0x12c0258
	.align	2
_winit:
	.long	_putq
	.long	_wsrv
	.long	_open
	.long	_close
	.long	0x12c0258
	.align	2
	.globl	_xttystream
_xttystream:
	.long	_rinit
	.long	_winit
	.align	2
_xttyproto:
	.long	0x40080d0d
	.long	0x1c7f0018
	.long	0xff041311
	.space	16
	.data
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
	.text
	.align	2
_open:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"open",0x24,0,45,_open
	.stabs	"open",0x32,0,68,0
	.stabs	"qp",0xa0,0,40,4
	.stabs	"dev",0xa0,0,13,8
	movl	4(ap),r11
	clrl	-4(fp)
	jbr	L53
L54:
	mull3	$28,-4(fp),r0
	tstl	_xttyld+12(r0)
	jneq	L55
	mull3	$28,-4(fp),r0
	addl2	$_xttyld,r0
	movc3	$28,_xttyproto,(r0)
	mull3	$28,-4(fp),r0
	movl	r11,_xttyld+12(r0)
	bisw2	$128,26(r11)
	mull3	$28,-4(fp),r0
	addl3	$_xttyld,r0,20(r11)
	bisw2	$128,54(r11)
	mull3	$28,-4(fp),r0
	addl3	$_xttyld,r0,48(r11)
	movl	$1,r0
	jbr	L50
L55:
	incl	-4(fp)
L53:
	cmpl	-4(fp),_xttycnt
	jlss	L54
L52:
	clrl	r0
	jbr	L50
	.stabs	"i",0x80,0,4,4
	.stabs	"qp",0x40,0,40,11
L50:
	ret
	.set	L.R1,0x800
	.set	L.SO1,0x4
L56:	.data
	.text
	.align	2
_close:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"close",0x24,0,64,_close
	.stabs	"close",0x32,0,68,0
	.stabs	"qp",0xa0,0,40,4
	movl	4(ap),r0
	movl	20(r0),r11
	tstl	20(r11)
	jeql	L58
	pushl	20(r11)
	calls	$1,_freeb
	clrl	20(r11)
L58:
	clrl	12(r11)
	.stabs	"xt",0x40,0,40,11
L57:
	ret
	.set	L.R2,0x800
	.set	L.SO2,0x0
L60:	.data
	.text
	.align	2
_ctl:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"ctl",0x24,0,79,_ctl
	.stabs	"ctl",0x32,0,80,0
	.stabs	"qp",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	8(ap),r11
	movl	4(ap),r0
	movl	20(r0),r10
	addl3	$4,4(r11),r9
	movzbl	*4(r11),r0
	movl	4(r11),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl2	r1,r0
	jbr	L64
L65:
	addl3	$6,r10,r0
	movc3	$6,(r0),(r9)
	movb	$69,20(r11)
	addl3	$10,4(r11),8(r11)
	jbr	L63
L66:
	addl3	$6,r10,r0
	movc3	$6,(r9),(r0)
	movb	$69,20(r11)
	addl3	$4,4(r11),8(r11)
	jbr	L63
L67:
	movc3	$6,(r10),(r9)
	movb	$69,20(r11)
	addl3	$10,4(r11),8(r11)
	jbr	L63
L68:
L69:
	movc3	$6,(r9),(r10)
	movb	$69,20(r11)
	addl3	$4,4(r11),8(r11)
	jbr	L63
L70:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L62
L64:
	casel	r0,$29704,$10
L71:
	.word	L67-L71
	.word	L69-L71
	.word	L68-L71
	.word	L70-L71
	.word	L70-L71
	.word	L70-L71
	.word	L70-L71
	.word	L70-L71
	.word	L70-L71
	.word	L66-L71
	.word	L65-L71
	jbr	L70
L63:
	pushl	r11
	movl	4(ap),r0
	bitw	$16,26(r0)
	jeql	L72
	addl3	$28,4(ap),r0
	jbr	L73
L72:
	subl3	$28,4(ap),r0
L73:
	pushl	12(r0)
	movl	4(ap),r0
	bitw	$16,26(r0)
	jeql	L74
	addl3	$28,4(ap),r0
	jbr	L75
L74:
	subl3	$28,4(ap),r0
L75:
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	bitl	$8,16(r10)
	jeql	L76
	bitw	$1,4(r10)
	jneq	L76
L77:
	bicl2	$8,16(r10)
	cvtbl	8(r10),-(sp)
	pushl	$0
	addl3	$28,12(r10),-(sp)
	calls	$3,_putctl1d
L76:
	bitw	$32,4(r10)
	jeql	L79
	clrl	16(r10)
	addl3	$28,12(r10),-(sp)
	calls	$1,_qenable
L79:
	bitw	$34,4(r10)
	jeql	L81
	movl	12(r10),r0
	bicw2	$-65408,26(r0)
	jbr	L82
L81:
	movl	12(r10),r0
	bisw2	$128,26(r0)
L82:
	.stabs	"data",0x40,0,44,9
	.stabs	"xt",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L62:
	ret
	.set	L.R3,0xe00
	.set	L.SO3,0x0
L83:	.data
	.text
	.align	2
_sig:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"sig",0x24,0,131,_sig
	.stabs	"sig",0x32,0,80,0
	.stabs	"xt",0xa0,0,40,4
	.stabs	"sig",0xa0,0,4,8
	movl	4(ap),r11
	movl	12(r11),r10
	pushl	$0
	pushl	r10
	calls	$2,_flushq
	pushl	$0
	addl3	$28,r10,-(sp)
	calls	$2,_flushq
	tstl	20(r11)
	jeql	L87
	pushl	20(r11)
	calls	$1,_freeb
	clrl	20(r11)
L87:
	bicl2	$7,16(r11)
	addl3	$28,r10,-(sp)
	calls	$1,_qenable
	pushl	$66
	pushl	12(r10)
	calls	$2,_putctl
	pushl	8(ap)
	pushl	$65
	pushl	12(r10)
	calls	$3,_putctl1
	pushl	$66
	pushl	40(r10)
	calls	$2,_putctl
	.stabs	"qp",0x40,0,40,10
	.stabs	"xt",0x40,0,40,11
L85:
	ret
	.set	L.R4,0xc00
	.set	L.SO4,0x0
L90:	.data
	.text
	.align	2
_icanon:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"icanon",0x24,0,152,_icanon
	.stabs	"icanon",0x32,0,68,0
	.stabs	"xt",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	bitw	$2,4(r11)
	jeql	L93
	clrl	r0
	jbr	L94
L93:
	bicl3	$-2,16(r11),r0
L94:
	movl	r0,r7
	bicl2	$1,16(r11)
	jbr	L96
L97:
	bitl	$4,16(r11)
	jeql	L98
	bicl2	$4,16(r11)
	addl3	$28,12(r11),-(sp)
	calls	$1,_qenable
L98:
	movl	4(r10),r0
	incl	4(r10)
	movzbl	(r0),r8
	bitw	$16,4(r11)
	jeql	L99
	cmpl	r8,$13
	jneq	L99
L100:
	movl	$10,r8
L99:
	bitw	$4,4(r11)
	jeql	L101
	cmpl	r8,$65
	jlss	L101
L103:
	cmpl	r8,$90
	jgtr	L101
L102:
	addl2	$32,r8
L101:
	tstl	r7
	jeql	L104
	cmpl	8(r9),4(r9)
	jlequ	L105
	cvtbl	2(r11),r0
	cmpl	r8,r0
	jeql	L107
	cvtbl	3(r11),r0
	cmpl	r8,r0
	jeql	L107
L113:
	cvtbl	10(r11),r0
	cmpl	r8,r0
	jeql	L107
L112:
	cvtbl	11(r11),r0
	cmpl	r8,r0
	jeql	L107
L111:
	cvtbl	6(r11),r0
	cmpl	r8,r0
	jeql	L107
L110:
	cvtbl	7(r11),r0
	cmpl	r8,r0
	jeql	L107
L109:
	cvtbl	8(r11),r0
	cmpl	r8,r0
	jeql	L107
L108:
	cvtbl	9(r11),r0
	cmpl	r8,r0
	jneq	L105
L107:
L106:
	decl	8(r9)
L105:
	cmpl	r8,$128
	jgequ	L114
	tstb	_maptab(r8)
	jeql	L114
L115:
	cvtbl	_maptab(r8),r8
L114:
	bisl2	$256,r8
L104:
	cvtbl	6(r11),r0
	cmpl	r8,r0
	jeql	L117
	cvtbl	7(r11),r0
	cmpl	r8,r0
	jneq	L116
L117:
	movl	8(r10),4(r10)
	cvtbl	6(r11),r0
	cmpl	r8,r0
	jneq	L118
	movl	$2,-(sp)
	jbr	L119
L118:
	movl	$3,-(sp)
L119:
	pushl	r11
	calls	$2,_sig
	clrl	r0
	jbr	L92
L116:
	cvtbl	9(r11),r0
	cmpl	r8,r0
	jneq	L120
	bisl2	$4,16(r11)
	clrl	r0
	jbr	L92
L120:
	cvtbl	8(r11),r0
	cmpl	r8,r0
	jneq	L121
	clrl	r0
	jbr	L92
L121:
	bitw	$8,4(r11)
	jeql	L122
	pushl	r8
	pushl	$0
	addl3	$28,12(r11),-(sp)
	calls	$3,_putctl1d
L122:
	bitw	$2,4(r11)
	jneq	L123
	cvtbl	2(r11),r0
	cmpl	r8,r0
	jneq	L124
	cmpl	8(r9),4(r9)
	jlequ	L125
	decl	8(r9)
L125:
	jbr	L96
L124:
	cvtbl	3(r11),r0
	cmpl	r8,r0
	jneq	L126
	movl	4(r9),8(r9)
	bitw	$8,4(r11)
	jeql	L127
	pushl	$10
	pushl	$0
	addl3	$28,12(r11),-(sp)
	calls	$3,_putctl1d
L127:
	jbr	L96
L126:
L123:
	bitw	$2,4(r11)
	jneq	L129
	cvtbl	10(r11),r0
	cmpl	r8,r0
	jeql	L128
L129:
	cmpl	8(r9),12(r9)
	jgequ	L130
	movl	8(r9),r0
	incl	8(r9)
	movb	r8,(r0)
	jbr	L131
L130:
	decl	4(r10)
	movb	r8,*4(r10)
	movl	$1,r0
	jbr	L92
L131:
L128:
	bitw	$2,4(r11)
	jneq	L132
	cvtbl	10(r11),r0
	cmpl	r8,r0
	jeql	L134
	cvtbl	11(r11),r0
	cmpl	r8,r0
	jeql	L134
L135:
	cmpl	r8,$10
	jneq	L133
L134:
	movl	$1,r0
	jbr	L92
L133:
	bicl3	$-256,r8,r0
	cmpl	r0,$92
	jneq	L136
	movl	$1,r0
	jbr	L137
L136:
	clrl	r0
L137:
	movl	r0,r7
L132:
L96:
	cmpl	4(r10),8(r10)
	jlssu	L97
L95:
	bisl2	r7,16(r11)
	cvtwl	4(r11),r0
	bicl2	$-3,r0
	jbr	L92
	.stabs	"esc",0x40,0,4,7
	.stabs	"c",0x40,0,4,8
	.stabs	"icanb",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"xt",0x40,0,40,11
L92:
	ret
	.set	L.R5,0xf80
	.set	L.SO5,0x0
L138:	.data
	.text
	.align	2
_rsrv:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"rsrv",0x24,0,226,_rsrv
	.stabs	"rsrv",0x32,0,68,0
	.stabs	"qp",0xa0,0,40,4
	movl	4(ap),r0
	movl	20(r0),r11
	tstl	12(r11)
	jneq	L140
	jbr	L139
L140:
	jbr	L142
L143:
	bitw	$32,4(r11)
	jeql	L144
	tstl	20(r11)
	jeql	L144
L145:
	pushl	20(r11)
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	clrl	20(r11)
	jbr	L142
L144:
	pushl	4(ap)
	calls	$1,_getq
	movl	r0,-4(fp)
	tstl	-4(fp)
	jneq	L146
	jbr	L141
L146:
	bitw	$32,4(r11)
	jneq	L147
	movl	-4(fp),r0
	tstb	20(r0)
	jneq	L147
L148:
L151:
	tstl	20(r11)
	jneq	L152
	bitw	$2,4(r11)
	jeql	L153
	movl	-4(fp),r0
	movl	-4(fp),r1
	subl3	8(r1),4(r0),-(sp)
	calls	$1,_allocb
	movl	r0,20(r11)
	jbr	L154
L153:
	pushl	$256
	calls	$1,_allocb
	movl	r0,20(r11)
L154:
	tstl	20(r11)
	jneq	L155
	pushl	-4(fp)
	pushl	4(ap)
	calls	$2,_putbq
	movl	4(ap),r0
	movl	12(r0),r0
	bisw2	$4,26(r0)
	jbr	L139
L155:
	movl	20(r11),r0
	clrb	20(r0)
L152:
	pushl	-4(fp)
	pushl	r11
	calls	$2,_icanon
	tstl	r0
	jeql	L157
	bitw	$2,4(r11)
	jneq	L158
	movl	20(r11),r0
	bisb2	$128,21(r0)
L158:
	pushl	20(r11)
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	clrl	20(r11)
L157:
L150:
	movl	-4(fp),r0
	movl	-4(fp),r1
	cmpl	4(r0),8(r1)
	jneq	L151
L149:
	pushl	-4(fp)
	calls	$1,_freeb
	jbr	L159
L147:
	movl	-4(fp),r0
	cmpb	20(r0),$6
	jneq	L160
	pushl	-4(fp)
	pushl	4(ap)
	calls	$2,_ctl
	jbr	L161
L160:
	movl	-4(fp),r0
	movzbl	20(r0),r0
	jbr	L163
L164:
	bitw	$32,4(r11)
	jeql	L165
	movl	-4(fp),r0
	clrb	20(r0)
	movl	-4(fp),r0
	bisb2	$128,21(r0)
	movl	-4(fp),r0
	movl	-4(fp),r1
	cmpl	8(r0),12(r1)
	jgequ	L166
	movl	-4(fp),r0
	movl	8(r0),r1
	incl	8(r0)
	clrb	(r1)
L166:
	jbr	L167
L165:
	pushl	-4(fp)
	calls	$1,_freeb
	pushl	$2
	pushl	r11
	calls	$2,_sig
	jbr	L139
L167:
	jbr	L162
L168:
	tstl	20(r11)
	jeql	L169
	movl	20(r11),r0
	movl	20(r11),r1
	movl	4(r1),8(r0)
L169:
	jbr	L162
L163:
	cmpl	r0,$1
	jeql	L164
	cmpl	r0,$66
	jeql	L168
L162:
	movl	-4(fp),r0
	bicb2	$-128,21(r0)
	pushl	-4(fp)
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
L161:
L159:
L142:
	movl	4(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L143
L141:
	cvtwl	4(r11),r0
	bicl2	$-34,r0
	cmpl	r0,$1
	jneq	L170
	bitl	$8,16(r11)
	jneq	L171
	movl	4(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L171
L172:
	bisl2	$8,16(r11)
	cvtbl	9(r11),-(sp)
	pushl	$0
	addl3	$28,4(ap),-(sp)
	calls	$3,_putctl1d
L171:
	bitl	$8,16(r11)
	jeql	L173
	movl	4(ap),r0
	movl	12(r0),r0
	tstw	26(r0)
	jneq	L175
	movl	$1,r0
	jbr	L176
L175:
	clrl	r0
L176:
	bitl	$8,r0
	jeql	L173
L174:
	bicl2	$8,16(r11)
	cvtbl	8(r11),-(sp)
	pushl	$0
	addl3	$28,4(ap),-(sp)
	calls	$3,_putctl1d
L173:
L170:
	movl	4(ap),r0
	tstw	24(r0)
	jeql	L177
	movl	4(ap),r0
	movl	12(r0),r0
	bisw2	$4,26(r0)
L177:
	.stabs	"bp",0x80,0,40,4
	.stabs	"xt",0x40,0,40,11
L139:
	ret
	.set	L.R6,0x800
	.set	L.SO6,0x4
L178:	.data
	.text
	.align	2
_ocanon:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"ocanon",0x24,0,308,_ocanon
	.stabs	"ocanon",0x32,0,68,0
	.stabs	"xt",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	.stabs	"qp",0xa0,0,40,12
	movl	4(ap),r11
	movl	8(ap),r10
	jbr	L182
L183:
	subl3	4(r10),8(r10),r0
	addl3	$8,r0,-(sp)
	calls	$1,_allocb
	movl	r0,r9
	tstl	r9
	jneq	L184
	clrl	r0
	jbr	L180
L184:
	bisb2	$128,21(r9)
	clrl	r7
	jbr	L186
L187:
	movl	4(r10),r0
	incl	4(r10)
	movzbl	(r0),r8
	bicl3	$-8,24(r11),r0
	subl3	r0,$8,r6
	bitl	$2,16(r11)
	jeql	L188
	bicl2	$2,16(r11)
	jbr	L189
L188:
	bitw	$16,4(r11)
	jeql	L190
	cmpl	r8,$10
	jneq	L191
	decl	4(r10)
	movl	$13,r8
	bisl2	$2,16(r11)
	jbr	L192
L191:
	cmpl	r8,$13
	jneq	L193
	decl	4(r10)
	movb	$10,*4(r10)
	bisl2	$2,16(r11)
L193:
L192:
L190:
L189:
	movl	r8,r0
	jbr	L195
L196:
L197:
	clrl	24(r11)
	bitw	$16384,4(r11)
	jeql	L198
	movl	$127,r7
L198:
	jbr	L194
L199:
	clrl	24(r11)
	cvtwl	4(r11),r0
	bicl2	$-12289,r0
	jbr	L201
L202:
	movl	$5,r7
	jbr	L200
L203:
	movl	$10,r7
	jbr	L200
L204:
	movl	$20,r7
	jbr	L200
L201:
	cmpl	r0,$4096
	jeql	L202
	cmpl	r0,$8192
	jeql	L203
	cmpl	r0,$12288
	jeql	L204
L200:
	jbr	L194
L205:
	addl2	r6,24(r11)
	cvtwl	4(r11),r0
	bicl2	$-3073,r0
	jbr	L207
L208:
	movl	r6,r7
	cmpl	r7,$5
	jgeq	L209
	clrl	r7
L209:
	jbr	L206
L210:
	jbr	L212
L213:
	movl	8(r9),r0
	incl	8(r9)
	movb	$32,(r0)
L212:
	movl	r6,r0
	decl	r6
	tstl	r0
	jneq	L213
L211:
	jbr	L186
L207:
	cmpl	r0,$1024
	jeql	L208
	cmpl	r0,$3072
	jeql	L210
L206:
	jbr	L194
L214:
	clrl	24(r11)
	cvtwl	4(r11),r0
	bicl2	$-769,r0
	jbr	L216
L217:
	pushl	$6
	extzv	$4,$28,24(r11),r0
	addl3	$3,r0,-(sp)
	calls	$2,_max
	movl	r0,r7
	jbr	L215
L219:
	movl	$6,r7
	jbr	L215
L216:
	cmpl	r0,$256
	jeql	L217
	cmpl	r0,$512
	jeql	L219
L215:
	jbr	L194
L220:
	decl	24(r11)
	jgeq	L221
	clrl	24(r11)
L221:
	jbr	L194
L222:
	incl	24(r11)
	jbr	L194
L195:
	casel	r0,$8,$5
L223:
	.word	L220-L223
	.word	L205-L223
	.word	L214-L223
	.word	L196-L223
	.word	L197-L223
	.word	L199-L223
	jbr	L222
L194:
	movl	8(r9),r0
	incl	8(r9)
	movb	r8,(r0)
	tstl	r7
	jeql	L224
	jbr	L185
L224:
L186:
	cmpl	4(r10),8(r10)
	jgequ	L225
	subl3	$8,12(r9),r0
	cmpl	8(r9),r0
	jlssu	L187
L225:
L185:
	pushl	r9
	pushl	12(ap)
	movl	*12(ap),r0
	movl	(r0),r1
	calls	$2,(r1)
	tstl	r7
	jeql	L226
	pushl	r7
	pushl	$7
	pushl	12(ap)
	calls	$3,_putctl1d
L226:
L182:
	cmpl	4(r10),8(r10)
	jlssu	L183
L181:
	pushl	r10
	calls	$1,_freeb
	movl	$1,r0
	jbr	L180
	.stabs	"t",0x40,0,4,6
	.stabs	"d",0x40,0,4,7
	.stabs	"c",0x40,0,4,8
	.stabs	"ocanb",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"xt",0x40,0,40,11
L180:
	ret
	.set	L.R7,0xfc0
	.set	L.SO7,0x0
L227:	.data
	.text
	.align	2
_wsrv:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"wsrv",0x24,0,402,_wsrv
	.stabs	"wsrv",0x32,0,68,0
	.stabs	"qp",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	jbr	L230
L231:
	bitl	$4,16(r10)
	jeql	L232
	tstb	20(r9)
	jneq	L232
L233:
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	bisw2	$8,26(r11)
	jbr	L228
L232:
	bitw	$32,4(r10)
	jneq	L234
	bitw	$65296,4(r10)
	jeql	L234
L236:
	tstb	20(r9)
	jneq	L234
L235:
	pushl	12(r11)
	pushl	r9
	pushl	r10
	calls	$3,_ocanon
	tstl	r0
	jneq	L237
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	movl	12(r11),r0
	bisw2	$4,26(r0)
	jbr	L228
L237:
	jbr	L238
L234:
	cmpb	20(r9),$6
	jneq	L239
	pushl	r9
	pushl	r11
	calls	$2,_ctl
	jbr	L240
L239:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L240:
L238:
L230:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L241
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L231
L241:
L229:
	tstw	24(r11)
	jeql	L242
	movl	12(r11),r0
	bisw2	$4,26(r0)
L242:
	.stabs	"bp",0x40,0,40,9
	.stabs	"xt",0x40,0,40,10
	.stabs	"qp",0x40,0,40,11
L228:
	ret
	.set	L.R8,0xe00
	.set	L.SO8,0x0
L243:	.data
	.stabs	"maptab",0x26,0,98,_maptab
	.stabs	"xttyproto",0x26,0,8,_xttyproto
	.stabs	"winit",0x26,0,8,_winit
	.stabs	"rinit",0x26,0,8,_rinit
	.text
L244:	.stabs	"xttyld.c",0x94,0,429,L244
