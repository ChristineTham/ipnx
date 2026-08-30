L11:	.stabs	"connld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553096
	.data
	.comm	_nswdevt,4
	.comm	_rootdir,4
	.align	2
_connrinit:
	.long	_connput
	.long	0
	.long	_connopen
	.long	_nulldev
	.long	0x0
	.align	2
_connwinit:
	.long	_connput
	.long	0
	.long	_connopen
	.long	_nulldev
	.long	0x0
	.align	2
	.globl	_connstream
_connstream:
	.long	_connrinit
	.long	_connwinit
	.align	2
_connrgrab:
	.long	_conngput
	.long	0
	.long	_connnull
	.long	_nulldev
	.long	0x0
	.align	2
_connwgrab:
	.long	_connput
	.long	0
	.long	_connnull
	.long	_nulldev
	.long	0x0
	.align	2
_connginfo:
	.long	_connrgrab
	.long	_connwgrab
	.text
	.align	2
	.globl	_connopen
_connopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"connopen",0x24,0,29,_connopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	tstl	20(r11)
	jneq	L70
	movl	$1,20(r11)
	movl	$1,r0
	jbr	L69
L70:
	calls	$0,_allocfile
	movl	r0,r10
	jneq	L71
	clrl	r0
	jbr	L69
L71:
	pushal	-8(fp)
	pushal	-4(fp)
	calls	$2,_makepipe
	tstl	r0
	jneq	L73
	clrw	2(r10)
	clrl	r0
	jbr	L69
L73:
	movl	-8(fp),4(r10)
	movw	$3,(r10)
	decw	2(r10)
	movl	-4(fp),r0
	subl3	$28,*32(r0),r6
	pushl	r10
	addl3	$28,r11,-(sp)
	calls	$2,_sndfile
	tstl	r0
	jneq	L75
	pushl	$1
	pushl	-4(fp)
	calls	$2,_stclose
	pushl	-4(fp)
	calls	$1,_iput
	pushl	$1
	pushl	-8(fp)
	calls	$2,_stclose
	pushl	-8(fp)
	calls	$1,_iput
	clrl	r0
	jbr	L69
L75:
	pushl	$0
	pushl	r6
	pushl	$_connginfo
	calls	$3,_qattach
	tstl	r0
	jneq	L79
	pushl	$1
	pushl	-4(fp)
	calls	$2,_stclose
	pushl	-4(fp)
	calls	$1,_iput
	clrl	r0
	jbr	L69
L79:
	pushl	r6
	calls	$1,_backq
	movl	r0,r6
	calls	$0,_spl6
	movl	r0,r8
	jbr	L82
L83:
	pushl	$0
	pushl	$28
	pushl	r6
	calls	$3,_tsleep
	tstl	r0
	jeql	L85
	pushl	$1
	pushl	-4(fp)
	calls	$2,_stclose
	pushl	-4(fp)
	calls	$1,_iput
	clrl	r0
	jbr	L69
L85:
L82:
	pushl	r6
	calls	$1,_getq
	movl	r0,r7
	jeql	L83
L81:
	pushl	r8
	calls	$1,_splx
	movzbl	20(r7),r0
	jbr	L88
L89:
	pushl	r7
	calls	$1,_freeb
	pushl	$1
	pushl	-4(fp)
	calls	$2,_stclose
	pushl	-4(fp)
	calls	$1,_iput
	clrl	r0
	jbr	L69
L91:
	pushl	$1
	pushl	-4(fp)
	calls	$2,_stclose
	pushl	-4(fp)
	calls	$1,_iput
	movl	*4(r7),r9
	movl	4(r9),-4(fp)
	movl	-4(fp),r0
	incw	6(r0)
	pushl	r9
	calls	$1,_closef
	movl	-4(fp),r0
	jbr	L69
L93:
	movzbl	*4(r7),r0
	movl	4(r7),r1
	movzbl	1(r1),r1
	ashl	$8,r1,r1
	bisl3	r1,r0,-12(fp)
	cmpl	-12(fp),$26121
	jeql	L95
	cmpl	-12(fp),$26122
	jneq	L94
L95:
	movb	$69,20(r7)
	movl	4(r7),8(r7)
	pushl	r7
	pushl	r6
	calls	$2,_qreply
	cmpl	-12(fp),$26122
	jneq	L97
	pushl	$1
	pushl	-4(fp)
	calls	$2,_stclose
	pushl	-4(fp)
	calls	$1,_iput
	clrl	r0
	jbr	L69
L97:
	jbr	L99
L100:
	pushl	r7
	pushl	12(r6)
	movl	*12(r6),r0
	movl	(r0),r1
	calls	$2,(r1)
L99:
	pushl	r6
	calls	$1,_getq
	movl	r0,r7
	jneq	L100
L98:
	pushl	$1
	pushl	r6
	calls	$2,_qdetach
	movl	-4(fp),r0
	jbr	L69
L94:
L102:
	pushl	r7
	pushl	12(r6)
	movl	*12(r6),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L104
L105:
	pushl	r7
	pushl	12(r6)
	movl	*12(r6),r0
	movl	(r0),r1
	calls	$2,(r1)
L104:
	pushl	r6
	calls	$1,_getq
	movl	r0,r7
	jneq	L105
L103:
	pushl	$1
	pushl	r6
	calls	$2,_qdetach
	movl	-4(fp),r0
	jbr	L69
L88:
	casel	r0,$2,$7
L106:
	.word	L89-L106
	.word	L102-L106
	.word	L102-L106
	.word	L102-L106
	.word	L93-L106
	.word	L102-L106
	.word	L102-L106
	.word	L91-L106
	jbr	L102
L87:
	.stabs	"ioc",0x80,0,4,12
	.stabs	"nq",0x40,0,40,6
	.stabs	"bp",0x40,0,40,7
	.stabs	"s",0x40,0,4,8
	.stabs	"nfp",0x40,0,40,9
	.stabs	"fp",0x40,0,40,10
	.stabs	"ip2",0x80,0,40,8
	.stabs	"ip1",0x80,0,40,4
	.stabs	"q",0x40,0,40,11
L69:
	ret
	.set	L.R1,0xfc0
	.set	L.SO1,0xc
L107:	.data
	.text
	.align	2
	.globl	_connnull
_connnull:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"connnull",0x24,0,124,_connnull
	movl	$1,r0
	jbr	L108
L108:
	ret
	.set	L.R2,0x0
	.set	L.SO2,0x0
L109:	.data
	.text
	.align	2
	.globl	_connput
_connput:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"connput",0x24,0,131,_connput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movzbl	20(r10),r0
	jbr	L112
L113:
L114:
L115:
L116:
L117:
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
	jbr	L110
L112:
	cmpl	r0,$2
	jeql	L113
	cmpl	r0,$6
	jeql	L114
	cmpl	r0,$9
	jeql	L117
	cmpl	r0,$69
	jeql	L115
	cmpl	r0,$70
	jeql	L116
L111:
	pushl	r10
	calls	$1,_freeb
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L110:
	ret
	.set	L.R3,0xc00
	.set	L.SO3,0x0
L118:	.data
	.text
	.align	2
	.globl	_conngput
_conngput:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"conngput",0x24,0,148,_conngput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	pushl	r10
	pushl	r11
	calls	$2,_putq
	pushl	r11
	calls	$1,_wakeup
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L119:
	ret
	.set	L.R4,0xc00
	.set	L.SO4,0x0
L121:	.data
	.stabs	"connginfo",0x26,0,8,_connginfo
	.stabs	"connwgrab",0x26,0,8,_connwgrab
	.stabs	"connrgrab",0x26,0,8,_connrgrab
	.stabs	"connwinit",0x26,0,8,_connwinit
	.stabs	"connrinit",0x26,0,8,_connrinit
	.text
L122:	.stabs	"connld.c",0x94,0,152,L122
