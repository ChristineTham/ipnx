#!/usr/bin/env python3
"""Is the V10 golden a functional superset of the V8 one?  Host-side.

	tools/v8v10-diff.py                 the functional summary
	tools/v8v10-diff.py --paths         and the raw path diff, by directory
	tools/v8v10-diff.py --commands      just the command names still missing
	tools/v8v10-diff.py --libs         ... the library names
	tools/v8v10-diff.py --devs         ... the device node names
	tools/v8v10-diff.py --all          all three lists

Reads both images with tools/v8fs.py and tools/v10fs.py; no simulator, about a
second.  Root and /usr are walked separately and stitched, because both are two
filesystems (V8: a + f, V10: a + c).

WHY IT REPORTS TWO WAYS, AND WHY THE PATH DIFF ALONE MISLEADS.  A path diff is
the right question for a COMMAND -- `awk' either exists or it does not -- and
the wrong one for a source tree.  Installing V10's own kernel source at
/usr/sys is the exact analogue of V8 keeping its kernel source there, and it
closes nothing at all by path: V8's subdirectories are `alice boot conf kdi
pcs' and V10's are `md io os fs astro ml'.  Reading only the path diff, that
work looks like it failed -- 202 missing before, 199 after -- when what actually
happened is that the tree went from absent to 785 files.  So:

	by NAME      commands, libraries and device nodes -- a real gap
	by TREE      man, sys, doc, src, include, jerq, blit, dict, net,
	             games, spool, lost+found -- present or absent, not identical

The same trap in one sentence: a metric that cannot distinguish "V10 has its own"
from "V10 has nothing" will report the second when the first is true.
"""

import importlib.util
import os
import sys

V8 = "work/myv8/rp07new"
V10 = "work/v10gold/ipnx-v10-made.img"

BINDIRS = ("/bin", "/usr/bin", "/etc", "/usr/games", "/usr/ucb", "/usr/jerq/bin")
LIBDIRS = ("/lib", "/usr/lib", "/usr/jerq/lib")
TREES = ("/usr/man", "/usr/sys", "/usr/doc", "/usr/src", "/usr/dict", "/usr/net",
         "/usr/jerq", "/usr/blit", "/usr/include", "/usr/games", "/usr/spool",
         "/usr/lib", "/usr/inet", "/lost+found", "/usr/lost+found")


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def main(argv):
    here = os.path.dirname(os.path.abspath(argv[0]))
    v8m = load("v8fs", os.path.join(here, "v8fs.py"))
    v10m = load("v10fs", os.path.join(here, "v10fs.py"))
    for p in (V8, V10):
        if not os.path.exists(p):
            sys.stderr.write("v8v10-diff: no %s\n" % p)
            return 1

    def w8(part, pre=""):
        fs = v8m.V8FS(V8, part)
        return {pre + p: (ip.kind, ip.size if ip.isreg else 0)
                for p, ip in fs.walk("/")}

    def w10(part, pre=""):
        fs = v10m.Fs(V10, part)
        km = {v10m.IFDIR: "d", v10m.IFCHR: "c", v10m.IFBLK: "b", v10m.IFREG: "-"}
        out = {}
        for p, i in fs.walk("/"):
            if p == "/":
                continue
            t = i["mode"] & v10m.IFMT
            out[pre + p] = (km.get(t, "?"), i["size"] if t == v10m.IFREG else 0)
        return out

    a = dict(w8("a")); a.update(w8("f", "/usr"))
    b = dict(w10("a")); b.update(w10("c", "/usr"))

    def names(d, dirs):
        out = set()
        for p, (k, _) in d.items():
            if k != "-":
                continue
            if p.rpartition("/")[0] in dirs:
                out.add(p.rpartition("/")[2])
        return out

    print("== inventories ==")
    print("   V8  %5d entries      V10 %5d entries" % (len(a), len(b)))

    c8, c10 = names(a, BINDIRS), names(b, BINDIRS)
    l8, l10 = names(a, LIBDIRS), names(b, LIBDIRS)
    d8 = {p.rpartition("/")[2] for p, (k, _) in a.items()
          if k in "cb" and p.startswith("/dev/")}
    d10 = {p.rpartition("/")[2] for p, (k, _) in b.items()
           if k in "cb" and p.startswith("/dev/")}

    print()
    print("== BY NAME -- a real gap ==")
    for label, s8, s10 in (("commands", c8, c10), ("libraries", l8, l10),
                           ("device nodes", d8, d10)):
        print("   %-14s V8 %4d   V10 %4d   V8-only %4d"
              % (label, len(s8), len(s10), len(s8 - s10)))

    print()
    print("== BY TREE -- present or absent, not identical ==")
    absent = 0
    for t in TREES:
        n8 = sum(1 for p in a if p == t or p.startswith(t + "/"))
        n10 = sum(1 for p in b if p == t or p.startswith(t + "/"))
        # RELATIVE, not absolute: /lost+found is ONE entry on V8 and one is the
        # correct state for it, while /usr/games at 2 of 154 is a directory with
        # a token in it.  A fixed threshold called the first thin and the second
        # ok -- both backwards.
        if n10 == 0:
            tag = "ABSENT"; absent += 1
        elif n10 >= n8:
            tag = "ok"
        elif n10 * 4 < n8:
            tag = "thin"
        else:
            tag = "partial"
        print("   %-18s V8 %5d   V10 %5d   %s" % (t, n8, n10, tag))

    def names_block(label, s8, s10):
        print()
        print("== %s on V8 and not on V10 (%d) ==" % (label, len(s8 - s10)))
        line = "   "
        for n in sorted(s8 - s10):
            if len(line) + len(n) > 76:
                print(line); line = "   "
            line += n + " "
        if line.strip():
            print(line)

    if "--commands" in argv or "--paths" in argv or "--all" in argv:
        names_block("command names", c8, c10)
    if "--libs" in argv or "--all" in argv:
        names_block("library names", l8, l10)
    if "--devs" in argv or "--all" in argv:
        names_block("device node names", d8, d10)

    if "--paths" in argv:
        import collections
        missing = sorted(p for p in a if p not in b)
        print()
        print("== raw path diff: %d V8 paths absent, %d V10 paths V8 lacks =="
              % (len(missing), len([p for p in b if p not in a])))

        def top2(p):
            parts = p.strip("/").split("/")
            return "/" + "/".join(parts[:2]) if len(parts) > 1 else "/" + parts[0]
        for d, n in collections.Counter(top2(p) for p in missing).most_common(20):
            print("   %-24s %6d" % (d, n))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
