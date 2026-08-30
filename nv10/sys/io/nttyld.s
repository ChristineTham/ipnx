L11:	.stabs	"nttyld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553296
	.data
	.comm	_nswdevt,4
	.align	2
_rinit:
	.long	_ntin
	.long	_ntinsrv
	.long	_ntopen
	.long	_ntclose
	.long	0x12c
	.align	2
_winit:
	.long	_ntout
	.long	_ntoutsrv
	.long	_ntopen
	.long	_ntclose
	.long	0xc8012c
	.align	2
	.globl	_nttystream
_nttystream:
	.long	_rinit
	.long	_winit
	.text
	.align	2
	.globl	_ntbs
_ntbs:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"ntbs",0x24,0,38,_ntbs
	.stabs	"nt",0xa0,0,40,4
	.stabs	"n",0xa0,0,4,8
	movl	4(ap),r11
	movl	8(ap),r10
	jbr	L64
L65:
	pushl	$8
	pushl	(r11)
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L67
	bisw2	$32,268(r11)
	bitw	$4,284(r11)
	jeql	L68
	pushl	$32
	pushl	(r11)
	pushl	$_putq
	calls	$3,_putd
	pushl	$8
	pushl	(r11)
	pushl	$_putq
	calls	$3,_putd
L68:
L67:
L64:
	decl	r10
	jgeq	L65
L63:
	jbr	L62
	.stabs	"n",0x40,0,4,10
	.stabs	"nt",0x40,0,40,11
L62:
	ret
	.set	L.R1,0xc00
	.set	L.SO1,0x0
L69:	.data
	.text
	.align	2
	.globl	_ntchars
_ntchars:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"ntchars",0x24,0,58,_ntchars
	.stabs	"nt",0xa0,0,40,4
	movl	4(ap),r11
	.data
L72:
	.long	0x13111c7f
	.long	0xff04
L73:
	.long	0xf12191a
	.long	0x1617
	.text
	movb	$8,272(r11)
	movb	$64,273(r11)
	addl3	$274,r11,r0
	movc3	$6,L72,(r0)
	addl3	$288,r11,r0
	movc3	$6,L73,(r0)
	jbr	L71
	.stabs	"ltchars",0x26,0,8,L73
	.stabs	"tchars",0x26,0,8,L72
	.stabs	"nt",0x40,0,40,11
L71:
	ret
	.set	L.R2,0x800
	.set	L.SO2,0x0
L74:	.data
	.text
	.align	2
	.globl	_ntclose
_ntclose:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"ntclose",0x24,0,74,_ntclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	clrw	268(r10)
	jbr	L75
	.stabs	"nt",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L75:
	ret
	.set	L.R3,0xc00
	.set	L.SO3,0x0
L76:	.data
	.text
	.align	2
	.globl	_ntcooked
_ntcooked:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"ntcooked",0x24,0,90,_ntcooked
	.stabs	"nt",0xa0,0,40,4
	movl	4(ap),r11
	subl3	$28,(r11),r7
	bitw	$8,26(r7)
	jneq	L79
	pushl	$1
	calls	$1,_allocb
	movl	r0,r8
	jeql	L79
L80:
	addl3	$8,r11,r10
	cvtwl	264(r11),r0
	addl3	r0,r10,r9
	jbr	L83
L84:
	cvtbl	(r10),-(sp)
	pushl	r7
	pushl	$_putq
	calls	$3,_putd
	incl	r10
L83:
	cmpl	r10,r9
	jlssu	L84
L82:
	bisb2	$128,21(r8)
	pushl	r8
	pushl	r7
	calls	$2,_putq
	incb	271(r11)
L79:
	pushl	r7
	calls	$1,_qenable
	clrw	264(r11)
	clrw	280(r11)
	jbr	L78
	.stabs	"q",0x40,0,40,7
	.stabs	"b",0x40,0,40,8
	.stabs	"t",0x40,0,34,9
	.stabs	"s",0x40,0,34,10
	.stabs	"nt",0x40,0,40,11
L78:
	ret
	.set	L.R4,0xf80
	.set	L.SO4,0x0
L86:	.data
	.text
	.align	2
	.globl	_ntecho
_ntecho:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"ntecho",0x24,0,116,_ntecho
	.stabs	"c",0xa0,0,4,4
	.stabs	"nt",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	(r10),r9
	bicw2	$128,284(r10)
	bitw	$8,266(r10)
	jeql	L90
	bitw	$8,26(r9)
	jeql	L89
L90:
	jbr	L88
L89:
	bicl2	$-256,r11
	bitw	$32,266(r10)
	jeql	L91
	jbr	L92
L91:
	cmpl	r11,$13
	jneq	L93
	bitw	$16,266(r10)
	jeql	L93
L94:
	movl	$10,r11
L93:
	cmpl	r11,$10
	jeql	L95
	cmpl	r11,$9
	jeql	L95
L97:
	bitw	$4096,284(r10)
	jeql	L95
L96:
	bicl2	$-128,r11
	cmpl	r11,$31
	jleq	L99
	cmpl	r11,$127
	jneq	L98
L99:
	pushl	$94
	pushl	r9
	pushl	$_putq
	calls	$3,_putd
	cmpl	r11,$127
	jneq	L100
	movl	$63,r11
	jbr	L101
L100:
	bitw	$4,266(r10)
	jeql	L102
	addl2	$96,r11
	jbr	L103
L102:
	addl2	$64,r11
L103:
L101:
	jbr	L92
L98:
L95:
	bicl2	$-128,r11
	cmpl	r11,$4
	jneq	L104
	jbr	L88
L104:
L92:
	pushl	r11
	pushl	r9
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L105
	bisw2	$32,268(r10)
L105:
	jbr	L88
	.stabs	"echoq",0x40,0,40,9
	.stabs	"nt",0x40,0,40,10
	.stabs	"c",0x40,0,4,11
L88:
	ret
	.set	L.R5,0xe00
	.set	L.SO5,0x0
L106:	.data
	.text
	.align	2
	.globl	_ntflush
_ntflush:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"ntflush",0x24,0,155,_ntflush
	.stabs	"nt",0xa0,0,40,4
	.stabs	"rw",0xa0,0,4,8
	movl	*4(ap),-4(fp)
	subl3	$28,-4(fp),-8(fp)
	bitl	$1,8(ap)
	jeql	L109
	pushl	$0
	pushl	-8(fp)
	calls	$2,_flushq
	pushl	$66
	movl	-8(fp),r0
	pushl	12(r0)
	calls	$2,_putctl
	movl	4(ap),r0
	clrb	271(r0)
	movl	4(ap),r0
	clrw	264(r0)
	movl	4(ap),r0
	clrw	280(r0)
	movl	4(ap),r0
	clrw	286(r0)
L109:
	bitl	$2,8(ap)
	jeql	L112
	pushl	$0
	pushl	-4(fp)
	calls	$2,_flushq
	pushl	$66
	movl	-4(fp),r0
	pushl	12(r0)
	calls	$2,_putctl
L112:
	jbr	L108
	.stabs	"rdq",0x80,0,40,8
	.stabs	"wrq",0x80,0,40,4
L108:
	ret
	.set	L.R6,0x0
	.set	L.SO6,0x8
L113:	.data
	.text
	.align	2
	.globl	_ntin
_ntin:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"ntin",0x24,0,182,_ntin
	.stabs	"q",0xa0,0,40,4
	.stabs	"b",0xa0,0,40,8
	movl	8(ap),r11
	movl	4(ap),r0
	movl	20(r0),r10
	movzbl	20(r11),r0
	jbr	L116
L117:
	bitw	$32,266(r10)
	jeql	L118
	bitw	$8,266(r10)
	jneq	L118
L119:
	jbr	L115
L118:
	bicw2	$32,268(r10)
	jbr	L121
L122:
	pushl	r10
	movl	4(r11),r0
	incl	4(r11)
	movzbl	(r0),-(sp)
	calls	$2,_ntinc
L121:
	cmpl	4(r11),8(r11)
	jlssu	L122
L120:
	pushl	r11
	calls	$1,_freeb
	bitw	$32,268(r10)
	jeql	L125
	movl	(r10),r0
	movl	12(r0),r0
	bitw	$128,26(r0)
	jeql	L125
L126:
	pushl	$0
	pushl	(r10)
	calls	$2,_qpctld
L125:
	jbr	L114
L128:
	bitw	$32,266(r10)
	jeql	L129
	clrb	20(r11)
	cmpl	8(r11),12(r11)
	jgequ	L130
	movl	8(r11),r0
	incl	8(r11)
	clrb	(r0)
L130:
	jbr	L115
L129:
	pushl	$2
	pushl	$65
	movl	4(ap),r0
	pushl	12(r0)
	calls	$3,_putctl1
	pushl	$3
	pushl	r10
	calls	$2,_ntflush
	pushl	r11
	calls	$1,_freeb
	jbr	L114
L132:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
	jbr	L114
L116:
	casel	r0,$0,$2
L133:
	.word	L117-L133
	.word	L128-L133
	.word	L132-L133
L134:
L115:
	movl	4(ap),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L135
	pushl	r11
	calls	$1,_freeb
	jbr	L136
L135:
	pushl	r11
	movl	4(ap),r0
	pushl	12(r0)
	movl	4(ap),r0
	movl	*12(r0),r1
	movl	(r1),r0
	calls	$2,(r0)
L136:
	jbr	L114
	.stabs	"nt",0x40,0,40,10
	.stabs	"b",0x40,0,40,11
L114:
	ret
	.set	L.R7,0xc00
	.set	L.SO7,0x0
L137:	.data
	.text
	.align	2
	.globl	_ntinc
_ntinc:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"ntinc",0x24,0,227,_ntinc
	.stabs	"c",0xa0,0,4,4
	.stabs	"nt",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	bicl2	$-256,r11
	cvtwl	266(r10),r9
	bitl	$32,r9
	jeql	L139
	movl	4(r10),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jneq	L140
	pushl	r11
	movl	4(r10),r0
	pushl	12(r0)
	movl	4(r10),r0
	movl	*12(r0),r1
	pushl	(r1)
	calls	$3,_putd
	tstl	r0
	jeql	L141
	pushl	r10
	pushl	r11
	calls	$2,_ntecho
L141:
L140:
	jbr	L138
L139:
	bitw	$16,286(r10)
	jneq	L142
	bicl2	$-128,r11
L142:
	bitw	$8,286(r10)
	jeql	L143
	bisl2	$128,r11
	bicw2	$8,286(r10)
L143:
	cvtbl	293(r10),r0
	cmpl	r11,r0
	jneq	L144
	bisw2	$8,286(r10)
	bitw	$8,266(r10)
	jeql	L145
	pushl	$94
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L146
	bisw2	$32,268(r10)
	pushl	$8
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
L146:
L145:
	jbr	L138
L144:
	pushl	r10
	pushl	r11
	calls	$2,_ntstst
	tstl	r0
	jneq	L151
	pushl	r10
	pushl	r11
	calls	$2,_ntoflush
	tstl	r0
	jneq	L151
L152:
	pushl	r10
	pushl	r11
	calls	$2,_ntsigc
	tstl	r0
	jeql	L150
L151:
	jbr	L138
L150:
	cmpl	r11,$13
	jneq	L153
	bitl	$16,r9
	jeql	L153
L154:
	movl	$10,r11
L153:
	bitl	$4,r9
	jeql	L155
	cmpl	r11,$65
	jlss	L155
L157:
	cmpl	r11,$90
	jgtr	L155
L156:
	addl2	$32,r11
L155:
	bitl	$2,r9
	jeql	L158
	movl	4(r10),r0
	movl	12(r0),r0
	bitw	$8,26(r0)
	jeql	L159
	pushl	$7
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L160
	bisw2	$32,268(r10)
L160:
	jbr	L161
L159:
	bicl3	$-128,r11,-(sp)
	movl	4(r10),r0
	pushl	12(r0)
	movl	4(r10),r0
	movl	*12(r0),r1
	pushl	(r1)
	calls	$3,_putd
	tstl	r0
	jeql	L162
	pushl	r10
	pushl	r11
	calls	$2,_ntecho
L162:
L161:
	jbr	L138
L158:
	bitw	$2,286(r10)
	jeql	L163
	bicw2	$2,286(r10)
	cvtbl	272(r10),r0
	cmpl	r11,r0
	jeql	L165
	cvtbl	273(r10),r0
	cmpl	r11,r0
	jneq	L164
L165:
	bisl2	$128,r11
	pushl	r10
	calls	$1,_ntrubout
L164:
L163:
	cmpl	r11,$92
	jneq	L167
	bisw2	$2,286(r10)
L167:
	cvtbl	272(r10),r0
	cmpl	r11,r0
	jneq	L168
	pushl	r10
	calls	$1,_ntrubout
	jbr	L169
L168:
	cvtbl	273(r10),r0
	cmpl	r11,r0
	jneq	L170
	pushl	r10
	calls	$1,_ntkill
	jbr	L172
L170:
	cvtbl	292(r10),r0
	cmpl	r11,r0
	jneq	L173
	pushl	r10
	calls	$1,_ntwerase
	jbr	L175
L173:
	cvtbl	290(r10),r0
	cmpl	r11,r0
	jneq	L176
	pushl	r10
	calls	$1,_ntreprint
	jbr	L178
L176:
	cmpw	264(r10),$256
	jgeq	L179
	tstw	264(r10)
	jneq	L180
	cvtbw	270(r10),282(r10)
L180:
	addl3	$8,r10,r0
	movw	264(r10),r1
	incw	264(r10)
	cvtwl	r1,r1
	addl2	r1,r0
	movb	r11,(r0)
	jbr	L181
L179:
	pushl	$7
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L182
	bisw2	$32,268(r10)
L182:
	jbr	L138
L181:
	cmpl	r11,$10
	jeql	L184
	cvtbl	278(r10),r0
	cmpl	r11,r0
	jeql	L184
L186:
	cvtbl	279(r10),r0
	cmpl	r11,r0
	jeql	L184
L185:
	cmpl	r11,$13
	jneq	L183
	bitw	$16,266(r10)
	jeql	L183
L187:
L184:
	pushl	r10
	calls	$1,_ntcooked
L183:
	bitw	$4,286(r10)
	jeql	L188
	bicw2	$4,286(r10)
	pushl	$47
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L189
	bisw2	$32,268(r10)
L189:
L188:
	pushl	r10
	pushl	r11
	calls	$2,_ntecho
	cvtbl	278(r10),r0
	cmpl	r11,r0
	jneq	L190
	bitw	$8,266(r10)
	jeql	L190
L192:
	bitw	$4096,284(r10)
	jeql	L190
L191:
	pushl	$8
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
	tstl	r0
	jeql	L193
	bisw2	$32,268(r10)
	pushl	$8
	pushl	(r10)
	pushl	$_putq
	calls	$3,_putd
L193:
L190:
L178:
L175:
L172:
L169:
	jbr	L138
	.stabs	"t_flags",0x40,0,4,9
	.stabs	"nt",0x40,0,40,10
	.stabs	"c",0x40,0,4,11
L138:
	ret
	.set	L.R8,0xe00
	.set	L.SO8,0x0
L194:	.data
	.text
	.align	2
	.globl	_ntinsrv
_ntinsrv:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"ntinsrv",0x24,0,343,_ntinsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	.lcomm	L196,256
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L197
	jbr	L195
L197:
	movl	20(r11),r10
	movl	$L196,r8
	jbr	L199
L200:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	tstl	r9
	jneq	L201
	cmpl	r8,$L196
	jlequ	L202
	subl3	$L196,r8,-(sp)
	pushl	$L196
	pushl	12(r11)
	calls	$3,_putcpy
L202:
	jbr	L195
L201:
	jbr	L205
L206:
	movl	4(r9),r0
	incl	4(r9)
	movzbl	(r0),r7
	bitl	$128,r7
	jeql	L207
	bicl2	$-128,r7
	bitw	$4,266(r10)
	jeql	L208
	tstb	_maptab(r7)
	jeql	L208
L209:
	cvtbl	_maptab(r7),r7
	jbr	L210
L208:
	cvtbl	272(r10),r0
	cmpl	r7,r0
	jeql	L211
	cvtbl	273(r10),r0
	cmpl	r7,r0
	jeql	L211
L213:
	cvtbl	278(r10),r0
	cmpl	r7,r0
	jeql	L211
L212:
	movb	$92,(r8)+
L211:
L210:
	jbr	L214
L207:
	cvtbl	278(r10),r0
	cmpl	r7,r0
	jneq	L215
	jbr	L205
L215:
L214:
	movb	r7,(r8)+
	cmpl	r8,$L196+255
	jlssu	L216
	subl3	$L196,r8,-(sp)
	pushl	$L196
	pushl	12(r11)
	calls	$3,_putcpy
	movl	$L196,r8
L216:
L205:
	cmpl	4(r9),8(r9)
	jlssu	L206
L204:
	bitb	$128,21(r9)
	jneq	L217
	pushl	r9
	calls	$1,_freeb
	jbr	L218
L217:
	cmpl	r8,$L196
	jlequ	L219
	subl3	$L196,r8,-(sp)
	pushl	$L196
	pushl	12(r11)
	calls	$3,_putcpy
L219:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	decb	271(r10)
	movl	$L196,r8
L218:
L199:
	tstb	271(r10)
	jneq	L200
L198:
	jbr	L195
	.stabs	"canonb",0x28,0,98,L196
	.stabs	"c",0x40,0,4,7
	.stabs	"op",0x40,0,34,8
	.stabs	"b",0x40,0,40,9
	.stabs	"nt",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L195:
	ret
	.set	L.R9,0xf80
	.set	L.SO9,0x0
L220:	.data
	.text
	.align	2
	.globl	_ntiocack
_ntiocack:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"ntiocack",0x24,0,418,_ntiocack
	.stabs	"q",0xa0,0,40,4
	.stabs	"b",0xa0,0,40,8
	.stabs	"n",0xa0,0,4,12
	movl	4(ap),r11
	movl	8(ap),r10
	movl	12(ap),r9
	tstl	r9
	jleq	L223
	addl2	$4,r9
L223:
	addl3	r9,4(r10),8(r10)
	movb	$69,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_qreply
	jbr	L222
	.stabs	"n",0x40,0,4,9
	.stabs	"b",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L222:
	ret
	.set	L.R10,0xe00
	.set	L.SO10,0x0
L225:	.data
	.text
	.align	2
	.globl	_ntioctl
_ntioctl:
	.word	L.R11
	subl2	$L.SO11,sp
	.stabs	"ntioctl",0x24,0,436,_ntioctl
	.stabs	"q",0xa0,0,40,4
	.stabs	"b",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	movl	4(r10),r8
	movl	(r8),r0
	jbr	L229
L230:
L231:
	calls	$0,_spl6
	movl	r0,-4(fp)
	bitw	$34,8(r8)
	jeql	L233
	bitw	$34,266(r9)
	jneq	L233
L234:
	tstw	264(r9)
	jleq	L235
	pushl	r9
	calls	$1,_ntcooked
L235:
	subl3	$28,(r9),-(sp)
	calls	$1,_ntinsrv
L233:
	movb	6(r8),272(r9)
	movb	7(r8),273(r9)
	movw	8(r8),266(r9)
	movl	4(r9),r0
	bicw2	$-65408,26(r0)
	bitw	$34,266(r9)
	jneq	L236
	movl	4(r9),r0
	bisw2	$128,26(r0)
L236:
	pushl	-4(fp)
	calls	$1,_splx
	pushl	$0
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L238:
	movb	272(r9),6(r8)
	movb	273(r9),7(r8)
	movw	266(r9),8(r8)
	movb	$13,r0
	movb	r0,5(r8)
	movb	r0,4(r8)
	addl3	$10,4(r10),8(r10)
	addl3	$12,4(r10),8(r10)
	pushl	$6
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L239:
	addl3	$4,r8,r0
	addl3	$274,r9,r1
	movc3	$6,(r0),(r1)
	pushl	$0
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L240:
	addl3	$274,r9,r0
	addl3	$4,r8,r1
	movc3	$6,(r0),(r1)
	pushl	$6
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L241:
	addl3	$4,r8,r0
	addl3	$288,r9,r1
	movc3	$6,(r0),(r1)
	pushl	$0
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L242:
	addl3	$288,r9,r0
	addl3	$4,r8,r1
	movc3	$6,(r0),(r1)
	pushl	$6
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L243:
	bisw2	4(r8),284(r9)
	pushl	$0
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L244:
	mcomw	4(r8),r0
	mcomw	r0,r1
	bicw2	r1,284(r9)
	pushl	$0
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L245:
	movw	4(r8),284(r9)
	pushl	$0
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L246:
	movw	284(r9),4(r8)
	pushl	$2
	pushl	r10
	pushl	r11
	calls	$3,_ntiocack
	jbr	L228
L247:
L248:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L228
L229:
	cmpl	r0,$29813
	jeql	L241
	jgtr	L249
	cmpl	r0,$29713
	jeql	L239
	jgtr	L250
	cmpl	r0,$29705
	jeql	L230
	jgtr	L251
	cmpl	r0,$29704
	jeql	L238
	jbr	L248
L251:
	cmpl	r0,$29706
	jeql	L231
	jbr	L248
L250:
	cmpl	r0,$29811
	jeql	L247
	jgtr	L252
	cmpl	r0,$29714
	jeql	L240
	jbr	L248
L252:
	cmpl	r0,$29812
	jeql	L242
	jbr	L248
L249:
	cmpl	r0,$29822
	jeql	L244
	jgtr	L253
	cmpl	r0,$29821
	jeql	L245
	jgtr	L248
	cmpl	r0,$29820
	jeql	L246
	jbr	L248
L253:
	cmpl	r0,$29823
	jeql	L243
	jbr	L248
	jbr	L248
L228:
	jbr	L227
	.stabs	"s",0x80,0,4,4
	.stabs	"ioc",0x40,0,40,8
	.stabs	"nt",0x40,0,40,9
	.stabs	"b",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L227:
	ret
	.set	L.R11,0xf00
	.set	L.SO11,0x4
L254:	.data
	.text
	.align	2
	.globl	_ntkill
_ntkill:
	.word	L.R12
	subl2	$L.SO12,sp
	.stabs	"ntkill",0x24,0,555,_ntkill
	.stabs	"nt",0xa0,0,40,4
	movl	4(ap),r11
	bitw	$1024,284(r11)
	jeql	L256
	tstw	280(r11)
	jneq	L256
L257:
	jbr	L259
L260:
	pushl	r11
	calls	$1,_ntrubout
L259:
	tstw	264(r11)
	jgtr	L260
L258:
	jbr	L261
L256:
	pushl	r11
	cvtbl	273(r11),-(sp)
	calls	$2,_ntecho
	pushl	r11
	pushl	$10
	calls	$2,_ntecho
	clrw	264(r11)
	clrw	280(r11)
L261:
	clrw	286(r11)
	jbr	L255
	.stabs	"nt",0x40,0,40,11
L255:
	ret
	.set	L.R12,0x800
	.set	L.SO12,0x0
L262:	.data
	.text
	.align	2
	.globl	_ntoflush
_ntoflush:
	.word	L.R13
	subl2	$L.SO13,sp
	.stabs	"ntoflush",0x24,0,580,_ntoflush
	.stabs	"c",0xa0,0,4,4
	.stabs	"nt",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	bitw	$128,284(r10)
	jeql	L264
	bicw2	$128,284(r10)
	cvtbl	291(r10),r0
	cmpl	r11,r0
	jneq	L265
	movl	$1,r0
	jbr	L263
L265:
	jbr	L266
L264:
	cvtbl	291(r10),r0
	cmpl	r11,r0
	jneq	L267
	pushl	$2
	pushl	r10
	calls	$2,_ntflush
	pushl	r10
	pushl	r11
	calls	$2,_ntecho
	pushl	r10
	calls	$1,_ntreprint
	bisw2	$128,284(r10)
	movl	$1,r0
	jbr	L263
L267:
L266:
	clrl	r0
	jbr	L263
	.stabs	"nt",0x40,0,40,10
	.stabs	"c",0x40,0,4,11
L263:
	ret
	.set	L.R13,0xc00
	.set	L.SO13,0x0
L268:	.data
	.text
	.align	2
	.globl	_ntopen
_ntopen:
	.word	L.R14
	subl2	$L.SO14,sp
	.stabs	"ntopen",0x24,0,604,_ntopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	tstl	20(r11)
	jeql	L270
	movl	$1,r0
	jbr	L269
L270:
	movl	$_ntty,r10
	jbr	L273
L274:
	subl3	$1,_nttycnt,r0
	mull2	$296,r0
	addl2	$_ntty,r0
	cmpl	r10,r0
	jlssu	L275
	clrl	r0
	jbr	L269
L275:
	addl2	$296,r10
L273:
	bitw	$8,268(r10)
	jneq	L274
L272:
	movl	r10,r0
	movl	r0,20(r11)
	movl	r0,48(r11)
	addl3	$28,r11,(r10)
	movl	r11,4(r10)
	clrw	264(r10)
	movw	$8,268(r10)
	movw	$24,266(r10)
	clrb	270(r10)
	clrb	271(r10)
	pushl	r10
	calls	$1,_ntchars
	clrw	280(r10)
	clrw	284(r10)
	clrw	286(r10)
	bisw2	$128,26(r11)
	movl	$1,r0
	jbr	L269
	.stabs	"nt",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L269:
	ret
	.set	L.R14,0xc00
	.set	L.SO14,0x0
L276:	.data
	.text
	.align	2
	.globl	_ntout
_ntout:
	.word	L.R15
	subl2	$L.SO15,sp
	.stabs	"ntout",0x24,0,638,_ntout
	.stabs	"wrq",0xa0,0,40,4
	.stabs	"b",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	tstb	20(r10)
	jneq	L278
	movb	$8,20(r10)
L278:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	jbr	L277
	.stabs	"b",0x40,0,40,10
	.stabs	"wrq",0x40,0,40,11
L277:
	ret
	.set	L.R15,0xc00
	.set	L.SO15,0x0
L279:	.data
	.text
	.align	2
	.globl	_ntoutb
_ntoutb:
	.word	L.R16
	subl2	$L.SO16,sp
	.stabs	"ntoutb",0x24,0,655,_ntoutb
	.stabs	"nt",0xa0,0,40,4
	.stabs	"ib",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	clrl	r9
	movl	(r11),r8
	jbr	L283
L284:
	tstl	r9
	jeql	L286
	cmpl	8(r9),12(r9)
	jlssu	L285
L286:
	tstl	r9
	jeql	L287
	bitw	$128,284(r11)
	jeql	L288
	jbr	L282
L288:
	pushl	r9
	pushl	12(r8)
	movl	*12(r8),r0
	movl	(r0),r1
	calls	$2,(r1)
L287:
	movl	12(r8),r0
	bitw	$8,26(r0)
	jneq	L290
	pushl	$64
	calls	$1,_allocb
	movl	r0,r9
	jneq	L289
L290:
	pushl	r10
	pushl	r8
	calls	$2,_putbq
	jbr	L281
L289:
L285:
	movl	4(r10),r0
	incl	4(r10)
	movzbl	(r0),r0
	bicl3	$-128,r0,r7
	movl	r7,r0
	jbr	L293
L294:
	cvtwl	266(r11),r0
	bicl2	$-3073,r0
	cmpl	r0,$3072
	jeql	L295
	jbr	L292
L295:
L298:
	movl	8(r9),r0
	incl	8(r9)
	movb	$32,(r0)
	incb	270(r11)
	bitb	$7,270(r11)
	jneq	L299
	jbr	L297
L299:
	cmpl	8(r9),12(r9)
	jlssu	L300
	decl	4(r10)
	jbr	L297
L300:
	jbr	L298
L297:
	jbr	L283
L301:
	bitw	$16,266(r11)
	jneq	L302
	jbr	L292
L302:
	bitw	$4,268(r11)
	jeql	L303
	bicw2	$4,268(r11)
	jbr	L304
L303:
	bisw2	$4,268(r11)
	movl	$13,r7
	decl	4(r10)
L304:
	jbr	L292
L305:
	bitw	$8,284(r11)
	jeql	L306
	movl	$96,r7
L306:
L307:
	bitw	$4,266(r11)
	jneq	L308
	jbr	L292
L308:
	bitw	$16,268(r11)
	jeql	L309
	bicw2	$16,268(r11)
	jbr	L292
L309:
	.data	1
L310:

	.byte	0x7b,0x28,0x7d,0x29,0x7c,0x21,0x7e,0x5e
	.byte	0x60,0x27,0x0
	.text
	movl	$L310,-8(fp)
	jbr	L313
L314:
	addl2	$2,-8(fp)
L313:
	tstb	*-8(fp)
	jeql	L315
	cvtbl	*-8(fp),r0
	cmpl	r7,r0
	jneq	L314
L315:
L312:
	tstb	*-8(fp)
	jneq	L317
	cmpl	r7,$65
	jlss	L316
	cmpl	r7,$90
	jgtr	L316
L318:
L317:
	decl	4(r10)
	tstb	*-8(fp)
	jeql	L319
	movl	-8(fp),r0
	cvtbl	1(r0),r0
	jbr	L320
L319:
	movl	r7,r0
L320:
	movb	r0,*4(r10)
	bisw2	$16,268(r11)
	movl	$92,r7
	jbr	L321
L316:
	cmpl	r7,$97
	jlss	L322
	cmpl	r7,$122
	jgtr	L322
L323:
	addl2	$-32,r7
L322:
L321:
	jbr	L292
L293:
	cmpl	r0,$9
	jeql	L294
	cmpl	r0,$10
	jeql	L301
	cmpl	r0,$126
	jeql	L305
	jbr	L307
L292:
	movl	8(r9),r0
	incl	8(r9)
	movb	r7,(r0)
	clrl	r6
	cvtbl	_partab(r7),r0
	bicl3	$-64,r0,-4(fp)
	movl	-4(fp),r0
	jbr	L325
L326:
	incb	270(r11)
	jbr	L324
L327:
	jbr	L324
L328:
	tstb	270(r11)
	jeql	L329
	decb	270(r11)
L329:
	jbr	L324
L330:
	cvtwl	266(r11),r0
	extzv	$8,$24,r0,r0
	bicl3	$-4,r0,-4(fp)
	cmpl	-4(fp),$1
	jneq	L331
	tstb	270(r11)
	jeql	L332
	cvtbl	270(r11),r0
	extzv	$4,$28,r0,r6
	cmpl	r6,$6
	jgeq	L333
	movl	$6,r6
L333:
L332:
	jbr	L334
L331:
	cmpl	-4(fp),$2
	jneq	L335
	movl	$6,r6
L335:
L334:
	bitw	$16,266(r11)
	jneq	L336
	clrb	270(r11)
L336:
	jbr	L324
L337:
	cvtwl	266(r11),r0
	extzv	$10,$22,r0,r0
	bicl3	$-4,r0,-4(fp)
	cmpl	-4(fp),$1
	jneq	L338
	cvtbl	270(r11),r0
	bisl2	$-8,r0
	subl3	r0,$1,r6
	cmpl	r6,$5
	jgeq	L339
	clrl	r6
L339:
L338:
	bisb2	$7,270(r11)
	incb	270(r11)
	jbr	L324
L340:
	bitw	$16384,266(r11)
	jeql	L341
	movl	$127,r6
L341:
	jbr	L324
L342:
	cvtwl	266(r11),r0
	extzv	$12,$20,r0,r0
	bicl3	$-4,r0,-4(fp)
	cmpl	-4(fp),$1
	jneq	L343
	movl	$5,r6
	jbr	L344
L343:
	cmpl	-4(fp),$2
	jneq	L345
	movl	$10,r6
	jbr	L346
L345:
	cmpl	-4(fp),$3
	jneq	L347
	cvtbl	270(r11),r0
	subl3	r0,$9,r6
	jgeq	L348
	clrl	r6
L348:
L347:
L346:
L344:
	clrb	270(r11)
	jbr	L324
L325:
	casel	r0,$0,$6
L349:
	.word	L326-L349
	.word	L327-L349
	.word	L328-L349
	.word	L330-L349
	.word	L337-L349
	.word	L340-L349
	.word	L342-L349
L350:
L324:
	tstl	r6
	jeql	L351
	bitw	$128,284(r11)
	jeql	L352
	jbr	L282
L352:
	pushl	r9
	pushl	12(r8)
	movl	*12(r8),r0
	movl	(r0),r1
	calls	$2,(r1)
	pushl	$1
	calls	$1,_allocb
	movl	r0,r9
	jeql	L353
	movb	$7,20(r9)
	movl	8(r9),r0
	incl	8(r9)
	movb	r6,(r0)
	pushl	r9
	pushl	12(r8)
	movl	*12(r8),r0
	movl	(r0),r1
	calls	$2,(r1)
L353:
	clrl	r9
L351:
L283:
	cmpl	4(r10),8(r10)
	jlssu	L284
L282:
	bitb	$128,21(r10)
	jeql	L354
	tstl	r9
	jneq	L355
	pushl	$0
	calls	$1,_allocb
	movl	r0,r9
L355:
	tstl	r9
	jeql	L356
	bisb2	$128,21(r9)
L356:
L354:
	pushl	r10
	calls	$1,_freeb
	tstl	r9
	jeql	L357
	bitw	$128,284(r11)
	jeql	L358
	pushl	r9
	calls	$1,_freeb
	jbr	L359
L358:
	pushl	r9
	pushl	12(r8)
	movl	*12(r8),r0
	movl	(r0),r1
	calls	$2,(r1)
L359:
L357:
	.stabs	"colp",0x80,0,34,8
	.stabs	"ctype",0x80,0,4,4
	.stabs	"delay",0x40,0,4,6
	.stabs	"c",0x40,0,4,7
	.stabs	"q",0x40,0,40,8
	.stabs	"ob",0x40,0,40,9
	.stabs	"ib",0x40,0,40,10
	.stabs	"nt",0x40,0,40,11
L281:
	ret
	.set	L.R16,0xfc0
	.set	L.SO16,0x8
L360:	.data
	.text
	.align	2
	.globl	_ntoutsrv
_ntoutsrv:
	.word	L.R17
	subl2	$L.SO17,sp
	.stabs	"ntoutsrv",0x24,0,833,_ntoutsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	jbr	L363
L364:
	movzbl	20(r9),r0
	jbr	L366
L367:
	pushl	r9
	calls	$1,_freeb
	jbr	L363
L368:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L369
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L361
L369:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L363
L370:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L371
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L361
L371:
	pushl	r9
	pushl	r11
	calls	$2,_ntioctl
	jbr	L363
L372:
	pushl	$0
	pushl	r11
	calls	$2,_flushq
L373:
L374:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L363
L375:
L376:
	bitw	$128,284(r10)
	jeql	L377
	pushl	r9
	calls	$1,_freeb
	jbr	L363
L377:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jeql	L378
	pushl	r9
	pushl	r11
	calls	$2,_putbq
	jbr	L361
L378:
	cmpb	20(r9),$8
	jneq	L379
	clrb	20(r9)
	movw	264(r10),280(r10)
L379:
	bitw	$32,266(r10)
	jneq	L381
	bitw	$32,284(r10)
	jeql	L380
L381:
	pushl	r9
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L382
L380:
	pushl	r9
	pushl	r10
	calls	$2,_ntoutb
L382:
	jbr	L363
L366:
	cmpl	r0,$0
	jeql	L376
	cmpl	r0,$1
	jeql	L368
	cmpl	r0,$6
	jeql	L370
	cmpl	r0,$8
	jeql	L375
	cmpl	r0,$66
	jeql	L372
	cmpl	r0,$69
	jeql	L374
	cmpl	r0,$70
	jeql	L373
	jbr	L367
L365:
L363:
	pushl	r11
	calls	$1,_getq
	movl	r0,r9
	jneq	L364
L362:
	jbr	L361
	.stabs	"b",0x40,0,40,9
	.stabs	"nt",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L361:
	ret
	.set	L.R17,0xe00
	.set	L.SO17,0x0
L383:	.data
	.text
	.align	2
	.globl	_ntreprint
_ntreprint:
	.word	L.R18
	subl2	$L.SO18,sp
	.stabs	"ntreprint",0x24,0,894,_ntreprint
	.stabs	"nt",0xa0,0,40,4
	movl	4(ap),r11
	cvtbl	290(r11),r0
	cmpl	r0,$255
	jeql	L385
	pushl	r11
	cvtbl	290(r11),-(sp)
	calls	$2,_ntecho
L385:
	pushl	$10
	pushl	(r11)
	pushl	$_putq
	calls	$3,_putd
	addl3	$8,r11,r10
	cvtwl	264(r11),r9
	jbr	L388
L389:
	pushl	r11
	cvtbl	(r10),-(sp)
	calls	$2,_ntecho
	incl	r10
	movl	r9,r0
	decl	r9
L388:
	tstl	r9
	jgtr	L389
L387:
	bicw2	$4,286(r11)
	clrw	280(r11)
	jbr	L384
	.stabs	"nin",0x40,0,4,9
	.stabs	"in",0x40,0,34,10
	.stabs	"nt",0x40,0,40,11
L384:
	ret
	.set	L.R18,0xe00
	.set	L.SO18,0x0
L390:	.data
	.text
	.align	2
	.globl	_ntrubout
_ntrubout:
	.word	L.R19
	subl2	$L.SO19,sp
	.stabs	"ntrubout",0x24,0,915,_ntrubout
	.stabs	"nt",0xa0,0,40,4
	movl	4(ap),r11
	tstw	264(r11)
	jgtr	L392
	jbr	L391
L392:
	addl3	$8,r11,r0
	decw	264(r11)
	cvtwl	264(r11),r1
	addl2	r1,r0
	cvtbl	(r0),r10
	bitw	$8,266(r11)
	jneq	L393
	jbr	L391
L393:
	bicw2	$128,284(r11)
	bitw	$2,284(r11)
	jeql	L394
	bitw	$4,286(r11)
	jneq	L395
	pushl	$92
	pushl	(r11)
	pushl	$_putq
	calls	$3,_putd
	bisw2	$4,286(r11)
L395:
	pushl	r11
	pushl	r10
	calls	$2,_ntecho
	jbr	L391
L394:
	bitw	$1,284(r11)
	jneq	L396
	pushl	r11
	cvtbl	272(r11),-(sp)
	calls	$2,_ntecho
	jbr	L391
L396:
	cmpw	280(r11),264(r11)
	jleq	L397
	pushl	r11
	calls	$1,_ntreprint
	jbr	L391
L397:
	cmpl	r10,$137
	jeql	L399
	cmpl	r10,$138
	jneq	L398
L399:
	pushl	$2
	pushl	r11
	calls	$2,_ntbs
	jbr	L391
L398:
	bicl2	$-128,r10
	cvtbl	_partab(r10),r0
	bicl2	$-128,r0
	jbr	L401
L402:
	bitw	$4,266(r11)
	jeql	L403
	cmpl	r10,$65
	jlss	L403
L405:
	cmpl	r10,$90
	jgtr	L403
L404:
	pushl	$2
	pushl	r11
	calls	$2,_ntbs
	jbr	L406
L403:
	pushl	$1
	pushl	r11
	calls	$2,_ntbs
L406:
	jbr	L400
L407:
	cvtwl	282(r11),r8
	clrl	r7
	jbr	L410
L411:
	addl3	$8,r11,r0
	addl2	r7,r0
	cvtbl	(r0),r9
	cmpl	r9,$137
	jeql	L413
	cmpl	r9,$138
	jneq	L412
L413:
	addl2	$2,r8
	jbr	L408
L412:
	bicl2	$-128,r9
	cvtbl	_partab(r9),r0
	bicl2	$-128,r0
	jbr	L415
L416:
	bitw	$4,266(r11)
	jeql	L417
	cmpl	r9,$65
	jlss	L417
L419:
	cmpl	r9,$90
	jgtr	L417
L418:
	addl2	$2,r8
	jbr	L420
L417:
	incl	r8
L420:
	jbr	L414
L421:
	addl3	$8,r8,r0
	bicl3	$7,r0,r8
	jbr	L414
L422:
	bitw	$4096,284(r11)
	jeql	L423
	addl2	$2,r8
L423:
	jbr	L414
L415:
	casel	r0,$0,$4
L424:
	.word	L416-L424
	.word	L422-L424
	.word	L422-L424
	.word	L422-L424
	.word	L421-L424
	jbr	L422
L414:
L408:
	incl	r7
L410:
	cvtwl	264(r11),r0
	cmpl	r7,r0
	jlss	L411
L409:
	bicl3	$-8,r8,r0
	subl3	r0,$8,-(sp)
	pushl	r11
	calls	$2,_ntbs
	jbr	L400
L425:
	bitw	$4096,284(r11)
	jeql	L426
	pushl	$2
	pushl	r11
	calls	$2,_ntbs
L426:
	jbr	L400
L401:
	casel	r0,$0,$4
L427:
	.word	L402-L427
	.word	L425-L427
	.word	L425-L427
	.word	L425-L427
	.word	L407-L427
	jbr	L425
L400:
	jbr	L391
	.stabs	"i",0x40,0,4,7
	.stabs	"col",0x40,0,4,8
	.stabs	"cc",0x40,0,4,9
	.stabs	"c",0x40,0,4,10
	.stabs	"nt",0x40,0,40,11
L391:
	ret
	.set	L.R19,0xf80
	.set	L.SO19,0x0
L428:	.data
	.text
	.align	2
	.globl	_ntsigc
_ntsigc:
	.word	L.R20
	subl2	$L.SO20,sp
	.stabs	"ntsigc",0x24,0,1001,_ntsigc
	.stabs	"c",0xa0,0,4,4
	.stabs	"nt",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	cvtbl	274(r10),r0
	cmpl	r11,r0
	jneq	L430
	pushl	$3
	pushl	r10
	calls	$2,_ntflush
	pushl	$2
	pushl	$65
	movl	4(r10),r0
	pushl	12(r0)
	calls	$3,_putctl1
	jbr	L431
L430:
	cvtbl	275(r10),r0
	cmpl	r11,r0
	jneq	L432
	pushl	$3
	pushl	r10
	calls	$2,_ntflush
	pushl	$3
	pushl	$65
	movl	4(r10),r0
	pushl	12(r0)
	calls	$3,_putctl1
	jbr	L433
L432:
	cvtbl	288(r10),r0
	cmpl	r11,r0
	jneq	L434
	pushl	$1
	pushl	r10
	calls	$2,_ntflush
	pushl	$18
	pushl	$65
	movl	4(r10),r0
	pushl	12(r0)
	calls	$3,_putctl1
	jbr	L435
L434:
	clrl	r0
	jbr	L429
L435:
L433:
L431:
	pushl	r10
	pushl	r11
	calls	$2,_ntecho
	movl	$1,r0
	jbr	L429
	.stabs	"nt",0x40,0,40,10
	.stabs	"c",0x40,0,4,11
L429:
	ret
	.set	L.R20,0xc00
	.set	L.SO20,0x0
L436:	.data
	.text
	.align	2
	.globl	_ntstst
_ntstst:
	.word	L.R21
	subl2	$L.SO21,sp
	.stabs	"ntstst",0x24,0,1030,_ntstst
	.stabs	"c",0xa0,0,4,4
	.stabs	"nt",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	bitw	$1,268(r10)
	jeql	L438
	cvtbl	276(r10),r0
	cmpl	r11,r0
	jeql	L440
	bitw	$16384,284(r10)
	jneq	L439
	cvtbl	277(r10),r0
	cmpl	r11,r0
	jneq	L442
	cmpb	277(r10),276(r10)
	jneq	L439
L442:
L441:
L440:
	pushl	$68
	movl	(r10),r0
	pushl	12(r0)
	calls	$2,_putctl
	tstl	r0
	jeql	L443
	bicw2	$1,268(r10)
L443:
L439:
	jbr	L444
L438:
	cvtbl	277(r10),r0
	cmpl	r11,r0
	jneq	L445
	pushl	$67
	movl	(r10),r0
	pushl	12(r0)
	calls	$2,_putctl
	tstl	r0
	jeql	L446
	bisw2	$1,268(r10)
L446:
L445:
L444:
	cvtbl	276(r10),r0
	cmpl	r11,r0
	jeql	L449
	cvtbl	277(r10),r0
	cmpl	r11,r0
	jneq	L447
L449:
	movl	$1,r0
	jbr	L448
L447:
	clrl	r0
L448:
	jbr	L437
	.stabs	"nt",0x40,0,40,10
	.stabs	"c",0x40,0,4,11
L437:
	ret
	.set	L.R21,0xc00
	.set	L.SO21,0x0
L450:	.data
	.text
	.align	2
	.globl	_ntwerase
_ntwerase:
	.word	L.R22
	subl2	$L.SO22,sp
	.stabs	"ntwerase",0x24,0,1055,_ntwerase
	.stabs	"nt",0xa0,0,40,4
	movl	4(ap),r11
	addl3	$8,r11,r0
	cvtwl	264(r11),r1
	addl2	r1,r0
	subl3	$1,r0,r10
	jbr	L454
L455:
	cmpb	(r10),$32
	jeql	L457
	cmpb	(r10),$9
	jneq	L456
L457:
	pushl	r11
	calls	$1,_ntrubout
	jbr	L458
L456:
	jbr	L453
L458:
	decl	r10
L454:
	addl3	$8,r11,r0
	cmpl	r10,r0
	jgequ	L455
L453:
	jbr	L461
L462:
	cmpb	(r10),$32
	jeql	L464
	cmpb	(r10),$9
	jneq	L463
L464:
	jbr	L460
L463:
	pushl	r11
	calls	$1,_ntrubout
	decl	r10
L461:
	addl3	$8,r11,r0
	cmpl	r10,r0
	jgequ	L462
L460:
	jbr	L451
	.stabs	"s",0x40,0,34,10
	.stabs	"nt",0x40,0,40,11
L451:
	ret
	.set	L.R22,0xc00
	.set	L.SO22,0x0
L465:	.data
	.stabs	"winit",0x26,0,8,_winit
	.stabs	"rinit",0x26,0,8,_rinit
	.text
L466:	.stabs	"nttyld.c",0x94,0,1070,L466
