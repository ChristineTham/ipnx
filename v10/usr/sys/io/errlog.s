L11:	.stabs	"errlog.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553293
	.data
	.comm	_nswdevt,4
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
	.comm	_zvms,40
	.comm	_buf,4
	.comm	_buffers,4
	.comm	_nbuf,4
	.comm	_swsize,4
	.comm	_swpf,4
	.comm	_bfreelist,132
	.comm	_bswlist,44
	.comm	_bclnlist,4
	.comm	_errcnt,4
	.comm	_errlog,128
	.lcomm	_errlost,4
	.lcomm	_erptr,1
	.lcomm	_ewptr,1
	.align	2
	.globl	_errcdev
_errcdev:
	.long	_erropen
	.long	_nodev
	.long	_errread
	.long	_errwrite
	.long	_nodev
	.long	_nulldev
	.long	0
	.text
	.align	2
	.globl	_erropen
_erropen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"erropen",0x24,0,37,_erropen
	.stabs	"dev",0xa0,0,13,4
	.stabs	"flag",0xa0,0,4,8
	tstl	_errcnt
	jneq	L88
	movb	$6,_u+197
L88:
L87:
	ret
	.set	L.R1,0x0
	.set	L.SO1,0x0
L89:	.data
	.text
	.align	2
	.globl	_errread
_errread:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"errread",0x24,0,45,_errread
	.stabs	"dev",0xa0,0,13,4
	cmpl	_u+292,$128
	jgequ	L91
	movb	$22,_u+197
	jbr	L90
L91:
	calls	$0,_spl7
	movl	r0,r11
	jbr	L94
L95:
	pushl	$49
	pushl	$_errlog
	calls	$2,_sleep
L94:
	cmpb	_erptr,_ewptr
	jeql	L95
L93:
	pushl	r11
	calls	$1,_splx
	cvtbl	_erptr,r0
	ashl	$7,r0,r0
	cvtbl	_errlog+2(r0),r0
	addl3	$16,r0,r11
	pushl	$1
	pushl	r11
	cvtbl	_erptr,r0
	ashl	$7,r0,r0
	addl3	$_errlog,r0,-(sp)
	calls	$3,_iomove
	incb	_erptr
	cvtbl	_erptr,r0
	cmpl	r0,_errcnt
	jlss	L99
	clrb	_erptr
L99:
	.stabs	"s",0x40,0,4,11
L90:
	ret
	.set	L.R2,0x800
	.set	L.SO2,0x0
L100:	.data
	.text
	.align	2
	.globl	_errwrite
_errwrite:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"errwrite",0x24,0,68,_errwrite
	.stabs	"dev",0xa0,0,13,4
	movl	_u+292,r11
	cmpl	r11,$132
	jlequ	L102
	movb	$22,_u+197
	jbr	L101
L102:
	pushl	$0
	pushl	r11
	pushal	-132(fp)
	calls	$3,_iomove
	tstb	_u+197
	jeql	L103
	jbr	L101
L103:
	moval	-132(fp),r10
	jbr	L105
L106:
	cmpb	(r10)+,$10
	jneq	L107
	jbr	L104
L107:
L105:
	decl	r11
	jgeq	L106
L104:
	clrb	-1(r10)
	tstl	r11
	jgeq	L108
	clrl	r11
L108:
	pushl	$0
	pushl	r11
	pushl	r10
	pushl	$0
	pushal	-132(fp)
	calls	$5,_logerr
	.stabs	"p",0x40,0,34,10
	.stabs	"len",0x40,0,4,11
	.stabs	"b",0x80,0,98,132
L101:
	ret
	.set	L.R3,0xc00
	.set	L.SO3,0x84
L110:	.data
	.text
	.align	2
	.globl	_logerr
_logerr:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"logerr",0x24,0,105,_logerr
	.stabs	"dev",0xa0,0,34,4
	.stabs	"unit",0xa0,0,4,8
	.stabs	"data",0xa0,0,34,12
	.stabs	"len",0xa0,0,4,16
	.stabs	"hard",0xa0,0,4,20
	calls	$0,_spl7
	movl	r0,r10
	cvtbl	_ewptr,r0
	addl3	$1,r0,r9
	cmpl	r9,_errcnt
	jlss	L112
	clrl	r9
L112:
	cvtbl	_erptr,r0
	cmpl	r9,r0
	jneq	L113
	pushl	r10
	calls	$1,_splx
	incl	_errlost
	jbr	L111
L113:
	cvtbl	_ewptr,r0
	ashl	$7,r0,r0
	addl3	$_errlog,r0,r11
	movb	r9,_ewptr
	pushl	r10
	calls	$1,_splx
	movb	$-89,(r11)
	movb	$101,1(r11)
	pushl	$112
	pushl	16(ap)
	calls	$2,_min
	movl	r0,16(ap)
	movb	16(ap),2(r11)
	tstl	20(ap)
	jeql	L114
	bisb2	$-128,2(r11)
L114:
	movb	8(ap),3(r11)
	movl	_time,4(r11)
	movl	4(ap),r8
	jbr	L116
L117:
L116:
	tstb	(r8)+
	jneq	L117
L115:
	pushl	$8
	subl3	4(ap),r8,-(sp)
	calls	$2,_min
	pushl	r0
	addl3	$8,r11,-(sp)
	pushl	4(ap)
	calls	$3,_bcopy
	tstl	16(ap)
	jeql	L119
	pushl	16(ap)
	addl3	$16,r11,-(sp)
	pushl	12(ap)
	calls	$3,_bcopy
L119:
	pushl	$_errlog
	calls	$1,_wakeup
	.stabs	"p",0x40,0,34,8
	.stabs	"i",0x40,0,4,9
	.stabs	"s",0x40,0,4,10
	.stabs	"ep",0x40,0,40,11
L111:
	ret
	.set	L.R4,0xf00
	.set	L.SO4,0x0
L121:	.data
	.stabs	"ewptr",0x28,0,2,_ewptr
	.stabs	"erptr",0x28,0,2,_erptr
	.stabs	"errlost",0x28,0,4,_errlost
	.text
L122:	.stabs	"errlog.c",0x94,0,137,L122
