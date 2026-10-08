# How a Tenth Edition is made

*Read off the scripts in `v10/usr/src/build`, 2026-09-16. They are the authority: where this
document and a script disagree, the script is right. Everything here was verified against the
files rather than carried forward from an earlier plan.*

## Where V10 actually stands

A V10 machine boots, builds itself and has produced a golden image. It is **not a complete
Tenth Edition**, and the gaps are measured rather than guessed — see
[What the build does not reach](#what-the-build-does-not-reach).

How it got here, in the order it happened:

1. The six TUHS tapes were analysed and merged into one reconstructed `/usr` tree. No single
   tape is the Tenth Edition; where two disagree the newer wins, and `v10/` is the result.
2. That tree is the best V10 distribution this project can assemble. It is incomplete — some
   packages have no source on any tape, and some data files are missing (a few of which V8
   carries and could be brought across; none has been).
3. On the **V8** machine, V10's toolchain was compiled, and with that toolchain running on V8
   a V10 kernel configuration was written and a kernel compiled.
4. Still on V8 with the V10 toolchain, a V10 root filesystem was built — `/bin`, `/lib`, `/etc`.
5. A disk carrying that kernel and root booted. This is the point at which V10 became a machine
   rather than a cross-build.
6. From there the disk was built out on itself. **`v10/usr/src/build` is the build system**, and
   it is where all the remaining work is.

Steps 3 to 5 are history: no script in this repository performs them any more, and the V8-hosted
cross-build is gone. What survives is the machine-side build, which is the only path forward.

Two properties of `v10/` were established along the way and are maintained by the build:
**one name per path**, so the tree survives a case-insensitive checkout, and **no source
archives**, so every `ar` archive is a directory of its members with an `ORDER` file beside them.

## The split: what the host does, and what it cannot

**The host fetches the tapes and never unpacks one.** `tools/v10-tapes.sh` downloads the six
archives from TUHS and decompresses them into `v10tapes/` — gitignored, 430 MB, and **scratch**:
`mkv10` reads them once ever, `v10/` is the committed result, and the directory can be deleted
the moment the bootstrap is done. The host fetches at all because TUHS
answers plain HTTP with a 301 to https and **V10 has no TLS**, and because **gzip is 1992 and
bzip2 1996**, so a 1989 machine can read neither. Decompressing is not extracting: nothing on
the Mac decides anything about the shape of the tree. `mkv10` extracts them on the machine,
reading them straight off the share if you name it. What the host does:

| | |
|---|---|
| `tools/v10-tapes.sh` | fetch the six TUHS archives and decompress them to plain `tar` in `v10tapes/` |
| `tools/v10-reset.sh` | `image/*.tar.bz2` → `run/`: both disks uncompressed, and the boot ROM beside them |
| `tools/v10-launch.sh` | boot `run/v10` with `run/v10-golden` on the second drive and both shares up |
| `tools/v10-golden.sh` | boot a throwaway copy of the golden, one drive, no shares |
| `tools/v10-proto.py` | the kernel config and `sys/lib/tab` → `build/proto-dev` |
| `tools/v10-makedev.py` | `build/proto-dev` → `build/mkdev` |
| *(no tool)* | **create the blank disk image file the machine formats** — see below |

Two directories, and they are not the same one:

| | |
|---|---|
| `image/` | the **committed compressed** disks — three bzip2 tars through Git LFS, the V10 golden in halves. The only binaries in the repository. |
| `run/` | the **uncompressed working** disks restored from them, plus the boot ROM and the simh configs the launchers write. Gitignored, and every file in it is reproducible. |

Case collisions are resolved on the machine, where the filesystem is case-sensitive and the
tapes' own names survive — `cmd/` carries `compress(.Z)` and `pack(.z)`, so anything handed to
it must be plain `tar`.

**The missing host step.** `mkimage` formats a second drive — it runs `mkbitfs` against
`/dev/ra10`, `/dev/ra14` and `/dev/ra15` — but a simulated drive needs a **file** behind it, and
V10 cannot create a sparse one. That file has to exist on the host and be attached as `rq1`
before the machine is booted. No script in this repository creates it. Until one is written,
fabricating a fresh disk means making the file by hand:

```bash
dd if=/dev/zero of=run/v10-new bs=512 count=3920490   # RA73, 1,914 MB, sparse
```

`tools/v10-launch.sh` attaches the golden as the second drive, so an ordinary
build-the-other-disk round needs no new file at all.

## The tree

`v10/` in this repository **is the machine's own `/usr`**, byte for byte what `taripnx` writes
and what `mkimage` extracts. A question about what we build from is a `git grep`. A question
about what a particular tape says is answered on the machine, where the tapes are.

`build/usrtrees` is the single statement of the shape, and four scripts read it rather than
repeating it:

```
src  man  include  sys  blit  jerq  630  maps  vol2  local
```

`bin` and `lib` are absent deliberately — they are **product, not shape**, built and installed
by a running machine. `ipnx`, `tmp`, `adm` and `spool` are run-state and stay out for the same
reason.

## The verbs

Five do the work, and `cfboot` once. Everything else in the directory serves them.

| | what it does | how often |
|---|---|---|
| `ipnxbuild [ROOT]` | build a complete system from `/usr/src` — this machine by default, the disk on `ra1` when given `/v10` | every round |
| `ipnxclean [ROOT]` | remove everything `ipnxbuild` made, from the list `ipnxbuild` wrote | before archiving |
| `mkimage` | format the second drive, extract an archive into it, build it | when fabricating a disk |
| `mkv10 [dir]` | the six tapes → `v10.tar`, pristine. `/usr/tmp` unless told otherwise; the share works too, and costs the disk nothing | once, ever |
| `mkipnx [repo]` | `v10.tar` + the build system + the repairs → `ipnxorig.tar` | when the repairs change |
| `taripnx` | this machine's live `/usr` → `/usr/ipnx/ipnx.tar` | when a machine is worth preserving |
| `cfboot [seed]` | C++ for a machine that has none, from V8's cfront — see [C++](#c) | once, on a disk without `/usr/bin/cfront` |

`updatebuild` is the sixth and is not part of a build: it refreshes `/usr/src/build` from the
repository over the share, and it is **the only script here that touches `/n`**. The inner
loop is `updatebuild; ipnxbuild`.

`ipnxinstall` installs what `ipnxbuild` deliberately does not — the files that belong to the
operator. It asks before replacing a file that exists and differs, defaults to N, and is silent
when a file is absent or identical.

### Bootstrapping from nothing

```
mkimage     # no ipnx.tar yet -> formats ra1, mounts /v10 and /v10/usr, stops
mkv10       # six tapes -> /v10/usr/ipnx/v10.tar, then removes the tree
mkipnx      # v10.tar + build system + repairs -> ipnxorig.tar
mkimage     # again, now with an archive to extract
```

`mkimage` handles the first step deliberately: with no `/usr/ipnx/ipnx.tar` it says so, leaves
`/v10` blank and mounted — which is exactly what `mkv10` needs — and exits 0.

### The three archives, and the equation

| archive | written by | contents | binaries |
|---|---|---|---|
| `v10.tar` | `mkv10` | the six tapes, assembled, one name per path, nothing of ours | none |
| `ipnxorig.tar` | `mkipnx` | that plus `/usr/src/build`, the tree's own build files, and the repairs applied | none |
| `ipnx.tar` | `taripnx` | a machine's live `/usr` | yes, unless `ipnxclean` ran first |

**`ipnxorig.tar` = `ipnx.tar` = `v10/`**, given a clean tree. The first two are the same tree cut
at two moments, so they hold the same files or one of them is lying, and most of the accounting
in `ipnxbuild` exists to keep that true. Three things had to be reconciled:

- **`consumed`** — six rules regenerate a file the tape ships and then remove it (`lex`'s and
  `m4`'s `y.tab.c`, `make`'s `gram.c`, `pcc`'s `cgram.c` and `rodata.c`, `termcap.obj`), so a
  tree that has built lacks six files a tree that has not. `mkipnx` removes them from its own.
- **`preserve`** — the derived list is a difference of *names*, so it sees a file that appeared
  and is blind to one that **changed**. Twenty-five rows name tape files a tape's own rule
  rewrites in place; `ipnxbuild` copies each aside before building and restores it after.
- **directories** — three empty ones (`local/lib`, `cmd/efl/efix`, `libplot/libblit/xplot`) were
  the whole remaining difference once the overwritten files were accounted for.

### Checking it from the host

The equation was proven once, on 2026-09-04, by tarring a live machine onto the share. Nothing
checked it again, and by 2026-10-07 the golden disk and `v10/` disagreed on **301 paths**:

- **90 repository edits had no way to reach a machine.** `updatebuild` delivers `build/` and the
  `build/mkfiles` rows, and a source fix made in `v10/` was neither. So `dmesg`, `docgen`, `troff`,
  `sdb`, the kernel's `printf` arguments and vol2 had all been fixed in git, and the golden still
  built every one of them from the unfixed source. `finddev.c`'s fix was lost a second way: it
  went into `src/cmd/finddev.c`, and `patch` copies `build/v8/finddev.c` over that file.
- **The repository lagged the machine** on 24 files that `patch` repairs (`struct`'s casts,
  `cref`, `stdio.h`'s `_IOFBF`, `lrndef`, `macrunch`, `install.sh`), and spelled five names in
  the wrong case. `qsnap`'s two sources had been swapped by hand on 24 Sep in the belief that the
  names were wrong, when the names were right and the swap moved the contents.
- **48 build products** (`struct`'s objects, `cref`'s tables) were on the golden from a build
  older than the before/after sweep, so no sweep ever counted them.

`tools/v10fs.py` reads a V10 disk image directly, and `tools/v10-tree-check.py` holds every
difference to a delivery route: mkbuild for `src/build`, a `build/mkfiles` row for anything else
in `v10/usr`, and `patch` for its own repairs. Each file `patch` copies whole must equal its
source here and have a row of its own, because `patch` runs only when the patch *script*
changes (`mkfile:254`). `--current` additionally fails anything still waiting to be delivered,
which is the question to ask after a rebuild. The equation's exceptions are named in the script,
each with its reason:

- `sys/ipnx/*`, `build/src`'s kernel configuration, which `patch` and `mkfile:1830` put on the
  machine and `v10/` deliberately does not carry twice;
- `sys/io/camac.s` and `pascal/libpc/libpc`, `preserve` rows whose copies on **both** sides are
  build products (`camac.s`'s `.stabs` line is dated 2026), because builds before the restore
  existed overwrote them with no copy kept. Only the tapes have the originals;
- empty directories, which git cannot hold.

## What `ipnxbuild` does

`patch` first, then a snapshot of every file and directory under `usrtrees`, then the
`preserve` copies, then the build in four `mk` processes (`build1`..`build4`), then the install
targets — each in **its own `mk`**, because a virtual target whose prerequisites are themselves
virtual aggregates dies at its first fork with `Not enough memory`, and so does a flat
300-prerequisite aggregate. Measured on the machine, in every combination.

Afterwards it writes `/usr/ipnx/derived`, the list of every file that appeared, by comparing the
tree against its own snapshot. **The build knows what it wrote**; a sweep that has to work it out
afterwards gets it wrong — patterns that deleted tape files, a magic test that could not see a
generated header, an archive comparison that read `x linked to y` as a filename and deleted every
hard link in the tree. `ipnxclean` is one line, and it reads that list.

`world` is the distribution in bootstrap order:

```
tools lib libs usrbin bin etc $ROOT/unix $ROOT/.profile ulib cmds pkgs games
```

The order is enforced by real dependencies, not by the list: `lcc` depends on `rcc` and
`gcc-cpp`, and `libc.a` depends on `lcc`, because libc's own mkfile compiles ten of its members
with it.

**`$ROOT` means only where output goes** — not where the toolchain is, not where the build system
is. `$GEN` is pinned to `/usr/src/build` and does not follow `$ROOT`, so the builder's kit is
what runs whichever disk is being filled, and there is no copy on the target that can go stale.

### What a failed recipe does, and what `ipnxbuild` says about it

A recipe that fails says so — `NAME: FAILED`, `install FAILED`, `the package did not produce
it` — and `mk` carries on, which is what lets one broken package not stop three hundred others.
Until 8 Oct 2026 those lines were in the console log and nowhere else, so a build could finish
with status 0 and a broken package in it. Now:

- **Every step's output goes through `tee` into `/usr/ipnx/build.log`**, and `mk`'s own status
  comes back through a file, because a pipeline's status in this `sh` is `tee`'s. `mk` flushes
  its echo before every fork (`mk/src/run.c:74`), so the log is in the console's order.
- **The failures are counted from it** into `/usr/ipnx/failed`. Every marker is also in the log
  as recipe *text*, because `mk` echoes a recipe before running it, and every such line has
  `echo` in it, which no message has. A full build's console log on 8 Oct held 1,266 lines with
  `FAILED` in them and not one failure.
- **Status 0** is a build with no failed recipe; **1**, a step — `mk` itself — failed and the
  steps after it were skipped; **2**, every step ran and some recipe failed. A 2 holds back
  `obsolete`'s removals, as a 1 does. `ipnxbuild /v10` does the same into `build.v10.log` and
  `failed.v10`.
- **A failed link's output is never copied.** `ld(1)`: *"This file is made executable only if
  no errors occurred during the load."* So a program whose link failed is still there, mode
  664, and an install's `cp` put it in place — over a working binary it arrived executable,
  because `cp` keeps an existing target's mode. Around the steps, `cp` is
  `build/src/guardcp`, which refuses a source with no execute bit, a VAX a.out magic and a name
  not ending in `.o`. An undefined symbol makes `ld` keep the relocation bits and write `0407`
  (`ld.c:847-858`), the format of an object file — the guard's first version looked for `ld`'s
  default `0413` and passed every failed link it was shown. Every rule gets it without being
  edited, the rule's own `|| echo` says `FAILED`, and the old target stays whole.

## C++

V10 has C++ — cfront 2.1 (`<<2.1++ 08/24/90>>`), `libC`, `munch` and `CC` — and **builds it
with itself**, as `cc` builds `cc`. Getting the first one took V8.

**No tape carries a cfront binary**, and cfront is written in C++. AT&T shipped a
half-translated C version beside the source so a native `cc` could start the chain; that set is
on none of the six tapes (`build/mkfile` records the search), and neither is `Cpre`. V8's
golden, though, carries Bell's VAX `cfront` (`<<cfront 7/04/85>>`), its `munch` and its
`libC.a` — three of the files V8 shipped without source (`v8/mk/gen/carry.txt:67,81,1117`) —
and the chain from there to V10's own translator is four links long:

| stage | what | translated by |
|---|---|---|
| 1 | cfront 2.00 (`cmd/cfront/cfront2.00`, 06/30/89) | V8's 1985 cfront, through `build/src/cf85fix.c` |
| rt | `libC`'s `new/` and `misc/`, and `munch.c` | stage 1 |
| 2 | cfront 2.1 (`cmd/cfront/cfront`) | stage 1 |
| 3, 4, 5 | cfront 2.1 | stage 2, then 3, then 4 |

**The 1985 translator has three bugs that cfront 2.00's source walks into**, each of which
cost stage 1 a crash, and each measured on the translator's own output before it was worked
around:

- `sizeof(type)` followed by an operator groups everything to its right first: `n*sizeof(int)+2`
  is `n*6`, `n-sizeof(S)-2` is `n-14`, `new char[n*sizeof(S)+1]` allocates `n*17` bytes.
  `norm2.c` sized its free-list chunks that way and overran them into `malloc`'s next block.
  `(sizeof(S))` is right, and so are casts and `sizeof x`.
- A `for`-init with two declarators — `for (Pname nx, nn=n; nn; nn=nx)` — loses every
  initialiser unless the `for` opens an inner block, so the loop walks stack garbage;
  `classdef::dcl` crashed on every class with a base. A declaration statement in front of the
  `for` keeps them, and 2.0 scopes a `for`-init to the enclosing block anyway.
- A reference parameter's default argument — `const ea& = *ea0` in `cfront.h` — comes out as a
  cast of a struct to a pointer, which `cc` rejects 190 times.

`cf85fix -i` rewrites the first two on `cpp`'s output and `cf85fix -o` the third on the
translator's; nothing in the tree is edited for them. All 53 struct layouts the 1985 translator
computes match `pcc`'s, which ruled size out before the bugs were found.

**The fixed point.** Stages 3 and 4 translate all 27 files of cfront 2.1 identically, so a
fifth stage built from stage 4's translations is stage 4 again: the two binaries differ only in
the 28 compile times the symbol table carries, and stripped they are the same bytes. Stage 2
does not match stage 3 — it puts a `# line` directive before some empty statements where 3 does
not, whitespace and nothing else — which is why 3 and 4 are the comparison. `cfboot` builds
stage 5 to make it: each stage's directory keeps the translations the stage before it made. With that in hand the rest is ordinary: `libC` whole, 57 objects, runs iostream,
`complex`, `strstream` and the `task` library's coroutines.

**What V10's tree needed**, six whole-file repairs (`build/mkfiles`): `CC/memory.h` and
`CC/string.h` use `size_t` and nothing they include declares it, so no program that includes
`<iostream.h>` compiled; `libC/generic/generic.c`, `libC/task/obj.c` and `munch.c` call
`abort` or `exit` with nothing declaring it, which 2.x refuses; and `libC/iostream/oldformat.c`
names a buffer `max`, which V10's own `CC/libc.h:67` declares as a function — Research libc
has `max` and `min`.

**`CC` is ours**: no tape carries V10's driver. `build/src/CC` is V8's `/usr/bin/CC` with what
`c++(1)` and cfront 2.1 need — `cpp` given `-D__cplusplus=1 -Dc_plusplus=1`, which 2.1's own
sources test, and `munch` taken from `/usr/lib/munch` as `c++(1)` says — and three of V8's own
slips fixed, each marked. **`munch` is `munch.c`**, Research's own, as `cmd/cfront/mkfile:6` has
it: it takes V8's `_STI` names and 2.x's `__sti__` alike and exits 1 when it wrote a table,
which is the convention V8's `CC` relinks on. `munch2.1.c` beside it is AT&T's, and exits the
other way round.

**To give a machine C++ for the first time**, on the host and then on the guest:

```bash
python3 tools/v10-cfseed.py        # V8's three files + V8's CC headers -> work/cfseed
```
```sh
sh /usr/src/build/cfboot /n/macos/work/cfseed     # after updatebuild; about five minutes
```

`cfboot` checks the seed's `ORIGIN`, refuses a tree without this repository's repairs, runs the
four stages, stops without installing anything if 3 and 4 disagree, installs `/usr/bin/CC`,
`/usr/bin/cfront`, `/usr/lib/munch` and `/usr/lib/libC.a`, and proves them by compiling a
program with a static constructor and destructor through the installed `CC`. **After that it
is never needed again**: `build/mkfile`'s C++ rules rebuild all four with the machine's own
`CC`, and a new cfront is installed only if it can translate a line of C++ first, because it
replaces the only translator the machine has.

## What the build does not reach

The tape carries its own manifests of what a V10 machine holds — `cmd/Admin/binfiles`,
`etcfiles`, `libfiles`, `ulibfiles` — and they are the measure. Recounted against the
mkfile's install lists on 2026-09-17:

| | on the tape's list | not built | |
|---|---|---|---|
| `/bin` | 57 | **4** | `iostat` `mail` `rmail` `rsh` — each explained in the mkfile header |
| `/etc` | 56 | **4** | `analyze` `backsh` `catman` `dklisten` — no source on any tape |
| `/usr/lib` | 50 | **23** | below; it was 27 |
| `/lib` | 1 | 1 | `dknames`, which nothing in the corpus produces or reads |

The 23 still missing from `/usr/lib` are not one kind of thing:

```
11as2 11c0 11c1 11c2 11crt0.o      the PDP-11 cross-toolchain
libbt.a libg.a libnew.a libport.a  libraries
libr.a libsa.a libtc.a
suftab man manprog tel             troff and man data files
ikeya.term ikeya.tmac lib.b
lisp cunumber                      programs and their support
ex3.6preserve ex3.6recover
```

`macros`, `uucp`, `Rpull` and `Rpush` came off that list on 2026-09-17; the file-by-file
reading below is what found them. Some of the rest have no source on any tape and never will
be built; others are data files V8 carries and V10's tapes do not.

**A name counted present is a weaker statement than it looks.** `tmac` counted as installed
before any of this work, because `docgen` and `postscript` each `mkdir` it for their own
helpers — and it held no macro package at all, which is why `man(1)` could not format a page
on any disk this project has built. Check what is *in* a directory the manifest names.

Directories under `/usr/src` that the mkfile never names at all: `lbin/Mail`, `lbin/kermit`,
`lbin/mailx`, and four under `ipc/` (`h`, `mgrs`, `perf`, `servers`). Everything else is named
somewhere, which is not the same as being built.

## The lists

Each is the only statement of its thing. *A component list that appears twice will disagree* is
the rule the directory is built around.

| file | what it settles | read by |
|---|---|---|
| `usrtrees` | the shape of `/usr` | `taripnx`, `mkipnx`, `mkimage`, `ipnxbuild` |
| `casenames` | which spelling of a **tape** path survives | `mkv10`, at extraction |
| `casefix` | the `/usr`-relative renames that keep one name per path | `updatebuild`, `ipnxbuild /v10`, `mkv10` |
| `arcfix` | dissolving every `ar` archive into a directory | the same three |
| `mkfiles` | every file the repository carries for the tree that no tape or `patch` run puts there: the converted mkfiles, whole-file repairs, and `patch`'s own copies | `updatebuild`, `mkipnx`, `ipnxbuild /v10`; held to by `tools/v10-tree-check.py` |
| `preserve` | tape files a rule rewrites in place; line order is restore order, so an input sits above what is made from it | `ipnxbuild` |
| `obsolete` | products an older rule installed at a path no rule makes now, removed after a clean in-place build | `ipnxbuild` |
| `inshape` | products a rule installs *inside* a `usrtrees` root — `maps/map`, `local/lib/flex.skel` — which the sweep must keep | `ipnxclean`, `ipnxbuild`'s overwrite report, `tools/v10-tree-check.py` |
| `proto-dev` | every node `/dev` needs | `tools/v10-proto.py` → it → `tools/v10-makedev.py` → `mkdev` |
| `mkcheck` | what a machine must already have before the mkfile will run | by hand |

`build/etc` and `build/v8` are not lists but **what the build ships as it is**. `build/etc` is
the configuration (`rc`, `fstab`, `passwd` …) and, since 8 Oct 2026, data no tape carries:
`dst` (ours), `Units` and `Monetary.Units` (generated from the tape's own old units table by
`tools/v10-units.py`, whose `--check` keeps them in step), `hyphen.tex` (Knuth's, from Plan 9's
tree) and the mail system's `upas.*`. `build/v8` is byte-identical to this repository's `v8/`:
five sources `patch` copies into the tree, and the data `words`, `lib.b`, `fortunes`, `quiz.k/`
and `cunumber`. `mkbuild` copies both by listing them, so a new file arrives on its first
round; `build/v8/README` says where each came from.

### Case: the survivor is what the build names

Where two tape paths differ only in case, exactly one keeps its name, and **the survivor is
whatever the directory's own build file names — not whatever is lowercase**. Lowercase-wins was
the earlier rule and is wrong twice over: `ostdio`'s `olibcmkfile:123` is
`doprnt.o: stdio/doprnt.S`, and `cfront/libstring`'s makefile names `String.h` seven times and
`string.h` never.

`casenames` settles **tape** names, because it runs during extraction. `casefix` and `arcfix`
settle the **tree**. Both are applied by `mkv10` as well as by `updatebuild`, because two paths
to one tree must apply one discipline — until they did, a tree built from the tapes and a tree
built by a machine disagreed in 699 files.

### Archives

`arcfix` extracts each archive's members into a directory named as the archive's bare stem —
*folders cannot have extensions*, so `tek.c.a` becomes `tek/` — writes `ar t` output to `ORDER`
beside them, and deletes the archive. Object members and all-object archives are deleted
outright. **This is true of the repository tree and not of the machine**: `mkv10` fills
`/usr/src` straight from the tapes, where the same name is an archive, so a rule written for the
wrong form fails with `bad directory`.

## `patch`, and what is ours

`build/patch` is a shell script of **idempotent** source repairs run before anything compiles.
The stamp is `$CMD/.patched`, a real target whose prerequisite is `$GEN/patch`, so `mk` re-runs
the repairs when the script is newer. `PATCHES.md` is the long form, with the evidence per
repair.

`build/src` holds the sources this project wrote, which no tape carries:

- **`9pfs.c`** — **the share.** It serves a remote 9P2000.u tree to this machine's own netb
  client, which is what lets the host run a standard 9P server and this project implement no
  netfs at all. No kernel change was needed: `fmount(2)` takes an open **file descriptor**, and
  `netfs/libnetb/runfs.c` pipes a local user process onto a mount point, so the far end of a
  mount can be a program. `/etc/rc` starts it as `runfs /n/macos /etc/9pfs 10.0.2.2 9200`.
  It is the thirteen `<rf.h>` callbacks expressed as 9P messages; `libnetb` does the netb wire,
  the tag table, the permission checks and the dispatch loop. See its header comment.
- **`nafsmnt.c`** — mounts a **netfs** share, and stays. It is what a golden older than `9pfs`
  boots with, and netfs is still V8's protocol. V10 removed `gmount` and `fmount` takes an open
  file descriptor, so the connection is named by the fd; `fstab(5)` has five fields and none
  holds a host or a port, so neither mounter can be reached through `/etc/mount -a`.
- **`ipnx-v10.m`** — the kernel configuration: a VAX-11/780 with an **RA73** root, 128 MB,
  sixteen MSCP disks, thirty-two DZ11 lines and an Interlan. **Three swap areas, and their
  minors carry `0100`.** `io/sw.c` frees only index 0 at boot; the rest are freed by
  `swapon(2)`, which matches the named block device's `rdev` against `swdevt[]` — and
  `/dev/ra02` is minor 66, not 2, because `0100` marks a bitmapped filesystem. Declared by
  partition letter, the two 122 MB areas answered `No such device` on every boot and the
  machine ran on 10 MB. It **and `ipnx.mkfile` are targets in `build/mkfile`**, not only
  copies made by `build/patch`: patch runs when *patch* changes, so before that an edit to
  the configuration reached a guest only by coincidence. The rules are `cmp`-guarded, so an
  unchanged `.m` does not re-date itself and rebuild the kernel every round.
- **`streamio.c`** — the tape's `lsys/os/streamio.c` plus the four repairs netfs needs, carried
  whole because four edits across fifty lines of C is past what a `sed` can do idempotently.

## The rules that recur

Each is written into more than one script because each was learned the same way.

1. **A component list that appears twice will disagree.** Where it can be, *the list is the
   directory*: `mkbuild` enumerates its source directory, `ipnxinstall` enumerates `$GEN/etc`.
2. **Whatever mounts, unmounts, including on the failure path.** V10 records in the superblock
   that a filesystem is mounted, so a missed unmount makes the next boot answer `In use` and
   carry on with an empty `/usr` showing through, reporting nothing.
3. **Tally into files, never variables.** This shell forks for a compound command carrying an
   input redirection, so a counter incremented inside `while read ... done < file` is lost.
4. **`sync` twice, and V10's kernel does not sync on halt** — `md/machdep.c`'s `boot()` calls
   `death()` without one, so a file written and then left by `^E` is not on the disk at all.
5. **Write an archive outside the tree it archives.** `tar` here has no `--exclude`, and an
   archive created under the directory being walked is copied into itself while it grows.
6. **Extract twice.** `tar` walks in inode order and emits a hard link the moment it meets it, so
   a link can precede its target — and V10's `tar` drops it in silence. 38 files went missing
   that way.
7. **`DIRSIZ` is 14.** `sys/dir.h:2`. A fifteen-character filename makes `creat` answer ENOENT
   and `rm -f` stay silent.
8. **V10's `cp` takes only `-z`.** No `-r`, so a directory is copied by a loop per level; no
   `-p`, so a stamp is written with `echo`.
9. **A guard is `exists at all`**, spelled `-f` or `-d`: this `test` has no `-e`.

## What is left

Four tasks finish V10. The first two are work on this tree; the third and fourth need the
emulator and the app.

**1. The data files V10 is missing, from V8 — done, 8 Oct 2026.** `tools/v10-datafiles.py`
asks the source rather than a list: every `/usr/lib` and `/usr/dict` path the tree names,
against what the mkfile installs. It found 19 that V8 has at the identical path. `words`,
`lib.b` and `cunumber` are imported, under `build/v8`. `tmac.cs` and the seven `macros/*` were
already built, and so is an `eign` — the tool reads source, so it cannot see a generated file;
but that `eign` is cref's table and not V8's word list ([v10-gaps.md](v10-gaps.md), fourth
status pass). The rest are wanted by nothing installed: `units` is the old program's table
(V10's reads `Units`, translated from the tape's own), `Mail.rc` is Berkeley Mail's, which is
not built, `lint -p` reads `llib-port.ln`, which is installed, and `upas/forwardlist` and
uucp's `Maxuuxqts` and `Maxuuscheds` are site policy whose absence means no limit
(`chkfwd.c:31-33`, `uuxqt.c:104-106`, `uusched.c:62-64`). `uucp/Systems` is a site's own.

**2. `/usr/src`, read file by file — done, acted on, and written up in
[v10-gaps.md](v10-gaps.md).** Every one of the 670 directories was walked in full, against
`build/mkfile`, with each claim cited to a file and line. The pattern it found: **the build
installs programs and not the data they read, nor the ownership they need**, and nothing fails
at build time when it doesn't — the program says `cannot open` the first time someone runs it.

Acted on 2026-09-17: all of §1, the ownership and set-id installs for every product the build
actually installs, and most of §4 — the macro packages, uucp's two destinations and its
set-uid bits, `/usr/lib/tabset`, `grap.defines`, matlab's help database, spitbol's error
text, atc's flow files, dict's ten helpers, worm's six, ideal's four filters, `lcomp`,
learn's whole lesson tree, `Rpull`/`Rpush`, and `canfield`.

**Then it was checked against a running machine**, which is why that list no longer includes
`psych` and `rain`. open-simh builds on a plain Linux host, the committed golden boots on it
with one disk and no share at all, and `tools/v10drive.py` runs a script of shell commands on
it.
Every gap the reading claimed is real on the machine; three of the fixes for them were not.
`macrunch` did not parse under V10's `sh` at all — repaired in `build/patch`, and `man`,
`-ms` and `-mm` then work. `psych` and `rain` do not link, and this file's own notes already
said why. `ideal` builds two of its four filters. What is still unrun: the ownership installs
and the three ROOT fixes, which need a `mk ROOT=/v10 world` against a second disk.

What was still open there was closed on 8 Oct 2026 — `units`, `/lib/dst`, `hyphen.tex`,
`trek`, mail, `ipc/`, `sky`, `sml`, `dist`, the PDP-11 tools and the rest of §3 that the tapes
can build — and v10-gaps.md's fourth status pass lists what stays, each with its reason: C++,
data on no tape, and a few decisions. `tools/v10-datafiles.py` re-runs the data-file half of
the measurement at any time.

**3. `/usr/jerq` or `/usr/blit` against the DMD emulator.** The host side is on the tape as a
VAX binary; the terminal side is the open question. Nothing here has been tried yet.

**4. The app, rewritten to run V10.** Its `MachineSpec` still describes a machine the kernel
was not measured against — 8 DZ lines where `ipnx-v10.m` configures 32, no `vh`/`rq*`/`tq`
lines, and an Interlan with neither address nor vector — so the device set simh autoconfigures
is not the one the compiled-in addresses assume.

**Also outstanding:** a host-side tool to create the blank disk image `mkimage` formats. V10
cannot make a sparse file, so a fresh disk currently needs a `dd` typed by hand.

## Testing the golden

```bash
bash tools/v10-reset.sh     # image/ -> run/v10, run/v10-golden, run/uda
bash tools/v10-launch.sh    # boots run/v10, golden on the second drive, shares up
bash tools/v10-golden.sh    # boots a throwaway copy of the golden alone
```

Both launchers boot the disk as an **RA73** and load the boot ROM at `FA00`, matching
`ipnx-v10.m`. The device set and the order it is enabled in are a property of the kernel, not a
preference: simh assigns Unibus addresses by DEC's floating-address algorithm at configure time,
and `ipnx-v10.m` carries the measured addresses compiled in.
