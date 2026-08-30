L11:	.stabs	"stream.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553091
	.data
	.comm	_buf,4
	.comm	_buffers,4
	.comm	_nbuf,4
	.comm	_swsize,4
	.comm	_swpf,4
	.comm	_bfreelist,132
	.comm	_bswlist,44
	.comm	_bclnlist,4
	.comm	_qhead,4
	.comm	_qtail,4
	.data
	.align	2
	.globl	_rbsize
_rbsize:
	.long	4
	.long	16
	.long	64
	.long	256
	.long	1024
	.long	4096
	.align	2
	.globl	_bsize
_bsize:
	.long	4
	.long	16
	.long	64
	.long	256
	.long	256
	.long	256
	.comm	_qfreelist,24
	.comm	_blkfree,12
	.comm	_blkall,12
	.comm	_blkmax,12
	.text
	.align	2
	.globl	_qinit
_qinit:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"qinit",0x24,0,102,_qinit
	clrl	r11
	jbr	L59
L60:
	calls	$0,_geteblk
	movl	r0,r10
	jneq	L61
	jbr	L58
L61:
	mull3	$28,r11,r0
	movb	$5,_cblock+21(r0)
	mull3	$28,r11,r0
	movl	28(r10),_cblock+16(r0)
	mull3	$28,r11,r0
	addl3	28(r10),20(r10),_cblock+12(r0)
	mull3	$28,r11,r0
	movb	r11,_cblock+23(r0)
	movl	r10,_cblkbuf[r11]
	mull3	$28,r11,r0
	addl3	$_cblock,r0,-(sp)
	calls	$1,_freeb
	incl	r11
L59:
	cmpl	r11,_blkbcnt
	jlss	L60
L58:
	clrw	_blkall+10
	jbr	L65
L66:
	mull3	$28,r11,r0
	clrb	_cblock+21(r0)
	mull3	$28,r11,r0
	mull3	$28,r11,r1
	addl3	$_cblock+24,r1,_cblock+16(r0)
	mull3	$28,r11,r0
	mull3	$28,r11,r1
	addl3	$_cblock+28,r1,_cblock+12(r0)
	mull3	$28,r11,r0
	movb	$255,_cblock+23(r0)
	mull3	$28,r11,r0
	addl3	$_cblock,r0,-(sp)
	calls	$1,_freeb
	incl	r11
L65:
	cmpl	r11,_blkcnt
	jlss	L66
L64:
	clrw	_blkall
	.stabs	"bp",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L56:
	ret
	.set	L.R1,0xc00
	.set	L.SO1,0x0
L67:	.data
	.text
	.align	2
	.globl	_allocb
_allocb:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"allocb",0x24,0,137,_allocb
	.stabs	"size",0xa0,0,4,4
	clrl	r10
	jbr	L71
L72:
	cmpl	4(ap),_rbsize[r10]
	jgtr	L73
	jbr	L70
L73:
	incl	r10
L71:
	cmpl	r10,$6
	jlss	L72
L70:
	cmpl	r10,$6
	jlss	L74
	.data	1
L76:

	.byte	0x61,0x6c,0x6c,0x6f,0x63,0x62,0x20,0x62
	.byte	0x61,0x64,0x20,0x73,0x69,0x7a,0x65,0x0
	.text
	pushl	$L76
	calls	$1,_panic
L74:
	calls	$0,_spl6
	movl	r0,r9
	movl	_qfreelist[r10],r11
	jneq	L78
	addl3	$1,r10,-(sp)
	calls	$1,_bsplit
	movl	_qfreelist[r10],r11
	jneq	L79
	cmpl	4(ap),$64
	jeql	L80
	pushl	r9
	calls	$1,_splx
	pushl	$64
	calls	$1,_allocb
	jbr	L68
L80:
	.data	1
L82:

	.byte	0x61,0x6c,0x6c,0x6f,0x63,0x62,0x20,0x6e
	.byte	0x6f,0x20,0x62,0x6c,0x6f,0x63,0x6b,0x0
	.text
	pushl	$L82
	calls	$1,_panic
L79:
L78:
	movl	(r11),_qfreelist[r10]
	incw	_blkall[r10]
	cmpw	_blkall[r10],_blkmax[r10]
	jleq	L83
	movw	_blkall[r10],_blkmax[r10]
L83:
	decw	_blkfree[r10]
	pushl	r9
	calls	$1,_splx
	clrb	20(r11)
	clrl	(r11)
	movl	16(r11),4(r11)
	movl	16(r11),8(r11)
	movb	23(r11),22(r11)
	bicb2	$-128,21(r11)
	movl	r11,r0
	jbr	L68
	.stabs	"s",0x40,0,4,9
	.stabs	"lev",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L68:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L84:	.data
	.text
	.align	2
_bsplit:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"bsplit",0x24,0,193,_bsplit
	.stabs	"bsplit",0x32,0,68,0
	.stabs	"lev",0xa0,0,4,4
	movl	4(ap),r11
	cmpl	r11,$6
	jlss	L86
	jbr	L85
L86:
	movl	_qfreelist[r11],r10
	jneq	L87
	addl3	$1,r11,-(sp)
	calls	$1,_bsplit
	movl	_qfreelist[r11],r10
	jneq	L88
	jbr	L85
L88:
L87:
	movl	(r10),_qfreelist[r11]
	decw	_blkfree[r11]
	subl3	16(r10),12(r10),r0
	divl3	$4,r0,r7
	decl	r11
	movl	$1,r8
	jbr	L91
L92:
	movl	_qfreelist,r9
	jneq	L93
	jbr	L85
L93:
	movl	(r9),_qfreelist
	decw	_blkfree
	movl	16(r10),16(r9)
	addl2	r7,16(r10)
	addl3	r7,16(r9),12(r9)
	movb	r11,21(r9)
	movb	23(r10),23(r9)
	movl	_qfreelist[r11],(r9)
	movl	r9,_qfreelist[r11]
	incw	_blkfree[r11]
	incl	r8
L91:
	cmpl	r8,$4
	jlss	L92
L90:
	movb	r11,21(r10)
	movl	_qfreelist[r11],(r10)
	movl	r10,_qfreelist[r11]
	incw	_blkfree[r11]
	.stabs	"size",0x40,0,4,7
	.stabs	"i",0x40,0,4,8
	.stabs	"bp1",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"lev",0x40,0,4,11
L85:
	ret
	.set	L.R3,0xf80
	.set	L.SO3,0x0
L94:	.data
	.text
	.align	2
	.globl	_cramb
_cramb:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"cramb",0x24,0,235,_cramb
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	subl3	4(r11),8(r11),r9
	movzbl	21(r11),r0
	bicl2	$-128,r0
	cmpl	r0,$3
	jlssu	L97
	movzbl	21(r11),r0
	bicl2	$-128,r0
	decl	r0
	cmpl	r9,_rbsize[r0]
	jleq	L96
L97:
	movl	r11,r0
	jbr	L95
L96:
	pushl	r9
	calls	$1,_allocb
	movl	r0,r10
	tstl	r10
	jneq	L98
	movl	r11,r0
	jbr	L95
L98:
	subl3	8(r10),12(r10),r0
	cmpl	r0,r9
	jgeq	L99
	pushl	r10
	calls	$1,_freeb
	movl	r11,r0
	jbr	L95
L99:
	pushl	r9
	pushl	8(r10)
	pushl	4(r11)
	calls	$3,_bcopy
	addl2	r9,8(r10)
	movb	20(r11),20(r10)
	bitb	$128,21(r11)
	jeql	L101
	bisb2	$128,21(r10)
L101:
	pushl	r11
	calls	$1,_freeb
	movl	r10,r0
	jbr	L95
	.stabs	"n",0x40,0,4,9
	.stabs	"nbp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L95:
	ret
	.set	L.R4,0xe00
	.set	L.SO4,0x0
L102:	.data
	.text
	.align	2
	.globl	_dupb
_dupb:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"dupb",0x24,0,265,_dupb
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	pushl	$0
	calls	$1,_allocb
	movl	r0,r10
	jneq	L104
	clrl	r0
	jbr	L103
L104:
	movb	20(r11),20(r10)
	movl	4(r11),4(r10)
	movl	8(r11),8(r10)
	movb	22(r11),22(r10)
	bicb3	$-129,21(r11),r0
	bisb2	r0,21(r10)
	movl	r10,r0
	jbr	L103
	.stabs	"nbp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L103:
	ret
	.set	L.R5,0xc00
	.set	L.SO5,0x0
L105:	.data
	.text
	.align	2
	.globl	_freeb
_freeb:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"freeb",0x24,0,287,_freeb
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	calls	$0,_spl6
	movl	r0,r10
	movzbl	21(r11),r0
	bicl3	$-128,r0,r9
	movl	_qfreelist[r9],(r11)
	movl	r11,_qfreelist[r9]
	decw	_blkall[r9]
	incw	_blkfree[r9]
	pushl	r10
	calls	$1,_splx
	.stabs	"lev",0x40,0,4,9
	.stabs	"s",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L106:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x0
L107:	.data
	.text
	.align	2
	.globl	_getq
_getq:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"getq",0x24,0,309,_getq
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	calls	$0,_spl6
	movl	r0,r9
	movl	4(r11),r10
	jneq	L109
	bitw	$1,26(r11)
	jneq	L110
	bisw2	$2,26(r11)
L110:
	jbr	L111
L109:
	movl	(r10),4(r11)
	jneq	L112
	clrl	8(r11)
L112:
	movzbl	21(r10),r0
	bicl2	$-128,r0
	addl2	r0,r0
	addl2	r0,r0
	subw2	_bsize(r0),24(r11)
	movl	(r11),r0
	cmpw	24(r11),16(r0)
	jgeq	L113
	bicw2	$-65528,26(r11)
L113:
	bicw2	$-65534,26(r11)
L111:
	movl	(r11),r0
	cmpw	24(r11),18(r0)
	jgtr	L114
	bitw	$4,26(r11)
	jeql	L114
L116:
	bitw	$16,26(r11)
	jeql	L117
	addl3	$28,r11,r0
	jbr	L118
L117:
	subl3	$28,r11,r0
L118:
	tstl	12(r0)
	jeql	L114
L115:
	pushl	r11
	calls	$1,_backq
	movl	r0,r8
	movl	(r8),r0
	tstl	4(r0)
	jeql	L119
	pushl	r8
	calls	$1,_qenable
L119:
	bicw2	$-65532,26(r11)
	.stabs	"bq",0x40,0,40,8
L114:
	pushl	r9
	calls	$1,_splx
	movl	r10,r0
	jbr	L108
	.stabs	"s",0x40,0,4,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L108:
	ret
	.set	L.R7,0xf00
	.set	L.SO7,0x0
L121:	.data
	.text
	.align	2
	.globl	_putq
_putq:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"putq",0x24,0,348,_putq
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	cmpb	20(r10),$66
	jneq	L123
	pushl	$0
	pushl	r11
	calls	$2,_flushq
L123:
	calls	$0,_spl6
	movl	r0,-4(fp)
	tstl	4(r11)
	jneq	L125
	movl	r10,4(r11)
	movl	r10,8(r11)
	clrl	(r10)
	jbr	L126
L125:
	cmpb	20(r10),$64
	jlssu	L128
	movl	8(r11),r0
	cmpb	20(r0),$64
	jlssu	L127
L128:
	movl	8(r11),r9
	subl3	4(r10),8(r10),r8
	tstb	20(r10)
	jneq	L129
	tstb	20(r9)
	jneq	L129
L133:
	bitb	$128,21(r9)
	jneq	L129
L132:
	subl3	8(r9),12(r9),r0
	cmpl	r8,r0
	jgtr	L129
L131:
	cmpl	8(r9),16(r9)
	jlssu	L129
L130:
	pushl	r8
	pushl	8(r9)
	pushl	4(r10)
	calls	$3,_bcopy
	addl2	r8,8(r9)
	bitb	$128,21(r10)
	jeql	L134
	bisb2	$128,21(r9)
L134:
	pushl	r10
	calls	$1,_freeb
	clrl	r10
	jbr	L135
L129:
	movl	r10,(r9)
	movl	r10,8(r11)
	clrl	(r10)
L135:
	.stabs	"n",0x40,0,4,8
	.stabs	"lastp",0x40,0,40,9
	jbr	L136
L127:
	movl	4(r11),r9
	cmpb	20(r9),$64
	jgequ	L137
	movl	4(r11),(r10)
	movl	r10,4(r11)
	jbr	L138
L137:
	jbr	L140
L141:
	movl	(r9),r9
L140:
	movl	(r9),r0
	cmpb	20(r0),$64
	jgequ	L141
L139:
	movl	(r9),(r10)
	movl	r10,(r9)
L138:
	.stabs	"nbp",0x40,0,40,9
L136:
L126:
	tstl	r10
	jeql	L142
	movzbl	21(r10),r0
	bicl2	$-128,r0
	addl2	r0,r0
	addl2	r0,r0
	addw2	_bsize(r0),24(r11)
	cmpb	20(r10),$64
	jlssu	L143
	cmpb	20(r10),$127
	jeql	L143
L144:
	bisw2	$2,26(r11)
L143:
L142:
	movl	(r11),r0
	cmpw	24(r11),16(r0)
	jlss	L145
	bisw2	$12,26(r11)
L145:
	movzwl	26(r11),r0
	bicl2	$-68,r0
	cmpl	r0,$2
	jneq	L146
	movl	(r11),r0
	tstl	4(r0)
	jeql	L146
L147:
	pushl	r11
	calls	$1,_qenable
L146:
	pushl	-4(fp)
	calls	$1,_splx
	.stabs	"s",0x80,0,4,4
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L122:
	ret
	.set	L.R8,0xf00
	.set	L.SO8,0x4
L148:	.data
	.text
	.align	2
	.globl	_putbq
_putbq:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"putbq",0x24,0,410,_putbq
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movzbl	20(r10),r9
	calls	$0,_spl6
	movl	r0,r8
	movb	$127,20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_putq
	movb	r9,20(r10)
	pushl	r8
	calls	$1,_splx
	.stabs	"s",0x40,0,4,8
	.stabs	"savetype",0x40,0,4,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L150:
	ret
	.set	L.R9,0xf00
	.set	L.SO9,0x0
L151:	.data
	.text
	.align	2
	.globl	_flushq
_flushq:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"flushq",0x24,0,425,_flushq
	.stabs	"q",0xa0,0,40,4
	.stabs	"flag",0xa0,0,4,8
	movl	4(ap),r11
	calls	$0,_spl6
	movl	r0,r8
	movl	4(r11),r10
	clrl	4(r11)
	tstl	8(r11)
	jeql	L153
	clrl	*8(r11)
L153:
	clrl	8(r11)
	clrw	24(r11)
	bicw2	$-65528,26(r11)
	jbr	L155
L156:
	movl	(r10),r9
	tstb	20(r10)
	jeql	L157
	cmpb	20(r10),$3
	jeql	L157
L162:
	cmpb	20(r10),$8
	jeql	L157
L161:
	cmpb	20(r10),$7
	jeql	L157
L160:
	cmpb	20(r10),$66
	jeql	L157
L159:
	tstl	8(ap)
	jneq	L157
L158:
	pushl	r10
	pushl	r11
	calls	$2,_putq
	jbr	L163
L157:
	cmpb	20(r10),$9
	jneq	L164
	.data	1
L166:

	.byte	0x66,0x6c,0x75,0x73,0x68,0x69,0x6e,0x67
	.byte	0x20,0x50,0x41,0x53,0x53,0x20,0x25,0x78
	.byte	0xa,0x0
	.text
	pushl	*4(r10)
	pushl	$L166
	calls	$2,_printf
L164:
	pushl	r10
	calls	$1,_freeb
L163:
	movl	r9,r10
L155:
	tstl	r10
	jneq	L156
L154:
	bitw	$4,26(r11)
	jeql	L167
	bitw	$16,26(r11)
	jeql	L169
	addl3	$28,r11,r0
	jbr	L170
L169:
	subl3	$28,r11,r0
L170:
	tstl	12(r0)
	jeql	L167
L168:
	bicw2	$-65532,26(r11)
	pushl	r11
	calls	$1,_backq
	pushl	r0
	calls	$1,_qenable
L167:
	pushl	r8
	calls	$1,_splx
	.stabs	"s",0x40,0,4,8
	.stabs	"nbp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L152:
	ret
	.set	L.R10,0xf00
	.set	L.SO10,0x0
L171:	.data
	.text
	.align	2
	.globl	_allocq
_allocq:
	.word	L.R11
	subl2	$L.SO11,sp
	.stabs	"allocq",0x24,0,461,_allocq
	.data
	.align	2
L173:
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0x300000
	.align	2
L174:
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0x200000
	.text
	movl	$_queue,r11
	jbr	L177
L178:
	bitw	$32,26(r11)
	jneq	L179
	movc3	$28,L173,(r11)
	addl3	$28,r11,r0
	movc3	$28,L174,(r0)
	movl	r11,r0
	jbr	L172
L179:
	addl2	$56,r11
L177:
	mull3	$28,_queuecnt,r0
	addl2	$_queue,r0
	cmpl	r11,r0
	jlssu	L178
L176:
	clrl	r0
	jbr	L172
	.stabs	"zeroW",0x26,0,8,L174
	.stabs	"zeroR",0x26,0,8,L173
	.stabs	"qp",0x40,0,40,11
L172:
	ret
	.set	L.R11,0x800
	.set	L.SO11,0x0
L180:	.data
	.text
	.align	2
	.globl	_noput
_noput:
	.word	L.R12
	subl2	$L.SO12,sp
	.stabs	"noput",0x24,0,483,_noput
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	.data	1
L182:

	.byte	0x6e,0x6f,0x70,0x75,0x74,0x0
	.text
	pushl	$L182
	calls	$1,_panic
L181:
	ret
	.set	L.R12,0x0
	.set	L.SO12,0x0
L183:	.data
	.text
	.align	2
	.globl	_putd
_putd:
	.word	L.R13
	subl2	$L.SO13,sp
	.stabs	"putd",0x24,0,493,_putd
	.stabs	"f",0xa0,0,292,4
	.stabs	"q",0xa0,0,40,8
	.stabs	"c",0xa0,0,4,12
	movl	8(ap),r11
	calls	$0,_spl6
	movl	r0,r9
	cmpl	4(ap),$_putq
	jneq	L186
	movl	8(r11),r10
	jeql	L186
L190:
	tstb	20(r10)
	jneq	L186
L189:
	cmpl	8(r10),12(r10)
	jgequ	L186
L188:
	bitb	$128,21(r10)
	jneq	L186
L187:
	movl	8(r10),r0
	incl	8(r10)
	movb	12(ap),(r0)
	pushl	r9
	calls	$1,_splx
	jbr	L191
L186:
	pushl	r9
	calls	$1,_splx
	pushl	$16
	calls	$1,_allocb
	movl	r0,r10
	jneq	L192
	clrl	r0
	jbr	L185
L192:
	movl	8(r10),r0
	incl	8(r10)
	movb	12(ap),(r0)
	pushl	r10
	pushl	r11
	calls	$2,*4(ap)
L191:
	movl	$1,r0
	jbr	L185
	.stabs	"s",0x40,0,4,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L185:
	ret
	.set	L.R13,0xe00
	.set	L.SO13,0x0
L193:	.data
	.text
	.align	2
	.globl	_putctl
_putctl:
	.word	L.R14
	subl2	$L.SO14,sp
	.stabs	"putctl",0x24,0,516,_putctl
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	pushl	$0
	calls	$1,_allocb
	movl	r0,r11
	jneq	L196
	clrl	r0
	jbr	L195
L196:
	movb	8(ap),20(r11)
	pushl	r11
	pushl	4(ap)
	movl	*4(ap),r0
	movl	(r0),r1
	calls	$2,(r1)
	movl	$1,r0
	jbr	L195
	.stabs	"bp",0x40,0,40,11
L195:
	ret
	.set	L.R14,0x800
	.set	L.SO14,0x0
L197:	.data
	.text
	.align	2
	.globl	_putctld
_putctld:
	.word	L.R15
	subl2	$L.SO15,sp
	.stabs	"putctld",0x24,0,531,_putctld
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	pushl	$0
	calls	$1,_allocb
	movl	r0,r11
	jneq	L200
	clrl	r0
	jbr	L199
L200:
	movb	8(ap),20(r11)
	bisb2	$128,21(r11)
	pushl	r11
	pushl	4(ap)
	movl	*4(ap),r0
	movl	(r0),r1
	calls	$2,(r1)
	movl	$1,r0
	jbr	L199
	.stabs	"bp",0x40,0,40,11
L199:
	ret
	.set	L.R15,0x800
	.set	L.SO15,0x0
L201:	.data
	.text
	.align	2
	.globl	_putctl1
_putctl1:
	.word	L.R16
	subl2	$L.SO16,sp
	.stabs	"putctl1",0x24,0,547,_putctl1
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	.stabs	"p",0xa0,0,4,12
	pushl	$1
	calls	$1,_allocb
	movl	r0,r11
	jneq	L204
	clrl	r0
	jbr	L203
L204:
	movb	8(ap),20(r11)
	movl	8(r11),r0
	incl	8(r11)
	movb	12(ap),(r0)
	pushl	r11
	pushl	4(ap)
	movl	*4(ap),r0
	movl	(r0),r1
	calls	$2,(r1)
	movl	$1,r0
	jbr	L203
	.stabs	"bp",0x40,0,40,11
L203:
	ret
	.set	L.R16,0x800
	.set	L.SO16,0x0
L205:	.data
	.text
	.align	2
	.globl	_putctl1d
_putctl1d:
	.word	L.R17
	subl2	$L.SO17,sp
	.stabs	"putctl1d",0x24,0,563,_putctl1d
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	.stabs	"p",0xa0,0,4,12
	pushl	$1
	calls	$1,_allocb
	movl	r0,r11
	jneq	L208
	clrl	r0
	jbr	L207
L208:
	movb	8(ap),20(r11)
	bisb2	$128,21(r11)
	movl	8(r11),r0
	incl	8(r11)
	movb	12(ap),(r0)
	pushl	r11
	pushl	4(ap)
	movl	*4(ap),r0
	movl	(r0),r1
	calls	$2,(r1)
	movl	$1,r0
	jbr	L207
	.stabs	"bp",0x40,0,40,11
L207:
	ret
	.set	L.R17,0x800
	.set	L.SO17,0x0
L209:	.data
	.text
	.align	2
	.globl	_putctl2
_putctl2:
	.word	L.R18
	subl2	$L.SO18,sp
	.stabs	"putctl2",0x24,0,580,_putctl2
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	.stabs	"p1",0xa0,0,4,12
	.stabs	"p2",0xa0,0,4,16
	pushl	$2
	calls	$1,_allocb
	movl	r0,r11
	jneq	L212
	clrl	r0
	jbr	L211
L212:
	movb	8(ap),20(r11)
	movl	8(r11),r0
	incl	8(r11)
	movb	12(ap),(r0)
	movl	8(r11),r0
	incl	8(r11)
	movb	16(ap),(r0)
	pushl	r11
	pushl	4(ap)
	movl	*4(ap),r0
	movl	(r0),r1
	calls	$2,(r1)
	movl	$1,r0
	jbr	L211
	.stabs	"bp",0x40,0,40,11
L211:
	ret
	.set	L.R18,0x800
	.set	L.SO18,0x0
L213:	.data
	.text
	.align	2
	.globl	_qpctl
_qpctl:
	.word	L.R19
	subl2	$L.SO19,sp
	.stabs	"qpctl",0x24,0,597,_qpctl
	.stabs	"q",0xa0,0,40,4
	.stabs	"d",0xa0,0,4,8
	movl	4(ap),r11
	pushl	$1
	calls	$1,_allocb
	movl	r0,r10
	tstl	r10
	jeql	L216
	movb	8(ap),20(r10)
	pushl	r10
	pushl	r11
	calls	$2,_putq
L216:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L215:
	ret
	.set	L.R19,0xc00
	.set	L.SO19,0x0
L217:	.data
	.text
	.align	2
	.globl	_qpctl1
_qpctl1:
	.word	L.R20
	subl2	$L.SO20,sp
	.stabs	"qpctl1",0x24,0,608,_qpctl1
	.stabs	"q",0xa0,0,40,4
	.stabs	"c",0xa0,0,4,8
	.stabs	"d",0xa0,0,4,12
	movl	4(ap),r11
	pushl	$1
	calls	$1,_allocb
	movl	r0,r10
	tstl	r10
	jeql	L220
	movb	8(ap),20(r10)
	movl	8(r10),r0
	incl	8(r10)
	movb	12(ap),(r0)
	pushl	r10
	pushl	r11
	calls	$2,_putq
L220:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L219:
	ret
	.set	L.R20,0xc00
	.set	L.SO20,0x0
L221:	.data
	.text
	.align	2
	.globl	_qpctld
_qpctld:
	.word	L.R21
	subl2	$L.SO21,sp
	.stabs	"qpctld",0x24,0,620,_qpctld
	.stabs	"q",0xa0,0,40,4
	.stabs	"d",0xa0,0,4,8
	movl	4(ap),r11
	pushl	$1
	calls	$1,_allocb
	movl	r0,r10
	tstl	r10
	jeql	L224
	movb	8(ap),20(r10)
	bisb2	$128,21(r10)
	pushl	r10
	pushl	r11
	calls	$2,_putq
L224:
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L223:
	ret
	.set	L.R21,0xc00
	.set	L.SO21,0x0
L225:	.data
	.text
	.align	2
	.globl	_putcpy
_putcpy:
	.word	L.R22
	subl2	$L.SO22,sp
	.stabs	"putcpy",0x24,0,636,_putcpy
	.stabs	"q",0xa0,0,40,4
	.stabs	"cp",0xa0,0,34,8
	.stabs	"n",0xa0,0,4,12
	movl	4(ap),r11
	movl	8(ap),r10
	jbr	L229
L230:
	pushl	12(ap)
	calls	$1,_allocb
	movl	r0,r9
	jneq	L231
	jbr	L227
L231:
	clrb	20(r9)
	subl3	8(r9),12(r9),r8
	cmpl	r8,12(ap)
	jleq	L232
	movl	12(ap),r8
L232:
	pushl	r8
	pushl	8(r9)
	pushl	r10
	calls	$3,_bcopy
	addl2	r8,r10
	addl2	r8,8(r9)
	subl2	r8,12(ap)
	pushl	r9
	pushl	r11
	movl	*(r11),r0
	calls	$2,(r0)
L229:
	tstl	12(ap)
	jneq	L230
L228:
	.stabs	"nm",0x40,0,4,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"cp",0x40,0,34,10
	.stabs	"q",0x40,0,40,11
L227:
	ret
	.set	L.R22,0xf00
	.set	L.SO22,0x0
L233:	.data
	.text
	.align	2
	.globl	_backq
_backq:
	.word	L.R23
	subl2	$L.SO23,sp
	.stabs	"backq",0x24,0,661,_backq
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	bitw	$16,26(r11)
	jeql	L235
	addl3	$28,r11,r0
	jbr	L236
L235:
	subl3	$28,r11,r0
L236:
	movl	r0,r11
	tstl	12(r11)
	jeql	L237
	movl	12(r11),r11
	bitw	$16,26(r11)
	jeql	L238
	addl3	$28,r11,r0
	jbr	L239
L238:
	subl3	$28,r11,r0
L239:
	jbr	L234
L237:
	bitw	$16,26(r11)
	jeql	L240
	addl3	$28,r11,r0
	jbr	L241
L240:
	subl3	$28,r11,r0
L241:
	movl	r0,r11
	.data	1
L242:

	.byte	0x62,0x61,0x63,0x6b,0x71,0x20,0x63,0x61
	.byte	0x6c,0x6c,0x65,0x64,0x20,0x77,0x69,0x74
	.byte	0x68,0x20,0x6e,0x6f,0x20,0x62,0x61,0x63
	.byte	0x6b,0x20,0x28,0x51,0x20,0x25,0x78,0x29
	.byte	0xa,0x0
	.text
	pushl	r11
	pushl	$L242
	calls	$2,_printf
	.data	1
L243:

	.byte	0x62,0x61,0x63,0x6b,0x71,0x0
	.text
	pushl	$L243
	calls	$1,_panic
	clrl	r0
	jbr	L234
	.stabs	"q",0x40,0,40,11
L234:
	ret
	.set	L.R23,0x800
	.set	L.SO23,0x0
L244:	.data
	.text
	.align	2
	.globl	_qreply
_qreply:
	.word	L.R24
	subl2	$L.SO24,sp
	.stabs	"qreply",0x24,0,680,_qreply
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	bitw	$16,26(r11)
	jeql	L247
	addl3	$28,r11,r0
	jbr	L248
L247:
	subl3	$28,r11,r0
L248:
	movl	r0,r11
	pushl	8(ap)
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	.stabs	"q",0x40,0,40,11
L246:
	ret
	.set	L.R24,0x800
	.set	L.SO24,0x0
L249:	.data
	.text
	.align	2
	.globl	_qenable
_qenable:
	.word	L.R25
	subl2	$L.SO25,sp
	.stabs	"qenable",0x24,0,691,_qenable
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	calls	$0,_spl6
	movl	r0,r10
	bitw	$1,26(r11)
	jeql	L251
	pushl	r10
	calls	$1,_splx
	jbr	L250
L251:
	movl	(r11),r0
	tstl	4(r0)
	jneq	L252
	pushl	r10
	calls	$1,_splx
	jbr	L250
L252:
	bisw2	$1,26(r11)
	clrl	16(r11)
	tstl	_qhead
	jneq	L253
	movl	r11,_qhead
	jbr	L254
L253:
	movl	_qtail,r0
	movl	r11,16(r0)
L254:
	movl	r11,_qtail
	pushl	$3
	pushl	$20
	calls	$2,_mtpr
	pushl	r10
	calls	$1,_splx
	.stabs	"s",0x40,0,4,10
	.stabs	"q",0x40,0,40,11
L250:
	ret
	.set	L.R25,0xc00
	.set	L.SO25,0x0
L256:	.data
	.text
	.align	2
	.globl	_queuerun
_queuerun:
	.word	L.R26
	subl2	$L.SO26,sp
	.stabs	"queuerun",0x24,0,719,_queuerun
	tstl	_panicstr
	jeql	L261
	jbr	L258
L261:
	calls	$0,_spl6
	movl	r0,r10
	incl	_queueflag
	jbr	L263
L264:
	movl	16(r11),_qhead
	jneq	L265
	clrl	_qtail
L265:
	bicw2	$-65535,26(r11)
	pushl	r10
	calls	$1,_splx
	movl	(r11),r0
	tstl	4(r0)
	jeql	L266
	pushl	r11
	movl	(r11),r0
	calls	$1,*4(r0)
	jbr	L267
L266:
	.data	1
L268:

	.byte	0x51,0x20,0x25,0x78,0x20,0x72,0x75,0x6e
	.byte	0x20,0x77,0x69,0x74,0x68,0x20,0x6e,0x6f
	.byte	0x20,0x73,0x72,0x76,0x70,0xa,0x0
	.text
	pushl	r11
	pushl	$L268
	calls	$2,_printf
L267:
	calls	$0,_spl6
L263:
	movl	_qhead,r11
	jneq	L264
L262:
	decl	_queueflag
	pushl	r10
	calls	$1,_splx
	.stabs	"s",0x40,0,4,10
	.stabs	"q",0x40,0,40,11
L258:
	ret
	.set	L.R26,0xc00
	.set	L.SO26,0x0
L269:	.data
	.text
L270:	.stabs	"stream.c",0x94,0,743,L270
