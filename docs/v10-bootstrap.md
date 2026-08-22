# Bootstrapping a Tenth Edition golden image

One pass, from a blank disk to a finished one, with the new image mounted
throughout and every stage installing into it. Stage by stage, file by file.
Every list quoted here is generated and lives in `v10/mk/gen`; this document
names them, it is not their source.

## The three rules

**1. THE SOURCE CONTAINS EVERYTHING NEEDED TO MAKE A GOLDEN.  THERE ARE NO
DEPENDENCIES ANYWHERE ELSE.**

	work/v10             the TUHS tarballs, unpacked and hash-verified,
	                     25,682 files.  Never edited.
	v10/src              our patches and captured files, each derived from
	                     a named upstream file with a stated sha256.
	v10/mk, v10/mk/gen   the build description, generated, all --check.

Not the builder's filesystem, not the Eighth Edition, not a previous golden,
not a file a harness writes inline.

**2. THERE IS NO STAGING TREE.  THE BUILD INSTALLS INTO THE NEW IMAGE.**

The new disk is mounted for the whole run and `$(DESTDIR)` is that mount. The
generated makefiles already work this way:

	init.mk    install:  -mkdir $(DESTDIR)/etc ; cp init $(DESTDIR)/etc/init
	ls.mk      install:  -mkdir $(DESTDIR)/bin ; cp ls   $(DESTDIR)/bin/ls
	worldc.sh  DEST=$7   ... if test -d $DEST$pdest ; cp $prog $DEST$pdest/

Nothing is built somewhere and copied afterwards, so there is no second step in
which provenance can be lost. `/usr/w10` stops existing: a staged root is what
made 33 files arrive on a disk without anyone choosing them.

**3. AND THE NEW TOOLCHAIN RUNS ON THE NEW IMAGE.**

Once stage 1 has installed the passes into the mounted image, stage 2 compiles
with *those* — `cc -B$MNT/lib/` — not with the builder's. By stage 3 the image
is compiling itself. The builder supplies a running kernel and nothing else;
every byte on the finished disk was put there by a tool that was already on it
or by the tape.

---

## Stage 0 — materialise

	tools/v10-import.py        work/v10/  <- v10src, v10blit, r70include
	                           25,682 files; --verify re-checks every hash

## Stage 1 — mount the blank, install the toolchain into it

	blank         sparse:  dd if=/dev/zero of=IMG bs=1 count=0 seek=456228864
	              NOT count=891072, which allocates 456 MB of real zeros
	filesystems   V10's own /etc/mkbitfs, run from the builder
	                root  1,280 blocks on partition a   (ra_sizes, in SECTORS)
	                /usr 30,752 blocks on partition c   (= MAXSMALL)
	mount         $MNT -- and it stays mounted for the whole pass

V10's own `ccom`, `as` and `libc.a` are on the tape as linked VAX binaries and
run on a V8 kernel (`tools/v10-probe.sh`, 9/9), so only the passes with no
binary must be built. **`tc.order`** — 7 components; the third column is the
install path *inside the new image*:

	yacc    cmd/yacc          usr/bin/yacc
	cpp     cmd/cpp           lib/cpp
	ccom    cmd/ccom/vax      lib/ccom
	as      cmd/as            bin/as
	c2      cmd/c2            lib/c2
	ld      cmd               bin/ld
	cc      cmd               bin/cc

**`buildtools.ord`** — 4 more, because stage 2 *is* an archive and stage 3 *is*
a byte comparison, and neither tool is on the golden:

	ar   cmd  bin/ar      cmp  cmd  bin/cmp
	tail cmd  usr/bin/tail  ed cmd  bin/ed

**`shutdown.order`** — 2, because a machine that cannot halt cleanly corrupts
its disk:

	halt cmd  etc/halt    sleep cmd usr/bin/sleep

At the end of this stage the new image has a compiler.

## Stage 2 — libc, compiled by the image's own passes

	cc -B$MNT/lib/ -t02p        the passes stage 1 just installed

**`libc.ord`** — 260 members in the tape's own archive order, read off Bell
Labs' `libc.a` rather than recomputed, because the golden has neither `lorder`
nor `tsort`. The makefile builds from `$(OBJS)` in that order, not `ar cr
libc.a *.o`, which is the shell's alphabetical glob and a different archive.

**`libc.drop`** — one named exclusion:

	setupshares.o

`<sys/share.h>`'s `struct sh_consts` is printed in no manual page and referenced
in neither kernel tree, and `L_GETCOSTS` has the *kernel* write through that
pointer, so a guessed size corrupts the caller's stack. `libc_from_tape()` still
asserts all 261 against the archive and the mkfile: subtracted, not hidden.

It was excluded for a second reason worth keeping — three stage-2 assertions
were gated on it and could **never** pass, and a check that cannot pass is
camouflage. A permanently-NO line is what a missing `atof.o` hid behind for a
week.

**One compiler, and that is the work.** Measured over all 261:

	cc alone                        246 of 261
	lcc alone                       202 of 261
	cc + lcc, the tape's mixture    246 of 261
	cc alone, after the repairs     260 of 261    <- what we build

`LIBC_LCC` is empty. lcc must not be reinstated to close a member: its prebuilt
driver passes `-undef` to a cpp that rejects it, so those members become empty
objects that exit 0 — a loud failure beats a silent hole. Two limits found on
the way, neither a compiler problem: `<shares.h>` exists on no surviving machine
and was reconstructed from the tape's own `lnode(5)` then checked against Bell
Labs' object code; and `stdio/iolib.h` has no branch for a V10 VAX, so nine
printf/scanf members failed under *both* compilers and are named patches.

Two installs, and the distinction is load-bearing: `$(TOOLDIR)/lib/libc.a` is
what the compiler links against while the pass runs; `$(DESTDIR)/lib/libc.a` is
what ships.

## Stage 3 — rebuild the toolchain on the new libc

The test the whole bootstrap exists to pass, and now it happens **on the image**:
stage 3 compiles `tc.order`'s seven components with the image's own passes
against the image's own libc, and stage 3b compiles them again with stage 3's
output. Each must be byte-identical to what its own output built.

	components reproducing themselves    7
	components that do not               0

7 differ / 0 same against stage 1 is the expected result, not a failure: stage 1
linked the tape's archive and stage 3 links ours.

After this the image is self-hosting. Nothing later needs the builder's tools.

## Stage 4 — the libraries

**`libs.txt`** — 27 rows, one per library, with member counts:

	libF77 113   libI77 33   libcbt 8   libcc 4   libcurses 35   libdbm 1 ...
	500 members across 26 archives; libc is stage 2's

Installed into `$(DESTDIR)/usr/lib` under every `-l` name each answers to.
`libl.a`/`libln.a` and `libtermcap.a`/`libtermlib.a` are one archive under two
names, which the tape itself does.

## Stage 5 — the kernel

Our `ipnx780` config: the Interlan, the netfs stream-head fix, stream pipes
(`cdev 18 pt`), the 780 devices. `kobj.order`'s fourth column says whether an
object comes from `v10/src` or from the tape's archives — they read from
different roots.

The link must report **no undefined symbols**: V10's `ld` writes its output
anyway and clears the execute bits, so "a kernel file appeared" is not evidence.

`/unix` goes down **first** among the image's files — `lsys/boot/README` requires
it in the filesystem at the front of the boot device, at most singly indirect.

## Stage 6 — the world

	world.units   427     world.link    349     world.prog   206
	world.script   45     world.alias    22     world.drop  (what is not built,
	                                                         and why)

Compiled in-tree, because V10's cpp cannot resolve a quoted include for an
out-of-tree source and `-I` does not help. `worldc.sh` takes the destination as
its seventh argument, so this installs into the mounted image directly.

`bootpath.order` (24) and `disktools.ord` (7) name what has to be present for
the disk to boot and for a machine to build the next one:

	init getty login mount umount mkfs fsck icheck sync date stty cat
	cp mv rm mkdir echo find chmod ls cpio grep wc ln

## Stage 7 — the tape's own files, and the tables

	tapebins.txt  428 linked binaries the tape ships, at their install paths
	              7 ix binaries excluded with reasons: ix is a DIFFERENT
	              operating system built on V10, and its own README says the
	              tree is "shorn of most material that may be copied bodily
	              from research unix"
	man           the tape's 1,521 manual files
	include       r70's headers
	blit          the tape's own terminal distribution, 1,369 files
	proto-dev     463 device nodes, generated from the tape's lsys/lib/tab
	proto-etc     9 files, content in v10/src/etc:
	                passwd group ttys rc motd fstab mtab utmp profile
	              mtab and utmp ship EMPTY -- a fresh system has nothing
	              mounted and nobody logged in
	boot block    dd if=lsys/boot/bb/4kb of=IMG bs=512 count=1 conv=notrunc
	              host-side, after the guest halts; guest-side writes fail

`/etc/fstab` is in **V10's colon format** — `/dev/ra0a:/:rw:1:1`. It was
tab-separated, which is the Eighth Edition's, and V10's `getfsent` splits on
`:`. Almost nothing notices, because `/etc/rc` mounts `/usr` by explicit path
and never reads fstab; the one caller that does is `df`'s root lookup, which
prints `": can't find filesystem"` against a perfectly healthy root.

## Stage 8 — verify

`tools/v10-manifest.py` against the finished disk. **Any file whose only source
is the builder is a build failure**, not a note. That check would have caught
the V8-format `fstab`, the duplicate `mtab` records and the ix binaries the
first time, because none of the three was ever chosen.

## Stage 9 — the Eighth Edition — NOT DONE

Nothing is carried from V8. The extraction that pulled `/jerq`, `/net` and
`/dict` off `work/myv8/rp07new` at build time is removed, with the netfs share
that served it.

So a disk built now ships **no `/usr/jerq`**, and V10's own `mux` — which this
build compiles, IX excised — fails at `_32ld("/usr/jerq/lib/muxterm")`. That is
the honest state. The V10 tape has no 5620 userland and no `3cc`, measured:

	src/630/src/muxterm   WE32100 COFF 0560, but its .data holds 1024x768
	                      twice, no 800x1024, no Bitmap at 0x700000 -- the
	                      630 MTG's, a different terminal
	blit/                 68000, magic 0407
	history/ix/src/jerq   76 files, host side only, and IX besides
	3cc 3as 3ld           absent; documented in man9/3cc.9, shipped nowhere

V8 has both in source — `jerq/src` 777 files, `jerq/sgs` 272 — so the rule says
build them, and that is a phase of its own: the SGS has never been compiled by
anyone, and V8's own build carries 366 jerq files rather than building them.

When stage 9 happens the files are **captured into `v10/src`** with their
provenance, not read off an image at build time.

---

## What the last measurement found

`tools/v10-manifest.py` against the disk built before these rules — 6,025 files,
by the source whose bytes they match:

	tape                    3,029        builder + tape          431
	tape + v8                 774        staged root             276
	v8                      1,308        BUILDER ONLY             33
	builder+tape+v8            93        written by the build      5
	builder+scratch+…          72        overlay/stage1/scratch    4

The 33 were 26 libraries plus `/bin/ld`, `/lib/ld`, `/lib/cpp`, `/lib/crt0.o`
and `/lib/libc.a` — each one something a phase had built and installed into the
*builder*, which the disk build then scooped up. Installing into `$(DESTDIR)`
removes the category entirely; there is nothing left to adjudicate.

The 5 written by the build were `/etc/motd`, `rc`, `ttys`, `utmp`, `whoami` —
the only files whose bytes existed nowhere else, so they could not be reviewed,
diffed or regenerated. They are now in `v10/src/etc`.

## Two hazards the geometry imposes

**Source does not fit beside `/usr`.** `ra_sizes[]`, in 512-byte sectors:

	a  0       .. 10,240    root       d  280,568 .. 530,416   128 MB
	b  10,240  .. 30,720    swap       e  530,416 .. 780,264   128 MB
	c  30,720  .. 280,568   /usr       g  30,720  .. 780,264   CONTAINS c
	                                   h  0       .. 891,072   CONTAINS a,b,c

`d` and `e` are the only partitions that do not overlap `c`, 128 MB each and not
joinable, against 243 MB of source. So source ships on a second spindle:
`tools/v10-srcdisk10.sh`, whole-drive partition h, 111,384 blocks, with the
tape's `src/` at the top so it mounts as `/usr/src` holding `cmd/` and `lsys/`
directly — not `/usr/src/src`.

`h` is safe there and not on a boot disk: a whole-drive filesystem contains
partition `b`, so `swap ra 01 20480` writes swap through blocks 10,240–30,720 of
live data. The source disk is `rq1`, carries no swap and is never booted.

**The builder must never write to the golden's path.** `v10-mkdisk.sh` line 24
was `BLANK=…/ipnx-v10-made.img` — the golden's own path — and `rm -f "$BLANK"`
plus a `dd` run before the guest does anything. A run killed a minute in on
2026-08-22 left a partial disk where the golden was, and because no V10 image
had ever been committed there was no way back. Cloning does not help: the clone
rule protects an image from a *boot*; this was destroyed by output redirection.
