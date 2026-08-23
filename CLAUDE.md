# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

**ipnx** runs Research Unix under full-system emulation as a native iPad/Mac app. Two
interpreters and a wire, mirroring the 1985 topology: open-simh's `vax780` executes the
VAX, `dmd_core` executes a DMD 5620 terminal's WE32100, and a DZ11 connects them.

Two tracks run in parallel:

- **Track A — Eighth Edition (1985), shipping.** The app plus a golden disk built from
  this repository's own V8 source (`v8/`).
- **Track B — Tenth Edition (1989), restoration.** Building a bootable V10 disk from the
  TUHS tapes, compiled by V10 itself. `v10tapes/` is the tape, `v10superset/` the
  corpus, `v10/` the distribution and working copy.

`README.md` is the public overview, `RESEARCH.md` is the frozen feasibility study (evidence,
not a living doc), `docs/architecture.md` is the living spec.

## Commands

### App and cores

```bash
libsimh/build-xcframework.sh
```

```bash
libdmd/build-xcframework.sh
```

```bash
cd app && xcodebuild -project ipnx.xcodeproj -scheme ipnx -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build
```

```bash
cd app && xcodebuild -project ipnx.xcodeproj -scheme ipnxMac -destination 'platform=macOS,arch=arm64' build
```

The app build's only media prerequisite — unpacks the committed golden:

```bash
tar -xSjf image/ipnx-v8-rp07.img.tar.bz2 -C work/myv8
```

Is the app you would launch right now the latest?

```bash
tools/app-check.sh --full
```

### Track A — the V8 disk

Stages 4–8 against a build filesystem that already has 1–3 (`work/rp06build`). Use
`tools/drive-stage1.sh` instead when the toolchain, libc or the fixpoint changed:

```bash
bash tools/drive-stages48.sh "" "" 4 8 rp07ref rp07
```

```bash
tools/verify-golden.sh          # content-only, no VAX, about a second
IMG=rp07new tools/boot-newdisk.sh   # boot end to end, 13 assertions, clean halt
bash tools/net-selftest.sh rp07new  # asserts TRAFFIC, not config
python3 tools/v8fs.py sum work/myv8/rp07new   # read a V8 filesystem host-side
```

### Track B — the V10 build

```bash
python3 tools/v10-tree.py       # what have WE changed since the tapes?
python3 tools/v10-check.py      # validate the superset, independently
python3 tools/v10-plan.py       # regenerate docs/v10-plan.md  (--check, --gaps)
```

One stage per run — each depends on the last, and running them together hides which failed:

```bash
bash tools/v10-build.sh 1                    # stage 1 also makes the blank disk
bash tools/v10-build.sh 6 '/bin/sh'          # optional glob: one row, two minutes
```

```bash
expect tools/v10-tryboot.exp work/v10gold/v10-golden.img
```

`tools/v10-dryrun.sh` exercises the driver with `spawn` stubbed — no simulator.

## The V10 source: three trees, and each answers a different question

| | | |
|---|---|---|
| `v10tapes/` | **gitignored** | the six archives, pristine, one root each. Re-extractable; `MANIFEST` has a hash per file. Never edited. |
| `v10superset/` | **committed** | a **corpus** — everything the six tapes hold, merged by rule, in whatever shape the tapes were cut. Validated, not shaped. |
| `v10/` | **committed** | a **filesystem** — what a running machine sees. `/usr/src/cmd`, `/usr/man`, `/usr/include`. **Our working copy**, edited directly. |

`v10superset` is *not* shape-identical to any V10 distribution: its roots are tape
roots — `cmd`, `man`, `jerq`, `630` side by side — and no Tenth Edition machine ever
looked like that. It exists so nothing is lost and so a question about the tapes has
an answer. `v10/` is the distribution, laid out to mirror the guest exactly as `v8/`
does, so `v10/usr/src/cmd/ls.c` is what the machine has at `/usr/src/cmd/ls.c`.

**There is no patch directory and no `OVERLAY` file.** Git keeps that record, and
keeps it honestly. The previous arrangement kept corrections in `v10/src` with a
hand-maintained manifest, and eleven files of pure **configuration** — a motd, a
hostname, an `/etc` — sat there indistinguishable from genuine repairs for as long
as nobody diffed it.

```bash
bash tools/v10-tapes.sh          # six archives -> v10tapes/, pristine
python3 tools/v10-tree.py --bootstrap   # v10tapes/ -> v10superset/  (DESTRUCTIVE)
python3 tools/v10-check.py       # validate the superset, independently
python3 tools/v10-dist.py        # v10superset/ -> v10/  (DESTRUCTIVE)
```

Both `--bootstrap` and `v10-dist.py` **delete their output tree**, so neither is a
default and neither is quiet. `v10-tree.py` with no arguments prints what we have
changed since the tapes.

### How the superset is chosen

`secombe` is the base — of 13,360 paths shared with `norman`, **13,300 are
byte-identical, 60 are newer in secombe and none is newer in norman** — and `norman`
augments it with 10,612 paths secombe does not carry. Where bytes differ the newer
mtime wins; every contested path is listed with dates in
[docs/v10-tree.md](docs/v10-tree.md). Excluded: `history/ix` (877 files — IX is a
different operating system) and one duplicate name.

### How the distribution is placed

Only two kinds of evidence are allowed, recorded per tree in
[docs/v10-dist.md](docs/v10-dist.md):

1. **A file that names its own path.** `cmd/Admin/dest` opens
   `DIR=/usr/src/cmd/Admin`, settling `cmd` and with it both `/usr/src` tapes.
   `cmd/map/export/mapdata` is a symlink to `/usr/maps`. jerq's sources name
   `/usr/jerq/include` 196 times.
2. **`srctotape`** — the tape's own manifest of what `/usr/src` contains.

**Counting references does not settle a source directory**: `/usr/games/hack` is
where hack is *installed* while its source is `/usr/src/games/hack`, so both strings
appear everywhere and the installed one wins on volume. Good evidence for a
self-contained tree that names itself; misleading for anything built and installed
elsewhere.

Anything not settled by that evidence **stays in `v10superset`** — `blit`, `lsys`,
`vol2`, `dk` and seven more, each with its reason in the report. `v10-dist.py`
refuses to run if a directory is neither placed nor explained.

### Case collisions and archives

Two rules, applied per path component and to directories as well as files:

- **Two files collide** — the all-lowercase spelling keeps the name, the others take
  `u_` in front of their own: `makefile`/`u_Makefile`, `junk`/`u_Junk/`.
- **One inode under two names** — `games/sail/makefile` is a hard link to `Makefile`
  — one name is kept, the commoner spelling *by count across all six tapes*
  (`v10tapes/HARDLINKS`).

The merge creates collisions neither tape had alone (secombe `ipc/bin/Con`, norman
`ipc/bin/con`), so the rule applies to the merged tree too, and the contest runs on
**tape paths** — otherwise the extractor's renaming and the merge's renaming compound
and overwrite each other. Archives collide internally too: `cmd/awk/test.a` holds
both `T.getline` and `t.getline`.

An archive is found **by its magic number**, never its name — `!<arch>\n` in the
first eight bytes. The host's `ar` is not used: macOS's exits **zero** having
extracted nothing from the SysV/COFF archives under `630/`, so `630/lib/libc.a`
became an empty directory and sixty members vanished silently. Headers are parsed
directly, handling BSD (`__.SYMDEF`, inline long names) and SysV (`/`, `//`,
`/offset`) alike.

## Architecture

The app shell is deliberately **edition-agnostic**: it knows about *machines* (a simulator
+ a disk image + a wiring), not about editions, so V10 arrives as just another image.

- `app/` — one Swift/SwiftUI source folder, two targets (`ipnx` iPad, `ipnxMac`). Platform
  differences go behind `#if os(macOS)` and the `PlatformViewRepresentable` shim in
  `Platform.swift`, never a forked file. Both xcframeworks' Swift modules are declared in
  `app/ipnx/Modules/module.modulemap` — two frameworks cannot each bundle one (flat
  `include/` collision).
- `libsimh/` — open-simh as a C static library. No async, no network, no SDL.
- `libdmd/` — dmd_core as a Rust staticlib via its **built-in** C FFI. Never wrap it in
  another crate; the unmangled exports collide. Extend via logged patch.
- `netfs/` — a Swift host-side server (`swift build -c release`) serving a directory to the
  guest over the Interlan, so V10 builds read source from the repository live.
- `v8/` — the Eighth Edition source tree the golden is built from; `v8/mk/*.sh` are the
  stage scripts, `v8/RELEASE` is the single source of truth for the version.
- `v10tapes/` — the six archives, pristine. `v10superset/` — the corpus. `v10/` — the
  distribution and our working copy. See above.

## The rule that outranks everything else

**Never leave a machine inconsistent. A machine that was not cleanly halted has a corrupted
disk — assume it.**

```
cd /; sync; sync
/etc/halt
```

Wait for the marker, *then* `quit`. V8 prints `halting`; **V10 prints `death`** and its
kernel does not sync on halt — `lsys/md/machdep.c`'s `boot()` is two lines, so the userland
sync is the whole flush. V10 also records in the superblock that a filesystem is mounted, so
halting without `/etc/umount -a` makes the next boot answer `In use` and carry on with an
empty `/usr` showing through, reporting nothing.

Never `pkill` a `vax780`, and never delete a `state.sav` while keeping its disk — snapshot
and disk are consistent only as a pair.

`fsck` restores metadata *consistency*, not data. Several of its repairs destroy data by
design. A clean pass is not evidence anything survived; a hash against a known-good artefact
is. That is why `image/ipnx-v8-rp07.img.tar.bz2` is committed.

**Run every guest harness against a clone, never the golden.** Booting mounts, and mounting
rewrites the superblock, so a clean successful run still changes the hash. `tools/v8clone.sh`
exists because stating this was not enough — three harnesses defaulted to booting the golden
and one moved it while every assertion passed.

**Two simulators must never run at once** (`tools/norun.sh`, `tools/norun.exp`). Match the
process *name*: `pgrep -f vax780` matches the waiter's own arguments and reads 2 with one
simulator running.

## Track B: what the tape teaches that no single file shows

- **The tape states its own build.** `src/cmd/Admin/Mk` is the command build system (five
  suffixes; `Admin/dest` gives the install path from `binfiles`/`etcfiles`/`libfiles`/
  `ulibfiles`; `Admin/large` names the 27 programs compiled `-O` not `-Od2`).
  `lsys/lib/mk.star` is the kernel recipe and `lsys/astro/mk.out` is the tape's own
  *transcript* of it running for thirteen machines. Read those before inferring.
- **No inheritance.** `cmd/cc.c:9-11` hardcodes `as="/bin/as"`, `ld="/bin/ld"`,
  `crt0="/lib/crt0.o"`, and `-B` reaches only ccom, c2 and cpp — V10's cc has three `-t`
  letters where V8's has six. `cmd/ld.c:1579-1595` hardcodes `-lX` to `/lib`, then
  `/usr/lib`, then `/usr/local/lib`, with no `-L`. So a build that links through `cc` and
  passes `-l` uses the *builder's* assembler, linker, crt0 and libc whatever `-B` says. The
  build calls `ld` directly with absolute paths instead — which is how the tape links the
  kernel.
- **An object file is not evidence a compiler ran.** Without `-O` this compiler emits a bare
  36-byte a.out header and exits 0, and `test -s` cannot tell that from a real object.
- **`ar cr` accepts object names that do not exist**, and `ranlib` blesses the result. Assert
  member counts, never "an archive appeared".
- **V10's `ld` writes its output even with symbols undefined** — it reports them and clears
  the execute bits. Ask `ld` what it said; do not test for the file.
- **Archive member order is not derivable from a directory.** `v10-tree.py` unpacks every
  `ar` member as a file, which keeps every byte and destroys the order; V10's `ld` makes one
  sequential pass without a current `__.SYMDEF`. `ORDER` files beside the members carry it.
- **A `.a` is not evidence of a link library.** `ar` was the ordinary way to package any file
  set: `tek.c.a` holds `.c` files, `libdbm.a` is a bare object, `crlib` is an archive with no
  `.a` at all. Sniff the first 512 bytes.
- **The build is in-tree.** V10's cpp cannot resolve a quoted include for an out-of-tree
  source and `-I` does not help.
- **On V10 `ls` exits 0 for a file that is not there.** Assert with `test -b`/`test -c`/
  `test -s`.
- **1970s `sh` forks for a compound command carrying an input redirection**, so a counter
  assigned inside `while read ... done < file` is lost in a dead child. Tally into files.
  `IFS='|'` on the `read` also persists into the loop body, which stops the shell splitting
  on space and expands a command held in a variable to one word.

## Conventions

- Big binaries never enter git. The exception is `image/*.tar.bz2` — the disks we build,
  because each is the *input* to the next build. Both `.gitignore` and
  `tools/hook-block-binaries.sh` un-block that one path; raw `*.img` stays blocked so the
  packed form is the only way in.
- **Unpack a disk with `tar -xSjf`, never without the `S`.** It is the only standard format
  that restores a *hole*: the zero runs come back as holes rather than allocated blocks, so
  the 1.9 GB RA73 costs its non-zero bytes on disk. Measured — a dense 100 MB of zeros
  restores to 0 B. zip cannot do this and neither can xz, and both were tried here first.
  `tools/v10-reset.sh` restores `images/v10` and `images/v10-golden` that way.
- V10 must stay authentic. A deviation is allowed only where the tape cannot run as-is, and
  then it is a commit with a stated reason — never a file a harness writes inline, and never
  configuration or branding invented here. `python3 tools/v10-tree.py` is where that
  discipline is checked: it prints every file we have changed, added or removed.
- A component list that appears twice will disagree. The plan is the only list the build
  reads.
- Every guest harness matches output **markers**, not shell prompts: a prompt repeats, and
  the tty splices what you type into whatever is already printing. Spell markers through a
  shell variable (`echo PE''ND`) so the tty's echo of the command line does not answer the
  question the driver is asking.
- Cite primary sources (TUHS preferred) for factual claims in docs.
- **VERIFY** marks a documented step assembled from research but not executed here.
  Resolving one means executing it and correcting the doc, or recording that it was
  superseded — never silently deleting the marker.
- Track B keeps a dated lab notebook in `docs/v10-log/`.

## Current state (2026-08-23)

Track A ships. Track B reached a login prompt at `d4c9fb97`, then that result was found to
be non-vanilla and the build was rewritten:

- `v10/mk/build.sh` rewritten from scratch with no inheritance from the builder.
- The kernel banner now comes from the tape's own rule (`mk.star:8-10`, a date), replacing an
  invented `Unix 10e ipnx 780`.
- The V10 source tree was rebuilt from scratch: `v10tapes/` (pristine, gitignored) and
  `v10/` (the superset, committed, our working copy). Eleven customised `/etc` files and the
  old `v10/src` overlay are gone; our patches are parked in `work/v10-preserved/` and have
  **not** been reapplied, so `v10/` currently reports zero deviations from the tapes.
- The kernel config `ipnx780.m` is retained deliberately: of the seventeen configs in
  `lsys/astro`, alice is the only 780, but its root is behind a UDA50 at `0772160` while
  `lsys/boot/star/uda.s:157` (`udareg: .long 0772150, 0772160`) makes the ROM's controller 0
  the standard `0772150`. The boot disk selection itself is unchanged from alice.

**The rewritten build has not been run.** Known open items: stage 3 (fixpoint) has 0 rows;
stage 8 (manuals) has never executed; `docs/v10-plan.md` carries 328 phantom `/usr/bin` rows
generated from `cmd/lcc/ph`, which is lcc's cpp *test suite*; stage 4 builds 13 libraries
while stage 6 requests around 20; lcc is not yet built as the second compiler, though the
tape's own build is mixed per file.

`.claude/` and the previous `CLAUDE.md` were set aside this session as `xx.claude/` and
`xxCLAUDE.md` — so the repository's hooks, skills and subagents are currently not installed.
