L11:	.stabs	"ra.c",0x64,0,0,L11
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
	.comm	_zvms,40
	.comm	_nswdevt,4
	.lcomm	_rarefno,4
	.lcomm	_rctbuf,44
	.align	2
	.globl	_rabdev
_rabdev:
	.long	_raopen
	.long	_raclose
	.long	_rastrategy
	.long	0
	.align	2
	.globl	_racdev
_racdev:
	.long	_raopen
	.long	_raclose
	.long	_raread
	.long	_rawrite
	.long	_raioctl
	.long	_nulldev
	.long	0
	.data
	.align	2
_ra_sizes:
	.long	10240
	.long	0
	.long	20480
	.long	10240
	.long	249848
	.long	30720
	.long	249848
	.long	280568
	.long	249848
	.long	530416
	.long	2147483647
	.long	780264
	.long	749544
	.long	30720
	.long	2147483647
	.long	0
	.text
	.align	2
	.globl	_raopen
_raopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"raopen",0x24,0,96,_raopen
	.stabs	"dev",0xa0,0,13,4
	.stabs	"flag",0xa0,0,4,8
	movzwl	4(ap),r0
	extzv	$3,$29,r0,r0
	bicl3	$-24,r0,r11
	cmpl	r11,_racnt
	jlss	L85
	movb	$6,_u+197
	jbr	L84
L85:
	mull3	$108,r11,r0
	addl3	$_radisk,r0,r10
	addl3	r11,r11,r0
	addl2	r0,r0
	addl3	$_raaddr,r0,r9
	tstb	4(r10)
	jneq	L86
	tstb	1(r9)
	jlss	L88
	cvtbl	1(r9),r0
	cmpl	r0,_nmsport
	jgeq	L88
L89:
	cvtbl	1(r9),r0
	movl	_msportsw[r0],(r10)
	jneq	L87
L88:
	movb	$6,_u+197
	jbr	L84
L87:
	movl	$2147483647,88(r10)
	pushl	$_radg
	pushl	$_raseql
	pushl	$0
	pushl	$0
	cvtbl	1(r9),-(sp)
	cvtbl	(r9),-(sp)
	movl	*(r10),r0
	calls	$6,(r0)
	tstl	r0
	jneq	L90
	movb	$6,_u+197
	jbr	L84
L90:
	pushl	r9
	pushl	r10
	calls	$2,_racinit
L86:
	movzwl	4(ap),r0
	bicl3	$-8,r0,r8
	ashl	r8,$1,r0
	bitb	r0,5(r10)
	jneq	L91
	addl3	$24,r10,r0
	addl3	r8,r8,r1
	addl2	r1,r1
	addl2	r1,r0
	addl3	r8,r8,r1
	addl2	r1,r1
	addl2	r1,r1
	movl	_ra_sizes(r1),(r0)
	addl3	$56,r10,r0
	addl3	r8,r8,r1
	addl2	r1,r1
	addl2	r1,r0
	addl3	r8,r8,r1
	addl2	r1,r1
	addl2	r1,r1
	movl	_ra_sizes+4(r1),(r0)
	ashl	r8,$1,r0
	movb	r0,r0
	bisb2	r0,5(r10)
L91:
	ashl	r8,$1,r0
	movb	r0,r0
	bisb2	r0,4(r10)
	calls	$0,_spl6
	bitb	$1,6(r10)
	jneq	L93
	pushl	r9
	pushl	r10
	calls	$2,_raonline
L93:
	calls	$0,_spl0
	bitb	$1,6(r10)
	jneq	L95
	movb	$6,_u+197
L95:
	.stabs	"part",0x40,0,4,8
	.stabs	"rp",0x40,0,40,9
	.stabs	"ra",0x40,0,40,10
	.stabs	"unit",0x40,0,4,11
L84:
	ret
	.set	L.R1,0xf00
	.set	L.SO1,0x0
L96:	.data
	.text
	.align	2
	.globl	_raclose
_raclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"raclose",0x24,0,138,_raclose
	.stabs	"dev",0xa0,0,4,4
	extzv	$3,$29,4(ap),r0
	bicl2	$-24,r0
	mull2	$108,r0
	addl3	$_radisk,r0,r11
	extzv	$3,$29,4(ap),r0
	bicl2	$-24,r0
	addl2	r0,r0
	addl2	r0,r0
	addl3	$_raaddr,r0,r10
	bicl3	$-8,4(ap),r0
	ashl	r0,$1,r0
	movb	r0,r0
	mcomb	r0,r0
	mcomb	r0,r1
	bicb2	r1,4(r11)
	tstb	4(r11)
	jneq	L99
	bitb	$1,6(r11)
	jneq	L98
L99:
	jbr	L97
L98:
	cvtbl	(r10),-(sp)
	movl	(r11),r0
	calls	$1,*4(r0)
	movl	r0,r9
	addl2	$1,_rarefno
	movl	_rarefno,(r9)
	movw	2(r10),4(r9)
	movb	$8,8(r9)
	bitb	$64,6(r11)
	jneq	L100
	clrw	10(r9)
	jbr	L101
L100:
	movw	$1,10(r9)
	bicb2	$64,6(r11)
L101:
	clrw	14(r9)
	clrl	28(r9)
	bicb2	$1,6(r11)
	pushl	r9
	pushl	$0
	cvtbl	(r10),-(sp)
	movl	(r11),r0
	calls	$3,*12(r0)
	.stabs	"mp",0x40,0,40,9
	.stabs	"rp",0x40,0,40,10
	.stabs	"ra",0x40,0,40,11
L97:
	ret
	.set	L.R2,0xe00
	.set	L.SO2,0x0
L102:	.data
	.text
	.align	2
	.globl	_raread
_raread:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"raread",0x24,0,167,_raread
	.stabs	"dev",0xa0,0,4,4
	pushl	$_minphys
	pushl	$1
	pushl	4(ap)
	extzv	$3,$29,4(ap),r0
	bicl2	$-24,r0
	mull2	$44,r0
	addl3	$_rabuf,r0,-(sp)
	pushl	$_rastrategy
	calls	$5,_physio
L103:
	ret
	.set	L.R3,0x0
	.set	L.SO3,0x0
L105:	.data
	.text
	.align	2
	.globl	_rawrite
_rawrite:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"rawrite",0x24,0,172,_rawrite
	.stabs	"dev",0xa0,0,4,4
	pushl	$_minphys
	pushl	$0
	pushl	4(ap)
	extzv	$3,$29,4(ap),r0
	bicl2	$-24,r0
	mull2	$44,r0
	addl3	$_rabuf,r0,-(sp)
	pushl	$_rastrategy
	calls	$5,_physio
L106:
	ret
	.set	L.R4,0x0
	.set	L.SO4,0x0
L107:	.data
	.text
	.align	2
	.globl	_rastrategy
_rastrategy:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"rastrategy",0x24,0,184,_rastrategy
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	movzwl	26(r11),r0
	bicl2	$-256,r0
	extzv	$3,$29,r0,r0
	bicl3	$-24,r0,r8
	movzwl	26(r11),r0
	bicl2	$-256,r0
	bicl3	$-8,r0,r7
	mull3	$108,r8,r0
	addl3	$_radisk,r0,r10
	addl3	r8,r8,r0
	addl2	r0,r0
	addl3	$_raaddr,r0,r6
	addl3	$56,r10,r0
	addl3	r7,r7,r1
	addl2	r1,r1
	addl2	r1,r0
	subl3	(r0),88(r10),-8(fp)
	addl3	$24,r10,r0
	addl3	r7,r7,r1
	addl2	r1,r1
	addl2	r1,r0
	cmpl	-8(fp),(r0)
	jleq	L109
	addl3	$24,r10,r0
	addl3	r7,r7,r1
	addl2	r1,r1
	addl2	r1,r0
	movl	(r0),-8(fp)
L109:
	cmpl	32(r11),-8(fp)
	jlss	L110
	cmpl	r11,$_rctbuf
	jeql	L110
L111:
	addl3	$24,r10,r0
	addl3	r7,r7,r1
	addl2	r1,r1
	addl2	r1,r0
	cmpl	32(r11),(r0)
	jneq	L112
	movl	20(r11),36(r11)
	jbr	L113
L112:
	movw	$28,24(r11)
	bisl2	$4,(r11)
L113:
	pushl	r11
	calls	$1,_iodone
	jbr	L108
L110:
	movl	20(r11),-4(fp)
	divl3	$512,-4(fp),r0
	addl2	32(r11),r0
	cmpl	r0,-8(fp)
	jleq	L115
	cmpl	r11,$_rctbuf
	jeql	L115
L116:
	subl3	32(r11),-8(fp),r0
	ashl	$9,r0,-4(fp)
L115:
	calls	$0,_spl6
	bitb	$1,6(r10)
	jneq	L117
	pushl	r6
	pushl	r10
	calls	$2,_raonline
	tstl	r0
	jneq	L117
L118:
	bisl2	$4,(r11)
	pushl	r11
	calls	$1,_iodone
	calls	$0,_spl0
	jbr	L108
L117:
	cvtbl	(r6),-(sp)
	movl	(r10),r0
	calls	$1,*4(r0)
	movl	r0,r9
	addl2	$1,_rarefno
	movl	_rarefno,(r9)
	movw	2(r6),4(r9)
	bitl	$1,(r11)
	jeql	L119
	movl	$33,r0
	jbr	L120
L119:
	movl	$34,r0
L120:
	movb	r0,8(r9)
	clrw	10(r9)
	movl	-4(fp),12(r9)
	addl3	$56,r10,r0
	addl3	r7,r7,r1
	addl2	r1,r1
	addl2	r1,r0
	addl3	(r0),32(r11),28(r9)
	pushl	r11
	pushl	r9
	cvtbl	(r6),-(sp)
	movl	(r10),r0
	calls	$3,*8(r0)
	movl	r9,16(r11)
	movl	(r9),36(r11)
	clrl	12(r11)
	tstl	16(r10)
	jeql	L121
	movl	20(r10),r0
	movl	r11,12(r0)
	jbr	L122
L121:
	movl	r11,16(r10)
L122:
	movl	r11,20(r10)
	pushl	r9
	pushl	$0
	cvtbl	(r6),-(sp)
	movl	(r10),r0
	calls	$3,*12(r0)
	calls	$0,_spl0
	.stabs	"limit",0x80,0,4,8
	.stabs	"count",0x80,0,4,4
	.stabs	"rp",0x40,0,40,6
	.stabs	"part",0x40,0,4,7
	.stabs	"unit",0x40,0,4,8
	.stabs	"mp",0x40,0,40,9
	.stabs	"ra",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L108:
	ret
	.set	L.R5,0xfc0
	.set	L.SO5,0x8
L123:	.data
	.text
	.align	2
	.globl	_raioctl
_raioctl:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"raioctl",0x24,0,248,_raioctl
	.stabs	"dev",0xa0,0,13,4
	.stabs	"cmd",0xa0,0,4,8
	.stabs	"addr",0xa0,0,34,12
	.stabs	"flag",0xa0,0,4,16
	movzwl	4(ap),r0
	extzv	$3,$29,r0,r0
	bicl2	$-24,r0
	mull2	$108,r0
	addl3	$_radisk,r0,r10
	cvtbl	6(r10),r0
	bicl2	$-6,r0
	cmpl	r0,$5
	jeql	L125
	movb	$5,_u+197
	jbr	L124
L125:
	movl	12(ap),r11
	movl	8(ap),r0
	jbr	L127
L128:
	movb	$25,_u+197
	jbr	L124
L129:
	bitl	$2,16(ap)
	jneq	L130
	movb	$9,_u+197
	jbr	L124
L130:
	pushl	$8
	pushal	-8(fp)
	pushl	12(ap)
	calls	$3,_copyin
	tstl	r0
	jgeq	L132
	movb	$14,_u+197
	jbr	L124
L132:
	addl3	$56,r10,r0
	movzwl	4(ap),r1
	bicl2	$-8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	movl	-8(fp),(r0)
	addl3	$24,r10,r0
	movzwl	4(ap),r1
	bicl2	$-8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	movl	-4(fp),(r0)
	jbr	L124
L133:
	addl3	$56,r10,r0
	movzwl	4(ap),r1
	bicl2	$-8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	movl	(r0),-8(fp)
	addl3	$24,r10,r0
	movzwl	4(ap),r1
	bicl2	$-8,r1
	addl2	r1,r1
	addl2	r1,r1
	addl2	r1,r0
	movl	(r0),-4(fp)
	pushl	$8
	pushl	12(ap)
	pushal	-8(fp)
	calls	$3,_copyout
	tstl	r0
	jgeq	L135
	movb	$14,_u+197
L135:
	jbr	L124
L136:
	pushl	$20
	pushl	12(ap)
	addl3	$88,r10,-(sp)
	calls	$3,_copyout
	tstl	r0
	jeql	L137
	movb	$14,_u+197
L137:
	jbr	L124
L138:
	tstl	4(r11)
	jlss	L140
	cmpl	4(r11),92(r10)
	jleq	L139
L140:
	movb	$5,_u+197
	jbr	L124
L139:
	clrl	r9
	jbr	L143
L144:
	movl	$512,_u+292
	addl3	88(r10),4(r11),r0
	ashl	$9,r0,-(sp)
	calls	$1,_ltoL
	movq	(r0),_u+296
	mull3	92(r10),r9,r0
	ashl	$9,r0,-(sp)
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	movl	(r11),_u+288
	clrb	_u+196
	clrb	_u+197
	pushl	$_minphys
	pushl	$1
	movzwl	4(ap),-(sp)
	pushl	$_rctbuf
	pushl	$_rastrategy
	calls	$5,_physio
	tstb	_u+197
	jneq	L145
	jbr	L142
L145:
	incl	r9
L143:
	cvtbl	107(r10),r0
	cmpl	r9,r0
	jlss	L144
L142:
	jbr	L124
L146:
	bitl	$2,16(ap)
	jneq	L147
	movb	$9,_u+197
	jbr	L124
L147:
	tstl	4(r11)
	jlss	L149
	cmpl	4(r11),92(r10)
	jleq	L148
L149:
	movb	$5,_u+197
	jbr	L124
L148:
	clrl	r9
	jbr	L152
L153:
	movl	$512,_u+292
	addl3	88(r10),4(r11),r0
	ashl	$9,r0,-(sp)
	calls	$1,_ltoL
	movq	(r0),_u+296
	mull3	92(r10),r9,r0
	ashl	$9,r0,-(sp)
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	movl	(r11),_u+288
	clrb	_u+196
	pushl	$_minphys
	pushl	$0
	movzwl	4(ap),-(sp)
	pushl	$_rctbuf
	pushl	$_rastrategy
	calls	$5,_physio
	clrb	_u+197
	incl	r9
L152:
	cvtbl	107(r10),r0
	cmpl	r9,r0
	jlss	L153
L151:
	jbr	L124
L154:
	bitl	$2,16(ap)
	jneq	L155
	movb	$9,_u+197
	jbr	L124
L155:
	cvtwl	8(r11),-(sp)
	pushl	(r11)
	pushl	4(r11)
	movzwl	4(ap),-(sp)
	calls	$4,_rareplace
	jbr	L124
L156:
	bisb2	$64,6(r10)
	jbr	L124
L157:
	pushl	$_radg
	pushl	$_raseql
	pushl	$0
	pushl	$1
	movzwl	4(ap),r0
	extzv	$3,$29,r0,r0
	bicl2	$-24,r0
	addl2	r0,r0
	addl2	r0,r0
	cvtbl	_raaddr+1(r0),-(sp)
	movzwl	4(ap),r0
	extzv	$3,$29,r0,r0
	bicl2	$-24,r0
	addl2	r0,r0
	addl2	r0,r0
	cvtbl	_raaddr(r0),-(sp)
	movl	*(r10),r0
	calls	$6,(r0)
	jbr	L124
L127:
	cmpl	r0,$17408
	jeql	L129
	cmpl	r0,$17409
	jeql	L133
	cmpl	r0,$29952
	jeql	L138
	cmpl	r0,$29953
	jeql	L146
	cmpl	r0,$29954
	jeql	L136
	cmpl	r0,$29955
	jeql	L154
	cmpl	r0,$29956
	jeql	L156
	cmpl	r0,$29957
	jeql	L157
	jbr	L128
L126:
	.stabs	"parts",0x80,0,100,8
	.stabs	"i",0x40,0,4,9
	.stabs	"ra",0x40,0,40,10
	.stabs	"uap",0x40,0,41,11
L124:
	ret
	.set	L.R6,0xe00
	.set	L.SO6,0x8
L158:	.data
	.text
	.align	2
_rareplace:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"rareplace",0x24,0,364,_rareplace
	.stabs	"rareplace",0x32,0,68,0
	.stabs	"dev",0xa0,0,4,4
	.stabs	"badlbn",0xa0,0,4,8
	.stabs	"replbn",0xa0,0,4,12
	.stabs	"prim",0xa0,0,4,16
	bicl3	$-256,4(ap),r0
	extzv	$3,$29,r0,r0
	bicl3	$-24,r0,r8
	mull3	$108,r8,r0
	addl3	$_radisk,r0,r10
	addl3	r8,r8,r0
	addl2	r0,r0
	addl3	$_raaddr,r0,r9
	calls	$0,_spl6
	jbr	L161
L162:
	bisb2	$16,6(r10)
	pushl	$26
	addl3	$6,r10,-(sp)
	calls	$2,_sleep
L161:
	bitb	$8,6(r10)
	jneq	L162
L160:
	bisb2	$8,6(r10)
	.data	1
L165:

	.byte	0x72,0x61,0x25,0x64,0x20,0x72,0x65,0x70
	.byte	0x6c,0x61,0x63,0x65,0x20,0x25,0x44,0x20
	.byte	0x77,0x69,0x74,0x68,0x20,0x25,0x44,0xa
	.byte	0x0
	.text
	pushl	12(ap)
	pushl	8(ap)
	pushl	r8
	pushl	$L165
	calls	$4,_printf
	cvtbl	(r9),-(sp)
	movl	(r10),r0
	calls	$1,*4(r0)
	movl	r0,r11
	pushl	$36
	pushl	r11
	calls	$2,_bzero
	addl2	$1,_rarefno
	movl	_rarefno,(r11)
	movw	2(r9),4(r11)
	movb	$20,8(r11)
	movl	12(ap),12(r11)
	movl	8(ap),28(r11)
	tstl	16(ap)
	jeql	L167
	movl	$1,r0
	jbr	L168
L167:
	clrl	r0
L168:
	movw	r0,10(r11)
	movl	(r11),8(r10)
	movb	$20,12(r10)
	pushl	r11
	pushl	$0
	cvtbl	(r9),-(sp)
	movl	(r10),r0
	calls	$3,*12(r0)
	jbr	L170
L171:
	pushl	$25
	addl3	$7,r10,-(sp)
	calls	$2,_sleep
L170:
	bitb	$32,6(r10)
	jeql	L171
L169:
	movb	7(r10),_u+197
	bitb	$16,6(r10)
	jeql	L172
	addl3	$6,r10,-(sp)
	calls	$1,_wakeup
L172:
	bicb2	$56,6(r10)
	calls	$0,_spl0
	.stabs	"unit",0x40,0,4,8
	.stabs	"rp",0x40,0,40,9
	.stabs	"ra",0x40,0,40,10
	.stabs	"mp",0x40,0,40,11
L159:
	ret
	.set	L.R7,0xf00
	.set	L.SO7,0x0
L174:	.data
	.text
	.align	2
	.globl	_raseql
_raseql:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"raseql",0x24,0,407,_raseql
	.stabs	"ctl",0xa0,0,4,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"ep",0xa0,0,40,12
	movl	12(ap),r11
	tstb	8(r11)
	jneq	L176
	cmpw	10(r11),$255
	jneq	L176
L177:
	pushl	4(ap)
	calls	$1,_rareset
	jbr	L175
L176:
	clrl	r8
	jbr	L181
L182:
	addl3	r8,r8,r0
	addl2	r0,r0
	cvtbl	_raaddr(r0),r0
	cmpl	r0,4(ap)
	jneq	L183
	addl3	r8,r8,r0
	addl2	r0,r0
	cvtbl	_raaddr+1(r0),r0
	cmpl	r0,8(ap)
	jneq	L183
L185:
	addl3	r8,r8,r0
	addl2	r0,r0
	cmpw	_raaddr+2(r0),4(r11)
	jneq	L183
L184:
	jbr	L180
L183:
	incl	r8
L181:
	cmpl	r8,_racnt
	jlss	L182
L180:
	cmpl	r8,_racnt
	jlss	L186
	.data	1
L187:

	.byte	0x72,0x61,0x25,0x64,0x20,0x63,0x74,0x6c
	.byte	0x25,0x64,0x20,0x74,0x79,0x70,0x25,0x64
	.byte	0x3a,0x20,0x73,0x74,0x72,0x61,0x79,0x20
	.byte	0x6d,0x73,0x63,0x70,0x20,0x70,0x61,0x63
	.byte	0x6b,0x65,0x74,0x20,0x73,0x74,0x73,0x20
	.byte	0x78,0x25,0x78,0x20,0x6f,0x70,0x63,0x6f
	.byte	0x64,0x65,0x20,0x25,0x6f,0xa,0x0
	.text
	cvtbl	8(r11),-(sp)
	cvtwl	10(r11),-(sp)
	pushl	8(ap)
	pushl	4(ap)
	cvtwl	4(r11),-(sp)
	pushl	$L187
	calls	$6,_printf
	jbr	L175
L186:
	mull3	$108,r8,r0
	addl3	$_radisk,r0,r9
	cvtwl	10(r11),r0
	bicl3	$-32,r0,-4(fp)
	cmpl	-4(fp),$4
	jeql	L189
	cmpl	-4(fp),$3
	jneq	L188
L189:
	bicb2	$1,6(r9)
L188:
L190:
	cvtbl	8(r11),r0
	bicl2	$-256,r0
	jbr	L192
L193:
	cmpl	(r11),8(r9)
	jneq	L194
	bisb3	$-128,12(r9),8(r11)
	jbr	L190
L194:
L195:
L196:
	movl	16(r9),r10
	clrl	r7
	jbr	L199
L200:
	cmpl	(r11),36(r10)
	jneq	L201
	jbr	L198
L201:
	movl	r10,r7
	movl	12(r10),r10
L199:
	tstl	r10
	jneq	L200
L198:
	tstl	r10
	jneq	L202
	.data	1
L203:

	.byte	0x72,0x61,0x25,0x64,0x20,0x73,0x74,0x72
	.byte	0x61,0x79,0x20,0x65,0x6e,0x64,0x3a,0x20
	.byte	0x63,0x72,0x66,0x20,0x25,0x64,0x20,0x73
	.byte	0x74,0x73,0x20,0x78,0x25,0x78,0x20,0x6f
	.byte	0x70,0x63,0x6f,0x64,0x65,0x20,0x30,0x25
	.byte	0x6f,0xa,0x0
	.text
	cvtbl	8(r11),r0
	bicl3	$-256,r0,-(sp)
	cvtwl	10(r11),-(sp)
	pushl	(r11)
	pushl	r8
	pushl	$L203
	calls	$5,_printf
	jbr	L175
L202:
	cmpl	*16(r10),(r11)
	jeql	L204
	.data	1
L205:

	.byte	0x72,0x61,0x25,0x64,0x20,0x73,0x65,0x6e
	.byte	0x74,0x20,0x25,0x64,0x20,0x67,0x6f,0x74
	.byte	0x20,0x25,0x64,0x20,0x63,0x72,0x66,0x3b
	.byte	0x20,0x66,0x6c,0x67,0x20,0x25,0x78,0x20
	.byte	0x64,0x65,0x76,0x20,0x25,0x78,0xa,0x0
	.text
	movzwl	26(r10),-(sp)
	pushl	(r10)
	pushl	(r11)
	pushl	*16(r10)
	pushl	r8
	pushl	$L205
	calls	$6,_printf
L204:
	tstl	r7
	jeql	L206
	movl	12(r10),12(r7)
	jbr	L207
L206:
	movl	12(r10),16(r9)
L207:
	cmpl	r10,20(r9)
	jneq	L208
	movl	r7,20(r9)
L208:
	subl3	12(r11),20(r10),36(r10)
	tstl	-4(fp)
	jeql	L209
	bisl2	$4,(r10)
	cmpw	10(r11),$8
	jeql	L211
	cmpw	10(r11),$72
	jneq	L210
L211:
	movw	$6,24(r10)
	jbr	L212
L210:
	.data	1
L213:

	.byte	0x65,0x72,0x72,0x20,0x6f,0x6e,0x20,0x72
	.byte	0x61,0x25,0x64,0x20,0x62,0x6c,0x6f,0x63
	.byte	0x6b,0x20,0x25,0x44,0x3a,0x20,0x73,0x74
	.byte	0x73,0x20,0x78,0x25,0x78,0xa,0x0
	.text
	cvtwl	10(r11),-(sp)
	pushl	32(r10)
	pushl	r8
	pushl	$L213
	calls	$4,_printf
L212:
L209:
	pushl	16(r10)
	pushl	4(ap)
	movl	(r9),r0
	calls	$2,*16(r0)
	pushl	r10
	calls	$1,_iodone
	jbr	L175
L214:
	pushl	r11
	pushl	r9
	calls	$2,_rasonl
	jbr	L175
L215:
	bicb2	$1,6(r9)
	jbr	L175
L216:
	tstl	-4(fp)
	jeql	L217
	.data	1
L218:

	.byte	0x72,0x61,0x25,0x64,0x3a,0x20,0x63,0x61
	.byte	0x6e,0x27,0x74,0x20,0x67,0x65,0x74,0x20
	.byte	0x75,0x6e,0x69,0x74,0x20,0x73,0x74,0x73
	.byte	0x20,0x78,0x25,0x78,0xa,0x0
	.text
	cvtwl	10(r11),-(sp)
	pushl	r8
	pushl	$L218
	calls	$3,_printf
	jbr	L175
L217:
	movl	28(r11),96(r9)
	movw	36(r11),100(r9)
	movw	38(r11),102(r9)
	movw	40(r11),104(r9)
	cvtwl	44(r11),92(r9)
	movb	46(r11),106(r9)
	movb	47(r11),107(r9)
	bisb2	$4,6(r9)
	jbr	L175
L219:
	tstl	-4(fp)
	jeql	L220
	.data	1
L221:

	.byte	0x72,0x61,0x20,0x63,0x74,0x6c,0x25,0x64
	.byte	0x20,0x74,0x79,0x70,0x25,0x64,0x3a,0x20
	.byte	0x62,0x61,0x64,0x20,0x69,0x6e,0x69,0x74
	.byte	0xa,0x0
	.text
	pushl	8(ap)
	pushl	4(ap)
	pushl	$L221
	calls	$3,_printf
L220:
	jbr	L175
L222:
	clrb	7(r9)
	tstl	-4(fp)
	jeql	L223
	.data	1
L224:

	.byte	0x72,0x61,0x25,0x64,0x3a,0x20,0x72,0x70
	.byte	0x6c,0x20,0x73,0x74,0x73,0x20,0x78,0x25
	.byte	0x78,0xa,0x0
	.text
	cvtwl	10(r11),-(sp)
	pushl	r8
	pushl	$L224
	calls	$3,_printf
	movb	$5,7(r9)
L223:
	bisb2	$32,6(r9)
	addl3	$7,r9,-(sp)
	calls	$1,_wakeup
	jbr	L175
L225:
	.data	1
L226:

	.byte	0x72,0x61,0x25,0x64,0x20,0x63,0x74,0x6c
	.byte	0x25,0x64,0x20,0x74,0x79,0x70,0x25,0x64
	.byte	0x3a,0x20,0x73,0x74,0x72,0x61,0x79,0x20
	.byte	0x6d,0x73,0x63,0x70,0x20,0x6d,0x73,0x67
	.byte	0x20,0x6f,0x70,0x63,0x64,0x20,0x30,0x25
	.byte	0x6f,0x20,0x73,0x74,0x73,0x20,0x78,0x25
	.byte	0x78,0xa,0x0
	.text
	cvtwl	10(r11),-(sp)
	cvtbl	8(r11),r0
	bicl3	$-256,r0,-(sp)
	pushl	8(ap)
	pushl	4(ap)
	cvtwl	4(r11),-(sp)
	pushl	$L226
	calls	$6,_printf
	jbr	L175
L192:
	casel	r0,$128,$34
L227:
	.word	L193-L227
	.word	L225-L227
	.word	L225-L227
	.word	L216-L227
	.word	L219-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L215-L227
	.word	L214-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L222-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L225-L227
	.word	L195-L227
	.word	L196-L227
	jbr	L225
L191:
	.stabs	"sts",0x80,0,4,4
	.stabs	"obp",0x40,0,40,7
	.stabs	"unit",0x40,0,4,8
	.stabs	"ra",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"ep",0x40,0,40,11
L175:
	ret
	.set	L.R8,0xf80
	.set	L.SO8,0x4
L228:	.data
	.text
	.align	2
	.globl	_rareset
_rareset:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"rareset",0x24,0,526,_rareset
	.stabs	"ctl",0xa0,0,4,4
	clrl	r11
	jbr	L232
L233:
	addl3	r11,r11,r0
	addl2	r0,r0
	cvtbl	_raaddr(r0),r0
	cmpl	r0,4(ap)
	jeql	L234
	jbr	L230
L234:
	mull3	$108,r11,r0
	addl3	$_radisk,r0,r10
	movl	16(r10),r9
	jbr	L237
L238:
	movl	12(r9),r8
	pushl	16(r9)
	pushl	4(ap)
	movl	(r10),r0
	calls	$2,*16(r0)
	bisl2	$4,(r9)
	pushl	r9
	calls	$1,_iodone
	movl	r8,r9
L237:
	tstl	r9
	jneq	L238
L236:
	clrl	r0
	movl	r0,20(r10)
	movl	r0,16(r10)
	bicb2	$3,6(r10)
	pushl	r10
	calls	$1,_wakeup
L230:
	incl	r11
L232:
	cmpl	r11,_racnt
	jlss	L233
L231:
	.stabs	"nbp",0x40,0,40,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"ra",0x40,0,40,10
	.stabs	"unit",0x40,0,4,11
L229:
	ret
	.set	L.R9,0xf00
	.set	L.SO9,0x0
L239:	.data
	.data
	.align	2
_raevents:
	.data	2
L241:

	.byte	0x6f,0x6b,0x0
	.data
	.long	L241
	.data	2
L242:

	.byte	0x69,0x6e,0x76,0x20,0x63,0x6d,0x64,0x0
	.data
	.long	L242
	.data	2
L243:

	.byte	0x6f,0x70,0x20,0x61,0x62,0x6f,0x72,0x74
	.byte	0x65,0x64,0x0
	.data
	.long	L243
	.data	2
L244:

	.byte	0x6f,0x66,0x66,0x6c,0x69,0x6e,0x65,0x0
	.data
	.long	L244
	.data	2
L245:

	.byte	0x61,0x76,0x61,0x69,0x6c,0x61,0x62,0x6c
	.byte	0x65,0x0
	.data
	.long	L245
	.data	2
L246:

	.byte	0x6d,0x65,0x64,0x20,0x66,0x6d,0x74,0x0
	.data
	.long	L246
	.data	2
L247:

	.byte	0x77,0x72,0x69,0x74,0x65,0x20,0x70,0x72
	.byte	0x6f,0x74,0x0
	.data
	.long	L247
	.data	2
L248:

	.byte	0x63,0x6f,0x6d,0x70,0x20,0x65,0x72,0x72
	.byte	0x0
	.data
	.long	L248
	.data	2
L249:

	.byte	0x64,0x61,0x74,0x61,0x20,0x65,0x72,0x72
	.byte	0x0
	.data
	.long	L249
	.data	2
L250:

	.byte	0x68,0x6f,0x73,0x74,0x20,0x62,0x75,0x66
	.byte	0x20,0x61,0x63,0x63,0x65,0x73,0x73,0x20
	.byte	0x65,0x72,0x72,0x0
	.data
	.long	L250
	.data	2
L251:

	.byte	0x63,0x6e,0x74,0x6c,0x20,0x65,0x72,0x72
	.byte	0x0
	.data
	.long	L251
	.data	2
L252:

	.byte	0x64,0x72,0x69,0x76,0x65,0x20,0x65,0x72
	.byte	0x72,0x0
	.data
	.long	L252
	.text
	.align	2
	.globl	_radg
_radg:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"radg",0x24,0,575,_radg
	.stabs	"ctl",0xa0,0,4,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"ep",0xa0,0,40,12
	movl	12(ap),r11
	cmpb	8(r11),$2
	jneq	L254
	cmpw	10(r11),$8
	jneq	L254
L256:
	tstb	9(r11)
	jneq	L254
L255:
	jbr	L253
L254:
	.data	1
L257:

	.byte	0x72,0x61,0x25,0x64,0x20,0x63,0x74,0x6c
	.byte	0x25,0x64,0x20,0x74,0x79,0x70,0x25,0x64
	.byte	0x20,0x73,0x65,0x71,0x20,0x25,0x64,0x3a
	.byte	0x20,0x25,0x73,0x20,0x65,0x72,0x72,0x3b
	.byte	0x20,0x66,0x6d,0x74,0x20,0x78,0x25,0x78
	.byte	0x20,0x65,0x76,0x20,0x78,0x25,0x78,0x20
	.byte	0x66,0x6c,0x20,0x78,0x25,0x78,0xa,0x0
	.text
	.data	1
L258:

	.byte	0x73,0x6f,0x66,0x74,0x0
	.text
	.data	1
L259:

	.byte	0x68,0x61,0x72,0x64,0x0
	.text
	cvtbl	9(r11),r0
	bicl3	$-256,r0,-(sp)
	cvtwl	10(r11),-(sp)
	cvtbl	8(r11),-(sp)
	bitb	$192,9(r11)
	jeql	L260
	movl	$L258,-(sp)
	jbr	L261
L260:
	movl	$L259,-(sp)
L261:
	cvtwl	6(r11),-(sp)
	pushl	8(ap)
	pushl	4(ap)
	cvtwl	4(r11),-(sp)
	pushl	$L257
	calls	$9,_printf
	cvtwl	10(r11),r0
	bicl2	$-32,r0
	cmpl	r0,$11
	jgtr	L262
	.data	1
L263:

	.byte	0x25,0x73,0x3b,0x20,0x0
	.text
	cvtwl	10(r11),r0
	bicl2	$-32,r0
	pushl	_raevents[r0]
	pushl	$L263
	calls	$2,_printf
L262:
	cvtbl	8(r11),r0
	jbr	L265
L266:
	.data	1
L267:

	.byte	0x6f,0x6f,0x70,0x73,0xa,0x0
	.text
	pushl	$L267
	calls	$1,_printf
	jbr	L264
L268:
	.data	1
L269:

	.byte	0x68,0x6f,0x73,0x74,0x20,0x6d,0x65,0x6d
	.byte	0x20,0x61,0x63,0x63,0x65,0x73,0x73,0x3b
	.byte	0x20,0x61,0x64,0x64,0x72,0x20,0x78,0x25
	.byte	0x78,0xa,0x0
	.text
	pushl	24(r11)
	pushl	$L269
	calls	$2,_printf
	jbr	L264
L270:
	.data	1
L271:

	.byte	0x25,0x73,0x62,0x6e,0x20,0x25,0x64,0x3b
	.byte	0x20,0x6c,0x65,0x76,0x20,0x78,0x25,0x78
	.byte	0x2c,0x20,0x72,0x65,0x74,0x72,0x79,0x20
	.byte	0x78,0x25,0x78,0xa,0x0
	.text
	.data	1
L272:

	.byte	0x6c,0x0
	.text
	.data	1
L273:

	.byte	0x72,0x0
	.text
	cvtbl	35(r11),-(sp)
	cvtbl	34(r11),-(sp)
	bicl3	$-268435456,40(r11),-(sp)
	bitl	$-268435456,40(r11)
	jneq	L274
	movl	$L272,-(sp)
	jbr	L275
L274:
	movl	$L273,-(sp)
L275:
	pushl	$L271
	calls	$5,_printf
	jbr	L264
L276:
	.data	1
L277:

	.byte	0x25,0x73,0x62,0x6e,0x20,0x25,0x64,0x3b
	.byte	0x0
	.text
	.data	1
L278:

	.byte	0x6c,0x0
	.text
	.data	1
L279:

	.byte	0x72,0x0
	.text
	bicl3	$-268435456,40(r11),-(sp)
	bitl	$-268435456,40(r11)
	jneq	L280
	movl	$L278,-(sp)
	jbr	L281
L280:
	movl	$L279,-(sp)
L281:
	pushl	$L277
	calls	$3,_printf
	addl3	$56,r11,r10
	jbr	L283
L284:
	.data	1
L285:

	.byte	0x20,0x25,0x78,0x0
	.text
	subl2	$2,r10
	movzwl	(r10),-(sp)
	pushl	$L285
	calls	$2,_printf
L283:
	addl3	$44,r11,r0
	cmpl	r10,r0
	jgtru	L284
L282:
	.data	1
L286:

	.byte	0x20,0x78,0x78,0xa,0x0
	.text
	pushl	$L286
	calls	$1,_printf
	jbr	L264
L287:
	.data	1
L288:

	.byte	0x63,0x79,0x6c,0x20,0x25,0x64,0xa,0x0
	.text
	pushl	48(r11)
	pushl	$L288
	calls	$2,_printf
	jbr	L264
L289:
	.data	1
L290:

	.byte	0x73,0x63,0x73,0x69,0x3a,0x0
	.text
	pushl	$L290
	calls	$1,_printf
	addl3	$44,r11,r8
	clrl	r9
	jbr	L293
L294:
	.data	1
L295:

	.byte	0x20,0x25,0x78,0x0
	.text
	movzbl	(r8)+,-(sp)
	pushl	$L295
	calls	$2,_printf
	incl	r9
L293:
	cmpl	r9,$10
	jlss	L294
L292:
	.data	1
L296:

	.byte	0x20,0x5b,0x25,0x78,0x20,0x25,0x78,0x5d
	.byte	0xa,0x0
	.text
	movzbl	1(r8),-(sp)
	movzbl	(r8),-(sp)
	pushl	$L296
	calls	$3,_printf
	jbr	L264
L297:
	.data	1
L298:

	.byte	0xa,0x0
	.text
	pushl	$L298
	calls	$1,_printf
	jbr	L264
L265:
	cmpl	r0,$0
	jeql	L266
	cmpl	r0,$1
	jeql	L268
	cmpl	r0,$2
	jeql	L270
	cmpl	r0,$3
	jeql	L276
	cmpl	r0,$4
	jeql	L287
	cmpl	r0,$64
	jeql	L289
	jbr	L297
L264:
	.stabs	"cp",0x40,0,44,8
	.stabs	"i",0x40,0,4,9
	.stabs	"sp",0x40,0,45,10
	.stabs	"ep",0x40,0,40,11
L253:
	ret
	.set	L.R10,0xf00
	.set	L.SO10,0x0
L299:	.data
	.text
	.align	2
_raonline:
	.word	L.R11
	subl2	$L.SO11,sp
	.stabs	"raonline",0x24,0,645,_raonline
	.stabs	"raonline",0x32,0,68,0
	.stabs	"ra",0xa0,0,40,4
	.stabs	"rp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	calls	$0,_spl6
	movl	r0,-4(fp)
	bitb	$2,6(r11)
	jneq	L301
	bicb2	$4,6(r11)
	cvtbl	(r10),-(sp)
	movl	(r11),r0
	calls	$1,*4(r0)
	movl	r0,r9
	pushl	$36
	pushl	r9
	calls	$2,_bzero
	addl2	$1,_rarefno
	movl	_rarefno,(r9)
	movw	2(r10),4(r9)
	movb	$9,8(r9)
	movl	(r9),8(r11)
	movb	$9,12(r11)
	pushl	r9
	pushl	$0
	cvtbl	(r10),-(sp)
	movl	(r11),r0
	calls	$3,*12(r0)
	bisb2	$2,6(r11)
L301:
	jbr	L303
L304:
	pushl	$60
	pushl	$24
	pushl	r11
	calls	$3,_tsleep
L303:
	bitb	$2,6(r11)
	jneq	L304
L302:
	bitb	$1,6(r11)
	jneq	L306
	clrl	r0
	jbr	L300
L306:
	bitb	$4,6(r11)
	jneq	L307
	cvtbl	(r10),-(sp)
	movl	(r11),r0
	calls	$1,*4(r0)
	movl	r0,r9
	addl2	$1,_rarefno
	movl	_rarefno,(r9)
	movw	2(r10),4(r9)
	movb	$3,8(r9)
	clrw	10(r9)
	clrw	14(r9)
	clrl	28(r9)
	pushl	r9
	pushl	$0
	cvtbl	(r10),-(sp)
	movl	(r11),r0
	calls	$3,*12(r0)
L307:
	pushl	-4(fp)
	calls	$1,_splx
	movl	$1,r0
	jbr	L300
	.stabs	"s",0x80,0,4,4
	.stabs	"mp",0x40,0,40,9
	.stabs	"rp",0x40,0,40,10
	.stabs	"ra",0x40,0,40,11
L300:
	ret
	.set	L.R11,0xe00
	.set	L.SO11,0x4
L309:	.data
	.text
	.align	2
_rasonl:
	.word	L.R12
	subl2	$L.SO12,sp
	.stabs	"rasonl",0x24,0,684,_rasonl
	.stabs	"rasonl",0x32,0,68,0
	.stabs	"ra",0xa0,0,40,4
	.stabs	"ep",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	bitb	$2,6(r11)
	jeql	L311
	bicb2	$2,6(r11)
	pushl	r11
	calls	$1,_wakeup
L311:
	bitw	$31,10(r10)
	jeql	L312
	jbr	L310
L312:
	bisb2	$1,6(r11)
	cmpl	88(r11),$2147483647
	jeql	L313
	cmpl	88(r11),36(r10)
	jeql	L313
L314:
	.data	1
L315:

	.byte	0x72,0x61,0x25,0x64,0x3a,0x20,0x63,0x68
	.byte	0x61,0x6e,0x67,0x65,0x64,0x20,0x73,0x69
	.byte	0x7a,0x65,0x20,0x25,0x64,0x20,0x74,0x6f
	.byte	0x20,0x25,0x64,0xa,0x0
	.text
	pushl	36(r10)
	pushl	88(r11)
	subl3	$_radisk,r11,r0
	divl3	$108,r0,-(sp)
	pushl	$L315
	calls	$4,_printf
L313:
	movl	36(r10),88(r11)
	.stabs	"ep",0x40,0,40,10
	.stabs	"ra",0x40,0,40,11
L310:
	ret
	.set	L.R12,0xc00
	.set	L.SO12,0x0
L316:	.data
	.text
	.align	2
_racinit:
	.word	L.R13
	subl2	$L.SO13,sp
	.stabs	"racinit",0x24,0,707,_racinit
	.stabs	"racinit",0x32,0,68,0
	.stabs	"ra",0xa0,0,40,4
	.stabs	"rp",0xa0,0,40,8
	cvtbl	*8(ap),-(sp)
	movl	*4(ap),r0
	calls	$1,*4(r0)
	movl	r0,r11
	addl2	$1,_rarefno
	movl	_rarefno,(r11)
	movl	8(ap),r0
	movw	2(r0),4(r11)
	movb	$4,8(r11)
	clrw	10(r11)
	movw	$80,14(r11)
	clrw	12(r11)
	clrw	16(r11)
	clrl	r0
	movl	r0,24(r11)
	movl	r0,20(r11)
	calls	$0,_spl6
	movl	r0,r10
	pushl	r11
	pushl	$0
	cvtbl	*8(ap),-(sp)
	movl	*4(ap),r0
	calls	$3,*12(r0)
	pushl	r10
	calls	$1,_splx
	.stabs	"s",0x40,0,4,10
	.stabs	"mp",0x40,0,40,11
L317:
	ret
	.set	L.R13,0xc00
	.set	L.SO13,0x0
L318:	.data
	.stabs	"raevents",0x26,0,226,_raevents
	.stabs	"ra_sizes",0x26,0,104,_ra_sizes
	.stabs	"rctbuf",0x28,0,8,_rctbuf
	.stabs	"rarefno",0x28,0,4,_rarefno
	.text
L319:	.stabs	"ra.c",0x94,0,724,L319
