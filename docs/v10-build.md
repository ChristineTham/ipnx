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

### Phase 2 — one name per path

Apply Rule 0. The ~19 real-code cases individually; the rest mechanically. Record the table
where `mkv10` will read it. Then `v10-tree.py`'s computed renaming should find nothing to do.

*Proves it:* `git ls-files v10 | grep -c u_` is 0, and a case-insensitive checkout of `v10/`
has the same file count as `/usr/src`. *Unblocks:* phase 5, and it retires the whole class of
`patch` block that repairs a name this project's own tooling changed.

### Phase 3 — dependencies

Delete `build/installed` and every `:Psh $GEN/installed:` with it. Turn `.patched` and
`.ranlib` into ordinary targets with `patch` as a prerequisite. Make the install-out step
unconditional. Delegate each package's up-to-date decision to its own build file.

*Proves it:* touch one source file, run `ipnxbuild`, and exactly the affected objects rebuild
— which no run of this build system has ever done. And `rm -f .patched` never appears again.

### Phase 4 — `/usr/src` as the unit

Move `include`, `man` and `sys` into the source tree and install them out. Retire
`mktape:79`'s `mv /v10/usr/src/sys /v10/usr/sys` — the tape's shape stands and the build does
the moving.

*Proves it:* a disk holding only `/usr/src` plus the boot toolchain builds to completion.
*Unblocks:* phase 5.

### Phase 5 — the archives and the verbs

`mkv10` (reading the phase-2 table), `mkipnx`, `taripnx`, `mkimage` on the new flow,
`ipnx.tar` at `/usr/ipnx/`. Retire `mkbuild` and `mktape`.

*Proves it:* `mkv10` twice produces byte-identical `v10.tar`; `mkipnx v10.tar` then
`ipnxbuild` gives a working machine; `mkimage` makes a disk from a blank ra1 without a
hand-typed step.

### Phase 6 — mk everywhere

344 conversions. `$(VAR)`→`${VAR}` is 219 files and mechanical; the 81 that need real editing
are identifiable up front. Revive the five mkfiles that are newer than their makefile, write
new ones for `eqn`, `f2c` and `cbt`, stamp each superseded makefile `HISTORICAL` as part of
its own conversion.

*Proves it:* the mkfile drives everything with `mk` and no `make`, and the four `patch` blocks
that exist for make's exec behaviour are deleted. *Unblocks:* the v11 port system.

Phase 6 is the largest and the least urgent, and it is the only one that can run in parallel
with the others — its per-directory work does not touch what phases 3 to 5 change.

## What this does not settle

- **Whether `ipnxbuild` refuses to run with `/n/macos` unmounted, or falls back to the
  machine's own `/usr/src/build`.** Refusing means never building stale; falling back means
  still working with the share down.
- **`cbt`/`libcbt`** — same-day mkfiles with opposite verdicts, needing a read rather than a
  rule.
- **The `Readme`/`readme` class** (58 paths) — how many are the same text, which only a diff
  answers.
- **Whether the 320 directories with no mkfile convert in one pass or per package**, and in
  what order relative to the case work. Both touch the same files.
