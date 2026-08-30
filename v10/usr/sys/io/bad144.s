L11:	.stabs	"bad144.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553293
	.data
	.text
	.align	2
	.globl	_bad144rep
_bad144rep:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"bad144rep",0x24,0,14,_bad144rep
	.stabs	"bt",0xa0,0,40,4
	.stabs	"cyl",0xa0,0,4,8
	.stabs	"trk",0xa0,0,4,12
	.stabs	"sec",0xa0,0,4,16
	movl	4(ap),r11
	ashl	$16,8(ap),r0
	ashl	$8,12(ap),r1
	addl2	r1,r0
	addl3	16(ap),r0,r9
	clrl	r10
	jbr	L16
L17:
	addl3	$8,r11,r0
	addl3	r10,r10,r1
	addl2	r1,r1
	addl2	r1,r0
	movzwl	(r0),r0
	ashl	$16,r0,r0
	addl3	$8,r11,r1
	addl3	r10,r10,r2
	addl2	r2,r2
	addl2	r2,r1
	movzwl	2(r1),r1
	addl3	r1,r0,r8
	cmpl	r9,r8
	jneq	L18
	movl	r10,r0
	jbr	L13
L18:
	cmpl	r9,r8
	jlss	L20
	tstl	r8
	jgeq	L19
L20:
	jbr	L15
L19:
	incl	r10
L16:
	cmpl	r10,$126
	jlss	L17
L15:
	movl	$-1,r0
	jbr	L13
	.stabs	"bblk",0x40,0,4,8
	.stabs	"blk",0x40,0,4,9
	.stabs	"i",0x40,0,4,10
	.stabs	"bt",0x40,0,40,11
L13:
	ret
	.set	L.R1,0xf00
	.set	L.SO1,0x0
L21:	.data
	.text
L22:	.stabs	"bad144.c",0x94,0,28,L22
