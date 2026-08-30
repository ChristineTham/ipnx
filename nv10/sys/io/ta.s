L11:	.stabs	"ta.c",0x64,0,0,L11
	.stabs	"vaxpcc2",0xf0,0,17665,1787553294
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
	.lcomm	_tarefno,4
	.align	2
	.globl	_tabdev
_tabdev:
	.long	_taopen
	.long	_taclose
	.long	_tastrategy
	.long	1024
	.align	2
	.globl	_tacdev
_tacdev:
	.long	_taopen
	.long	_taclose
	.long	_taread
	.long	_tawrite
	.long	_taioctl
	.long	_nulldev
	.long	0
	.text
	.align	2
	.globl	_taopen
_taopen:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"taopen",0x24,0,83,_taopen
	.stabs	"dev",0xa0,0,13,4
	.stabs	"flag",0xa0,0,4,8
	movzwl	4(ap),r0
	bicl3	$-8,r0,r11
	cmpl	r11,_tacnt
	jleq	L83
	movb	$6,_u+197
	jbr	L82
L83:
	mull3	$20,r11,r0
	addl3	$_tatape,r0,r10
	addl3	r11,r11,r0
	addl2	r0,r0
	addl3	$_taaddr,r0,r9
	bitw	$4,(r10)
	jeql	L84
	movb	$16,_u+197
	jbr	L82
L84:
	tstb	1(r9)
	jlss	L86
	cvtbl	1(r9),r0
	cmpl	r0,_nmsport
	jgeq	L86
L87:
	cvtbl	1(r9),r0
	movl	_msportsw[r0],4(r10)
	jneq	L85
L86:
	movb	$6,_u+197
	jbr	L82
L85:
	bisw2	$4,(r10)
	bicw2	$536,(r10)
	pushl	$_tadg
	pushl	$_taseql
	pushl	$1
	pushl	$0
	cvtbl	1(r9),-(sp)
	cvtbl	(r9),-(sp)
	movl	*4(r10),r0
	calls	$6,(r0)
	tstl	r0
	jneq	L88
	movb	$6,_u+197
	bicw2	$4,(r10)
	jbr	L82
L88:
	pushl	r9
	pushl	r10
	calls	$2,_tacinit
	calls	$0,_spl6
	bitw	$1,(r10)
	jneq	L90
	movl	$1,r0
	jbr	L91
L90:
	clrl	r0
L91:
	movl	r0,-4(fp)
	bitw	$1,(r10)
	jneq	L92
	pushl	r9
	pushl	r10
	calls	$2,_taonline
L92:
	calls	$0,_spl0
	bitw	$1,(r10)
	jneq	L94
	movb	$6,_u+197
	bicw2	$4,(r10)
	jbr	L82
L94:
	bitw	$16,(r10)
	jeql	L95
	bitl	$2,8(ap)
	jeql	L95
L96:
	movb	$19,_u+197
	bitw	$128,4(ap)
	jneq	L97
	pushl	$0
	pushl	$0
	pushl	$8
	pushl	$1
	pushl	r11
	calls	$5,_tacmd
L97:
	bicw2	$5,(r10)
	jbr	L82
L95:
	movzwl	4(ap),r0
	bicl2	$-57,r0
	extzv	$3,$29,r0,r0
	ashl	r0,$1,r0
	movw	r0,2(r10)
	pushl	$0
	pushl	$0
	pushl	$3
	pushl	$0
	pushl	r11
	calls	$5,_tacmd
	tstl	r0
	jneq	L99
	tstl	-4(fp)
	jeql	L100
	cvtwl	2(r10),-(sp)
	jbr	L101
L100:
	clrl	-(sp)
L101:
	bitw	$64,4(ap)
	jeql	L102
	clrl	-(sp)
	jbr	L103
L102:
	movl	$64,-(sp)
L103:
	pushl	$10
	pushl	$0
	pushl	r11
	calls	$5,_tacmd
	tstl	r0
	jeql	L98
L99:
	movb	$6,_u+197
	bitw	$128,4(ap)
	jneq	L104
	pushl	$0
	pushl	$0
	pushl	$8
	pushl	$1
	pushl	r11
	calls	$5,_tacmd
L104:
	bicw2	$5,(r10)
	jbr	L82
L98:
	bicl3	$-4,8(ap),r0
	cmpl	r0,$2
	jneq	L105
	bisw2	$512,(r10)
L105:
	.stabs	"wasoff",0x80,0,4,4
	.stabs	"rp",0x40,0,40,9
	.stabs	"ta",0x40,0,40,10
	.stabs	"unit",0x40,0,4,11
L82:
	ret
	.set	L.R1,0xe00
	.set	L.SO1,0x4
L106:	.data
	.text
	.align	2
	.globl	_taclose
_taclose:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"taclose",0x24,0,144,_taclose
	.stabs	"dev",0xa0,0,4,4
	bicl3	$-8,4(ap),-4(fp)
	mull3	$20,-4(fp),r0
	addl3	$_tatape,r0,r11
	bitw	$1,(r11)
	jeql	L108
	bitw	$520,(r11)
	jeql	L109
	pushl	$0
	pushl	$0
	pushl	$36
	pushl	$0
	pushl	-4(fp)
	calls	$5,_tacmd
	pushl	$0
	pushl	$0
	pushl	$36
	pushl	$0
	pushl	-4(fp)
	calls	$5,_tacmd
	pushl	$-1
	pushl	$0
	pushl	$37
	pushl	$0
	pushl	-4(fp)
	calls	$5,_tacmd
L109:
	bitl	$128,4(ap)
	jneq	L110
	pushl	$0
	pushl	$0
	pushl	$8
	pushl	$1
	pushl	-4(fp)
	calls	$5,_tacmd
L110:
L108:
	bicw2	$4,(r11)
	.stabs	"unit",0x80,0,4,4
	.stabs	"ta",0x40,0,40,11
L107:
	ret
	.set	L.R2,0x800
	.set	L.SO2,0x4
L111:	.data
	.text
	.align	2
_tacmd:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"tacmd",0x24,0,175,_tacmd
	.stabs	"tacmd",0x32,0,68,0
	.stabs	"dev",0xa0,0,4,4
	.stabs	"async",0xa0,0,4,8
	.stabs	"op",0xa0,0,4,12
	.stabs	"p0",0xa0,0,4,16
	.stabs	"p1",0xa0,0,4,20
	mull3	$20,4(ap),r0
	addl3	$_tatape,r0,r10
	addl3	4(ap),4(ap),r0
	addl2	r0,r0
	addl3	$_taaddr,r0,r9
	bitw	$1,(r10)
	jneq	L113
	movl	$1,r0
	jbr	L112
L113:
	cvtbl	(r9),-(sp)
	movl	4(r10),r0
	calls	$1,*4(r0)
	movl	r0,r11
	pushl	$36
	pushl	r11
	calls	$2,_bzero
	addl2	$1,_tarefno
	movl	_tarefno,(r11)
	movw	2(r9),4(r11)
	movb	12(ap),8(r11)
	movw	$8192,10(r11)
	movl	12(ap),r0
	jbr	L116
L117:
	tstl	20(ap)
	jgeq	L118
	mnegl	20(ap),20(ap)
	bisw2	$8,10(r11)
L118:
	cmpl	16(ap),$-1
	jneq	L119
	bisw2	$2,10(r11)
	bisw2	20(ap),10(r11)
	jbr	L120
L119:
	tstl	16(ap)
	jneq	L121
	movl	20(ap),16(r11)
	jbr	L122
L121:
	bisw2	$4,10(r11)
	movl	20(ap),12(r11)
L122:
L120:
	jbr	L115
L123:
	bisw2	16(ap),14(r11)
	movw	20(ap),32(r11)
	jbr	L115
L124:
	movw	16(ap),10(r11)
	jbr	L115
L125:
	bisw2	16(ap),10(r11)
	jbr	L115
L116:
	cmpl	r0,$3
	jeql	L124
	cmpl	r0,$10
	jeql	L123
	cmpl	r0,$37
	jeql	L117
	jbr	L125
L115:
	calls	$0,_spl6
	movl	r0,r8
	jbr	L127
L128:
	bisw2	$32,(r10)
	pushl	$25
	pushl	r10
	calls	$2,_sleep
L127:
	tstl	16(r10)
	jneq	L128
L126:
	movl	r11,16(r10)
	bicw2	$192,(r10)
	bitw	$256,(r10)
	jeql	L130
	bicw2	$256,(r10)
	bisw2	$4096,10(r11)
L130:
	pushl	r11
	pushl	$1
	cvtbl	(r9),-(sp)
	movl	4(r10),r0
	calls	$3,*12(r0)
	tstl	8(ap)
	jneq	L131
	jbr	L133
L134:
	pushl	$0
	pushl	$26
	pushl	r10
	calls	$3,_tsleep
	cmpl	r0,$2
	jneq	L136
	jbr	L132
L136:
L133:
	bitw	$64,(r10)
	jeql	L134
L132:
L131:
	bitw	$128,(r10)
	jeql	L137
	movl	$1,r0
	jbr	L138
L137:
	clrl	r0
L138:
	movl	r0,r7
	clrl	16(r10)
	bitw	$32,(r10)
	jeql	L139
	bicw2	$32,(r10)
	pushl	r10
	calls	$1,_wakeup
L139:
	pushl	r8
	calls	$1,_splx
	movl	r7,r0
	jbr	L112
	.stabs	"err",0x40,0,4,7
	.stabs	"s",0x40,0,4,8
	.stabs	"rp",0x40,0,40,9
	.stabs	"ta",0x40,0,40,10
	.stabs	"mp",0x40,0,40,11
L112:
	ret
	.set	L.R3,0xf80
	.set	L.SO3,0x0
L142:	.data
	.text
	.align	2
	.globl	_taread
_taread:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"taread",0x24,0,253,_taread
	.stabs	"dev",0xa0,0,4,4
	pushl	$_minphys
	pushl	$1
	pushl	4(ap)
	bicl3	$-8,4(ap),r0
	mull2	$44,r0
	addl3	$_tabuf,r0,-(sp)
	pushl	$_tastrategy
	calls	$5,_physio
L143:
	ret
	.set	L.R4,0x0
	.set	L.SO4,0x0
L145:	.data
	.text
	.align	2
	.globl	_tawrite
_tawrite:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"tawrite",0x24,0,258,_tawrite
	.stabs	"dev",0xa0,0,4,4
	pushl	$_minphys
	pushl	$0
	pushl	4(ap)
	bicl3	$-8,4(ap),r0
	mull2	$44,r0
	addl3	$_tabuf,r0,-(sp)
	pushl	$_tastrategy
	calls	$5,_physio
L146:
	ret
	.set	L.R5,0x0
	.set	L.SO5,0x0
L147:	.data
	.text
	.align	2
	.globl	_tastrategy
_tastrategy:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"tastrategy",0x24,0,269,_tastrategy
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	movzwl	26(r11),r0
	bicl2	$-256,r0
	bicl3	$-8,r0,r8
	mull3	$20,r8,r0
	addl3	$_tatape,r0,r10
	addl3	r8,r8,r0
	addl2	r0,r0
	addl3	$_taaddr,r0,r7
	movl	20(r11),-4(fp)
	calls	$0,_spl6
	bitw	$1,(r10)
	jneq	L149
	pushl	r7
	pushl	r10
	calls	$2,_taonline
	tstl	r0
	jneq	L149
L150:
	bisl2	$4,(r11)
	pushl	r11
	calls	$1,_iodone
	calls	$0,_spl0
	jbr	L148
L149:
	cvtbl	(r7),-(sp)
	movl	4(r10),r0
	calls	$1,*4(r0)
	movl	r0,r9
	addl2	$1,_tarefno
	movl	_tarefno,(r9)
	movw	2(r7),4(r9)
	bitl	$1,(r11)
	jeql	L152
	movl	$33,r0
	jbr	L153
L152:
	movl	$34,r0
L153:
	movb	r0,8(r9)
	movw	$8192,10(r9)
	bitw	$256,(r10)
	jeql	L154
	bitl	$1,(r11)
	jneq	L154
L155:
	bicw2	$256,(r10)
	bisw2	$4096,10(r9)
L154:
	clrw	14(r9)
	movl	-4(fp),12(r9)
	pushl	r11
	pushl	r9
	cvtbl	(r7),-(sp)
	movl	4(r10),r0
	calls	$3,*8(r0)
	movl	r9,16(r11)
	movl	(r9),36(r11)
	clrl	12(r11)
	tstl	8(r10)
	jeql	L156
	movl	12(r10),r0
	movl	r11,12(r0)
	jbr	L157
L156:
	movl	r11,8(r10)
L157:
	movl	r11,12(r10)
	bitl	$1,(r11)
	jneq	L158
	bisw2	$8,(r10)
L158:
	pushl	r9
	pushl	$1
	cvtbl	(r7),-(sp)
	movl	4(r10),r0
	calls	$3,*12(r0)
	calls	$0,_spl0
	.stabs	"count",0x80,0,4,4
	.stabs	"rp",0x40,0,40,7
	.stabs	"unit",0x40,0,4,8
	.stabs	"mp",0x40,0,40,9
	.stabs	"ta",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L148:
	ret
	.set	L.R6,0xf80
	.set	L.SO6,0x4
L159:	.data
	.text
	.align	2
	.globl	_taioctl
_taioctl:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"taioctl",0x24,0,322,_taioctl
	.stabs	"dev",0xa0,0,13,4
	.stabs	"cmd",0xa0,0,4,8
	.stabs	"addr",0xa0,0,34,12
	.stabs	"flag",0xa0,0,4,16
	movl	8(ap),r0
	jbr	L162
L163:
	movb	$25,_u+197
	jbr	L161
L164:
	pushl	$8
	pushal	-8(fp)
	pushl	12(ap)
	calls	$3,_copyin
	tstl	r0
	jgeq	L166
	movb	$14,_u+197
	jbr	L160
L166:
	tstw	-8(fp)
	jneq	L167
	bitl	$2,16(ap)
	jneq	L168
	movb	$9,_u+197
	jbr	L160
L168:
	jbr	L170
L171:
	pushl	$0
	pushl	$0
	pushl	$36
	pushl	$0
	movzwl	4(ap),r0
	bicl3	$-8,r0,-(sp)
	calls	$5,_tacmd
	tstl	r0
	jeql	L172
	movb	$5,_u+197
	jbr	L160
L172:
L170:
	movl	-4(fp),r0
	decl	-4(fp)
	tstl	r0
	jgtr	L171
L169:
	jbr	L160
L167:
	cmpw	-8(fp),$8
	jneq	L173
	pushl	$_tadg
	pushl	$_taseql
	pushl	$1
	pushl	$1
	movzwl	4(ap),r0
	bicl2	$-8,r0
	addl2	r0,r0
	addl2	r0,r0
	cvtbl	_taaddr+1(r0),-(sp)
	movzwl	4(ap),r0
	bicl2	$-8,r0
	addl2	r0,r0
	addl2	r0,r0
	cvtbl	_taaddr(r0),-(sp)
	movzwl	4(ap),r0
	bicl2	$-8,r0
	mull2	$20,r0
	movl	*_tatape+4(r0),r1
	calls	$6,(r1)
	jbr	L160
L173:
	movl	-4(fp),-20(fp)
	movl	$37,-12(fp)
	cvtwl	-8(fp),r0
	jbr	L175
L176:
	mnegl	-20(fp),-20(fp)
L177:
	clrl	-16(fp)
	jbr	L174
L178:
	mnegl	-20(fp),-20(fp)
L179:
	movl	$1,-16(fp)
	jbr	L174
L180:
	clrl	-20(fp)
	movl	$-1,-16(fp)
	jbr	L174
L181:
	movl	$8,-12(fp)
	clrl	-20(fp)
	movl	$16,-16(fp)
	jbr	L174
L182:
	jbr	L160
L175:
	casel	r0,$1,$6
L183:
	.word	L177-L183
	.word	L176-L183
	.word	L179-L183
	.word	L178-L183
	.word	L180-L183
	.word	L181-L183
	.word	L182-L183
L184:
L174:
	pushl	-20(fp)
	pushl	-16(fp)
	pushl	-12(fp)
	pushl	$0
	movzwl	4(ap),r0
	bicl3	$-8,r0,-(sp)
	calls	$5,_tacmd
	tstl	r0
	jeql	L185
	movb	$5,_u+197
L185:
	jbr	L161
L162:
	cmpl	r0,$27905
	jeql	L164
	jbr	L163
L161:
	.stabs	"p1",0x80,0,4,20
	.stabs	"p0",0x80,0,4,16
	.stabs	"func",0x80,0,4,12
	.stabs	"mt",0x80,0,8,8
L160:
	ret
	.set	L.R7,0x0
	.set	L.SO7,0x14
L186:	.data
	.text
	.align	2
	.globl	_taseql
_taseql:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"taseql",0x24,0,394,_taseql
	.stabs	"ctl",0xa0,0,4,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"ep",0xa0,0,40,12
	movl	12(ap),r11
	tstb	8(r11)
	jneq	L188
	cmpw	10(r11),$255
	jneq	L188
L189:
	pushl	8(ap)
	pushl	4(ap)
	calls	$2,_tareset
	jbr	L187
L188:
	clrl	r8
	jbr	L193
L194:
	addl3	r8,r8,r0
	addl2	r0,r0
	cvtbl	_taaddr(r0),r0
	cmpl	r0,4(ap)
	jneq	L195
	addl3	r8,r8,r0
	addl2	r0,r0
	cvtbl	_taaddr+1(r0),r0
	cmpl	r0,8(ap)
	jneq	L195
L197:
	addl3	r8,r8,r0
	addl2	r0,r0
	cmpw	_taaddr+2(r0),4(r11)
	jneq	L195
L196:
	jbr	L192
L195:
	incl	r8
L193:
	cmpl	r8,_tacnt
	jlss	L194
L192:
	cmpl	r8,_tacnt
	jlss	L198
	.data	1
L200:

	.byte	0x74,0x6d,0x73,0x63,0x70,0x20,0x73,0x74
	.byte	0x72,0x61,0x79,0x20,0x75,0x6e,0x69,0x74
	.byte	0x3a,0x20,0x63,0x74,0x6c,0x25,0x64,0x20
	.byte	0x74,0x79,0x70,0x25,0x64,0x20,0x74,0x61
	.byte	0x25,0x64,0x20,0x73,0x74,0x73,0x20,0x25
	.byte	0x6f,0x20,0x6f,0x70,0x63,0x6f,0x64,0x65
	.byte	0x20,0x25,0x6f,0xa,0x0
	.text
	cvtbl	8(r11),-(sp)
	cvtwl	10(r11),-(sp)
	cvtwl	4(r11),-(sp)
	pushl	8(ap)
	pushl	4(ap)
	pushl	$L200
	calls	$6,_printf
	jbr	L187
L198:
	mull3	$20,r8,r0
	addl3	$_tatape,r0,r9
	bitb	$2,9(r11)
	jeql	L201
	bisw2	$256,(r9)
L201:
	cvtbl	8(r11),r0
	bicl2	$-256,r0
	jbr	L203
L204:
	.data	1
L205:

	.byte	0x74,0x6d,0x73,0x63,0x70,0x20,0x63,0x74
	.byte	0x6c,0x25,0x64,0x20,0x74,0x61,0x25,0x64
	.byte	0x20,0x69,0x6c,0x6c,0x20,0x63,0x6d,0x64
	.byte	0x20,0x63,0x72,0x66,0x20,0x25,0x64,0x20
	.byte	0x6f,0x66,0x66,0x20,0x25,0x64,0xa,0x0
	.text
	cvtwl	10(r11),r0
	extzv	$8,$24,r0,-(sp)
	pushl	(r11)
	cvtwl	4(r11),-(sp)
	pushl	4(ap)
	pushl	$L205
	calls	$5,_printf
	tstl	16(r9)
	jeql	L206
	cmpl	*16(r9),(r11)
	jneq	L206
L207:
	jbr	L208
L206:
L209:
L210:
	movl	8(r9),r10
	clrl	r7
	jbr	L213
L214:
	cmpl	(r11),36(r10)
	jneq	L215
	jbr	L212
L215:
	movl	r10,r7
	movl	12(r10),r10
L213:
	tstl	r10
	jneq	L214
L212:
	tstl	r10
	jneq	L216
	.data	1
L217:

	.byte	0x74,0x61,0x25,0x64,0x20,0x73,0x74,0x72
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
	pushl	$L217
	calls	$5,_printf
	jbr	L187
L216:
	tstl	r7
	jeql	L218
	movl	12(r10),12(r7)
	jbr	L219
L218:
	movl	12(r10),8(r9)
L219:
	cmpl	r10,12(r9)
	jneq	L220
	movl	r7,12(r9)
L220:
	cvtwl	10(r11),r0
	bicl3	$-32,r0,-4(fp)
	cmpl	-4(fp),$4
	jeql	L222
	cmpl	-4(fp),$3
	jneq	L221
L222:
	bicw2	$1,(r9)
L221:
	subl3	12(r11),20(r10),36(r10)
	cmpl	-4(fp),$14
	jneq	L223
	clrl	-4(fp)
L223:
	tstl	-4(fp)
	jeql	L224
	bisl2	$4,(r10)
	movl	-4(fp),r0
	jbr	L226
L227:
L228:
L229:
L230:
	jbr	L225
L231:
	.data	1
L232:

	.byte	0x65,0x72,0x72,0x20,0x6f,0x6e,0x20,0x74
	.byte	0x61,0x25,0x64,0x20,0x62,0x6c,0x6f,0x63
	.byte	0x6b,0x20,0x25,0x44,0x3a,0x20,0x73,0x74
	.byte	0x73,0x20,0x30,0x25,0x6f,0x20,0x66,0x6c
	.byte	0x67,0x73,0x20,0x30,0x25,0x6f,0xa,0x0
	.text
	cvtbl	9(r11),-(sp)
	cvtwl	10(r11),-(sp)
	pushl	32(r10)
	pushl	r8
	pushl	$L232
	calls	$5,_printf
	jbr	L225
L226:
	casel	r0,$3,$13
L233:
	.word	L228-L233
	.word	L229-L233
	.word	L231-L233
	.word	L230-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L231-L233
	.word	L227-L233
	jbr	L231
L225:
L224:
	bitb	$8,9(r11)
	jeql	L234
	bitl	$1,(r10)
	jneq	L234
L235:
	movw	$28,24(r10)
	bisl2	$4,(r10)
L234:
	pushl	16(r10)
	pushl	4(ap)
	movl	4(r9),r0
	calls	$2,*16(r0)
	pushl	r10
	calls	$1,_iodone
	jbr	L187
L236:
	bicw2	$-256,2(r9)
	bicw3	$255,36(r11),r0
	bisw2	r0,2(r9)
	jbr	L208
L237:
	tstw	10(r11)
	jneq	L238
	bicw2	$1,(r9)
L238:
L239:
L240:
L241:
L242:
L208:
	cvtwl	10(r11),r0
	bicl2	$-32,r0
	cmpl	r0,$4
	jeql	L244
	cvtwl	10(r11),r0
	bicl2	$-32,r0
	cmpl	r0,$3
	jneq	L243
L244:
	bicw2	$1,(r9)
L243:
	tstl	16(r9)
	jeql	L245
	bisw2	$64,(r9)
	bitw	$31,10(r11)
	jeql	L246
	.data	1
L247:

	.byte	0x74,0x61,0x25,0x64,0x3a,0x20,0x63,0x6d
	.byte	0x64,0x20,0x30,0x25,0x6f,0x20,0x73,0x74
	.byte	0x73,0x20,0x30,0x25,0x6f,0x20,0x66,0x6c
	.byte	0x67,0x73,0x20,0x30,0x25,0x6f,0xa,0x0
	.text
	cvtbl	9(r11),-(sp)
	cvtwl	10(r11),-(sp)
	cvtbl	8(r11),r0
	bicl3	$-256,r0,-(sp)
	pushl	r8
	pushl	$L247
	calls	$5,_printf
	bisw2	$128,(r9)
L246:
	pushl	r9
	calls	$1,_wakeup
L245:
	jbr	L187
L248:
	pushl	r11
	pushl	r9
	calls	$2,_tasonl
	jbr	L187
L249:
	bitw	$31,10(r11)
	jeql	L250
	.data	1
L251:

	.byte	0x74,0x6d,0x73,0x63,0x70,0x20,0x63,0x74
	.byte	0x6c,0x25,0x64,0x20,0x74,0x79,0x70,0x25
	.byte	0x64,0x3a,0x20,0x62,0x61,0x64,0x20,0x69
	.byte	0x6e,0x69,0x74,0xa,0x0
	.text
	pushl	8(ap)
	pushl	4(ap)
	pushl	$L251
	calls	$3,_printf
L250:
	jbr	L187
L252:
	.data	1
L253:

	.byte	0x73,0x74,0x72,0x61,0x79,0x20,0x74,0x6d
	.byte	0x73,0x63,0x70,0x20,0x6d,0x73,0x67,0x20
	.byte	0x74,0x61,0x25,0x64,0x20,0x6f,0x70,0x63
	.byte	0x64,0x20,0x30,0x25,0x6f,0x20,0x73,0x74
	.byte	0x73,0x20,0x78,0x25,0x78,0xa,0x0
	.text
	cvtwl	10(r11),r0
	bicl3	$-65536,r0,-(sp)
	cvtbl	8(r11),r0
	bicl3	$-256,r0,-(sp)
	pushl	r8
	pushl	$L253
	calls	$4,_printf
	jbr	L187
L203:
	casel	r0,$128,$37
L254:
	.word	L204-L254
	.word	L252-L254
	.word	L252-L254
	.word	L236-L254
	.word	L249-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L237-L254
	.word	L248-L254
	.word	L242-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L241-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L252-L254
	.word	L209-L254
	.word	L210-L254
	.word	L252-L254
	.word	L239-L254
	.word	L240-L254
	jbr	L252
L202:
	.stabs	"sts",0x80,0,4,4
	.stabs	"obp",0x40,0,40,7
	.stabs	"unit",0x40,0,4,8
	.stabs	"ta",0x40,0,40,9
	.stabs	"bp",0x40,0,40,10
	.stabs	"ep",0x40,0,40,11
L187:
	ret
	.set	L.R8,0xf80
	.set	L.SO8,0x4
L255:	.data
	.text
	.align	2
	.globl	_tareset
_tareset:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"tareset",0x24,0,518,_tareset
	.stabs	"ctl",0xa0,0,4,4
	.stabs	"type",0xa0,0,4,8
	clrl	r11
	jbr	L259
L260:
	addl3	r11,r11,r0
	addl2	r0,r0
	cvtbl	_taaddr(r0),r0
	cmpl	r0,4(ap)
	jneq	L262
	addl3	r11,r11,r0
	addl2	r0,r0
	cvtbl	_taaddr+1(r0),r0
	cmpl	r0,8(ap)
	jeql	L261
L262:
	jbr	L257
L261:
	mull3	$20,r11,r0
	addl3	$_tatape,r0,r10
	movl	8(r10),r9
	jbr	L265
L266:
	movl	12(r9),r8
	pushl	16(r9)
	pushl	4(ap)
	movl	4(r10),r0
	calls	$2,*16(r0)
	bisl2	$4,(r9)
	pushl	r9
	calls	$1,_iodone
	movl	r8,r9
L265:
	tstl	r9
	jneq	L266
L264:
	clrl	r0
	movl	r0,12(r10)
	movl	r0,8(r10)
	bicw2	$3,(r10)
	tstl	16(r10)
	jeql	L267
	bisw2	$192,(r10)
L267:
	pushl	r10
	calls	$1,_wakeup
L257:
	incl	r11
L259:
	cmpl	r11,_tacnt
	jlss	L260
L258:
	.stabs	"nbp",0x40,0,40,8
	.stabs	"bp",0x40,0,40,9
	.stabs	"ta",0x40,0,40,10
	.stabs	"unit",0x40,0,4,11
L256:
	ret
	.set	L.R9,0xf00
	.set	L.SO9,0x0
L268:	.data
	.data
	.align	2
_taevents:
	.data	2
L270:

	.byte	0x6f,0x6b,0x0
	.data
	.long	L270
	.data	2
L271:

	.byte	0x69,0x6e,0x76,0x20,0x63,0x6d,0x64,0x0
	.data
	.long	L271
	.data	2
L272:

	.byte	0x6f,0x70,0x20,0x61,0x62,0x6f,0x72,0x74
	.byte	0x65,0x64,0x0
	.data
	.long	L272
	.data	2
L273:

	.byte	0x6f,0x66,0x66,0x6c,0x69,0x6e,0x65,0x0
	.data
	.long	L273
	.data	2
L274:

	.byte	0x61,0x76,0x61,0x69,0x6c,0x61,0x62,0x6c
	.byte	0x65,0x0
	.data
	.long	L274
	.data	2
L275:

	.byte	0x6d,0x65,0x64,0x20,0x66,0x6d,0x74,0x0
	.data
	.long	L275
	.data	2
L276:

	.byte	0x77,0x72,0x69,0x74,0x65,0x20,0x70,0x72
	.byte	0x6f,0x74,0x0
	.data
	.long	L276
	.data	2
L277:

	.byte	0x63,0x6f,0x6d,0x70,0x20,0x65,0x72,0x72
	.byte	0x0
	.data
	.long	L277
	.data	2
L278:

	.byte	0x64,0x61,0x74,0x61,0x20,0x65,0x72,0x72
	.byte	0x0
	.data
	.long	L278
	.data	2
L279:

	.byte	0x68,0x6f,0x73,0x74,0x20,0x62,0x75,0x66
	.byte	0x20,0x61,0x63,0x63,0x65,0x73,0x73,0x20
	.byte	0x65,0x72,0x72,0x0
	.data
	.long	L279
	.data	2
L280:

	.byte	0x63,0x6e,0x74,0x6c,0x20,0x65,0x72,0x72
	.byte	0x0
	.data
	.long	L280
	.data	2
L281:

	.byte	0x64,0x72,0x69,0x76,0x65,0x20,0x65,0x72
	.byte	0x72,0x0
	.data
	.long	L281
	.text
	.align	2
	.globl	_tadg
_tadg:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"tadg",0x24,0,565,_tadg
	.stabs	"ctl",0xa0,0,4,4
	.stabs	"type",0xa0,0,4,8
	.stabs	"ep",0xa0,0,40,12
	movl	12(ap),r11
	cmpw	10(r11),$18
	jneq	L283
	jbr	L282
L283:
	.data	1
L284:

	.byte	0x74,0x61,0x25,0x64,0x20,0x63,0x74,0x6c
	.byte	0x25,0x64,0x20,0x74,0x79,0x70,0x25,0x64
	.byte	0x20,0x73,0x65,0x71,0x20,0x25,0x64,0x3a
	.byte	0x20,0x25,0x73,0x20,0x65,0x72,0x72,0x3b
	.byte	0x20,0x66,0x6d,0x74,0x20,0x78,0x25,0x78
	.byte	0x20,0x65,0x76,0x20,0x78,0x25,0x78,0x20
	.byte	0x66,0x6c,0x20,0x78,0x25,0x78,0xa,0x0
	.text
	.data	1
L285:

	.byte	0x73,0x6f,0x66,0x74,0x0
	.text
	.data	1
L286:

	.byte	0x68,0x61,0x72,0x64,0x0
	.text
	cvtbl	9(r11),r0
	bicl3	$-256,r0,-(sp)
	cvtwl	10(r11),-(sp)
	cvtbl	8(r11),-(sp)
	bitb	$192,9(r11)
	jeql	L287
	movl	$L285,-(sp)
	jbr	L288
L287:
	movl	$L286,-(sp)
L288:
	cvtwl	6(r11),-(sp)
	pushl	8(ap)
	pushl	4(ap)
	cvtwl	4(r11),-(sp)
	pushl	$L284
	calls	$9,_printf
	cvtwl	10(r11),r0
	bicl2	$-32,r0
	cmpl	r0,$11
	jgtr	L289
	.data	1
L290:

	.byte	0x25,0x73,0x3b,0x20,0x0
	.text
	cvtwl	10(r11),r0
	bicl2	$-32,r0
	pushl	_taevents[r0]
	pushl	$L290
	calls	$2,_printf
L289:
	cvtbl	8(r11),r0
	jbr	L292
L293:
	.data	1
L294:

	.byte	0x6f,0x6f,0x70,0x73,0xa,0x0
	.text
	pushl	$L294
	calls	$1,_printf
	jbr	L291
L295:
	.data	1
L296:

	.byte	0x68,0x6f,0x73,0x74,0x20,0x6d,0x65,0x6d
	.byte	0x20,0x61,0x63,0x63,0x65,0x73,0x73,0x3b
	.byte	0x20,0x61,0x64,0x64,0x72,0x20,0x78,0x25
	.byte	0x78,0xa,0x0
	.text
	pushl	24(r11)
	pushl	$L296
	calls	$2,_printf
	jbr	L291
L297:
	.data	1
L298:

	.byte	0x6c,0x76,0x6c,0x20,0x78,0x25,0x78,0x20
	.byte	0x72,0x65,0x74,0x72,0x79,0x20,0x78,0x25
	.byte	0x78,0xa,0x0
	.text
	cvtbl	35(r11),-(sp)
	cvtbl	34(r11),-(sp)
	pushl	$L298
	calls	$3,_printf
	jbr	L291
L299:
	.data	1
L300:

	.byte	0xa,0x0
	.text
	pushl	$L300
	calls	$1,_printf
	jbr	L291
L292:
	casel	r0,$0,$5
L301:
	.word	L293-L301
	.word	L295-L301
	.word	L299-L301
	.word	L299-L301
	.word	L299-L301
	.word	L297-L301
	jbr	L299
L291:
	.stabs	"ep",0x40,0,40,11
L282:
	ret
	.set	L.R10,0x800
	.set	L.SO10,0x0
L302:	.data
	.text
	.align	2
_taonline:
	.word	L.R11
	subl2	$L.SO11,sp
	.stabs	"taonline",0x24,0,604,_taonline
	.stabs	"taonline",0x32,0,68,0
	.stabs	"ta",0xa0,0,40,4
	.stabs	"rp",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	calls	$0,_spl6
	movl	r0,-4(fp)
	bitw	$2,(r11)
	jneq	L304
	cvtbl	(r10),-(sp)
	movl	4(r11),r0
	calls	$1,*4(r0)
	movl	r0,r9
	pushl	$36
	pushl	r9
	calls	$2,_bzero
	addl2	$1,_tarefno
	movl	_tarefno,(r9)
	movw	2(r10),4(r9)
	movb	$9,8(r9)
	movw	$8224,10(r9)
	bitw	$256,(r11)
	jeql	L305
	bicw2	$256,(r11)
	bisw2	$4096,10(r9)
L305:
	clrw	14(r9)
	clrw	32(r9)
	pushl	r9
	pushl	$1
	cvtbl	(r10),-(sp)
	movl	4(r11),r0
	calls	$3,*12(r0)
	bisw2	$2,(r11)
L304:
	jbr	L307
L308:
	pushl	$60
	pushl	$24
	pushl	r11
	calls	$3,_tsleep
L307:
	bitw	$2,(r11)
	jneq	L308
L306:
	pushl	-4(fp)
	calls	$1,_splx
	bitw	$1,(r11)
	jneq	L309
	clrl	r0
	jbr	L303
L309:
	movl	$1,r0
	jbr	L303
	.stabs	"s",0x80,0,4,4
	.stabs	"mp",0x40,0,40,9
	.stabs	"rp",0x40,0,40,10
	.stabs	"ta",0x40,0,40,11
L303:
	ret
	.set	L.R11,0xe00
	.set	L.SO11,0x4
L310:	.data
	.text
	.align	2
_tasonl:
	.word	L.R12
	subl2	$L.SO12,sp
	.stabs	"tasonl",0x24,0,637,_tasonl
	.stabs	"tasonl",0x32,0,68,0
	.stabs	"ta",0xa0,0,40,4
	.stabs	"ep",0xa0,0,40,8
	movl	4(ap),r11
	movl	8(ap),r10
	bitw	$2,(r11)
	jeql	L312
	bicw2	$2,(r11)
	pushl	r11
	calls	$1,_wakeup
L312:
	bitw	$31,10(r10)
	jeql	L313
	jbr	L311
L313:
	bisw2	$1,(r11)
	bitw	$8192,14(r10)
	jeql	L314
	bisw2	$16,(r11)
L314:
	.stabs	"ep",0x40,0,40,10
	.stabs	"ta",0x40,0,40,11
L311:
	ret
	.set	L.R12,0xc00
	.set	L.SO12,0x0
L315:	.data
	.text
	.align	2
_tacinit:
	.word	L.R13
	subl2	$L.SO13,sp
	.stabs	"tacinit",0x24,0,659,_tacinit
	.stabs	"tacinit",0x32,0,68,0
	.stabs	"ta",0xa0,0,40,4
	.stabs	"rp",0xa0,0,40,8
	cvtbl	*8(ap),-(sp)
	movl	4(ap),r0
	movl	4(r0),r0
	calls	$1,*4(r0)
	movl	r0,r11
	pushl	$36
	pushl	r11
	calls	$2,_bzero
	addl2	$1,_tarefno
	movl	_tarefno,(r11)
	movb	$4,8(r11)
	movw	$8192,10(r11)
	movw	$80,14(r11)
	clrw	12(r11)
	calls	$0,_spl6
	movl	r0,r10
	pushl	r11
	pushl	$1
	cvtbl	*8(ap),-(sp)
	movl	4(ap),r0
	movl	4(r0),r0
	calls	$3,*12(r0)
	pushl	r10
	calls	$1,_splx
	.stabs	"s",0x40,0,4,10
	.stabs	"mp",0x40,0,40,11
L316:
	ret
	.set	L.R13,0xc00
	.set	L.SO13,0x0
L317:	.data
	.stabs	"taevents",0x26,0,226,_taevents
	.stabs	"tarefno",0x28,0,4,_tarefno
	.text
L318:	.stabs	"ta.c",0x94,0,674,L318
