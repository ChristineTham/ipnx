L11:	.stabs	"fineclock.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553091
	.data
	.comm	_lbolt,4
	.comm	_time,4
	.comm	_runin,1
	.comm	_runout,1
	.comm	_runrun,4
	.comm	_noproc,4
	.comm	_curpri,1
	.comm	_maxmem,4
	.comm	_physmem,4
	.comm	_wantin,4
	.comm	_rablock,4
	.comm	_rootdev,2
	.comm	_argdev,2
	.comm	_buf,4
	.comm	_buffers,4
	.comm	_nbuf,4
	.comm	_swsize,4
	.comm	_swpf,4
	.comm	_bfreelist,132
	.comm	_bswlist,44
	.comm	_bclnlist,4
	.comm	_nswdevt,4
	.comm	_zvms,40
	.align	2
	.globl	_clkcdev
_clkcdev:
	.long	_nulldev
	.long	_nulldev
	.long	_clkread
	.long	_nodev
	.long	_nodev
	.long	_nulldev
	.long	0
	.text
	.align	2
_clkread:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"clkread",0x24,0,21,_clkread
	.stabs	"clkread",0x32,0,68,0
	.stabs	"dev",0xa0,0,4,4
	calls	$0,_spl7
	movl	r0,r11
	pushl	$26
	calls	$1,_mfpr
	addl3	$16667,r0,-4(fp)
	pushl	$24
	calls	$1,_mfpr
	bitl	$128,r0
	jeql	L82
	addl2	$16667,-4(fp)
L82:
	mull3	$16667,_lbolt,r0
	mull3	$16667,_time,r1
	mull2	$60,r1
	addl2	r1,r0
	addl2	r0,-4(fp)
	pushl	r11
	calls	$1,_splx
	pushl	$1
	cmpl	_u+292,$4
	jgequ	L85
	movl	_u+292,-(sp)
	jbr	L86
L85:
	movl	$4,-(sp)
L86:
	pushal	-4(fp)
	calls	$3,_iomove
	.stabs	"finetime",0x80,0,4,4
	.stabs	"s",0x40,0,4,11
L79:
	ret
	.set	L.R1,0x800
	.set	L.SO1,0x4
L87:	.data
	.text
L88:	.stabs	"fineclock.c",0x94,0,33,L88
