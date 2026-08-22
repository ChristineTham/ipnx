#!/usr/bin/env python3
"""Where every file on a V10 disk comes from, measured rather than recalled.

	tools/v10-manifest.py [--disk IMG] [--builder IMG] [--out FILE]

Writes v10/mk/gen/manifest.txt: one row per file on the disk, naming the source
whose bytes it matches.

WHY THIS EXISTS.  The build was assembled by copying whole directories off the
machine that built it and overlaying products on top, so nothing recorded what
came from where.  Asked that question I answered it from memory of CLAUDE.md
and got it wrong repeatedly -- attributing files to phases without checking.
This computes the answer from bytes.

NOTHING HERE IS REMEMBERED.  Every source is indexed by sha256 of its actual
content, and a file's origin is whichever sources hold those exact bytes.  A
file matching none of them is reported as such rather than explained.

THE SOURCES, AND WHY THEY ARE SPLIT THIS WAY.  A builder image contains both
the machine and the things it built, and those are not the same kind of thing:
taking /bin/cat off the builder's root is inheritance, while taking a file out
of its staged root is installation.  So the builder is indexed by directory,
not as one blob.

AMBIGUITY IS REPORTED, NOT RESOLVED.  A file that exists identically in several
sources gets all of them listed.  Deciding which one a build SHOULD use is a
judgement; this tool only says where the bytes exist.
"""

import argparse
import collections
import hashlib
import importlib.util
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


v10fs = load("v10fs", os.path.join(ROOT, "tools", "v10fs.py"))
try:
    v8fs = load("v8fs", os.path.join(ROOT, "tools", "v8fs.py"))
except Exception:
    v8fs = None


# ---------------------------------------------------------------- readers ---

def v10_files(img, parts):
    """{path: (size, sha256)} for every regular file, both filesystems."""
    out = {}
    for part, pre in parts:
        try:
            fs = v10fs.Fs(img, part)
        except SystemExit:
            continue
        for p, i in fs.walk("/"):
            if (i["mode"] & v10fs.IFMT) != v10fs.IFREG:
                continue
            try:
                data = bytes(fs.read(i))
            except Exception:
                continue
            out[pre + p] = (len(data), hashlib.sha256(data).hexdigest())
    return out


def v8_files(img, parts):
    out = {}
    if v8fs is None or not os.path.exists(img):
        return out
    for part, pre in parts:
        try:
            fs = v8fs.V8FS(img, part)
        except SystemExit:
            continue
        for p, ip in fs.walk("/"):
            if not ip.isreg:
                continue
            try:
                data = bytes(fs.read(ip))
            except Exception:
                continue
            out[pre + p] = (len(data), hashlib.sha256(data).hexdigest())
    return out


def tree_files(root):
    out = {}
    if not os.path.isdir(root):
        return out
    for dp, _, fs in os.walk(root):
        for f in fs:
            p = os.path.join(dp, f)
            try:
                with open(p, "rb") as fh:
                    data = fh.read()
            except OSError:
                continue
            out[os.path.relpath(p, root)] = (len(data), hashlib.sha256(data).hexdigest())
    return out


# ------------------------------------------------------- builder, by role ---
# A builder image holds the machine AND what it built.  Which directory a file
# sits in is the only thing that distinguishes installation from inheritance,
# so the split is by path prefix and each prefix is named in the output.
BUILDER_ROLES = [
    ("staged",  ("/usr/w10/",)),
    ("stage1",  ("/usr/s1/",)),
    ("scratch", ("/usr/obj/", "/usr/k10lib/", "/usr/k10lnk/", "/usr/nd/", "/tmp/")),
    ("builder", ()),                     # everything else: the machine itself
]


def builder_role(path):
    for role, prefixes in BUILDER_ROLES:
        if prefixes and path.startswith(prefixes):
            return role
    return "builder"


# ------------------------------------------------ who writes an unmatched ---
# For a file that matches no indexed source, the question "what put it here"
# is answered by searching the harnesses for the path -- a grep, not a memory.
def searchers(paths, where=("tools", "v10/mk", "v10/mk/gen")):
    """{path: [file:line, ...]} for each path mentioned in the build scripts."""
    hits = collections.defaultdict(list)
    pats = {p: re.compile(re.escape(p.rsplit("/", 1)[-1])) for p in paths}
    for d in where:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full):
            continue
        for dp, _, fs in os.walk(full):
            for f in fs:
                if not f.endswith((".sh", ".exp", ".py", ".mk", ".txt", ".order")):
                    continue
                fp = os.path.join(dp, f)
                try:
                    lines = open(fp, "r", errors="replace").read().split("\n")
                except OSError:
                    continue
                for n, line in enumerate(lines, 1):
                    for p, rx in pats.items():
                        if rx.search(line):
                            hits[p].append("%s:%d" % (os.path.relpath(fp, ROOT), n))
    return hits


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--disk",    default="work/v10gold/v10-built.img")
    ap.add_argument("--builder", default="work/v10gold/ipnx-v10-ra81.img.stage1.k102.k7.k13.k103")
    ap.add_argument("--v8",      default="work/myv8/rp07new")
    ap.add_argument("--out",     default="v10/mk/gen/manifest.txt")
    ap.add_argument("--no-search", action="store_true",
                    help="skip the harness search for unmatched files")
    a = ap.parse_args(argv)

    disk = os.path.join(ROOT, a.disk)
    if not os.path.exists(disk):
        sys.exit("v10-manifest: no %s" % disk)

    sys.stderr.write("indexing the disk ...\n")
    target = v10_files(disk, [("a", ""), ("c", "/usr")])
    sys.stderr.write("  %d files\n" % len(target))

    # index every source by content hash -> {(kind, path)}
    index = collections.defaultdict(set)

    def add(kind, files):
        for p, (s, h) in files.items():
            index[h].add((kind, p))
        sys.stderr.write("  %-10s %6d files\n" % (kind, len(files)))

    sys.stderr.write("indexing sources ...\n")
    add("tape",    tree_files(os.path.join(ROOT, "work", "v10")))
    add("overlay", tree_files(os.path.join(ROOT, "v10", "src")))
    add("gen",     tree_files(os.path.join(ROOT, "v10", "mk", "gen")))
    bfiles = v10_files(os.path.join(ROOT, a.builder), [("a", ""), ("c", "/usr")])
    byrole = collections.defaultdict(dict)
    for p, v in bfiles.items():
        byrole[builder_role(p)][p] = v
    for role in ("staged", "stage1", "scratch", "builder"):
        add(role, byrole.get(role, {}))
    add("v8", v8_files(os.path.join(ROOT, a.v8), [("a", ""), ("f", "/usr")]))

    rows, unmatched = [], []
    for p in sorted(target):
        size, h = target[p]
        srcs = sorted(index.get(h, ()))
        if not srcs:
            rows.append((p, size, "UNMATCHED", ""))
            unmatched.append(p)
        else:
            kinds = sorted({k for k, _ in srcs})
            # report the first path for each kind, so a row stays one line
            first = {}
            for k, sp in srcs:
                first.setdefault(k, sp)
            rows.append((p, size, "+".join(kinds),
                         " ".join("%s=%s" % (k, first[k]) for k in kinds)))

    found = {}
    if unmatched and not a.no_search:
        sys.stderr.write("searching the harnesses for %d unmatched files ...\n" % len(unmatched))
        found = searchers(unmatched)

    tally = collections.Counter(r[2] for r in rows)
    out = ["# Where every file on a V10 disk comes from.",
           "#",
           "# Generated by tools/v10-manifest.py -- MEASURED, not recalled.  Each row's",
           "# source is whichever indexed tree holds those exact bytes (sha256).",
           "#",
           "#   disk     %s" % a.disk,
           "#   builder  %s" % a.builder,
           "#",
           "# fields: path<TAB>size<TAB>source-kinds<TAB>where",
           "#",
           "# `builder' means the bytes exist ONLY in the builder's own system",
           "# directories -- not in its staged root, not in stage 1, not on the tape.",
           "# That is inheritance: the build copied a machine rather than installing a",
           "# file, and nothing recorded the choice.",
           "#",
           "# tally:"]
    for k, n in tally.most_common():
        out.append("#   %-40s %5d" % (k, n))
    out.append("")
    for p, s, kinds, where in rows:
        out.append("%s\t%d\t%s\t%s" % (p, s, kinds, where))
    if unmatched:
        out.append("")
        out.append("# UNMATCHED -- these bytes are in no indexed source.  The lines below")
        out.append("# are what the build scripts say about each path, found by search:")
        for p in unmatched:
            out.append("#   %s" % p)
            for hit in found.get(p, [])[:6]:
                out.append("#       %s" % hit)
            if not found.get(p):
                out.append("#       (no build script mentions it)")

    dest = os.path.join(ROOT, a.out)
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    open(dest, "w").write("\n".join(out) + "\n")
    print("v10-manifest: %d files -> %s" % (len(rows), a.out))
    for k, n in tally.most_common():
        print("   %-40s %5d" % (k, n))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
