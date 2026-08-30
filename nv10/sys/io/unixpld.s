L11:	.stabs	"unixpld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553093
	.data
	.comm	_nswdevt,4
	.align	2
_xprinit:
	.long	_xpiput
	.long	0
	.long	_xpopen
	.long	_xpclose
	.long	0x240048
	.align	2
_xpwinit:
	.long	_xpoput
	.long	_xposrv
	.long	_xpopen
	.long	_nulldev
	.long	0x240048
	.align	2
	.globl	_xpstream
_xpstream:
	.long	_xprinit
	.long	_xpwinit
	.comm	_xp,384
	.text
	.align	2
	.globl	_xpopen
_xpopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"xpopen",0x24,0,64,_xpopen
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
	movl	$_xp,r10
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

	.byte	0x78,0x70,0x6f,0x70,0x65,0x6e,0x0
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
	cmpl	r10,$_xp+384
	jlssu	L63
L61:
	tstl	r9
	jneq	L73
	clrl	r0
	jbr	L57
L73:
	movl	r11,(r9)
	bicw3	$-256,8(ap),r0
	subw3	10(r8),r0,8(r9)
	movl	r8,4(r9)
	bisw2	$128,26(r11)
	clrl	20(r11)
	movl	r9,48(r11)
	tstl	L58
	jneq	L74
	calls	$0,_xptimer
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
	.globl	_xpclose
_xpclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"xpclose",0x24,0,100,_xpclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	48(r11),r9
	tstl	r9
	jneq	L78
	.data	1
L79:

	.byte	0x6e,0x75,0x6c,0x6c,0x20,0x70,0x74,0x72
	.byte	0x3b,0x20,0x71,0x20,0x25,0x78,0x20,0x77
	.byte	0x71,0x20,0x25,0x78,0xa,0x0
	.text
	addl3	$28,r11,-(sp)
	pushl	r11
	pushl	$L79
	calls	$3,_printf
L78:
	addl3	$28,r11,r0
	movl	4(r9),r1
	cmpl	r0,4(r1)
	jneq	L80
	movl	4(r9),r0
	clrl	4(r0)
	movl	4(r9),r0
	clrw	14(r0)
L80:
	jbr	L82
L83:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L82:
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L83
L81:
	clrl	(r9)
	clrl	4(r9)
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L77:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L84:	.data
	.text
	.align	2
	.globl	_xpoput
_xpoput:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"xpoput",0x24,0,121,_xpoput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	movl	4(r9),r8
	movzbl	20(r10),r0
	jbr	L87
L88:
	movzbl	*4(r10),r0
	movl	4(r10),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl2	r1,r0
	jbr	L90
L91:
	cmpw	8(r9),$5
	jgeq	L92
	pushl	$0
	pushl	$1
	pushl	$4
	pushl	r8
	calls	$4,_xpmesg
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L85
L92:
	jbr	L89
L95:
	tstl	4(r8)
	jneq	L96
	movl	r11,4(r8)
	movw	$117,14(r8)
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r8
	calls	$4,_xpmesg
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L85
L96:
	jbr	L89
L97:
	movl	$1,-8(r11)
	movb	$69,20(r10)
	movl	8(r10),4(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L85
L98:
	cvtwl	10(r8),r0
	addl3	$2,r0,r7
	jbr	L101
L102:
	addl3	(r8),r7,r0
	tstb	(r0)
	jneq	L103
	movl	4(r10),r0
	movl	r7,4(r0)
	addl3	$8,4(r10),8(r10)
	movb	$69,20(r10)
	jbr	L100
L103:
	incl	r7
L101:
	cvtwl	12(r8),r0
	cmpl	r7,r0
	jlss	L102
L100:
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L85
L104:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L85
L90:
	casel	r0,$25632,$7
L105:
	.word	L95-L105
	.word	L91-L105
	.word	L104-L105
	.word	L104-L105
	.word	L104-L105
	.word	L104-L105
	.word	L98-L105
	.word	L97-L105
	jbr	L104
L89:
	movb	$70,20(r10)
	movl	4(r10),8(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L85
L87:
	cmpl	r0,$6
	jeql	L88
L86:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	.stabs	"i",0x40,0,4,7
	.stabs	"modp",0x40,0,40,8
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L85:
	ret
	.set	L.R3,0xf80
	.set	L.SO3,0x0
L106:	.data
	.text
	.align	2
	.globl	_xposrv
_xposrv:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"xposrv",0x24,0,191,_xposrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	jbr	L109
L110:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L109:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L111
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L110
L111:
L108:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L107:
	ret
	.set	L.R4,0xc00
	.set	L.SO4,0x0
L112:	.data
	.text
	.align	2
	.globl	_xpiput
_xpiput:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"xpiput",0x24,0,205,_xpiput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	48(r11),r9
	movzbl	20(r10),r0
	jbr	L115
L116:
	addl3	$28,r11,r0
	movl	4(r9),r1
	cmpl	r0,4(r1)
	jneq	L118
	pushl	r10
	pushl	4(r9)
	calls	$2,_xplstnr
	tstl	r0
	jeql	L118
L119:
	jbr	L113
L118:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L120
	pushl	r10
	calls	$1,_freeb
	jbr	L113
L120:
	bisb2	$128,21(r10)
	tstl	20(r11)
	jeql	L122
	pushl	r10
	pushl	r11
	calls	$2,_putq
	jbr	L113
L122:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L113
L123:
L124:
L125:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L113
L126:
	movzbl	*4(r10),r0
	jbr	L128
L129:
	movl	4(r10),r0
	movzbl	1(r0),r0
	addl2	*4(r9),r0
	movb	$2,(r0)
	movl	4(r10),r0
	movzbl	1(r0),-(sp)
	pushl	$1
	pushl	$3
	pushl	4(r9)
	calls	$4,_xpmesg
	pushl	r10
	calls	$1,_freeb
	jbr	L113
L130:
	pushl	r10
	calls	$1,_freeb
	jbr	L113
L128:
	cmpl	r0,$0
	jeql	L129
	jbr	L130
L127:
L131:
	pushl	r10
	calls	$1,_freeb
	jbr	L114
L115:
	cmpl	r0,$0
	jeql	L116
	cmpl	r0,$2
	jeql	L125
	cmpl	r0,$69
	jeql	L123
	cmpl	r0,$70
	jeql	L124
	cmpl	r0,$71
	jeql	L126
	jbr	L131
L114:
	.stabs	"dkp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L113:
	ret
	.set	L.R5,0xe00
	.set	L.SO5,0x0
L132:	.data
	.text
	.align	2
	.globl	_xpmesg
_xpmesg:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"xpmesg",0x24,0,254,_xpmesg
	.stabs	"modp",0xa0,0,40,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"srv",0xa0,0,4,12
	.stabs	"p0",0xa0,0,4,16
	movl	4(ap),r11
	tstl	4(r11)
	jeql	L135
	movl	4(r11),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L134
L135:
	jbr	L133
L134:
	pushl	$12
	calls	$1,_allocb
	movl	r0,r9
	jneq	L136
	jbr	L133
L136:
	movl	8(r9),r10
	movb	8(ap),(r10)
	movb	12(ap),1(r10)
	movw	16(ap),2(r10)
	clrw	4(r10)
	clrw	6(r10)
	clrw	8(r10)
	clrw	10(r10)
	addl2	$12,8(r9)
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
L133:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x0
L137:	.data
	.text
	.align	2
	.globl	_xplstnr
_xplstnr:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"xplstnr",0x24,0,281,_xplstnr
	.stabs	"modp",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	8(ap),r11
	movl	4(ap),r0
	movl	4(r0),r8
	movl	4(r11),r10
	cvtwl	2(r10),r9
	cvtwl	4(r10),-4(fp)
	cvtbl	(r10),r0
	jbr	L140
L141:
	cmpb	1(r10),$3
	jneq	L142
	.data	1
L143:

	.byte	0x64,0x61,0x74,0x61,0x6b,0x69,0x74,0x20
	.byte	0x63,0x6c,0x6f,0x73,0x69,0x6e,0x67,0x20
	.byte	0x61,0x6c,0x6c,0x20,0x63,0x68,0x61,0x6e
	.byte	0x73,0xa,0x0
	.text
	pushl	$L143
	calls	$1,_printf
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	subl3	$1,r0,r9
	jbr	L146
L147:
	movl	20(r8),r0
	cvtwl	8(r0),r0
	cmpl	r0,r9
	jneq	L148
	jbr	L144
L148:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),r0
	jbr	L150
L151:
	incl	_dkstat+40
L152:
	.data	1
L153:

	.byte	0x63,0x6c,0x6f,0x73,0x69,0x6e,0x67,0x20
	.byte	0x25,0x64,0xa,0x0
	.text
	pushl	r9
	pushl	$L153
	calls	$2,_printf
	pushl	r9
	pushl	$0
	pushl	$71
	pushl	12(r8)
	calls	$4,_putctl2
	jbr	L149
L155:
	.data	1
L156:

	.byte	0x63,0x6c,0x6f,0x73,0x65,0x64,0x20,0x25
	.byte	0x64,0xa,0x0
	.text
	pushl	r9
	pushl	$L156
	calls	$2,_printf
L157:
	addl3	*4(ap),r9,r0
	clrb	(r0)
	jbr	L149
L150:
	casel	r0,$0,$3
L158:
	.word	L157-L158
	.word	L151-L158
	.word	L155-L158
	.word	L152-L158
L159:
L149:
L144:
	decl	r9
L146:
	tstl	r9
	jgtr	L147
L145:
	pushl	r11
	calls	$1,_freeb
	movl	$1,r0
	jbr	L138
L142:
	tstl	r9
	jleq	L161
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r9,r0
	jlss	L160
L161:
	incl	_dkstat+36
	tstb	1(r10)
	jeql	L162
	pushl	r9
	pushl	$1
	pushl	$3
	pushl	4(ap)
	calls	$4,_xpmesg
L162:
	pushl	r11
	calls	$1,_freeb
	movl	$1,r0
	jbr	L138
L160:
	cvtbl	1(r10),r0
	jbr	L164
L165:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),r0
	jbr	L167
L168:
	incl	_dkstat+40
L169:
	pushl	r9
	pushl	$0
	pushl	$71
	pushl	12(r8)
	calls	$4,_putctl2
	jbr	L166
L170:
L171:
	pushl	r9
	pushl	$1
	pushl	$3
	pushl	4(ap)
	calls	$4,_xpmesg
	jbr	L166
L167:
	casel	r0,$0,$3
L172:
	.word	L171-L172
	.word	L168-L172
	.word	L170-L172
	.word	L169-L172
L173:
L166:
	jbr	L163
L174:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),r0
	jbr	L176
L177:
L178:
	pushl	r9
	pushl	$0
	pushl	$71
	pushl	12(r8)
	calls	$4,_putctl2
	jbr	L175
L179:
L180:
	incl	_dkstat+44
	jbr	L175
L176:
	casel	r0,$0,$3
L181:
	.word	L178-L181
	.word	L180-L181
	.word	L177-L181
	.word	L179-L181
L182:
L175:
	jbr	L163
L164:
	casel	r0,$1,$1
L183:
	.word	L165-L183
	.word	L174-L183
L184:
L163:
	pushl	r11
	calls	$1,_freeb
	movl	$1,r0
	jbr	L138
L185:
	tstl	r9
	jlss	L187
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r9,r0
	jlss	L186
L187:
	clrl	r0
	jbr	L138
L186:
	movl	$_xp,r7
	jbr	L190
L191:
	cmpl	4(r7),4(ap)
	jneq	L192
	cvtwl	8(r7),r0
	cmpl	r0,r9
	jneq	L192
L193:
	pushl	r11
	movl	(r7),r0
	pushl	12(r0)
	movl	(r7),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	movl	$1,r0
	jbr	L138
L192:
	addl2	$12,r7
L190:
	cmpl	r7,$_xp+384
	jlssu	L191
L189:
	clrl	r0
	jbr	L138
L194:
	cmpb	1(r10),$7
	jneq	L195
	tstl	r9
	jlss	L197
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	cmpl	r9,r0
	jlss	L196
L197:
	clrl	r0
	jbr	L138
L196:
	pushl	r11
	calls	$1,_freeb
	pushl	$4
	calls	$1,_allocb
	movl	r0,r11
	jneq	L198
	clrl	r0
	jbr	L138
L198:
	movl	8(r11),r0
	incl	8(r11)
	movb	$1,(r0)
	movl	8(r11),r0
	incl	8(r11)
	movb	r9,(r0)
	movl	8(r11),r0
	incl	8(r11)
	extzv	$8,$24,-4(fp),r1
	movb	r1,(r0)
	movl	8(r11),r0
	incl	8(r11)
	movb	-4(fp),(r0)
	movb	$71,20(r11)
	pushl	r11
	pushl	12(r8)
	movl	*12(r8),r0
	movl	(r0),r1
	calls	$2,(r1)
	movl	$1,r0
	jbr	L138
L195:
	clrl	r0
	jbr	L138
L199:
	.data	1
L200:

	.byte	0x64,0x61,0x74,0x61,0x6b,0x69,0x74,0x20
	.byte	0x72,0x65,0x73,0x74,0x61,0x72,0x74,0xa
	.byte	0x0
	.text
	pushl	$L200
	calls	$1,_printf
	movl	4(ap),r0
	cvtwl	12(r0),r0
	movl	4(ap),r1
	cvtwl	10(r1),r1
	subl2	r1,r0
	subl3	$1,r0,r9
	jbr	L203
L204:
	addl3	*4(ap),r9,r0
	cvtbl	(r0),r0
	jbr	L206
L207:
	pushl	r9
	pushl	$1
	pushl	$3
	pushl	4(ap)
	calls	$4,_xpmesg
	jbr	L205
L206:
	cmpl	r0,$2
	jeql	L207
L205:
	decl	r9
L203:
	tstl	r9
	jgtr	L204
L202:
	pushl	r11
	calls	$1,_freeb
	movl	$1,r0
	jbr	L138
L208:
	clrl	r0
	jbr	L138
L140:
	casel	r0,$1,$7
L209:
	.word	L194-L209
	.word	L185-L209
	.word	L141-L209
	.word	L208-L209
	.word	L208-L209
	.word	L208-L209
	.word	L208-L209
	.word	L199-L209
	jbr	L208
L139:
	.stabs	"t",0x80,0,4,4
	.stabs	"dkp",0x40,0,40,7
	.stabs	"listnrq",0x40,0,40,8
	.stabs	"i",0x40,0,4,9
	.stabs	"dialp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L138:
	ret
	.set	L.R7,0xf80
	.set	L.SO7,0x4
L210:	.data
	.text
	.align	2
	.globl	_xptimer
_xptimer:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"xptimer",0x24,0,413,_xptimer
	movl	$_dkmod,r10
	jbr	L214
L215:
	tstl	4(r10)
	jeql	L216
	cmpw	14(r10),$117
	jneq	L216
L217:
	pushl	$0
	pushl	$0
	pushl	$4
	pushl	r10
	calls	$4,_xpmesg
	cvtwl	12(r10),r0
	cvtwl	10(r10),r1
	subl2	r1,r0
	subl3	$1,r0,r11
	jbr	L220
L221:
	addl3	(r10),r11,r0
	cmpb	(r0),$2
	jneq	L222
	pushl	r11
	pushl	$1
	pushl	$3
	pushl	r10
	calls	$4,_xpmesg
L222:
	decl	r11
L220:
	tstl	r11
	jgeq	L221
L219:
L216:
	addl2	$16,r10
L214:
	addl3	_dkmodcnt,_dkmodcnt,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	$_dkmod,r0
	cmpl	r10,r0
	jlssu	L215
L213:
	pushl	$900
	pushl	$0
	pushl	$_xptimer
	calls	$3,_timeout
	.stabs	"dkp",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L211:
	ret
	.set	L.R8,0xc00
	.set	L.SO8,0x0
L224:	.data
	.stabs	"xpwinit",0x26,0,8,_xpwinit
	.stabs	"xprinit",0x26,0,8,_xprinit
	.text
L225:	.stabs	"unixpld.c",0x94,0,427,L225
