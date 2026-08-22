#!/usr/bin/env python3
"""Build v10/ -- a real Tenth Edition FILESYSTEM -- from v10superset/.

    tools/v10-dist.py            # build v10/, write docs/v10-dist.md
    tools/v10-dist.py --dry      # say what would be copied, copy nothing

THE DIFFERENCE BETWEEN THE TWO TREES, WHICH IS THE WHOLE POINT.

    v10superset/  a CORPUS.  Everything six tapes hold, merged by rule, in
                  whatever shape the tapes happened to be cut.  Its roots are
                  tape roots -- `cmd', `man', `jerq', `630' side by side --
                  and no Tenth Edition machine ever looked like that.
    v10/          a FILESYSTEM.  What the running machine sees: /usr/src/cmd,
                  /usr/man, /usr/include.  The layout mirrors the guest, the
                  same rule v8/ follows, so v10/usr/src/cmd/ls.c is what the
                  machine has at /usr/src/cmd/ls.c.

WHERE EACH TREE GOES IS READ OFF THE TAPE, NOT INFERRED FROM ITS NAME.  Two
kinds of evidence, and only these:

    1  A FILE THAT NAMES ITS OWN PATH.  cmd/Admin/dest opens `DIR=
       /usr/src/cmd/Admin', which settles cmd and with it the root of the two
       /usr/src tapes.  cmd/map/export/mapdata is a symlink to /usr/maps.
       jerq's sources name /usr/jerq/include 196 times; 630's name /usr/630.

    2  srctotape, THE TAPE'S OWN MANIFEST OF /usr/src.  A plain list of the
       directories whoever cut the tape considered to be the source tree.

WHAT COUNTING REFERENCES CANNOT SETTLE, and why it is not used for the source
directories: `/usr/games/hack' is where hack is INSTALLED while its source is
/usr/src/games/hack, so both strings appear all over the tape and the installed
one wins on volume.  The count is good evidence for a self-contained tree that
refers to itself and misleading for anything that gets built and installed
somewhere else.

ANYTHING NOT SETTLED BY THAT EVIDENCE STAYS IN v10superset.  Leaving a tree
behind costs nothing -- the superset is committed and complete, and a directory
can be promoted later in one line once its home is known.  Guessing costs the
thing this rebuild was for: a tree whose shape is a claim about V10 rather than
a record of it.  Every omission is listed with its reason in docs/v10-dist.md.
"""

import argparse
import collections
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SUPER = os.path.join(ROOT, "v10superset")
DIST = os.path.join(ROOT, "v10")
REPORT = os.path.join(ROOT, "docs", "v10-dist.md")

# The tape's own manifest of /usr/src, read at build time rather than copied
# here, so a re-cut tape that lists something new is followed automatically.
SRCTOTAPE = "srctotape"

# tree -> (destination, the evidence for it)
PLACED = {
    "man":     ("usr/man",
                "roff manual pages -- man/man1/ls.1 opens `.TH LS 1'; cmd/man "
                "reads /usr/man/man0/secindex"),
    "sys":     ("usr/sys",
                "the kernel tree; 124 references to /usr/sys, and v8 keeps its "
                "kernel at the same place"),
    "include": ("usr/include",
                "r70's reconstruction of /usr/include, its own tape; 731 "
                "references"),
    "jerq":    ("usr/jerq",
                "the 5620 distribution, its own tape; its sources name "
                "/usr/jerq/include 196 times and /usr/jerq/bin 95"),
    "630":     ("usr/630",
                "the WE32100 cross-tools; 57 references to /usr/630/bin, "
                "/usr/630/lib and /usr/630/mbin"),
    "local":   ("usr/local",
                "270 references to /usr/local, none to /usr/src/local"),
    "vol2":    ("usr/vol2",
                "40 SELF-references: vol2/index/tools/gettop opens "
                "`M=/usr/vol2/index/tools' and sits at vol2/index/tools/gettop; "
                "vol2/ADM/mkfile does `cd /usr/vol2'"),
    "dk":      ("usr/src/dk",
                "Datakit source, and v8 keeps its own at /usr/src/dk. The "
                "/usr/dk strings in it are RUNTIME paths -- "
                "`char *logfile = \"/usr/dk/LOGPROC\"' -- not the tree's home"),
    "netfs":   ("usr/src/netfs",
                "v8 keeps its own at /usr/src/netfs"),
    "maps":    ("usr/maps",
                "cmd/map/export/mapdata is a SYMLINK to /usr/maps -- the tape "
                "naming the path itself"),
}

# tree -> why it is not in the distribution
LEFT = {
    "blit":       "the 68000 Blit. Its own files name /usr/blit 228 times, so "
                  "the PATH is not in doubt -- what is in doubt is whether a "
                  "Tenth Edition machine carried it at all. It is a different "
                  "terminal from the 5620 this project emulates, and the tape "
                  "came bundled with V8-era material. Placement evidence is "
                  "not shipping evidence.",
    "lsys":       "`local sys' -- one machine's kernel tree, and it names "
                  "itself nowhere. sys/ is the vanilla one: 1,134 files "
                  "against lsys's 922, newer on 111 of 266 differing files "
                  "against 8, and more 780 support (52 `star' paths to 35).",
    "ncurses":    "a curses library beside the libcurses that IS in srctotape. "
                  "Not in srctotape, not in v8's source tree, and it names "
                  "itself nowhere.",
    "libpicfile": "not in srctotape, not in v8's source tree, and it names "
                  "itself nowhere -- despite the lib* spelling of its "
                  "siblings.",
    "history":    "five loose files left after history/ix was excluded; they "
                  "name themselves nowhere.",
    "dist":       "a distribution working directory, naming itself nowhere.",
    "dregs":      "the name is the tape's own verdict on it.",
    "nbstests":   "a test corpus, naming itself nowhere.",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry", action="store_true")
    args = ap.parse_args()

    if not os.path.isdir(SUPER):
        sys.exit("v10-dist: no %s" % SUPER)

    tops = sorted(d for d in os.listdir(SUPER)
                  if os.path.isdir(os.path.join(SUPER, d)))
    loose = sorted(f for f in os.listdir(SUPER)
                   if os.path.isfile(os.path.join(SUPER, f)))

    srcdirs = []
    st = os.path.join(SUPER, SRCTOTAPE)
    if os.path.exists(st):
        srcdirs = [l.strip() for l in open(st) if l.strip()]
    srcdirs = [d for d in srcdirs if d in tops]

    plan = {}
    for d in srcdirs:
        plan[d] = ("usr/src/" + d, "named in srctotape, the tape's own "
                                   "manifest of /usr/src")
    for d, (dest, why) in PLACED.items():
        if d in tops:
            plan[d] = (dest, why)

    # NOTHING MAY BE SILENTLY FORGOTTEN.  Every directory is either placed or
    # left behind WITH A REASON; a tree that is in neither list is a tree
    # somebody stopped thinking about, and it would disappear without a word.
    unaccounted = [d for d in tops if d not in plan and d not in LEFT]
    if unaccounted:
        print("v10-dist: %d directories are neither placed nor explained:"
              % len(unaccounted))
        for d in unaccounted:
            print("   %s" % d)
        print("Add each to PLACED with its evidence, or to LEFT with a reason.")
        sys.exit(1)

    n_files = collections.Counter()
    if not args.dry:
        shutil.rmtree(DIST, ignore_errors=True)
    for d, (dest, _why) in sorted(plan.items()):
        src = os.path.join(SUPER, d)
        dst = os.path.join(DIST, dest)
        n = sum(len(f) for _dp, _dn, f in os.walk(src))
        n_files[d] = n
        if not args.dry:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copytree(src, dst, symlinks=True)

    total = sum(n_files.values())
    left_total = 0
    for d in LEFT:
        if d in tops:
            left_total += sum(len(f) for _dp, _dn, f in os.walk(os.path.join(SUPER, d)))

    print("== v10, a filesystem ==")
    for d, (dest, _w) in sorted(plan.items(), key=lambda x: x[1][0]):
        print("   %-28s <- %-12s %6d files" % (dest, d, n_files[d]))
    print("   %d files placed" % total)
    print("== left in v10superset ==")
    for d in sorted(LEFT):
        if d in tops:
            print("   %-12s %s" % (d, LEFT[d].split(".")[0]))
    print("   %d files left behind" % left_total)
    if loose:
        print("== loose files at the superset root, not placed ==")
        print("   %s" % " ".join(loose))

    write_report(plan, n_files, total, left_total, tops, loose)
    print("   report -> %s" % os.path.relpath(REPORT, ROOT))


def write_report(plan, n_files, total, left_total, tops, loose):
    L = []
    A = L.append
    A("# v10 — the Tenth Edition as a filesystem")
    A("")
    A("`v10/` is what a running machine sees: `/usr/src/cmd`, `/usr/man`, "
      "`/usr/include`. `v10superset/` is the corpus it was drawn from — "
      "everything six tapes hold, in whatever shape the tapes were cut. This "
      "file is generated by `tools/v10-dist.py`.")
    A("")
    A("The layout mirrors the guest filesystem, the same rule `v8/` follows, "
      "so `v10/usr/src/cmd/ls.c` is what the machine has at "
      "`/usr/src/cmd/ls.c`.")
    A("")
    A("## What was placed, and on what evidence")
    A("")
    A("| destination | from | files | evidence |")
    A("|---|---|---|---|")
    for d, (dest, why) in sorted(plan.items(), key=lambda x: x[1][0]):
        A("| `%s` | `%s` | %d | %s |" % (dest, d, n_files[d], why))
    A("| **total** | | **%d** | |" % total)
    A("")
    A("Two kinds of evidence were allowed, and only these:")
    A("")
    A("1. **A file that names its own path.** `cmd/Admin/dest` opens "
      "`DIR=/usr/src/cmd/Admin`, which settles `cmd` and with it the root of "
      "both `/usr/src` tapes. `cmd/map/export/mapdata` is a symlink to "
      "`/usr/maps`. jerq's sources name `/usr/jerq/include` 196 times.")
    A("2. **`srctotape`**, the tape's own manifest of `/usr/src` — a plain "
      "list of the directories whoever cut the tape considered to be the "
      "source tree.")
    A("")
    A("**Counting references was deliberately not used for source "
      "directories.** `/usr/games/hack` is where hack is *installed* while "
      "its source is `/usr/src/games/hack`, so both strings appear all over "
      "the tape and the installed one wins on volume. The count is good "
      "evidence for a self-contained tree that refers to itself, and "
      "misleading for anything built and installed elsewhere.")
    A("")
    A("## What was left in `v10superset`, and why")
    A("")
    A("| tree | why |")
    A("|---|---|")
    for d in sorted(LEFT):
        if d in tops:
            A("| `%s` | %s |" % (d, LEFT[d]))
    A("")
    A("%d files. Leaving a tree behind costs nothing — the superset is "
      "committed and validated, and a directory can be promoted in one line "
      "once its home is known. Guessing costs the thing this rebuild was for: "
      "a tree whose shape is a claim about V10 rather than a record of it."
      % left_total)
    A("")
    if loose:
        A("Loose files at the superset root, not placed: %s."
          % ", ".join("`%s`" % f for f in loose))
        A("")
    A("## What is missing")
    A("")
    A("Everything a running system has that no tape carries: `/bin`, `/etc`, "
      "`/dev`, `/lib`, `/usr/lib`, `/usr/bin`, `/usr/games` as *installed* "
      "binaries. Those are what the build produces; this tree is its input.")
    os.makedirs(os.path.dirname(REPORT), exist_ok=True)
    open(REPORT, "w").write("\n".join(L) + "\n")


if __name__ == "__main__":
    main()
