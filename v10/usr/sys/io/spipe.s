L11:	.stabs	"spipe.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553662
	.data
	.comm	_nswdevt,4
	.align	2
_sprinit:
	.long	_putq
	.long	_spsrv
	.long	_spopen
	.long	_spclose
	.long	0x410080
	.align	2
	.globl	_spinfo
_spinfo:
	.long	_sprinit
	.long	_sprinit
	.align	2
	.globl	_spcdev
_spcdev:
	.long	_nodev
	.long	_nulldev
	.long	_nodev
	.long	_nodev
	.long	_nodev
	.long	_nulldev
	.long	_spinfo
	.text
	.align	2
	.globl	_spopen
_spopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"spopen",0x24,0,20,_spopen
	.stabs	"q",0xa0,0,40,4
	.stabs	"dev",0xa0,0,4,8
	movl	4(ap),r11
	bicl3	$-256,8(ap),r10
	cmpl	r10,_spcnt
	jleq	L52
	clrl	r0
	jbr	L51
L52:
	tstl	20(r11)
	jeql	L53
	bitl	$1,r10
	jeql	L54
	clrl	r0
	jbr	L51
L54:
	movl	$1,r0
	jbr	L51
L53:
	bisw2	$128,26(r11)
	xorl3	$1,r10,r0
	movl	_spipes[r0],r9
	jeql	L55
	bitl	$1,r10
	jeql	L56
	clrl	r0
	jbr	L51
L56:
	movl	r9,48(r11)
	movl	r11,48(r9)
	jbr	L57
L55:
	bitl	$1,r10
	jneq	L58
	clrl	r0
	jbr	L51
L58:
L57:
	movl	8(ap),20(r11)
	movl	r11,_spipes[r10]
	movl	$1,r0
	jbr	L51
	.stabs	"oq",0x40,0,40,9
	.stabs	"d",0x40,0,4,10
	.stabs	"q",0x40,0,40,11
L51:
	ret
	.set	L.R1,0xe00
	.set	L.SO1,0x0
L59:	.data
	.text
	.align	2
	.globl	_spclose
_spclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"spclose",0x24,0,47,_spclose
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	movl	48(r11),r10
	jeql	L61
	jbr	L63
L64:
	pushl	r9
	pushl	12(r10)
	movl	*12(r10),r0
	movl	(r0),r1
	calls	$2,(r1)
L63:
	addl3	$28,r11,-(sp)
	calls	$1,_getq
	movl	r0,r9
	jneq	L64
L62:
	pushl	$2
	pushl	12(r10)
	calls	$2,_putctl
	clrl	48(r10)
L61:
	bicl3	$-256,20(r11),r0
	clrl	_spipes[r0]
	.stabs	"bp",0x40,0,40,9
	.stabs	"oq",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L60:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L66:	.data
	.text
	.align	2
	.globl	_spsrv
_spsrv:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"spsrv",0x24,0,62,_spsrv
	.stabs	"q",0xa0,0,40,4
	movl	4(ap),r11
	bitw	$16,26(r11)
	jeql	L68
	movl	48(r11),r9
	tstl	r9
	jeql	L69
	movl	12(r11),r0
	bitw	$8,26(r0)
	jneq	L69
L70:
	addl3	$28,r9,-(sp)
	calls	$1,_qenable
L69:
	jbr	L67
L68:
	movl	20(r11),r9
	jbr	L73
L74:
	tstl	r9
	jneq	L75
	pushl	r10
	calls	$1,_freeb
	jbr	L73
L75:
	movl	12(r9),r0
	bitw	$8,26(r0)
	jeql	L77
	cmpb	20(r10),$64
	jgequ	L77
L78:
	pushl	r10
	pushl	r11
	calls	$2,_putbq
	jbr	L67
L77:
	pushl	r10
	pushl	12(r9)
	movl	*12(r9),r0
	movl	(r0),r1
	calls	$2,(r1)
L73:
	pushl	r11
	calls	$1,_getq
	movl	r0,r10
	jneq	L74
L72:
	.stabs	"oq",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"q",0x40,0,40,11
L67:
	ret
	.set	L.R3,0xe00
	.set	L.SO3,0x0
L80:	.data
	.stabs	"sprinit",0x26,0,8,_sprinit
	.text
L81:	.stabs	"spipe.c",0x94,0,85,L81
