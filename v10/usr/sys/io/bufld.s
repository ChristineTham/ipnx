L11:	.stabs	"bufld.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553096
	.data
	.comm	_nswdevt,4
	.comm	_bufldact,4
	.align	2
_bufrinit:
	.long	_bufput
	.long	_bufsrv
	.long	_bufopen
	.long	_bufclose
	.long	0x2000400
	.align	2
_bufwinit:
	.long	_bufput
	.long	_bufsrv
	.long	_bufopen
	.long	_bufclose
	.long	0x400080
	.align	2
	.globl	_bufldstream
_bufldstream:
	.long	_bufrinit
	.long	_bufwinit
	.text
	.align	2
	.globl	_bufopen
_bufopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"bufopen",0x24,0,27,_bufopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	tstl	20(r11)
	jeql	L55
	movl	$1,r0
	jbr	L54
L55:
	clrl	r10
	jbr	L58
L59:
	addl2	$2,r10
L58:
	mull3	$12,r10,r0
	tstl	_bufld(r0)
	jeql	L60
	cmpl	r10,_bufldcnt
	jlss	L59
L60:
L57:
	cmpl	r10,_bufldcnt
	jgeq	L62
	cmpl	r10,$32
	jlss	L61
L62:
	clrl	r0
	jbr	L54
L61:
	mull3	$12,r10,r0
	addl3	$_bufld,r0,r9
	movl	r11,(r9)
	addl3	$28,r11,12(r9)
	movb	r10,8(r9)
	movb	r10,r0
	addb3	$1,r0,20(r9)
	movb	$3,7(r9)
	movb	$3,19(r9)
	movb	$16,6(r9)
	movb	$16,18(r9)
	clrb	4(r9)
	clrb	16(r9)
	clrb	5(r9)
	clrb	17(r9)
	movl	12(r11),r0
	bicw3	$-129,26(r0),r1
	bisw2	r1,26(r11)
	movl	40(r11),r0
	bicw3	$-129,26(r0),r1
	bisw2	r1,54(r11)
	movl	r9,20(r11)
	addl3	$12,r9,48(r11)
	bisw2	$64,26(r11)
	bisw2	$64,54(r11)
	movl	$1,r0
	jbr	L54
	.stabs	"fp",0x40,0,40,9
	.stabs	"i",0x40,0,4,10
	.stabs	"q",0x40,0,40,11
L54:
	ret
	.set	L.R1,0xe00
	.set	L.SO1,0x0
L63:	.data
	.text
	.align	2
	.globl	_bufclose
_bufclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"bufclose",0x24,0,61,_bufclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	pushl	r11
	calls	$1,_bufunload
	addl3	$28,r11,-(sp)
	calls	$1,_bufunload
	movl	20(r11),r0
	clrb	5(r0)
	movl	48(r11),r0
	clrb	5(r0)
	clrl	*20(r11)
	clrl	*48(r11)
	.stabs	"q",0x40,0,40,11
L64:
	ret
	.set	L.R2,0x800
	.set	L.SO2,0x0
L66:	.data
	.text
	.align	2
	.globl	_bufput
_bufput:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"bufput",0x24,0,74,_bufput
	.stabs	"q",0xa0,0,40,4
	.stabs	"bp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	movl	20(r11),r9
	calls	$0,_spl6
	movl	r0,r8
	movzbl	20(r10),r6
	subl3	4(r10),8(r10),r7
	pushl	r10
	pushl	r11
	calls	$2,_putq
	movb	r7,r0
	addb2	r0,4(r9)
	tstl	r6
	jneq	L70
	cmpb	4(r9),6(r9)
	jlssu	L69
L70:
	pushl	r11
	calls	$1,_bufunload
L69:
	tstl	4(r11)
	jeql	L71
	divl3	$2,r7,r0
	movb	r0,r0
	addb3	r0,7(r9),5(r9)
	tstl	_bufldact
	jneq	L72
	pushl	$1
	pushl	$0
	pushl	$_buftimo
	calls	$3,_timeout
L72:
	movzbl	8(r9),r0
	ashl	r0,$1,r0
	bisl2	r0,_bufldact
	jbr	L74
L71:
	clrb	4(r9)
	clrb	5(r9)
L74:
	pushl	r8
	calls	$1,_splx
	.stabs	"t",0x40,0,4,6
	.stabs	"n",0x40,0,4,7
	.stabs	"s",0x40,0,4,8
	.stabs	"fp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L67:
	ret
	.set	L.R3,0xfc0
	.set	L.SO3,0x0
L76:	.data
	.text
	.align	2
	.globl	_bufsrv
_bufsrv:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"bufsrv",0x24,0,100,_bufsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r10
	tstl	4(r11)
	jeql	L78
	tstb	5(r10)
	jneq	L78
L79:
	pushl	r11
	calls	$1,_bufunload
L78:
	.stabs	"fp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L77:
	ret
	.set	L.R4,0xc00
	.set	L.SO4,0x0
L80:	.data
	.text
	.align	2
	.globl	_bufunload
_bufunload:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"bufunload",0x24,0,109,_bufunload
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	20(r11),r9
	jbr	L83
L84:
	subb3	4(r10),8(r10),r0
	subb2	r0,4(r9)
	pushl	r10
	pushl	12(r11)
	movl	*12(r11),r0
	movl	(r0),r1
	calls	$2,(r1)
L83:
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L85
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L84
L85:
L82:
	.stabs	"fp",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L81:
	ret
	.set	L.R5,0xe00
	.set	L.SO5,0x0
L86:	.data
	.text
	.align	2
	.globl	_buftimo
_buftimo:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"buftimo",0x24,0,120,_buftimo
	movl	_bufldact,r11
	movl	$_bufld,r10
	movl	$1,r9
	jbr	L90
L91:
	bitl	r9,r11
	jeql	L92
	mcoml	r9,r0
	mcoml	r0,r1
	bicl2	r1,r11
	tstb	5(r10)
	jeql	L93
	decb	5(r10)
	tstb	5(r10)
	jneq	L94
	tstl	(r10)
	jeql	L94
L96:
	movl	(r10),r0
	tstl	4(r0)
	jeql	L94
L95:
	pushl	(r10)
	calls	$1,_qenable
	mcoml	r9,r0
	mcoml	r0,r1
	bicl2	r1,_bufldact
L94:
L93:
L92:
	addl2	$12,r10
	addl2	r9,r9
L90:
	tstl	r11
	jneq	L91
L89:
	tstl	_bufldact
	jeql	L98
	pushl	$1
	pushl	$0
	pushl	$_buftimo
	calls	$3,_timeout
L98:
	.stabs	"ish",0x40,0,4,9
	.stabs	"fp",0x40,0,40,10
	.stabs	"bact",0x40,0,4,11
L87:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x0
L99:	.data
	.stabs	"bufwinit",0x26,0,8,_bufwinit
	.stabs	"bufrinit",0x26,0,8,_bufrinit
	.text
L100:	.stabs	"bufld.c",0x94,0,142,L100
