# Building a Tenth Edition disk

*How V10 is built today, 2026-08-25. The ten-stage arrangement this document used to
describe — `work/v10`, `v10/src`, `v10/mk/gen`, a generated plan per stage — is gone, and so
are all six paths it named. What replaced it is smaller: two files the guest reads, and one
target. The design it is moving towards is [v10-build.md](v10-build.md); this document is
the present tense.*

## The shape of it

There are two halves and they meet at `/usr/src`.

**On the Mac**, three trees, each answering a different question:

| | | |
|---|---|---|
| `v10tapes/` | gitignored | the six TUHS archives, pristine, one root each. Re-extractable; `MANIFEST` has a hash per file. Never edited. |
| `v10superset/` | committed | a **corpus** — everything the six tapes hold, merged by rule, in whatever shape the tapes were cut |
| `v10/` | committed | a **filesystem** — what a running machine sees. Our working copy, edited directly. |

```bash
bash tools/v10-tapes.sh                 # six archives -> v10tapes/, pristine
python3 tools/v10-tree.py --bootstrap   # v10tapes/ -> v10superset/  (DESTRUCTIVE)
python3 tools/v10-check.py              # validate the superset, independently
python3 tools/v10-dist.py               # v10superset/ -> v10/  (DESTRUCTIVE)
python3 tools/v10-tree.py               # what have WE changed since the tapes?
```

**On the machine**, `/usr/src` is the real tree — extracted from the tapes by `mktape`, with
the tape's own names on a case-sensitive filesystem. `v10/` on the Mac is a proxy for it,
and a lossy one: 265 paths carry a `u_` prefix that does not exist on the machine, because
`v10-tree.py:225,243` renames case collisions for a case-insensitive checkout. Closing that
gap is the first item in [v10-build.md](v10-build.md).

## The two files the guest reads

Everything the build does is described by two files, both under `/usr/src/build`, both
edited in the repository at `v10/usr/src/build`:

- **`mkfile`** — one rule per product. `world` is the whole distribution in bootstrap order:
  `tools $INC lib libs usrbin bin etc $ROOT/unix $ROOT/.profile ulib cmds pkgs`.
- **`patch`** — a shell script of idempotent source repairs, run once before anything
  compiles. Everything V10 cannot compile as-shipped is a block in here with the evidence
  beside it.

`patch` **edits `/usr/src` in place**, and the guest's `/usr/src` persists between builds.
That is the single most important thing to know about this arrangement: a bad edit has to be
*repaired*, not merely stopped, because the tree already carries it. Several blocks in
`patch` exist only for that — they match a form the script itself produced on an earlier run.

## The loop

```bash
sh /usr/src/build/mkbuild / /n/macos/Users/christie/Repositories/Unix/ipnx/v10/usr/src/build
```

```bash
rm -f /usr/src/cmd/.patched
```

```bash
mk -f /usr/src/build/mkfile world
```

The first pulls the edited build system off the netfs share onto the machine. The second
clears the stamp so `patch` runs again — `mkfile:126-135` makes `.patched` and `.ranlib`
plain files with no `P` attribute, so their existence is the whole test. The third builds.

Three commands, two of them ceremony. [v10-build.md](v10-build.md) reduces this to
`updatebuild; ipnxbuild`.

### Targeting the other disk

`/v10` and `/v10/usr` are deliberately absent from `etc/fstab`, so nothing mounts them at
boot. `mkimage:19-31` is the authority on how:

```bash
test -d /v10 || mkdir /v10; /etc/mount /dev/ra10 /v10
```

```bash
test -d /v10/usr || mkdir /v10/usr; /etc/mount /dev/ra15 /v10/usr
```

```bash
sh /usr/src/build/mkbuild && sh /v10/usr/src/build/mkdev /v10/dev
```

```bash
mk -f /v10/usr/src/build/mkfile ROOT=/v10 world
```

```bash
cd /; sync; /etc/umount /v10/usr && /etc/umount /v10; sync
```

`mkbuild`'s default destination is `/v10`, which is why the third command needs no argument.
It is required, not optional: `mkfile:88,98` are `SRC=$ROOT/usr/src` and `GEN=$SRC/build`, so
`$GEN` follows `$ROOT` and the build reads `installed`, `patch` and `etc/*` from the target
disk. A stale copy there is a stale build.

**The unmount is not optional either.** V10 records in the superblock that a filesystem is
mounted, so a missed unmount makes the next boot answer `In use` and carry on with an empty
`/usr` showing through, reporting nothing.

## Why nothing rebuilds

Every target in the mkfile carries mk's `P` attribute pointing at `build/installed`, which
is one line:

```sh
test -f "$1"
```

It exits 0 — *not out of date* — whenever the target exists, and its comment says why: "the
binaries on the image came off the tape and are older than nothing in particular, so
comparing times would rebuild the lot."

The consequence is that **an installed target is never reconsidered**. That is what you are
seeing when `world` runs `patch` and then finishes at `libjobs.a` in seconds with nothing
between: everything else exists. It is also why a source fix does not propagate —
`mkfile:114,323` key the whole include tree on `/usr/include/libc.h`, so `patch` carries 24
absolute `/usr/include/` references to reach around a rule that will not run twice.

[v10-build.md](v10-build.md) deletes the predicate and lets mk compare times, which is only
safe once the tree holds no binaries.

## Fabricating a disk

Rarely, and in this order. `mkimage:34` names the chain: **mkimage, mktape, mkbuild, mkipnx,
mkimage.**

| | |
|---|---|
| `mkimage` | blanks ra1, mounts `/v10` and `/v10/usr`, extracts `ipnx.tar` into `/v10/usr`, runs `mkdev` and then `mk ROOT=/v10 world`, unmounts. With no `ipnx.tar` present it stops after mounting and says so — that is the bootstrap entry point. |
| `mktape` | fills a **blank** `/v10/usr` from the six archives. Refuses a populated tree: "extracting six tapes over it would mix two trees". |
| `mkbuild` | copies the build system into `<root>/usr/src/build`. Both ends parameterised; `/v10` by default. |
| `mkipnx` | writes **this machine's** whole `/usr` out as `ipnx.tar`. Removes `.patched` and `.ranlib` first, because "archiving them hands every disk made from here a source tree that claims to be patched and is not". |

`ipnx.tar` is the one file `mkimage` reads, and it lives at `/usr/src/build/ipnx.tar` —
inside the tree `mkipnx` archives, which is why `mkipnx:33-37` writes it to `/usr/tmp` first
and moves it in, and why `mkbuild` must not glob-delete its own directory.

Then, host-side:

```bash
expect tools/v10-tryboot.exp work/v10gold/v10-golden.img
```

## Where the seams are

Four things about this arrangement are known to be wrong, and all four are what
[v10-build.md](v10-build.md) exists to fix:

1. **`$GEN` follows `$ROOT`**, so the build system is duplicated onto every target and can go
   stale there. `mkimage:44-47` exists solely to paper over it: "THE ARCHIVE CARRIES WHATEVER
   BUILD SYSTEM THE DISK IT CAME FROM HAD, which is one generation behind as soon as this
   machine's own is edited."
2. **`ipnx.tar` means two different things** — a tree derived from the tapes plus our patches,
   and a snapshot of a live machine. Same name, different patch state.
3. **`/usr/src` is not the unit.** `include` comes from the source tree and is installed out;
   `sys` and `man` do not, so `mkipnx` must archive all of `/usr` to make a disk that can
   build. `mktape:79` is the tell — `mv /v10/usr/src/sys /v10/usr/sys`, moving out of the
   tree what the tape shipped inside it.
4. **Two build tools.** 241 `make` invocations in the mkfile against 47 `mk`, and four blocks
   in `patch` that exist only because V10's `make` execs the command itself rather than
   handing the line to a shell.

## State

The `world` target completes on the boot disk. As of 2026-08-25 the pascal package —
`eyacc`, `libpc`, `pc0`, `pascal`, `pi`, `px`, `pxp` — builds and installs. Getting there
took **473 substitutions over 1,018 lines of `patch`**, touching `libpc`, `pi` and `pxp`,
and it closed the last `pkgs` failure. Two thirds of those are one mechanical class: a parse
tree carried in `int *` that V10's `ccom` will not assign to or from a struct pointer.

The lab notebook is [docs/v10-log/](v10-log/), the plan the build reads is
[v10-plan.md](v10-plan.md), and what we have changed since the tapes is always
`python3 tools/v10-tree.py`.
