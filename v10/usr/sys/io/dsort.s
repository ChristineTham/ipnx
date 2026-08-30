L11:	.stabs	"dsort.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553293
	.data
	.comm	_buf,4
	.comm	_buffers,4
	.comm	_nbuf,4
	.comm	_swsize,4
	.comm	_swpf,4
	.comm	_bfreelist,132
	.comm	_bswlist,44
	.comm	_bclnlist,4
	.text
	.align	2
	.globl	_disksort
_disksort:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"disksort",0x24,0,20,_disksort
	.stabs	"actf",0xa0,0,168,4
	.stabs	"actl",0xa0,0,168,8
	.stabs	"bp",0xa0,0,40,12
	movl	4(ap),r11
	movl	8(ap),r10
	movl	12(ap),r9
	movl	(r11),r8
	jneq	L34
	movl	r9,r0
	movl	r0,(r10)
	movl	r0,(r11)
	clrl	12(r9)
	jbr	L33
L34:
	cmpl	36(r9),36(r8)
	jgeq	L35
	jbr	L37
L38:
	movl	12(r8),r0
	cmpl	36(r0),36(r8)
	jgeq	L39
	clrl	r7
	jbr	L36
L39:
	movl	12(r8),r8
L37:
	tstl	12(r8)
	jneq	L38
L36:
	jbr	L40
L35:
	movl	36(r8),r7
L40:
	jbr	L42
L43:
	movl	12(r8),r0
	cmpl	36(r0),r7
	jlss	L45
	movl	12(r8),r0
	cmpl	36(r9),36(r0)
	jgeq	L44
L45:
	jbr	L41
L44:
	movl	12(r8),r8
	movl	36(r8),r7
L42:
	tstl	12(r8)
	jneq	L43
L41:
	movl	12(r8),12(r9)
	movl	r9,12(r8)
	cmpl	r8,(r10)
	jneq	L46
	movl	r9,(r10)
L46:
	.stabs	"cyl",0x40,0,4,7
	.stabs	"ap",0x40,0,40,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"actl",0x40,0,168,10
	.stabs	"actf",0x40,0,168,11
L33:
	ret
	.set	L.R1,0xf80
	.set	L.SO1,0x0
L47:	.data
	.text
L48:	.stabs	"dsort.c",0x94,0,52,L48
