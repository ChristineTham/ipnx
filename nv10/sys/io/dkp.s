L11:	.stabs	"dkp.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553093
	.data
	.comm	_nswdevt,4
	.align	2
_cdkprinit:
	.long	_dkpiput
	.long	_dkpisrv
	.long	_cdkpopen
	.long	_dkpclose
	.long	0x400200
	.align	2
_cdkpwinit:
	.long	_dkpoput
	.long	_dkposrv
	.long	_cdkpopen
	.long	_dkpclose
	.long	0x410080
	.align	2
_dkprinit:
	.long	_dkpiput
	.long	_dkpisrv
	.long	_dkpopen
	.long	_dkpclose
	.long	0x20005dc
	.align	2
_dkpwinit:
	.long	_dkpoput
	.long	_dkposrv
	.long	_dkpopen
	.long	_dkpclose
	.long	0x20005dc
	.align	2
	.globl	_dkpstream
_dkpstream:
	.long	_dkprinit
	.long	_dkpwinit
	.align	2
	.globl	_cdkpstream
_cdkpstream:
	.long	_cdkprinit
	.long	_cdkpwinit
	.text
	.align	2
	.globl	_dkpopen
_dkpopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"dkpopen",0x24,0,87,_dkpopen
	.stabs	"q",0xa0,0,40,4
	pushl	$0
	pushl	4(ap)
	calls	$2,_rdkpopen
	jbr	L61
L61:
	ret
	.set	L.R1,0x0
	.set	L.SO1,0x0
L63:	.data
	.text
	.align	2
	.globl	_cdkpopen
_cdkpopen:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"cdkpopen",0x24,0,94,_cdkpopen
	.stabs	"q",0xa0,0,40,4
	pushl	$8
	pushl	4(ap)
	calls	$2,_rdkpopen
	jbr	L64
L64:
	ret
	.set	L.R2,0x0
	.set	L.SO2,0x0
L65:	.data
	.text
	.align	2
	.globl	_rdkpopen
_rdkpopen:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"rdkpopen",0x24,0,100,_rdkpopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"mode",0xa0,0,4,8
	movl	4(ap),r11
	.data
	.align	2
L67:
	.long	0
	.text
	tstl	L67
	jneq	L69
	movl	$1,L67
	pushl	$60
	pushl	$0
	pushl	$_dkptimer
	calls	$3,_timeout
L69:
	tstl	20(r11)
	jneq	L71
	movl	$_dkp,r10
	jbr	L74
L75:
	ashl	$6,_dkpcnt,r0
	addl2	$_dkp,r0
	cmpl	r10,r0
	jlssu	L76
	clrl	r0
	jbr	L66
L76:
	addl2	$64,r10
L74:
	tstw	12(r10)
	jneq	L75
L73:
	movl	r11,(r10)
	movl	r10,20(r11)
	movl	r10,48(r11)
	bisw2	$64,54(r11)
	pushl	$66
	pushl	12(r11)
	calls	$2,_putctl
	movb	$2,24(r10)
	clrb	14(r10)
	clrb	18(r10)
	movb	$16,19(r10)
	movb	$1,20(r10)
	movb	$1,21(r10)
	movb	$1,22(r10)
	movb	$3,23(r10)
	movw	$64,30(r10)
	clrb	15(r10)
	cmpl	8(ap),$8
	jeql	L78
	bisw2	$128,54(r11)
	movw	$144,12(r10)
	pushl	$49
	pushl	$8
	pushl	40(r11)
	calls	$3,_putctl1d
	jbr	L80
L78:
	movb	$1,23(r10)
	movw	$137,12(r10)
	pushl	$48
	pushl	$8
	pushl	40(r11)
	calls	$3,_putctl1d
L80:
L71:
	movl	$1,r0
	jbr	L66
	.stabs	"timer",0x26,0,4,L67
	.stabs	"dkpp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L66:
	ret
	.set	L.R3,0xc00
	.set	L.SO3,0x0
L81:	.data
	.text
	.align	2
	.globl	_dkpclose
_dkpclose:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"dkpclose",0x24,0,149,_dkpclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	calls	$0,_spl5
	movl	r0,r9
	movl	20(r11),r10
	bisw2	$2,12(r10)
	pushl	$1
	pushl	r11
	calls	$2,_flushq
	clrl	r8
	jbr	L87
L88:
	pushl	$1
	pushl	$28
	pushl	r10
	calls	$3,_tsleep
	incl	r8
L87:
	cmpb	21(r10),22(r10)
	jgeq	L90
	cmpl	r8,$15
	jlss	L88
L90:
L86:
	cmpb	21(r10),22(r10)
	jgeq	L91
	cvtbl	22(r10),r0
	decl	r0
	bicl2	$-8,r0
	addl3	$32,r0,-(sp)
	pushl	r10
	calls	$2,_dkprack
L91:
	pushl	r10
	calls	$1,_dkpinflush
	pushl	r9
	calls	$1,_splx
	clrw	12(r10)
	pushl	$1
	addl3	$28,r11,-(sp)
	calls	$2,_flushq
	.stabs	"i",0x40,0,4,8
	.stabs	"s",0x40,0,4,9
	.stabs	"dkpp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L82:
	ret
	.set	L.R4,0xf00
	.set	L.SO4,0x0
L95:	.data
	.text
	.align	2
	.globl	_dkpisrv
_dkpisrv:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"dkpisrv",0x24,0,174,_dkpisrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	jbr	L98
L99:
	cmpb	20(r9),$8
	jneq	L100
	movzbl	*4(r9),r0
	bicl3	$-249,r0,r8
	cmpl	r8,$24
	jeql	L102
	cmpl	r8,$16
	jneq	L101
L102:
	movb	*4(r9),19(r10)
	bisb2	$128,21(r9)
	pushl	r9
	pushl	40(r11)
	movl	*40(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L103
L101:
	pushl	r9
	calls	$1,_freeb
L103:
	jbr	L98
L100:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L106
	cmpb	20(r9),$64
	jgequ	L106
L107:
	bitw	$4,12(r10)
	jeql	L105
L106:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L108
L105:
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L96
L108:
L98:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L99
L97:
	.stabs	"c",0x40,0,4,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"dkpp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L96:
	ret
	.set	L.R5,0xf00
	.set	L.SO5,0x0
L110:	.data
	.text
	.align	2
	.globl	_dkpiput
_dkpiput:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"dkpiput",0x24,0,207,_dkpiput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	8(ap),r11
	movl	4(ap),r0
	movl	20(r0),r10
	jneq	L112
	pushl	r11
	calls	$1,_freeb
	jbr	L111
L112:
	movzbl	20(r11),r0
	jbr	L114
L115:
	incl	4(r11)
	clrb	20(r11)
L116:
	bicb2	$-128,21(r11)
	cmpl	4(r11),8(r11)
	jgequ	L118
	movl	4(ap),r0
	bitw	$8,26(r0)
	jneq	L118
L119:
	bitw	$2,12(r10)
	jeql	L117
L118:
	pushl	r11
	calls	$1,_freeb
	jbr	L111
L117:
	bitw	$128,12(r10)
	jeql	L120
	pushl	r11
	pushl	4(ap)
	calls	$2,_putq
	jbr	L111
L120:
	movzbl	14(r10),r0
	jbr	L122
L123:
L124:
	addl3	$26,r10,r0
	movb	14(r10),r1
	incb	14(r10)
	movzbl	r1,r1
	addl2	r1,r0
	movb	*4(r11),(r0)
	jbr	L115
L125:
	clrb	14(r10)
L126:
	jbr	L121
L122:
	casel	r0,$0,$2
L127:
	.word	L126-L127
	.word	L123-L127
	.word	L124-L127
	jbr	L125
L121:
	clrl	(r11)
	cmpw	16(r10),$4096
	jleq	L128
	pushl	r11
	calls	$1,_freeb
	jbr	L111
L128:
	tstl	4(r10)
	jeql	L129
	movl	r11,*8(r10)
	movl	r11,8(r10)
	jbr	L130
L129:
	movl	r11,4(r10)
	movl	r11,8(r10)
L130:
	subw3	4(r11),8(r11),r0
	addw2	r0,16(r10)
	jbr	L111
L131:
	movzbl	*4(r11),r0
	jbr	L133
L134:
	movzbl	19(r10),-(sp)
	pushl	$8
	movl	4(ap),r0
	pushl	40(r0)
	calls	$3,_putctl1
L136:
	movzbl	18(r10),r0
	addl3	$32,r0,-(sp)
	pushl	$8
	movl	4(ap),r0
	pushl	40(r0)
	calls	$3,_putctl1d
	pushl	r10
	calls	$1,_dkpinflush
	jbr	L115
L137:
	bicw2	$16,12(r10)
	bisw2	$1,12(r10)
	addl3	$28,4(ap),-(sp)
	calls	$1,_qenable
	pushl	r10
	calls	$1,_dkpinflush
	jbr	L115
L139:
L140:
	pushl	$50
	pushl	$8
	movl	4(ap),r0
	pushl	40(r0)
	calls	$3,_putctl1d
	cmpb	*4(r11),$48
	jneq	L141
	bitw	$128,12(r10)
	jneq	L141
L142:
	bisw2	$128,12(r10)
	movb	$1,23(r10)
	movl	4(ap),r0
	bicw2	$-65408,26(r0)
	jbr	L143
L141:
	cmpb	*4(r11),$49
	jneq	L144
	bitw	$128,12(r10)
	jeql	L144
L145:
	bicw2	$128,12(r10)
	movb	$3,23(r10)
	movl	4(ap),r0
	bisw2	$128,26(r0)
L144:
L143:
	pushl	r10
	calls	$1,_dkpinflush
	clrb	18(r10)
	pushl	r10
	calls	$1,_wakeup
	jbr	L115
L147:
	bitw	$8,12(r10)
	jeql	L148
	pushl	$48
	pushl	$8
	movl	4(ap),r0
	pushl	40(r0)
	calls	$3,_putctl1d
	jbr	L149
L148:
	cmpb	20(r10),22(r10)
	jgeq	L150
	cvtbl	22(r10),r0
	decl	r0
	bicl2	$-8,r0
	addl3	$16,r0,-(sp)
	pushl	r10
	calls	$2,_dkprack
L150:
	movb	$1,20(r10)
	movb	$1,21(r10)
	movb	$1,22(r10)
	pushl	$49
	pushl	$8
	movl	4(ap),r0
	pushl	40(r0)
	calls	$3,_putctl1d
L149:
	pushl	r10
	calls	$1,_dkpinflush
	jbr	L115
L151:
	pushl	$1
	pushl	4(ap)
	calls	$2,_qpctl
	incw	16(r10)
	jbr	L115
L153:
L154:
L155:
	movb	$1,14(r10)
	movb	*4(r11),26(r10)
	jbr	L115
L156:
L157:
L158:
L159:
L160:
L161:
L162:
L163:
	bitw	$8,12(r10)
	jeql	L164
	jbr	L115
L164:
	movzbl	*4(r11),r0
	incl	r0
	bicl2	$-8,r0
	cvtbl	21(r10),r1
	bicl2	$-8,r1
	cmpl	r0,r1
	jneq	L165
	bitw	$32,12(r10)
	jneq	L165
L166:
	incl	_dkstat+48
	cvtbl	21(r10),r9
	jbr	L169
L170:
	bisw2	$32,12(r10)
	pushl	r9
	addl3	$32,r10,r0
	bicl3	$-8,r9,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	pushl	(r0)
	addl3	$28,4(ap),-(sp)
	calls	$3,_dkpxmit
	incl	r9
L169:
	cvtbl	22(r10),r0
	cmpl	r9,r0
	jlss	L170
L168:
L165:
	jbr	L115
L172:
L173:
L174:
L175:
L176:
L177:
L178:
L179:
L180:
L181:
L182:
L183:
L184:
L185:
L186:
L187:
	movzbl	*4(r11),-(sp)
	pushl	r10
	calls	$2,_dkprack
	jbr	L115
L188:
L189:
L190:
L191:
L192:
L193:
L194:
L195:
	movzbl	*4(r11),r0
	bicl3	$-8,r0,r9
	bitw	$128,12(r10)
	jeql	L196
	addl3	$16,r9,-(sp)
	pushl	$8
	pushl	4(ap)
	calls	$3,_qpctl1
	jbr	L115
L196:
	cmpb	14(r10),$3
	jneq	L199
	cvtwl	16(r10),r0
	movzbl	27(r10),r1
	movzbl	28(r10),r2
	ashl	$8,r2,r2
	addl2	r2,r1
	cmpl	r0,r1
	jneq	L199
L200:
	movzbl	18(r10),r0
	incl	r0
	bicl2	$-8,r0
	cmpl	r9,r0
	jeql	L198
L199:
	cmpb	14(r10),$3
	jeql	L201
	incl	_dkstat+52
	jbr	L202
L201:
	movzbl	18(r10),r0
	incl	r0
	bicl2	$-8,r0
	cmpl	r9,r0
	jeql	L203
	incl	_dkstat+60
	jbr	L204
L203:
	incl	_dkstat+56
L204:
L202:
	pushl	r10
	calls	$1,_dkpinflush
	cmpb	26(r10),$42
	jneq	L205
	movb	r9,18(r10)
L205:
	movzbl	18(r10),r0
	addl3	$24,r0,-(sp)
	pushl	$8
	pushl	4(ap)
	calls	$3,_qpctl1
	jbr	L115
L198:
	tstl	8(r10)
	jneq	L206
	pushl	$0
	calls	$1,_allocb
	movl	r0,8(r10)
	movl	r0,4(r10)
L206:
	cmpb	26(r10),$41
	jeql	L207
	movl	4(ap),r0
	bitw	$128,26(r0)
	jeql	L207
L208:
	movl	8(r10),r0
	bisb2	$128,21(r0)
L207:
	jbr	L210
L211:
	movl	(r8),4(r10)
	pushl	r8
	pushl	4(ap)
	calls	$2,_putq
L210:
	movl	4(r10),r8
	jneq	L211
L209:
	clrl	8(r10)
	clrb	14(r10)
	clrw	16(r10)
	movb	r9,18(r10)
	addl3	$16,r9,-(sp)
	pushl	$8
	pushl	4(ap)
	calls	$3,_qpctl1
	jbr	L115
L212:
	movzbl	*4(r11),r0
	cmpl	r0,$128
	jgequ	L213
	incw	16(r10)
L213:
	movb	*4(r11),15(r10)
	movzbl	*4(r11),-(sp)
	pushl	$8
	pushl	4(ap)
	calls	$3,_qpctl1
	jbr	L115
L133:
	casel	r0,$8,$64
L214:
	.word	L188-L214
	.word	L189-L214
	.word	L190-L214
	.word	L191-L214
	.word	L192-L214
	.word	L193-L214
	.word	L194-L214
	.word	L195-L214
	.word	L180-L214
	.word	L181-L214
	.word	L182-L214
	.word	L183-L214
	.word	L184-L214
	.word	L185-L214
	.word	L186-L214
	.word	L187-L214
	.word	L156-L214
	.word	L157-L214
	.word	L158-L214
	.word	L159-L214
	.word	L160-L214
	.word	L161-L214
	.word	L162-L214
	.word	L163-L214
	.word	L172-L214
	.word	L173-L214
	.word	L174-L214
	.word	L175-L214
	.word	L176-L214
	.word	L177-L214
	.word	L178-L214
	.word	L179-L214
	.word	L153-L214
	.word	L155-L214
	.word	L154-L214
	.word	L212-L214
	.word	L212-L214
	.word	L134-L214
	.word	L136-L214
	.word	L147-L214
	.word	L139-L214
	.word	L140-L214
	.word	L137-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L212-L214
	.word	L151-L214
	jbr	L212
L132:
L215:
	bisw2	$4,12(r10)
	pushl	$1
	addl3	$28,4(ap),-(sp)
	calls	$2,_flushq
	cvtbl	22(r10),r0
	decl	r0
	bicl2	$-8,r0
	addl3	$16,r0,-(sp)
	pushl	r10
	calls	$2,_dkprack
	pushl	r11
	pushl	4(ap)
	calls	$2,_putq
	jbr	L111
L216:
L217:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L111
L218:
	cmpb	*4(r11),$1
	jeql	L219
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L111
L219:
	movb	$8,20(r11)
	movl	4(r11),8(r11)
	movl	8(r11),r0
	incl	8(r11)
	movb	$47,(r0)
	pushl	r11
	pushl	4(ap)
	calls	$2,_dkpiput
	pushl	$47
	pushl	$8
	movl	4(ap),r0
	pushl	40(r0)
	calls	$3,_putctl1d
	jbr	L111
L220:
	pushl	r11
	calls	$1,_freeb
	jbr	L111
L114:
	cmpl	r0,$0
	jeql	L116
	cmpl	r0,$2
	jeql	L215
	cmpl	r0,$8
	jeql	L131
	cmpl	r0,$69
	jeql	L216
	cmpl	r0,$70
	jeql	L217
	cmpl	r0,$71
	jeql	L218
	jbr	L220
L113:
	.stabs	"nbp",0x40,0,40,8
	.stabs	"i",0x40,0,4,9
	.stabs	"dkpp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L111:
	ret
	.set	L.R6,0xf00
	.set	L.SO6,0x0
L221:	.data
	.align	2
	.globl	_dkpwbig
_dkpwbig:
	.long	200
	.text
	.align	2
	.globl	_dkpoput
_dkpoput:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"dkpoput",0x24,0,436,_dkpoput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	bitw	$4,12(r9)
	jeql	L224
	pushl	r10
	calls	$1,_freeb
	jbr	L223
L224:
	movzbl	20(r10),r0
	jbr	L226
L227:
	bisw2	$64,12(r9)
	pushl	r10
	calls	$1,_freeb
	jbr	L223
L228:
	bicw2	$64,12(r9)
	pushl	r10
	calls	$1,_freeb
	pushl	r11
	calls	$1,_qenable
	jbr	L223
L229:
	pushl	r10
	calls	$1,_freeb
	calls	$0,_spl5
	movl	r0,r6
	clrl	r7
	jbr	L232
L233:
	addl3	$32,r9,r0
	addl3	r7,r7,r1
	addl2	r1,r1
	addl2	r1,r0
	movl	(r0),r10
	jeql	L234
	movl	4(r10),8(r10)
L234:
	incl	r7
L232:
	cmpl	r7,$8
	jlss	L233
L231:
	pushl	r6
	calls	$1,_splx
	pushl	$0
	pushl	r11
	calls	$2,_flushq
	jbr	L223
L235:
	addl3	$4,4(r10),r8
	movzbl	*4(r10),r0
	movl	4(r10),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl2	r1,r0
	jbr	L237
L238:
	cvtbl	(r8),r7
	movl	4(r10),8(r10)
	movb	$69,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	tstl	r7
	jneq	L240
	pushl	$2
	bitw	$16,26(r11)
	jeql	L241
	addl3	$28,r11,-(sp)
	jbr	L242
L241:
	subl3	$28,r11,-(sp)
L242:
	calls	$2,_putctl
L240:
	jbr	L223
L243:
	movb	$13,r0
	movb	r0,1(r8)
	movb	r0,(r8)
	addl3	$8,4(r10),8(r10)
	cmpl	8(r10),12(r10)
	jlssu	L244
	.data	1
L246:

	.byte	0x64,0x6b,0x69,0x6f,0x63,0x0
	.text
	pushl	$L246
	calls	$1,_panic
L244:
	movb	$69,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L247:
	bicw2	$-65408,-2(r11)
	movl	4(r10),8(r10)
	movb	$69,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L248:
	bitw	$128,12(r9)
	jneq	L249
	bisw2	$128,-2(r11)
	movb	$69,20(r10)
	jbr	L250
L249:
	movb	$70,20(r10)
L250:
	movl	4(r10),8(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L251:
	bitw	$8,12(r9)
	jeql	L252
	pushl	$48
	pushl	$8
	pushl	12(r11)
	calls	$3,_putctl1d
	jbr	L253
L252:
	calls	$0,_spl5
	movl	r0,r6
	cmpb	20(r9),22(r9)
	jgeq	L254
	cvtbl	22(r9),r0
	decl	r0
	bicl2	$-8,r0
	addl3	$16,r0,-(sp)
	pushl	r9
	calls	$2,_dkprack
L254:
	movb	$1,20(r9)
	movb	$1,21(r9)
	movb	$1,22(r9)
	pushl	r6
	calls	$1,_splx
	pushl	$49
	pushl	$8
	pushl	12(r11)
	calls	$3,_putctl1d
L253:
	movl	4(r10),8(r10)
	movb	$69,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L255:
	movl	4(r10),8(r10)
	movb	$69,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L256:
	movb	$69,20(r10)
	movl	4(r10),8(r10)
	tstb	(r8)
	jneq	L257
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L257:
	pushl	$1
	calls	$1,_allocb
	movl	r0,-4(fp)
	jneq	L258
	movb	$70,20(r10)
	jbr	L259
L258:
	movl	-4(fp),r0
	movb	$8,20(r0)
	movl	-4(fp),r0
	bisb2	$128,21(r0)
	movl	-4(fp),r0
	movl	8(r0),r1
	incl	8(r0)
	movb	(r8),(r1)
	pushl	-4(fp)
	pushl	r11
	calls	$2,_putq
	cvtbl	22(r9),r0
	cvtbl	20(r9),r1
	movzbl	23(r9),r2
	addl2	r2,r1
	cmpl	r0,r1
	jgequ	L260
	pushl	r11
	calls	$1,_qenable
L260:
L259:
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L261:
	movb	15(r9),(r8)
	clrb	15(r9)
	movb	$69,20(r10)
	addl3	$1,r8,8(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L262:
	movb	$69,20(r10)
	cmpb	4(r8),$8
	jgequ	L264
	tstb	4(r8)
	jneq	L263
L264:
	movb	$70,20(r10)
	jbr	L265
L263:
	movzbl	(r8),r0
	movzbl	1(r8),r1
	ashl	$8,r1,r1
	addl3	r1,r0,r7
	jlss	L267
	cmpl	r7,$4096
	jleq	L266
L267:
	movb	$70,20(r10)
	jbr	L268
L266:
	movw	r7,30(r9)
	movb	4(r8),23(r9)
	cmpl	r7,_dkpwbig
	jleq	L269
	bisw2	$256,26(r11)
	jbr	L270
L269:
	bicw2	$-65280,26(r11)
L270:
L268:
L265:
	movl	4(r10),8(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L223
L271:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L223
L237:
	cmpl	r0,$27393
	jeql	L255
	jgtr	L272
	cmpl	r0,$25643
	jeql	L256
	jgtr	L273
	cmpl	r0,$25635
	jeql	L248
	jgtr	L274
	cmpl	r0,$25634
	jeql	L247
	jbr	L271
L274:
	cmpl	r0,$25642
	jeql	L262
	jbr	L271
L273:
	cmpl	r0,$25644
	jeql	L261
	jbr	L271
L272:
	cmpl	r0,$29719
	jeql	L243
	jgtr	L275
	cmpl	r0,$27394
	jeql	L251
	jbr	L271
L275:
	cmpl	r0,$29720
	jeql	L238
	jbr	L271
	jbr	L271
L236:
L276:
	movzbl	*4(r10),r7
	movb	$64,*4(r10)
	movb	$8,20(r10)
	jbr	L278
L279:
	incb	*4(r10)
	extzv	$1,$31,r7,r7
L278:
	tstl	r7
	jneq	L279
L277:
	jbr	L280
L281:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L223
L282:
	pushl	r10
	calls	$1,_freeb
	jbr	L223
L283:
	movb	$8,20(r10)
	movl	8(r10),r0
	incl	8(r10)
	movb	$72,(r0)
L284:
L285:
L280:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	cvtbl	22(r9),r0
	cvtbl	20(r9),r1
	movzbl	23(r9),r2
	addl2	r2,r1
	cmpl	r0,r1
	jgequ	L286
	pushl	r11
	calls	$1,_qenable
L286:
	jbr	L223
L226:
	casel	r0,$0,$71
L287:
	.word	L284-L287
	.word	L283-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L235-L287
	.word	L276-L287
	.word	L285-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L282-L287
	.word	L229-L287
	.word	L227-L287
	.word	L228-L287
	.word	L282-L287
	.word	L282-L287
	.word	L281-L287
	jbr	L282
L225:
	.stabs	"xbp",0x80,0,40,4
	.stabs	"s",0x40,0,4,6
	.stabs	"x",0x40,0,4,7
	.stabs	"sp",0x40,0,44,8
	.stabs	"dkpp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L223:
	ret
	.set	L.R7,0xfc0
	.set	L.SO7,0x4
L288:	.data
	.text
	.align	2
	.globl	_dkposrv
_dkposrv:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"dkposrv",0x24,0,624,_dkposrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	bitw	$80,12(r10)
	jeql	L290
	jbr	L289
L290:
	jbr	L292
L293:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L294
	jbr	L291
L294:
	tstb	20(r9)
	jneq	L295
	subl3	4(r9),8(r9),r0
	cvtwl	30(r10),r1
	cmpl	r0,r1
	jleq	L295
L296:
	pushl	r9
	calls	$1,_dupb
	movl	r0,r8
	cvtwl	30(r10),r0
	addl2	r0,4(r9)
	cvtwl	30(r10),r0
	addl3	r0,4(r8),8(r8)
	bicb2	$-128,21(r8)
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	movl	r8,r9
L295:
	bitw	$8,12(r10)
	jeql	L297
	subb3	4(r9),8(r9),r0
	addb2	r0,25(r10)
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	movzbl	25(r10),r0
	cvtwl	30(r10),r1
	cmpl	r0,r1
	jlssu	L298
	cvtbl	22(r10),r0
	bicl2	$-8,r0
	addl3	$8,r0,-(sp)
	pushl	$8
	pushl	12(r11)
	calls	$3,_putctl1d
	incb	22(r10)
	movb	22(r10),21(r10)
	clrb	25(r10)
L298:
	jbr	L292
L297:
	addl3	$32,r10,r0
	cvtbl	22(r10),r1
	bicl2	$-8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl3	r1,r0,r6
	tstl	(r6)
	jeql	L299
	calls	$0,_spl5
	movl	r0,-4(fp)
	tstl	(r6)
	jeql	L300
	pushl	(r6)
	calls	$1,_freeb
	.data	1
L302:

	.byte	0x64,0x6b,0x70,0x20,0x6c,0x6f,0x73,0x69
	.byte	0x6e,0x67,0x20,0x62,0x6c,0x6f,0x63,0x6b
	.byte	0x20,0x25,0x78,0xa,0x0
	.text
	pushl	(r6)
	pushl	$L302
	calls	$2,_printf
	clrl	(r6)
L300:
	pushl	-4(fp)
	calls	$1,_splx
L299:
	movl	r9,(r6)
	movb	22(r10),r0
	incb	22(r10)
	cvtbl	r0,r7
	pushl	r7
	pushl	r9
	pushl	r11
	calls	$3,_dkpxmit
L292:
	cvtbl	22(r10),r0
	cvtbl	20(r10),r1
	movzbl	23(r10),r2
	addl2	r2,r1
	cmpl	r0,r1
	jlssu	L293
L291:
	.stabs	"s",0x80,0,4,4
	.stabs	"bpp",0x40,0,168,6
	.stabs	"seqno",0x40,0,4,7
	.stabs	"xbp",0x40,0,40,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"dkpp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L289:
	ret
	.set	L.R8,0xfc0
	.set	L.SO8,0x4
L303:	.data
	.text
	.align	2
	.globl	_dkpxmit
_dkpxmit:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"dkpxmit",0x24,0,684,_dkpxmit
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	.stabs	"seqno",0xa0,0,4,12
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r7
	tstl	r10
	jneq	L305
	.data	1
L306:

	.byte	0x6e,0x75,0x6c,0x6c,0x20,0x62,0x70,0x20
	.byte	0x69,0x6e,0x20,0x64,0x6b,0x70,0x78,0x6d
	.byte	0x69,0x74,0xa,0x0
	.text
	pushl	$L306
	calls	$1,_printf
	jbr	L304
L305:
	subl3	4(r10),8(r10),r9
	bicl2	$-8,12(ap)
	tstl	r9
	jeql	L307
	pushl	r10
	calls	$1,_dupb
	movl	r0,r8
	jneq	L308
	jbr	L304
L308:
	bicb2	$-128,21(r8)
	pushl	r8
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L307:
	pushl	$3
	calls	$1,_allocb
	movl	r0,r8
	jneq	L309
	jbr	L304
L309:
	movb	$8,20(r8)
	movl	8(r8),r0
	incl	8(r8)
	bitb	$128,21(r10)
	jeql	L310
	movl	$40,r1
	jbr	L311
L310:
	movl	$41,r1
L311:
	movb	r1,(r0)
	movl	8(r8),r0
	incl	8(r8)
	movb	r9,(r0)
	movl	8(r8),r0
	incl	8(r8)
	extzv	$8,$24,r9,r1
	movb	r1,(r0)
	pushl	r8
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	addl3	$8,12(ap),-(sp)
	pushl	$8
	pushl	12(r11)
	calls	$3,_putctl1d
	movb	$2,24(r7)
	.stabs	"dkpp",0x40,0,40,7
	.stabs	"xbp",0x40,0,40,8
	.stabs	"size",0x40,0,4,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L304:
	ret
	.set	L.R9,0xf80
	.set	L.SO9,0x0
L312:	.data
	.text
	.align	2
	.globl	_dkprack
_dkprack:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"dkprack",0x24,0,722,_dkprack
	.stabs	"dkpp",0xa0,0,40,4
	.stabs	"msg",0xa0,0,4,8
	movl	4(ap),r11
	bicl3	$-8,8(ap),r9
	bicl2	$-249,8(ap)
	cvtbl	22(r11),r0
	cmpl	r9,r0
	jlss	L314
	subl2	$8,r9
	jbr	L315
L314:
	addl3	$8,r9,r0
	cvtbl	22(r11),r1
	cmpl	r0,r1
	jgeq	L316
	addl2	$8,r9
L316:
L315:
	bicw2	$32,12(r11)
	cvtbl	20(r11),r8
	jbr	L319
L320:
	addl3	$32,r11,r0
	bicl3	$-8,r8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl3	r1,r0,r10
	tstl	(r10)
	jeql	L321
	pushl	(r10)
	calls	$1,_freeb
	clrl	(r10)
L321:
	incl	r8
L319:
	cmpl	r8,r9
	jleq	L320
L318:
	cvtbl	21(r11),r0
	cmpl	r0,r9
	jgtr	L322
	movb	r9,r0
	addb3	$1,r0,21(r11)
L322:
	cmpl	8(ap),$16
	jneq	L323
	cvtbl	20(r11),r0
	cmpl	r0,r9
	jgtr	L324
	movb	$2,24(r11)
	movb	r9,r0
	addb3	$1,r0,20(r11)
	cvtbl	22(r11),r0
	cvtbl	20(r11),r1
	movzbl	23(r11),r2
	addl2	r2,r1
	cmpl	r0,r1
	jgequ	L325
	movl	(r11),r0
	tstw	52(r0)
	jeql	L325
L326:
	addl3	$28,(r11),-(sp)
	calls	$1,_qenable
L325:
L324:
	jbr	L327
L323:
	cvtbl	21(r11),r8
	jbr	L330
L331:
	addl3	$32,r11,r0
	bicl3	$-8,r8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	tstl	(r0)
	jneq	L332
	.data	1
L333:

	.byte	0x57,0x53,0x20,0x25,0x64,0x20,0x57,0x41
	.byte	0x43,0x4b,0x20,0x25,0x64,0x20,0x57,0x4e
	.byte	0x58,0x20,0x25,0x64,0x20,0x69,0x20,0x25
	.byte	0x64,0x20,0x73,0x65,0x71,0x6e,0x6f,0x20
	.byte	0x25,0x64,0xa,0x0
	.text
	pushl	r9
	pushl	r8
	cvtbl	22(r11),-(sp)
	cvtbl	21(r11),-(sp)
	cvtbl	20(r11),-(sp)
	pushl	$L333
	calls	$6,_printf
L332:
	pushl	r8
	addl3	$32,r11,r0
	bicl3	$-8,r8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	pushl	(r0)
	addl3	$28,(r11),-(sp)
	calls	$3,_dkpxmit
	incl	_dkstat+48
	incl	r8
L330:
	cvtbl	22(r11),r0
	cmpl	r8,r0
	jlss	L331
L329:
L327:
	cmpb	20(r11),$8
	jlss	L334
	subb2	$8,20(r11)
	subb2	$8,21(r11)
	subb2	$8,22(r11)
L334:
	.stabs	"i",0x40,0,4,8
	.stabs	"seqno",0x40,0,4,9
	.stabs	"bpp",0x40,0,168,10
	.stabs	"dkpp",0x40,0,40,11
L313:
	ret
	.set	L.R10,0xf00
	.set	L.SO10,0x0
L335:	.data
	.text
	.align	2
	.globl	_dkptimer
_dkptimer:
	.word	L.R11
	subl2	$L.SO11,sp
	.stabs	"dkptimer",0x24,0,768,_dkptimer
	movl	$_dkp,r11
	movl	_dkpcnt,r9
	jbr	L339
L340:
	bitw	$17,12(r11)
	jneq	L341
	jbr	L337
L341:
	decb	24(r11)
	jeql	L342
	jbr	L337
L342:
	movl	(r11),r0
	movl	40(r0),r10
	bitw	$8,26(r10)
	jeql	L343
	jbr	L337
L343:
	bitw	$8,12(r11)
	jeql	L344
	cmpb	20(r11),22(r11)
	jgeq	L345
	cvtbl	22(r11),r0
	decl	r0
	bicl2	$-8,r0
	addl3	$8,r0,-(sp)
	pushl	$8
	pushl	r10
	calls	$3,_putctl1d
L345:
	movb	$10,24(r11)
	jbr	L337
L344:
	bitw	$16,12(r11)
	jeql	L346
	pushl	$49
	pushl	$8
	pushl	r10
	calls	$3,_putctl1d
L346:
	cmpb	20(r11),22(r11)
	jeql	L347
	pushl	$45
	pushl	$8
	pushl	r10
	calls	$3,_putctl1d
L347:
	movb	$2,24(r11)
L337:
	addl2	$64,r11
	decl	r9
L339:
	tstl	r9
	jgtr	L340
L338:
	pushl	$60
	pushl	$0
	pushl	$_dkptimer
	calls	$3,_timeout
	.stabs	"i",0x40,0,4,9
	.stabs	"q",0x40,0,40,10
	.stabs	"dkpp",0x40,0,40,11
L336:
	ret
	.set	L.R11,0xe00
	.set	L.SO11,0x0
L348:	.data
	.text
	.align	2
	.globl	_dkpinflush
_dkpinflush:
	.word	L.R12
	subl2	$L.SO12,sp
	.stabs	"dkpinflush",0x24,0,801,_dkpinflush
	.stabs	"dkpp",0xa0,0,40,4
	movl	4(ap),r11
	jbr	L351
L352:
	movl	(r10),4(r11)
	pushl	r10
	calls	$1,_freeb
L351:
	movl	4(r11),r10
	jneq	L352
L350:
	clrl	8(r11)
	clrb	14(r11)
	clrw	16(r11)
	.stabs	"bp",0x40,0,40,10
	.stabs	"dkpp",0x40,0,40,11
L349:
	ret
	.set	L.R12,0xc00
	.set	L.SO12,0x0
L353:	.data
	.stabs	"dkpwinit",0x26,0,8,_dkpwinit
	.stabs	"dkprinit",0x26,0,8,_dkprinit
	.stabs	"cdkpwinit",0x26,0,8,_cdkpwinit
	.stabs	"cdkprinit",0x26,0,8,_cdkprinit
	.text
L354:	.stabs	"dkp.c",0x94,0,812,L354
