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
ideal's four filters, `lcomp`, learn's whole lesson tree, `Rpull`/`Rpush`, and `canfield`.
*CORRECTED*: this paragraph also said `psych` and `rain`, and neither was built — `psych`
wanted the classic `plot(3)` and `rain` the `gtty`/`stty` this libc deleted; both are built
since 8 Oct 2026 (the fourth status pass). In §3: the reasons recorded for `ancient.nroff`,
`learn` and `dk`'s four `/etc` programs have been replaced with ones the tree supports.

**Four claims in the reading below were wrong and are corrected in place**, each marked
*CORRECTED*: cyntax's leak is real but one level lower than stated; `ex`, `struct` and
`apsend` do not take the ownership the §2 table gives them; `ideal` was broken in its
*default* mode, not merely in `-p` and `-tex`; and `refer`'s `lookbib` and `pubindex` are not
V10 commands at all.

**Three more `strip` defects** of the same shape as §1.1 were found by a better detector and
fixed with it.

**Still open** when this was written: the rest of §3, §5, §6 and `ipc/`. The fourth status
pass below closes most of it and lists what remains, each with the reason it stays.

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
array sizes. *CORRECTED 8 Oct 2026, from every boot log since*: only `ra01` answers `In use` —
it is index 0, which `sw.c` frees at boot itself — and `ra02` and `ra03` attach and say
nothing, which is what success looks like.

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
costs nothing today. *Still so since cfront is built (fifth pass): `build/mkfile`'s own rules
build it and never call that mkfile.*

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

**One inconsistency found while working — RESOLVED 8 Oct 2026:** `build/mkfile:23-26` says the
`./installed` predicate "is gone", and there is no `:P` attribute and no `installed` script
anywhere — but six comments still described it as live, including the one that justifies the
whole `config:V:` target. The comments were the stale half; they are rewritten as history, and
`config:V:` stays for the reason that still holds: one command that reinstalls every
configuration file after hand edits on a machine. Nothing in the build calls it.

### Third status pass, 2026-10-08: the golden rebuilt, and three weeks of edits built

*The golden was rebuilt for the first time since 18 Sep. Before it could be, the rebuild had to
work: nine changes committed in between had never been built, the first full `ipnxbuild` in
three weeks stopped half-way, and `ipnxbuild` itself turned that stop into damage. Every row
below was measured on a booted machine, and the end state was read off the disk from the host
with `tools/v10-tree-check.py`.*

| Reported | Root cause | Fix |
|---|---|---|
| `ipnxbuild` exited 1 in `pkgs` | 1d0a864b (19 Sep) linked `dcon`, `rogin`, `rlogin` and `nogin` to `con` with a bare `ln` — the one recipe shape in `build/mkfile` with no `\|\| echo FAILED` — and `con` had not been built | the guard on all six link rules |
| `cyntax`, `sign` ×2, `ipc/bin` | 93821ca3 (20 Sep) added `libq` to cyntax's lint libraries unbuilt; `llib-lq:17` wants `<sys/utsname.h>`, this tree's is `include/utsname.h`, and `mk` stopped before installing `libc`, so every cyntax link pass answered `cem: no library '-lc'` | `libq` out again (nothing links `-lq`); `libipc` gets `preserve` row 263 |
| `ipc/bin` (again) | with the lint libraries installed the gate is real, and `rsh.c` fails it (`select`, `sprintf`, `exit`); `mk` stops before linking anything in the directory | the stanza asks for the six programs it installs by name; `rsh` and the rest are `dk/cmd`'s |
| `f2c` | the `version.c` rule shells out to `Dt`, a Bell Labs tool on no tape; it fired the first time a source (`names.c`, 20 Sep) was newer than `version.c` | rule commented out; `version.c` stays the tape's |
| `libF77.a` ×11 | 1e060705 (25 Sep) put `pow_qq.o` back; `longint` is defined in neither `f2c.h` | out again, where the tape's double space shows it was taken out |
| `postscript` | 22d04efc (24 Sep) wrote `#` comments inside a recipe in `devpost.mk`, which `make` runs; v10's `make` execs a metacharacter-free line itself — `Make: Cannot load #` | the notes above the target |
| `pascal pc0` | 58f57bbb (24 Sep) gave `pc0` `pi`'s two-target `y.tab.h y.tab.c:` rule; `pc0`'s 1980 `gram` deletes `/^int yylval 0/` where `eyacc` writes `int yylval = 0;`, `ex` stops at the miss, and the regenerated `y.tab.c` keeps `##` at line 66 | `y.tab.h` alone again; `y.tab.c` gets `preserve` row 264 |
| `f77` *(second build only)* | `defs: ftypes defines machdefs` has no recipe, and `preserve` restores `defs` (row 70) before `machdefs` (row 72) with `cp`'s fresh date | the objects carry the four headers; `dag` and `twig` had the same trap latent, found by checking every recipe-less rule over two `preserve` rows |
| `spell`, `backup.old` *(first pass only)* | the swap fix of 18 Sep lives in the kernel, and the first pass runs on the old one: `pcode: Not enough memory`, `Can't find /lib/ccom` | gone on the second pass, booted on the kernel the first pass installed — `ra02` and `ra03` attach, where every earlier boot said `No such device` |
| Pascal printed `D` *(smoke test of the rebuilt disk)* | `pi/proc.c:558-564` builds every `write` format as `"%%%d%c"`, and an integer's letter is `D`, V7's long decimal; libc's `vfprintf.c` is the tape's 1993 pANS member, which has no `D`, `O` or `U` — it prints the letter and does not take the argument, so every later conversion reads the wrong one | `D`, `O` and `U` go to the `d`, `o` and `u` converters with `LONG`; `vfscanf.c` gives `D O U E F` V7's sizes. 27 files in `cmd` use them — `dd`, `find`, `tar`, `adb`, `ex`, `struct`, `mkfs` … |
| `spitbol/opttsts` `OVERWRITTEN AND NOT PRESERVED` *(fourth pass)* | `preserve` is restored in line order with `cp`'s fresh date, and `spitv35.serr` sat above its own input `spitv35.src`; the two copies straddled a second, the next build re-ran the translator, and its log is `opttsts` | every input above what is made from it — the spitbol chain and eight other pairs moved, none inverted now — and `opttsts` is row 265 |

**And `ipnxbuild` made the first stop worse than a stop.** Every step was `|| exit 1`, so the
failure skipped the derived list (`ipnxclean` then swept with September's 2,504 rows), the
consumed list, the overwrite report and the restore of all 263 preserved tape files — which a
second build would have saved as the "originals". A failed step now skips only the build steps
after it, and a build that finds an unrestored index from one that never finished puts those
originals back before saving anything. **Its overwrite report had never worked**: `$D` carries
the `/usr/` prefix and the `find` it was subtracted from does not, both since bbe1a5a2, so every
file the build wrote was listed — 2,780 on the second attempt, with the one real overwrite
somewhere among them. **And `pi` touched its own sources every build**: `0.h: pTree.h` hangs on
the `${GET} $target` rule, and `mk`'s `$target` is the rule's whole target list where `make`'s
`$@` was one. `GET = :` now.

**The result, measured.** Four builds on the 18 Sep golden itself — the first on its old
kernel, the rest on the one that build installed — then one boot that only refreshed
`build/`. The last build printed no `FAILED` and no `did not produce it`, and its overwrite
report named one file, `opttsts`, unchanged in content and preserved since. That disk was
committed (4dd60b2e) and then read from the host, which found the leftovers, the swept
product and the misplaced installs described below; four more builds on it, each followed by a
clean boot, removed and fixed them (e7208eef to 6da349b3), and the cleaned disk replaced it the same
day. Its last build printed no `FAILED`, `ipnxclean` kept `flex.skel`, and
`tools/v10-tree-check.py --current` reads 27,687 files identical to `v10/usr`, 28 expected
differences, none pending and none undelivered. A fresh copy boots with a clean `fsck` and
runs `f77`, `struct`, `spell`, Pascal (`42`), `tar tv` (whose sizes go through `%7D`),
`flex`, `lcc -b` with `bprint`, `cref -c`, `tbl -ms`, `mm -e`, `gram`, `pxp` and `lint -p`, and
mounts `/n/macos`; 109 paths installed programs name are still absent, every one of them site
configuration, a run-time file, a template, a fallback whose other choice exists, or data on
no tape (§5).

**An in-place build leaves two linkless files, and only the next boot shows them.** The build
replaces `/bin/sh` and `/etc/init` while the login shell and `init` are running from them;
`/etc/down` cannot release either, so the next boot's `fsck` prints `2 LINKLESS FILES
CLEARED` and `FREE INODE COUNT 4 SHOULD BE 6`. Read off the disk from the host, they were
inodes 1010 and 1012, byte-identical to the new `/bin/sh` and `/etc/init`, so nothing is lost
— but the golden is booted once more after its last build so that it ships without them. A
disk `mkimage` builds on the second drive never has them, because nothing runs from it. That
the repair then goes unacted on is §1.8.

**And what the build left, or took away, that no build report shows.** Reading the committed
golden from the host for files its last build did not write found leftovers already on the
18 Sep golden. Three products sat at paths their rules had since left: `/usr/bin/dump` (now
`/etc/dump`), `/usr/lib/plot/hplot` (now `hpplot`) and `/usr/bin/asdrcv` (now the setuid
`/etc/asd/asdrcv`). An install never removes an old one, so `build/obsolete` names them and
`ipnxbuild` deletes them after a clean build. Nineteen postscript man pages sat in the root
filesystem's own `/tmp`, under the `ra04` mount: `postscript.mk:114` is `MAN1DIR=$(ROOT)/tmp`,
meant as "nowhere permanent", which under `ROOT=/v10` is the new disk's root; `MAN1DIR=/tmp`
on the command line now. Then a scan for absolute paths that installed programs name and the
disk lacks found the opposite kind: **`/usr/local/lib/flex.skel` was installed by every build
and deleted by every `ipnxclean`**, because `local` is a shape root, so `flex` could never
find its skeleton. `/usr/maps/map` was the known case of a product inside a shape root,
special-cased by hand in three places; `build/inshape` is now the one list all three read.
The same scan, every hit traced to the program's source, found ten more of the build's own:
**`passwd` could never work** (`passwd.sh:6` runs `/bin/passwdx`; the rule installed
`/usr/bin/passwdx`, and not set-uid), `cref` exec'd a `/bin/sort` v10 does not have, `mm -e`
and `mmt -e` fed eqn a `/usr/pub/eqnchar` nothing made, `-mcs` and docgen wanted a `tmac.cs`
only `vol2/ms` held, `upchuck` exec'd an `/etc/chuck` installed in `/usr/bin`, `tbl -ms`
and `-mm` read macro files from `/usr/lib` where v10 keeps them in `/usr/lib/tmac`, `lcc -b`
had no `bbexit.o`, `pxp`'s help was under another name, `uustat -p` had no `uups`, and
`lint -p` read a `llib-port.ln` installed as `llib-lport.ln`. All fixed in `build/mkfile`,
`cref/dr.c` and `tbl/t1.c`; the tape gaps it found are §5's.

### Fourth status pass, 2026-10-08: the gaps closed

*Asked to close every gap this document lists. Each row was built and run on a booted copy of
the golden with `tools/v10drive.py` — six rounds — before the golden was rebuilt with all of
it; "measured" means that machine said so.*

| Gap | What was in the way | Fix | Measured |
|---|---|---|---|
| `units` could not start (§5) | no tape carries `/usr/lib/Units`; the one table on the tapes, `cmd/units/old/usr.lib.units`, is in the old program's syntax, which `units.y` rejects line by line | `tools/v10-units.py` translates it and proves the translation with ports of both readers: 484 of 484 units agree to 1e-12, and the C programs compiled on the host agree too. The money goes to `Monetary.Units`, `units.y`'s second file. Five are carried as comments, each with its reason: two zero exchange rates, their two aliases, and the roofer's `square`, which `units.y` lexes as its operator | `15 pounds force/sq in` in `atm` is `1.02069`; the second run reads `Units.bin` |
| the machine kept standard time all year (§5) | `ctime.c:104-118` reads `/lib/dst`, on no tape | `build/etc/dst`, ours: the US rules since 1967 | 1215000000 prints 08:00 (EDT), 1200000000 16:20 (EST); `date` says EDT |
| `look`, `hangman`, `bc -l`, `fortune`, `quiz` and `cu` read data no tape carries (§5) | — | `words`, `lib.b`, `fortunes`, `quiz.k/` and `cunumber` (empty in v8 too), byte-identical from `v8/`, under `build/v8` | `look`, `bc -l`, `fortune` and `quiz` answer |
| `troff` and `nroff` warned `can't find hyphen.tex` (§5) | TeX is on no tape | Knuth's patterns, unmodified, from Plan 9's tree, at troff's own `ALTHYPHENS`: 4,447 patterns, 44,298 of `n8.c`'s 50,000 bytes | `interna-tional-ization`, and no warning |
| `trek` (§4's games) | PDP-11 C: V6's global member names, initialisers without `=`, `1e50` past the VAX float, untyped `schedule`/`bmove`/`ctime`, `a68.h`'s indented directives, a private `printf` stepping at PDP-11 sizes, `gtty`/`stty`, and a save that wrote memory from address 0 and read it back over ZMAGIC text | ported in the tree, each file with a `build/mkfiles` row; the save names the game's objects | plays, `dump`s, `restart`s from the dump with the game intact, `quit`s |
| `ideal -s` (§4) | `idsort` had no rule, and tested `cmd` before setting it | a rule, and `cmd` set as `idfilt.c:104` does | works |
| `ideal -4`, `-p`; `psych` (§4) | the classic `plot(3)` in `libplot/oldplot` was never built | built in place, linked by path | `4filt`, `pfilt`, `psych` run |
| `sky` (§3) | `gets`, gone from this libc | patch bounds it to `startab`'s 20 bytes | prints the sky for 1 Jan 1990 |
| `cfront/demangle` (§3) | `lorder`, on no tape | the archive made by name | `dem __ct__1AFv` is `A::A()` |
| `movie` (§3) | its install only prints advice | the host half: `stills`, `develop`, `fdevelop`, `newer`, `stills.awk`; the 5620 half has no loader or compiler here | `fdevelop` and `stills` run |
| `ncurses` (§3) | its libcurses would land on the Berkeley one | `tic` and the terminfo database only | the database is compiled; nothing on this disk reads terminfo yet |
| `basic/basic` (§3) | `-lPW`, and four names only `junkdefs.c` defines | `PW/`'s four routines and `junkdefs.o`, driven with `make` | `print sqr(2)` is `1.4142135623731` |
| `boggle`, `rain` (§4) | `gtty`/`stty`; `boggle`'s `setbuf(fileno(stdin))` passed 0 for a `FILE *`; no dictionary | patch appends the pair as `TIOCGETP`/`TIOCSETP`; `setbuf(stdin)`; `bogdict` packed from the imported words | `boggle appl epie moth erhd` lists the board's words |
| mail (§4, §5) | `nupas` was built and its install deferred | installed by name — `send` and `rmail` set-uid root, `edmail`, `translate`, `/bin/mail`, and `mail(1)`'s vacation responder `gone.fishing` with its `gone.msg`, which the path scan of the rebuilt disk found named and absent — with a local-only `rewrite`, `namefiles` and `postmaster` → `root` (`build/etc/upas.*`) | `mail root` and `mail postmaster` deliver; `mail -p` reads; `gone.fishing` answers a sender once |
| `ipc/` (§4) | nothing answered under `/cs`, so `con`, `rcp` and `telnet` were inert; the internet tools and managers were unbuilt | `netstat`, `route`, `arp`, `gettable`; `tcpmgr`, `svcmgr`, `udpconfig`; `inservices`; `/etc/rc` starts `tcpmgr` | `telnet 10.0.2.2 7777` reached a port on the host through `/cs/tcp`, with the 9P shares unaffected |
| PDP-11 cross tools (§3) | the Makefile's `11as: .force1` meets the tape's own `.force1` and answers "up to date" | made in their own directories | `11cc -c`, `11cc -S`, `11nm` |
| `dist` (§3) | `ENOMEM` (lcc's `errno.h` is ANSI's two names), `-DDOPRNT` (`_doprnt` went with the old stdio), `lcc -g` | the tree's `ftwlk.c` and `conf/mkrules.v10` | builds, and asks for its site's destinations |
| `sml` (§3) | nothing drove `makeml`, and `zcat \| tar xf -` stops after two members | unpacked from a file, then `makeml -vax -v9` | `1 + 41;` is `val it = 42 : int` |
| `units(7)` | said `cube` where `units.y:231` takes `cubic`, and named td's file on alice | corrected, and `filnam` and `filref` with it | — |

**Two things the harness got wrong, recorded so nobody chases them.** `mail nobody@nowhere`
"failed" with `nowhere: not found` for two rounds: the console's line-kill character is `@`,
the seventh-edition default, so the tty erased everything typed before it and `sh` ran
`nowhere`. And `compress` was blamed for SML's unpack: `zcat` gives the same 1,331,200 bytes
whichever way it is built, and the failure was `tar` reading a pipe.

**And the golden rebuild found five of its own**, none of which a round on one package could
show:

- **`netstat` would not compile inside a full build.** `cmd/ether`'s rule copies its own
  `<sys/ethernet.h>` over the system's, and the tape's copy — byte-identical to the kernel's
  `sys/sys/ethernet.h` — came back only at the end of the build, so `netstat.c`, compiled
  later, had no `struct etherpup` (`netstat.c:527`), and `mk` stopped before `route`,
  `gettable`, `arp` and `udpconfig`. On the gap round it had built against a header the
  previous build had restored. `P_CMD_ether_all` now puts the tape's copy back as soon as
  `ether` is built; the next build made all five and left the header the tape's.
- **`tcpmgr` is replaced under itself.** With `/etc/rc` starting it, a machine rebuilding
  itself is running the file that every build after a clean relinks and reinstalls, and `cp`
  onto a running text answers `Text file busy`. The install is copy-then-`mv`, as
  `dipconfig`'s and `9pfs`'s are, and the second build replaced it under the running manager.
- **Its start-up lines landed under `login:`.** `logconsole()` (`mgrs/common/log.c`) opens
  `/dev/console` itself, so `rc`'s redirection cannot quiet `announced to network` and
  `announced to fs`, and the backgrounded `(sleep 5; tcpmgr) &` printed both five seconds
  after the prompt. `rc` now sleeps and starts it in the foreground, as `rc(8)`'s sample does;
  `detach()` forks, so the foreground costs nothing but the sleep.
- **SML's build leaves a symlink no sweep can see.** `makeml` makes `src/mo -> ../mo.vax` on
  every run, and `ipnxbuild`'s snapshots are `find -type f` and `-type d`, which a link is
  neither, so `ipnxclean` left it pointing at a `mo.vax` it had removed;
  `tools/v10-tree-check.py --current` reported it. The rule removes it after `makeml`.
- **One halt in six refused, and the harness called it a pass.** With `tcpmgr` running,
  `/etc/down`'s single `umount -a` once answered `/usr: In use` and would not halt; the same
  sequence again halted, and a `ps` before that halt showed nothing on `/usr` but `tcpmgr`'s
  two processes, which `down`'s `kill -9` takes — so a killed process had not finished
  exiting. `down` now tries `umount -a` three times, five and fifteen seconds apart; the
  machine's `sh` runs that form, and every halt since has gone through at the first try, so
  the retry itself is still unexercised. `tools/v10drive.py` had waited out its 240 seconds,
  quit simh with the disk marked mounted and exited 0; it now logs in again and retries a
  refused halt once, and exits 4 if the machine still will not stop.

**What remains, and why it stays.** None of it can be built from what the tapes carry:

- C++ — **done, fifth status pass below.** `cfront` has no C bootstrap on any tape, so
  `asd++`, `dag`, `vsw`, the name server `ipc/mgrs/ns` and `libC` waited with it. The one
  untried route was a binary — V8's golden carries Bell's VAX `cfront` and `munch`
  (`v8/mk/gen/carry.txt:67,81`) — and that 1985 compiler, three of its bugs worked around,
  translated cfront 2.00, which translated V10's cfront 2.1. `asd++` still waits, on cfront
  3.0's `PTCC`.
- On no tape, and not in `v8/` either: `pico`'s `libfb`, `odist`'s APE, `dimpress`'s
  `TABLES/`, `weather`'s `bopen` library, `tmac.pm`, TeX, `snocone`'s epilogue, `lex`'s
  `nrform` and `ebcform`, `word_clout`'s `thes.packed`, `docgen`'s `mmdata`, `msdata` and
  `wr`, `town`'s gazetteer, `dict`'s `oaldce` and `w7full`, `refer`'s `papers/Ind`, the
  `-mcs` cover macros, the `lp` command `lp(1)` describes (its daemon half, `lpdaemon` and
  `lpsend`, is built), `notify` for `mail -n` (`nupas/misc/makefile:35` has a rule and no
  `notify.c`), and the `aed` and `ubell` tab-stop files two terminfo entries name.
- `/usr/lib`'s own manifest, `Admin/ulibfiles`, still lacks 16 of its 50. Thirteen have no
  source anywhere in the tree: `ikeya.term`, `ikeya.tmac`, `libbt.a`, `libg.a`, `libnew.a`,
  `libport.a`, `libr.a`, `libsa.a`, `libtc.a`, `lisp`, `man`, `manprog` and `tel`. `suftab`
  has one (`ancient.nroff/makefile:50`), but only the ancient nroff reads it, and the troff
  installed compiles `suftab.c` in; `ex3.6preserve` and `ex3.6recover` are stale names for
  the `ex3.7` pair `/etc/rc` runs.
- Decided, not blocked: `backup.old`'s administrator half and five user programs (Bell's WORM
  jukebox service), `svcmgr` installed and not started (its `serv` and `auth` files are on no
  tape), `dkmgr` (no Datakit), ncurses' own `libcurses.a`, and the PDP-11 `fpp` behind
  `11cc -F`, which the tape's own `PDP11/README:31-40` says only a PDP-11/03-class machine
  without floating point needs.
- §6's two `preserve` originals, which only the TUHS tapes hold and this environment cannot
  reach.

**Found while closing these, and left as they are**, each with the reason.
- **`ipnxbuild` counts no recipe failure** — *resolved in the fifth pass: it counts them, and a
  failed link's output is never copied.* Every recipe ends `|| echo '…: FAILED'`, so `mk`
  carries on and `ipnxbuild`'s status sees only `mk` itself failing; the `FAILED` lines are in
  the console log and nowhere else. And an install rule copies whatever a failed link left:
  while `trek` still lacked `gtty`, `ld` left a `trek` of mode 664, and the rule's `cp` and
  `chmod 711` installed it as a program — which answered `Illegal instruction - core dumped`
  before printing anything. Grep the log, and leave out the recipe echoes
  (`grep FAILED | grep -v '|| echo'`), or the count is of recipe text. Not changed: counting
  means capturing `mk`'s output through a pipe, which loses its exit status in this `sh`.
- **`Units.bin` is world-writable on purpose.** `units.y:425-427` is `umask(0);
  creat(buf, 0666)`, a cache any user's run may refresh; it holds the binary's own pointers,
  and `:359` refuses one older than the binary's compile date (`mkcdate.c`), so a rebuilt
  `units` cannot read a stale one.
- **`trek`'s `longjmp(errjmp)` passes one argument of two** (`play.c:94`). Harmless:
  `main.c:77` ignores what `setjmp` returns. *Given its second argument in the fifth pass.*
- **`c++filt` and `dem` disagree, by design.** `c++filt.c:22-24` drops a leading `_` on the
  VAX because it reads `nm` output, so it wants `___ct__1AFv` where `dem` wants `__ct__1AFv`.
- **`/usr/lib/eign` is two programs' file.** `cref -e` reads a hash table there
  (`cref/dr.c:365`), which the build makes from `esym` with cref's own `make.c`; `refer` and
  its `mkey` read a word list there (`mkey3.c:2,23-31`, linked into both by
  `refer/makefile:6,25-28`), which V8 ships and no V10 tape carries. The build installs
  cref's, so `refer` takes binary for its list of common words and in effect ignores none.
  V8 never met it: the same `cref` is in `v8/` with the same path and no build file, so V8's
  `/usr/lib/eign` is the word list. Both claims are Bell's and neither failure stops
  anything, so neither is moved.

**The result, measured.** Three full builds on a copy of that morning's golden — the first
stopped short of the internet tools, the second and third built everything and derived the
same 3,197 files — then a boot that cleared the two linkless files an in-place build leaves,
and two short rounds that installed the vacation responder and the retrying `/etc/down`. The
last build printed no `FAILED` and no `did not produce it`; it overwrote 25 files in place,
all of them `preserve` rows, and restored all 263. Read from the host,
`tools/v10-tree-check.py --current` finds 27,733 files identical to `v10/usr`, 28 expected
differences, none pending and none undelivered; there is no linkless inode, root's `/tmp` is
empty and 17 root inodes are free (§1.7). Against the tape's manifests `/bin` lacks 2 of its
57 (`iostat`, `rsh`), `/etc` 4 of 56, `/lib` its one (`dknames`) and `/usr/lib` 16 of 50.
The path scan of installed programs finds 108 absent paths against the morning's 109: ten
fixed — `/bin/mail`, `/lib/dst`, `words`, `fortunes`, `quiz.k`, both units tables, `lib.b`,
`cunumber`, `hyphen.tex` — and nine new from the programs this pass installed, of which
`boglog` and `/lib/names` are optional by design (`boggle.c:501` logs only to a file that
exists; `names` is `$HOME/lib/names`), `/usr/lib/11` is `11cc`'s prefix, quiz's `areas` is
prose inside a data file, and `notify`, `lp`, `fpp` and two tab-stop files are listed above. A
fresh copy boots with a clean `fsck` and `tcpmgr` announcing itself before `login:`, runs
every row of the table above — `telnet` to the host through `/cs/tcp` among them — and the
morning's own list (`f77`, Pascal's `42`, `struct`, `spell`, `tar tv`, `lint -p`, `mm -e`),
and halts; `tools/webterm-check.py` boots it in the browser. The committed halves restore it
byte for byte.

### Fifth status pass, 2026-10-08: C++, and a build that says what failed

**C++ is built.** No tape carries a `cfront` binary and `cfront` is written in C++, so V10's
seven cfront trees had no first link — until V8's golden supplied one: Bell's VAX `cfront` of
7/04/85. With three of its bugs worked around it translates cfront 2.00, which translates V10's
cfront 2.1, and two generations of that agree on every file. `build/cfboot` runs the chain once,
from a seed `tools/v10-cfseed.py` lifts off the V8 disk; from then on `build/mkfile` rebuilds
`CC`, `cfront`, `munch` and `libC` with the machine's own `CC`. The whole account — the stages,
the three bugs and how each was measured, the fixed point — is
[v10-build.md, C++](v10-build.md#c).

| | what it needed | measured |
|---|---|---|
| `cfront`, `libC`, `munch`, `CC` | six whole-file repairs: `CC/memory.h` and `CC/string.h` use `size_t` undeclared; `generic.c`, `task/obj.c` and `munch.c` call `abort` or `exit` undeclared; `oldformat.c`'s `max` is V10's `CC/libc.h:67` function. `CC` itself is ours — V8's driver, adjusted | iostream, `complex`, `strstream`, the `task` library's coroutines, a virtual base, static constructors through `munch` |
| `vsw` | nothing: it compiles as the tape left it | builds; drives hardware nobody here has |
| `dag` | `QSORTDCL`, as its README says where `libc.h` declares `qsort`; its comparator typedef made `const`; `inversion()` declared `static` where it is defined so; `parsedag.c`, yacc's C++, compiled with `$CC` and not `cc` | lays out a four-node graph for `pic` |
| `ns` | `set.c`'s own `qsort` and `parsefiles.c`'s own `memset` removed — V10's headers declare both now, and 2.1 refuses a second C-linkage function | builds; installed and not started, as `svcmgr` is: `ns(8)` reads `/usr/ipc/lib/ns.db`, and the tape's is Murray Hill's astro department |
| `asd++` | `PTCC` — cfront 3.0, templates. `ptcfront` and `xptcfront` are on the tape as C++ source, so 2.1 is the next link if it can translate one | untried |

**What V8's `CC` brought with it.** `build/src/CC` is V8's driver, and V8's named its two
temporary files alone in the current directory. `vsw`'s mkfile sets `NPROC=3`, and three `CC`s
in one directory removed each other's `__err` mid-build; they carry the process number now.

**`ipnxbuild` counts what failed.** A recipe that fails says `FAILED` and `mk` carries on, so
until this pass a build could end with status 0 and a broken package in it — the `FAILED` lines
were in the console log and nowhere else. Every step now writes into `/usr/ipnx/build.log`,
the failures are counted from it into `/usr/ipnx/failed` with the recipe echoes left out (every
one has `echo` in it; a full build's console log held 1,266 lines with `FAILED` in them and not
one failure), and the status is 2 when any recipe failed, 1 when a step did. **And a failed
link's output is never copied**: around the steps `cp` is `build/src/guardcp`, which refuses a
non-executable VAX a.out not named `.o` — what `ld(1)` leaves when a load fails.

**Four of this pass's own first attempts were wrong, and the machine said each time.**

- The log went through `tee`, and the first build stopped in `build1` with status 1 and no
  message. **A V10 pipe is a stream, and a zero-length write into it reads as end of file**:
  `tee.c` stops at a read of 0, and `mk`, writing on into a pipe nobody reads, dies of SIGPIPE.
  Measured with `write(1, "a\n", 2); write(1, "", 0); write(1, "b\n", 2)`, which through `tee`
  or `cat` delivers `a` alone. The log is a file now, and a background `tail +1f` mirrors it.
- That `tail` was `/usr/bin/tail`, which the build installs, and the next build said
  `cp: /usr/bin/tail: Text file busy` — `tail: FAILED`, the build's own count catching the
  build's own tooling. The mirror runs a private copy.
- The guard looked for `ld`'s default `0413`, and a real failed link went straight through it:
  an undefined symbol makes `ld` keep the relocation bits and write `0407` (`ld.c:847-858`),
  the format of an object file — 637 bytes, where the program linked is 3,408. It refuses by
  mode, magic and name now, and a test on the machine refuses the failed link, leaves the old
  target whole, and passes a program, an object, a data file and a two-file copy.
- And by name it exempted `.o` alone, so the first full build under it refused `libdbm.a` and
  `libsdb.a`, which are bare objects named as libraries (`mv dbm.o libdbm.a`). Every refusal
  is in the log, so those two were the complete list of what it matched; `.a` is exempt too.

**And one the tree had all along:** `dag/mkfile:42` made the `.c` files depend on
`defaults.h` where the objects were meant — harmless to `make`, but `mk` will not leave an
out-of-date target with no recipe, and on the tape `defaults.h` is the newer: `no recipe to
make 'node_t.c'`. A copy of the directory built, because a copy's dates are all the same.

**And a repair that had been undoing itself:** `patch`'s `_IOFBF` stanza tested
`$IDIR/stdio.h` and rewrote `/usr/include/stdio.h`, so a run against `/v10` added a second
`_IOFBF` to the builder's header and none to the target's. Both sides are `$IDIR` now.

**The other reported items.** `trek`'s `longjmp` has its second argument. `/usr/lib/eign`
stays cref's: no manifest names the file, so nothing says which program V10 shipped it for, and
`mkey -c` (`mkey1.c:31-33`) already lets `refer`'s indexer name a word list. `Units.bin` stays
mode 666, the cache `units.y:425-427` means it to be. The committed golden's `/usr/ipc/log/tcp`
is empty: the torn line seen there earlier came from the build machine's own boots and was
cleared before the image was made. `tcpmgr`'s log writes are `lseek` then `write`
(`mgrs/common/log.c`) on a system with no append mode — `fcntl.h` has only the three access
modes — so two separate opens could overwrite each other. One `tcpmgr` never makes two:
`detach.c:21` opens the log once, after its own fork, and the dialer and listener fork from
that (`main.c:78`), so every writer shares one offset. Only a second `tcpmgr` started beside
the first could tear a line, and nothing here starts one.

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

*CORRECTED 2026-10-08*: not every one — the claim held for the scripts `build/mkfile` copies
itself, not for the ones a package's own install copies. Listing the rebuilt golden's command
directories for files with no execute bit found three more: **`/usr/bin/lint`**
(`lint/mkfile:19`, `cp lint.sh` and no `chmod`, so `lint` answered `lint: cannot execute` on
every golden), `/usr/bin/WWB/gram` (`wwb/mkfile:65`; `gram.sh` alone of wwb's scripts is 644 in
the tree) and `/etc/mkimage`, which the verbs table types by name. All three are `chmod +x`'d
by their rules now — **FIXED** — and the same listing found `/etc/su` and `/bin/newgrp`
without their set-uid bit (§2).

**1.7 The root filesystem has 17 free inodes** (measured 2026-10-08 on the golden of the
fourth status pass: `fsck` counts 1,071 files of `s_isize 19 blocks (1088 inodes)`). It had
22 that morning, and the fourth pass took five: `/lib/dst`, `/bin/mail`, `/bin/rmail`, `/cs`,
and `/cs/tcp`, the file `tcpmgr` creates to mount on (`libipc/ipccreat.c:47-53`), which
outlives every halt and is reused at the next boot. It had eight on 18 Sep. `/etc/asd` and
`/etc/asd/asdrcv` (651a1ea3) took two, `/bin/passwdx`, `/etc/chuck` and `/etc/upchuck` three
more — each moved to where the program that runs it looks — and nineteen were never the
system's at all — postscript's man pages, written into the new disk's own `/tmp` by
`MAN1DIR=$(ROOT)/tmp` under `ROOT=/v10` and hidden there by the `ra04` mount since 4 Sep (§0,
third status pass). `mkimage:27-33` already explains the 1,088 — root is 1,280 4K blocks and
`proto-dev`'s 917 device nodes take most of the i-list — so this is not a fault, but it is a
budget, and the first new file past it under `/`, `/etc` or `/dev` makes `mkimage` fail with
the disk half-built. (The count is the in-place golden's. A disk `mkimage` builds has not been
measured since the `MAN1DIR` fix; it should hold the same files, less `/cs/tcp` until it first
boots.)

**1.8 `fsck` never asks for a reboot, so `rc` cannot act on a repaired root.** Every boot
prints `ROOT MODIFIED`, clean or not: the bit-map free check ends with
`superblk.s_valid = 1; superblk.s_tfree = n_free;` and a dirty superblock unconditionally
(`fsck.c:1718-1720`), any write sets `dfile.mod` (`bwrite`, `fsck.c:1997`), and
`fsck.c:730-731` prints the line for any write to the mounted root. It then returns 0 —
`fsck.c` has no `exit(4)` at all; its codes are 0, 8 and 12 — so `build/etc/rc:21`'s
`4) /etc/reboot -n` arm cannot run, and a boot that really did repair the root carries on
with the kernel's in-core superblock older than the disk's. That happens after every
in-place build (the third status pass above has the two linkless files it leaves). V8's
`fsck.c:686-687` is the same, so this is Bell Labs' arrangement in both editions, and the
likeliest reason is the first sentence: an `exit(4)` on any root write would make every boot
a reboot. Measured consequence so far: none — each boot after one that cleared two inodes
found nothing left to fix. **Not changed**: telling a repair from the routine rewrite needs a
flag at every fix site, and missing one makes the machine reboot forever. **And measured since
(8 Oct 2026): the right exit would stop the machine.** `/etc/reboot -n` on this simulator does
not reboot — simh's 780 answers the console restart by halting at `sim>` unless a BOOT command
was saved, and this project's launchers boot with `load -o uda FA00; run FA02` and save none
— so an `exit(4)` would turn every repaired boot into a halted simulator. What `fsck -p` repairs
on this root is only ever freeing — linkless inodes and the free counts — so the in-core state
it leaves stale can hold a block or an inode back until the next boot, and never hands one out
twice. `mkbitfs` takes no inode count —
`mkbitfs.c:80` derives it from the size, `(size-2)/(1+ICOUNT)` — so the levers are fewer
device nodes, a larger root partition in `ra_sizes`, or an argument added to `mkbitfs`.

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
| `/bin/passwdx` | set-uid root, **in `/bin`** | `passwdx.c:2-4`; `passwd.sh:6` runs it from `/bin` — added 8 Oct 2026; it was in `/usr/bin`, 775 |
| `/etc/su` | set-uid root | `su.c:32-45` setuid()s to the target — added 8 Oct 2026; no makefile says so, because `Admin/Mk`'s `strip && cp` onto an existing file kept a bit set by hand |
| `/bin/newgrp` | set-uid root | `newgrp.c:41,54`, the same reason — added 8 Oct 2026 |
| `/usr/lib/upas/send`, `/bin/rmail` | set-uid root, 4755 | `nupas/send/mkfile:41-47`; `send` creates a recipient's mailbox and chowns it to them (`libc/genopen.c:76-77`) — added 8 Oct 2026 with the mail install |
| `/bin/mail` | owner bin, 775 | `nupas/misc/mkfile:23-26` — added 8 Oct 2026 |

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
| `dist` — **BUILT 8 Oct 2026** | "`SYS` is set nowhere" | `conf/mkconf.v10:1` is `SYS=v10`, reached through two `<` includes. 21 products |
| `odist` — **still out, for the real blocker** | the same | `odist/mkconf.v10:1` likewise. Real blocker: `/usr/ape` for two of three subdirs; `odist/v10` builds with `lcc`. `pax` (a fourth `odist/` subtree — `libx`, `libodelta`, the pax/cpio/tar command, frozen as 1991 AT&T `ship` shipment archives) isn't one of those three at all: `odist/mkfile`'s own `DIRS=` never names it, and it has no `mkfile` of its own to run even if it were added — a `SYS` fix alone wouldn't reach it |
| `dimpress` — **still out, for the real blocker** | "`ARGS` is empty" | `dimpress/makefile:100` is `ARGS=all`. Real blocker: no `TABLES/` directory |
| `asd++` — **still out, for the real blocker** | "`$(ASD)` … the variable is empty" | `asd++/Makefile:5` is `ASD = /usr/lib/asd`. Real blocker: `CC = PTCC` |
| `basic/basic` — **BUILT 8 Oct 2026** | "no `libPW`" | the four routines used are in `basic/basic/PW/`; `LIBLD` is empty in `all` |
| `sky` — **BUILT 8 Oct 2026** | "`all:` with an empty recipe" | `sky/mkfile:1-4` has a four-line recipe producing `sky` |
| `sml` — **BUILT 8 Oct 2026** | "no build file at the top level" | `sml/src/makeml` is a 372-line driver with its own man page; `cd src; makeml -vax -v9` |
| `PDP11` — **BUILT 8 Oct 2026** | "only half of it is here" | `11as/` and `11c/` are both present; only the archiver is absent, which `README:19-28` says is not needed |
| `cfront` — **`demangle` BUILT 8 Oct 2026** | "C++, deferred to V11" | scoped to seven named dirs; `cfront/demangle/` is plain C (`makefile:7` is `CC = cc`) |
| `learn` — **REASON REPLACED, PACKAGE NOW BUILT** | "nothing on the tape says where the lesson tree goes" | three files say it: `makefile:15` `LLIB = /usr/lib/learn`, `lib/src/README:3-4`, and `makefile:64-69`, the `check` target, which is a manifest of what `LLIB` must hold. 542 files in `lib/lib/`, not 519 |
| `dk`'s four `/etc` programs — **REASON REPLACED, DECISION KEPT** | "installed nowhere, exactly as the tape has it" | `dk/cmd/Makefile:49-51` installs all four and set-uids one. The reason that holds: none of the four is in any Admin list, and all four drive Datakit hardware this machine does not have. `Rpull`/`Rpush` from the same install **are** in `ulibfiles` and are now made |
| `libj`'s `jerq.h` | "the include tree already carries it" | `v10/usr/include/jerq.h` does not exist; the three other copies all differ |
| `chuck` — **FIXED** | listed as not built at :3056 | and built at :5029 — to `/usr/bin`, where the package and `man8/chuck.8` say `/etc`. `upchuck`, which `rc(8)` invokes, is never built |
| `ancient.nroff` — **`macros.d` NOW BUILT** | "its install is `mv nroff /usr/bin`, over the link made here" | true of the parent; `macros.d/makefile:12-15,44-47` writes only `/usr/lib/tmac` and `/usr/lib/macros` and builds no binary but the `ntar` filter its own pipeline uses |
| `ncurses` — **`tic` AND THE DATABASE BUILT 8 Oct 2026** | "its `libcurses.a` would land on the Berkeley one" | true of the library; `tic` and the terminfo database are a separate install and collide with nothing |
| `movie` — **HOST HALF BUILT 8 Oct 2026** | "the install target … copies nothing" | true of `movie/mkfile`; `blit.make:43-45` is a real install, and seven of the eight products need only `cc` |

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
`learn`, `dict` and `tabset` are also done. `/usr/lib/upas` is done too since 8 Oct 2026: the
mail system installed, with a routing file for local mail (fourth status pass).

**Programs whose data was never installed — ALL FIXED** (`sky` on 8 Oct 2026): `grap` without
`/usr/lib/grap.defines`, so every `bullet` and `star` is an undefined name. `matlab` without
its whole HELP database, both pre-built and present — *CORRECTED*: the two halves of the tape
disagree about where it lives, `src/helper.f:10-11` (the reader) saying `/usr/lib` and
`helpset.f:6-7` (the generator) `/usr/local/lib`, and the reader is the one that runs.
`spitbol` without `vaxspitv35.err`, so every diagnostic is numeric. `sky` without
`/usr/lib/startab` — *FIXED 8 Oct 2026*, with `sky` itself. `atc` without its flow files —
*CORRECTED*: a missing flow file is **not** an error, `aread.c:115-132` falls through and the
game plays with no traffic flow, which is not the game but is not a failure either. `rogue`
cannot record a score at all — `rip.c:107` opens the file `O_RDWR` with no `O_CREAT`.

**Binaries built and then dropped — FIXED, and `backup.old`'s remainder decided:** `worm` builds fifteen and
installs nine (`wdir wreset wmv wtmpdir wmount wcopy` missing). `ideal`'s output filters —
*CORRECTED*: there are **five** names in `ideal.cmd` (`tfilt`, `pfilt`, `4filt`, `texfilt`,
`idsort`) and `t` is the **default** (`ideal.cmd:5`), so plain `ideal file` was broken too,
not merely `-p` and `-tex`; `idfilt/makefile:24` is `install: 4filt tfilt pfilt texfilt`
*with no recipe*, so the tape builds four and installs none. `idsort` had no build rule
anywhere, so `-s` stayed broken — *FIXED 8 Oct 2026*. `learn`'s `tee` and `lcount`. `lcomp`'s driver script,
leaving `/usr/bin/lprint` with nothing to drive it. `refer`'s `lookbib` and `pubindex` —
*CORRECTED*: these are **not** V10 commands. Neither has a manual page in `v10/usr/man`,
neither is in any Admin list, and `refer`'s own install target names neither; the tape's
decision to leave them stands and they are not installed. `backup.old`'s 23 — *CORRECTED*:
all 29 of its programs build, and the golden's `/usr/ipnx/derived` lists every one; nine plus
`act`, `recover` and `/usr/bin/backup` are installed, and the administrator half and five user
programs are left out on purpose, as `build/mkfile` records — Bell's WORM jukebox service,
with its machine names, and no hardware here for it.
`canfield`, 1,145 lines of buildable curses game that appears **nowhere** in the mkfile while
every other unbuilt game carries a recorded reason — and `psych` and `rain` were the same,
all three now built. `boggle` stayed out because `boggle/makedict` reads `/usr/dict/words`
and no tape carries `/usr/dict` — built 8 Oct 2026, with the words imported from `v8/`.

**Links never made — FIXED:** `/usr/lib/Rpull` and `/usr/lib/Rpush` — `pull.c:10` and
`push.c:11` hardcode them as their server, so both installed binaries were inert, and both
names are in `Admin/ulibfiles`.

**`ipc/` is essentially unbuilt.** The tape's driver names five directories
(`libipc libin bin mgrs internet`); the build takes four files. `/usr/ipc` is not in
`usrtrees` at all, and `cyntax` is a hard prerequisite for the whole of it. *FIXED 8 Oct
2026, all but the C++*: `libipc`, `libin` and `bin` were already in; the internet tools,
`tcpmgr`, `svcmgr` and `udpconfig` are now, `/etc/rc` starts `tcpmgr`, and a dial through
`/cs/tcp` reaches the host. The name server `ns` is C++ and waits for `cfront`.

**`pico` is not built at all, not merely missing its data.** `cmd/pico/Makefile:12` links
`-lfb`, and `libfb` is on no tape — only the header `/usr/include/fb.h` survives.
Holzmann's own released VAX pico (spinroot.com/pico/pico.tar.gz) is byte-for-byte this same
tree and carries no `libfb` either; its symbol table settles it, holding `fb.h`'s declared
symbols and nothing from `framebuffers/`. No `mk`/`make` rule anywhere produces
`$ROOT/usr/bin/pico`. Its `defines` and `help` data (§5) are moot until the binary itself
exists.

## 5. Data that exists nowhere, so no build work will recover it

*8 Oct 2026: of this list, `units`' tables, `fortunes`, `quiz.k/`, `/usr/dict/words`, `trek`'s
`a68defs`, `hyphen.tex`, `/lib/dst` and `/bin/mail` are FIXED — translated, imported from
`v8/` or Plan 9, written, ported or installed, each recorded in the fourth status pass. The
rest is as described.*

`units`' `/usr/lib/Units` — the program is installed and `units.y:375-381` makes a missing
table fatal, so `/usr/bin/units` cannot start. *FIXED: translated from the tape's own old
table, `cmd/units/old/usr.lib.units`, which is not nowhere after all.* `fortune`'s
`fortunes`. `quiz`'s `quiz.k/`. `word_clout`'s `thes.packed` (760 KB), so the installed game
fails on its first line. `hangman`'s `/usr/dict/words` — V8 has it. `docgen`'s `mmdata`, `msdata` and `wr`, so `-ms`
and `-mm` mode have no data. `town`'s entire gazetteer.
`lex`'s `nrform`, so `lex -r` cannot work. `snocone`'s `epilogue`, which the compiler copies
onto the tail of every program it emits — and the stage-2 compiler is built by running the
stage-1 compiler, so it is produced without one, silently, exit 0. `trek`'s `/usr/lib/a68defs`
is the one recoverable case: `games/trek/a68.h` is the same macro set under another name —
*FIXED: `trek` includes `a68.h`, and is ported and built.*
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

**More, from reading the 8 Oct golden for paths its installed programs name** (116 missing;
ten were the build's and are fixed, the rest are site configuration, run-time files,
templates, or this):
- **`hyphen.tex`, TeX's hyphenation patterns.** troff's `HYPHALG` is 1 (`tdef.h:152`), so the
  first time a troff or nroff run hyphenates it looks for the patterns, prints `warning: can't
  find hyphen.tex` once, and falls back to the old suffix and digram rules (`n8.c:342-354,
  436-444`). TeX is on no tape. *FIXED 8 Oct 2026: Knuth's patterns, from Plan 9's tree.*
- **`/lib/dst`, the daylight-saving table.** With the kernel's `dstflag` set, `ctime.c:104-118`
  reads it, and with no table applies no shift at all, so the machine keeps standard time all
  year. *FIXED 8 Oct 2026: `build/etc/dst`, ours.*
- `lex -e`'s `ebcform` (beside `-r`'s `nrform` above); `/usr/dict/oaldce`, `w7full` and
  `papers/Ind` (`ldefine`, `wdefine`, `refer`'s default index); monk's `apseqnchar`,
  `i300eqnchar` and `im300eqnchar`; termcap's `tabset/aa`, `infoton_tabs` and `stdcrt`;
  `/etc/dpd`, whose `spider.dpd.c:23` includes a `gcos.c` on no tape. And three that
  `tmac.cs` sources, now that it is installed — `tmac.rscover` (`mcs.6:141`; read only when
  register `ST` is 1, `tmac.cs:1048-1049`) and `complet.1127` and `cover.1127` (read only
  when a macro is given a `y`, `:475`, `:500`) — so `-mcs` works on its common path.
- **And `/bin/mail`, which is not this kind.** nupas installs `/bin/mail` and `/bin/rmail`
  and is built; its install was deferred until its products were proven on the machine
  (`build/mkfile`, `P_CMD_nupas_v10_all`), so `passwd` and `asdrcv` called a mailer that was
  not there. *FIXED 8 Oct 2026: proven, and installed.*

## 6. Divergences between the repository tree and the machine

Measured on 2026-10-07 with `tools/v10-tree-check.py`, which reads the golden disk from the host
and holds every difference to a delivery route; `docs/v10-build.md` (*Checking it from the
host*) has the whole account. What this section recorded, and what became of it:

**`qsnap`: resolved, after being made worse.** `qsnap/mkfile:14` names `Qsnap.c`, and the
checkout held `qsnap.c` + `u_Qsnap.c` where the machine holds `Qsnap.c` + `u_qsnap.c`. The
contents were right and only the case of the names was wrong, but a commit on 24 Sep swapped the
*contents* to fit the names, so the checkout's `Qsnap.c` became the `<fb.h>` variant — which
needs pico's missing `libfb` and is not what any machine builds. `qsnap.1` was then rewritten
from that file and documented options the shipped binary does not have. Both are corrected:
`Qsnap.c` is the `piclib.h` variant the mkfile links with `piclib.o`, byte for byte the
machine's, and `qsnap.1` is the original page with `-d`, `-n`, `-F` and `-L` added from the code
and its two errors fixed (`-f 8` cannot reach Tmax-100; the offsets are not scaled by `-m`).

**Four more names in the wrong case**, the same case-insensitive-filesystem artefact:
`jerq/src/lib/C` for `c`, `cfront/libstring/string.h` for `String.h`, `ooptcfront/hash.h` for
`hash.H`, and ostdio's `doprnt.s`/`u_doprnt.S` for `doprnt.S`/`u_doprnt.s`. Contents identical to
the machine's; renamed to match `casefix` and the rule that the build file's spelling survives.

**`cref`: the checkout now carries the healed files.** `make.c:128` and `mtab.c:177` read
`exit(0);tt/* ipnx exit … */` — v10's `sed` rendered a `\t\t` as a literal `tt` — which
`build/patch:550` and `:579` heal at build time, and `make.c` also lacked patch's `&array`
repair. Both now hold what patch leaves, as do `struct`'s seventeen cast-repaired sources,
`stdio.h`, `lrndef`, `macrunch` and `install.sh`. The heal stays in patch for any tree that
still carries `tt`.

**Still open: two `preserve` rows hold build products on both sides.** `sys/io/camac.s` (its
`.stabs` line is dated 2026 in the checkout and on the golden) and `pascal/libpc/libpc`. Builds
before `ipnxbuild` restored what it saved overwrote them with no copy kept, so every restore since
has faithfully put back a product. Only the tapes have the originals; `tools/v10-tree-check.py`
names both as expected. A third, `struct/beauty.c`, was yacc's output on the golden and is the
tape's (plus patch's one cast) in the checkout, which `build/mkfiles` now delivers.

## 7. How to read the rest

Each partition's report also recorded what is *correct* — packages where the build file, the
man page and `build/mkfile` agree — so a future pass need not re-audit them. The largest
single class is generated files whose recipes the build already delegates correctly
(`libc/errlst.o` through an `ed` script, `awk/proctab.c` from `maketab`, `2500/helptab.c`,
`cyntax/cyn/bits.c`, pascal's `pi2.0strings`), and the ORDER files under `libplot/`, which no
mkfile honours and which do not matter because every one of those archives is `ranlib`'d at
its destination.
