#!/usr/bin/env python3
"""Reconstruct a V10 source tree that is a SUPERSET of the six tapes.

    tools/v10-tree.py              # what have WE changed since the tapes?
    tools/v10-tree.py --bootstrap  # build v10/ from the tapes (ONCE)
    tools/v10-tree.py --report     # regenerate docs/v10-tree.md

v10/ IS THE WORKING COPY AND IT IS EDITED DIRECTLY.  There is no separate
patch directory and no OVERLAY file, because git already keeps that record and
keeps it honestly: every change to the tree is a commit with a message, and
what we have deviated from the tape is a diff anyone can compute rather than a
list somebody has to maintain.  The old arrangement kept our corrections in
v10/src with an OVERLAY manifest, and eleven files of pure CONFIGURATION -- a
motd, a hostname, an /etc -- sat in that directory indistinguishable from
genuine repairs for as long as nobody diffed it.

WHICH IS WHY THE DEFAULT ACTION IS A DIFF, NOT A BUILD.  Rebuilding means
deleting the tree, and the tree is now the work.  --bootstrap is deliberately
spelled out, refuses to run over an existing tree without --force, and is
expected to be used once.

WHY A SUPERSET AND NOT A TAPE.  No single archive is the Tenth Edition.  The
two /usr/src tapes overlap almost completely by path -- 13,360 of secombe's
13,390 files also exist in norman -- but they are cut from DIFFERENT MACHINES
at different times, so where they disagree one of them is simply later.  Taking
either one whole means shipping the other's staleness; merging them by rule
means shipping the best of both and being able to say which came from where.

THE RULE.  For a path only one tape has, that tape supplies it.  For a path
several tapes have:

    identical bytes   -> no contest, and the agreement is worth recording
    different bytes   -> THE NEWER MTIME WINS

Modification times survive tar, and on these archives they are the real dates:
1985 through 1995, machine by machine.  Where mtimes tie to the day, the
precedence below breaks it, and every such case is listed in the report rather
than settled quietly.

WHAT IS LEFT OUT, AND WHY EACH.  Only two things:

    history/ix      877 files.  IX is a DIFFERENT OPERATING SYSTEM -- IBM's
                    secure Unix derivative -- kept on this tape as history.  It
                    is not V10 and nothing in V10 builds from it.
    duplicate names one file.  games/sail/makefile and games/sail/Makefile are
                    ONE INODE on the tape; a case-insensitive filesystem cannot
                    name it twice, so one name is kept.  See v10tapes/HARDLINKS.

Everything else on every tape is in the tree, including trees this project does
not build from (630, blit, dregs).  A superset is a statement about what the
ARCHIVE holds; what gets built is a decision the plan makes later, and keeping
the two apart is why "the 5620's compiler is not on the tape" was believed for
as long as it was.

AN ARCHIVE IS FOUND BY ITS MAGIC, NEVER BY ITS NAME.  `!<arch>\\n' in the first
eight bytes is an ar archive whatever it is called, and on this tape the name
lies in both directions: crlib is libcurses' archive with no `.a' at all,
plot.c.a is an archive of SOURCES, and libdbm.a is `mv dbm.o libdbm.a' -- a bare
object wearing an archive's name.  Every file is sniffed.
"""

import argparse
import collections
import hashlib
import os
import shutil
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TAPES = os.path.join(ROOT, "v10tapes")
TREE = os.path.join(ROOT, "v10superset")
REPORT = os.path.join(ROOT, "docs", "v10-tree.md")

# Which tape lands where, and why it needs its own namespace or does not.
#
#   norman/secombe/sellers  ONE /usr/src namespace.  secombe is another
#       machine's copy of the same tree; sellers' man/ and vol2/ are the same
#       directories norman carries, two files and 167 files fuller.
#   milligan  root is jerq/, which no other tape has -- no prefix needed.
#   r70include  root is a.out.h, sys/, libc/, local/ -- three of which COLLIDE
#       with /usr/src.  It is /usr/include and gets its own root.
#   blit  root is doc/, include/, lib/, src/ -- doc collides.  A different
#       terminal besides, so its own root says so.
LAYOUT = [("norman", ""), ("secombe", ""), ("sellers", ""),
          ("milligan", ""), ("r70include", "include"), ("blit", "blit")]

# SECOMBE IS THE BASE, NORMAN AUGMENTS IT.  This decides which tape is
# CREDITED when several carry a path with identical bytes, and which wins the
# rare case of different bytes under the same mtime.
#
# THE EVIDENCE IS THE CONTESTED PATHS THEMSELVES.  Where the two /usr/src tapes
# disagree, secombe is almost always the later cut -- its files date 1993-1995
# against norman's 1988-1993 -- so secombe is a NEWER SNAPSHOT of the same
# tree.  What norman has is REACH, not currency: 10,612 paths secombe does not
# carry at all.  So the tree is secombe brought up to full extent by norman,
# not norman with secombe's corrections dropped in.
PRECEDENCE = ["secombe", "norman", "sellers", "milligan", "r70include", "blit"]

EXCLUDE = [("norman", "history/ix",
            "IX is a different operating system (IBM's secure Unix), kept "
            "here as history; nothing in V10 builds from it")]

AR_MAGIC = b"!<arch>\n"


def walk(root):
    """Every regular file under root, relative, symlinks recorded not followed."""
    out = {}
    for dp, dn, fn in os.walk(root):
        for name in fn:
            p = os.path.join(dp, name)
            rel = os.path.relpath(p, root)
            out[rel] = p
    return out


def digest(path):
    """A content hash, and for a symlink the hash of its TARGET STRING.

    cmd/map/export/mapdata points at /usr/maps, which the host does not have,
    so opening it raises and stat'ing it raises -- a broken symlink is still a
    file the tape carries, and its content IS the path it names.
    """
    if os.path.islink(path):
        return hashlib.sha256(os.readlink(path).encode()).hexdigest()
    try:
        with open(path, "rb") as f:
            return hashlib.sha256(f.read()).hexdigest()
    except OSError:
        return None


def excluded(tape, rel):
    for t, prefix, _why in EXCLUDE:
        if tape == t and (rel == prefix or rel.startswith(prefix + "/")):
            return True
    return False


# ======================================================== 1. the selection ===
def select():
    """path -> (winning tape, source file, contenders, why)."""
    dropped = set()
    hl = os.path.join(TAPES, "HARDLINKS")
    if os.path.exists(hl):
        for line in open(hl):
            if line.startswith("#"):
                continue
            f = line.rstrip("\n").split("\t")
            if len(f) == 4:
                dropped.add((f[0], os.path.join(f[1], f[3]) if f[1] != "." else f[3]))

    # THE CONTEST IS ON TAPE PATHS, NOT DISK PATHS.  tools/v10-tapes.sh renames
    # a case loser to u_<name> WITHIN ITS OWN TAPE, so secombe's ipc/bin/Con is
    # on disk as ipc/bin/u_Con while norman -- which had no collision there --
    # still has ipc/bin/Con.  Comparing disk paths makes those two look like
    # different files when they are one file on two tapes, and the merge then
    # renames norman's copy to u_Con and lands on top of secombe's.  CASEMAP
    # says what each file is called on the tape; the contest uses that, and the
    # case rule is applied ONCE, afterwards.
    untranslate = {}
    cm = os.path.join(TAPES, "CASEMAP")
    if os.path.exists(cm):
        for line in open(cm):
            if line.startswith("#"):
                continue
            t, was, now = line.rstrip("\n").split("\t")
            untranslate[(t, now)] = was

    offers = collections.defaultdict(list)   # dest path -> [(tape, src, mtime, hash)]
    skipped = collections.Counter()
    for tape, prefix in LAYOUT:
        root = os.path.join(TAPES, tape)
        if not os.path.isdir(root):
            sys.exit("v10-tree: no %s -- run tools/v10-tapes.sh" % root)
        for rel, src in walk(root).items():
            if excluded(tape, rel):
                skipped[tape] += 1
                continue
            if (tape, rel) in dropped:
                skipped[tape] += 1
                continue
            rel = untranslate.get((tape, rel), rel)
            dest = os.path.join(prefix, rel) if prefix else rel
            # lstat, NOT stat: a broken symlink has no target to stat.
            offers[dest].append((tape, src, int(os.lstat(src).st_mtime),
                                 digest(src)))

    chosen, contested, ties = {}, [], []
    for dest, cands in offers.items():
        if len(cands) == 1:
            tape, src, _mt, _h = cands[0]
            chosen[dest] = (tape, src, "only tape with this path")
            continue
        hashes = {c[3] for c in cands}
        if len(hashes) == 1:
            # THE TAPES AGREE.  Worth counting: it is the reason a difference
            # elsewhere is evidence rather than noise.
            tape, src, _mt, _h = sorted(cands, key=lambda c: PRECEDENCE.index(c[0]))[0]
            chosen[dest] = (tape, src, "identical on %d tapes"
                            % len(cands))
            continue
        newest = max(c[2] for c in cands)
        best = [c for c in cands if c[2] == newest]
        if len(best) > 1:
            best = [sorted(best, key=lambda c: PRECEDENCE.index(c[0]))[0]]
            ties.append((dest, [c[0] for c in cands]))
            why = "same mtime on %s -- precedence" % ",".join(
                sorted(c[0] for c in cands))
        else:
            why = "newer (%s)" % _when(newest)
        tape, src, _mt, _h = best[0]
        chosen[dest] = (tape, src, why)
        contested.append((dest, tape, [(c[0], c[2]) for c in cands]))
    # ------------------------------------- collisions the MERGE creates ---
    # Two tapes can each be unambiguous and still collide once merged:
    # secombe has ipc/bin/Con, norman has ipc/bin/con, and neither tree has a
    # problem until both are written into one.  On a case-insensitive
    # filesystem the second copy lands in the first one's slot and the first
    # is simply gone -- fifteen files, silently, with no error anywhere.
    #
    # RULE 0: THE SURVIVOR IS WHATEVER THE DIRECTORY'S OWN BUILD FILE NAMES.
    # All-lowercase-wins is the default and is right for almost every collision,
    # but it is wrong wherever the build reads the capitalised spelling -- and
    # then it renames the one file that had to keep its name, after which a
    # block in build/patch has to undo it on the machine, at build time.
    # v10/usr/src/build/casenames carries the whole decision; these four are the
    # cases where it overrides the default, and the evidence is on each line.
    CAPWINS = {
        # olibcmkfile:123 is `doprnt.o: stdio/doprnt.S'
        ("libc/stdio/ostdio",     "doprnt.s"): "doprnt.S",
        # makefile names String.h at :11,14,17,23,26,50,53 and string.h never
        ("cmd/cfront/libstring",  "string.h"): "String.h",
        # makefile:113 is `hash.o: hash.c hash.H'
        ("cmd/cfront/ooptcfront", "hash.h"):   "hash.H",
        # makefile:12-13 build qsnap from Qsnap.c
        ("cmd/qsnap",             "qsnap.c"):  "Qsnap.c",
    }
    # Otherwise the extractor's rule: the all-lowercase spelling keeps the name,
    # the others take `u_' in front of their own.
    kids = collections.defaultdict(set)
    for dest in chosen:
        parts = dest.split("/")
        for i, comp in enumerate(parts):
            kids["/".join(parts[:i])].add(comp)
    ren = {}
    for parent, names in kids.items():
        g = collections.defaultdict(list)
        for n in names:
            g[n.lower()].append(n)
        for _low, spellings in g.items():
            if len(spellings) < 2:
                continue
            over = CAPWINS.get((parent, _low))
            if over and over in spellings:
                keep = over
            else:
                lower = [n for n in spellings if n == n.lower()]
                keep = lower[0] if lower else sorted(spellings)[0]
            for n in sorted(spellings):
                if n != keep:
                    ren[(parent, n)] = "u_" + n
    if ren:
        # A RENAME THAT LANDS ON AN EXISTING KEY DROPS AN ENTRY, and a dict
        # does it as silently as the filesystem does -- the same fault one
        # level up from the collision this block exists to fix.  So the rebuild
        # is checked, not assumed: a lost destination is a file that would
        # never appear in the tree and never be reported missing.
        moved = {}
        lost = []
        for dest, v in chosen.items():
            parts, out = dest.split("/"), []
            for i, comp in enumerate(parts):
                out.append(ren.get(("/".join(parts[:i]), comp), comp))
            nd = "/".join(out)
            if nd in moved:
                lost.append((dest, nd, moved[nd][0], v[0]))
            moved[nd] = v
        if lost:
            print("v10-tree: %d destinations collided AFTER renaming:" % len(lost))
            for dest, nd, had, now in lost[:20]:
                print("   %s -> %s (%s displaced by %s)" % (dest, nd, had, now))
            sys.exit(1)
        chosen = moved

    return chosen, contested, ties, skipped, len(ren)


def _when(ts):
    import time
    return time.strftime("%Y-%m-%d", time.gmtime(ts))


# ========================================================== 2. the archives ===
def unpack_archives(tree):
    """Unpack every ar archive found BY MAGIC, keeping member order in ORDER.

    THE HOST'S ar IS NOT USED, and that is the whole point.  macOS's ar exits
    ZERO having extracted nothing from the WE32100 archives under 630/, so
    630/lib/libc.a became an empty directory and sixty members were simply
    gone -- no error, no non-zero status, and a count nobody was comparing.
    The headers are already being read here to build ORDER, so the bytes come
    out the same way and every ar variant on these tapes is handled by the
    same forty lines.

    Unpacking is what makes the sources inside an archive visible to a build,
    and it is also what destroys the one thing a directory cannot hold: the
    ORDER of the members.  V10's ld makes ONE sequential pass when __.SYMDEF is
    absent or stale, so libc.a has to be rebuilt in the tape's own order or
    backward references go unresolved.  ORDER is written beside the members.
    """
    found = unpacked = failed = 0
    log = []
    for dp, _dn, fn in list(os.walk(tree)):
        for name in sorted(fn):
            p = os.path.join(dp, name)
            if os.path.islink(p):
                continue
            try:
                with open(p, "rb") as f:
                    if f.read(8) != AR_MAGIC:
                        continue
                    f.seek(0)
                    data = f.read()
            except OSError:
                continue
            found += 1
            rel = os.path.relpath(p, tree)
            members = ar_members(data)
            if not members:
                failed += 1
                log.append((rel, 0, "no members could be read"))
                continue
            # A CASE COLLISION HAPPENS INSIDE AN ARCHIVE TOO: cmd/awk/test.a
            # holds T.getline AND t.getline, and one slot cannot take both.
            # The same rule as everywhere else -- lowercase keeps, the others
            # take u_ -- so no member is lost to the filesystem.
            seen, final = {}, []
            for mname, body in members:
                low = mname.lower()
                if low in seen and seen[low] != mname:
                    final.append(("u_" + mname, body))
                else:
                    seen[low] = mname
                    final.append((mname, body))
            tmp = p + ".unpack"
            shutil.rmtree(tmp, ignore_errors=True)
            os.makedirs(tmp)
            for mname, body in final:
                with open(os.path.join(tmp, mname), "wb") as f:
                    f.write(body)
            # ASSERT THE RESULT.  An archive that unpacked to nothing is the
            # fault this function exists to stop reporting as success.
            got = set(os.listdir(tmp))
            want = {m for m, _b in final}
            if got != want:
                shutil.rmtree(tmp, ignore_errors=True)
                failed += 1
                log.append((rel, len(final),
                            "wrote %d of %d members" % (len(got), len(want))))
                continue
            os.remove(p)
            os.rename(tmp, p)
            with open(os.path.join(p, "ORDER"), "w") as f:
                for mname, _b in final:
                    f.write(mname + "\n")
            unpacked += 1
            log.append((rel, len(final), "unpacked"))
    return found, unpacked, failed, log


def ar_members(data):
    """(name, bytes) for every member, in archive order, BSD and SysV alike.

    The tapes carry both.  A VAX archive is BSD: long names inline, the symbol
    table called __.SYMDEF.  The WE32100 archives under 630/ are System V:
    the symbol table is a member called `/', long names live in a `//' string
    table, and a member whose name is `/<offset>' points into it.  Reading
    only the BSD form gave those archives a member with an EMPTY NAME and lost
    the rest.
    """
    out, i = [], 8
    strtab = b""
    while i + 60 <= len(data):
        hdr = data[i:i + 60]
        raw = hdr[0:16].decode("latin-1")
        try:
            size = int(hdr[48:58].decode("latin-1").strip())
        except ValueError:
            break
        i += 60
        name = raw.rstrip()
        if name == "//":                      # SysV long-name string table
            strtab = data[i:i + size]
            i += size + (size & 1)
            continue
        if name in ("/", "__.SYMDEF", "__.SYMDEF SORTED"):
            i += size + (size & 1)
            continue
        if name.startswith("#1/"):            # BSD long name, inline
            n = int(name[3:])
            name = data[i:i + n].decode("latin-1").rstrip("\0")
            i += n
            size -= n
        elif name.startswith("/") and name[1:].strip().isdigit():
            off = int(name[1:].strip())       # SysV long name, in the table
            end = strtab.find(b"/\n", off)
            if end < 0:
                end = strtab.find(b"\n", off)
            name = strtab[off:end].decode("latin-1") if end > 0 else name
        name = name.rstrip("/").strip()
        if name:
            out.append((name, data[i:i + size]))
        i += size + (size & 1)
    return out


# ============================================================ 3. the report ===
def write_report(chosen, contested, ties, arc):
    found, unpacked, failed, log = arc
    per = collections.Counter(t for t, _s, _w in chosen.values())
    why = collections.Counter(w.split(" (")[0].split(" --")[0]
                              for _t, _s, w in chosen.values())
    lines = []
    A = lines.append
    A("# The reconstructed V10 source tree")
    A("")
    A("`v10` is a **superset** of the six tapes, built by "
      "`tools/v10-tree.py` from the pristine extracts in `v10tapes/`. "
      "This file is generated; it is the provenance record.")
    A("")
    A("## Where every file came from")
    A("")
    A("| tape | files in the tree | what it is |")
    A("|---|---|---|")
    WHAT = {
        "norman": "`/usr/src`. The larger source tape and the base of the tree.",
        "secombe": "`/usr/src` from a **different machine**. Only 30 paths are "
                   "its own; its value is that it is newer where it differs.",
        "sellers": "`/usr/man` and `vol2`. The documentation, two files fuller "
                   "than norman's `man` and 167 fuller in `vol2`.",
        "milligan": "`/usr/jerq`. The 5620 distribution.",
        "r70include": "`/usr/include`, r70's reconstruction. Its own root: "
                      "`sys`, `libc` and `local` all collide with `/usr/src`.",
        "blit": "The 68000 Blit. Its own root: `doc` collides, and it is a "
                "different terminal from the 5620 this project emulates.",
    }
    for tape, _p in LAYOUT:
        A("| `%s` | %d | %s |" % (tape, per.get(tape, 0), WHAT[tape]))
    A("| **total** | **%d** | |" % len(chosen))
    A("")
    A("## How each file was chosen")
    A("")
    A("| reason | files |")
    A("|---|---|")
    for k, v in why.most_common():
        A("| %s | %d |" % (k, v))
    A("")
    A("A path carried by one tape alone is taken from it. Where several tapes "
      "carry it and the bytes agree, there is no contest — that agreement "
      "covers most of the overlap and is what makes a *disagreement* evidence "
      "rather than noise. Where the bytes differ, **the newer mtime wins**.")
    A("")
    A("## The contested paths")
    A("")
    A("%d paths differ between tapes. Every one is listed here with the date "
      "of each contender, so the choice can be checked rather than trusted."
      % len(contested))
    A("")
    if contested:
        A("| path | taken from | contenders |")
        A("|---|---|---|")
        for dest, winner, cands in sorted(contested)[:400]:
            c = ", ".join("%s %s" % (t, _when(m)) for t, m in
                          sorted(cands, key=lambda x: -x[1]))
            A("| `%s` | **%s** | %s |" % (dest, winner, c))
        if len(contested) > 400:
            A("")
            A("*(%d more, same rule.)*" % (len(contested) - 400))
    A("")
    if ties:
        A("### Ties broken by precedence")
        A("")
        A("%d paths differ but share an mtime to the second, so the date "
          "cannot choose. Precedence is `%s`."
          % (len(ties), " > ".join(PRECEDENCE)))
        A("")
        for dest, cands in sorted(ties)[:60]:
            A("- `%s` — %s" % (dest, ", ".join(sorted(cands))))
        A("")
    A("## What was left out")
    A("")
    A("| what | files | why |")
    A("|---|---|---|")
    for t, prefix, w in EXCLUDE:
        A("| `%s/%s` | %d | %s |" % (t, prefix, 877, w))
    A("| duplicate names | 1 | one inode under two spellings; see "
      "`v10tapes/HARDLINKS` |")
    A("")
    A("Nothing else is excluded. Trees this project does not build from — "
      "`630`, `blit`, `dregs` — are still in the tree, because a superset is "
      "a statement about what the archive holds and what gets *built* is a "
      "decision the plan makes later.")
    A("")
    A("## The archives, found by magic")
    A("")
    A("%d files begin with `!<arch>\\n` and are ar archives whatever they are "
      "called; %d were unpacked into directories of the same name, each with "
      "an `ORDER` file recording the member order. %d could not be read."
      % (found, unpacked, failed))
    A("")
    A("The name lies in both directions on this tape, which is why the magic "
      "number is the test: `crlib` is libcurses' archive with no `.a` at all, "
      "`plot.c.a` is an archive of **sources**, and `libdbm.a` is `mv dbm.o "
      "libdbm.a` — a bare object wearing an archive's name.")
    A("")
    A("`ORDER` matters because V10's `ld` makes one sequential pass when "
      "`__.SYMDEF` is absent or stale, so an archive rebuilt in the wrong "
      "order leaves backward references unresolved. Unpacking keeps every "
      "byte and destroys the one thing a directory cannot hold.")
    A("")
    if failed:
        A("### Archives that could not be unpacked")
        A("")
        for rel, n, note in log:
            if note != "unpacked":
                A("- `%s` (%d members) — %s" % (rel, n, note))
        A("")
    os.makedirs(os.path.dirname(REPORT), exist_ok=True)
    open(REPORT, "w").write("\n".join(lines) + "\n")


# =================================================================== main ===
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bootstrap", action="store_true",
                    help="build v10/ from the tapes -- DESTROYS the tree")
    ap.add_argument("--force", action="store_true",
                    help="allow --bootstrap over an existing tree")
    ap.add_argument("--report", action="store_true",
                    help="regenerate docs/v10-tree.md")
    args = ap.parse_args()

    chosen, contested, ties, skipped, merge_ren = select()

    if args.bootstrap:
        # THE TREE IS THE WORK NOW.  A rebuild deletes it, so it cannot be the
        # default and it cannot be quiet.  This guard exists because the line
        # below is one `shutil.rmtree' away from every edit we have made.
        if os.path.isdir(TREE) and os.listdir(TREE) and not args.force:
            print("v10-tree: %s already exists -- bootstrapping would DELETE it."
                  % os.path.relpath(TREE, ROOT))
            print("          v10/ is the working copy; run without arguments to")
            print("          see how it differs from the tapes, or pass --force")
            print("          if you really mean to throw the tree away.")
            sys.exit(1)
        print("== building %s ==" % TREE)
        shutil.rmtree(TREE, ignore_errors=True)
        for dest, (_tape, src, _why) in chosen.items():
            d = os.path.join(TREE, dest)
            os.makedirs(os.path.dirname(d), exist_ok=True)
            # A SYMLINK IS RECREATED, NOT RESOLVED.  copy2 would follow it and
            # fail on a target the host has never had (/usr/maps), and where
            # the target does exist it would silently turn one file into two.
            if os.path.islink(src):
                os.symlink(os.readlink(src), d)
            else:
                shutil.copy2(src, d)
        print("   %d files, %d renamed with u_ for merge collisions"
          % (len(chosen), merge_ren))
        print("== archives, by magic ==")
        arc = unpack_archives(TREE)
        print("   %d found, %d unpacked, %d could not be read" % arc[:3])
        write_report(chosen, contested, ties, arc)
        per = collections.Counter(t for t, _s, _w in chosen.values())
        for tape, _p in LAYOUT:
            print("   %-11s %6d files" % (tape, per.get(tape, 0)))
        return

    if args.report:
        write_report(chosen, contested, ties, (0, 0, 0, []))
        print("report -> %s" % os.path.relpath(REPORT, ROOT))
        return

    # ------------------------------------------------- what have WE changed ---
    # Against the tape SELECTION, not against one tape: a file we have not
    # touched should be byte-identical to whichever tape supplied it, and the
    # archives we unpacked are directories now, so they are compared member by
    # member rather than as files.
    ours = walk(TREE)
    added, changed, removed = [], [], []
    for dest, (tape, src, _why) in chosen.items():
        have = ours.pop(dest, None)
        if have is None:
            # An unpacked archive: the file is a directory of members now.
            if os.path.isdir(os.path.join(TREE, dest)):
                continue
            removed.append((dest, tape))
        elif digest(have) != digest(src):
            changed.append((dest, tape))
    for dest in ours:
        # Members of unpacked archives, and ORDER files, are not deviations.
        parts = dest.split(os.sep)
        if any(os.path.isdir(os.path.join(TREE, *parts[:i + 1]))
               and os.path.exists(os.path.join(TREE, *parts[:i + 1], "ORDER"))
               for i in range(len(parts) - 1)):
            continue
        added.append(dest)

    print("== v10/ against the tapes ==")
    print("   %d files in the tree" % (len(chosen)))
    print("   changed by us  %d" % len(changed))
    print("   added by us    %d" % len(added))
    print("   removed by us  %d" % len(removed))
    for label, rows in (("CHANGED", [d for d, _t in sorted(changed)]),
                        ("ADDED", sorted(added)),
                        ("REMOVED", [d for d, _t in sorted(removed)])):
        for d in rows[:40]:
            print("   %-8s %s" % (label, d))
        if len(rows) > 40:
            print("   %-8s ... and %d more" % (label, len(rows) - 40))


if __name__ == "__main__":
    main()
