# The reconstructed V10 source tree

`v10` is a **superset** of the six tapes, built by `tools/v10-tree.py` from the pristine extracts in `v10tapes/`. This file is generated; it is the provenance record.

## Where every file came from

| tape | files in the tree | what it is |
|---|---|---|
| `norman` | 9722 | `/usr/src`. The larger source tape and the base of the tree. |
| `secombe` | 13394 | `/usr/src` from a **different machine**. Only 30 paths are its own; its value is that it is newer where it differs. |
| `sellers` | 174 | `/usr/man` and `vol2`. The documentation, two files fuller than norman's `man` and 167 fuller in `vol2`. |
| `milligan` | 3698 | `/usr/jerq`. The 5620 distribution. |
| `r70include` | 336 | `/usr/include`, r70's reconstruction. Its own root: `sys`, `libc` and `local` all collide with `/usr/src`. |
| `blit` | 1373 | The 68000 Blit. Its own root: `doc` collides, and it is a different terminal from the 5620 this project emulates. |
| **total** | **28697** | |

## How each file was chosen

| reason | files |
|---|---|
| identical on 2 tapes | 16029 |
| only tape with this path | 12600 |
| newer | 67 |
| same mtime on norman,sellers,sellers | 1 |

A path carried by one tape alone is taken from it. Where several tapes carry it and the bytes agree, there is no contest — that agreement covers most of the overlap and is what makes a *disagreement* evidence rather than noise. Where the bytes differ, **the newer mtime wins**.

## The contested paths

68 paths differ between tapes. Every one is listed here with the date of each contender, so the choice can be checked rather than trusted.

| path | taken from | contenders |
|---|---|---|
| `cmd/egrep/mkfile` | **secombe** | secombe 1995-09-11, norman 1988-07-08 |
| `cmd/map/export/index.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/export/iplot.h` | **secombe** | secombe 1994-11-25, norman 1988-01-17 |
| `cmd/map/export/libmap.a` | **secombe** | secombe 1994-12-07, norman 1993-02-09 |
| `cmd/map/export/map.c` | **secombe** | secombe 1994-12-07, norman 1993-02-09 |
| `cmd/map/export/map.h` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/export/route.c` | **secombe** | secombe 1994-12-07, norman 1993-02-06 |
| `cmd/map/export/symbol.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/index.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/iplot.h` | **secombe** | secombe 1994-11-25, norman 1988-01-17 |
| `cmd/map/libmap.a` | **secombe** | secombe 1994-12-07, norman 1993-02-09 |
| `cmd/map/libmap/harrison.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/libmap/homing.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/libmap/orthographic.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/libmap/perspective.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/map.c` | **secombe** | secombe 1994-12-07, norman 1993-02-09 |
| `cmd/map/map.h` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/map/map.sh` | **secombe** | secombe 1994-11-25, norman 1993-02-09 |
| `cmd/map/symbol.c` | **secombe** | secombe 1994-11-25, norman 1993-02-06 |
| `cmd/sed/fixedbugs` | **secombe** | secombe 1993-12-03, norman 1992-05-30 |
| `cmd/sed/sed.h` | **secombe** | secombe 1993-12-03, norman 1992-05-03 |
| `cmd/sort/Makefile` | **secombe** | secombe 1994-06-20, norman 1993-04-06 |
| `cmd/sort/README` | **secombe** | secombe 1994-06-20, norman 1993-03-11 |
| `cmd/sort/cfiles.c` | **secombe** | secombe 1994-06-20, norman 1993-03-01 |
| `cmd/sort/field.c` | **secombe** | secombe 1994-06-20, norman 1992-11-11 |
| `cmd/sort/files.c` | **secombe** | secombe 1994-06-20, norman 1993-02-03 |
| `cmd/sort/fsort.c` | **secombe** | secombe 1994-06-20, norman 1993-03-01 |
| `cmd/sort/fsort.h` | **secombe** | secombe 1994-06-20, norman 1992-11-10 |
| `cmd/sort/memmove.c` | **secombe** | secombe 1994-06-20, norman 1993-03-01 |
| `cmd/sort/merge.c` | **secombe** | secombe 1994-06-20, norman 1993-03-01 |
| `cmd/sort/mkfile` | **secombe** | secombe 1994-06-20, norman 1993-04-06 |
| `cmd/sort/rsort.c` | **secombe** | secombe 1994-06-20, norman 1992-11-10 |
| `cmd/sort/sort.1` | **secombe** | secombe 1994-06-20, norman 1993-03-11 |
| `cmd/sort/sorttest` | **secombe** | secombe 1994-06-20, norman 1993-06-08 |
| `cmd/sort/tables.c` | **secombe** | secombe 1994-06-20, norman 1993-03-02 |
| `cmd/spell.old/american` | **secombe** | secombe 1994-01-04, norman 1993-06-30 |
| `cmd/spell.old/british` | **secombe** | secombe 1994-01-04, norman 1993-06-30 |
| `cmd/spell.old/list` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell.old/local` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell.old/stop` | **secombe** | secombe 1994-01-04, norman 1993-06-30 |
| `cmd/spell/american` | **secombe** | secombe 1994-01-04, norman 1993-06-30 |
| `cmd/spell/amspell` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell/british` | **secombe** | secombe 1994-01-04, norman 1993-06-30 |
| `cmd/spell/brspell` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell/list` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell/local` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell/sprog.c` | **secombe** | secombe 1994-01-04, norman 1993-07-10 |
| `cmd/spell/stop` | **secombe** | secombe 1994-01-04, norman 1993-06-30 |
| `cmd/u9fs/u9fs.c` | **secombe** | secombe 1994-07-21, norman 1993-06-27 |
| `ipc/internet/routed.c` | **secombe** | secombe 1994-01-05, norman 1992-03-09 |
| `ipc/mgrs/ns/dbtypes.h` | **secombe** | secombe 1994-04-15, norman 1990-01-17 |
| `ipc/mgrs/ns/ns.c` | **secombe** | secombe 1994-04-15, norman 1993-02-10 |
| `jerq/src/lib/C/makefile` | **milligan** | milligan 1987-07-29, milligan 1986-01-15 |
| `libc/gen/memmove.c` | **secombe** | secombe 1994-06-20, norman 1993-03-01 |
| `man/man1/comm.1` | **sellers** | sellers 1995-02-28, norman 1989-08-16 |
| `man/man1/junk` | **sellers** | sellers 1995-02-28, norman 1990-01-27 |
| `man/man1/sort.1` | **sellers** | sellers 1994-06-20, norman 1993-05-05 |
| `man/man1/spell.1` | **sellers** | sellers 1994-06-18, norman 1993-04-28 |
| `man/man3/proj.3` | **sellers** | sellers 1994-08-05, norman 1993-02-06 |
| `man/man7/map.7` | **sellers** | sellers 1994-11-25, norman 1993-02-09 |
| `sys/astro/r70.m` | **secombe** | secombe 1993-11-08, norman 1993-02-09 |
| `sys/inet/ip_subr.c` | **secombe** | secombe 1994-01-06, norman 1992-03-09 |
| `sys/io/mkfile` | **secombe** | secombe 1994-08-17, norman 1992-05-08 |
| `sys/lib/devs` | **secombe** | secombe 1994-06-13, norman 1991-08-08 |
| `sys/lib/tab` | **secombe** | secombe 1994-06-13, norman 1991-08-08 |
| `sys/mkconf/tab` | **secombe** | secombe 1994-06-15, norman 1990-08-15 |
| `sys/toronto/mkfile` | **secombe** | secombe 1995-11-20, norman 1990-11-27 |
| `vol2/Preface/preface.ms` | **norman** | norman 1993-06-18, sellers 1993-06-18, sellers 1993-06-18 |

### Ties broken by precedence

1 paths differ but share an mtime to the second, so the date cannot choose. Precedence is `secombe > norman > sellers > milligan > r70include > blit`.

- `vol2/Preface/preface.ms` — norman, sellers, sellers

## What was left out

| what | files | why |
|---|---|---|
| `norman/history/ix` | 877 | IX is a different operating system (IBM's secure Unix), kept here as history; nothing in V10 builds from it |
| duplicate names | 1 | one inode under two spellings; see `v10tapes/HARDLINKS` |

Nothing else is excluded. Trees this project does not build from — `630`, `blit`, `dregs` — are still in the tree, because a superset is a statement about what the archive holds and what gets *built* is a decision the plan makes later.

## The archives, found by magic

0 files begin with `!<arch>\n` and are ar archives whatever they are called; 0 were unpacked into directories of the same name, each with an `ORDER` file recording the member order. 0 could not be read.

The name lies in both directions on this tape, which is why the magic number is the test: `crlib` is libcurses' archive with no `.a` at all, `plot.c.a` is an archive of **sources**, and `libdbm.a` is `mv dbm.o libdbm.a` — a bare object wearing an archive's name.

`ORDER` matters because V10's `ld` makes one sequential pass when `__.SYMDEF` is absent or stale, so an archive rebuilt in the wrong order leaves backward references unresolved. Unpacking keeps every byte and destroys the one thing a directory cannot hold.

