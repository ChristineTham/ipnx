L11:	.stabs	"bio.c",0x64,0,0,L11
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
	.comm	_qs,256
	.comm	_whichqs,4
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
	.comm	_bfreelist,132
	.comm	_bswlist,44
	.comm	_bclnlist,4
	.text
	.align	2
	.globl	_bhinit
_bhinit:
	.word	L.R1
	subl2	$L.SO1,sp
	.stabs	"bhinit",0x24,0,43,_bhinit
	movl	$_bufhash,r10
	clrl	r11
	jbr	L125
L126:
	movl	r10,r0
	movl	r0,8(r10)
	movl	r0,4(r10)
	incl	r11
	movl	r10,r0
	addl2	$12,r10
L125:
	cmpl	r11,_bufhcnt
	jlss	L126
L124:
	.stabs	"bp",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L122:
	ret
	.set	L.R1,0xc00
	.set	L.SO1,0x0
L127:	.data
	.comm	_io_info,276
	.comm	_cec_info,1024
	.text
	.align	2
	.globl	_bread
_bread:
	.word	L.R2
	subl2	$L.SO2,sp
	.stabs	"bread",0x24,0,109,_bread
	.stabs	"dev",0xa0,0,13,4
	.stabs	"blkno",0xa0,0,4,8
	pushl	8(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_getblk
	movl	r0,r11
	bitl	$2,(r11)
	jeql	L133
	incl	_io_info+12
	movzwl	4(ap),r0
	bicl3	$-256,r0,r10
	cmpl	r10,$64
	jlss	L134
	subl3	$64,r10,r0
	jbr	L135
L134:
	movl	r10,r0
L135:
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	incl	_cec_info+8(r0)
	movl	r11,r0
	jbr	L132
L133:
	bisl2	$1,(r11)
	bitw	$64,4(ap)
	jeql	L136
	movl	$4096,r0
	jbr	L137
L136:
	movl	$1024,r0
L137:
	movl	r0,20(r11)
	pushl	r11
	movzwl	4(ap),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	calls	$1,*8(r0)
	incl	_io_info+4
	movzwl	4(ap),r0
	bicl3	$-256,r0,r10
	cmpl	r10,$64
	jlss	L138
	subl3	$64,r10,r0
	jbr	L139
L138:
	movl	r10,r0
L139:
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	incl	_cec_info(r0)
	incl	_u+1304
	pushl	r11
	calls	$1,_iowait
	movl	r11,r0
	jbr	L132
	.stabs	"sub",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L132:
	ret
	.set	L.R2,0xc00
	.set	L.SO2,0x0
L141:	.data
	.text
	.align	2
	.globl	_breada
_breada:
	.word	L.R3
	subl2	$L.SO3,sp
	.stabs	"breada",0x24,0,149,_breada
	.stabs	"dev",0xa0,0,13,4
	.stabs	"blkno",0xa0,0,4,8
	.stabs	"rablkno",0xa0,0,4,12
	clrl	r11
	pushl	8(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_incore
	tstl	r0
	jneq	L144
	pushl	8(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_getblk
	movl	r0,r11
	bitl	$2,(r11)
	jneq	L145
	bisl2	$1,(r11)
	bitw	$64,4(ap)
	jeql	L146
	movl	$4096,r0
	jbr	L147
L146:
	movl	$1024,r0
L147:
	movl	r0,20(r11)
	pushl	r11
	movzwl	4(ap),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	calls	$1,*8(r0)
	incl	_io_info+4
	movzwl	4(ap),r0
	bicl3	$-256,r0,r9
	cmpl	r9,$64
	jlss	L148
	subl3	$64,r9,r0
	jbr	L149
L148:
	movl	r9,r0
L149:
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	incl	_cec_info(r0)
	incl	_u+1304
L145:
L144:
	tstl	12(ap)
	jeql	L150
	pushl	12(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_incore
	tstl	r0
	jneq	L150
L151:
	pushl	12(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_getblk
	movl	r0,r10
	bitl	$2,(r10)
	jeql	L152
	pushl	r10
	calls	$1,_brelse
	jbr	L154
L152:
	bisl2	$257,(r10)
	bitw	$64,4(ap)
	jeql	L155
	movl	$4096,r0
	jbr	L156
L155:
	movl	$1024,r0
L156:
	movl	r0,20(r10)
	pushl	r10
	movzwl	4(ap),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	calls	$1,*8(r0)
	incl	_io_info+8
	movzwl	4(ap),r0
	bicl3	$-256,r0,r9
	cmpl	r9,$64
	jlss	L157
	subl3	$64,r9,r0
	jbr	L158
L157:
	movl	r9,r0
L158:
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	incl	_cec_info+4(r0)
	incl	_u+1304
L154:
L150:
	tstl	r11
	jneq	L159
	pushl	8(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_bread
	jbr	L142
L159:
	pushl	r11
	calls	$1,_iowait
	movl	r11,r0
	jbr	L142
	.stabs	"sub",0x40,0,4,9
	.stabs	"rabp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L142:
	ret
	.set	L.R3,0xe00
	.set	L.SO3,0x0
L160:	.data
	.text
	.align	2
	.globl	_bwrite
_bwrite:
	.word	L.R4
	subl2	$L.SO4,sp
	.stabs	"bwrite",0x24,0,202,_bwrite
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	movl	(r11),r10
	bicl2	$647,(r11)
	bitw	$64,26(r11)
	jeql	L163
	movl	$4096,r0
	jbr	L164
L163:
	movl	$1024,r0
L164:
	movl	r0,20(r11)
	incl	_io_info+16
	movzwl	26(r11),r0
	bicl3	$-256,r0,r9
	cmpl	r9,$64
	jlss	L165
	subl3	$64,r9,r0
	jbr	L166
L165:
	movl	r9,r0
L166:
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	incl	_cec_info+12(r0)
	bitl	$512,r10
	jneq	L167
	incl	_u+1308
L167:
	pushl	r11
	movzwl	26(r11),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	calls	$1,*8(r0)
	bitl	$256,r10
	jneq	L168
	pushl	r11
	calls	$1,_iowait
	pushl	r11
	calls	$1,_brelse
	jbr	L169
L168:
	bitl	$512,r10
	jeql	L170
	bisl2	$128,(r11)
	jbr	L171
L170:
	pushl	r11
	calls	$1,_geterror
L171:
L169:
	.stabs	"sub",0x40,0,4,9
	.stabs	"flag",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L162:
	ret
	.set	L.R4,0xe00
	.set	L.SO4,0x0
L173:	.data
	.text
	.align	2
	.globl	_bdwrite
_bdwrite:
	.word	L.R5
	subl2	$L.SO5,sp
	.stabs	"bdwrite",0x24,0,240,_bdwrite
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	bitl	$512,(r11)
	jneq	L176
	incl	_u+1308
L176:
	movzwl	26(r11),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	bitl	$1024,12(r0)
	jeql	L177
	pushl	r11
	calls	$1,_bawrite
	jbr	L179
L177:
	incl	_io_info
	bisl2	$514,(r11)
	pushl	r11
	calls	$1,_brelse
L179:
	.stabs	"bp",0x40,0,40,11
L175:
	ret
	.set	L.R5,0x800
	.set	L.SO5,0x0
L180:	.data
	.text
	.align	2
	.globl	_bawrite
_bawrite:
	.word	L.R6
	subl2	$L.SO6,sp
	.stabs	"bawrite",0x24,0,260,_bawrite
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	bisl2	$256,(r11)
	pushl	r11
	calls	$1,_bwrite
	.stabs	"bp",0x40,0,40,11
L181:
	ret
	.set	L.R6,0x800
	.set	L.SO6,0x0
L182:	.data
	.text
	.align	2
	.globl	_brelse
_brelse:
	.word	L.R7
	subl2	$L.SO7,sp
	.stabs	"brelse",0x24,0,271,_brelse
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	bitl	$64,(r11)
	jeql	L184
	pushl	r11
	calls	$1,_wakeup
L184:
	bitl	$64,_bfreelist
	jeql	L186
	bicl2	$64,_bfreelist
	pushl	$_bfreelist
	calls	$1,_wakeup
L186:
	bitl	$4,(r11)
	jeql	L187
	bitl	$131072,(r11)
	jeql	L188
	bicl2	$4,(r11)
	jbr	L189
L188:
	movw	$65535,26(r11)
L189:
L187:
	calls	$0,_spl6
	movl	r0,r9
	bitl	$65540,(r11)
	jeql	L191
	movl	$_bfreelist+88,r10
	movl	12(r10),r0
	movl	r11,16(r0)
	movl	12(r10),12(r11)
	movl	r11,12(r10)
	movl	r10,16(r11)
	jbr	L192
L191:
	bitl	$131072,(r11)
	jeql	L193
	movl	$_bfreelist,r10
	jbr	L194
L193:
	bitl	$128,(r11)
	jeql	L195
	movl	$_bfreelist+88,r10
	jbr	L196
L195:
	movl	$_bfreelist+44,r10
L196:
L194:
	movl	16(r10),r0
	movl	r11,12(r0)
	movl	16(r10),16(r11)
	movl	r11,16(r10)
	movl	r10,12(r11)
L192:
	bicl2	$456,(r11)
	pushl	r9
	calls	$1,_splx
	.stabs	"s",0x40,0,4,9
	.stabs	"flist",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L183:
	ret
	.set	L.R7,0xe00
	.set	L.SO7,0x0
L198:	.data
	.text
	.align	2
	.globl	_incore
_incore:
	.word	L.R8
	subl2	$L.SO8,sp
	.stabs	"incore",0x24,0,317,_incore
	.stabs	"dev",0xa0,0,13,4
	.stabs	"blkno",0xa0,0,4,8
	bitw	$64,4(ap)
	jeql	L200
	addl3	8(ap),8(ap),r0
	addl2	r0,r0
	addl2	r0,r0
	jbr	L201
L200:
	addl3	8(ap),8(ap),r0
L201:
	movl	r0,r9
	movzwl	4(ap),r0
	addl2	r9,r0
	divl3	_bufhcnt,r0,r1
	mull2	_bufhcnt,r1
	subl3	r1,r0,r1
	mull2	$12,r1
	addl3	$_bufhash,r1,r10
	movl	4(r10),r11
	jbr	L204
L205:
	cmpl	32(r11),r9
	jneq	L206
	cmpw	26(r11),4(ap)
	jneq	L206
L208:
	bitl	$65536,(r11)
	jneq	L206
L207:
	movl	$1,r0
	jbr	L199
L206:
	movl	4(r11),r11
L204:
	cmpl	r11,r10
	jneq	L205
L203:
	clrl	r0
	jbr	L199
	.stabs	"dblkno",0x40,0,4,9
	.stabs	"dp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L199:
	ret
	.set	L.R8,0xe00
	.set	L.SO8,0x0
L209:	.data
	.text
	.align	2
	.globl	_baddr
_baddr:
	.word	L.R9
	subl2	$L.SO9,sp
	.stabs	"baddr",0x24,0,334,_baddr
	.stabs	"dev",0xa0,0,13,4
	.stabs	"blkno",0xa0,0,4,8
	pushl	8(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_incore
	tstl	r0
	jeql	L211
	pushl	8(ap)
	movzwl	4(ap),-(sp)
	calls	$2,_bread
	jbr	L210
L211:
	clrl	r0
	jbr	L210
L210:
	ret
	.set	L.R9,0x0
	.set	L.SO9,0x0
L212:	.data
	.text
	.align	2
	.globl	_getblk
_getblk:
	.word	L.R10
	subl2	$L.SO10,sp
	.stabs	"getblk",0x24,0,350,_getblk
	.stabs	"dev",0xa0,0,13,4
	.stabs	"blkno",0xa0,0,4,8
	cmpl	8(ap),$8388608
	jlssu	L214
	movl	$16777216,8(ap)
L214:
	bitw	$64,4(ap)
	jeql	L215
	addl3	8(ap),8(ap),r0
	addl2	r0,r0
	addl2	r0,r0
	jbr	L216
L215:
	addl3	8(ap),8(ap),r0
L216:
	movl	r0,r8
	movzwl	4(ap),r0
	addl2	r8,r0
	divl3	_bufhcnt,r0,r1
	mull2	_bufhcnt,r1
	subl3	r1,r0,r1
	mull2	$12,r1
	addl3	$_bufhash,r1,r10
L217:
	calls	$0,_spl0
	movl	4(r10),r11
	jbr	L221
L222:
	cmpl	32(r11),r8
	jneq	L224
	cmpw	26(r11),4(ap)
	jneq	L224
L225:
	bitl	$65536,(r11)
	jeql	L223
L224:
	jbr	L219
L223:
	calls	$0,_spl6
	bitl	$8,(r11)
	jeql	L226
	bisl2	$64,(r11)
	pushl	$21
	pushl	r11
	calls	$2,_sleep
	jbr	L217
L226:
	calls	$0,_spl0
	clrl	r7
	movl	12(r11),r10
	jbr	L229
L230:
	incl	r7
	movl	12(r10),r10
L229:
	bitl	$262144,(r10)
	jeql	L230
L228:
	cmpl	r7,$64
	jgeq	L231
	incl	_io_info+20[r7]
L231:
	calls	$0,_spl6
	movl	r0,-4(fp)
	movl	16(r11),r0
	movl	12(r11),12(r0)
	movl	12(r11),r0
	movl	16(r11),16(r0)
	bisl2	$8,(r11)
	pushl	-4(fp)
	calls	$1,_splx
	.stabs	"s",0x80,0,4,4
	movl	r11,r0
	jbr	L213
L219:
	movl	4(r11),r11
L221:
	cmpl	r11,r10
	jneq	L222
L220:
	movzwl	4(ap),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	cmpl	r0,_nblkdev
	jlss	L232
	.data	1
L234:

	.byte	0x62,0x6c,0x6b,0x64,0x65,0x76,0x0
	.text
	pushl	$L234
	calls	$1,_panic
L232:
	calls	$0,_spl6
	movl	$_bfreelist+88,r9
	jbr	L237
L238:
	cmpl	12(r9),r9
	jeql	L239
	jbr	L236
L239:
	subl2	$44,r9
L237:
	cmpl	r9,$_bfreelist
	jgtru	L238
L236:
	cmpl	r9,$_bfreelist
	jneq	L240
	bisl2	$64,(r9)
	pushl	$21
	pushl	r9
	calls	$2,_sleep
	jbr	L217
L240:
	calls	$0,_spl0
	movl	12(r9),r11
	calls	$0,_spl6
	movl	r0,-4(fp)
	movl	16(r11),r0
	movl	12(r11),12(r0)
	movl	12(r11),r0
	movl	16(r11),16(r0)
	bisl2	$8,(r11)
	pushl	-4(fp)
	calls	$1,_splx
	.stabs	"s",0x80,0,4,4
	bitl	$512,(r11)
	jeql	L241
	bisl2	$256,(r11)
	pushl	r11
	calls	$1,_bwrite
	jbr	L217
L241:
	movl	$8,(r11)
	movl	8(r11),r0
	movl	4(r11),4(r0)
	movl	4(r11),r0
	movl	8(r11),8(r0)
	movl	4(r10),4(r11)
	movl	r10,8(r11)
	movl	4(r10),r0
	movl	r11,8(r0)
	movl	r11,4(r10)
	movw	4(ap),26(r11)
	movl	r8,32(r11)
	movl	r11,r0
	jbr	L213
	.stabs	"i",0x40,0,4,7
	.stabs	"dblkno",0x40,0,4,8
	.stabs	"ep",0x40,0,40,9
	.stabs	"dp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L213:
	ret
	.set	L.R10,0xf80
	.set	L.SO10,0x4
L242:	.data
	.text
	.align	2
	.globl	_geteblk
_geteblk:
	.word	L.R11
	subl2	$L.SO11,sp
	.stabs	"geteblk",0x24,0,424,_geteblk
L244:
	calls	$0,_spl6
	movl	r0,r9
	movl	$_bfreelist+88,r10
	jbr	L247
L248:
	cmpl	12(r10),r10
	jeql	L249
	jbr	L246
L249:
	subl2	$44,r10
L247:
	cmpl	r10,$_bfreelist
	jgtru	L248
L246:
	cmpl	r10,$_bfreelist
	jneq	L250
	bisl2	$64,(r10)
	pushl	$21
	pushl	r10
	calls	$2,_sleep
	jbr	L244
L250:
	pushl	r9
	calls	$1,_splx
	movl	12(r10),r11
	calls	$0,_spl6
	movl	r0,-4(fp)
	movl	16(r11),r0
	movl	12(r11),12(r0)
	movl	12(r11),r0
	movl	16(r11),16(r0)
	bisl2	$8,(r11)
	pushl	-4(fp)
	calls	$1,_splx
	.stabs	"s",0x80,0,4,4
	bitl	$512,(r11)
	jeql	L251
	bisl2	$256,(r11)
	pushl	r11
	calls	$1,_bwrite
	jbr	L244
L251:
	movl	$65544,(r11)
	movl	8(r11),r0
	movl	4(r11),4(r0)
	movl	4(r11),r0
	movl	8(r11),8(r0)
	movl	4(r10),4(r11)
	movl	r10,8(r11)
	movl	4(r10),r0
	movl	r11,8(r0)
	movl	r11,4(r10)
	movw	$65535,26(r11)
	movl	$4096,20(r11)
	movl	r11,r0
	jbr	L243
	.stabs	"s",0x40,0,4,9
	.stabs	"dp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L243:
	ret
	.set	L.R11,0xe00
	.set	L.SO11,0x4
L252:	.data
	.text
	.align	2
	.globl	_iowait
_iowait:
	.word	L.R12
	subl2	$L.SO12,sp
	.stabs	"iowait",0x24,0,464,_iowait
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	calls	$0,_spl6
	jbr	L255
L256:
	pushl	$20
	pushl	r11
	calls	$2,_sleep
L255:
	bitl	$2,(r11)
	jeql	L256
L254:
	calls	$0,_spl0
	pushl	r11
	calls	$1,_geterror
	.stabs	"bp",0x40,0,40,11
L253:
	ret
	.set	L.R12,0x800
	.set	L.SO12,0x0
L257:	.data
	.text
	.align	2
	.globl	_iodone
_iodone:
	.word	L.R13
	subl2	$L.SO13,sp
	.stabs	"iodone",0x24,0,501,_iodone
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	bitl	$2,(r11)
	jeql	L260
	.data	1
L261:

	.byte	0x64,0x75,0x70,0x20,0x69,0x6f,0x64,0x6f
	.byte	0x6e,0x65,0x0
	.text
	pushl	$L261
	calls	$1,_panic
L260:
	bisl2	$2,(r11)
	bitl	$8192,(r11)
	jeql	L262
	bitl	$4,(r11)
	jeql	L263
	.data	1
L264:

	.byte	0x49,0x4f,0x20,0x65,0x72,0x72,0x20,0x69
	.byte	0x6e,0x20,0x70,0x75,0x73,0x68,0x0
	.text
	pushl	$L264
	calls	$1,_panic
L263:
	calls	$0,_spl6
	movl	r0,r10
	movl	_bclnlist,12(r11)
	subl3	$_swapbuf,r11,r0
	divl2	$44,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	movl	_swapinfo(r0),20(r11)
	subl3	$_swapbuf,r11,r0
	divl2	$44,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	movl	_swapinfo+4(r0),36(r11)
	incl	_cnt+32
	divl3	$512,20(r11),r0
	addl2	r0,_cnt+40
	movl	r11,_bclnlist
	bitl	$64,_bswlist
	jeql	L265
	pushl	$_proc+248
	calls	$1,_wakeup
L265:
	pushl	r10
	calls	$1,_splx
	jbr	L259
L262:
	bitl	$256,(r11)
	jeql	L266
	pushl	r11
	calls	$1,_brelse
	jbr	L267
L266:
	bicl2	$64,(r11)
	pushl	r11
	calls	$1,_wakeup
L267:
	.stabs	"s",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L259:
	ret
	.set	L.R13,0xc00
	.set	L.SO13,0x0
L268:	.data
	.text
	.align	2
	.globl	_clrbuf
_clrbuf:
	.word	L.R14
	subl2	$L.SO14,sp
	.stabs	"clrbuf",0x24,0,535,_clrbuf
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r0
	movl	28(r0),r11
	movl	$1024,r10
L273:
	clrl	(r11)+
L272:
	decl	r10
	jneq	L273
L271:
	movl	4(ap),r0
	clrl	36(r0)
	.stabs	"c",0x40,0,4,10
	.stabs	"p",0x40,0,36,11
L270:
	ret
	.set	L.R14,0xc00
	.set	L.SO14,0x0
L274:	.data
	.text
	.align	2
	.globl	_swap
_swap:
	.word	L.R15
	subl2	$L.SO15,sp
	.stabs	"swap",0x24,0,566,_swap
	.stabs	"p",0xa0,0,40,4
	.stabs	"dblkno",0xa0,0,4,8
	.stabs	"addr",0xa0,0,34,12
	.stabs	"nbytes",0xa0,0,4,16
	.stabs	"rdflg",0xa0,0,4,20
	.stabs	"flag",0xa0,0,4,24
	.stabs	"dev",0xa0,0,13,28
	.stabs	"pfcent",0xa0,0,14,32
	calls	$0,_spl6
	jbr	L278
L279:
	bisl2	$64,_bswlist
	pushl	$1
	pushl	$_bswlist
	calls	$2,_sleep
L278:
	tstl	_bswlist+12
	jeql	L279
L277:
	movl	_bswlist+12,r11
	movl	12(r11),_bswlist+12
	calls	$0,_spl0
	bisl3	$24,20(ap),r0
	bisl3	24(ap),r0,(r11)
	bitl	$24576,(r11)
	jneq	L280
	cmpl	20(ap),$1
	jneq	L281
	addl3	$511,16(ap),r0
	extzv	$9,$23,r0,r0
	addl2	r0,_sum+20
	jbr	L282
L281:
	addl3	$511,16(ap),r0
	extzv	$9,$23,r0,r0
	addl2	r0,_sum+24
L282:
L280:
	movl	4(ap),40(r11)
	bitl	$8192,24(ap)
	jeql	L283
	subl3	$_swapbuf,r11,r0
	divl2	$44,r0
	addl2	r0,r0
	ashl	$4,r0,-4(fp)
	addl3	_proc+304,_proc+304,r0
	addl2	r0,r0
	addl2	_proc+344,r0
	addl3	-4(fp),-4(fp),r1
	addl2	r1,r1
	addl3	r1,r0,r9
	extzv	$9,$23,12(ap),-(sp)
	pushl	4(ap)
	calls	$2,_vtopte
	movl	r0,r8
	clrl	r10
	jbr	L286
L287:
	extzv	$0,$21,(r8),r0
	jeql	L289
	extzv	$25,$1,(r8),r0
	jeql	L288
L289:
	.data	1
L290:

	.byte	0x73,0x77,0x61,0x70,0x20,0x62,0x61,0x64
	.byte	0x20,0x70,0x74,0x65,0x0
	.text
	pushl	$L290
	calls	$1,_panic
L288:
	movl	(r8)+,(r9)+
	addl2	$512,r10
L286:
	cmpl	r10,16(ap)
	jlss	L287
L285:
	ashl	$9,-4(fp),28(r11)
	jbr	L291
L283:
	movl	12(ap),28(r11)
L291:
	jbr	L293
L294:
	pushl	16(ap)
	pushl	$61440
	calls	$2,_imin
	movl	r0,r10
	movl	r10,20(r11)
	movl	8(ap),32(r11)
	movw	28(ap),26(r11)
	bitl	$8192,24(ap)
	jeql	L296
	subl3	$_swapbuf,r11,r0
	divl2	$44,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	movl	32(ap),_swapinfo+4(r0)
	subl3	$_swapbuf,r11,r0
	divl2	$44,r0
	addl2	r0,r0
	addl2	r0,r0
	addl2	r0,r0
	movl	16(ap),_swapinfo(r0)
L296:
	movzwl	28(ap),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	tstl	_bdevsw[r0]
	jneq	L297
	.data	1
L298:

	.byte	0x73,0x77,0x61,0x70,0x0
	.text
	pushl	$L298
	calls	$1,_panic
L297:
	pushl	r11
	movzwl	28(ap),r0
	extzv	$8,$24,r0,r0
	bicl2	$-256,r0
	movl	_bdevsw[r0],r0
	calls	$1,*8(r0)
	bitl	$8192,24(ap)
	jeql	L299
	cmpl	r10,16(ap)
	jgeq	L300
	.data	1
L301:

	.byte	0x62,0x69,0x67,0x20,0x70,0x75,0x73,0x68
	.byte	0x0
	.text
	pushl	$L301
	calls	$1,_panic
L300:
	jbr	L276
L299:
	calls	$0,_spl6
	jbr	L303
L304:
	pushl	$0
	pushl	r11
	calls	$2,_sleep
L303:
	bitl	$2,(r11)
	jeql	L304
L302:
	calls	$0,_spl0
	addl2	r10,28(r11)
	bicl2	$2,(r11)
	bitl	$4,(r11)
	jeql	L305
	bitl	$6144,24(ap)
	jneq	L307
	tstl	20(ap)
	jneq	L306
L307:
	.data	1
L308:

	.byte	0x68,0x61,0x72,0x64,0x20,0x49,0x4f,0x20
	.byte	0x65,0x72,0x72,0x20,0x69,0x6e,0x20,0x73
	.byte	0x77,0x61,0x70,0x0
	.text
	pushl	$L308
	calls	$1,_panic
L306:
	pushl	$0
	pushl	4(ap)
	calls	$2,_swkill
L305:
	subl2	r10,16(ap)
	addl3	$511,r10,r0
	extzv	$9,$23,r0,r0
	addl2	r0,8(ap)
L293:
	tstl	16(ap)
	jgtr	L294
L292:
	calls	$0,_spl6
	bicl2	$14424,(r11)
	movl	_bswlist+12,12(r11)
	movl	r11,_bswlist+12
	bitl	$64,_bswlist
	jeql	L310
	bicl2	$64,_bswlist
	pushl	$_bswlist
	calls	$1,_wakeup
	pushl	$_proc+248
	calls	$1,_wakeup
L310:
	calls	$0,_spl0
	.stabs	"vpte",0x40,0,40,8
	.stabs	"dpte",0x40,0,40,9
	.stabs	"p2dp",0x80,0,4,4
	.stabs	"c",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L276:
	ret
	.set	L.R15,0xf00
	.set	L.SO15,0x4
L311:	.data
	.text
	.align	2
	.globl	_bswinit
_bswinit:
	.word	L.R16
	subl2	$L.SO16,sp
	.stabs	"bswinit",0x24,0,650,_bswinit
	movl	$_swapbuf,r10
	movl	r10,_bswlist+12
	clrl	r11
	jbr	L317
L318:
	addl3	$44,r10,12(r10)
	incl	r11
	movl	r10,r0
	addl2	$44,r10
L317:
	subl3	$1,_swbufcnt,r0
	cmpl	r11,r0
	jlss	L318
L316:
	clrl	12(r10)
	.stabs	"sp",0x40,0,40,10
	.stabs	"i",0x40,0,4,11
L313:
	ret
	.set	L.R16,0xc00
	.set	L.SO16,0x0
L319:	.data
	.text
	.align	2
	.globl	_swkill
_swkill:
	.word	L.R17
	subl2	$L.SO17,sp
	.stabs	"swkill",0x24,0,669,_swkill
	.stabs	"p",0xa0,0,40,4
	.stabs	"rout",0xa0,0,34,8
	.data	1
L322:

	.byte	0x70,0x69,0x64,0x20,0x25,0x64,0x3a,0x20
	.byte	0x0
	.text
	movl	4(ap),r0
	cvtwl	40(r0),-(sp)
	pushl	$L322
	calls	$2,_printf
	tstl	8(ap)
	jeql	L323
	.data	1
L324:

	.byte	0x6b,0x69,0x6c,0x6c,0x65,0x64,0x20,0x64
	.byte	0x75,0x65,0x20,0x74,0x6f,0x20,0x6e,0x6f
	.byte	0x20,0x73,0x77,0x61,0x70,0x20,0x73,0x70
	.byte	0x61,0x63,0x65,0xa,0x0
	.text
	pushl	$L324
	calls	$1,_printf
	jbr	L325
L323:
	.data	1
L326:

	.byte	0x6b,0x69,0x6c,0x6c,0x65,0x64,0x20,0x6f
	.byte	0x6e,0x20,0x73,0x77,0x61,0x70,0x20,0x65
	.byte	0x72,0x72,0x6f,0x72,0xa,0x0
	.text
	pushl	$L326
	calls	$1,_printf
L325:
	pushl	$9
	pushl	4(ap)
	calls	$2,_psignal
	movl	4(ap),r0
	bisl2	$64,32(r0)
L320:
	ret
	.set	L.R17,0x0
	.set	L.SO17,0x0
L328:	.data
	.text
	.align	2
	.globl	_bflush
_bflush:
	.word	L.R18
	subl2	$L.SO18,sp
	.stabs	"bflush",0x24,0,694,_bflush
	.stabs	"dev",0xa0,0,13,4
L331:
	calls	$0,_spl6
	movl	r0,r9
	movl	$_bfreelist,r10
	jbr	L334
L335:
	movl	12(r10),r11
	jbr	L338
L339:
	bitl	$512,(r11)
	jeql	L340
	movzwl	4(ap),r0
	cmpl	r0,$65535
	jeql	L342
	cmpw	4(ap),26(r11)
	jneq	L340
L342:
L341:
	bisl2	$256,(r11)
	calls	$0,_spl6
	movl	r0,-4(fp)
	movl	16(r11),r0
	movl	12(r11),12(r0)
	movl	12(r11),r0
	movl	16(r11),16(r0)
	bisl2	$8,(r11)
	pushl	-4(fp)
	calls	$1,_splx
	.stabs	"s",0x80,0,4,4
	pushl	r9
	calls	$1,_splx
	pushl	r11
	calls	$1,_bwrite
	jbr	L331
L340:
	movl	12(r11),r11
L338:
	cmpl	r11,r10
	jneq	L339
L337:
	addl2	$44,r10
L334:
	cmpl	r10,$_bfreelist+132
	jlssu	L335
L333:
	pushl	r9
	calls	$1,_splx
	.stabs	"s",0x40,0,4,9
	.stabs	"flist",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L330:
	ret
	.set	L.R18,0xe00
	.set	L.SO18,0x4
L343:	.data
	.text
	.align	2
	.globl	_physio
_physio:
	.word	L.R19
	subl2	$L.SO19,sp
	.stabs	"physio",0x24,0,733,_physio
	.stabs	"strat",0xa0,0,292,4
	.stabs	"bp",0xa0,0,40,8
	.stabs	"dev",0xa0,0,4,12
	.stabs	"rw",0xa0,0,4,16
	.stabs	"mincnt",0xa0,0,302,20
	movl	8(ap),r11
	cmpl	16(ap),$1
	jneq	L348
	clrl	-(sp)
	jbr	L349
L348:
	movl	$1,-(sp)
L349:
	pushl	_u+292
	pushl	_u+288
	calls	$3,_useracc
	tstl	r0
	jneq	L347
	movb	$14,_u+197
	jbr	L345
L347:
	calls	$0,_spl6
	movl	r0,r9
	jbr	L351
L352:
	bisl2	$64,(r11)
	pushl	$20
	pushl	$21
	pushl	r11
	calls	$3,_tsleep
	jbr	L355
L356:
	jbr	L351
L357:
	jbr	L351
L358:
	movb	$5,_u+197
	pushl	r9
	calls	$1,_splx
	jbr	L345
L355:
	casel	r0,$0,$2
L359:
	.word	L356-L359
	.word	L358-L359
	.word	L357-L359
L360:
L354:
L351:
	bitl	$8,(r11)
	jneq	L352
L350:
	pushl	r9
	calls	$1,_splx
	clrw	24(r11)
	movl	_u+272,40(r11)
	movl	_u+288,28(r11)
	jbr	L362
L363:
	bisl3	$24,16(ap),(r11)
	movw	12(ap),26(r11)
	pushl	$9
	movq	_u+296,-(sp)
	calls	$3,_Lshift
	movl	r0,32(r11)
	movl	_u+292,20(r11)
	pushl	r11
	calls	$1,*20(ap)
	movl	20(r11),r10
	movl	_u+272,r0
	bisl2	$2048,32(r0)
	pushl	r10
	movl	28(r11),-4(fp)
	pushl	-4(fp)
	calls	$2,_vslock
	pushl	r11
	calls	$1,*4(ap)
	calls	$0,_spl6
	movl	r0,r9
	jbr	L366
L367:
	pushl	$20
	pushl	r11
	calls	$2,_sleep
L366:
	bitl	$2,(r11)
	jeql	L367
L365:
	pushl	16(ap)
	pushl	r10
	pushl	-4(fp)
	calls	$3,_vsunlock
	movl	_u+272,r0
	bicl2	$2048,32(r0)
	bitl	$64,(r11)
	jeql	L369
	pushl	r11
	calls	$1,_wakeup
L369:
	pushl	r9
	calls	$1,_splx
	addl2	r10,28(r11)
	subl2	r10,_u+292
	pushl	r10
	movq	_u+296,-(sp)
	calls	$3,_Lladd
	movq	(r0),_u+296
	bitl	$4,(r11)
	jeql	L370
	jbr	L361
L370:
L362:
	tstl	_u+292
	jneq	L363
L361:
	bicl2	$88,(r11)
	movl	36(r11),_u+292
	pushl	r11
	calls	$1,_geterror
	.stabs	"s",0x40,0,4,9
	.stabs	"a",0x80,0,34,4
	.stabs	"c",0x40,0,4,10
	.stabs	"bp",0x40,0,40,11
L345:
	ret
	.set	L.R19,0xe00
	.set	L.SO19,0x4
L371:	.data
	.text
	.align	2
	.globl	_minphys
_minphys:
	.word	L.R20
	subl2	$L.SO20,sp
	.stabs	"minphys",0x24,0,794,_minphys
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r0
	cmpl	20(r0),$65024
	jleq	L373
	movl	4(ap),r0
	movl	$65024,20(r0)
L373:
L372:
	ret
	.set	L.R20,0x0
	.set	L.SO20,0x0
L374:	.data
	.text
	.align	2
	.globl	_geterror
_geterror:
	.word	L.R21
	subl2	$L.SO21,sp
	.stabs	"geterror",0x24,0,808,_geterror
	.stabs	"bp",0xa0,0,40,4
	movl	4(ap),r11
	bitl	$4,(r11)
	jeql	L376
	movb	24(r11),_u+197
	jneq	L377
	movb	$5,_u+197
L377:
L376:
	.stabs	"bp",0x40,0,40,11
L375:
	ret
	.set	L.R21,0x800
	.set	L.SO21,0x0
L378:	.data
	.text
	.align	2
	.globl	_binval
_binval:
	.word	L.R22
	subl2	$L.SO22,sp
	.stabs	"binval",0x24,0,828,_binval
	.stabs	"dev",0xa0,0,13,4
	subl3	$1,_bufhcnt,r0
	mull2	$12,r0
	addl3	$_bufhash,r0,r10
	jbr	L383
L384:
	movl	4(r10),r11
	jbr	L387
L388:
	cmpw	26(r11),4(ap)
	jneq	L389
	bisl2	$65536,(r11)
L389:
	movl	4(r11),r11
L387:
	cmpl	r11,r10
	jneq	L388
L386:
	subl2	$12,r10
L383:
	cmpl	r10,$_bufhash
	jgequ	L384
L382:
	.stabs	"hp",0x40,0,40,10
	.stabs	"bp",0x40,0,40,11
L380:
	ret
	.set	L.R22,0xc00
	.set	L.SO22,0x0
L390:	.data
	.text
L391:	.stabs	"bio.c",0x94,0,838,L391
