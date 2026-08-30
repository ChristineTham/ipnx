L11:	.stabs	"dkmod.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553094
	.data
	.align	2
	.globl	_dkmodcnt
_dkmodcnt:
	.long	4
	.comm	_dkmod,64
	.comm	_dkstat,64
	.text
	.align	2
	.globl	_dkmodall
_dkmodall:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"dkmodall",0x24,0,26,_dkmodall
	.stabs	"dev",0xa0,0,13,4
	.stabs	"lo",0xa0,0,4,8
	.stabs	"hi",0xa0,0,4,12
	movzwl	4(ap),r0
	extzv	$8,$24,r0,r1
	movw	r1,r0
	bicw3	$-256,r0,4(ap)
	clrl	r9
	movl	$_dkmod,r10
	clrl	r11
	jbr	L25
L26:
	tstw	8(r10)
	jneq	L27
	tstl	r9
	jneq	L27
L28:
	movl	r10,r9
	jbr	L23
L27:
	cmpw	8(r10),4(ap)
	jneq	L29
	cvtwl	10(r10),r0
	cmpl	r0,8(ap)
	jneq	L29
L31:
	cvtwl	12(r10),r0
	cmpl	r0,12(ap)
	jneq	L29
L30:
	movl	r10,r0
	jbr	L22
L29:
L23:
	addl2	$16,r10
	movl	r11,r0
	incl	r11
L25:
	cmpl	r11,$4
	jlss	L26
L24:
	tstl	r9
	jeql	L32
	movw	4(ap),8(r9)
	movw	8(ap),10(r9)
	movw	12(ap),12(r9)
L32:
	movl	r9,r0
	jbr	L22
	.stabs	"ek",0x40,0,40,9
	.stabs	"dk",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L22:
	ret
	.set	L.R1,0xe00
	.set	L.SO1,0x0
L33:	.data
	.text
	.align	2
	.globl	_getdkmod
_getdkmod:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"getdkmod",0x24,0,52,_getdkmod
	.stabs	"dev",0xa0,0,13,4
	movzwl	4(ap),r0
	extzv	$8,$24,r0,r0
	bicl3	$-256,r0,r9
	movzwl	4(ap),r0
	bicl3	$-256,r0,r8
	movl	$_dkmod,r10
	clrl	r11
	jbr	L37
L38:
	cvtwl	8(r10),r0
	cmpl	r0,r9
	jneq	L39
	cvtwl	10(r10),r0
	cmpl	r8,r0
	jlss	L39
L41:
	cvtwl	12(r10),r0
	cmpl	r8,r0
	jgeq	L39
L40:
	movl	r10,r0
	jbr	L34
L39:
	addl2	$16,r10
	movl	r11,r0
	incl	r11
L37:
	cmpl	r11,$4
	jlss	L38
L36:
	clrl	r0
	jbr	L34
	.stabs	"min",0x40,0,4,8
	.stabs	"maj",0x40,0,4,9
	.stabs	"dk",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L34:
	ret
	.set	L.R2,0xf00
	.set	L.SO2,0x0
L42:	.data
	.text
L43:	.stabs	"dkmod.c",0x94,0,64,L43
