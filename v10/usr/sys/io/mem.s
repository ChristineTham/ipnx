L11:	.stabs	"mem.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553091
	.data
	.comm	_zvms,40
	.comm	_buf,4
	.comm	_buffers,4
	.comm	_nbuf,4
	.comm	_swsize,4
	.comm	_swpf,4
	.comm	_bfreelist,132
	.comm	_bswlist,44
	.comm	_bclnlist,4
	.comm	_nswdevt,4
	.comm	_klseql,4
	.comm	_klsdist,4
	.comm	_klin,4
	.comm	_kltxt,4
	.comm	_klout,4
	.comm	_cnt,116
	.comm	_rate,116
	.comm	_sum,116
	.comm	_total,56
	.comm	_dmon,516
	.comm	_smon,516
	.comm	_pmon,264
	.comm	_rmon,264
	.comm	_pmonmin,4
	.comm	_pres,4
	.comm	_rmonmin,4
	.comm	_rres,4
	.comm	_rectime,4
	.comm	_pgintime,4
	.comm	_freemem,4
	.comm	_avefree,4
	.comm	_avefree30,4
	.comm	_deficit,4
	.comm	_nscan,4
	.comm	_desscan,4
	.comm	_kmapwnt,4
	.comm	_maxpgio,4
	.comm	_maxslp,4
	.comm	_lotsfree,4
	.comm	_minfree,4
	.comm	_desfree,4
	.comm	_saferss,4
	.comm	_swptstat,16
	.align	2
	.globl	_mmcdev
_mmcdev:
	.long	_nulldev
	.long	_nulldev
	.long	_mmread
	.long	_mmwrite
	.long	_nodev
	.long	_nulldev
	.long	0
	.comm	_vmmap,4
	.comm	_mmap,4
	.text
	.align	2
	.globl	_mmread
_mmread:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"mmread",0x24,0,26,_mmread
	.stabs	"dev",0xa0,0,4,4
	bicl3	$-256,4(ap),r0
	jbr	L119
L120:
	jbr	L122
L123:
	pushl	_u+288
	calls	$1,_fubyte
	cmpl	r0,$-1
	jneq	L125
	jbr	L126
L125:
	extzv	$9,$23,_u+296,r9
	bisl3	$-1744830464,r9,*_mmap
	pushl	_vmmap
	pushl	$58
	calls	$2,_mtpr
	bicl3	$-512,_u+296,r11
	pushl	_u+292
	subl3	r11,$512,-(sp)
	calls	$2,_min
	movl	r0,r10
	bicl3	$-512,_u+288,r0
	subl3	r0,$512,-(sp)
	pushl	r10
	calls	$2,_min
	movl	r0,r10
	pushl	r10
	pushl	_u+288
	addl3	_vmmap,r11,-(sp)
	calls	$3,_copyout
	tstl	r0
	jeql	L130
	jbr	L126
L130:
	subl2	r10,_u+292
	addl2	r10,_u+288
	pushl	r10
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
L122:
	tstl	_u+292
	jeql	L131
	tstb	_u+197
	jeql	L123
L131:
L121:
	jbr	L117
L132:
	pushl	$1
	pushl	_u+292
	pushl	_u+296
	calls	$3,_iomove
	jbr	L117
L134:
	jbr	L117
L135:
	pushl	$0
	pushl	_u+292
	pushl	_u+288
	calls	$3,_useracc
	tstl	r0
	jneq	L137
	jbr	L126
L137:
	pushl	$1
	pushl	_u+292
	pushl	_u+288
	pushl	_u+296
	calls	$4,_UNIcpy
	tstl	r0
	jeql	L139
	jbr	L126
L139:
	movl	_u+292,r10
	clrl	_u+292
	addl2	r10,_u+288
	pushl	r10
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	jbr	L117
L140:
	pushl	$4
	pushl	_u+292
	calls	$2,_min
	movl	r0,r10
	pushl	$4
	pushl	_u+296
	calls	$2,udiv
	pushl	r0
	calls	$1,_umfpr
	movl	r0,-4(fp)
	pushl	r10
	pushl	_u+288
	pushal	-4(fp)
	calls	$3,_copyout
	tstl	r0
	jeql	L142
	jbr	L126
L142:
	subl2	r10,_u+292
	addl2	r10,_u+288
	pushl	r10
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	jbr	L117
L119:
	casel	r0,$0,$5
L143:
	.word	L120-L143
	.word	L132-L143
	.word	L134-L143
	.word	L135-L143
	.word	L144-L143
	.word	L140-L143
L144:
L118:
L126:
	movb	$14,_u+197
	jbr	L117
	.stabs	"v",0x40,0,14,9
	.stabs	"c",0x40,0,14,10
	.stabs	"lbuf",0x80,0,4,4
	.stabs	"o",0x40,0,4,11
L117:
	ret
	.set	L.R1,0xe00
	.set	L.SO1,0x4
L145:	.data
	.text
	.align	2
	.globl	_mmwrite
_mmwrite:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"mmwrite",0x24,0,84,_mmwrite
	.stabs	"dev",0xa0,0,4,4
	bicl3	$-256,4(ap),r0
	jbr	L148
L149:
	jbr	L151
L152:
	pushl	_u+288
	calls	$1,_fubyte
	cmpl	r0,$-1
	jneq	L153
	jbr	L154
L153:
	extzv	$9,$23,_u+296,r9
	bisl3	$-1879048192,r9,*_mmap
	pushl	_vmmap
	pushl	$58
	calls	$2,_mtpr
	bicl3	$-512,_u+296,r11
	pushl	_u+292
	subl3	r11,$512,-(sp)
	calls	$2,_min
	movl	r0,r10
	bicl3	$-512,_u+288,r0
	subl3	r0,$512,-(sp)
	pushl	r10
	calls	$2,_min
	movl	r0,r10
	pushl	r10
	addl3	_vmmap,r11,-(sp)
	pushl	_u+288
	calls	$3,_copyin
	tstl	r0
	jeql	L156
	jbr	L154
L156:
	subl2	r10,_u+292
	addl2	r10,_u+288
	pushl	r10
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
L151:
	tstl	_u+292
	jeql	L157
	tstb	_u+197
	jeql	L152
L157:
L150:
	jbr	L146
L158:
	pushl	$0
	pushl	_u+292
	pushl	_u+296
	calls	$3,_iomove
	jbr	L146
L159:
	pushl	_u+292
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	clrl	_u+292
	jbr	L146
L160:
	pushl	$1
	pushl	_u+292
	pushl	_u+288
	calls	$3,_useracc
	tstl	r0
	jneq	L161
	jbr	L154
L161:
	pushl	$0
	pushl	_u+292
	pushl	_u+288
	pushl	_u+296
	calls	$4,_UNIcpy
	tstl	r0
	jeql	L162
	jbr	L154
L162:
	addl2	_u+292,_u+288
	pushl	_u+292
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	clrl	_u+292
	jbr	L146
L163:
	cmpl	_u+292,$4
	jgequ	L164
	jbr	L154
L164:
	pushl	$4
	pushal	-4(fp)
	pushl	_u+288
	calls	$3,_copyin
	tstl	r0
	jeql	L165
	jbr	L154
L165:
	pushl	-4(fp)
	pushl	$4
	pushl	_u+296
	calls	$2,udiv
	pushl	r0
	calls	$2,_umtpr
	tstl	r0
	jneq	L167
	jbr	L154
L167:
	subl2	$4,_u+292
	addl2	$4,_u+288
	pushl	$4
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	jbr	L146
L148:
	casel	r0,$0,$5
L168:
	.word	L149-L168
	.word	L158-L168
	.word	L159-L168
	.word	L160-L168
	.word	L169-L168
	.word	L163-L168
L169:
L147:
L154:
	movb	$14,_u+197
	jbr	L146
	.stabs	"v",0x40,0,14,9
	.stabs	"c",0x40,0,14,10
	.stabs	"lbuf",0x80,0,4,4
	.stabs	"o",0x40,0,4,11
L146:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x4
L170:	.data
	.text
L171:	.stabs	"mem.c",0x94,0,143,L171
