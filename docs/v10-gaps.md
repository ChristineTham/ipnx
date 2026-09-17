# What the V10 build does not do

*A file-by-file reading of `v10/usr/src`, 2026-09-17. Eight partitions, every one of the 670
directories walked in full, every claim cited to a file and line and checked against
`v10/usr/src/build/mkfile` before being called missing. The items in §1 were re-verified
mechanically against the tree; the rest carry their evidence and need a person to accept
each one.*

**The pattern the reading found: the build installs programs and not the data they read, and
not the ownership they need.** Nothing fails at build time when it doesn't — the program is
there and says `cannot open` the first time someone runs it. A second pattern sits behind
several entries in §3: the mkfile declines a package with a stated reason, and the reason is
contradicted by the tree.

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
  `$ROOT/usr/bin/cyntax` is never created.
- **picasso** — `picasso/mkfile:1,63,65` are literal `/usr/…`; `build/mkfile:4250` runs
  `mk all INS=cp ROOT=$ROOT` and `ROOT` appears nowhere in that mkfile except an unused
  target. With no `/usr/lib/postscript` on the builder the `cd ${POSTLIB}` fails, the whole
  block returns non-zero, and `|| echo 'picasso: FAILED'` swallows it.

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
| `egrep`, `ex`, `sign`, `struct`, `apsend` | `chmod 775`, `chown bin,bin` | `egrep/mkfile:8-12`, `ex/makefile:122`, `sign/mkfile:26-28`, `struct/mkfile:22-26` |

**Blocker.** `build/etc/passwd` holds root, daemon, sys, bin and `build/etc/group` holds
other, sys, man, bin. There is no `games`, no `uucp` (which `parms.h:24-25` fixes at uid 48),
no `news`. Those accounts must exist before any of the above can be applied.

## 3. Exclusions whose stated reason the tree contradicts

Each of these is declined in `build/mkfile` with a reason that is not what the files say.
The decision may still be right — the *reason* needs replacing before anyone can judge.

| package | the mkfile says | the tree says |
|---|---|---|
| `dist` | "`SYS` is set nowhere" | `conf/mkconf.v10:1` is `SYS=v10`, reached through two `<` includes. 21 products |
| `odist` | the same | `odist/mkconf.v10:1` likewise. Real blocker: `/usr/ape` for two of three subdirs; `odist/v10` builds with `lcc` |
| `dimpress` | "`ARGS` is empty" | `dimpress/makefile:100` is `ARGS=all`. Real blocker: no `TABLES/` directory |
| `asd++` | "`$(ASD)` … the variable is empty" | `asd++/Makefile:5` is `ASD = /usr/lib/asd`. Real blocker: `CC = PTCC` |
| `basic/basic` | "no `libPW`" | the four routines used are in `basic/basic/PW/`; `LIBLD` is empty in `all` |
| `sky` | "`all:` with an empty recipe" | `sky/mkfile:1-4` has a four-line recipe producing `sky` |
| `sml` | "no build file at the top level" | `sml/src/makeml` is a 372-line driver with its own man page; `cd src; makeml -vax -v9` |
| `PDP11` | "only half of it is here" | `11as/` and `11c/` are both present; only the archiver is absent, which `README:19-28` says is not needed |
| `cfront` | "C++, deferred to V11" | scoped to seven named dirs; `cfront/demangle/` is plain C (`makefile:7` is `CC = cc`) |
| `learn` | "nothing on the tape says where the lesson tree goes" | `lib/src/README:3` — "Lessons are in `/usr/lib/learn/*`"; the tree is in `lib/lib/`, 519 files |
| `dk`'s four `/etc` programs | "installed nowhere, exactly as the tape has it" | `dk/cmd/Makefile:48-51` installs all four and set-uids one |
| `libj`'s `jerq.h` | "the include tree already carries it" | `v10/usr/include/jerq.h` does not exist; the three other copies all differ |
| `chuck` | listed as not built at :3056 | and built at :5029 — to `/usr/bin`, where the package and `man8/chuck.8` say `/etc`. `upchuck`, which `rc(8)` invokes, is never built |
| `ancient.nroff` | "its install is `mv nroff /usr/bin`, over the link made here" | true of the parent; `macros.d` writes only `/usr/lib/tmac` and `/usr/lib/macros` — see §4 |
| `ncurses` | "its `libcurses.a` would land on the Berkeley one" | true of the library; `tic` and the terminfo database are a separate install and collide with nothing |
| `movie` | "the install target … copies nothing" | true of `movie/mkfile`; `blit.make:43-45` is a real install, and seven of the eight products need only `cc` |

## 4. Missing installs, with the sources present

**The macro packages are the biggest user-visible gap.** Nothing populates `/usr/lib/tmac`
or `/usr/lib/macros`, both named in `Admin/ulibfiles`, while `troff/tdef.h:13` compiles in
`TMACDIR "/usr/lib/tmac/tmac."`. So on this disk `nroff -ms`, `troff -ms`, `-mm` and **`man`**
all fail. Sources and rule: `troff/ancient.nroff/macros.d/{makefile:4-5,12-15,44-47}`. There
is a decision inside it — three different `-ms` copies exist in the tree (`macros.d/tmac.s`,
`/usr/man/man0/tmac.s`, `/usr/vol2/ms/tmac.s`) and only this one has an install rule.

**Whole configurations, never installed:** `/usr/lib/uucp` (Devices, Dialers, Dialcodes,
Permissions, Poll, remote.unknown, uups, the `uudemon.*` scripts, and the generated
`Maxuuxqts`/`Maxuuscheds`) — and six uucp binaries are installed to `/usr/bin` while
`uucp.h:219-221` hardcodes `/usr/lib/uucp/` for them, with `uulog`, `uupick` and `uuto` not
installed at all. `/usr/lib/upas` routing configuration. `/usr/lib/learn` (six courses).
`/usr/lib/dict` (ten helper binaries built and discarded, so `/usr/bin/dict`'s every branch
execs something absent). `/usr/lib/tabset` (`termcap/makefile:12-14`).

**Programs whose data was never installed:** `grap` without `/usr/lib/grap.defines`, so every
`bullet` and `star` is an undefined name. `matlab` without `mathelp.dac`/`mathelp.idx`, its
whole HELP database, both pre-built and present. `spitbol` without `vaxspitv35.err`, so every
diagnostic is numeric. `sky` without `/usr/lib/startab`. `atc` without `Apple1.flow`, which
its *default* airspace needs. `rogue` cannot record a score at all — `rip.c:107` opens the
file `O_RDWR` with no `O_CREAT` and the tape's Makefile creates both.

**Binaries built and then dropped:** `worm` builds fifteen and installs nine (`wdir wreset
wmv wtmpdir wmount wcopy` missing). `ideal`'s four output filters, so every mode except `-n`
is broken. `learn`'s `tee` and `lcount`. `lcomp`'s driver script, leaving `/usr/bin/lprint`
with nothing to drive it. `refer`'s `lookbib` and `pubindex`, both documented commands.
`backup.old`'s 23. `canfield`, 1,145 lines of buildable curses game that appears **nowhere**
in the mkfile while every other unbuilt game carries a recorded reason.

**Links never made:** `/usr/lib/Rpull` and `/usr/lib/Rpush` — `pull.c:10` and `push.c:11`
hardcode them as their server, so both installed binaries are inert, and both names are in
`Admin/ulibfiles`.

**`ipc/` is essentially unbuilt.** The tape's driver names five directories
(`libipc libin bin mgrs internet`); the build takes four files. `/usr/ipc` is not in
`usrtrees` at all, and `cyntax` is a hard prerequisite for the whole of it.

## 5. Data that exists nowhere, so no build work will recover it

`units`' `/usr/lib/Units` — the program is installed and `units.y:375-381` makes a missing
table fatal, so `/usr/bin/units` cannot start. `fortune`'s `fortunes`. `quiz`'s `quiz.k/`.
`word_clout`'s `thes.packed` (760 KB), so the installed game fails on its first line.
`hangman`'s `/usr/dict/words` — V8 has it. `docgen`'s `mmdata`, `msdata` and `wr`, so `-ms`
and `-mm` mode have no data. `pico`'s `defines` and `help`. `town`'s entire gazetteer.
`lex`'s `nrform`, so `lex -r` cannot work. `snocone`'s `epilogue`, which the compiler copies
onto the tail of every program it emits — and the stage-2 compiler is built by running the
stage-1 compiler, so it is produced without one, silently, exit 0. `trek`'s `/usr/lib/a68defs`
is the one recoverable case: `games/trek/a68.h` is the same macro set under another name.

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
