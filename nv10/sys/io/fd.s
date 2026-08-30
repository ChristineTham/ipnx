L11:	.stabs	"fd.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553091
	.data
	.comm	_zvms,40
	.comm	_nswdevt,4
	.align	2
	.globl	_fdcdev
_fdcdev:
	.long	_fdopen
	.long	_nodev
	.long	_nodev
	.long	_nodev
	.long	_nodev
	.long	_nulldev
	.long	0
	.text
	.align	2
	.globl	_fdopen
_fdopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"fdopen",0x24,0,16,_fdopen
	.stabs	"dev",0xa0,0,4,4
	.stabs	"flag",0xa0,0,4,8
	movl	_u+280,r10
	bicl3	$-256,4(ap),r0
	cmpl	r0,r10
	jeql	L54
	bicl3	$-256,4(ap),r0
	cmpl	r0,$128
	jlssu	L55
	clrl	r0
	jbr	L56
L55:
	bicl3	$-256,4(ap),r0
	movl	_u+344[r0],r0
L56:
	movl	r0,r11
	jneq	L53
L54:
	movb	$9,_u+197
	jbr	L52
L53:
	cmpl	r10,$128
	jgequ	L58
	tstl	_u+344[r10]
	jneq	L57
L58:
	.data	1
L60:

	.byte	0x66,0x64,0x6f,0x70,0x65,0x6e,0x0
	.text
	pushl	$L60
	calls	$1,_panic
L57:
	pushl	_u+344[r10]
	calls	$1,_closef
	movl	r11,_u+344[r10]
	incw	2(r11)
	.stabs	"ofd",0x40,0,4,10
	.stabs	"fp",0x40,0,40,11
L52:
	ret
	.set	L.R1,0xc00
	.set	L.SO1,0x0
L62:	.data
	.text
L63:	.stabs	"fd.c",0x94,0,32,L63
