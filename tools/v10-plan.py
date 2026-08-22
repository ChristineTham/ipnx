#!/usr/bin/env python3
"""The file-by-file plan: every path on the golden, and how it gets there.

	tools/v10-plan.py [--check]

Writes two files from one computation:

	docs/v10-plan.md        the plan, to read
	v10/mk/gen/plan.txt     the same rows, tab-separated, for the build

One row per destination path:

	path <TAB> stage <TAB> method <TAB> source <TAB> list

WHY GENERATED.  A plan written by hand goes stale the first time a unit starts
building, and a plan quoted from memory is how this project put ix binaries and
an Eighth Edition fstab on a Tenth Edition disk.  Every row here comes from a
list in v10/mk/gen that some other generator produced from the tape.

METHODS, AND THE DISTINCTION THAT MATTERS:

	build    compiled from source by the stage named, installed by its
	         makefile's `install:' target into $(DESTDIR) -- the new image.
	copy     the tape ships it and nothing can build it; copied from the
	         netfs share.
	mknod    a device node, from the generated table.
	config   content lives in v10/src/etc.
	tree     a whole directory copied from the tape.

There is no `inherit'.  If a row cannot name a source it is a defect in the
plan, not a file to scavenge off the builder.
"""

import argparse
import collections
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(ROOT, "v10", "mk", "gen")


def rows(name, ncol=None):
    """Data rows of a generated list, split on tabs, comments dropped."""
    p = os.path.join(GEN, name)
    if not os.path.exists(p):
        return []
    out = []
    for line in open(p, errors="replace"):
        line = line.split("#")[0].rstrip("\n")
        if not line.strip():
            continue
        f = line.split("\t") if "\t" in line else line.split()
        if ncol and len(f) < ncol:
            continue
        out.append(f)
    return out


def norm(d, name=None):
    """`usr/bin/yacc' or `/usr/bin' + name -> an absolute path."""
    d = d.strip()
    if name is not None:
        d = d.rstrip("/") + "/" + name
    return "/" + d.lstrip("/")


def build():
    plan = {}          # path -> (stage, method, source, list)

    def put(path, stage, method, source, lst):
        # FIRST WRITER WINS, and a collision is reported rather than resolved:
        # two lists claiming one path is a question for whoever wrote them.
        if path in plan:
            plan[path][4].append("%s:%s" % (lst, source))
            return
        plan[path] = [stage, method, source, lst, []]

    # -- stage 1: the toolchain, and the tools stages 2/3 and a disk build need
    for lst, stage in (("tc.order", "1 toolchain"),
                       ("buildtools.ord", "1 buildtools"),
                       ("shutdown.order", "1 shutdown")):
        for f in rows(lst, 3):
            put(norm(f[2]), stage, "build", "%s/%s" % (f[1], f[0]), lst)

    # -- stage 2: libc.  260 members become two installed files.
    n = len(rows("libc.ord", 1))
    put("/lib/libc.a", "2 libc", "build",
        "libc/mkfile, %d members in the tape's order" % n, "libc.ord")
    put("/lib/crt0.o", "2 libc", "build", "libc/csu", "libc.mk")

    # -- stage 4: the libraries
    for f in rows("libs.txt", 4):
        put("/usr/lib/" + f[3], "4 libraries", "build",
            "%s (%s members)" % (f[1], f[4] if len(f) > 4 else "?"), "libs.txt")

    # -- stage 5: the kernel
    put("/unix", "5 kernel", "build", "lsys, ipnx780.m", "kobj.order")

    # -- stage 6: the world.  world.link is name/dir/authority/-; world.prog
    #    names the programs inside multi-main units; aliases are second names.
    for f in rows("world.link", 2):
        put(norm(f[1], f[0]), "6 world", "build", "cmd/%s" % f[0], "world.link")
    # world.prog is `name unit unitdir dest libs objects...' -- the
    # destination is the FOURTH field.  Using the third gives paths like
    # /../games/atc/atc, because the third is the unit's directory relative
    # to cmd/.
    for f in rows("world.prog", 4):
        put(norm(f[3], f[0]), "6 world", "build",
            "%s (%s)" % (f[2], f[1]), "world.prog")
    # `name dir unitdir src' -- a shell script, copied rather than compiled.
    for f in rows("world.script", 4):
        put(norm(f[1], f[0]), "6 world", "copy", "cmd/%s/%s" % (f[2], f[3]),
            "world.script")
    # `alias dir target' -- a hard link, which is how the tape itself does it:
    # V8's nlink>1 shows edit=ex=vi=view is ONE inode with four names, so
    # building ex closes four of these.
    for f in rows("world.alias", 3):
        put(norm(f[1], f[0]), "6 world", "link",
            "a second name for %s" % f[2], "world.alias")

    # -- stage 7: the tape's own binaries
    for f in rows("tapebins.txt", 3):
        put(norm(f[2], f[0]), "7 tape", "copy", f[1], "tapebins.txt")

    # -- stage 7: the device table
    for f in rows("proto-dev", 4):
        put("/dev/" + f[0], "7 dev", "mknod",
            "%s %s %s" % (f[1], f[2], f[3]), "proto-dev")

    # -- stage 7: the configuration
    for f in rows("proto-etc", 2):
        put("/etc/" + f[0], "7 etc", "config", "v10/src/etc/" + f[0], "proto-etc")

    # -- stage 7: whole trees from the tape
    for dest, src in (("/usr/man", "src/man"),
                      ("/usr/include", "include"),
                      ("/usr/blit", "blit")):
        put(dest + "/...", "7 tape", "tree", src, "(whole tree)")

    return plan


def render(plan):
    bystage = collections.Counter()
    bymethod = collections.Counter()
    for p, v in plan.items():
        bystage[v[0]] += 1
        bymethod[v[1]] += 1
    out = ["# The file-by-file plan: every path on the golden, and how it gets there.",
           "#",
           "# Generated by tools/v10-plan.py from the lists in v10/mk/gen.  Do not",
           "# edit: a plan written by hand goes stale the first time a unit starts",
           "# building.",
           "#",
           "# fields: path<TAB>stage<TAB>method<TAB>source<TAB>list",
           "#",
           "# method:  build  compiled from source, installed by its makefile's",
           "#                 install: target into $(DESTDIR) -- the new image",
           "#          copy   the tape ships it and nothing can build it",
           "#          link   a second name for a binary already built",
           "#          mknod  a device node from the generated table",
           "#          config content lives in v10/src/etc",
           "#          tree   a whole directory from the tape",
           "#",
           "# There is no `inherit'.  A path with no source is a defect in the plan.",
           "#",
           "# by stage:"]
    for k in sorted(bystage):
        out.append("#   %-16s %5d" % (k, bystage[k]))
    out.append("# by method:")
    for k, v in bymethod.most_common():
        out.append("#   %-16s %5d" % (k, v))
    out.append("#   %-16s %5d" % ("TOTAL", len(plan)))
    out.append("")
    for p in sorted(plan):
        stage, method, source, lst, dups = plan[p]
        row = "%s\t%s\t%s\t%s\t%s" % (p, stage, method, source, lst)
        if dups:
            row += "\t# also claimed by: " + ", ".join(dups[:3])
        out.append(row)
    return "\n".join(out) + "\n", bystage, bymethod


def markdown(plan, bystage, bymethod):
    """The same rows, grouped by directory, as a document."""
    bydir = collections.defaultdict(list)
    for path in sorted(plan):
        stage, method, source, lst, dups = plan[path]
        parts = path.split("/")
        d = "/".join(parts[:3]) if len(parts) > 3 and parts[1] == "usr" \
            else ("/" + parts[1] if len(parts) > 2 else "/")
        bydir[d].append((path, stage, method, source, lst, dups))

    o = ["# The file-by-file plan",
         "",
         "Every path on the golden, and how it gets there. **Generated by",
         "`tools/v10-plan.py`** from the lists in `v10/mk/gen` — a plan written by",
         "hand goes stale the first time a unit starts building, and a plan quoted",
         "from memory is how this project put ix binaries and an Eighth Edition",
         "`fstab` on a Tenth Edition disk.",
         "",
         "`docs/v10-bootstrap.md` is the procedure; this is its manifest.",
         "",
         "## Methods",
         "",
         "| method | meaning |",
         "|---|---|",
         "| `build` | compiled from source by the stage named, installed by its makefile's `install:` target into `$(DESTDIR)` — the new image |",
         "| `copy` | the tape ships it and nothing can build it |",
         "| `link` | a second name for a binary already built, as a hard link |",
         "| `mknod` | a device node, from the generated table |",
         "| `config` | content lives in `v10/src/etc` |",
         "| `tree` | a whole directory from the tape |",
         "",
         "**There is no `inherit`.** A path with no source is a defect in this plan,",
         "not a file to scavenge off the machine that happens to have it.",
         "",
         "## Totals",
         "",
         "| stage | paths |    | method | paths |",
         "|---|---:|---|---|---:|"]
    st = sorted(bystage.items())
    me = bymethod.most_common()
    for i in range(max(len(st), len(me))):
        a = "`%s` | %d" % st[i] if i < len(st) else " | "
        b = "`%s` | %d" % me[i] if i < len(me) else " | "
        o.append("| %s |  | %s |" % (a, b))
    o.append("| **total** | **%d** |  |  |  |" % len(plan))
    o.append("")

    for d in sorted(bydir):
        rowsd = bydir[d]
        o.append("## `%s` — %d paths" % (d, len(rowsd)))
        o.append("")
        o.append("| path | stage | method | source |")
        o.append("|---|---|---|---|")
        for path, stage, method, source, lst, dups in rowsd:
            note = "" if not dups else "  ⚠ also claimed by %s" % dups[0]
            o.append("| `%s` | %s | `%s` | `%s`%s |" % (path, stage, method, source, note))
        o.append("")
    return "\n".join(o) + "\n"


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="v10/mk/gen/plan.txt")
    ap.add_argument("--md",  default="docs/v10-plan.md")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args(argv)
    plan = build()
    text, bystage, bymethod = render(plan)
    md = markdown(plan, bystage, bymethod)
    dest = os.path.join(ROOT, a.out)
    mdest = os.path.join(ROOT, a.md)
    if a.check:
        for f, want in ((dest, text), (mdest, md)):
            cur = open(f).read() if os.path.exists(f) else ""
            if cur != want:
                sys.stderr.write("v10-plan: %s is out of date\n" % f)
                return 1
        print("v10-plan: up to date (%d paths)" % len(plan))
        return 0
    open(dest, "w").write(text)
    open(mdest, "w").write(md)
    print("v10-plan: %d paths -> %s and %s" % (len(plan), a.md, a.out))
    for k in sorted(bystage):
        print("   %-16s %5d" % (k, bystage[k]))
    print("   %s" % ("-" * 22))
    for k, v in bymethod.most_common():
        print("   %-16s %5d" % (k, v))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
