L11:	.stabs	"sw.c",0x64,0,0,L11
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
	.comm	_rootdir,4
	.comm	_rswbuf,44
	.align	2
	.globl	_swbdev
_swbdev:
	.long	_swopen
	.long	_nulldev
	.long	_swstrategy
	.long	0
	.align	2
	.globl	_swcdev
_swcdev:
	.long	_swopen
	.long	_nulldev
	.long	_swread
	.long	_swwrite
	.long	_nodev
	.long	_nulldev
	.long	0
	.text
	.align	2
	.globl	_swopen
_swopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"swopen",0x24,0,31,_swopen
	.stabs	"dev",0xa0,0,13,4
	.stabs	"flag",0xa0,0,4,8
	.lcomm	L101,4
	tstl	L101
	jeql	L102
	jbr	L100
L102:
	incl	L101
	pushl	$0
	calls	$1,_swfree
	.stabs	"opened",0x28,0,4,L101
L100:
	ret
	.set	L.R1,0x0
	.set	L.SO1,0x0
L104:	.data
	.text
	.align	2
	.globl	_swstrategy
_swstrategy:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"swstrategy",0x24,0,42,_swstrategy
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	addl3	$511,20(r11),r0
	extzv	$9,$23,r0,r10
	divl3	_dmmax,32(r11),r0
	mull2	_dmmax,r0
	subl3	r0,32(r11),r0
	movl	r0,r9
	divl3	_dmmax,32(r11),r8
	divl3	_nswdevt,r8,r0
	mull2	_nswdevt,r0
	subl3	r0,r8,r0
	mull2	$12,r0
	movw	_swdevt(r0),-2(fp)
	movzwl	-2(fp),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	tstl	_bdevsw[r0]
	jneq	L106
	.data	1
L108:

	.byte	0x73,0x77,0x73,0x74,0x72,0x61,0x74,0x65
	.byte	0x67,0x79,0x0
	.text
	pushl	$L108
	calls	$1,_panic
L106:
	divl3	_nswdevt,r8,32(r11)
	mull2	_dmmax,32(r11)
	addl2	r9,32(r11)
	movw	-2(fp),26(r11)
	addl3	r10,32(r11),r0
	divl3	_nswdevt,r8,r1
	mull2	_nswdevt,r1
	subl3	r1,r8,r1
	mull2	$12,r1
	cmpl	r0,_swdevt+4(r1)
	jgtr	L110
	addl3	r10,r9,r0
	cmpl	r0,_dmmax
	jleq	L109
L110:
	bisl2	$4,(r11)
	pushl	r11
	calls	$1,_iodone
	jbr	L105
L109:
	pushl	r11
	movzwl	-2(fp),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	calls	$1,*8(r0)
	.stabs	"dev",0x80,0,13,2
	.stabs	"seg",0x40,0,4,8
	.stabs	"off",0x40,0,4,9
	.stabs	"sz",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L105:
	ret
	.set	L.R2,0xf00
	.set	L.SO2,0x4
L112:	.data
	.text
	.align	2
	.globl	_swread
_swread:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"swread",0x24,0,68,_swread
	.stabs	"dev",0xa0,0,4,4
	pushl	$_minphys
	pushl	$1
	pushl	4(ap)
	pushl	$_rswbuf
	pushl	$_swstrategy
	calls	$5,_physio
L113:
	ret
	.set	L.R3,0x0
	.set	L.SO3,0x0
L115:	.data
	.text
	.align	2
	.globl	_swwrite
_swwrite:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"swwrite",0x24,0,74,_swwrite
	.stabs	"dev",0xa0,0,4,4
	pushl	$_minphys
	pushl	$0
	pushl	4(ap)
	pushl	$_rswbuf
	pushl	$_swstrategy
	calls	$5,_physio
L116:
	ret
	.set	L.R4,0x0
	.set	L.SO4,0x0
L117:	.data
	.text
	.align	2
	.globl	_vswapon
_vswapon:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"vswapon",0x24,0,90,_vswapon
	pushl	$1
	pushl	$_nilargnamei
	pushl	$0
	pushl	*_u+276
	calls	$4,_namei
	movl	r0,r11
	tstl	r11
	jneq	L120
	jbr	L119
L120:
	movzwl	12(r11),r0
	bicl2	$-61441,r0
	cmpl	r0,$24576
	jneq	L122
	tstb	4(r11)
	jeql	L121
L122:
	movb	$22,_u+197
	pushl	r11
	calls	$1,_iput
	jbr	L119
L121:
	movw	36(r11),-2(fp)
	pushl	r11
	calls	$1,_iput
	clrl	r10
	jbr	L126
L127:
	mull3	$12,r10,r0
	cmpw	_swdevt(r0),-2(fp)
	jeql	L128
	jbr	L124
L128:
	mull3	$12,r10,r0
	tstl	_swdevt+8(r0)
	jeql	L129
	movb	$16,_u+197
	jbr	L119
L129:
	pushl	r10
	calls	$1,_swfree
	jbr	L119
L124:
	incl	r10
L126:
	cmpl	r10,_nswdevt
	jlss	L127
L125:
	movb	$19,_u+197
	.stabs	"i",0x40,0,4,10
	.stabs	"dev",0x80,0,13,2
	.stabs	"ip",0x40,0,40,11
L119:
	ret
	.set	L.R5,0xc00
	.set	L.SO5,0x4
L130:	.data
	.text
	.align	2
	.globl	_swfree
_swfree:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"swfree",0x24,0,133,_swfree
	.stabs	"index",0xa0,0,4,4
	movl	4(ap),r11
	mull3	$12,r11,r0
	movzwl	_swdevt(r0),-(sp)
	calls	$1,_bdevopen
	tstb	_u+197
	jeql	L133
	jbr	L131
L133:
	mull3	$12,r11,r0
	mull3	_nswdevt,_swdevt+4(r0),r8
	mull3	_dmmax,r11,r0
	addl2	r0,r8
	subl3	$1,_nswdevt,r0
	mull3	$12,r11,r1
	divl3	_dmmax,_swdevt+4(r1),r2
	mull2	_dmmax,r2
	subl3	r2,_swdevt+4(r1),r2
	mull2	r2,r0
	subl2	r0,r8
	mull3	r11,_dmmax,r10
	jbr	L136
L137:
	subl3	r10,r8,r9
	cmpl	r9,_dmmax
	jleq	L138
	movl	_dmmax,r9
L138:
	tstl	r10
	jeql	L139
	pushl	r10
	pushl	r9
	pushl	$_swapmap
	calls	$3,_rmfree
	jbr	L141
L139:
	movw	_swdevt,_argdev
	pushl	$2
	divl3	$2,r9,r0
	subl3	$2,r0,-(sp)
	pushl	_argcnt
	pushl	$_argmap
	calls	$4,_rminit
	divl3	$2,r9,-(sp)
	divl3	$2,r9,-(sp)
	pushl	_swmapcnt
	pushl	$_swapmap
	calls	$4,_rminit
L141:
	mull3	_nswdevt,_dmmax,r0
	addl2	r0,r10
L136:
	cmpl	r10,r8
	jlss	L137
L135:
	mull3	$12,r11,r0
	movl	$1,_swdevt+8(r0)
	.stabs	"xsize",0x40,0,4,8
	.stabs	"nblk",0x40,0,4,9
	.stabs	"bno",0x40,0,4,10
	.stabs	"index",0x40,0,4,11
L131:
	ret
	.set	L.R6,0xf00
	.set	L.SO6,0x0
L143:	.data
	.text
L144:	.stabs	"sw.c",0x94,0,159,L144
