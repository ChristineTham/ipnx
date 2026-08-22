# Bootstrapping a Tenth Edition golden image from a clean checkout

Every step, in order, from `git clone` to a bootable `v10-golden.img`.  Each
row names the tool that does it, what it consumes, what it produces, and how
the result is checked.  Nothing here is a phase number: the K labels were
experiments, and an experiment label is not a build stage.

## What a clean checkout has, and nothing else

	work/v10src.tar.bz2        TUHS      the Tenth Edition source tape
	work/v10blit.tar.bz2       TUHS      the terminal distribution
	work/r70include.tar        TUHS      V10's /usr/include, reconstructed 1997
	v10/ tools/ netfs/ libsimh/  repo    generators, harnesses, the emulator

**There is no Eighth Edition in this procedure.**  This is a V10 bootstrap: the
tape is the only source of bytes, and every stage after the first runs on V10
itself.

## The one problem a V10 bootstrap has to solve

TUHS ships V10 as three tarballs.  **No bootable V10 media survived** — that is
what this project exists to fix — so there is nothing to boot, and therefore
nothing that can write the first V10 filesystem.

An earlier version of this plan solved that by booting the Eighth Edition and
letting it host the assembly, on the strength of V10's binaries running on a V8
kernel.  That works and it is not a bootstrap: it makes a V10 disk a function of
a V8 disk.

**The first disk is built on the host, from the tape.**  `tools/v10fs.py`
already reads a V10 filesystem well enough to extract nine binaries
byte-identical to the tape's own copies — through `itod`, `itoo`, the vax arm of
`l3tol`, the 3-versus-4-byte address split, `NADDR`, `NSHIFT` and `NMASK`, all
of which must be right at once for `as` at 57,203 bytes to come out whole.
Writing is that format inverted.

**The circularity this avoids is real and is named in CLAUDE.md**: a reader used
to build a tree *and* to bless it approves its own mistakes.  So the writer is
never the judge — **the boot is**.  If a single field is wrong, V10's kernel
does not mount the disk.

---

## Stage 0 — materialise the inputs

	tools/v10-import.py               ->  work/v10/               15 s
	libsimh/build-xcframework.sh      ->  work/opensimh/BIN/vax780
	( cd netfs && swift build -c release )

`work/v10/` is **the master**: `src/` from v10src, `blit/` from v10blit,
`include/` from r70include, with `CASEMAP` recording the 373 paths that differ
from another only by case.  `--verify` re-checks every hash.

**Check:** `tools/v10-import.py --verify` re-checks every hash in ~15 s.

## Stage 1 — the generators (host-side, seconds, all have `--check`)

Nothing here boots anything.  These turn the master into build description.

	tools/v10-where.py        install paths, from V10's manual and its makefiles
	tools/v10-overlay.py      v10/src/ -- our named patches, each with a reason
	tools/v10-world.py --write  world.{units,link,prog,script,alias,gen,drop}
	tools/v10-libs.py --write   which library holds which member
	tools/v10-prebuilt.py     prebuilt.txt -- the 57 oracle binaries
	tools/v10-tapebins.py     tapebins.txt -- ALL 435 linked binaries
	tools/v10-proto.py        proto-dev -- 463 device nodes
	tools/v10-uda750.py       the boot ROM
	v10/mk/mkdep.py           the makefiles V10 never had

**Check:** every one takes `--check` and fails on drift.  A stage that boots a
machine refuses to start if any of these is stale.

## Stage 2 — `v10-reference.img`: the first V10 disk, built on the host

	tools/v10-mkfs.py                                          seconds

NEW, and the only genuinely new tool this plan needs.  It writes a V10
filesystem directly into an image file, using the constants `tools/v10fs.py`
already reads with: `lsys/sys/ino.h` (64-byte dinode), `lsys/sys/dir.h`
(DIRSIZ 14, so 16 bytes), `NADDR` 13, `itod`/`itoo`, `fsbtodb = b*8`, and
`cmd/mkbitfs.c` for the free-block bitmap.

Two filesystems, at the offsets `lsys/io/ra.c` gives **in sectors**:

	a   10240 sectors at      0    5 MB   root
	b   20480 sectors at  10240   10 MB   swap
	c  249848 sectors at  30720  122 MB   /usr

Installed: the tape's boot block (`lsys/boot/star/uda`), the tape's own kernel,
**all 435 linked binaries** from `tapebins.txt`, r70's headers, `/dev` from
`proto-dev`, and `/etc` config.

**Check, and it is the load-bearing one in this whole procedure:** boot it.  It
must reach `login:` and run a copied binary.  A filesystem written by a tool
nobody has exercised is a guess until a 1990 kernel mounts it — and V10's
`iinit` panics rather than limping, so the check cannot pass by accident.

## Stage 3 — the toolchain: V10 compiles its own C

	tools/v10-stage1.sh      yacc cpp ccom as c2 ld cc, ar cmp tail ed ln
	tools/v10-stage2.sh      libc -- 260 of 261 members
	tools/v10-stage3.sh      the fixpoint: stage 3 rebuilds itself byte-identical

Stage 1 matters for one reason: the tape's `cpp`, `c2` and `ld` have no binary,
so they must be built — and until this runs, they were built by *V8's* cc.
After it, no binary on the machine was built by the Eighth Edition.

`setupshares` is a **named exclusion** (`LIBC_DROP`), not a shortfall:
`<sys/share.h>` is printed nowhere and reconstructible from nothing.

**Check:** stage 3 is self-reproducing — 7 components, each byte-identical to
what its own output builds.

## Stage 4 — the libraries

	tools/v10-libs.sh        26 libraries, 500 members

**Check:** every archive's member list against the manifest, by count, and
`ar t` rather than "an archive appeared" — `ar cr` accepts names that do not
exist and `ranlib` blesses the result.

## Stage 5 — our kernel

	tools/v10-kernel.sh      the ipnx780 config

The tape's `seki` kernel cannot do what the rest of the bootstrap needs: it
configures `netafs 0`/`netbfs 0` and no Interlan.  Ours adds the card, the
netfs stream-head fix, stream pipes (`cdev 18 pt`), and the 780 devices.

**Check:** the link must report **no undefined symbols** — V10's `ld` writes
its output anyway and clears the execute bits, so "a kernel file appeared" is
not evidence.

## Stage 6 — networking, and the machine is finished

	tools/v10-netboot.sh     /dev/il0 /dev/ip6 /dev/ip17, dipconfig,
	                         tcpconfig, nafsmnt, and /etc/rc to bring it up

	==> v10-build.img        THE BUILD MACHINE.  Never written again.

This is the counterpart of V8's `rp07v8.net`.  From here on, a build runs *on*
this machine and writes to a *separate* disk — which is what stops the image
name becoming a changelog.

**Check:** halt, boot again, and mount a share.  A machine that only networks
during the run that configured it is not configured.

## Stage 7 — build the world

	tools/v10-link.sh        compile, link, install to a STAGED ROOT

Every unit under `cmd/ games/ lbin/ dregs/ local/ ipc/`, compiled in-tree
(V10's cpp cannot resolve a quoted include for an out-of-tree source, and `-I`
does not help), linked per the tape's own rules, installed to `/usr/w10`.

Never over the machine's own `/bin` — the 46 prebuilt binaries are the oracle,
and installing over them destroys the only comparison we have.

**Check:** the reported measurement is **how much of the tape we failed to
build, and why**, per unit, with the compiler's own diagnostic.  Not "is it a
superset of V8" — that question invites carrying V8 files to answer it.

## Stage 8 — assemble the golden

	tools/v10-mkdisk.sh      a BLANK disk, filled in provenance order

	1  our build       what V10 compiled from the tape          preferred
	2  the tape        Bell Labs' binary, where we cannot build it
	3  generated       /dev, from proto-dev
	4  config          /etc/ttys /etc/passwd /etc/rc motd -- OURS, and marked

The golden is **binaries and configuration**.  Source ships on a separate disk,
as V10 always mounted it.  `/usr/man` is the tape's own 1,521 files;
`/usr/include` is r70's; the terminal trees come from `blit/` and the master.

**Check:** boot the disk it just built.  Host-side, a manifest naming the rung
for every path.

## Stage 9 — report what the tape did not give us

	python3 tools/v10-unbuilt.py

The bootstrap ends by naming its own gaps: every unit in the master that did
not compile, did not link, or produced nothing to install, with the compiler's
own diagnostic beside it.

**Check:** the list must SHRINK between runs.  A list that grows is the
measurement telling you the build went backwards.

Comparing the result against the Eighth Edition is a **separate question**, and
a legitimate one — it is what `tools/v8v10-diff.py` is for.  It is not part of
this bootstrap, and nothing it reports may be answered by copying a V8 file
onto a V10 disk.

---

## Rules the procedure depends on

- **Run every harness against a clone, never a golden.**  Booting a disk mounts
  it and mounting rewrites the superblock.
- **Two simulators must never run at once.**  `source tools/norun.sh;
  no_other_sims` — running `bash tools/norun.sh` defines functions and exits 0,
  which reads exactly like a pass.
- **Never leave a machine inconsistent.**  `cd /; sync; sync` then the
  edition's own halt; V10's kernel does not sync on halt and V8's does.
- **The simulator is a property of the image.**  `v10_select_machine` reads the
  banner off `/unix`; a 780 kernel on a vax750 panics on hardware that is not
  there.
- **A component list that appears twice will disagree.**  Every list is
  generated once and read, never restated in a harness.

## Naming

Role, edition, one suffix.  No device type, no history in the filename.

	v10-reference.img   built on the host from the tape     (was ipnx-v10-ra81.img)
	v10-build.img       the build machine                   (was …k102.k7.k13)
	v10-golden.img      what we ship                        (was ipnx-v10-made.img)
	v10-source.img      the source disk, mounted separately (was ipnx-v10-src.img)

## Total

Nine stages.  Stages 0 and 1 are host-side and take under a minute.  Stages
2–8 each boot a machine; the long ones are the world build and the assembly.
Every stage is a pure function of the stage before it plus the master, and no
stage edits its input.
