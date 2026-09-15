# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

**ipnx** boots genuine Bell Labs Research Unix under full-system emulation inside one native
iPadOS/macOS app. Two ahead-of-time-compiled interpreters and a wire, mirroring the 1985
topology: open-simh's `vax780` runs the VAX, `dmd_core` runs a DMD 5620 terminal's WE32100,
and a DZ11 connects them. Nothing is syscall-translated, so iOS's no-fork/no-exec/no-JIT
rules never apply.

Two tracks run in parallel:

- **Track A — Eighth Edition (1985), shipping.** The app, plus a golden disk built from this
  repository's own V8 source (`v8/`).
- **Track B — Tenth Edition (1989), restoration.** V10 has never been booted by anyone. It
  now builds its own toolchain, libc, `/bin`, kernel and whole distribution — on itself.

Doc map: `README.md` is the public overview; `RESEARCH.md` is the **frozen** feasibility
study (evidence, not a living doc); `docs/architecture.md` is the living spec;
`docs/roadmap.md` is phases and status; **`docs/v10-build.md` is how a Tenth Edition is
made**, read off `v10/usr/src/build`; `docs/v10-log/` is a dated lab notebook.

## Commands

### Cores, app, host services

```bash
libsimh/build-xcframework.sh          # open-simh vax780 -> xcframework
libdmd/build-xcframework.sh           # dmd_core (Rust staticlib) -> xcframework
cd netfs && swift build -c release    # -> netfs/.build/release/netfsd
cd website && npm run dev             # Astro site; npm run build to publish-check
```

```bash
cd app && xcodebuild -project ipnx.xcodeproj -scheme ipnx \
    -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build
cd app && xcodebuild -project ipnx.xcodeproj -scheme ipnxMac \
    -destination 'platform=macOS,arch=arm64' build
```

The app build's only media prerequisite (the committed golden; `image/*.tar.bz2` is **Git
LFS**, so `git lfs pull` first on a fresh clone):

```bash
tar -xSjf image/ipnx-v8-rp07.img.tar.bz2 -C work/myv8
```

Is the app you would launch right now the latest, and will it start?

```bash
tools/app-check.sh --full
```

### Track A — the V8 disk

`v8/mk/*.sh` are the stage scripts; `v8/mk/mkdep.py` generates the makefiles Research Unix
never had; `v8/RELEASE` is the single source of truth for the version. The edition-independent
half of the generator lives at `mk/mkgen.py` (dependency scanning, emit, install layout) — a
fork would mean every later fix made twice and silently not made, and `mkdep.py --check`
guards it by diffing the committed output byte for byte.

```bash
bash tools/drive-stage1.sh                              # toolchain/libc/fixpoint, ~50 min
bash tools/drive-stages48.sh "" "" 4 8 rp07ref rp07     # stages 4-8 against work/rp06build
v8/mk/mkdep.py --check                                  # committed makefiles stale?
tools/ipnx-release.py --check                           # has the version drifted?
tools/verify-golden.sh                                  # content only, no VAX, ~1 s
IMG=rp07new tools/boot-newdisk.sh                       # boot end to end, 13 assertions
bash tools/net-selftest.sh rp07new                      # asserts TRAFFIC, not config
python3 tools/v8fs.py sum work/myv8/rp07new             # read a V8 filesystem host-side
```

### Track B — the V10 round

**`docs/v10-build.md` is the whole of it**, read off `v10/usr/src/build`, which is the
authority. The machine builds itself; the host only fetches tapes.

```bash
bash tools/v10-tapes.sh                 # fetch the six -> work/tapes/*.tar, for the guest
bash tools/v10-launch.sh                # netfsd shares + images/v10 as rq0, golden as rq1
bash tools/v10-golden.sh                # boot a throwaway copy of the golden, no netfsd
bash tools/v10-reset.sh                 # restore images/ from the committed archives
```

Never run two simulators, and never run one from a session that is also giving
instructions.

On the guest, the inner loop is **two commands** (`v10/usr/src/build/`):

```
updatebuild        # pull /usr/src/build from the share -- the ONLY command touching /n
ipnxbuild          # build this machine;  ipnxbuild /v10  targets the disk on ra1
```

The rest of the verb set is rare: `mkv10` (six tapes → `v10.tar`, pristine, once ever),
`mkipnx` (`v10.tar` + build system + repairs → `ipnxorig.tar`), `taripnx` (live `/usr` →
`/usr/ipnx/ipnx.tar`), `mkimage` (blank disk, extract, `mk world`), `ipnxinstall` (the
configuration, asking before it overwrites anything the operator owns), `ipnxclean`
(remove what was derived).

Bootstrapping from nothing is `mkimage` (leaves `/v10` blank and mounted), `mkv10`,
`mkipnx`, `mkimage` again.

## Architecture

### The app shell is edition-agnostic

It knows about *machines* (a SIMH simulator + a disk image + a serial wiring), not editions,
so V10 arrives as just another image (`MachineSpec.swift`, `Machine.swift`).

- `app/` — one Swift/SwiftUI source folder, two targets (`ipnx` iPad, `ipnxMac`). Platform
  differences go behind `#if os(macOS)` and the `PlatformViewRepresentable` shim in
  `Platform.swift`, **never a forked file**. Both xcframeworks' Swift modules are declared
  in `app/ipnx/Modules/module.modulemap` — two frameworks cannot each bundle one (flat
  `include/` collision).
- Three threads: simh (`simh_vax780_run()`, compiled **without** `SIM_ASYNCH_IO` — V8 needs
  synchronous mode and it is a build-time guarantee), dmd (WE32100 at ~10 MHz wall clock —
  the DUART is a wall-clock state machine), main (SwiftUI + Metal, 1-bit VRAM expanded in a
  fragment shader).
- Control plane: two localhost sockets — telnet console `127.0.0.1:42323` (a pure byte pipe
  into SwiftTerm) and SIMH remote console `:42324`, where `^E` suspends into command mode for
  `save`/`continue`. The two dialects differ sharply (WRU, IAC tolerance, prompts); read the
  table in `docs/a1-notes.md` before touching that plumbing.
- `libsimh/` — open-simh as a C static library. No async, no network, no SDL.
- `libdmd/` — dmd_core as a Rust staticlib via its **built-in** C FFI. Never wrap it in
  another crate; the unmangled exports collide. Extend via logged patch.
- `netfs/` — the host half of Weinberger's netfs, in Swift. Two targets on purpose: `NetFS`
  depends on nothing a phone lacks (Foundation + POSIX sockets, no Network.framework), so the
  app compiles the same sources; `netfsd` is a thin `main()`. Nothing here may grow a
  Mac-only dependency.

### The trees

| | | |
|---|---|---|
| `v10/` | committed | a **filesystem** — byte-for-byte the machine's own `ipnx.tar`, a tar of `/usr`, so `v10/usr/src/cmd/ls.c` is what the guest has at `/usr/src/cmd/ls.c`. **Our working copy, edited directly.** |
| `v8/` | committed | the Eighth Edition source the golden is built from, laid out the same way. |
| `work/tapes/` | gitignored | the six TUHS archives as plain tar, written by `tools/v10-tapes.sh`. What `mkv10` reads. |

`v10tapes/` and `v10superset/` were a host-side reconstruction — a pristine extract per
tape, merged into a corpus, shaped into `v10/`. The machine does all of that now
(`mkv10`), so both trees are deleted; git history has them at `751594dd` and later. Six
tools that read them are still in `tools/` and are no part of the build: `v10-tree.py`,
`v10-dist.py`, `v10-check.py`, `v10-read.py`, `v10-files.py`, `v10-plan.py`.

**There is no patch directory and no OVERLAY file** — git keeps that record honestly. The
old arrangement hid eleven files of pure *configuration* (a motd, a hostname, an `/etc`)
among genuine repairs for as long as nobody diffed it. `v10/usr/src/build/patch` is the
repairs, each idempotent and each carrying its evidence; `PATCHES.md` is the long form.

### The guest-side build

`v10/usr/src/build/` is edited here and reaches the machine via `updatebuild`. Full
account: `docs/v10-build.md`. What recurs everywhere in it:

1. **The shape of `/usr` is `build/usrtrees`** — `src man include sys blit jerq 630 maps
   vol2 local`. `sys`, `man` and `include` sit **beside** `src`, not inside it; an earlier
   migration put them under `/usr/src` and was reversed. `bin` and `lib` are absent
   deliberately: product, not shape.
2. **`$ROOT` means only where output goes** — not where the toolchain is, not where the
   build system is. `$GEN` is pinned to the builder, so no copy on the target can go
   stale, and the toolchain is always this machine's.
3. **A component list that appears twice will disagree.** Each of `usrtrees`, `casenames`,
   `casefix`, `arcfix`, `mkfiles`, `preserve`, `derived` and `consumed` is the only
   statement of its thing, and where it can be, *the list is the directory* — `mkbuild`
   enumerates its source, `ipnxinstall` enumerates `$GEN/etc`.
4. **Build and install are two halves.** `build1`..`build4` make artefacts in the source
   tree; `world`'s members install them. Each runs in its own `mk`, because a nested
   virtual aggregate dies at its first fork with `Not enough memory`.
5. **Whatever mounts, unmounts** — including on the failure path, which `ipnxbuild` traps
   1 2 3 15 for.
6. **Tally into files, never variables.** 1970s `sh` forks for a compound command carrying
   an input redirection, so a counter assigned inside `while read ... done < file` is lost
   in the child.
7. **`ipnx.tar` = `ipnxorig.tar` = `v10/`.** Two archives cut at different moments hold
   the same tree, or one of them is lying. `consumed`, `preserve` and the directory list
   exist to close that equation.

## The rule that outranks everything else

**Never leave a machine inconsistent. A machine that was not cleanly halted has a corrupted
disk — assume it.**

```
cd /; sync; sync; /etc/halt      # V8 -- wait for `halting'
/etc/down                        # V10 -- wait for `death'
```

Then `q` at `sim>`, and not before the marker. V10's kernel does not sync on halt
(`md/machdep.c:439-446`'s `boot()` is two lines), so the userland sync is the whole flush, and
V10 records in the superblock that a filesystem is mounted — halting without `/etc/umount -a`
makes the next boot answer `In use` and carry on with an empty `/usr` showing through,
reporting nothing. `/etc/down` is the script that gets that order right: it kills every
process holding an inode (`/etc/update` alone makes `/usr` permanently unmountable), syncs,
unmounts, and **refuses to halt if the unmount failed**.

- Never `pkill` a `vax780`, and never delete a `state.sav` while keeping its disk — snapshot
  and disk are consistent only as a pair.
- `fsck` restores metadata *consistency*, not data; several of its repairs destroy data by
  design. A clean pass is not evidence anything survived — a hash against a known-good
  artefact is.
- **Run every guest harness against a clone, never the golden** (`tools/v8clone.sh`). Booting
  mounts, and mounting rewrites the superblock, so a clean successful run still changes the
  hash. Stating this was not enough: three harnesses defaulted to booting the golden and one
  moved it while every assertion passed.
- **Two simulators must never run at once** (`tools/norun.sh`, `tools/norun.exp`). Match the
  process *name*: `pgrep -f vax780` matches the waiter's own arguments and reads 2 with one
  simulator running.

## What the tapes teach that no single file shows

- **The tape states its own build.** `src/cmd/Admin/Mk` is the command build system;
  `Admin/dest` gives install paths from `binfiles`/`etcfiles`/`libfiles`/`ulibfiles`;
  `Admin/large` names the 27 programs compiled `-O` not `-Od2`. `usr/sys/lib/mk.star` is the
  kernel recipe, and `lsys/astro/mk.out` is the tape's own *transcript* of it running for
  thirteen machines — that one is in the corpus only, so it needs a rebuild or
  `git show 751594dd:v10superset/lsys/astro/mk.out`. Read them before inferring.
- **No inheritance.** `cmd/cc.c:9-11` hardcodes `as`, `ld` and `crt0`, and `-B` reaches only
  ccom, c2 and cpp; `cmd/ld.c:1579-1595` hardcodes `-lX` to `/lib`, `/usr/lib`,
  `/usr/local/lib`, with no `-L`. A build that links through `cc` uses the *builder's*
  assembler, linker, crt0 and libc whatever `-B` says. The build calls `ld` directly with
  absolute paths — which is how the tape links the kernel.
- **An object file is not evidence a compiler ran.** Without `-O` this compiler emits a bare
  36-byte a.out header and exits 0, and `test -s` cannot tell that from a real object.
- **`ar cr` accepts object names that do not exist** and `ranlib` blesses the result. Assert
  member counts, never "an archive appeared". A `.a` is not evidence of a link library either
  — `ar` packaged any file set (`tek.c.a` holds `.c` files). Sniff the first 512 bytes.
- **V10's `ld` writes its output even with symbols undefined** — it reports them and clears the
  execute bits. Ask `ld` what it said; do not test for the file.
- **On V10 `ls` exits 0 for a file that is not there.** Assert with `test -b`/`test -c`/`test -s`.
- **The build is in-tree.** V10's cpp cannot resolve a quoted include for an out-of-tree
  source, and `-I` does not help.
- **`sys/mkconf/` has its own test fixtures; the build reads `sys/lib/`.** `mk.star:19` is
  `mkconf -t $LD/tab -d $LD/devs`, so `sys/lib/tab` and `sys/lib/devs` are the authority.
  Reading `mkconf/`'s copies says `pt` has no major and `hp` is an unknown device, and
  `readconf.c:73` makes an unknown name a hard error — the difference between a kernel that
  configures and one that does not. Our patched `usr/sys/lib/tab` is `lib/tab` **plus one
  line**, `cdev 18 pt`; keep it derived from that file or it silently loses what the tape gained.
- **`/dev/pt/*` are STREAM PIPES, not pseudo-ttys** (major 18 is `spipe.c` in both editions).
- **`/dev/tty` is `40,3`, a userland convention rather than a kernel feature.** `param.h:9`
  gives the whole answer (`NSYSFILE 4`); `init.c`'s `setupio()` dups **three** times, so the
  terminal occupies fds 0,1,2 *and 3*. Reading `io/fd.c` alone predicts EBADF and is wrong.
- **`ra`'s `0100` bitmapped-fs marker is per-partition, and units 8..15 do not exist.**
  `ra.c:39` masks with `027`, which clears the shifted bit, so `ra 8` reads back as unit 0;
  `phone/gauss.m` jumps 0..7 then 16..23 for exactly this reason.
- **1970s `sh` forks for a compound command carrying an input redirection**, so a counter
  assigned inside `while read ... done < file` is lost in a dead child. Tally into files.
  `IFS='|'` on the `read` also persists into the loop body.
- **V10 has no `chgrp`** — no source in `cmd`, in no Admin list, installed by no rule.

## Conventions

- **Big binaries never enter git.** The exception is `image/*.tar.bz2` (Git LFS — `git lfs
  pull` on a fresh clone) — the disks we build, because each is the *input* to the next
  build. `.gitignore` blocks every raw disk suffix and un-blocks that one path, and since
  `tools/hook-block-binaries.sh` was deleted it is the only guard.
  `image/v10-golden.tar.bz2` exceeds GitHub's 100 MB limit and is committed as two halves,
  which are **not** LFS (the filter matches `*.tar.bz2`, not `.aa`/`.ab`). Stream them;
  never join them on disk, because `.gitignore`'s `!image/*.tar.bz2` exception does not
  ignore the result: `cat image/v10-golden.tar.bz2.a? | tar -xSjf - -C images`.
  `tools/v10-reset.sh` does this, and copies the boot ROM the launchers need.
- **Unpack a disk with `tar -xSjf`, never without the `S`.** It is the only standard format
  that restores a *hole*, so a 1.9 GB RA73 costs its non-zero bytes on disk. zip cannot do
  this and neither can xz; both were tried here first.
- **V10 must stay authentic.** A deviation is allowed only where the tape cannot run as-is,
  and then it is a commit with a stated reason — never a file a harness writes inline, and
  never configuration or branding invented here.
- **Never recut `ipnxorig.tar` on the Mac.** bsdtar adds an AppleDouble member and a pax
  header per file, and macOS `tar tf` hides both: one such cut listed 27,708 clean names while
  holding 83,124 headers and under half the tree's bytes.
- **Every guest harness matches output *markers*, not shell prompts** — a prompt repeats, and
  the tty splices what you type into whatever is already printing. Spell markers through a
  shell variable (`echo PE''ND`) so the tty's echo of the command line does not answer the
  question the driver is asking. `tools/v8drive.exp` is the shared driver; three private
  copies of "log in and run a command" all hung, which is why it exists.
- Cite primary sources (TUHS preferred) for factual claims in docs.
- **VERIFY** marks a documented step assembled from research but not executed here. Resolving
  one means executing it and correcting the doc, or recording that it was superseded — never
  silently deleting the marker.
- Track B keeps a dated lab notebook in `docs/v10-log/`.

## Repository upkeep

- `bash tools/check-md-links.sh` sweeps every markdown file that is ours and **exits
  non-zero** on a broken relative link; name files to check just those. It was a
  PostToolUse hook and reported through a JSON object on stdout, so it exited 0 whatever
  it found — `.claude/` is gone and nothing installs hooks now, so it is a command and
  fails like one. The eight tracked `cmd/gcc/*.md` files are GCC **machine descriptions**,
  not markdown, and the sweep skips the tape trees for that reason.
- **Six tools in `tools/` are no part of the build and await deletion**:
  `v10-tree.py`, `v10-dist.py`, `v10-check.py`, `v10-read.py`, `v10-files.py` and
  `v10-plan.py`. They implemented the host-side reconstruction that `mkv10` replaced, and
  they read trees that no longer exist. `tools/v10-tapes.sh` is the only host-side piece
  of the bootstrap that survives, and it now does nothing but fetch and decompress.
- `v10/usr/src/build/PATCHES.md` opens *"Generated by `tools/v10-overlay.py` — do not
  edit; edit the tool"*. That tool does not exist and has not for some time, so the file
  is maintained by hand whatever its header says.
- `docs/roadmap.md` and the `docs/v10-log/` notebook cite tools that were deleted —
  `v10-syscalls.py`, `v10-probe.sh`, `v10-stage1.sh` and about forty more. Those are
  **dated provenance** for results that were obtained ("✅ 2026-08-16, 9/9"), not commands
  to run; `ls tools/` is the authority on what exists. `RESEARCH.md` is frozen evidence
  and is not corrected either.
