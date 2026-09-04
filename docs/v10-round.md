# v10 — the round, start to finish

The procedure for taking `images/v10` from whatever state it is in to a fresh
`/usr/ipnx/ipnx.tar` built by V10 itself. It is written down because it was
re-derived from memory a dozen times and got a different wrong answer each
time; the steps below are the checked ones and the notes say what keeps being
added that must not be.

One command per step. Never two at once — each depends on the last, and running
them together hides which failed.

## 0 — Host: launch

```
bash tools/v10-launch.sh
```

Starts both netfsd shares (9200 read-only on `/` → `/n/macos`, 9201 read/write
on `$HOME` → `/n/home`) and attaches `images/v10` as `rq0`, `images/v10-golden`
as `rq1`. Boots to `login:`. Log in as `root`.

Never run two simulators. Never run one from a session that is also giving
instructions.

## 1 — Read the machine before writing a single step

```
cat /etc/fstab
```

```
grep -c 'reboot interrupted' /etc/rc; test -b /dev/ra02 && echo HAVE-ra02; test -b /dev/ra03 && echo HAVE-ra03; df
```

**This is not optional and it cannot be done from the host.** `grep -a` over
`images/v10` finds *both* the old config and the new one in blocks — ten copies
of `/dev/ra02:/usr:0:0:2` beside three of `/dev/ra04:/tmp:rw:0:2` — because a
raw block scan cannot tell a live file from a freed one, and there is no V10
bitmapped-filesystem reader in `tools/` (`v8fs.py` is V8; every `v10-*.py`
reads the repository tree, not a disk).

What the answers decide:

- `fstab` carrying `/dev/ra04:/tmp` and three `sw` entries, and `rc` answering
  1 → **the config is installed. Steps 2 and 3 below do not exist.**
- either one missing → the config is not installed, and it goes on first with
  `mk -f /usr/src/build/mkfile /etc/fstab /etc/rc /etc/down /.profile`, then a
  clean halt and a relaunch so the new `rc` runs. Those four rules depend on
  `dirs` and their own source only — if they still carry `$PREP` they drag in
  `$SRCOK` (`mkfile:145`) and a four-file copy runs `patch` over the whole tree.

## 2 and 3 — the two steps that are NOT steps

Both come from `work/clone/round-K18.sh`, which ran against a **clone** whose
`/dev` had no swap nodes and whose `/etc/rc` predated the fix. On a machine
whose config is installed they are not steps, they are symptoms:

- **Manual `mknod` + `swapon`.** Swap is permanent in three places:
  `build/etc/fstab` carries `ra01`, `ra02`, `ra03` as `sw`; `build/etc/rc:34`
  is `/etc/swapon -a`; `build/makedev:64,72` creates the nodes and
  `proto-dev:181-183` declares them.
- **Patching `tar` by hand.** `build/patch:2569-2571` already carries the
  `MTIOCTOP` fix, so `updatebuild` plus `ipnxbuild` applies it.

## 4 — Wipe the ten trees

```
cd /usr; for d in `grep '^[a-z0-9]' /n/macos/Users/christie/Repositories/Unix/ipnx/v10/usr/src/build/usrtrees`; do rm -rf $d; done; ls; df /usr
```

On screen, not redirected: it is the destructive step and its output is short.

`usrtrees` is read **from the share**, not from `/usr/src/build`: a local copy a
failed round gutted makes `grep` print nothing, `for` iterate an empty list, and
the wipe silently do nothing while the `echo` at the end of the line still
claims success.

It removes only the ten names the archive carries — `src man include sys blit
jerq 630 maps vol2 local` — so `bin`, `lib`, `adm`, `ether`, `games`, `spool`,
`tmp` and `ipnx` stay. **Nothing is ever appended to that loop.** Appending
`rm -rf tmp/* ._* PaxHeader longnamelist` to it is what took `/usr` to 64 KB.

`rm -rf` is not the hazard: `cmd/rm.c:17-34` walks the characters of a combined
flag word and sets both flags.

## 5 and 6 — Extract, twice

```
cd /usr && cat /n/home/Repositories/Unix/ipnx/work/clone/ipnxorig.tar | tar xf - > /tmp/5.log 2>&1; echo $?; cd /
```

```
cd /usr && cat /n/home/Repositories/Unix/ipnx/work/clone/ipnxorig.tar | tar xf - > /tmp/6.log 2>&1; echo $?; df /usr; cd /
```

Piped in from the share so nothing 450 MB lands on `/usr`. Twice, because one
pass does not settle every entry.

**`ipnxorig.tar` must never be recut on the Mac.** bsdtar's default format adds
one AppleDouble `._name` member and one pax header per file, and `tar tf` on
macOS *hides both* — so a recut archive lists 27,708 clean-looking names while
holding 83,124 headers and less than half the tree's bytes. Cutting it that way
on 4 Sep 2026 produced a 271,589,888-byte archive with 197,889,380 bytes of real
content against the tree's 429,378,798, and cost a day: `._*` files and a
`PaxHeader` directory in `/usr`, `longnamelist` renames from `tar.c:1106-1108`,
no `/usr/include`, no `cmd/pascal`, no `cmd/paper`, and `patch` failing.

The archive V10's own `tar` wrote is the good one. If one must be cut on the
host, it is `COPYFILE_DISABLE=1 tar --format=ustar --no-mac-metadata` — the
longest path in the tree is 52 characters, so ustar needs no extensions — and it
is verified by a **raw header reader**, never by `tar tf`: total headers, count
of `._` basenames, count of pax types, and total content bytes against the
tree's own `du`.

## 7 — Seed `consumed`

```
test -d /usr/ipnx || mkdir /usr/ipnx; cp /n/home/Repositories/Unix/ipnx/work/clone/consumed.lst /usr/ipnx/consumed > /tmp/7.log 2>&1; echo $?
```

## 8 — Refresh the build tree from the repository

```
sh /usr/src/build/updatebuild > /tmp/8.log 2>&1; echo $?
```

After the extract, not before: the extract overwrites `/usr/src/build` with the
archive's copy of it.

## 9 — Build

```
sh /usr/src/build/ipnxbuild > /tmp/9.log 2>&1; echo $?; df /usr
```

It builds and installs, and its `etc` quarter installs `rc`, `fstab`, `down` and
`.profile` from `$GEN/etc` — so config repairs arrive here and need no separate
step. It ends by writing `/usr/ipnx/derived`, its own before/after difference:
files (`ipnxbuild:145`) and then directories (`:163`), both absolute.

**Every row of `build/preserve` is exactly two fields.** `ipnxbuild:98` reads it
with `while read n f`, so `$f` takes the whole rest of the line; a trailing
`# provenance` comment then reaches `cp /usr/$f $PD/$n`, `sh` strips from the
`#`, and `cp` gets one operand. 233 rows carried such a comment on 4 Sep:
231 `Usage: cp` messages, `29 of them saved`, and 2,688 tape files overwritten
with no copy kept. `test -f /usr/$f` passes for the same reason and catches
nothing.

**`ipnxbuild` restores what it saved, and that is what closes the equation.**
The save loop copies each `preserve` file to `/usr/ipnx/pres/NN` before anything
is built; the restore at the tail copies them back, *after* the OVERWRITTEN AND
NOT PRESERVED accounting (restoring first would make every rewritten tape file
look untouched) and after the install quarters (the built `libpc` and `camac.o`
are already in `/usr/lib` and `/unix`, so the source tree can go back to the
tape's bytes). It reports `N overwritten files restored`.

The restore used to live in `ipnxclean` and went when that became one line. In
the interval, four files stayed overwritten in every archive — and once such a
tree is committed, the tape's version is gone from the repository. That is how
`include/sys/ethernet.h` came to hold ether's `struct ether_in` instead of the
tape's `struct etherpup` and `dipconfig` became uncompilable, and how
`spell/brspell` and three `ipc/mgrs/svcmgr` sources reached 0 bytes. The check
is `python3 tools/v10-tree.py`, which must answer **`changed by us 0`**.

The restore tallies through `/usr/tmp/ipb.re`, not a variable: `done < file`
makes the whole `while` a forked child in 1970s `sh`, so `cp`'s effect survives
and a counter does not.

**The OVERWRITTEN AND NOT PRESERVED report is not a list of differences.** On
4 Sep it named 2,692 files, of which exactly **4** actually differed by content
— `sys/io/camac.s`, `spell/brspell`, `cyntax/lib/libc`, `pascal/libpc/libpc`,
`preserve` rows 01, 02, 07 and 09. The other 2,687 are tape-shipped objects and
binaries under `cmd/2500` and its like that the build rewrote **byte-identical**;
they show up as overwrites rather than as derived files only because the tape
ships them, so they existed before the build. Adding them to `preserve` would
copy 2,687 files aside every round for no change in the archive.

## 10 — Clean

```
sh /usr/src/build/ipnxclean > /tmp/10.log 2>&1; echo $?; df /usr
```

`ipnxclean` is one line — `cat /usr/ipnx/derived | xargs rm -rf` — and it removes
exactly what step 9 measured. It has no patterns, no archive comparison and no
argument. Every attempt to work out afterwards what was derived destroyed tape
content: extension patterns took `cmd/cyntax/nohup.out` and libcc's four `.t`
stamps, `cmd/bcp/mkfile:38`'s own `clean` rule took 95 files of source because
bcp's sources *are* `.c` and `.h`, and an archive comparison read `tar tf`
output where a hard link prints as `x linked to y` and deleted all 32 of them.

## 11 — Cut the archive

```
sh /usr/src/build/taripnx > /tmp/11.log 2>&1; echo $?; df /usr
```

`taripnx`, not a hand-rolled `tar cf -`. It writes `/usr/ipnx/ipnx.tar`, and
that fits: `/usr` is 1,566,016 KB and the clean tree is about 460,000, so the
450,000 the archive needs has room. K18 hit `07,0105 : file system full` here
only because it carried the 450 MB **input** archive on `/usr` as well and
relied on `taripnx`'s own `rm -f` to free the slot; reading the input from the
share removes that.

## 12 — Copy the archive and the logs out

```
cp /usr/ipnx/ipnx.tar /n/home/Repositories/Unix/ipnx/ipnx.tar
```

```
for n in 5 6 7 8 9 10 11; do cp /tmp/$n.log /n/home/Repositories/Unix/ipnx/v10run-$n.log; done; echo LOGS-COPIED
```

**The repository root, never `work/clone`.** `work/clone` is the assistant's
scratch area: the round *reads* `ipnxorig.tar` and `consumed.lst` from it and
writes nothing there. Everything the round produces lands in the repository
root, where it is the user's.

Capture every step from the start. A failure whose preceding lines were not kept
cannot be diagnosed — `cp`'s usage message names no caller, and asking for the
context after the fact costs a round and sometimes the whole run. The 231
`Usage: cp` lines of the 4 Sep round were found in one look at `v10run-6.log`
after two rounds of guessing without it.

**EVERY DESTINATION BASENAME IS 14 CHARACTERS OR FEWER.** `sys/dir.h:2` is
`#define DIRSIZ 14` and `nami.c` builds each path component into a buffer that
size, so the V10 end refuses a longer name however long a name the host could
store — the share being macOS makes no difference. `v10run-$n.log` is 12 or 13
and goes through; `v10run-mkimage.log` is 18 and `cp` answers
`No such file or directory`, naming the destination, with the source sitting
there intact. Measured on 4 Sep: `v10run-ub.log` (13) landed and
`v10run-mkimage.log` (18) did not, in the same loop, one iteration apart. The
same fault, in the same session, cost `ipnxclean` a round through
`ipnxclean.$$` where it now uses `icl.$$`. Count the basename before writing
the instruction.

## 13 — mkimage: the bootable disk on ra1

The golden disk is a fresh host file, and `tools/v10-launch.sh:13,54` attaches
that path as `rq1`, so nothing in the launcher changes:

```
rm -f images/v10-golden && dd if=/dev/zero of=images/v10-golden bs=1 count=0 seek=2007290880 && ls -l images/v10-golden
```

`seek` with `count=0` writes nothing, so the file starts as a pure hole and
grows only where `mkimage` writes. 2,007,290,880 bytes is the RA73.

Then, on the machine, `updatebuild` **before** `mkimage` whenever the build
system has changed since the last one: `mkimage:88` runs `$BUILD/ipnxclean /v10`
where `BUILD=/v10/usr/src/build`, and `mkbuild` fills that from
`/usr/src/build`, so a stale local copy is the one that runs. On 4 Sep the
machine held an `ipnxclean` that ignored its argument, which would have swept
the builder's `/usr` instead of `/v10`.

```
sh /usr/src/build/updatebuild > /tmp/ub.log 2>&1; echo $?
```

```
sh /usr/src/build/mkimage > /tmp/mki.log 2>&1; echo $?; df /v10 2>/dev/null
```

```
cp /tmp/ub.log /n/home/Repositories/Unix/ipnx/v10run-ub.log; cp /tmp/mki.log /n/home/Repositories/Unix/ipnx/v10run-mki.log; echo $?
```

`v10run-mki.log` is 14 characters, `v10run-ub.log` is 13. Both fit.

`mkimage` unmounts `/v10/usr` and `/v10` if they are mounted (`:19-20`), copies
the running root's boot block with `dd if=/dev/ra00 of=/dev/ra10 bs=512 count=1`
(`:23`), makes three filesystems — `mkbitfs /dev/ra10 1280` for root,
`/dev/ra14 31231` for `/tmp`, `/dev/ra15 392528` for `/usr` (`:33-35`) — mounts
them, extracts `/usr/ipnx/ipnx.tar` twice (`:58-59`), checks all ten `usrtrees`
arrived (`:60-63`), ships the build system with `mkbuild` (`:69`), makes
`/v10/dev` (`:75`), runs `mk -f $BUILD/mkfile ROOT=/v10 world` (`:77`), cleans
with `ipnxclean /v10` (`:88`), and unmounts (`:100-101`). `ra14` and `ra15` are
unit **1** — `ra.c:39` is `UNIT=(minor>>3)&027`, so minor 76 gives unit 1 part
e and minor 77 unit 1 part g — so nothing it formats touches the builder's own
`/tmp` on `ra04` (minor 68, unit 0 part e).

## 14 — Halt

```
/etc/down
```

Wait for `death`, then `q` at `sim>`. A machine that was not cleanly halted has
a corrupted disk; assume it. V10's kernel does not sync on halt —
`md/machdep.c:439-446`'s `boot()` is two lines — so the userland sync in
`/etc/down` is the whole flush, and V10 records in the superblock that a
filesystem is mounted, so halting without `/etc/umount -a` makes the next boot
answer `In use` and carry on with an empty `/usr` showing through.
