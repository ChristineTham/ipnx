#
# ipnx780 -- the VAX-11/780 this project actually has.
#
# OURS, derived from lsys/astro/alice.m and diffed against it in
# v10/src/PATCHES.md.  alice was a real CSRC 11/780; this is the same machine
# reduced to the hardware open-simh's vax780 provides, which is what makes it
# buildable AND bootable rather than only faithful.
#
# WHY A NEW CONFIG RATHER THAN alice.m VERBATIM.  Christine, 2026-08-17: "we
# need to generate a new config that we can build from."  alice describes one
# specific machine at Bell Labs -- two Unibus adapters, two UDA50s at
# deliberately nonstandard addresses, a TU78 tape, a Datakit interface, a DN11
# autodialer.  Compiling that and then failing to boot it teaches nothing about
# V10; compiling a 780 we can run teaches everything.
#
# WHERE THE ADDRESSES COME FROM, AND WHICH SIDE MOVED.  Register and vector
# numbers are compiled into the kernel and are settable in the simulator, so
# where the two disagree it is better to move the SIMULATOR -- that keeps V10's
# own numbers.  The exception is where SIMH simply has no such device, and then
# the device leaves this file.  Measured with `show devices' on
# work/opensimh/BIN/vax780, not assumed.
#
# KEPT FROM alice, unchanged:
#	root regfs ra 0100	UDA50/RA81, 0100 = the BITFS bit, 0 = partition a.
#	ms780 0/1		= SIMH MCTL0, MCTL1
#	ni1010a 0		= SIMH IL, this project's own device model
#				(libsimh/patches/pdp11_il.c).  Present but
#				disabled by default: `set il enable'.
#	ip/udp/tcp/arp		alice already configured the whole stack.
#
# CHANGED, each with a reason:
#	dw780 1 REMOVED		SIMH has ONE Unibus adapter (UBA, nexus 3), so
#				everything alice put on `ub 1' moves to `ub 0'.
#	uda50 1 REMOVED		SIMH's RQ is one controller (RQB/C/D exist but
#				are disabled).  One is enough: unit 0 is the
#				system disk, unit 1 the source disk.
#	uda50 0 reg		0772150, SIMH's default, rather than alice's
#				0772160 -- which alice's own comment calls
#				"annoyingly nonstandard".  This is the one place
#				the CONFIG moved instead of the simulator,
#				because the standard address is also V10's own
#				elsewhere and nothing is lost by using it.
#	ra 2..5 REMOVED		one controller, and we have two disks.
#	swap			one device, ra 01 = unit 0 partition b, which is
#				20480 blocks at offset 10240 in ra_sizes[].
#				alice striped swap across six drives; we have
#				one.
#	tm78/tu78 REMOVED	SIMH's MBA1 carries a TM03, not a TM78, and the
#				tape route is dead here anyway (docs/media-
#				exchange.md: V8's ht driver panics the kernel).
#	mba REMOVED		nothing left on it once the tape goes.
#	dn11, drbit, dk		no counterpart in SIMH's vax780.  dk is Datakit,
#	REMOVED			which is the network V10 lost in 1985.
#	kmc11b KEPT		SIMH has none either, but removing it left ld
#				three symbols short -- see below.
#	dz11 4/5 REMOVED	SIMH's DZ is one controller with 32 lines; one
#				dz11 is what we can drive.
#	dz11 0 vec 0300		SIMH's DZ vector base (C0), not alice's 0320.
#
# WHAT K17 ADDED, AND WHY EACH IS A CAPABILITY RATHER THAN A NODE.  The K16
# audit asked whether this machine is a functional superset of the V8 golden
# and answered no in 382 device names.  Four of those groups were a config
# line each, because V10 ships the driver and mkconf's own catalogue
# (lsys/lib/devs) already knows it:
#
#	pt 64		STREAM PIPES, and V8's /dev/pt is NOT pseudo-ttys --
#			major 18 in V8's own cdevsw is `sp' with &spinfo.
#			V10 has lsys/io/spipe.c exporting spcdev, and
#			lsys/lib/devs line 64 is `pt sp count'.  All that was
#			missing is `cdev 18 pt' in tab, which V10 left
#			commented `# remove?' -- see v10/src/lsys/lib/tab.
#			64 nodes.
#	mba 0 + hp	THE MASSBUS RP DISKS.  bdev 0 / cdev 4 in V10's own
#			tab, driver lsys/io/hp.c in V10's own tree, and
#			`hp hp mb ...' in lsys/lib/devs -- so the tape can
#			configure it and no config on the tape does.  SIMH's
#			vax780 puts RP on MBA0 at nexus 8 (vax780_defs.h:
#			TR_MBA0 8), which is alice.m's own number.  This is
#			what lets V10 read an RP07 -- the V8 golden's own
#			disk -- so it is the one addition with a use beyond
#			closing a name.  32 nodes.
#	mba 1 + tm03	THE TAPE.  seki.m's own three lines (`mba', `tm03 0
#	+ te16 0	mb', `te16 0 ctl 0 unit 0'), and SIMH's MBA1 carries
#			exactly a TM03 (nexus 9 = TR_MBA1).  H_NOREWIND is 04
#			in V8's mt.c, V10's te16.c and V10's tu78.c alike, so
#			V8's own minors transfer untranslated.  12 nodes.
#	dn11 0		THE AUTODIALER, configured-but-absent on the same
#			argument kmc11b already is: autoconfig probes 0775200,
#			finds nothing, carries on.  research.m's own line.
#			1 node.
#
# netafs AND netbfs ARE NON-ZERO, AND THAT IS THE POINT OF THE 780.
# alice and seki both configure `netafs 0' and `netbfs 0' -- the network
# filesystem types compiled in with ZERO instances -- which is half of why
# "there is no netfs on V10".  The other half was that SIMH's vax750 has no
# Interlan.  Both halves are ours to fix here: we write the config, and the
# 780 has our NI1010.  Weinberger's netfs client has been compiled into every
# V8 kernel since 1985 with nothing to talk to; this is the line that gives
# V10 the same live /n/src share, and retires the courier disk.

root	regfs	ra	0100
swap	ra	01	20480
dump	uddump	0x1001	10240	20480

ms780 0	bus 0	tr 1
ms780 1	bus 0	tr 2

dw780 0	bus 0	tr 3	voff 0x200

#
# THE MASSBUS.  SIMH's vax780 has two adapters -- vax780_defs.h names them
# TR_MBA0 8 and TR_MBA1 9, which are alice.m's own nexus numbers -- carrying
# pdp11_rp.c (the RP disks) and pdp11_tu.c (a TM03/TE16 tape).  Both objects
# are in libsimh's CMakeLists, so this works in the app and not only on the
# desktop build.
#
mba 0	bus 0	tr 8
hp 0	mb 0	drive 0
hp 1	mb 0	drive 1

mba 1	bus 0	tr 9
tm03 0	mb 1	drive 0
te16 0	ctl 0	unit 0

#
# The UDA50 at SIMH's standard address: unit 0 is the system disk, unit 1 the
# source disk that tools/v10-srcdisk.sh builds.
#
uda50 0	ub 0	reg 0772150	vec 0154
ra 0	uda50 0	unit 0
ra 1	uda50 0	unit 1

dz11 0	ub 0	reg 0760100	vec 0300
ni1010a 0 ub 0	reg 0764000	vec 0350

#
# KEPT, THOUGH SIMH HAS NO SUCH DEVICE, and the reason is a linker error.
#
# Dropping kmc11b left `ld' three symbols short -- _kmccnt, _kmc, _kmcaddr --
# because something in the kernel references the KMC11B whether or not the
# config declares one.  A configured-but-absent device is exactly what
# autoconfig is for: V10 probes at boot, finds nothing at 0760200, and carries
# on.  alice.m's own line, restored verbatim.
kmc11b 0 ub 0	reg 0760200	vec 0600

# The DN11 autodialer, on the same argument -- research.m's own line.
dn11 0	ub 0	reg 0775200	vec 0430

# AND THE DR-11C, WHICH IS NOT A DEVICE WE WANT BUT ONE THE OTHERS NEED.
# `lsys/io/drbit.c' says so in its own header: "The routines in this driver are
# not called through the normal device interface.  Instead, they are available
# for other device drivers to use to send arbitrary information out on a
# DR-11C."  So configuring hp, te16 or dn pulls drbit.y into the link, and it
# then wants _drcnt, _drreg and _draddr -- which mkconf emits only for a
# CONFIGURED device.  The link's own words:
#
#	Undefined:
#	_drcnt
#	_drreg
#	_draddr
#
# Exactly the kmc11b case above, one device along, and the same answer:
# configured-but-absent, so autoconfig probes 0767570, finds nothing, and
# carries on.  research.m's and ssor.m's own line, verbatim.  `devs' gives it
# no vector (`drbit dr ub vec 0 data caddr_t drreg'), so neither does this.
drbit 0	ub 0	reg 0767570

kdi	1
drum	0
console	0
starcons 0
mem	0
stdio	0

# STREAM PIPES.  V8's /dev/pt/pt00..pt63 are these, not pseudo-ttys, so 64
# is V8's own number.  spopen() rejects a minor above spcnt.
pt	64

ttyld	128
nttyld	32
mesgld	256
rmesgld	0
cmcld	0
dkpld	256
cdkpld	0
connld	0
bufld	32

regfs	20
procfs	0
msfs	0
errfs	0
pipefs	0

#
# THE TWO LINES THIS CONFIG EXISTS FOR.  Instances, not merely types.
#
netafs	4
netbfs	4

#
# internet stuff -- alice's own numbers
#
ip	4
udp	16
tcp	96
arp	4
ipld	0
udpld	0
tcpld	0
