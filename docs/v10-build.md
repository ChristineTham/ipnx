# How a Tenth Edition is made

*What `v10/usr/src/build` does, read off the scripts themselves. They are the
authority; where this document and a script disagree, the script is right.*

Everything that makes a V10 disk lives in one directory on the machine,
`/usr/src/build`, edited in this repository at `v10/usr/src/build`. There is no
host-side build: the Mac fetches six archives and decompresses them, and V10
does the rest, on itself.

## The split, and why it falls there

The host half is `tools/v10-tapes.sh`, and it exists for two reasons that are
both about 1989. TUHS answers plain HTTP with a 301 to https and **V10 has no
TLS**; and **gzip is 1992 and bzip2 1996**, so a machine from 1989 has neither —
`cmd/` carries `compress(.Z)` and `pack(.z)` and nothing that reads these. So
the host fetches, decompresses to plain `tar`, and stops. Decompressing is not
extracting, so nothing about the tree is decided there.

Everything else happens on the machine, where the filesystem is case-sensitive
and the tapes' own names survive.

## The six verbs

| | | how often |
|---|---|---|
| `updatebuild [dir]` | refresh `/usr/src/build` from the repository share. **The only command here that touches `/n`.** | every round |
| `ipnxbuild [/v10]` | build a complete system from `/usr/src` — this machine by default, the disk on ra1 on request | every round |
| `mkv10 [tapes]` | the six tapes → `v10.tar`, pristine | once, ever |
| `mkipnx [repo]` | `v10.tar` + the build system + the repairs → `ipnxorig.tar` | when the patch set changes |
| `taripnx` | this machine's live `/usr` → `/usr/ipnx/ipnx.tar` | when a machine is worth preserving |
| `mkimage` | make a bootable disk on ra1, extract an archive into it, build it | when fabricating a disk |

`ipnxinstall` is the third verb of the install trio — `ipnxclean` removes what
was derived, `ipnxbuild` builds and installs nothing the operator owns, and
`ipnxinstall` installs the rest. It is the dangerous one, not because copying a
file is hard but because `/etc/passwd` and `/etc/rc` belong to the operator: it
asks before replacing a file that **exists and differs**, defaults to N, and is
silent when a file is absent (nothing to lose) or identical (nothing to do).

**The inner loop is two commands: `updatebuild; ipnxbuild`.** No mount, no
unmount, no `rm -f .patched`, no `ROOT=` unless you mean it.

## Bootstrapping from nothing

```
mkimage     # no ipnx.tar yet -> blanks ra1, mounts /v10 and /v10/usr, stops
mkv10       # six tapes -> /v10/usr/ipnx/v10.tar, then removes the tree
mkipnx      # v10.tar + build system + patch -> ipnxorig.tar
mkimage     # again, now with an archive to extract
```

`mkimage` handles the first step deliberately: with no `/usr/ipnx/ipnx.tar` it
says so, leaves `/v10` blank and mounted — which is exactly what `mkv10` needs —
and exits 0.

### What `mkimage` does

`dd` the boot block from `/dev/ra00` (this machine's own; `uda.s` reads absolute
block 0), then three filesystems: root at 1280 4k blocks, `/tmp` on partition
`e`, `/usr` on `f`.

**`/tmp` gets its own filesystem, and that is not tidiness.** Root is 1280 4k
blocks, and `mkbitfs`'s `isize = (size-2)/(1+ICOUNT)` makes that 1088 inodes, of
which `proto-dev`'s 917 are device nodes. `cc.c:178` hardcodes
`/tmp/ctm<pid>1..5` with no `getenv` and no flag, so **the compiler cannot be
pointed elsewhere** — the mount point is the only lever.

Then extract, `mkdev`, `mk world`, and `ipnxclean` to sweep what `world` just
made. No `cp /unix /v10/unix`: the mkfile builds the kernel and its predicate is
`test -f`, so a kernel copied in first would look up to date and the build would
silently keep the **builder's** kernel — the one thing the disk exists to
replace.

### What `mkv10` does

Extract the six tapes into a blank `/v10/usr`, in a fixed order, each to the
place the tar-of-`/usr` shape wants it:

- **secombe** → `/usr/src`; it cuts `sys` and `local` inside `src`, so both are
  moved out beside it.
- **sellers** → `/usr`, giving `man` and `vol2`. Sellers is the agreed source
  for the manuals: against norman's copy it is newer in all six pages that
  differ and carries two norman lacks, with nothing the other way.
- **milligan** → `/usr`, the 5620 distribution.
- **v10blit** → `/usr/blit`.
- **r70include** → `/usr/include`. It has to be at `/usr/include`, because
  libc's own mkfile names `/usr/include/libc.h` as an **absolute** prerequisite:
  a disk without it cannot build a libc at all.
- **v10src** (norman) → only what secombe lacks: `630`, `maps`, `doc`, thirteen
  source directories, and `cmd/adb/vax`. That last is one level down and easy to
  miss — secombe has `cmd/adb` with ten back ends and no `vax`, and ours is the
  one directory only norman carries.

The tapes are read **through a pipe, not opened**: `tar`'s `endtape()` calls
`backtape()`, which does an `MTIOCTOP` ioctl and tolerates only `ENOTTY`
(`tar.c:990`), so reading an archive straight off a netfs share dies with `tape
backspace error: No such device` at the end-of-archive block. A pipe answers
`ENOTTY`, `isatape` goes to 0, and the read completes — and the 413 MB of tapes
never need room on the disk.

Then `casenames`, `casefix` and `arcfix` (below), then **every compiled file is
deleted**. The tapes carry 2,093 objects and linked programs that Bell left in
their own source directories, and this is the only moment that can keep them out
of every archive downstream — `v10.tar` is what `mkipnx` and `mkimage` build
from, so a binary admitted here is a binary in the distribution for ever. It is
**not a list**: `file(1)` reads the a.out magic (0407, 0410, 0411, 0413, 0406 all
reach its `exec` label), so a file is compiled output because its own first two
bytes say so.

Finally the archive is written **outside the tree it archives** —
`/v10/usr/ipnx` is beside `src`, not inside it, because `tar` here has no
`--exclude` and an archive created under the directory being walked is copied
into itself while it grows.

### What `mkipnx` does

`v10.tar` extracted, `mkbuild` to install the build system, the tree's own
build files from `mkfiles`, then `patch`, then the `.patched` stamp, then the
archive.

It runs `patch` and ships the converted mkfiles **on purpose**, and the reason
is the equation below: a machine applies `patch` and takes the converted
mkfiles from the share while it builds, so its `taripnx` archive carries both.
An `ipnxorig.tar` that carried neither was 1,282 members apart from a machine's.

## The three archives, and the equation

| archive | contents | binaries |
|---|---|---|
| `v10.tar` | the six tapes, assembled, one name per path, nothing of ours | none |
| `ipnxorig.tar` | that plus `/usr/src/build`, the converted mkfiles, and the repairs | none |
| `ipnx.tar` | a machine that has already built | yes |

**`ipnx.tar` = `ipnxorig.tar` = `v10/`.** The first two are the same archive cut
at two moments, so they hold the same tree or one of them is lying — and making
them agree is what most of the accounting in `ipnxbuild` is for. Three things had
to be reconciled to close it:

- **`consumed`** — six rules regenerate a file the tape ships and then remove
  it (`lex`'s and `m4`'s `y.tab.c`, `make`'s `gram.c`, `pcc`'s `cgram.c` and
  `rodata.c`, `termcap.obj`), so a tree that has built lacks six files a tree
  that has not. `mkipnx` reads the list and removes them from its own tree.
  The list **accumulates**: which files a build removes is a property of its
  rules, not of the tree it started from, so a tree seeded from an archive that
  already lacks them consumes nothing and the list would come back empty.
- **`preserve`** — the derived list is a set difference of *names*, so it sees a
  file that appeared and is blind to one that **changed**. Twenty-five rows name
  tape files a tape's own rule rewrites in place. `ipnxbuild` copies each aside
  before building and restores it afterwards.
- **directories** — three empty ones (`local/lib`, `cmd/efl/efix`,
  `libplot/libblit/xplot`) were the whole remaining difference once the
  overwritten files were accounted for.

## The shape of `/usr`

`usrtrees` is the single statement of it, and three scripts read it rather than
repeating it — `taripnx` tars exactly these, `mkipnx` lays the tapes down into
exactly these and verifies, `mkimage` extracts and verifies the same:

```
src  man  include  sys  blit  jerq  630  maps  vol2  local
```

`bin` and `lib` are absent deliberately — they are **product, not shape**, built
and installed by a running machine and never carried in the archive. `ipnx`,
`tmp`, `adm` and `spool` are run-state and stay out for the same reason.

## The lists

Each is the only statement of its thing. *A component list that appears twice
will disagree* is the rule the whole directory is built around, and every list
here carries a scar that proves it.

| file | what it settles | read by |
|---|---|---|
| `usrtrees` | the shape of `/usr` | `taripnx`, `mkipnx`, `mkimage`, `ipnxbuild` |
| `casenames` | which spelling of a **tape** path survives | `mkv10`, at extraction |
| `casefix` | the `/usr`-relative renames that keep one name per path | `updatebuild`, `ipnxbuild /v10`, `mkv10` |
| `arcfix` | dissolving every `ar` archive into a directory | the same three |
| `mkfiles` | the build files the repository carries for the source tree | `updatebuild`, `mkipnx`, `ipnxbuild /v10` |
| `preserve` | tape files a rule rewrites in place | `ipnxbuild` |
| `derived` | every file the build wrote | written by `ipnxbuild`, read by `ipnxclean` |
| `consumed` | files a build regenerates and then removes | written by `ipnxbuild`, read by `mkipnx` |
| `proto-dev` | every node `/dev` needs | `tools/v10-proto.py` → it → `tools/v10-makedev.py` → `mkdev` |

### Case: Rule 0

The six tapes are case-sensitive and the tree has to survive a
case-**insensitive** checkout, so where two tape paths differ only in case
exactly one keeps its name. **The survivor is whatever the directory's own build
file names — not whatever is lowercase.**

Lowercase-wins was the earlier rule and it is wrong twice over: `ostdio`'s
`olibcmkfile:123` is `doprnt.o: stdio/doprnt.S`, so the build reads the
capitalised file and lowercase-wins renamed the one thing that had to keep its
name; and `cfront/libstring`'s makefile names `String.h` seven times and
`string.h` never.

`casenames` settles **tape** names, because it runs during extraction, and that
is all it can settle. `casefix` and `arcfix` settle the **tree**. Both disciplines
are applied by `mkv10` as well as by `updatebuild`, because two paths to one tree
must apply one discipline — until they did, a tree built from the tapes and a
tree built by a machine disagreed in 699 files.

### Archives

**No source archives in the tar of `/usr`.** `arcfix` extracts each archive's
members into a directory named as the archive's bare stem — *folders cannot have
extensions*, so `tek.c.a` becomes `tek/` — writes `ar t` output to `ORDER` beside
them, and deletes the archive. Object members and all-object archives are deleted
outright; the kernel's link libraries rebuild on the next `ipnxbuild` and the
object-only tape libraries are recoverable from `v10.tar`. `ORDER` keeps the one
thing a directory cannot.

## The mkfile

`build/mkfile` is one rule per product. The variables carry the whole design:

```
ROOT=            # where output goes -- AND NOTHING ELSE
SRC=$ROOT/usr/src
SYS=$ROOT/usr/sys
GEN=/usr/src/build   # the BUILDER's kit, pinned; it does not follow ROOT
```

**`$ROOT` means only where output goes.** Not where the toolchain is, not where
the build system is. Every use of `$GEN` is a read that writes to `$ROOT`, so
pinning it to the builder means there is no copy on the target that can go stale
— which is why `ipnxbuild` reads the mkfile from `/usr/src/build` whichever disk
it is filling, and why the toolchain is always this machine's.

`world` is the distribution in bootstrap order:

```
tools lib libs usrbin bin etc $ROOT/unix $ROOT/.profile ulib cmds pkgs games
```

The order is enforced by real dependencies, not by the list: `lcc` depends on
`rcc` and `gcc-cpp`, and `libc.a` depends on `lcc`. **libc cannot be built without
lcc** — libc's own mkfile compiles ten of its members with it — and lcc in turn
needs `gcc-cpp`, which is GNU CC 1.x's `cccp.c`, in `cmd/gcc`.

### Build and install are two halves

Every rule is two: the artefact, built in the source tree by `build1`..`build4`,
and the installed file that depends on it. `ipnxbuild` runs the four quarters
and then the install targets, each in **its own `mk` process**: a virtual target
whose prerequisites are themselves virtual aggregates dies at its first fork with
`Not enough memory`, and so does a flat 300-prerequisite aggregate. Measured, in
every combination.

Packages depend on a **virtual probe** rather than on source globs, for the same
reason: the globs made the parent's graph fat enough that `fork` began failing
against the 10 MB swap slice. The child knows its own sources and touches its
artefact only when something was stale, so the install half still moves on file
times alone.

### Times are compared

424 rules used to carry `mk`'s `P` attribute pointing at `./installed`, which
exits 0 — not out of date — whenever the target merely exists, so nothing was
ever rebuilt after the first pass. It is gone. A `:V:` prerequisite does **not**
propagate out-of-dateness to its parent (`mk.c:239` compares against
`arc->n->time` and `graph.c:153-155` gives a missing file time 0), so the `dirs`
target it was feared for costs nothing.

Every `make clean` carries `|| :`, because `mk(1):266-269` hands the recipe to
`/bin/sh -e` and `-e` abandons the whole recipe at the first non-zero command —
a `;` does not shield it, only a condition context does.

## `patch`, and what is ours

`build/patch` is a shell script of **idempotent** source repairs, run once before
anything compiles: the pattern is gone after the first pass. `mkimage`
re-extracts the tapes over the tree, so repairs are applied rather than edited in
place, and each is carried in the repository so git holds the record.
`PATCHES.md` is the long form, with the evidence per repair.

The stamp is `$CMD/.patched`, a real target whose prerequisite is `$GEN/patch`,
so `mk` re-runs the repairs when the script is newer — `rm -f .patched` is not a
thing to remember. `updatebuild` keeps that honest: `mkbuild` copies every file
whether it changed or not and a copy is always newer, so `updatebuild` compares
the old `patch` against the new one and **refreshes the stamp when it did not
change**, putting the stamp back in front of the copy.

`build/src` holds the sources this project wrote, which no tape carries:

- **`nafsmnt.c`** — mounts a netfs share. V10 removed `gmount` (slot 49 reads
  `nosys / was gmount`) and `fmount` takes an open file descriptor, so the
  connection is named by the fd. `fstab(5)` has five fields and none holds a host
  or a port, so this cannot be reached through `/etc/mount -a`.
- **`ipnx-v10.m`** — the kernel configuration: a VAX-11/780 with an RA73 root,
  128 MB, sixteen MSCP disks, thirty-two DZ11 lines and an Interlan. It lives
  here and not in `v10/usr/sys/ipnx` because `mkv10` fills `/usr/sys` by
  extracting secombe, and anything left in that tree beforehand is gone.
- **`streamio.c`** — the tape's `lsys/os/streamio.c` plus the four repairs netfs
  needs. Carried whole because four edits across fifty lines of C is past what a
  `sed` can do idempotently.

## What a machine must already have

`mkcheck` prints what is missing and is silent otherwise. The compiler's passes
are hardcoded — `cc.c:7-12` puts `cpp`, `ccom` and `c2` in `/lib`, `as` and `ld`
in `/bin`, `crt0.o` in `/lib` — and `-B` reaches only `ccom`, `c2` and `cpp`, so
those paths are absolute whatever else is set. `ld` searches `/lib`, `/usr/lib`
and `/usr/local/lib` and **has no `-L`**.

`mkmk` bootstraps `mk` itself, which `cmd/diff`, `cmd/ed`, `cmd/ps` and `cmd/sh`
are built with. `mk`'s own build is `cmd/mk/src/mkfile`, which cannot be used
because `mk` is what it needs.

## The rules that recur

Every one of these is written into more than one script, because each was
learned the same way.

1. **A component list that appears twice will disagree.** Where it can be, *the
   list is the directory*: `mkbuild` enumerates its source directory,
   `ipnxinstall` enumerates `$GEN/etc`. `mkbuild` held twenty names once, and
   adding `updatebuild` to the repository copied everything **except**
   `updatebuild` — a new file took two runs to arrive and the first looked like a
   success.
2. **Whatever mounts, unmounts, including on the failure path.** V10 records in
   the superblock that a filesystem is mounted, so a missed unmount makes the
   next boot answer `In use` and carry on with an empty `/usr` showing through,
   reporting nothing. `ipnxbuild` traps 1 2 3 15 for this: an interrupted build
   is the likely case, not the unlikely one.
3. **Tally into files, never variables.** 1970s `sh` forks for a compound command
   carrying an input redirection, so a counter assigned inside
   `while read ... done < file` is incremented in a child and lost. `cp` and `mv`
   survive the fork because their effect is on the disk; a count does not.
4. **`sync` twice, and V10's kernel does not sync on halt** — `md/machdep.c`'s
   `boot()` calls `death()` without one, so a file written and then left by `^E`
   is not on the disk at all.
5. **Write an archive outside the tree it archives.** `tar` here has no
   `--exclude`, and an archive created under the directory being walked is reached
   by that walk and copied into itself while it grows.
6. **Extract twice.** `tar` walks a directory in inode order and emits a hard link
   the moment it meets it, so a link is written **before** its target — and V10's
   `tar`, extracting in stream order, drops it in silence. 38 files went missing
   that way, every one a hard link. The second pass completes them.
7. **`DIRSIZ` is 14.** `sys/dir.h:2`. `updatebuild.was` is fifteen characters, so
   `creat` answered ENOENT, `rm -f` stayed silent, and `cmp -s` read the missing
   file as *differs* — which made every run take a self-handoff pass whether the
   script had changed or not. Found with `sh -x` on the machine.
8. **V10's `cp` takes only `-z`.** No `-r`, so a directory is copied by a loop per
   level; no `-p`, so an mtime cannot be carried across and a stamp is written
   with `echo`.
9. **A guard is `exists at all`**, spelled `-f` or `-d`, because this `test` has
   no `-e`. Directories collide too: `vol2/index` holds a `junk` file beside a
   `Junk` directory, and renaming the members one at a time leaves the directory
   colliding.

## Host-side tools that remain

| | |
|---|---|
| `tools/v10-tapes.sh` | fetch the six archives and decompress them to plain `tar` for the guest |
| `tools/v10-proto.py` | the kernel config and `sys/lib/tab` → `build/proto-dev` |
| `tools/v10-makedev.py` | `build/proto-dev` → `build/mkdev` |
| `tools/v10-launch.sh` | boot `images/v10` with both netfs shares up |
| `tools/v10-golden.sh` | boot a throwaway copy of the golden |
| `tools/v10-reset.sh` | restore `images/` from the committed archives |
