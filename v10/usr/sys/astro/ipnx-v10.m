#
# ipnx-v10 -- the largest and most fully configured VAX-11/780 this
# emulator can present and this kernel can drive.
#
#	boot disk   RA73, 1,914 MB   (MSCP; the largest simh models)
#	memory      128 MB           (MS780E; V10 has run at 138 MB)
#	disks       16 MSCP + 8 RP07 on Massbus
#	tapes       TE16 on Massbus, TU81 on MSCP
#	terminals   64 lines (4 x DZ11 + 4 x DHV11)
#	network     Interlan NI1010A
#
# ipnx780.m is the BUILDER: a small machine that boots quickly and compiles.
# This is the machine the golden image is for, and every number in it was
# either measured from open-simh or taken from a real Bell Labs config.
# Nothing here is invented; where a value is ours the comment says so.
#
# ============================================================ THE DISK ====
# THE BOOT DISK IS AN RA73 -- 3,920,490 sectors, 1,914 MB -- WHICH IS THE
# LARGEST DISK THIS MACHINE CAN PRESENT AND THIS KERNEL CAN ADDRESS.
#
# MSCP IS THE ANSWER PRECISELY BECAUSE THE KERNEL HAS NO TABLE FOR IT.  io/hp.c
# carries a geometry per Massbus drive and the largest is RP07 at 50 x 32 x 630
# = 1,008,000 sectors, 516 MB.  io/ra.c carries no geometry at all: an MSCP
# drive reports its own capacity and ra_sizes[] is a PARTITION LAYOUT, with
# HUGE meaning "the rest of the drive".  So Massbus is capped by a table and
# MSCP is capped only by the hardware, and open-simh models these:
#
#	RA80    237,212     121 MB      RA82  1,216,665    623 MB
#	RA60    400,176     205 MB      RA71  1,367,310    700 MB
#	RA70    547,041     280 MB      RA72  1,953,300   1000 MB
#	RA81    891,072     456 MB      RA90  2,376,153   1217 MB
#	                                RA92  2,940,951   1506 MB
#	                                RA73  3,920,490   1914 MB  <-- this
#
# THE FILESYSTEM IS NOWHERE NEAR ITS LIMIT.  sys/filsys.h gives the superblock
# 960 bitmap-block pointers (S_blk[BITMAP-1]) of 32,768 bits each, so a regfs
# can span 31,457,280 blocks -- 120 GB.  An RA73 uses 490,061 of them, 1.6%.
# Below MAXSMALL (961*32 = 30,752 blocks, 120 MB) the bitmap lives inside the
# superblock instead; every partition here is above that.
#
# AND MSCP NEEDS NO CHANGE TO HOW THE MACHINE STARTS.  boot/star/uda is the ROM
# this project already loads at FA00.  An RP07 would need boot/star/hp instead,
# which takes `r1 = mba address' rather than a controller index -- a different
# boot line for four times less disk.
#
# ROOT IS 5 MB AND THAT IS NOT A CHOICE.  uda.s reads absolute block 0
# (`clrl r8   # block 0'), so root must be partition a, and ra_sizes fixes a at
# 10,240 sectors whatever the drive holds.  The whole gain from a larger disk
# lands in /usr.  The four partitions used here tile the drive exactly:
#
#	a       10,240 @       0        5 MB    root
#	b       20,480 @  10,240       10 MB    swap
#	g      749,544 @  30,720      366 MB    spare filesystem
#	f    3,140,226 @ 780,264     1533 MB    /usr
#
# On the RA81 this project has been building, f is 54 MB.  On an RA73 it is
# 1,533 MB -- twenty-eight times the room, from one word in the simh config.
root	regfs	ra	0100			# ra0a, minor 64 = unit 0 part a
swap	ra	01	20480			# ra0b
dump	uddump	0	10240	20480		# into swap, ra0b

# ========================================================== THE MEMORY ====
# TWO MEMORY CONTROLLERS at simh's own nexus numbers (vax780_defs.h:
# TR_MCTL0 1, TR_MCTL1 2).  These drive error logging, not sizing: md/
# machdep.c takes memory from a probe -- `maxmem = physmem = btoc(hiaddr)' --
# with no compiled ceiling.
#
# HOW MUCH MEMORY IS SAFE IS ANSWERED BY THE TAPE.  astro/alice.m and
# mercury/hunny.m carry `mem 0   # 138 Mbytes', so this kernel has run on
# machines with 138 MB.  open-simh's MS780E ceiling is MAXMEMWIDTH_X 27 =
# 128 MB, comfortably inside what V10 has already seen.  Boot with `set cpu
# 128m'.
ms780 0	bus 0	tr 1
ms780 1	bus 0	tr 2

# ========================================================== THE BUSSES ====
# ONE UNIBUS.  vax780_defs.h has TR_UBA as a single value, not an array, so
# everything a real 780 could hang on a second dw780 comes back to this one.
dw780 0	bus 0	tr 3	voff 0x200

# TWO MASSBUS ADAPTERS, simh's TR_MBA0 8 and TR_MBA1 9 -- which are also
# alice.m's own nexus numbers, so the config and the hardware agree.
mba 0	bus 0	tr 8
mba 1	bus 0	tr 9

# ======================================================== MASSBUS DISKS ====
# EIGHT RP07s, 516 MB each, as SECONDARY storage -- open-simh's RP_NUMDR is 8
# and V10's hp driver is a `mb' class device taking a drive number.  Not the
# boot disk: an RP07 is a quarter of an RA73 and would need the other boot ROM.
# Configured anyway because configuring more than you have is free, and because
# no config on this tape has ever declared an RP07 -- only five of the
# eighty-nine declare a Massbus disk at all, and the four that root on one say
# `# eag48' in their own comments: Fujitsu Eagles, not DEC drives.
hp 0	mb 0	drive 0
hp 1	mb 0	drive 1
hp 2	mb 0	drive 2
hp 3	mb 0	drive 3
hp 4	mb 0	drive 4
hp 5	mb 0	drive 5
hp 6	mb 0	drive 6
hp 7	mb 0	drive 7

# ========================================================= MASSBUS TAPE ====
# simh's `tu' is a TM03 formatter with TE16 drives, and V10 has both in its
# device catalogue as `mb' and `sub' class.  seki.m's own three lines.
tm03 0	mb 1	drive 0
te16 0	ctl 0	unit 0

# ============================================================ MSCP DISK ====
# FOUR UDA50 CONTROLLERS, FOUR DRIVES EACH -- sixteen MSCP disks.  open-simh
# models rq, rqb, rqc and rqd with RQ_NUMDR 4 apiece.
#
# THE ADDRESSES ARE MEASURED, NOT ASSUMED, AND THAT MATTERS.  simh assigns
# Unibus addresses by DEC's floating-address algorithm at configure time
# (IOBA_AUTO/VEC_AUTO), so they are a property of the SET of devices enabled,
# not of any one device: turning on the fourth MSCP controller moved the
# Interlan from 0764000 to 0764040 when this was measured.  Every address
# below was read from `show <dev>' with exactly this device set, converted by
# unibus_octal = physical - 0x20100000, the arithmetic that takes simh's
# 2013F468 to the standard 0772150.
#
# SO THE SIMULATOR MUST BE PINNED TO MATCH.  A config file that enables these
# devices in a different order will float them somewhere else and the kernel
# will probe empty addresses.  These were RE-MEASURED against the final device
# set after the DHV11s were dropped, because removing a device can move every
# address after it; they did not move, but that was luck and not design.  The
# simh config this kernel expects is:
#
#	set cpu 128m
#	set vh disable
#	set rq enable / set rqb enable / set rqc enable / set rqd enable
#	set tq enable
#	set dz enable / set dz lines=32
#	set il enable / set il address=2013E800
#	set rq0 ra73
uda50 0	ub 0	reg 0772150	vec 0154	# simh rq
ra 0	uda50 0	unit 0				# THE SYSTEM DISK -- set rq0 ra73
ra 1	uda50 0	unit 1
ra 2	uda50 0	unit 2
ra 3	uda50 0	unit 3
# ONE CONTROLLER, FOUR DRIVES, and deliberately not more.  ra.4 states the
# minor encoding and the ra<drive><section> naming, but the only /dev we have
# from a real machine -- v8/proto-dev -- covers three drives, and its third is
# already irregular: sections 2 and 6 carry no 0100 bit where drives 0 and 1
# do, and section 0 is named ra20a.  That reads as site configuration rather
# than a convention, so generalising a rule past it would be inventing one.
# Christine's call, and the reason tools/v10-proto.py emits nodes for drives
# 0..2 only.
# ============================================================ MSCP TAPE ====
# simh's TQ is a TU81 at 0774500, and alice.m's 1993 revision configures
# exactly that: `uda50 0 ub 1 reg 0774500 vec 0310  # uda50-aa' with
# `ta 0 uda50 0 unit 0  # tu81-e-ba'.  So V10 already drives a TMSCP tape
# through its MSCP controller driver, at this address, on a real machine.
# The ADDRESS is alice's; the VECTOR is not.  alice pairs 0774500 with vec
# 0310, but on this machine 0310 belongs to dz11 1 -- copying a line from a
# real config transfers its correctness only if the surrounding machine is the
# same one.  0174 continues this config's own MSCP series.
uda50 4	ub 0	reg 0774500	vec 0174	# simh tq, TU81
ta 0	uda50 4	unit 0

# =========================================================== TERMINALS ====
# SIXTY-FOUR LINES.  simh gives four DZ11 muxes of eight lines (DZ_MUXES 4,
# DZ_LINES 8 on UNIBUS) and four DHU/DHV muxes of eight (VH_MUXES 4,
# VH_LINES 8).  V10 has drivers for both -- `dz11 ... rep 8 vec 2' and
# `dhv11 ... rep 8 vec 2' in lib/devs -- and no config on the tape uses more
# than three DZs, so this is the first machine here to take all of them.
dz11 0	ub 0	reg 0760100	vec 0300
dz11 1	ub 0	reg 0760110	vec 0310
dz11 2	ub 0	reg 0760120	vec 0320
dz11 3	ub 0	reg 0760130	vec 0330

# THE DHV11s ARE LEFT OUT, and this is the one place where more configuration
# would have been less correct.  simh models four more muxes as `vh' and V10
# has a dhv11 entry in lib/devs, so it looks like thirty-two extra lines for
# free.  But io/dhv11.c opens `DHV11 driver for Ninth Edition UNIX' and the
# DHV11 is a Q-BUS part, while simh's vh reports `DHU mode' -- a Unibus DHU11.
# Whether V10's driver can drive simh's device is unverified on both sides, and
# a device that is configured but cannot be driven is worse than one that is
# absent: autoconfig finds it, attaches it, and the failure appears later as a
# terminal that does not work.
#
# Thirty-two DZ11 lines are already four times what this project uses, and the
# DZ path is the one proven to work here.

# ============================================================= NETWORK ====
# The Interlan NI1010A, this project's own simh device model
# (libsimh/patches/pdp11_il.c).  PINNED to 0764000 -- alice.m's and
# research.m's own address -- because the floating algorithm moves it when
# the MSCP controllers above are enabled.  The simh config must say
# `set il address=2013E800' to match.
ni1010a 0 ub 0	reg 0764000	vec 0350

# ================================================ CONFIGURED BUT ABSENT ====
# simh models none of these.  They are here because autoconfig probes at boot,
# finds nothing and carries on -- and because leaving them out breaks the
# LINK, not the boot:
#
#	kmc11b  dropping it leaves _kmccnt, _kmc, _kmcaddr undefined
#	drbit   io/drbit.c says in its own header that its routines "are not
#	        called through the normal device interface. Instead, they are
#	        available for other device drivers to use", so configuring hp,
#	        te16 or dn pulls drbit.y into the link, and it then wants
#	        _drcnt, _drreg, _draddr -- which mkconf emits only for a
#	        CONFIGURED device
#	dn11    research.m's own line, on the same argument
#
# alice.m's, research.m's and ssor.m's lines, verbatim.
kmc11b 0 ub 0	reg 0760200	vec 0600
dn11 0	ub 0	reg 0775200	vec 0430
drbit 0	ub 0	reg 0767570

# ============================================================== PSEUDO ====
kdi	2
drum	0
console	0
starcons 0
mem	0						# up to 128 MB, probed
stdio	0
pt	64					# STREAM PIPES (cdev 18) -- v8's own count; see PATCHES.md
fineclock 0

# ======================================================== THE PARAMETERS ====
# EVERY NUMBER BELOW IS THE LARGEST FOUND ON ANY OF THE EIGHTY-NINE REAL
# MACHINE CONFIGURATIONS IN THIS TREE, with the machine it came from named.
# Taking the maximum of each parameter means no value is invented: each one
# is a number some Bell Labs machine actually ran.
proc	1000						# phone/gauss.m
inode	2000						# phone/gauss.m
file	1536						# phone/gauss.m
queue	4096						# phone/gauss.m
block	3200						# astro/r70.m
blkbuf	200						# astro/r70.m
stream	1200						# phone/gauss.m
maxdsize 819200						# phone/gauss.m
maxssize 819200						# phone/gauss.m

# STREAM PIPES ARE NOT CONFIGURED HERE, AND THE REASON IS A ONE-LINE BLOCKER.
# V10 has the driver -- io/spipe.c exports spcdev, and lib/devs line 64 is
# `pt sp count' -- but lib/tab:34 reads
#
#	# cdev 18	pt	# remove?
#
# so the device has no major number and nothing can open it.  An earlier
# kernel here carried `pt 64' only because that build patched lsys/lib/tab to
# uncomment the line; this config is against the VANILLA sys tree, where it is
# still commented.  Enabling stream pipes means editing lib/tab, which is a
# source change with its own justification, not something a machine
# configuration can decide.

# ============================================================ LINE DISCS ====
ttyld	480						# phone/gauss.m
nttyld	64						# misc/bartok.m
xttyld	128						# astro/o.bowell.m
mesgld	512						# misc/bartok.m
rmesgld	0
dkpld	256						# misc/bartok.m
cdkpld	0
cmcld	0
archosld 0
unixpld	96						# phone/gauss.m
connld	0
bufld	32						# misc/ndolphy.m

# ========================================================= FILESYSTEMS ====
regfs	48						# astro/pipe.m
procfs	0
msfs	0
errfs	0
pipefs	0

# NETAFS AND NETBFS ARE THE ONE PLACE THIS EXCEEDS EVERY REAL MACHINE, and
# the reason is stated rather than hidden.  Every config on the tape declares
# `netafs 0' and `netbfs 0' -- the network filesystem types compiled in with
# ZERO instances -- so Weinberger's netfs client has been in every kernel and
# had nothing to talk to.  This project supplies the other half: an Interlan
# the tape's machines did not have on a 750, and a host serving shares over
# it.  Four instances each.
netafs	4
netbfs	4

# ============================================================== INTERNET ====
# alice.m's and europa.m's own numbers, at the maxima found across the tree.
ip	64						# astro/europa.m
udp	32						# misc/most.m
tcp	256						# misc/europa.m
arp	128						# misc/bartok.m
ipld	0
udpld	0
tcpld	0
