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
reading them straight off the netfs share if you name it. What the host does:

| | |
|---|---|
| `tools/v10-tapes.sh` | fetch the six TUHS archives and decompress them to plain `tar` in `v10tapes/` |
| `tools/v10-reset.sh` | `image/*.tar.bz2` → `run/`: both disks uncompressed, and the boot ROM beside them |
| `tools/v10-launch.sh` | boot `run/v10` with `run/v10-golden` on the second drive and both netfs shares up |
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

Five do the work. Everything else in the directory serves them.

| | what it does | how often |
|---|---|---|
| `ipnxbuild [ROOT]` | build a complete system from `/usr/src` — this machine by default, the disk on `ra1` when given `/v10` | every round |
| `ipnxclean [ROOT]` | remove everything `ipnxbuild` made, from the list `ipnxbuild` wrote | before archiving |
| `mkimage` | format the second drive, extract an archive into it, build it | when fabricating a disk |
| `mkv10 [dir]` | the six tapes → `v10.tar`, pristine. `/usr/tmp` unless told otherwise; the share works too, and costs the disk nothing | once, ever |
| `mkipnx [repo]` | `v10.tar` + the build system + the repairs → `ipnxorig.tar` | when the repairs change |
| `taripnx` | this machine's live `/usr` → `/usr/ipnx/ipnx.tar` | when a machine is worth preserving |

`updatebuild` is the sixth and is not part of a build: it refreshes `/usr/src/build` from the
repository over the netfs share, and it is **the only script here that touches `/n`**. The inner
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

## What the build does not reach

The tape carries its own manifests of what a V10 machine holds — `cmd/Admin/binfiles`,
`etcfiles`, `libfiles`, `ulibfiles` — and they are the measure. Compared against the mkfile's
install lists on 2026-09-16:

| | on the tape's list | not built | |
|---|---|---|---|
| `/bin` | 57 | **4** | `iostat` `mail` `rmail` `rsh` — each explained in the mkfile header |
| `/etc` | 56 | **4** | `analyze` `backsh` `catman` `dklisten` — no source on any tape |
| `/usr/lib` | 50 | **27** | below |
| `/lib` | 1 | 1 | `dknames`, which nothing in the corpus produces or reads |

The 27 missing from `/usr/lib` are the real hole, and they are not one kind of thing:

```
11as2 11c0 11c1 11c2 11crt0.o      the PDP-11 cross-toolchain
libbt.a libg.a libnew.a libport.a  libraries
libr.a libsa.a libtc.a
suftab macros man manprog tel      troff and man data files
ikeya.term ikeya.tmac lib.b
lisp uucp Rpull Rpush cunumber     programs and their support
ex3.6preserve ex3.6recover
```

Some of these have no source on any tape and never will be built. Others are data files V8
carries and V10's tapes do not. **Nobody has been through them one at a time**, and that is the
next piece of work: a directory-by-directory reading of `/usr/src` against these manifests,
rather than pattern-matching on what looks like a program.

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
| `mkfiles` | the build files the repository carries for the source tree | `updatebuild`, `mkipnx`, `ipnxbuild /v10` |
| `preserve` | tape files a rule rewrites in place | `ipnxbuild` |
| `proto-dev` | every node `/dev` needs | `tools/v10-proto.py` → it → `tools/v10-makedev.py` → `mkdev` |
| `mkcheck` | what a machine must already have before the mkfile will run | by hand |

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

- **`nafsmnt.c`** — mounts a netfs share. V10 removed `gmount` and `fmount` takes an open file
  descriptor, so the connection is named by the fd; `fstab(5)` has five fields and none holds a
  host or a port, so this cannot be reached through `/etc/mount -a`.
- **`ipnx-v10.m`** — the kernel configuration: a VAX-11/780 with an **RA73** root, 128 MB,
  sixteen MSCP disks, thirty-two DZ11 lines and an Interlan.
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

**The distribution, completed.** Read `/usr/src` against the `Admin` manifests directory by
directory — not by pattern — and decide per missing file: buildable, absent from every tape,
or fetchable from V8. The 27 missing from `/usr/lib` are the bulk of it.

**A host-side tool to create the blank disk image** `mkimage` formats. V10 cannot make a
sparse file, so a fresh disk currently needs a `dd` typed by hand.

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
