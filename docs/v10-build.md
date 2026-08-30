# The ipnx build system — one tool, three archives, one source tree

*Design, 2026-08-25. Replaces the `mkimage`/`mktape`/`mkbuild`/`mkipnx` arrangement in
`v10/usr/src/build`. Nothing here is implemented. This document is the specification the
rewrite is measured against, and every claim in it cites the file that establishes it —
where a number appears with no citation it was counted from the tree and the counting
command is named.*

## The problem it replaces

The present arrangement grew one script at a time, each correct for the moment it was
written, and the seams show as ceremony:

- **Two hops for every edit.** The repository is the source of truth, so a change to
  `mkfile` or `patch` reaches the machine only via
  `mkbuild / /n/macos/Users/christie/Repositories/Unix/ipnx/v10/usr/src/build` — a
  ninety-character path, retyped every round, and forgettable, in which case the build
  runs stale and says nothing.
- **Three commands per round, seven to target `/v10`.** `mkbuild`, then
  `rm -f /usr/src/cmd/.patched`, then `mk world`. For the other disk, add two mounts, a
  second `mkbuild` with different arguments, `mkdev`, and two unmounts.
- **`$GEN` follows `$ROOT`.** `mkfile:88` is `SRC=$ROOT/usr/src` and `:98` is
  `GEN=$SRC/build`, so building `/v10` requires the whole build system to be copied there
  first — including the parts only the builder ever reads. All 445 uses of `$GEN` are
  reads writing to `$ROOT`: `$GEN/installed` ×423, `$GEN/etc/*` ×19, `$GEN/mkimage` ×2,
  `$GEN/patch` ×1.
- **Nothing is ever rebuilt.** `build/installed` is `test -f "$1"`, and every target
  carries it as its `:P:` predicate. Two plain files, `.patched` and `.ranlib`, exist only
  because that predicate cannot compare times — `mkipnx:26-31` says so: "mkfile:126-135
  makes .ranlib and .patched plain files with no P attribute, so their existence is the
  whole test."
- **The host tree and `/usr/src` have diverged.** 265 paths in `v10/` carry a `u_` prefix
  that does not exist on the machine (`git ls-files v10 | grep -c u_`), because
  `v10-tree.py:225,243` renames case collisions for a case-insensitive checkout while
  `mktape` extracts the tape's real names. `v10/` is therefore a proxy for `/usr/src`, and
  a lossy one.
- **One archive name for two different things.** `mkipnx` today archives a live machine's
  whole `/usr`; the same name would serve for a tree derived from the tapes plus our
  patches. Those differ in patch state and behave differently under the build.
- **Two build tools.** `make` and `mk` both, and four blocks in `patch` exist purely to
  paper over the difference: three `chown`/`chgrp` sed loops and the `sh install.sh` fix.
  V10's `make` execs the command itself instead of handing the line to a shell, so
  `chown` — which is `/etc/chown` — answers `Make: Cannot load chown. Stop.`

## The invariants

Everything below follows from six rules. Where a later section seems arbitrary, it is one
of these applied.

1. **`/usr/src` holds everything the tapes carry.** `/usr/bin` and `/usr/lib` hold what the
   build makes, and nothing else lives outside `/usr/src`. The tapes' own `/usr` content is
   `630 blit include jerq local man maps src sys vol2` — no `bin`, no `lib`; `mkfile:1110`
   creates those two itself in the dirs run.
2. **`$ROOT` means only where output goes.** Not where the toolchain is, not where the build
   system is, not where the sources are read from.
3. **The toolchain is always the boot system's.** The same compiler builds the running
   machine and the other disk. One process, one parameter.
4. **Every list the build reads is in the mkfile.** A component list that appears twice will
   disagree.
5. **The repository is the only source of truth for the build system.** Pulling from it is
   not a command; it is the first step of a run.
6. **Whatever mounts, unmounts** — including on the failure path. V10 records in the
   superblock that a filesystem is mounted, so a missed unmount makes the next boot answer
   `In use` and carry on with an empty `/usr` showing through, reporting nothing.

## The command surface

Six verbs, two of which you type daily and four of which you type rarely.

| | what it does | how often |
|---|---|---|
| `updatebuild` | refresh `/usr/src/build` from `v10/build` on the share. **The only command that touches `/n`.** | every round |
| `ipnxbuild [ROOT]` | build a complete system from `/usr/src` — the running machine by default, `/v10` on request. Mounts and unmounts what it was given. | every round |
| `mkv10` | assemble the six TUHS archives into a pristine source tree and write `v10.tar` in the current directory | once, or when the tapes change |
| `mkipnx v10.tar` | transform pristine into ours — apply the patches, add our files, add the build system — and write `ipnxorig.tar` | when the patch set changes |
| `taripnx` | snapshot the live `/usr/src` as `ipnx.tar` | when a machine is worth preserving |
| `mkimage` | make a blank disk on ra1, unpack an archive into `/v10/usr/src`, run `ipnxbuild /v10` | when fabricating a disk |

**The inner loop is two commands.** `updatebuild; ipnxbuild`. No `mkbuild`, no
`rm -f .patched`, no mount, no unmount, no `ROOT=` unless you mean it.

### The three archives

They are three because they are three different things, and giving two of them the same
name is how the present arrangement confuses derived state with captured state.

| archive | contents | patch state |
|---|---|---|
| `v10.tar` | the six tapes, assembled, nothing else | pristine |
| `ipnxorig.tar` | `v10.tar` + our patches + our files + `src/build` | patched, derived |
| `ipnx.tar` | a live machine's `/usr/src` | patched, plus whatever that machine accumulated |

All three unpack to `/usr/src`, not `/usr`. That is what makes `mkipnx`'s present argument
at `:9-13` obsolete — "a disk that gets only src cannot build: it has no /usr/include, so
libc/mkfile:150's absolute /usr/include/libc.h cannot be resolved" — because `include`
comes from `src` and the build installs it.

There is no `build.tar`. A change to the build system is a change to `ipnxorig.tar`;
`updatebuild` is how it reaches a running machine in the meantime.

On a live system the archive lives at **`/usr/ipnx/ipnx.tar`**, outside the tree it
archives. That alone deletes two documented workarounds: `mkipnx:33-37` ("WRITTEN OUTSIDE
THE TREE IT IS ARCHIVING, then moved in. tar has no --exclude here, and an archive created
under the directory being walked is reached by that walk and copied into itself while it
grows") and `mkbuild`'s glob guard ("NOT `rm -f $D/usr/src/build/*'. ipnx.tar lives in this
directory, and with D empty that glob deletes the archive mkimage reads — which it did").

## Everything under `/usr/src`

`include`, `man` and `sys` move into the source tree and the build installs them out to
`/usr/include`, `/usr/man` and `/usr/sys`.

This is not a new idea; it is the tape's own, generalised. `mktape:61-62` already says of
the include tape: "**THE INCLUDE TREE GOES IN THE SOURCE TREE, like every other tape.** The
mkfile installs it to /usr/include from there, the same as it installs everything else."
And `mktape:79` is the exception that proves it — `mv /v10/usr/src/sys /v10/usr/sys` — the
tape ships `sys` *inside* `src` and mktape moves it out. Under this design that `mv`
disappears and becomes an install step, so the tape's shape survives untouched and
`mkfile:103`'s `SYS=$ROOT/usr/sys` becomes a destination rather than a place the kernel
happens to already be.

**The install-out step is unconditional.** It is a copy of a few hundred small files and
correctness is worth the seconds. The alternative is what exists today: `mkfile:114` is
`INC=$ROOT/usr/include/libc.h` and `:323` is `$INC:Psh $GEN/installed:`, so the whole
include tree is keyed on one file's existence and is never copied twice. That is why
`patch` carries 24 absolute `/usr/include/` references and seds
`/usr/include/dumprestor.h` in place at `:191` — it is reaching around a rule that will not
re-run. Generalising the keyed pattern to `man` and `sys` would inherit that trap twice
more.

## Dependencies: delete the `installed` predicate

Do not replace it. Delete it, and let mk compare times.

`build/installed` explains why it exists:

> the binaries on the image came off the tape and are older than nothing in particular, so
> comparing times would rebuild the lot

In this design that premise is gone. `ipnx.tar` is source only, `/usr/bin` and `/usr/lib`
are always build products, and the toolchain is always the boot system's. There are no tape
binaries with meaningless dates left to protect, so ordinary time comparison becomes
correct — which is what mk is for.

What it buys:

- **The two stamps stop being stamps.** `.patched` and `.ranlib` become ordinary targets
  with `patch` as a prerequisite, which deletes `rm -f /usr/src/cmd/.patched` from the inner
  loop.
- **Package builds become incremental for the first time.** For the ~109 PKG entries built
  by a foreign build file, the up-to-date decision belongs to *that* file: run it
  unconditionally and let it decide. Today's predicate is precisely what stops it from ever
  being consulted a second time, which is why `pi` rebuilt all 57 objects on every round
  even when one source had changed.
- **`updatebuild` needs no special case.** Copying `mkfile`/`patch` off the share stamps them
  now, so they are newer than everything and the right things rebuild.
- **`$ROOT`-relative toolchain paths become builder-relative.** `mkfile:121` is
  `LCCOK=$ROOT/usr/bin/lcc $ROOT/usr/lib/rcc $ROOT/usr/lib/gcc-cpp` and `PREP=$ROOT/usr/bin/strip
  $SRCOK`. Under invariant 3 those follow the builder, exactly as `$GEN` does, and `$ROOT`
  is left meaning one thing.

### The clock

Time comparison needs a clock, and the machine has one.

Direct evidence: `ls -l /usr/src/build/mkfile` across one session of 2026-08-25 read
`10:29`, `11:13`, `11:25`, `12:03`, `12:11` — correct date, correct year, monotonic, and
written by the guest's own `cp`.

Across a boot, `machdep.c:263-281` is `clkinit(base)` with two sources: `gettodr()` — which
is `mfpr(TODR)` (`machmfair.c:190-192`), the 780's time-of-year register in hundredths of a
second within the current year — and, if that reads below `TODRZERO` (`clock.h:18`,
`1<<28`), "too small; TODR was restarted", the filesystem's superblock time. `clkcheck()`
writes the system clock back to the register about once a day. So the worst case is the
last-mounted time of the disk the kernel just mounted, which is by definition later than
every source file on it: **the clock cannot read earlier than the tree it is building.**
`etc/rc:3` is a bare `date`, so a wrong clock announces itself on the console rather than
skewing a build silently.

### The precondition: no binaries in the source tree

Deleting the predicate and cleaning the tree have to land together.

Under `test -f` a stale binary was harmless, because everything was skipped anyway. Under
time comparison, `make` weighs `cmd/ls` against `ls.c` — both carrying 1984 tape dates in
whatever order the tape recorded them — and may keep the tape's binary instead of the one
your compiler makes. `mkimage:50-52` already records this failure once, for the kernel:

> NO `cp /unix /v10/unix' HERE ANY MORE. The mkfile builds the kernel from lsys, and its P
> predicate is `test -f' — a copy put here first would make /v10/unix look up to date and the
> build would silently keep the BUILDER's kernel, which is the thing this disk exists to
> replace.

The tree can afford it. Of 352 VAX `a.out` binaries under `v10/usr/src`, **344 sit in a
directory that already holds its source**; the 8 that do not are scratch or data
(`cmd/tbl/tmp`, `cmd/odist/pax/bin`, `cmd/learn/lib/lib`, `cmd/snocone` ×2,
`ipc/mgrs/ns/poot`). There is no irreplaceable binary, and `v10.tar` keeps every one of
them regardless.

## The clean-out

`/usr/src` holds source. Derived content goes.

Of 20,241 files under `v10/usr/src`: 3,246 `.o`, 122 `.O`, 228 `*.out`, 26 `a.out`,
12 `core`, 30 `.Z`/`.z`, and 3,047 unpacked archive members. Roughly a third of the tree.

**`mk clean` is the instrument**, because it asks each directory's own build what it
considers derived — and that is the only reliable test. The same filename is derived in one
place and source in another: `y.tab.c` is regenerated by eyacc in `cmd/pascal/pi` and is a
checked-in source in `cmd/pascal/pxp`, where `makefile:26-28` comments the rule out. No
extension rule separates those.

It under-cleans today, and `mkfile:32-38` says by how much: sixteen directories have a
`clean` that fails on an unbuilt tree ("libdbm's is `rm libdbm.a` with no -f, and libj,
docgen, ideal, learn, pic and poly are the same shape") and nine have none at all
("apsend, ex, gre, imscan, plot, punct, sign, twig, xref"). Those 25 get a working `clean`,
and then the `|| :` guards at `mkfile:32-38` come out.

**`.O` is not stray objects — it is `cyntax` output**, V10's lint. `ipc/libin/mkfile:28-29`
is

```
%.O: %.c
	cyntax -DLINT $INCS $stem.c
```

and 22 build files name `.O` targets, with `libin/mkfile:12` putting `cyntax` in the
*default* target. So they regenerate on every build and walk into the next `taripnx` unless
`clean` removes them. Every `clean` covers `.O` alongside `.o`.

### Three kinds of `.a`, and they are not interchangeable

`ar` was the ordinary way to package any file set, so the suffix says nothing. Sniff the
magic number, never the name.

| kind | example | treatment |
|---|---|---|
| link library | `libc.a`, `libfw.a`, `libstring.a` | derived — delete the members, the build remakes them |
| source container | `cmd/ccom/vax/tests/all.a` (50 `.i` inputs), `cmd/awk/test.a` (`T.getline`/`t.getline`), `tek.c.a` (holds `.c` files) | **the archive *is* the source** — keep the extracted form, delete the archive |
| neither | `libdbm.a` is a bare object; `crlib` is an archive with no `.a` in its name | decide by magic number |

**`ORDER` files leave the live tree.** There are 84 of them, and the build mkfile mentions
`ORDER` only in two comments (`:1184`, `:1545`), never in a recipe — they are
`v10-tree.py:318-323` artefacts for reconstructing a tape archive, and they belong to
`v10.tar`. Member order is already recorded where invariant 4 wants it: `libc/mkfile:8-57`
is an explicit `OBJ=$L(_assert.o) $L(_cleanup.o) …` and `ipc/libin/mkfile:4-5` is
`OBJS=$L(tcp_lib.o) $L(udp_lib.o) …`. The work is the exception those two comments name —
archives the tape shipped with no build file listing their members, `/usr/sys/lib/os.a`
("23 files and an ORDER") and `plot.c.a` — which need lists written.

## Case: one name per path

The host checkout stops being a proxy and becomes a copy. Every collision is resolved in
`/usr/src`, so no two paths in the tree differ only in case, and `v10-tree.py`'s renaming
becomes a no-op.

**Rule 0: the survivor is whatever the local build file names.** Not whatever is lowercase.
`v10-tree.py:225` gives the name to the all-lowercase spelling, which is a filesystem
convenience with no relationship to which file the build reads — and in both cases that can
be checked, the file the build reads is the one that got mangled:

- `libc/stdio/ostdio/olibcmkfile:123-125` is `doprnt.o: stdio/doprnt.S` /
  `cp stdio/doprnt.S doprnt.c`. The build reads the **capitalised** `doprnt.S`, and the
  extractor renamed that to `u_doprnt.S` while `doprnt.s` kept the name. This collision has
  already cost a round: the repository's name was applied to the guest and had to be
  reversed by a second sed.
- `cmd/cfront/libstring/makefile` names `Regexp.h`, and `include/CC` is `Bits.h Block.h
  CCversion.h Map.h Pool.h` — capitalised is cfront's convention throughout. `u_Regexp.h`
  is the real header.

The 265, by what the loser is:

| count | what | action |
|---|---|---|
| 91 | `.O` vs `.o` | delete — `cyntax` output, and a host artefact only; on the machine they never collided |
| 3 | `.Z` | delete |
| 50 | `.i` in `cmd/ccom/vax/tests/all.a/` | mechanical — ccom's own test inputs, `a.i`/`A.i` … `z.i`/`Z.i`; suffix the uppercase |
| 58 | capitalised, no extension (`Readme` vs `readme`) | diff first; in one directory these are usually the same text |
| 38 | four directories — `630/man/src/man` (27), `vol2/index/Junk` (8), `vol2/Preface` (3) | documentation; nothing builds from them |
| ~19 | real code: 7 `.c`, 6 `.h`, 2 `Makefile`, `hash.H`, 3 `libfw.a` members | Rule 0 individually |

So the clean-out and the case fix are one job: **94 of the 265 stop being collisions when
neither file exists.** For `makefile`/`Makefile` the answer is known — V10's make reads
`makefile` then `Makefile` (`cmd/make/main.c:219-220`), so `makefile` survives and the other
becomes `makefile.orig`, a name make will never open. The three `630/lib/libfw.a/*.o` are
genuine members with an `ORDER` beside them, so they are renamed, not deleted.

**The rename table lives in `mkv10`.** If the renames exist only in `/usr/src`, `mkv10`
regenerates every collision from the tapes on its next run. It has to be a recorded
transform applied at assembly time — at which point `v10-tree.py`'s computed renaming is
redundant and the two trees are identical.

## One tool: mk everywhere

Including external packages. A v11 port system wants one dialect, and mk's `%` patterns and
`:P:` predicates can express "rebuild when the upstream tarball changed", which suffix rules
cannot.

**Census.** 420 directories under `v10/usr/src` hold a build file: 177 `makefile` only, 143
`Makefile` only, 76 `mkfile` only, 15 `makefile`+`mkfile`, 9 `Makefile`+`mkfile`. **No
directory holds both `makefile` and `Makefile`** — that collision is exactly the two already
carrying `u_Makefile` (`cmd/cfront/libstring`, `games/sail`), so case is not the argument for
conversion.

The argument is that mk hands recipes to `/bin/sh` where make execs them itself, and every
make-specific patch we carry is that difference showing through.

**Cost.** 344 build files to convert, and nothing in the tree uses a feature mk cannot
express:

| files | feature | translation |
|---|---|---|
| 219 | `$(VAR)` | `${VAR}` — `cmd/mk/src/quote.c:202-205` shows `varsub` accepts `${VAR}` and bare `$VAR` only. The largest single edit. |
| 72 | `$@ $* $? $<` | `$target $stem $prereq` |
| 35 | suffix rules `.c.o:` | `%.o: %.c` |
| 13 | `.SUFFIXES` | delete; the `%` rules replace it |
| 7 | `include` | mk's `<file` |
| 6 | `$(MAKE)` | `mk` |
| 0 | `VPATH` | — |
| 0 | `ifdef`/`ifeq` | — |

**81 of the 344 need more than token substitution.** The build mkfile's 241 `make`
invocations become `mk`, against 47 already using it.

The sharp edge is `sh -e`, and it is the `clean` defect at scale. `mkfile:32-38`:
"mk(1):266-269 gives the recipe to `/bin/sh -e` and -e abandons the whole recipe at the
first command that returns non-zero — a `;` does not shield it, only a condition context
does." Every careless `rm` in a converted build file becomes an abort.

### Where an mkfile already exists

Nine of the 24 directories holding both are driven by `make` today, which means the mkfile
is the abandoned one. The date decides which was intended — mk is V10's own tool, so a Bell
Labs mkfile is a later intention, not an experiment:

| revive the mkfile | mkfile | makefile |
|---|---|---|
| `cmd/matlab` | Sep 12 1989 | Jan 19 1984 |
| `cmd/sign` | Oct 31 1991 | Jun 27 1991 |
| `cmd/bison` | Jul 14 1988 | Jul 13 1988 |
| `cmd/gre` | Apr 13 1992 | same day, newer |
| `libcbt` | Apr 27 1988 | same day, newer |

| write a new mkfile from the makefile | makefile | mkfile |
|---|---|---|
| `cmd/eqn` | Jun 19 1991 | Feb 26 1987 |
| `cmd/f2c` | Apr 28 1993 | Apr 2 1992 |
| `cmd/cbt` | Apr 27 1988 | Apr 26 1988 |

Two of these cut against the obvious reading. `bison` and `matlab` are third-party and
their mkfiles are still the later intention — matlab's by five years — so the migration was
not confined to Bell Labs' own code. And `eqn` is core troff, unambiguously V10, and its
makefile is four years *newer* than its mkfile: the mk migration was reverted there, so
reviving that mkfile would be going backwards. For all three of the "write a new one" cases
the two independent signals agree — the makefile is newer *and* the build drives them with
`make`. `cbt`/`libcbt` are a matched pair with opposite verdicts one day apart, so somebody
converted one half and not the other; that one wants reading, not a rule.

### The originals stay, stamped

Keep the makefiles. `v10.tar` preserves them anyway, so removing them buys no authenticity,
and `mk` reads only `mkfile` so a leftover is inert. But an unstamped leftover is invariant
4 violated — inside `ipnx.tar` there would be two build files and no way to tell which is
authoritative. So each conversion inserts, above the original's first line:

```
# HISTORICAL.  Nothing reads this file.  The build is mk(1), driven from
# /usr/src/build/mkfile, and this directory's rules are in ./mkfile.  Kept
# because it is what the tape shipped; v10.tar has the unedited copy.
```

`#` is a comment in both dialects, so one text serves. Guard on the word `HISTORICAL` so a
second pass does not double-stamp; that word is also what makes a sweep able to find every
one. The stamp goes in **as part of each conversion**, never as a sweep over anything that
merely has an mkfile beside it — in nine of the 24 that would be the wrong file.

### Autoconf, and the v11 port

**It does not arise in V10.** There are zero `configure`, `configure.in`, `Makefile.in` or
`config.status` files in the tree. V10 is 1989 and autoconf 1.0 was 1991, so every build
file here is hand-written, gcc's and bison's included.

It becomes real at the v11 import, and the answer is that a generated Makefile and an mkfile
are not competing for the same job. `configure` produces a Makefile from `Makefile.in` plus
a host probe; what a port needs from it is the *answers* — which sources, which defines,
which libraries. An mkfile that includes a small generated fragment keeps the port rules
ours and the host answers upstream's, so a version bump regenerates the fragment and leaves
the mkfile alone. That is invariant 4 again, and the same split as `$GEN` versus `$ROOT`:
one file for what we decide, one for what is derived.

## Implementation

Seven phases, ordered by what blocks what. Three of the dependencies are hard and the rest is
preference:

- **the clean-out must precede deleting the predicate** — stale binaries plus time comparison
  is silent staleness, which is worse than the ceremony it replaces
- **the rename table must exist before `mkv10` is written** — otherwise `mkv10` regenerates
  every collision from the tapes on its next run
- **`/usr/src` must be the unit before `ipnx.tar` can unpack to it** — and therefore before
  `mkimage` changes

Everything else can move. Phase 0 is first because it pays back on the same day.

### Phase 0 — the inner loop

Write `updatebuild` and `ipnxbuild`. Split `$GEN` and the toolchain paths (`mkfile:121`) from
`$ROOT`, leaving `$ROOT` meaning only where output goes. `ipnxbuild` owns the mount and the
unmount, including on the failure path.

*Proves it:* `updatebuild; ipnxbuild` builds the running machine, and `ipnxbuild /v10` builds
the other disk with no second `mkbuild` and no hand-typed mount. *Unblocks:* nothing — it is
free-standing, which is why it goes first.

### Phase 1 — the clean-out

Give the 25 directories a working `clean` (`mkfile:32-38` names them), make every `clean`
cover `.O` alongside `.o`, then sweep what `clean` cannot reach. Delete the link-library
members and keep their `ORDER`; delete the source-container archives and keep their extracted
contents; sniff by magic number. Write member lists into the mkfile for `/usr/sys/lib/os.a`
and `plot.c.a`.

*Proves it:* a full `ipnxbuild` from a swept tree produces the same binaries, and `mk clean`
twice in a row is quiet. *Unblocks:* phases 2 and 3.

### Phase 2 — one name per path — *decided, mechanised, and the rule installed in the tool*

Rule 0: the survivor is whatever the directory's own build file names — **not** whatever is
lowercase. Lowercase-wins was wrong twice over: `ostdio/olibcmkfile:123` is
`doprnt.o: stdio/doprnt.S`, so it renamed the one spelling the build reads; and
`cfront/libstring/makefile` names `String.h` seven times and `string.h` never.

**Done.** All 229 collisions decided from primary sources, and the table is
[`v10/usr/src/build/casenames`](../v10/usr/src/build/casenames) — rewritten as a plain mapping
(`NAME <tape path> <our path>`, `DROP <tape path>`; 162 and 102 records, no path in both) that
**`mkv10` applies when it lays the tapes down**. That is the mechanism the phase needed: the
renaming is now declared in one file, applied by one command, and reversible.

- 11 deletions: six zero-byte `ipc/bin` merge artefacts, `sail`'s hard link,
  `libstring/string.h` which no source includes and no build file names, and three files the
  build **regenerates from the sibling they collide with** (`compress/makefile:10-11`,
  `pc0/MKFILE:62-63`, `px/makefile:37-39`).
- 91 cyntax `.O` outputs deleted; the three `libfw.a` members kept, because they **differ**
  despite identical sizes and `ORDER` names both.
- 4 swaps where the build names the capitalised spelling; 3 renames with their build-file and
  `#include` edits (`Mazewar.c`→`rmtmazewar.c`, `README`→`README.f2c`, `hash.h`→`odihash.h`).
- `olibcmkfile:276` deleted: mk **requires** a prerequisite named by a recipe-less duplicate
  rule (measured), so that boilerplate was load-bearing rather than dead, and `:123` supersedes
  it.

**`grep -c u_` is not 0, and every one of the 159 that remain is inert.** Checked, not assumed:
nothing in the tree includes `DB.h` (23 files include `db.h`); `libstring/Regexp.c:1` includes
`"Regexp.h"` and resolves to its own local copy, not the include tree's; the 29 `String.h`
includes are libstring's own and now resolve to the file that kept the name. And the one class
that genuinely **cannot** be renamed — the 34 troff font descriptions, where `devpost/Hb` is
`name Hb / Helvetica-Narrow-Bold` against `HB`'s `Helvetica-Bold` and troff resolves a `.ft`
request to a file of that name at run time — **reaches no install rule at all**: the mkfile
installs no postscript fonts. The breakage is latent, and the fix when a rule is written is to
install under the tape's name, which is what the table is for.

**Rule 0 now lives in `tools/v10-tree.py`, not only in the table.** `:239` was
`keep = lower[0] if lower else sorted(spellings)[0]` — all-lowercase-wins — so a re-bootstrap
would have quietly undone the four swaps and renamed `doprnt.S` back to the spelling
`olibcmkfile:123` does not read. It now consults a `CAPWINS` table first, four entries, each
carrying its evidence on the line. Lowercase-wins remains the default because it is right for
almost every collision; Rule 0 only overrides it where a build file names the capitalised
spelling.

*Proved by the tool itself.* `python3 tools/v10-tree.py` reconstructs from the tapes and
compares against `v10superset`, and across **28,697 files it now reports exactly eight
differences** — `String.h`/`u_string.h`, `hash.H`/`u_hash.h`, `Qsnap.c`/`u_qsnap.c`,
`doprnt.S`/`u_doprnt.s`. Those are the four swaps and nothing else: the corpus still holds what
lowercase-wins produced, because it has not been re-bootstrapped, and `--bootstrap` deletes its
output tree so it is not something to run in passing.

**`core.ignorecase` is `true` here**, so git records a case-only rename under the *old* name:
after `mv u_String.h String.h` the index still says `string.h` and reports a content change.
The four swaps need `git mv -f` or they commit the new bytes under the names this phase removes.

### Phase 3 — dependencies — *done, and proved on the machine*

The predicate is gone (424 `:Psh $GEN/installed:` and the script), the split holds (306
build/install pairs), and the phase's stated proof has now been **run on the machine**: touch
`cmd/basename.c`, run `ipnxbuild`, and the log carries exactly one compile —
`cc -Od2 -o basename basename.c` — with everything else `up to date`. A second untouched run
exits 0. No run of the old build system ever did either.

Getting there surfaced four behaviours of V10's own mk, each measured on the machine and each
now recorded where it is worked around:

- **A multi-target invocation mis-handles a shared missing intermediate.** `mk tek hplot
  trplot penplot` with two targets already present links `trplot` against a `driver.o` nothing
  built. Reproduced against the host build of mk with the same command. Every multi-target
  child call in the mkfile is now one `mk` per target.
- **A wide virtual aggregate dies at its first fork.** `build:V:` over 300 artefacts — or over
  four virtual quarters — fails with `mk fork: Not enough memory`; each quarter alone runs to
  completion. `ipnxbuild` drives four quarters as four processes.
- **The arithmetic behind that is the swap slice.** `ra.c`'s partition `b` is 20,480 blocks —
  10 MB — and V10 reserves swap eagerly per process. The glob prerequisites an earlier attempt
  added (every package's `*.c` as prereqs) fattened mk's graph enough that child forks began
  failing. The globs are gone; each package artefact now depends on a **virtual probe** that
  runs the package's own mk — the child owns its source dependencies, is one fork and a few
  stats when clean, and touches the artefact only when something was stale.
- **mk stats a node once.** A file the probe's child creates is still `absent` to the parent,
  so every probed artefact carries a `test -f` recipe: mk re-stats the target after it runs,
  and a package that failed to produce its artefact becomes one honest line.

The remaining failures in a full `ipnxbuild` are **14 packages, all source- or
toolchain-level** — at, awk, cref, eqn, neqn, grap, pic, gre, qsnap, sign, struct, spell,
worm, libdmalloc — the same class of per-package porting the pascal work was, and none of them
a fault of the build system. (worm's was the one true self-reference in the tree:
`CFLAGS="$CFLAGS -A"`, which make resolved from the environment and mk expands for ever; fixed
in its mkfile.)

### Phase 4 — `/usr/src` as the unit — *reversed by decision*

Run on the machine and then **reversed**: once `taripnx` existed, the archive of record had to
carry the whole of `/usr` — `blit`, `jerq`, `630`, `maps`, `vol2` live beside `src` and were
falling out of every tar of `src` alone — so `ipnx.tar` became **a tar of `/usr`**, and `sys`,
`man` and `include` moved back out of the source tree to live at `/usr` directly. The `$INC`
and `$MAN` install rules dissolved with the move: those trees now live at their installed
paths. `build/usrtrees` is the single statement of the shape — `taripnx` tars exactly its
list, `mkv10`/`mkipnx`/`mkimage` build to it and verify against it — because a component list
that appears twice will disagree. `bin` and `lib` are absent from the list deliberately:
they are product, not shape, installed onto a disk by a running machine and never carried.

What follows below in this section is the record of the earlier direction — kept because it
ran and its measurements are real, but every "under `/usr/src`" statement in it is the state
the reversal undid.

`include` (338 files), `man` (1,523) and `sys` (1,138) were under `/usr/src`, and the build
installed them out. `mktape`'s `mv /v10/usr/src/sys /v10/usr/sys` was retired, and is back
in spirit: `mkv10` performs the move once at assembly, and a machine already carrying the
old layout is migrated by `updatebuild` — `sys` moved out by one rename, `man` replaced,
`include` **merged file-by-file, only-missing** (the installed tree holds lcc's headers,
`stdlib.h` and every in-place repair; an `rm -r` here once took a clone's compilers down).

**The tape's shape was never the installed shape**, which is what made this the right move
rather than a rearrangement. `mktape:85` justified the move with "the kernel is /usr/sys on a
running machine" — true, and not what the tape ships: it ships `src/sys`, and the mv existed
only to undo that. The include tape was already untarred straight into `/v10/usr/src/include`
because `libc/mkfile:150,155,205` name `/usr/include/libc.h` as an absolute prerequisite, so
that tree was source-in-`/usr/src`-installed-out from the start. `man` was neither: nothing
installed it, because stage 8 never ran.

- `mkfile:128` is `SYS=$SRC/sys`; mk resolves `/unix` to depend on
  `/usr/src/sys/astro/ipnx-v10.u` and the kernel rules to `/usr/src/sys/lib/*`.
- `$MAN` is a new sentinel (`$ROOT/usr/man/man1/a.out`) with a rule modelled on `$INC`'s —
  tar out, tar in, no pipe, for the reason `$INC`'s comment already gives.
- `world` lists `$MAN`. 745 rules and 5 metarules by mk's count.
- `tools/v10-dist.py`'s placement table now says `usr/src/{man,sys,include}` with the tape
  evidence for each, so a re-run does not undo this; `tools/v10-proto.py` reads
  `v10/usr/src/sys/lib/tab`. `tools/v10-check.py` still reports VALID.

*Run on the machine:* starting from an image still carrying the old layout, `updatebuild`
migrated it — `mv /usr/sys /usr/src/sys` (one rename, same filesystem), `/usr/src/man` filled
file-by-file from the repository (tar dies with a bus error when its working directory is on
the share; ls and cp are how every build reads its source), 432 tree build files shipped from
the manifest — and the next `ipnxbuild` built through all four quarters and exited 0, kernel
included: `ipnx-v10.u`, from the migrated tree, with spipe in io.a.
That is a guest run.

`CLAUDE.md` describes `v10/usr/sys` as the kernel's home, which the reversal made true again.

*After the reversal, on the machine:* the ship channels themselves needed the same audit as
the shape. updatebuild's mkfile loop read the **guest's** manifest (refreshed only by the
end-of-run handoff, so new rows never shipped) and gated on `/usr/src/`dirname`` while rows
had become /usr-relative — every row silently skipped. All three lists (mkfiles, casefix,
arcfix) are now read from `$REPO` directly. The tar of `/usr` also widened the case and
archive discipline to the beside-src trees — blit, jerq, 630, vol2, include — 29 archive
rows and 17 case rows classified from the repository and the tape manifests
(docs/v10-log/2026-08-29.md has the evidence); PDP11's four generated mkfiles were removed
as inventions, that tree building with `make` from its own Makefiles as it always did.

### Phase 5 — the archives and the verbs — *done*

**Three archives, each answering a different question.** `mkv10` replaces `mktape`: the six
tapes in, `v10.tar` out — pristine, one name per path, nothing of ours in it — so a question
about the tapes no longer means fetching 430 MB and blanking ra1. `mkipnx` is that plus
`/usr/src/build`, written as `ipnxorig.tar`: the starting point for a build from nothing.
`taripnx` replaces the old `mkipnx` and archives a machine that has already built. Only the
last one contains binaries.

`taripnx` archives **`/usr/src` alone** — which Phase 4 is what made possible. The old script
had to take all of `/usr`, and said why: "a disk that gets only src cannot build: it has no
`/usr/include`, so `libc/mkfile:150`'s absolute `/usr/include/libc.h` cannot be resolved".
With include, man and sys inside `/usr/src` and installed out, that reason is gone.
`/usr/bin` and `/usr/lib` are build products and are not archived.

`mkv10` is **the only command that reads `casenames`**, and the table was rewritten as a plain
mapping derived from the tree rather than from the decisions: `NAME <tape path> <our path>`,
`DROP <tape path>`, 162 and 102 records, no path in both. The earlier version described the
tree as it was *before* the swaps were applied, which would have renamed `doprnt.S` back to
the spelling the build does not read.

`ipnx.tar` and `v10.tar` live at `/usr/ipnx/`: outside the tree `taripnx` walks, and not part
of the build system, which they are not. `mkimage` reads from there and gives the new disk its
own copy in the same place. The bootstrap is now `mkimage, mkv10, mkipnx, mkimage`.

**`mkbuild` is kept deliberately**, against the plan's own wording. It is the one file list —
`updatebuild` and `mkipnx` both call it rather than restating eighteen names and nine
subdirectories, and a component list that appears twice will disagree. It did: adding
`updatebuild` to the repository copied everything except `updatebuild`.

*Retired:* `mktape`, and the old `mkipnx`. No reference to either survives in the build kit —
including the three in `patch`, one of which had the `sys` move as its stated premise.

### Phase 6 — mk everywhere — *497 of 503 converted; the 6 left hold no build commands*

**The conversion is a correctness change, not a style one**, and every item below was
established by running mk, not by reading it. Nine make constructs differ, and six are
*silently* wrong — a file left unconverted builds and looks fine:

- **`$(VAR)` is shell command substitution.** mk's `varsub` takes `${VAR}` and bare `$VAR` only
  (`quote.c:202-205`), so `$(VAR)` reaches the recipe's `/bin/sh` intact and the shell tries to
  *execute* `VAR`.
- **`.c.o:` is an ordinary target to mk.** A suffix rule left alone does not fail — mk quietly
  uses its own built-in `%.o: %.c`. The recipe that ran was `cc -c x.c`, not the file's own.
- **A rule colon must be followed by space, tab, or an attribute list** (`parse.c:139`). make
  accepts `lalex.o:lalex.c`; mk calls `l` an unknown attribute. mk's attribute set is
  `< D N P Q R U V`, so `:&` — another dialect's — goes too.
- **An assignment whose value contains `=` is a syntax error**, reported on the *following*
  line. `PPFLAGS=-DDFSIZ=8192`. The inner `=` is escaped.
- **A column-0 comment inside a recipe ends the recipe**, orphaning every line after it; an
  indented one does not.
- **A blank line before a recipe line ends the recipe** — and the lookahead has to skip
  comments, because `basic/basic` writes `<tab>cmd / blank / #banner / <tab>cmd`.
- mk honours neither `-` nor `@` — and stripping one tab before looking for them misses every
  recipe indented with two, which is how `basic/basic` writes its ed scripts.
- `$@`/`$<`/`$*`/`$?` → `$target`/`$prereq`/`$stem`/`$newprereq`.
- `include f` → `<f`, **and the include target itself**: `include ../tst/makefile` became
  `<../tst/makefile`, pointing mk at a file still written in make, which is why six `lcc`
  directories failed on their parent rather than on themselves.

**Two hazards checked; one absent, one real.** mk joins every recipe line into a *single* shell
invocation where make runs each in its own, so a bare `cd sub` alone on a line means opposite
things — no converted mkfile has one. But `"` is a quote character to mk's parser, so `\"`
loses its backslash: `blit/src/proof/host` and `jerq/src/proof/host` build four `-D` whose
values are C **string literals**, and cc would have received an expression. Those two got
hand-written mkfiles that move the quoting to where quoting belongs — `'"'`, supplied by the
shell — which reproduces make's `-DJERQM="/usr/jerq/mbin/proof.m"` exactly, verified by
preprocessing a file and reading back `char *p = "/x/y";`.

Writing them also turned up **damage in the tape**: `blit/src/proof/host/makefile` carries, twice
at column 0, `.$(JERQFONT) -DJLD=\"$(JLD)\" -c main.c` — debris from a mangled continuation, the
recipe above it already ending the same way. make reads it as a target nothing asks for, so it
has never been noticed. The mkfile records it and does not carry it over.

*Done:* **497 of 503 makefiles converted**, every one **parsed by mk before it was written**, and
463 superseded makefiles stamped `HISTORICAL`. 173 mkfiles became 636. `eqn`, `f2c` and `cbt`
all have one.

**The six that remain contain no build commands at all.** That is a better reason than "they
are nmake", and it took reading them rather than their first line. Three are a single line —
`:MAKE: lib - cmd`, `:MAKE: probe - ccc cpp - *`, `:MAKE: libx - *` — nmake's recursive
descent, which mk expresses in three lines. The other three are declarations, not recipes:

	odelta :LIBRARY: update.h suftree.h delta.c mtchstring.c suftree.c update.c
	pax :: RELEASE HISTORY pax.1 pax.h bio.c convert.c ... -lodelta -lx
	x $(VERSION) :LIBRARY: ... with `.SOURCE :' search paths over ten directories

nmake infers the compile, the archive and the link from those; there is not one command in the
122 lines. Converting them therefore means **authoring** the build nmake would have inferred —
every `-I` from `.SOURCE.h : include`, the two archives, the link order — for a package the
distribution does not build: the mkfile's only mention of `odist` is a comment. That is
inventing work, not finishing it.

**All but one call site now runs mk.** 155 switched, and none blind — a site moved only where
the directory's mkfile actually defines the target asked for, with that mkfile's *own* variables
expanded first (`netfs/libnetb`'s target is `$L` and `libcc`'s is `${ARCHIVE}`; a literal match
missed both). Three needed the call site corrected rather than switched: `libcbt` and `sign`
have the tape's own mk-native mkfiles, which name `libcbt.a` and `$X` and have no `all` — the
`make all` was written against the makefile beside them. And `apsend` needs no rule at all:
it is a checked-in binary with no source, and mk reports an existing ruleless file
`is up to date`.

**Five `make` words remain and four are prose inside comments.** The one real invocation is
`cd $CMD/postscript; make -f postscript.mk ROOT=$ROOT install`, and it is a **decided
delegation, not an unconverted file** — the mkfile has carried the reason since before this
work: `postscript.mk:105` is `SYSTEM=V9`, the nearest thing the package offers to a Tenth
Edition, and `:111-117` put FONTDIR, HOSTDIR, MAN1DIR, POSTBIN, POSTLIB and TMACDIR all under
`$(ROOT)`. The package configures itself for our root, which is precisely why the build hands
the job to it.

Converting it would be a port rather than a conversion, and measured rather than assumed: 219
lines that re-invoke themselves — `$(MAKE) -e -f $(MAKEFILE) ACTION=$@ $(TARGETS)` — to fan a
verb out over eleven subdirectories, then recurse again into each one's own `.mk`; `-e`, so the
environment overrides the file; and `$(TARGETS) ::`, a double-colon rule, which mk has no form
of. Reimplementing that in mk means reimplementing the self-configuration the comment above the
call site exists to preserve.

**And one more mk/make difference found on the way: mk has no implicit `%: %.c`.** make links a
single-file program from its source automatically; mk answers `don't know how to make 'prog'`.
Its whole built-in set is `%.o:` from `.c .s .f .l .y` and nothing else.

*Two things the parse test surfaced that are not conversion faults:* mk resolves `<path` against
the **cwd**, not the including file, and make resolves `include` the same way — so `lcc/gen2`'s
chain fails identically before and after. And an included fragment cannot be parse-tested alone:
`lcc/c/makefile:30` is `$(OBJS):`, and `OBJS` is defined by whichever file includes it.
