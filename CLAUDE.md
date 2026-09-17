# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Bell Labs Research Unix booted on an emulated VAX-11/780 inside one native iPadOS/macOS
app, displayed through an emulated DMD 5620 terminal. Two editions: **V8 ships** (the disk
is built from this repo's own source), **V10 is a restoration** (no boot media ever
existed; the tree now builds itself, kernel included).

The repository is four things at once, and confusing them is the main way to get lost:

1. a **Swift app** (`app/`) plus two emulator cores wrapped as xcframeworks (`libsimh/`, `libdmd/`);
2. two **Research Unix source trees** (`v8/`, `v10/`) that are *ours* — edited directly, not vendored, not carried as patch files;
3. **host-side build and test machinery** (`tools/`, `mk/`, `netfs/`) that drives a guest over a serial console;
4. a **website** (`website/`) and release tooling.

`README.md` is the project's own account of itself; `docs/` is the living detail
(`architecture.md`, `v10-build.md`, `golden-disk.md`,
`build-from-source.md`); `RESEARCH.md` is frozen evidence, not a living doc.

## Layout worth knowing before you touch anything

| Path | What it actually is |
|---|---|
| `app/ipnx/` | One Swift/SwiftUI source folder, two targets: `ipnx` (iPadOS) and `ipnxMac`. Every file is shared. |
| `libsimh/` | CMake wrapper turning an open-simh checkout into `SimhVAX.xcframework`. `patches/` adds the Interlan NI1010 driver and three `UNIT_IDLE` flags. Deliberately built **without** `SIM_ASYNCH_IO`. |
| `libdmd/` | dmd_core (Rust) → `DmdCore.xcframework`. Patches live in `tools/dmdbridge/patches/`. |
| `netfs/` | SwiftPM host half of Weinberger's netfs. The `NetFS` target compiles into *both* `netfsd` and the app (`FileShare.swift`), so it may never grow a Mac-only dependency. |
| `v8/` | Our V8 tree, laid out as the guest filesystem (`v8/usr/src/cmd/ls.c` is `/usr/src/cmd/ls.c`). `v8/mk/` is ours — V8 never had a world build. |
| `v10/` | The V10 working tree: the machine's own `/usr`, guest-shaped. The build system is `v10/usr/src/build/`. The six TUHS tapes and any tree reconstructed from them are **not** committed — the machine assembles them itself (`mkv10`). |
| `mk/mkgen.py` | The edition-agnostic half of the makefile generator. The per-edition knowledge (component tables, install layout, exceptions) stays in `v8/mk/mkdep.py`. |
| `tools/` | Host harnesses and probes. `*.exp` drive a guest over the console; `*.sh` wrap them with the guards. |
| `image/` | The only committed binaries: four bzip2 tars. `*.tar.bz2` go through **Git LFS** (`git lfs pull`, or `tar` says `not a bzip2 file`); the V10 golden is committed in halves `.aa`/`.ab`, which the LFS filter does not match. |
| `image/` | The **current working V10 image** and the committed `.tar.bz2` archives beside it. Everything but the archives and this README is gitignored. |
| `images/` | The **V10 golden**, restored from the halves in `image/`. Plural on purpose; not the same directory. |
| `v10tapes/` | Scratch: the six TUHS archives as plain `tar`, gitignored, **needed by nothing**. `mkv10` reads them once ever and `v10/` is the committed result, so delete the directory when the bootstrap is done. The host never unpacks one. |
| `work/` | V8's gitignored workbench — `work/myv8` (the golden and its build filesystems) and `work/opensimh` (the desktop simulator). |

## Commands

### Media and prerequisites

The committed disks are LFS pointers in a fresh clone — `git lfs pull` before unpacking.

```bash
tar -xSjf image/ipnx-v8-rp07.img.tar.bz2 -C work/myv8   # -> work/myv8/rp07new
tar -cjf  image/ipnx-v8-rp07.img.tar.bz2 -C work/myv8 rp07new   # repack
```

The `S` is not optional on extract: a disk image is mostly zeros, and only `tar -xS`
restores them as holes rather than 1.9 GB of allocated blocks.

Desktop simulator (what every `tools/*.sh` harness runs, via `work/opensimh/BIN` on `PATH`):

```bash
libsimh/patches/apply.sh work/opensimh   # idempotent
cd work/opensimh && make vax780
```

### The app

```bash
libsimh/build-xcframework.sh     # clones + patches open-simh, builds ios/sim/macos slices
libdmd/build-xcframework.sh      # clones + patches dmd_core, cargo builds three targets
cd app && xcodebuild -project ipnx.xcodeproj -scheme ipnx \
    -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build
cd app && xcodebuild -project ipnx.xcodeproj -scheme ipnxMac \
    -destination 'platform=macOS,arch=arm64' -derivedDataPath build/DerivedData build
```

### Checks that decide whether a change is done

```bash
tools/app-check.sh --full          # is the app you would launch the latest, and will it start
tools/verify-golden.sh             # disk content: containment, current lists, C4 reproduction
tools/boot-newdisk.sh              # disk behaviour: boots alone, has mux, games, man
bash tools/net-selftest.sh rp07new # real traffic: TCP to host, TCP to a web server, DNS
python3 v8/mk/mkdep.py --check     # committed makefiles match the tree
python3 tools/ipnx-release.py --check   # ipnx.h and newvers.sh match v8/RELEASE
tools/check-md-links.sh            # relative markdown links resolve (no args = every .md of ours)
```

`verify-golden.sh` and `boot-newdisk.sh` answer different questions and neither substitutes
for the other: a disk has passed containment with `UNIQUE 0` and still been unable to reach
`login:`.

### Building the V8 golden disk from source

```bash
( cd netfs && swift build -c release )        # the harnesses serve the source tree over netfs
tools/drive-stage1.sh 25200 9370              # stages 1-7: toolchain, libc, toolchain again, headers, libs, cmds, kernel
rm -f work/myv8/rp07new
tools/drive-stages48.sh 5400 9370 8 9         # stage 8 (the disk) and stage 9 (chroot self-rebuild)
```

Two runs, hours not minutes. The `rm` matters: `mkfs` does not clear data blocks, so reusing
the file leaves the previous run's contents in what the new filesystem calls free space.
`drive-stages48.sh` can re-run a single stage (`tools/drive-stages48.sh "" "" 8 8`) against
the `rp06build` filesystem stage 1 left behind.

### V10

**The machine builds itself; the host fetches tapes, restores disks and boots them.**

```bash
bash tools/v10-tapes.sh                 # the six TUHS archives -> v10tapes/, plain tar, gitignored
bash tools/v10-reset.sh                 # the committed archives -> image/v10 (working), images/v10-golden, image/uda
bash tools/v10-launch.sh                # boot image/v10, golden on the second drive, both shares up
bash tools/v10-golden.sh                # boot a throwaway copy of the golden, alone
```

`image/` is the **current working image** and `images/` is the **golden** — two directories,
on purpose. `image/` also holds the committed `.tar.bz2` archives; everything else in it is
gitignored.

**There is no host tool that creates a blank disk image**, and `mkimage` cannot make one —
V10 has no sparse files. The file must exist on the host and be attached as `rq1` first
(`dd if=/dev/zero of=images/v10-new bs=512 count=3920490` is an RA73). `v10-launch.sh`
attaches the golden as the second drive, so an ordinary round needs no new file.

The tapes are not committed and **neither is any tree made from them**. The host-side
reconstruction that used to produce one — a pristine extract per tape, merged into a
corpus, shaped into `v10/` — is gone, and so are the six tools that read it: the machine
does all of that itself now, via `mkv10`.

One consequence of that history is live and worth knowing: the **committed `v10/` tree
carries every `ar` member unpacked as a file**, so `plot.c.a` is a directory with an
`ORDER` file beside the members, while `mkv10` fills the machine's `/usr/src` straight
from the tapes, where the same name is an archive. The mkfile has rules for both forms;
one written for the wrong one fails with `bad directory`.

Guest side — the inner loop is two commands, both run on the machine:

```sh
updatebuild            # pull /usr/src/build from the repo over /n/macos; the ONLY command that touches /n
ipnxbuild [/v10]       # build a complete system from /usr/src into ROOT (default /)
ipnxclean [/v10]       # remove exactly what ipnxbuild wrote, from the list it wrote
```

Everything the build does is `v10/usr/src/build/mkfile` (one rule per product; `world` is
the whole distribution) and `v10/usr/src/build/patch` (idempotent source repairs run before
anything compiles). Both are edited **here**, in the repository, and reach the machine only
via `updatebuild`. `patch` edits `/usr/src` in place on a guest whose tree persists between
builds, so a bad edit must be *repaired*, not merely reverted.

The rarely-typed verbs: `mkv10` (the six tapes → `v10.tar`, pristine), `mkipnx`
(`v10.tar` + build system + repairs → `ipnxorig.tar`), `taripnx` (a live `/usr` →
`ipnx.tar`), `mkimage` (format the second drive and build a disk into it).
`build/usrtrees` is the single statement of what `/usr` carries; `build/mkcheck` lists what
must exist before the mkfile will run.

**V10 is not a complete distribution, and the measure is the tape's own.**
`v10/usr/src/cmd/Admin/{binfiles,etcfiles,libfiles,ulibfiles}` are the manifests of what a
V10 machine holds. Against them: 4 of `/bin`'s 57 and 4 of `/etc`'s 56 are not built (each
with a reason), and **27 of `/usr/lib`'s 50 are missing**. Check a claim about completeness
against those lists, never against a pattern over the source tree.

### Website and release

```bash
cd website && npm install && npm run dev      # Astro 7 + Tailwind 4
cd website && npm run build                   # GH Actions does this on push to main
tools/release-mac.sh [--skip-notarise]        # signed, notarised, stapled build/release/ipnx.dmg
python3 tools/ipnx-release.py --bump patch|minor|major
```

## Architecture

### One process, two interpreters, one wire

```
SIMH vax780 (C, thread)  --DZ11 line 0-->  dmd_core (Rust, thread)  -->  Metal/SwiftUI
                         --lines 1-7--->   SwiftTerm vt100 views
```

- **simh thread** runs `simh_vax780_run()`. SIMH's globals are never reinitialised, so a
  simulator cannot be started twice in one process — a genuinely fresh machine means a
  fresh process (`Machine.swift`).
- **dmd thread** steps the WE32100 at ~10 MHz wall-clock; the DUART is a wall-clock state
  machine and a flat-out CPU wedges its serial handshakes.
- **main thread** is SwiftUI + Metal; the 5620's packed 1-bit VRAM is expanded in a
  fragment shader.
- Control plane: two localhost sockets per machine — the console byte pipe and the SIMH
  remote console (`^E` → command mode → `save`/`continue`/`restore`). Ports are
  **pid-derived** per launch, because `tmxr` binds without `SO_REUSEADDR` and a quick
  relaunch would collide with its own `TIME_WAIT` ghost.
- **Every DZ line gets its own listen port** (`Machine.dzPort`). V8 has no `TIOCGWINSZ` and
  no `/etc/ttytype`; `/.profile` picks `TERM` from `` `tty` ``, so which line a session
  lands on *is* what terminal the guest thinks it is. A single mux-wide listener would hand
  connections to the next free line and a tab labelled `tty03` would be lying.
- Windows are grouped by **terminal shape**, not by taste: the shapes cannot be reflowed
  into one another, so tabs only ever group sessions of the same size.

`MachineSpec.swift` holds everything that differs between editions as data — V8 is an RP07
on the Massbus started by `load -o bootV8 0; run 2`; V10 is an RA73 on MSCP/UDA50A started
by `run FA02`. The resume path is a *different* list from the boot path on both machines.
The app shell is edition-agnostic by design: it knows about machines, not editions.

### netfs, and why it works inside the iOS sandbox

Weinberger's netfs client has been compiled into every V8 kernel since 1985 with nothing to
talk to. `netfs/` is a server for it. SIMH's SLiRP rewrites any address inside its virtual
network to host loopback, so the guest dialling `10.0.2.2:PORT` arrives at
`127.0.0.1:PORT` inside the same process — no port forwarding, no host interface, no
entitlement. `/n/macos` is served read-only (the absence of `-w` is the whole guard);
`/n/home` is read/write.

### The V8 build

Nine stages, `TOOLDIR`/`DESTDIR`/`OBJDIR` under `/usr/bld`, and **nothing is ever installed
into `/`** — the running system stays the one that works until `mkfs` turns a directory
tree into a disk. Stage order matters: libc (2) comes before the toolchain rebuild (3),
because every stage-1 binary is linked against the *tape's* libc. Stage 8 lifts 1,406
files off the committed image that Bell Labs shipped without source (`v8/mk/gen/carry.txt`)
— which is the entire reason one binary is in git. Stage 9 rebuilds the system inside
itself as the completeness proof.

V8's `make` cannot discover that `foo.o` depends on a header three includes deep, so the
dependency lists are generated on the host and committed (`v8/mk/gen/*.mk`). Regenerate
with `v8/mk/mkdep.py`; `--check` fails if the committed output is stale, and the drivers
run that check before spending an hour.

### The V10 build

`$ROOT` means **only where output goes**. The toolchain is always the running machine's, so
one process with a target parameter builds either disk. `mkfile`'s `installed` predicate is
`test -f`, so nothing is ever rebuilt on the strength of a timestamp — `.patched` and
`.ranlib` are plain stamp files. `docs/v10-build.md` describes the whole of it, read off
the scripts themselves — where that document and a script disagree, the script is right.

V10 is a **reconstruction and labelled as one**: there was never a pure Tenth Edition to
restore. The tape is one machine's working tree caught mid-upgrade from V9 — `libc.a`'s 261
members are dated across 4.1 years, neither compiler on the tape can build libc alone, and
the old members are V9's, whose VAX compiler is not there. Fidelity is to *this tree*, with
every deviation named in `patch`.

## Conventions that have already cost a run

These are not style preferences. Each is here because it failed once, quietly, with exit
status 0.

- **Binaries never enter git.** The exceptions are exactly `image/*.tar.bz2` and the split
  V10 golden; build everything else under `work/`, which is gitignored. Claude Code hooks
  used to enforce this and were deleted with `.claude/`, so `.gitignore` is now the only
  guard — `git add -f` of a disk image is a decision nothing will stop you making.
- **Run every guest harness against a clone, never the golden.** Booting mounts, and
  mounting rewrites the superblock — a clean, fully passing run still changes the image's
  hash. `source tools/v8clone.sh; v8_clone rp07new <tag>`. The `.sh` drivers now do this
  for you; the `.exp` files do not.
- **Two simulators must never run at once.** `source tools/norun.sh; no_other_sims;
  claim_images …`. Two runs once overlapped and both exited 0, one of them measuring a disk
  that was being zeroed underneath it.
- **Console automation matches markers, never prompts, and never a literal.** Use
  `tools/v8drive.exp`. The tty echoes what you type into whatever is already printing, a
  prompt repeats, and `login:` arrives with mark parity. Three harnesses each grew their own
  prompt matcher and all three hung.
- **A harness must terminate itself; needing to kill one is the bug** — and expect's `exit`
  closes the spawn, which kills a running guest.
- **Never answer IAC on the remote console** (`ConsoleLink(replyToIAC: false)`): a client
  that replies silences that session permanently.
- **`set noasynch`** on any desktop `vax780`: without it two overlapping transfers corrupt
  RP06 I/O and it presents as a hardware fault. The iOS/macOS library is compiled without
  `SIM_ASYNCH_IO` so the state cannot be lost.
- **The netfs share is live** — an edit to `v8/` lands in a run already in flight. Harmless
  for a read-only measurement, lethal during a two-hour world build.
- **An artefact must carry a record of its origin, and its consumer must check it.**
  Regenerating a file in the repository changes nothing a guest already holding a copy will
  see, and there is no symptom: it compiles, asserts and reports against the previous
  generation. On V10 this is why `updatebuild` is the first half of every round.
- **"It is in the golden, it will arrive on Reset" is not shipping it.** `tools/app-check.sh`
  asserts the whole chain — repo golden → app bundle → what launches — because a fix can be
  written, proven and committed while the thing the user double-clicks still runs last
  week's system.
- **Generated files stay in step with their source** — `mkdep.py --check`,
  `ipnx-release.py --check`, `mkcarry.py --check`. A stale makefile is the one failure that
  looks like a source bug.
- **Regenerate `v8/mk/gen/` on a case-insensitive filesystem only.** `derive_dirs()` tests
  for `os.path.exists(<dir>/makefile)`, and 66 of the command directories spell it
  `Makefile`. On macOS that test passes; on Linux it does not, so `mkdep.py --check`
  reports `provenance.txt stage6.order stage6-skipped.txt destfiles.txt` stale and a
  regeneration there would silently drop ~26 stage-6 commands (`adb`, `cp`, `ed`, `mail`,
  `man`, `mv`, `passwd`, `ps` …) from the world build.
- **Guest-side constraints that shape any port:** V8's 1985 `cc` takes no prototypes
  (`expected a NAME in list` is the rejection), filenames are 14 bytes, an archive must be
  re-`ranlib`'d at its destination after a copy, and `--` is not end-of-options.

## Prose

Documentation and comments lean Australian/British (*artefact*, *behaviour*, *licence* the
noun, *notarised*); match the file you are editing. The house style in this repository is
to write down *why* a thing is the way it is, with the incident or measurement that
settled it — most of the long comment blocks in `tools/` and `mk/` exist because something
passed, exited 0, and was wrong.
