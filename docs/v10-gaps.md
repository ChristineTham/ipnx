# What the V10 build did not do

*A file-by-file reading of `v10/usr/src`, 2026-09-17. Eight partitions, every one of the 670
directories walked in full, every claim cited to a file and line and checked against
`v10/usr/src/build/mkfile` before being called missing. The items in §1 were re-verified
mechanically against the tree; the rest carry their evidence and need a person to accept
each one.*

*Much of it has since been acted on — §0 says what, and marks the four places where the
reading below was **wrong**. The evidence is kept as it was written, with the status added
beside it, rather than rewritten to match the result.*

**The pattern the reading found: the build installs programs and not the data they read, and
not the ownership they need.** Nothing fails at build time when it doesn't — the program is
there and says `cannot open` the first time someone runs it. A second pattern sits behind
several entries in §3: the mkfile declines a package with a stated reason, and the reason is
contradicted by the tree.

## 0. Status

*Status pass, 2026-09-17, after the reading below was acted on, **and then checked against a
running machine**. open-simh was built from the pinned revision on this Linux host, the
committed golden was extracted and booted, and the claims were put to it one at a time with
`tools/v10drive.py`. That is what the "measured" notes below mean; where a claim is still
only read off the files, it says so.*

**What the machine confirmed.** `man ls` answers `nroff: cannot open file
/usr/lib/tmac/tmac.an`. `nm /usr/bin/awk` lists symbols where `nm /bin/ls` says `no name
list`, so the strip rules did leave their binaries unstripped. `/usr/lib/uucp`,
`/usr/lib/learn`, `Rpull`, `Rpush`, `grap.defines`, `vaxspitv35.err` and `tabset` are absent;
`/usr/lib/dict` is an empty directory; `at`, `ct`, `oops`, `load` and `server` carry no
set-id bit; `dump` is in `/usr/bin`; `/usr/lib/plot` holds `hplot`.

**What it refuted — three of the fixes were wrong.** `macrunch` does not parse under V10's
`sh`, so the macro packages could not be built at all until `build/patch` repaired it; with
that in, `man`, `-ms` and `-mm` all work. `psych` and `rain` do not link (`Undefined: _cont`
and `Undefined: _gtty _stty`) and the mkfile already said so in notes this reading missed, so
they are backed out. `ideal` builds two of its four filters, not four — `tfilt` (its default)
and `texfilt` build; `4filt` and `pfilt` want the classic plot(3) that only
`libplot/oldplot` has.

**Still only read, not run:** the ownership and set-id installs (their primitives are
measured — numeric `/etc/chown`, `chmod -rw,+x,g+s`, `: >>` — but not the rules), and the
`pascal`/`picasso`/`cyntax` ROOT fixes, which need a `mk ROOT=/v10 world` against a second
disk.*

**Done.** All of §1. In §2, every product the build actually installs. In §4: the macro
packages, uucp's destinations and set-uid bits, `/usr/lib/tabset`, `grap.defines`, matlab's
help database, spitbol's error text, atc's flow files, dict's ten helpers, worm's six,
ideal's four filters, `lcomp`, learn's whole lesson tree, `Rpull`/`Rpush`, and `canfield`,
`psych` and `rain`. In §3: the reasons recorded for `ancient.nroff`, `learn` and `dk`'s four
`/etc` programs have been replaced with ones the tree supports.

**Four claims in the reading below were wrong and are corrected in place**, each marked
*CORRECTED*: cyntax's leak is real but one level lower than stated; `ex`, `struct` and
`apsend` do not take the ownership the §2 table gives them; `ideal` was broken in its
*default* mode, not merely in `-p` and `-tex`; and `refer`'s `lookbib` and `pubindex` are not
V10 commands at all.

**Three more `strip` defects** of the same shape as §1.1 were found by a better detector and
fixed with it.

**Still open**, and each needs a decision rather than a patch: the rest of §3 (fifteen
packages declined for a reason the tree contradicts — the decision may still be right), §5
(data no tape carries, which is the `/usr/dict` import), §6, and `ipc/`, which is essentially
unbuilt.

### Second status pass, 2026-09-18: the failures a full `ipnxbuild` reported

*The golden rebuild of 18 Sep produced **nine** `FAILED` lines, and a tenth appeared on the
build that verified the fixes. All ten are fixed and each was measured on a booted machine,
not read off the files. Two had a cause nobody had looked for, one of those two had been
hiding behind a workaround, and one is a defect that only shows on the SECOND build of a
disk.*

**The count was first reported as five, and that was a grep and not a fact:** the pattern
used to count `FAILED` lines allowed no space in the name, so `pascal pc`, `pascal pi`,
`pascal px` and `pascal pxp` were invisible in a file they were sitting in. Four of the ten
below are those.

| Reported | Root cause | Fix |
|---|---|---|
| `cyntax: FAILED` | `install:` with an empty recipe: an ordinary make idiom that `mk` treats as an error (`mk/src/recipe.c:19-27`), so `mk install` stopped in `sets/` before `cyn`, `cem` or `lib` ran | `:V:` on the phony targets in the four subdirectory mkfiles |
| `sign: FAILED` (twice) | `sign/mkfile:15-19` runs `cyntax` twice per program, and `/usr/bin/cyntax` is a PKG target built *after* the `/usr/src/cmd` pass that first needs it | `$ROOT/usr/bin/cyntax` added as a prerequisite of `P_CMD_sign_verify` |
| `backup.old: FAILED` | `Can't find /lib/ccom` — `cc.c:384` prints that for *any* `execv` failure, and the one that happened was ENOMEM: the machine had 10 MB of swap, not the 254 MB its config declares | the swap minors, below |
| `9pfs: FAILED` | `cp: /etc/9pfs: Text file busy` — the build overwrites the binary that is serving `/n/macos` at that moment | copy-new-then-`mv`, the `/bin/sh` precedent |
| `spell: FAILED` | the same swap shortage as `backup.old`; the workaround that hid it had shrunk `pcode`'s arrays | swap fixed, the shrink backed out |
| `pascal pc: FAILED` | `./install.sh` is mode 644 — `sh: ./install.sh: cannot execute` | `sh ./install.sh` |
| `pascal pi: FAILED` | `RM = -rm -f`: make's ignore-the-status prefix, which `mk` does not strip — `sh: -rm: not found`. Behind it: nothing knew how to make `y.tab.c`, and then nothing made `y.tab.h` | `RM = rm -f`; `y.tab.h y.tab.c:` as one rule's two targets; `mk y.tab.h` asked for by name |
| `pascal px: FAILED` | `${PSHDR}:` with `cp ${PASCALDIR}/$target $target`, converted name-for-name from the tape's `$@` — but mk's `$target` is the **whole** out-of-date target list, so cp got eight arguments. Behind it: `utilities.o`'s whole recipe was the tab-indented `make depend` banner | one rule per file; banner unindented |
| `pascal pxp: FAILED` | `treen.c` and `treen.s` both present and mk's builtins make `.o` from either — `mk: ambiguous recipes` | explicit `treen.o: treen.c` (the `.s` is Berkeley's PDP-11 hand assembly); `AS= -as` fixed with it |
| `ether: FAILED` *(second build only)* | `ipnxbuild` restores the tape's `/usr/include/sys/ethernet.h` with `cp`'s mtime at the end of every build, so the next build finds it newer than `cmd/ether`'s own header, skips the copy, and compiles `netconfig.c` against a header with no `CHANS_PER_UNIT` | `rm -f` the destination before the package builds |

**The swap was declared and never attached, and that is the find of this pass.**
`ipnx-v10.m` asks for three swap areas totalling 254 MB. `io/sw.c:28-38` frees only
*index 0* at boot; every other area is freed by `swapon(2)`, which `/etc/rc` calls as
`swapon -a`. But `sw.c:108-118` matches the named block device's `rdev` against `swdevt[]`,
and the config named partitions c and d as `ra 02` and `ra 03` while `/dev/ra02` and
`/dev/ra03` are minors **66 and 67** — `0100` is the bitmapped-filesystem bit (`io/ra.c:34-35`),
set on every section `v8/proto-dev` carried a filesystem on. So every boot this project has
logged printed

```
Adding /dev/ra02 as swap device
/dev/ra02: No such device
```

and the machine ran on `ra0b`'s 10 MB — worse than not declaring the areas at all, because
`swstrategy()` stripes the map across all `nswdevt` devices whatever their state, so two
thirds of the stripes belonged to areas nothing had freed. Declaring the minors as `0102`
and `0103` fixes it; the bit is invisible to the driver (`UNIT()` masks it with `027`,
`PART()` with `07`) and a swap area has no filesystem to read it. Measured after: all three
`swapon` calls answer `In use`, `backup.old` builds, and `spell` builds with the tape's own
array sizes.

**And a delivery gap that would have made that fix dead code.** `$SYS/ipnx/ipnx-v10.m` and
`$SYS/ipnx/mkfile` reached a machine by one route only — `build/patch:2244,2255` — and
`patch` runs only when `$CMD/.patched` is older than `patch` *itself*. So an edit to the
**configuration** reached a guest only if the **script** happened to change in the same
round. Measured: after `updatebuild`, `/usr/src/build/src/ipnx-v10.m` carried the new text
and `/usr/sys/ipnx/ipnx-v10.m` did not. Both files are now targets in `build/mkfile` with
the repository's copy as their prerequisite, `cmp`-guarded so an unchanged `.m` does not
re-date itself and rebuild the kernel every round.

**The result, measured.** A full `ipnxbuild` on a disk that had already been built once --
which is the case that exposes `ether`, and a case this project had never run -- reports
**no `FAILED` line at all**. `/usr/bin/cyntax`, `/usr/bin/sign`, `/usr/bin/pxp`,
`/usr/ether/netconfig`, the nine products in `/usr/lib/pascal` and a 164,882-byte
`/usr/lib/spell/brspell` are all there, and `/etc/9pfs` is replaced while it is serving the
share it is replaced through.

**This repository had already diagnosed the bug once and not generalised it.**
`build/mkfile:4429-4433` — the `cbt` rule — reads *"cbt's mkfile is the tape's own, and its
`all: $ALL` has no recipe … Naming them sidesteps the aggregate without touching the tape's
file."* That is exactly right, and it was applied to `cbt` alone. The same empty recipe sat
in three of `cyntax`'s four subdirectories, on `install`, which the build *does* call.

**The `mk`/`make` idiom is a class, not one package.** A scan of all 670 mkfiles for a
target with no recipe in any rule naming it found **21 more** in 19 files, all phony
(`all`, `install`, `clean`, `clobber`, `start`, `sources`, `compilations`, `allprogs`,
`mkdirs`, `dist`). None is on a path the build takes today — which is why only `cyntax`
ever failed — and all are now `:V:`. Two idioms were deliberately left alone: `FRC:` (in
`sh`, `monk`, `prefer/libux3`) and `force:` (in `gcc`) are make's "always out of date"
marker, and `:V:` would invert their meaning; nothing requires either of them today, and
`sh/mkfile:2` is `FRC =` — empty — so the reference expands to nothing.

**One more of the same shape, not fixed:** `cmd/cfront/mkfile:2-3` shells out to `make`,
exactly as `cmd/cyntax/mkfile` did until this round. `cfront` is in no build list, so it
costs nothing today.

**Two properties of `mk` that this round had to learn the hard way**, both of which make a
dependency silently not happen:

1. **A missing prerequisite is time 0, so an existing target is up to date.** Removing
   `/usr/include/sys/ethernet.h` to force `cmd/ether`'s copy rule did the opposite: with
   `order.o` and `findslot.o` already built and newer than a file that was not there,
   `libether.a` read as up to date and the copy was never required. The remedy is to do the
   copy outside `mk`, which `build/mkfile` now does.
2. **`mk` *pretends*.** `mk/src/mk.c:136-145`: when a target does not exist and its **parent**
   is not out of date against it, mk marks it MADE with its own prerequisite's time instead
   of building it. So `pi/mkfile`'s `yy.h: y.tab.h` is inert — `yy.h` is a source file that
   exists and is newer than `pas.y` — and every object compiles against a `yy.h` whose
   `#include "y.tab.h"` cannot resolve. Pretending is guarded on the parent, so it cannot
   happen to a target named on the command line: `mk y.tab.h` builds it where any number of
   dependency lines will not.

**A recipe made only of comments is a recipe.** `make depend` writes a three-line banner
indented with tabs; make drops a comment-only recipe, mk hands it to `sh`, `sh` does nothing,
and mk records the target as made. `cmd/pascal/px`'s `utilities.o` was one of these — the
link then said `ld:utilities.o: cannot open`. A scan found nine rules whose entire recipe is
comments; three are real objects (`px`'s `utilities.o`, `pi`'s `yytree.o`, `libpc`'s
`WRITLN.o`, plus `lbin/kermit`'s `ckuscr.o`) and the rest are phony targets where it is
harmless. All are unindented now.

**`$target` is the whole list, and `learn` had it too.** Eight rules in the tree have more
than one target and use `$target` in the recipe. `cmd/learn`'s three (`lcount tee`,
`play log`, `${LESSONS}`) would each have produced one command with every name in it the
first time more than one was out of date; they are `for t in $target` loops now.
`lbin/Mail`'s `$S: sccs get $target` is left — `sccs` is on no tape and `lbin/Mail` is not
built. `pi`'s `${SRCS} ${HDRS} ${OTHERS}: touch $target` is correct as it stands.

**Two more mkfiles still shell out to `make`**, the defect that cost `cyntax`:
`ncurses/terminfo/mkfile:6` and the five `libplot/oldplot/*/mkfile`. Neither package is in a
build list, so neither costs anything today.

**A restore that defeats a dependency, and it alternates.** `build/preserve` names the tape
files a rule rewrites in place so a built-and-cleaned tree still matches the archive, and
`ipnxbuild` copies each back at the end of the build. `cp` has no `-p` on V10 and there is
no `touch(1)` taking a time, so the restored file carries a *later* mtime than anything the
build made — and where the rule that overwrote it compares mtimes, the next build skips it.
`include/sys/ethernet.h` is the one that bites: `cmd/ether`'s header and the tape's are
different files with one name, and `netconfig.c` needs the former's `CHANS_PER_UNIT`. So a
disk that has never been built passes and every disk that has does not. **It is worth asking
whether any of the other 24 preserve rows have the same shape** — this one was found only
because a second build was run on the same disk, which this project had not done before.

**And the kernel config had two copies, which had drifted in both directions.**
`build/src/README` says outright that `ipnx-v10.m` is "written here and not in
`v10/usr/sys/ipnx`" — and a second copy was in `v10/usr/sys/ipnx` anyway, read by nothing.
The tape-drive panic measurement of 17 Sep was only in that one; the RA81/RA73 sentence was
newer in the shipping one. `ipnx.mkfile` had the same duplicate, byte-identical only by
luck. The note is merged into the shipping copy and both duplicates are gone.

**One inconsistency found while working and not yet resolved:** `build/mkfile:23-26` says the
`./installed` predicate "is gone", and there is no `:P` attribute and no `installed` script
anywhere — but six comments still describe it as live, including the one that justifies the
whole `config:V:` target. Either those comments or that target's reason needs rewriting, and
which one is a question for whoever knows why `config` was added.

## 1. Defects in the build as it stands

These are wrong today, independent of any missing install, and each is a small fix.

**1.1 Twenty-four `strip` commands address a path that cannot exist.** The rule is
`cp a.out $ROOT/usr/bin/awk` followed by `strip $ROOT/usr/bin/awk/a.out` — a path *under* a
regular file. Every one fails with ENOTDIR, is swallowed by `|| echo '…: install FAILED'`,
and leaves the binary unstripped while the log reports a failure that is not one.

```
564  sort      2545 last      3251 eqn      3568 spitbol   3995 ideal
583  ranlib    2573 logtty    3261 neqn     3735 compat    4147 ex
2219 byteyears 2799 setpart   3343 m4       3908 learn     4169 grap
2293 cpio      3196 awk       3387 pic
2380 dis       3210 cb        3417 ratfor
      3241 efl       3437 snocone
```

`3825` is the twenty-fourth and a different shape: `strip $ROOT/usr/lib/apsend
$ROOT/usr/lib/apsend/apsend.mkhd`, whose first argument is the directory `mkdir`'d three
lines above, so *both* files ship unstripped.

**FIXED**, and **three more of the same shape were missed by this reading**: `troff`'s
`strip $ROOT/usr/bin/troff/a.out`, and `ex`'s `$ROOT/usr/lib/ex3.7recover/exrecover` and
`.../ex3.7preserve/expreserve`, where the parent in each case is the installed file. The
detector that found only 24 matched a `cp` against the line after it; troff's `strip` is
eight lines below its `cp`. The right test asks of every `strip` argument whether the build
ever creates its parent *directory* — that finds exactly 27 and now finds none. `ex`'s two
`chmod`s also moved to after its `strip`, because `strip/symwrite.c:66` rewrites the file
with `creat(2)`, which on a file that exists takes the mode already there.

**1.2 Three packages install to the builder rather than to `$ROOT`.** This is the most
serious item here: `ipnxbuild /v10` silently writes onto the running machine.

- **pascal** — `build/mkfile:4248` passes only `B=$ROOT/usr/bin`, and `pascal/mkfile:21` is
  `for i in ${DIRS}; do (cd $i; make -o; make -o install); done` — the sub-makes get no `B`,
  `L` or `DESTDIR`, and `px/makefile:4` and `pxp/makefile:2` assign `DESTDIR=` empty so the
  environment cannot reach them either. Everything but `/usr/bin/pascal` lands on the
  builder; `$ROOT/usr/lib/pascal` is created and left empty.
- **cyntax** — `build/mkfile:4109` passes `BIN=` and `LIB=`, but the recipes ignore them:
  `cyn/Makefile:37` is `cp ccom /usr/lib/cyntax/ccom`, `cem/Makefile:38,41` are
  `cp cyntax /usr/bin/cyntax` and `cp cem /usr/lib/cyntax/cem`. The declared target
  `$ROOT/usr/bin/cyntax` is never created. *CORRECTED*: the fourth subdirectory, `sets`, is
  **not** a leak — `sets/mkfile:5` is `INSDIR = ../cyn` and it installs a build-time filter
  into a sibling source directory. And this is the worst of the three, because
  `lib/mkfile:2-3` are `CCOM = ${LIB}/ccom` and `CEM = ${LIB}/cem`: cyntax's libraries are
  generated by *running* what the two previous steps installed, so a `ccom` that went to the
  builder is a `libc` and `libj` that cannot be built for the target at all.
- **picasso** — `picasso/mkfile:1,63,65` are literal `/usr/…`; `build/mkfile:4250` runs
  `mk all INS=cp ROOT=$ROOT` and `ROOT` appears nowhere in that mkfile except an unused
  target. With no `/usr/lib/postscript` on the builder the `cd ${POSTLIB}` fails, the whole
  block returns non-zero, and `|| echo 'picasso: FAILED'` swallows it.

**ALL THREE FIXED.** Re-checked afterwards by asking, of every package whose own `install`
`build/mkfile` runs, whether any recipe beneath it copies to a literal `/usr`, `/bin`, `/etc`
or `/lib` path: six hits in three packages, of which only cyntax's three are in an install
chain. `picasso` needed a different fix from the other two — `picasso/mkfile:90` compiles
`-DGWBFILES="${POSTLIB}"` into the binary, so `GWB` cannot be moved to `$ROOT` and the
package's `INS` is left at its default `:` instead, with the copies done in `build/mkfile`.

**1.3 `dump` is installed to the wrong directory.** `build/mkfile:5078` installs
`$ROOT/usr/bin/dump`; `dump/Makefile:34` is `mv dump $(DESTDIR)/etc`, the man page is
section 8, and **the mkfile's own comment at :4060 says `/etc`** — three lines from rules
that wire `$ROOT/etc/config` and `$ROOT/bin/tp` correctly.

**1.4 `plot -Thp` and `-T2621` find nothing.** `plot/mkfile:4` builds the filter as `hplot`;
`plot/mkfile:15` and `man1/plot.1:66-73` and `man/filnam:355` all name the installed file
`hpplot`. `build/mkfile:4055` installs it as `hplot`. One word.

**1.5 `sail`'s log is truncated on every build.** `build/mkfile:4777` is an unconditional
`: > $ROOT/usr/games/lib/saillog`; `sail/makefile:118-121` makes it a *file target*, so the
tape creates it only when absent.

**1.4, 1.5 and 1.6 FIXED**, along with 1.3.

**1.6 `/usr/bin/cflow` ships mode 644.** `cflow/Makefile:28` copies `cflow.sh` with no
`chmod`, and `cflow.sh` is 644 in the tree. Every other script install in `build/mkfile`
carries an explicit `chmod +x`.

## 2. Ownership, set-uid and set-gid

The whole 5,219-line mkfile carries one `chown` (`sh`, :826) and two set-id installs (`ps`,
:802). Everything below is specified by the package and dropped by the build.

| product | required | evidence |
|---|---|---|
| `/bin/at` | set-uid root | `at/makefile:17-18` — and `build/mkfile:3644` *says* it does this; the recipe at :3654 does not |
| `/usr/bin/ct` | set-uid root (writes `/usr/adm/wtmp`) | `ct/mkfile:10-11` |
| `/bin/oops` | set-gid sys (Berkeley `ps`; reads `/dev/kmem`, mode 644) | `oops/makefile:7-11` |
| `/usr/bin/server` | set-uid daemon, set-gid sys | `server/mkfile:10-12`, `manx/server.1:14-17` |
| `/usr/bin/load` | set-gid sys (reads `/dev/kmem`) | `load/makefile:7-11` |
| `/etc/dkdialsub` | set-uid root | `dk/cmd/Makefile:48-51` |
| `/usr/games/rogue` | `chown games`, set-gid | `rogue/Makefile:57-59` |
| `/usr/games/sail`, `lib/saildriver` | set-uid daemon | `sail/makefile:106-113` |
| `/usr/bin/mailx` | mode 2511, `bin:mail` | `mailx/makefile:73` |
| `/usr/bin/inews` | mode 6755, user+group `news` | `netnews/src/Makefile:35` |
| uucp's four in `/usr/bin` | set-uid uucp | `uucp/mkfile:103-106`, `doc/rtmdiff/filemodes:22-39` |
| `/usr/lib/asd/mkspool`, `asdrcv` | set-uid | `asd++/Makefile:15-16`, `asd/install.asd:26-31` |
| `egrep` | `chmod 775`, `chown bin,bin` | `egrep/mkfile:11-12` |
| `ex` | `chmod 775` **only** | `ex/makefile:122` — *CORRECTED*: the `/etc/chown bin,bin` on :121 is commented out on the tape |
| `sign`'s four | `chmod 775`, no chown | `sign/mkfile:26-28`, `:4` for `$X` |
| `/usr/lib/struct` the **directory** | `chown bin,bin`, `chmod 775` | `struct/mkfile:23-26` — *CORRECTED*: the two binaries under it are only stripped and copied |
| `apsend` | nothing beyond `chmod +x` | *CORRECTED*: `apsend/mkfile:9` is the whole of it, and `build/mkfile` already did it |
| `/usr/games/lib/atc` | `chown bin,bin`, `chmod o-w,g+w` | `atc/Makefile:6-11` — not in the original reading |

**Blocker — RESOLVED for the products the build installs.** `uucp` (uid 48, gid 1) is the
tape's own number, from `parms.h:24-25` and again from `v8/etc/passwd`, which ships the
identical line; it is added. `games` (uid 49, gid 5) is **ours** — no tape names a number for
it, only `games/adv/adv.c:3013` knows the name — and it is added because rogue's score files
are a set-gid mechanism and every existing group already owns something (`bin` owns `/bin/sh`,
so a set-gid-`bin` rogue would be a game that can write the shell). `mail` and `news` are
**not** needed: `mailx`, `netnews`/`inews` and `/etc/dkdialsub` are not installed by this
build at all, so the three rows above that want them are moot until they are.

Every chown added names its **number**, not its name: `/etc/chown` resolves a name against
the *builder's* `/etc/passwd` (`chown.c:63`), never `$ROOT/etc/passwd`, and `chown.c:61` takes
a number without consulting any passwd. `chown1()` in `sys4.c` clears `ISGID` only for a
non-root caller, so chown-then-chmod is safe for a build that runs as root.

**FIXED**: `at`, `ct`, `oops`, `load`, `server`, `egrep`, `sign`, `struct`, `ex`, `rogue`
(with its two score files, which `rip.c:107` opens `O_RDWR` with no `O_CREAT` and nothing
created), `sail` and its driver and log, uucp's six, and atc's data directory.

## 3. Exclusions whose stated reason the tree contradicts

Each of these is declined in `build/mkfile` with a reason that is not what the files say.
The decision may still be right — the *reason* needs replacing before anyone can judge.

| package | the mkfile says | the tree says |
|---|---|---|
| `dist` | "`SYS` is set nowhere" | `conf/mkconf.v10:1` is `SYS=v10`, reached through two `<` includes. 21 products |
| `odist` | the same | `odist/mkconf.v10:1` likewise. Real blocker: `/usr/ape` for two of three subdirs; `odist/v10` builds with `lcc`. `pax` (a fourth `odist/` subtree — `libx`, `libodelta`, the pax/cpio/tar command, frozen as 1991 AT&T `ship` shipment archives) isn't one of those three at all: `odist/mkfile`'s own `DIRS=` never names it, and it has no `mkfile` of its own to run even if it were added — a `SYS` fix alone wouldn't reach it |
| `dimpress` | "`ARGS` is empty" | `dimpress/makefile:100` is `ARGS=all`. Real blocker: no `TABLES/` directory |
| `asd++` | "`$(ASD)` … the variable is empty" | `asd++/Makefile:5` is `ASD = /usr/lib/asd`. Real blocker: `CC = PTCC` |
| `basic/basic` | "no `libPW`" | the four routines used are in `basic/basic/PW/`; `LIBLD` is empty in `all` |
| `sky` | "`all:` with an empty recipe" | `sky/mkfile:1-4` has a four-line recipe producing `sky` |
| `sml` | "no build file at the top level" | `sml/src/makeml` is a 372-line driver with its own man page; `cd src; makeml -vax -v9` |
| `PDP11` | "only half of it is here" | `11as/` and `11c/` are both present; only the archiver is absent, which `README:19-28` says is not needed |
| `cfront` | "C++, deferred to V11" | scoped to seven named dirs; `cfront/demangle/` is plain C (`makefile:7` is `CC = cc`) |
| `learn` — **REASON REPLACED, PACKAGE NOW BUILT** | "nothing on the tape says where the lesson tree goes" | three files say it: `makefile:15` `LLIB = /usr/lib/learn`, `lib/src/README:3-4`, and `makefile:64-69`, the `check` target, which is a manifest of what `LLIB` must hold. 542 files in `lib/lib/`, not 519 |
| `dk`'s four `/etc` programs — **REASON REPLACED, DECISION KEPT** | "installed nowhere, exactly as the tape has it" | `dk/cmd/Makefile:49-51` installs all four and set-uids one. The reason that holds: none of the four is in any Admin list, and all four drive Datakit hardware this machine does not have. `Rpull`/`Rpush` from the same install **are** in `ulibfiles` and are now made |
| `libj`'s `jerq.h` | "the include tree already carries it" | `v10/usr/include/jerq.h` does not exist; the three other copies all differ |
| `chuck` | listed as not built at :3056 | and built at :5029 — to `/usr/bin`, where the package and `man8/chuck.8` say `/etc`. `upchuck`, which `rc(8)` invokes, is never built |
| `ancient.nroff` — **`macros.d` NOW BUILT** | "its install is `mv nroff /usr/bin`, over the link made here" | true of the parent; `macros.d/makefile:12-15,44-47` writes only `/usr/lib/tmac` and `/usr/lib/macros` and builds no binary but the `ntar` filter its own pipeline uses |
| `ncurses` | "its `libcurses.a` would land on the Berkeley one" | true of the library; `tic` and the terminfo database are a separate install and collide with nothing |
| `movie` | "the install target … copies nothing" | true of `movie/mkfile`; `blit.make:43-45` is a real install, and seven of the eight products need only `cc` |

## 4. Missing installs, with the sources present

*Most of this section is now done; each paragraph says which parts.*

**The macro packages are the biggest user-visible gap. FIXED.** Twelve `tmac` files are
installed where the tape's list names eleven — `makefile:6-7` omits `tmac.srefs` and
`tmac.s:55` is `.so /usr/lib/tmac/tmac.srefs`, so the tape's own `-ms` stopped at its
reference macros. Going the other way, `tmac.org:2` sources `/usr/lib/macros/org` and there
is no `org.src` anywhere, so `-morg` stays broken and `tmac.org` is installed as the tape
installs it.

 Nothing populates `/usr/lib/tmac`
or `/usr/lib/macros`, both named in `Admin/ulibfiles`, while `troff/tdef.h:13` compiles in
`TMACDIR "/usr/lib/tmac/tmac."`. So on this disk `nroff -ms`, `troff -ms`, `-mm` and **`man`**
all fail. Sources and rule: `troff/ancient.nroff/macros.d/{makefile:4-5,12-15,44-47}`. There
is a decision inside it — three different `-ms` copies exist in the tree (`macros.d/tmac.s`,
`/usr/man/man0/tmac.s`, `/usr/vol2/ms/tmac.s`) and only this one has an install rule.

**Whole configurations, never installed** — *partly CORRECTED*: `/usr/lib/uucp` (Devices, Dialers, Dialcodes,
Permissions, Poll, remote.unknown, uups, the `uudemon.*` scripts, and the generated
`Maxuuxqts`/`Maxuuscheds`) — and six uucp binaries are installed to `/usr/bin` while
`uucp.h:219-221` hardcodes `/usr/lib/uucp/` for them, with `uulog`, `uupick` and `uuto` not
installed at all. `/usr/lib/upas` routing configuration. `/usr/lib/learn` (six courses).
`/usr/lib/dict` (ten helper binaries built and discarded, so `/usr/bin/dict`'s every branch
execs something absent). `/usr/lib/tabset` (`termcap/makefile:12-14`).

*CORRECTED, and FIXED:* the uucp gap was not the whole directory. The **site** files —
`Systems`, `Devices`, `Dialcodes`, `Permissions`, `Poll` — the package deliberately does not
install: there is no `Systems` in the tree at all and the other four are in `samples/`, named
as samples, which `uucp/mkfile`'s `cp` target does not copy. They describe a site's modems
and neighbours. What *was* missing is now in: the destination of six binaries, three
commands (`uulog`, `uupick`, `uuto`), eight scripts, `Dialers`, and the set-uid bits.
`learn`, `dict` and `tabset` are also done. `/usr/lib/upas` remains open.

**Programs whose data was never installed — ALL FIXED but `sky`:** `grap` without
`/usr/lib/grap.defines`, so every `bullet` and `star` is an undefined name. `matlab` without
its whole HELP database, both pre-built and present — *CORRECTED*: the two halves of the tape
disagree about where it lives, `src/helper.f:10-11` (the reader) saying `/usr/lib` and
`helpset.f:6-7` (the generator) `/usr/local/lib`, and the reader is the one that runs.
`spitbol` without `vaxspitv35.err`, so every diagnostic is numeric. `sky` without
`/usr/lib/startab` — still open, `sky` is not built. `atc` without its flow files —
*CORRECTED*: a missing flow file is **not** an error, `aread.c:115-132` falls through and the
game plays with no traffic flow, which is not the game but is not a failure either. `rogue`
cannot record a score at all — `rip.c:107` opens the file `O_RDWR` with no `O_CREAT`.

**Binaries built and then dropped — FIXED but `backup.old`:** `worm` builds fifteen and
installs nine (`wdir wreset wmv wtmpdir wmount wcopy` missing). `ideal`'s output filters —
*CORRECTED*: there are **five** names in `ideal.cmd` (`tfilt`, `pfilt`, `4filt`, `texfilt`,
`idsort`) and `t` is the **default** (`ideal.cmd:5`), so plain `ideal file` was broken too,
not merely `-p` and `-tex`; `idfilt/makefile:24` is `install: 4filt tfilt pfilt texfilt`
*with no recipe*, so the tape builds four and installs none. `idsort` has no build rule
anywhere, so `-s` stays broken. `learn`'s `tee` and `lcount`. `lcomp`'s driver script,
leaving `/usr/bin/lprint` with nothing to drive it. `refer`'s `lookbib` and `pubindex` —
*CORRECTED*: these are **not** V10 commands. Neither has a manual page in `v10/usr/man`,
neither is in any Admin list, and `refer`'s own install target names neither; the tape's
decision to leave them stands and they are not installed. `backup.old`'s 23 — still open.
`canfield`, 1,145 lines of buildable curses game that appears **nowhere** in the mkfile while
every other unbuilt game carries a recorded reason — and `psych` and `rain` were the same,
all three now built. `boggle` stays out and now says why: `boggle/makedict` reads
`/usr/dict/words` and no tape carries `/usr/dict`.

**Links never made — FIXED:** `/usr/lib/Rpull` and `/usr/lib/Rpush` — `pull.c:10` and
`push.c:11` hardcode them as their server, so both installed binaries were inert, and both
names are in `Admin/ulibfiles`.

**`ipc/` is essentially unbuilt.** The tape's driver names five directories
(`libipc libin bin mgrs internet`); the build takes four files. `/usr/ipc` is not in
`usrtrees` at all, and `cyntax` is a hard prerequisite for the whole of it.

**`pico` is not built at all, not merely missing its data.** `cmd/pico/Makefile:12` links
`-lfb`, and `libfb` is on no tape — only the header `/usr/include/fb.h` survives.
Holzmann's own released VAX pico (spinroot.com/pico/pico.tar.gz) is byte-for-byte this same
tree and carries no `libfb` either; its symbol table settles it, holding `fb.h`'s declared
symbols and nothing from `framebuffers/`. No `mk`/`make` rule anywhere produces
`$ROOT/usr/bin/pico`. Its `defines` and `help` data (§5) are moot until the binary itself
exists.

## 5. Data that exists nowhere, so no build work will recover it

`units`' `/usr/lib/Units` — the program is installed and `units.y:375-381` makes a missing
table fatal, so `/usr/bin/units` cannot start. `fortune`'s `fortunes`. `quiz`'s `quiz.k/`.
`word_clout`'s `thes.packed` (760 KB), so the installed game fails on its first line.
`hangman`'s `/usr/dict/words` — V8 has it. `docgen`'s `mmdata`, `msdata` and `wr`, so `-ms`
and `-mm` mode have no data. `town`'s entire gazetteer.
`lex`'s `nrform`, so `lex -r` cannot work. `snocone`'s `epilogue`, which the compiler copies
onto the tail of every program it emits — and the stage-2 compiler is built by running the
stage-1 compiler, so it is produced without one, silently, exit 0. `trek`'s `/usr/lib/a68defs`
is the one recoverable case: `games/trek/a68.h` is the same macro set under another name.
`/usr/lib/tmac/tmac.pm`, the `-mpm` macro package — 43 mkfiles across `vol2` pipe their final
troff stage through `-mpm` (every paper under `eqn/`, `f77/`, `fm/`, `grap/`, `pi/`, `pic/`,
`pico/`, `pm/`, `preface/`, and more), and `vol2/pm/pm.ms` is itself Kernighan & Van Wyk's
paper *about* `-mpm` — but the macro file it describes, and the `pm` postprocessor named
alongside it, are on no tape and nowhere in this tree. Unlike `pico` (§4), no comment anywhere
records this as a known exclusion — it was never noticed, most likely because it's an implicit
dependency buried inside `vol2`'s own mkfiles rather than its own top-level `cmd/` directory.
Moot for `ipnxbuild` either way, since `vol2` ships wholesale via `usrtrees` and none of its
mkfiles are ever invoked automatically — but a real dead end for anyone who tries to typeset
one of those 43 papers by hand.

## 6. Divergences between the repository tree and the machine

**`qsnap`.** `qsnap/mkfile:14` names `Qsnap.c`; the checkout holds `qsnap.c` + `u_Qsnap.c`,
the inverse of what `casenames` produces on the machine, and `casefix:94` is a no-op against
it. The machine builds; a reader of `v10/` concludes it cannot. This breaks `casefix`'s own
stated invariant that the tree, the checkout and `taripnx`'s archive agree.

**`cref`.** `make.c:128` and `mtab.c:177` read `exit(0);tt/* ipnx exit … */` — v10's `sed`
rendered a `\t\t` as a literal `tt`. This is **healed at build time** by a dedicated
expression in `build/patch:550` and `:579`, and the comment above it explains why the heal
has to be a line rather than a note: the corruption consumed the line the original stanza was
guarded on, and two trees already carry it. Nothing to fix; recorded because anyone reading
`cref` cold will trip over it.

## 7. How to read the rest

Each partition's report also recorded what is *correct* — packages where the build file, the
man page and `build/mkfile` agree — so a future pass need not re-audit them. The largest
single class is generated files whose recipes the build already delegates correctly
(`libc/errlst.o` through an `ed` script, `awk/proctab.c` from `maketab`, `2500/helptab.c`,
`cyntax/cyn/bits.c`, pascal's `pi2.0strings`), and the ORDER files under `libplot/`, which no
mkfile honours and which do not matter because every one of those archives is `ranlib`'d at
its destination.
