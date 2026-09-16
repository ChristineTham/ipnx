# The committed disks

Four archives, and they are the only binaries in this repository. Each is
`bzip2`-compressed tar, because **`tar -xSjf` is the only standard format that
restores a hole**: the zero runs come back as holes rather than allocated
blocks, so a 1.9 GB RA73 costs its non-zero bytes on disk. zip cannot do this
and neither can xz, and both were tried here first. Never unpack one without
the `S`.

| | | |
|---|---|---|
| `ipnx-v8-rp07.img.tar.bz2` | 10.6 MB | the Eighth Edition golden, **as this project builds it** |
| `v10.tar.bz2` | 3.3 MB | the V10 working disk `tools/v10-reset.sh` restores to `images/v10` |
| `v10-golden.tar.bz2.aa` + `.ab` | 139 MB | the V10 golden, in halves — see below |

```bash
git lfs pull                                            # see below
tar -xSjf ipnx-v8-rp07.img.tar.bz2 -C ../work/myv8      # -> work/myv8/ipnx-v8-rp07.img
bash ../tools/v10-reset.sh                              # both V10 disks + the boot ROM
```

## Git LFS, and the one pair that is not

`.gitattributes` puts `image/*.tar.bz2` through Git LFS, so in a fresh clone
those three files are 132-byte pointers until `git lfs pull` fetches them. `tar`
answers a pointer with `not a bzip2 file` — true, and no help at all about why,
which is why `tools/v10-reset.sh` checks for the pointer and names the command.

The golden is **committed in halves of 72,675,231 bytes** because GitHub refuses
a file over 100 MB. The LFS filter matches `*.tar.bz2` and so does not take the
`.aa`/`.ab` suffixes — they are ordinary committed blobs, present in every
clone. Join them by streaming, never on disk:

```bash
cat v10-golden.tar.bz2.a? | tar -xSjf - -C ../images
```

`cat ... > v10-golden.tar.bz2` leaves a 139 MB file that `.gitignore`'s
`!image/*.tar.bz2` exception does **not** ignore, so it shows up untracked and
invites exactly the commit the halves exist to prevent.

## Why a binary is here at all

`ipnx-v8-rp07.img.tar.bz2` is the **input to the next build**. Stage 8 lifts
1406 files off it that Bell Labs shipped without source — the games, the 5620
cross-toolchain, `cfront` — listed in `v8/mk/gen/carry.txt`. With it committed,
the build's only external input is the TUHS tapes, and `v8/MANIFEST` already
accounts for those.

It earns its place a second way: it is the known-good artefact a hash is taken
against. `fsck` restores metadata *consistency*, not data, so a clean pass is
not evidence anything survived — and on 2026-08-16 a single clean, fully
passing self-test moved the golden's hash, which only `tools/app-check.sh`
noticed. `tar -xSjf` put it back in eight seconds.

Everything else on the disk is built from `v8/` or is text already in git.
Which is which, and why retiring the TUHS image loses nothing, is
[docs/golden-disk.md](../docs/golden-disk.md).

## Do not add a fifth

`.gitignore` blocks `*.img` and every other raw disk suffix, and un-blocks
`image/*.tar.bz2` alone, so the packed form is the only way a disk can enter
git at all. That exception is the whole allowance; nothing else belongs here.
