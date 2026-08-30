# ipnx-v11 — the edition that never was, and the last one here

*Scope framing 2026-08-10; rewritten 2026-08-26 after the kernel scope was cut out and
moved to a separate project. Nothing here is committed and nothing should start before B4
(V10 boots). The purpose of this document is to make the question answerable: **what could
an Eleventh Edition contain without ceasing to be Research Unix?***

**The scope, stated once.** V11 keeps **V10's kernel** and renovates **everything above
it**: the anachronisms come out, the language is settled on ANSI C, a ports format is
defined, and what the tree lost or never had is brought back. Nothing in the kernel's model
of itself changes.

**V11 is the cleanest possible Unix in the old tradition.** Not a new system — the old one,
with the accretions removed and the language settled. That is the whole ambition, and it is
deliberately smaller than an earlier draft of this document, which had grown a microkernel,
per-process namespaces and `rfork` into the kernel and had stopped being Research Unix
somewhere along the way.

### This is the last edition in this repository

**ipnx terminates at V11.** The reimplementation — a modified Plan 9 kernel hosted as a
userspace process, WebAssembly executables, no VAX at all — is a different project with a
different premise, and it lives at
[**ipnx-v12**](https://github.com/ChristineTham/ipnx-v12). See
[the README](../README.md#where-this-project-ends) for why the break is clean rather than
gradual.

The practical consequence for this document: **V11 is not a de-risking exercise for
anything.** It does not have to prepare a kernel for a port, and it must not take on work
that only makes sense downstream. It has to be good on its own terms and then stop.

## The admission rule

"Pure Research Unix" is the constraint, and it is a sharper one than it sounds, because it
is not about vintage or taste. What makes this system Research Unix is not its utilities —
it is the kernel's model of itself. V8 answered "how do I talk to a device?" with
**streams**, "how do I attach a foreign file system?" with the **file system switch**, "how
do I reach another machine?" with **netfs** and Datakit. 4.2BSD answered the same three
questions with sockets, vnodes and TCP-in-the-kernel, and those answers are *why* BSD is a
different system rather than a variant of this one.

So the test for any candidate is one question:

> **Does this change the system's model of itself?**

- **Sockets, vnodes, a 4.4BSD VFS, a wholesale ANSI libc** — yes. Refuse. There are a dozen
  good BSDs and this is not one of them. (And in the case of sockets the point is stronger
  than taste — see below.)
- **`snake`** — no. It reads a terminal and prints characters. Port it freely.
- **Per-process namespaces, `rfork`, 9P in the kernel** — yes, all three. That is what the
  earlier draft got wrong, and it is why they are now in another repository rather than in
  this section.

Everything below sorts into three classes by that test:

| Class | What it means | Licence estate |
|---|---|---|
| **Restoration** | The tree had it and lost it, or has half of it | 2017 covenant — already ours |
| **Continuation** | What the same people built next, brought back | Plan 9 / Inferno (MIT) |
| **Furniture** | Third-party programs that make the machine livable | BSD, and case by case |

Restoration first. It is the cheapest, the most defensible, and the most interesting.

## The surprise: a good deal of v11 is already in the tree

Before planning any backport, I listed the V10 source tarball (25,077 entries) and looked.
Research Unix was not sitting still while Plan 9 was being written down the corridor — the
two were the same people, and it shows:

| Found | Where | What it actually is |
|---|---|---|
| **9P** | `cmd/u9fs/` — `u9fs.c` (1,119 lines), `9p.h` | A Plan 9 file server for Unix, in the V10 tree |
| **mk** | `cmd/mk/src/` — `mk.c`, `graph.c`, `run.c` | Andrew Hume's `mk`, which Plan 9 later adopted |
| **sam** | `630/bin/sam`, `630/lib/sam.m`, `man/man9/sam.9`, `vol2/sam/` | The terminal half and the paper — see below |
| **netfs** | `netfs/README`, `netfs/serv/`, `netfs/libnetb/` | Deliberately protocol-agnostic; ships servers for 4BSD, V6, V7 and FILES-11 |

The `9p.h` header is worth reading in full, because it dates itself. It opens *"Plan 9 file
protocol definitions for use on Unix with ANSI C"*, and the protocol it declares is the
**original 9P, not 9P2000**: `NAMELEN` 28, `Tnop = 50`, `DIRLEN` 116, and messages that
later vanished — `Tclone`, `Tclwalk`, `Tsession` with DES tickets.

That single file changes the framing. **9P is not something ipnx would be adding to Research
Unix. Research Unix already speaks it, and the source is in the tarball we have.** The
`netfs/README` makes the same point from the other side: the servers "may be compiled with
any protocol library", and `libnetb` is merely the one Research used.

**In V11 that stays a userspace fact.** Building `cmd/u9fs` and seeing what it does is a
build, not a kernel change — and it is the single cheapest interesting result available.

### There is no sockets work to do — it was answered differently, and better

The obvious "missing BSD feature" is sockets. It is not missing.

**V8 already carries the whole Internet stack.** The probe found `/usr/include/sys/inet/`
on the golden image — `in.h`, `ip.h`, `tcp.h`, `tcp_var.h`, `udp.h`, `mbuf.h`, and a
`socket.h` of its own — plus `/usr/lib/libin.a`. N3 has already driven it: `ipconfig
/dev/il0`, ARP to SLiRP, and a DNS answer back ([n-track-notes.md](n-track-notes.md)).

**V10 has the sources for all of it**, and they are built out of Ritchie's streams rather
than bolted alongside them: `sys/inet/` holds `tcp_ld.c`, `ip_ld.c` and `udp_ld.c`, which
are **stream line disciplines**. The userland is in `ipc/internet/`: `routed`, `arp`,
`netstat`, `tcpconfig`, `ipconfig`, and `interlan.c` for the same NI1010 our N2 model
emulates.

And the API is the interesting part. From `ipc/libin/tcp_lib.c`, a connection is obtained
by *opening a file*:

```c
for(n = 01; n < 100; n += 2){
        sprintf(name, "/dev/tcp%02d", n);
        fd = open(name, 2);
```

then a `struct tcpuser` is written to the descriptor and the reply read back. That is Plan
9's `/net` — the network as a file system — running on Research Unix **years before Plan 9
shipped**. It is not a poor relation of sockets; it is the design sockets are usually
contrasted *with*, and it is already here.

**Do not port a sockets layer, and do not write one.** If a BSD program needs
`socket()`/`connect()`, the shim is a small `libcompat` addition over `/dev/tcp` — and
`hunt`, the one game that needs a network, becomes a test of that shim rather than a reason
to import an API.

### The gap worth naming: sam's host side is missing

There is **no `cmd/sam/`** in the V10 source tarball. What survives is the 630 terminal half
(`630/bin/sam`, `630/lib/sam.m`, `630/bin/samuel`), the manual page `man/man9/sam.9`, and
the paper in `vol2/sam/`. The editor's host side — the half that does the editing — is not
in the distribution.

Pike's `sam` is in plan9port, MIT-licensed, and its terminal protocol is documented in the
very paper the tree still carries. So one of the more compelling things V11 could do is
**put sam's host side back**, against a terminal half that is already sitting on the disk.
A restoration with a working target to test against on day one.

## Stream 1 — the cleanout

*The heart of the edition, and the first thing to do, because everything else is cheaper
afterwards.*

The tree carries software whose far end no longer exists. Measured over `v10/usr/src/cmd`
(5,059 `.c` files, 1,446,595 lines):

| Class | Directories | `.c` files | lines | verdict |
|---|---|---|---|---|
| **The far end is gone** | `uucp`, `netnews`, `ap`/`apsend`, `2500`, `bcp` | 145 | 48,532 | **Retire** |
| **The tape already superseded it** | `backup.old`, `spell.old`, `post.src` vs `postscript` | 90 | 30,935 | **Retire** |
| **Cross-target we do not emulate** | `PDP11` | 50 | 18,431 | **Retire** |
| **Only *looks* anachronistic** | `upas`, `nupas` | 170 | 23,372 | **Keep** |

`netnews` confirms the first row from inside: **40 of its files reference `uucp`/`uux`**. It
is a client of the transport and retires with it.

The fourth row is where getting this wrong costs something. `upas/README`:

> There are 4 directories containing configuration info and makefiles for making UPAS for
> different versions of UNIX: v9, 4bsd, sun4bsd, s5, s5.3k

That is Presotto's mail system — the one Plan 9 adopted and still ships. The word "old" is
not in its name and it is not an anachronism.

**The test is the admission rule run backwards.** `uucp` and `netnews` answer *"how does
this machine reach a machine that is not here"* — and this machine answers that with netfs
and the Internet stack it already has, so removing them is **replacement**, not loss.
`upas` answers *"how does mail work"*, and nothing replaces it.

**Retire before renovating.** Every later stream — the ANSI conversion above all — is
priced per file, and this stream removes 285 files and 97,898 lines before that meter
starts.

## Stream 2 — ANSI C throughout

The tree's language is settled here and the question is never asked per file again.

**The mess stays in V10.** V10 is a restoration and has to remain authentic; standardising
is this edition's job. And the mess is real, not aesthetic: V10 was never built from
scratch, it accreted, and the tape shows it. The `libc/mkfile` that produced the shipped
`libc.a` names `cc` for members only `lcc` can compile; 25 of the 261 members are already
ANSI (`int fprintf(FILE *f, const char *fmt, ...)`, `void *`, `size_t`, `<stdarg.h>`); and
the tree carries **two generations of stdio at once** — the K&R `doprnt.c`/`doscan.c` set
`omakefile` builds, and the ANSI `_dtoa`/`vfprintf`/`snprintf` set the archive actually
contains. **No makefile on the tape is a reliable guide to which file needs which.**

### The wall is the compiler, and only the compiler

```
$ echo 'int f(int a, char *b){return a;} main(){exit(f(0,0));}' > /tmp/p.c; cc /tmp/p.c
"/tmp/p.c":1: syntax error
"/tmp/p.c":1: expected a NAME in list
"/tmp/p.c":1: saw TYPE
```

V8's `cc` (1985, `/lib/ccom`, `/lib/cpp`, `/lib/c2`) is **K&R and will not take a
prototype**. No `stdlib.h`, no `stddef.h`, no `unistd.h`; variadic code uses `varargs.h`.

**V10 is a different machine on this point**, and it is why the conversion is possible at
all. Its tree ships `cmd/lcc/` — Fraser and Hanson's ANSI C compiler — including a
`gen2/vax-v9/` back end, ANSI header sets, and `cmd/dist/v10/lcc-incl/` supplying V10's own
`dirent.h`, `unistd.h` and `utime.h`. `sys/inet/lccmkfile` shows lcc compiling real system
code on the tape rather than sitting unused. It also carries `cmd/gcc/` (145 files, an early
1.x with m68k and ns32k targets).

Two candidates, and both are small enough to run on an 11/780:

1. **`lcc`** — in hand, buildable from source, VAX back end at `gen3/gen.c` + `gen2/vax/`.
   The default, because it is already here and already proven on this tree.
2. **A reconstructed VAX back end for the Plan 9 compiler** (roadmap D-A4). Thompson's
   *Plan 9 C Compilers*: a shared front end plus a per-architecture generator, "which is why
   the suite carries seven of them; writing an eighth is the intended way to add a machine"
   — and the generator itself is *"so small (less than 500 lines of C)"*. VAX code generation
   is answered twice over in source we own: V8's `cmd/pcc2/` and V10's own `cmd/ccom/vax/`
   (5,024 lines), with `cmd/as/instrs` and `libc/sys/*.s` fixing encodings and the calling
   convention. The Plan 9 wiki records the original VAX compiler as *"The compiler binary was
   recently found but the source appears to have been lost in the mists of time"* — so there
   is an **oracle** to diff against, exactly as V10's prebuilt `ccom` was for Track B.

Two orderings are not preferences:

- **Back end before port.** A converted tree with no compiler to check it against is
  unverifiable; a back end can be tested against V10's existing binaries the moment it emits
  anything.
- **libc before everything.** The same reason stage 2 precedes stage 3 in Track B.

`PATCHES.md:374` already records the direction: "The conversion direction is ANSI to K&R,
and that is deliberate. V10 keeps the 1989 language; V11 is where the tree becomes ANSI."

### What `libcompat` actually needs, measured

An earlier draft asserted V8's libc was "4.1BSD-era" — `index` and `bcopy` native, `strchr`
and `memcpy` absent — and that ports would need the *reverse* of the usual ANSI-ification
pass. **That was wrong, and measuring it changed the plan.**
`tools/v8-libc-probe.exp` boots a scratch copy of the golden and asks `nm /lib/libc.a`
directly (log: `work/myv8/v8-libc-probe.log`).

| Present | Absent |
|---|---|
| `strchr` `strrchr` `strpbrk` `strspn` `strcspn` `strtok` | `strtol` `strtod` `strstr` |
| `memcpy` `memcmp` `memset` `qsort` | `memmove` `atexit` `vprintf` `vfprintf` |
| `index` `rindex` `strcpy` (and `/usr/include/string.h`) | **`bcopy` `bzero`** |

So the string library is largely the ANSI one already, and the two functions the old draft
named as "native" are the two that are missing. V10 closes most of the rest: its `libc/gen/`
and `libc/stdio/` carry `strtol`, `strtod`, `memmove`, `atexit`, `vprintf` and `vfprintf`.

`libcompat` is therefore **seven functions**, not a string library, plus `bcopy`/`bzero` as
one-line wrappers, plus a prototype-eliding macro for anything still built by a K&R
compiler.

## Stream 3 — the ports subsystem

*Machinery, and this time it is ours.* A ports tree is not a build script — it is a
**format**, and choosing the format is an editorial act of exactly the kind the admission
rule governs.

The model is FreeBSD's: one directory per port, and the directory *is* the record. Distfile
name and origin, a checksum, a patch series applied in order, build and install rules, and a
declared dependency list. Nothing about a port lives outside its own directory, so a port
can be read, audited and deleted as one thing.

What this system imposes, and none of it is optional:

- **`mk`, not `make`.** Per [v10-build.md](v10-build.md), the tree is one dialect by then.
  mk earns its place rather than merely being consistent: `%` patterns and `:P:` predicates
  can express "rebuild when the distfile changed", which suffix rules cannot.
- **The fetch is host-side, and that is not a limitation to fix.** A 1989 system has no
  HTTPS, no `gzip` (1992) and no `bzip2` (1996) — it carries `compress` (`.Z`) and `pack`
  (`.z`). So a distfile is fetched and decompressed on the Mac and served over netfs,
  exactly as `tools/v10-tapes.sh` already does for the six tapes. **Decompressing is not
  extracting**: the archive is unpacked *on the guest*, so case collisions and long names
  are resolved by the case-sensitive filesystem that will hold them, never by macOS.
- **14-byte filenames** are a hard constraint on what a port may contain, and belong in the
  format as a check rather than as a surprise at extraction time.
- **Generated makefiles coexist rather than compete.** For an autoconf'd upstream,
  `configure` produces the *answers* and the port's mkfile includes that as a fragment.
  There is nothing to do about this in V10: the tree holds zero `configure`,
  `configure.in`, `Makefile.in` or `config.status` files, because autoconf 1.0 is 1991 and
  every build file on the tape is hand-written.

## Stream 4 — Plan 9 userspace

**Licensing is clean.** On 23 March 2021 Nokia Bell Labs transferred the Plan 9 copyright to
the Plan 9 Foundation, which relicensed all previous editions under the **MIT licence**;
plan9port carries the same terms. [Plan 9 from User Space](https://9fans.github.io/plan9port/)
is the porting reference, not the source of truth: it is exactly the exercise of adapting
Plan 9 code to a Unix, already done once, with the awkward parts visible in its diffs.

Ranked by value against tractability:

1. **`sam`** — restores a missing half, has a live terminal target, MIT. Start here.
2. **`mk`** — already present; the work is building it, not porting it, and it makes every
   subsequent port easier. It is also Stream 3's prerequisite.
3. **`rc`** — Duff's shell. Self-contained, small, and the one Plan 9 program whose absence
   is felt daily. No kernel dependency.
4. **`u9fs`** — build it as it stands and see what it does. Cheap, and the answer is
   interesting whatever it is.

**`acme` is not on this list**, and the reason is the admission rule rather than effort: it
wants a mouse-and-windows environment served through a namespace, and V11 has no namespaces.
It belongs to [ipnx-v12](https://github.com/ChristineTham/ipnx-v12), where that is the
design.

## Stream 5 — BSD furniture, and mostly the games

**Take programs, refuse personality.** No sockets, no VFS, no libc replacement. What is left
is genuinely worth having, and the games are the clearest case — pure userland, mostly
Berkeley-original, and the part of BSD with no modern substitute worth using.

`/usr/games` on the V8 golden is richer than expected
(`work/myv8/v8-inspect-name.log`): `Mail arithmetic atc back banner bcd bigp canfield
cbrogue festoon fish fortune hack hangman hanoi mille ogre ppt quiz rogomatic rogue rogue52
rogue53 sail say scapegoat snake sread thanks tictactoe tso worm zork`. Three versions of
`rogue`, plus **`rogomatic`** — the rogue-playing program. This machine was played on.

**The free win nobody would look for: V10 → V8.** `v10/games/` contains games V8 does not
have, in the same copyright estate, under the same 2017 covenant, compiled by the same
compiler: `adv` `boggle` `doctor` `morse` `pacman` `psych` `rain` `rot` `trek` `wump` `imp`
`word_clout` `crypt`/`des`. **These are not ports** — they are intra-family transfers, and
they should be the first thing Stream 3's machinery is tested on, precisely *because* they
are easy. A ports tree whose first entry is a hard port is a ports tree that never gets
debugged.

It cuts the other way too: `festoon`, `doctor`, `psych`, `word_clout`, `say`, `thanks`,
`imp`, `tso` are **Research-only** games with no BSD equivalent.

Against the NetBSD-derived `bsd-games` collection, the genuine additions:

| Candidate | Why | Difficulty |
|---|---|---|
| `robots`, `worms`, `battlestar`, `cribbage`, `monop`, `gomoku` | Self-contained curses games with no equivalent here | Low |
| `phantasia` | Multi-user persistent RPG; shared score files | Medium |
| `pom`, `number`, `caesar`, `primes`, `random` | Trivial filters, an afternoon each | Trivial |
| **`hunt`** | **Real-time multiplayer over a network** | **High — and that is the point** |

`hunt` is the one to aim at: the only game that needs the machine to be a *networked*
machine, so it lands on the N track and tests the `/dev/tcp` shim. Two ipnx instances
playing hunt over `il0` is a demonstration nothing else in this project can make.

**Provenance rule: port from 4.4BSD-Lite or its descendants, never from 4.3BSD.**
4.4BSD-Lite was constructed after the 1994 USL settlement specifically to contain no AT&T
source, and UCB dropped the advertising clause in 1999, so the modern `bsd-games` lineage is
3-clause BSD with traceable provenance.

## Stream 6 — the languages

The same reconnaissance that found `u9fs` found that most of the languages one would think
of porting are already in `cmd/`. These are **builds, not ports**:

| Asked for | Status | Where |
|---|---|---|
| **BSD Pascal** | Present and complete | `cmd/pascal/` — `pi`, `px`, `pxp`, `pc0`, `libpc`, and Berkeley's error-recovering `eyacc` |
| **Fortran** | Present, and it is *ours* | `cmd/f77/` with `libF77`/`libI77` — Stuart Feldman wrote it at Bell Labs, single-handedly |
| Others | Present | `hoc`, `icon`, `sml`, `spitbol`, `sno`, `snocone`, `matlab`, `bc`/`dc`, `ratfor`, `efl`, `pfort`, `cfront` (C++) |

**Franz Lisp is the real port on this list.** `man/mana/lisp.1` documents `lisp`, `liszt`
and `lxref` — and its title line reads `.TH LISP 1 "alice sola"`, naming *alice*, one of the
lab's machines. So Franz Lisp ran on the Research machines, but its **source is not in the
distribution** (`mana` is the local manual — software installed, not shipped). That makes it
a genuine port, and an unusually well-suited one: written at Berkeley **for the VAX**,
shipped with BSD, ran on 4.1BSD — which is precisely what V8 is derived from. Very little
else from that decade fits this hardware so exactly. **Licence is the open question**:
Berkeley origin and BSD distribution suggest BSD terms; Wikipedia describes it as
proprietary freeware. Settle it before starting.

**S is out of reach, and it is the one that stings.** Chambers, Becker and Wilks wrote it at
Bell Labs; it ran on these machines; source versions were distributed from 1981. Then Bell
Labs gave StatSci an exclusive licence in 1993, Insightful bought it, TIBCO bought Insightful
in 2008. **The 2017 covenant does not reach it** — it was never part of the Research Unix
distribution — and no free source exists. R is not the substitute it looks like: a 1993
reimplementation wanting ANSI C, a Fortran runtime and far more memory than an 11/780 has.

The honest position: S needs someone at TIBCO to say yes. That is a letter to write, not a
task to schedule — but it is worth writing, because a working S on a VAX would be a better
memorial to Chambers, Becker and Wilks than any amount of engineering elsewhere.

## What is deliberately not in V11

Recorded because an earlier draft of this document contained all of it, and because the
reasoning is the boundary between the two projects:

| Not here | Why |
|---|---|
| Per-process namespaces | V10's mount lives on `struct inode` (`i_mpoint`/`i_mroot`) in the global inode table. Making it per-process is deep surgery on `nami()` and `iget()`, and it changes the system's model of itself. |
| `rfork` | Meaningless without namespaces; its interesting flags are `RFNAMEG`/`RFCNAMEG`/`RFNOMNT`. |
| 9P as a kernel filesystem type | The `fstypsw` switch would take it cleanly, but it exists to serve namespaces. Building `u9fs` in userspace answers the interesting question at a fraction of the cost. |
| Moving drivers out of the kernel | On the VAX the drivers *are* the machine. |
| **Inferno** | Superseded, not parked. Its proposition is a portable VM (**Dis**) plus a namespace protocol (**Styx**, which in the 4th edition *is* 9P2000). [ipnx-v12](https://github.com/ChristineTham/ipnx-v12) takes that proposition and substitutes **WebAssembly for Dis**, so the VM half is replaced and the protocol half is not V11's business. Nothing to port, no licence estate to resolve. |

All of it is in [ipnx-v12](https://github.com/ChristineTham/ipnx-v12), where it is the design
rather than a retrofit.

## Ordering

```
Stream 1 (cleanout) ──► Stream 2 (ANSI) ──► Stream 3 (ports format) ──► Streams 4, 5, 6
                                    │
                                    └──► libcompat
```

- **Cleanout first**, because the ANSI conversion is priced per file and this removes 285 of
  them before the meter starts.
- **ANSI before ports**, because the port format's build rules assume one language and one
  compiler; deciding that twice is the cost paid twice.
- **`mk` before the ports format**, because the format is written in it.
- **The V10→V8 games first** inside Streams 4–6, because a ports tree whose first entry is a
  hard port never gets debugged.

## Where this sits relative to ipnx-ports

- **ipnx-ports (Track C) is the mechanism.** How anything third-party is fetched, patched,
  built and installed. Edition-agnostic.
- **ipnx-v11 (Track D) is the editorial question.** *What belongs in the edition.*

The BSD games are built by Track C and chosen by Track D. `sam` is the same. Stream 3
specifies the format Track C implements, which is the one place the two genuinely overlap —
and it is here rather than beside it because a format is an editorial act.

**V11 increments the edition**, which breaks the numbering rule the README states — "the
**edition** is Bell Labs' and is not ours to increment; the **release** counts what this
project has made of it". It is the one place that rule does not hold, and that is precisely
what marks the boundary between restoration and authorship. It is also the last time this
repository does it.

## Open questions

- Does `cmd/u9fs` build under V10's own compiler, or was it maintained on another machine?
  (`cmd/u9fs/*.o` are present — objects for *some* target.)
- Does `lcc` build, and does its output link against V10's own libc? That single fact
  decides how much post-1989 software is reachable at all.
- Is `630/bin/sam` the terminal half only, or does the 630 support tree also carry a host
  binary? (Determines whether "restore sam" starts from a working reference.)
- Which Franz Lisp licence applies, and does anyone hold authority to say so?
- Is v11 an *image* (a bootable `v11.disk`) or a *layer* over v10? The former is cleaner to
  reason about; the latter is what actually happens if ports are how things arrive.
- Does retiring `uucp` orphan anything in `/usr/lib` or `/etc` that the cleanout should take
  with it?

## Sources

- [Plan 9 copyright transferred to the Plan 9 Foundation, MIT-licensed (2021)](https://www.phoronix.com/news/Plan-9-2021)
  · [The Register's account](https://www.theregister.com/2021/03/24/bell_labs_transfers_plan9pto_foundation/)
  · [Plan 9 from User Space](https://9fans.github.io/plan9port/) — MIT, per its `LICENSE`
- [Thompson, *Plan 9 C Compilers*](https://9p.io/sys/doc/compiler.html) ·
  [Other hardware — the lost VAX compiler](https://9p.io/wiki/plan9/Other_hardware/index.html)
- [4.4BSD and the Lite releases](https://gunkies.org/wiki/4.4BSD) ·
  [bsd-games, NetBSD-derived](https://github.com/jsm28/bsd-games)
- [S: history and commercialisation](https://en.wikipedia.org/wiki/S_(programming_language))
  · [Becker, *A Brief History of S*](https://sas.uwaterloo.ca/~rwoldfor/software/R-code/historyOfS.pdf)
- [Franz Lisp](https://en.wikipedia.org/wiki/Franz_Lisp) ·
  [the 1983 manual](https://softwarepreservation.computerhistory.org/LISP/franz/Foderaro_et_al-The_FRANZ_LISP_Manual-July_1983.pdf)
- [McIlroy, *A Research Unix Reader*](https://www.cs.dartmouth.edu/~doug/reader.pdf) — the
  authority on who wrote what, and the source for the README's credits
- Primary, in this repository: `v10superset/cmd/u9fs/{README,9p.h}`,
  `v10/usr/src/cmd/{mk,pascal,f77,lcc,gcc,ccom,upas}/`, `v10/usr/src/cmd/upas/README`,
  `v10/usr/src/sys/inet/`, `v10/usr/src/ipc/libin/tcp_lib.c`, `v10/usr/man/mana/lisp.1`,
  `work/myv8/{v8-inspect-name.log,v8-libc-probe.log}`, `PATCHES.md:374`
