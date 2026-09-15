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
`docs/roadmap.md` is phases and status; `docs/v10-round.md` is the V10 procedure start to
finish; `docs/v10-log/` is a dated lab notebook.

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

Host side, reading the tapes:

```bash
bash tools/v10-tapes.sh                 # six archives -> v10tapes/, pristine
python3 tools/v10-tree.py --bootstrap   # v10tapes/ -> v10superset/  (DESTRUCTIVE)
python3 tools/v10-check.py              # validate the superset, independently
python3 tools/v10-dist.py               # v10superset/ -> v10/       (DESTRUCTIVE)
python3 tools/v10-tree.py               # what have WE changed since the tapes?
```

Running a machine (**never two at once**, and never from a session that is also giving
instructions):

```bash
bash tools/v10-launch.sh                # netfsd shares + images/v10 as rq0, golden as rq1
bash tools/v10-golden.sh                # boot a throwaway copy of the golden, no netfsd
bash tools/v10-reset.sh                 # restore images/ from image/*.tar.bz2
```

On the guest, the inner loop is **two commands** (`v10/usr/src/build/`):

```
updatebuild        # pull /usr/src/build from the share -- the ONLY command touching /n
ipnxbuild          # build this machine;  ipnxbuild /v10  targets the disk on ra1
```

The rest of the verb set is rare: `mkv10` (six tapes → `v10.tar`, pristine), `mkipnx`
(`v10.tar` + patches + our files + `src/build` → `ipnxorig.tar`), `taripnx` (live `/usr` →
`/usr/ipnx/ipnx.tar`), `mkimage` (blank disk, unpack, `ipnxbuild /v10`). Full procedure with
the reason each wrong version was wrong: `docs/v10-round.md`.

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

### The four V10 trees, and what each answers

| | | |
|---|---|---|
| `v10tapes/` | **gitignored** | the six TUHS archives, pristine, one root each. Re-extractable; `MANIFEST` has a hash per file. Never edited. |
| `v10superset/` | **gitignored** | a **corpus** — everything the six tapes hold, merged by rule, in whatever shape the tapes were cut. Validated, not shaped. No V10 machine ever looked like this. |
| `v10/` | committed | a **filesystem** — byte-for-byte the machine's own `ipnx.tar` (a tar of `/usr`), so `v10/usr/src/cmd/ls.c` is what the guest has at `/usr/src/cmd/ls.c`. **Our working copy, edited directly.** |
| `v8/` | committed | the Eighth Edition source the golden is built from, laid out the same way. |

**Only `v10/` is in the repository.** The corpus was committed until it was deleted at
Christine's instruction; both tape trees are now build products, rebuilt by the two
commands above and recoverable from git history (`751594dd` and later). Six of the
corpus' roots — `lsys`, `dist`, `nbstests`, `history`, `dregs`, `facedl`, 1,654 files —
were never placed into `v10/` and so exist only there, `lsys/astro/mk.out` among them.
The generated reports stay committed and answer most tape questions without a rebuild:
`docs/v10-tree.md` (provenance, per file, with the contested paths dated) and
`docs/v10-dist.md` (what was placed where, and what was not).

There is **no patch directory and no OVERLAY file** — git keeps that record honestly. The
old arrangement hid eleven files of pure *configuration* (a motd, a hostname, an `/etc`) among
genuine repairs for as long as nobody diffed it. `python3 tools/v10-tree.py` is where the
discipline is checked: it prints every file we have changed, added or removed since the tapes,
and the tree currently answers **0**.

The superset merge: `secombe` is the base — the newer cut, dating 1993–1995 against
norman's 1988–1993 — and `norman` supplies reach, 10,612 paths secombe does not carry.
Where bytes differ the newer mtime wins, every contested path dated in `docs/v10-tree.md`.
Excluded: `history/ix`, 877 files of a different operating system. Case collisions take a
`u_` prefix on the non-lowercase spelling, applied per path component to the **merged tape
paths**. `ar` archives are unpacked as directories with an `ORDER` file beside the members,
which is why the corpus held 33,419 paths for 28,697 tape entries.
An archive is found by its magic number (`!<arch>\n`), never its name — the host `ar` is never
used, because macOS's exits **zero** having extracted nothing from the SysV/COFF archives under
`630/`. Placement into `v10/` allows only two kinds of evidence (a file naming its own path;
the tape's own `srctotape` manifest); counting references does *not* settle a source directory,
and anything unsettled stays in `v10superset`.

### The guest-side build

`v10/usr/src/build/` is edited here and reaches the machine via `updatebuild`. Two files carry
everything: **`mkfile`** (one rule per product; `world` is the distribution in bootstrap order)
and **`patch`** (idempotent source repairs run before anything compiles, each block carrying
its evidence — `PATCHES.md` is the long form). Invariants the arrangement rests on:

1. `/usr/src` holds everything the tapes carry; `/usr/bin` and `/usr/lib` hold what the build
   makes.
2. **`$ROOT` means only where output goes** — not where the toolchain is, the build system is,
   or sources are read from. `$GEN` no longer follows `$ROOT`, so no copy on the target can
   go stale.
3. The toolchain is always the boot system's. One process, one parameter.
4. Every list the build reads is in the mkfile. *A component list that appears twice will
   disagree.*
5. The repository is the only source of truth for the build system; pulling from it is the
   first half of every round, not a decision.
6. Whatever mounts, unmounts — including on the failure path.

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
- **Five tools need the corpus rebuilt before they run at all**, now that it is no longer
  committed: `v10-check.py`, `v10-dist.py`, `v10-read.py`, `v10-files.py` and
  `v10-plan.py`. Each says so and names the two commands rather than failing obscurely.
  They are kept precisely because they are the recipe — deleting them would make the
  corpus' deletion irreversible.
- `python3 tools/v10-read.py` reads the corpus and writes `v10superset/READ.jsonl`, which
  `tools/v10-files.py` turns into `docs/v10-files.md`. The committed report predates the
  rebuild — its header still names `v10/source` and `v10/READ.jsonl` and counts 54,328
  entries against the corpus' 33,419 — so the per-file descriptions hold but the shape it
  describes does not.
- **`docs/v10-plan.md` and `tools/v10-plan.py` are vestigial.** The plan was the list the
  ten-stage build read; the mkfile is now the only list the build reads
  (`docs/v10-build.md`, invariant 4). The tool's paths have been repointed, but it still
  reports `programs 0` because it assumes the old tree's `src/` level above `cmd`, which
  the corpus' tape roots do not have. Treat its output as unverified until that is either
  rebuilt or the pair is retired.
- `tools/v10-tree.py` emits the per-tape prose in `docs/v10-tree.md` from hardcoded
  strings at `:439-441` that still describe the **old** merge rule — they call `norman`
  "the base of the tree" and say `secombe` has "only 30 paths of its own", while
  `PRECEDENCE` at `:99` puts secombe first and the file-count column in the same table
  credits secombe with 13,394 files. One row says both things at once.
- `docs/roadmap.md` cites `tools/v10-syscalls.py` five times for the 112-of-128 syscall
  measurement. The tool was deleted; the measurement it recorded stands.
