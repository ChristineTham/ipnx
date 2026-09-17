#!/usr/bin/env python3
"""What V10's programs read, and whether anything puts it there.

	tools/v10-datafiles.py            # the three lists
	tools/v10-datafiles.py -v         # with every candidate source path

A V10 command is not finished when it links.  `style' wants fourteen `.t' and
`.st' files under /usr/lib/style, `uucp' wants its Devices and Permissions,
nroff wants the macro package, `spell' wants a dictionary -- and the build
installs the binaries and none of that.  The gap does not show up in a build
log, because nothing fails: the program is there, and it says `cannot open' the
first time somebody runs it.

SO THE QUESTION IS ASKED OF THE SOURCE, NOT OF A LIST.  Every /usr/lib and
/usr/dict path this tree NAMES is a path something expects to read, and the
answer for each is one of three:

    in the tree, not installed     a missing install rule -- the file is here
    not in the tree, V8 has it     an import, with V8 as the provenance
    neither                        nothing to do; the tape does not carry it

BASENAME MATCHING IS THE WEAK STEP and is deliberately not hidden.  A candidate
is any file in the tree with the same basename, so cmd/netnews/doc/howto turns
up as a candidate for /usr/lib/view2d/howto, which it plainly is not.  Every
candidate is printed for a person to accept or reject; -v prints all of them
rather than the first.  A tool that guessed here would be a tool that quietly
installed the wrong file.
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "v10", "usr", "src")
MKFILE = os.path.join(SRC, "build", "mkfile")
V8 = os.path.join(ROOT, "v8")

# `/usr/lib/x' or `/usr/dict/x', at least one component past the directory.
# Objects and archives are the toolchain's and are built, not carried.
PATH = re.compile(r'/usr/(?:lib|dict)/[A-Za-z0-9_./-]+')
SKIP_SUFFIX = (".o", ".a")


def referenced():
    """Every /usr/lib and /usr/dict path the source names, with one namer each."""
    out = {}
    for dirpath, dirs, files in os.walk(SRC):
        if "/build/" in dirpath + "/":
            continue                    # the build system is not the tree
        for name in files:
            full = os.path.join(dirpath, name)
            try:
                with open(full, "rb") as fh:
                    text = fh.read().decode("utf-8", "replace")
            except OSError:
                continue
            for m in PATH.findall(text):
                m = m.rstrip("./")
                if m.endswith(SKIP_SUFFIX) or len(m.split("/")) < 4:
                    continue
                out.setdefault(m, full[len(SRC) + 1:])
    return out


def installed():
    """Paths the mkfile puts under $ROOT/usr/lib or $ROOT/usr/dict."""
    mk = open(MKFILE, errors="replace").read()
    return set(re.findall(r'\$ROOT(/usr/(?:lib|dict)/[A-Za-z0-9_./-]+)', mk))


def by_basename(root, prefix=""):
    index = {}
    for dirpath, dirs, files in os.walk(root):
        for name in files:
            index.setdefault(name, []).append(
                os.path.join(dirpath, name)[len(root) + 1:])
    return index


def main():
    verbose = "-v" in sys.argv
    want = referenced()
    inst = installed()
    tree = by_basename(SRC)
    v8_paths = set()
    for dirpath, dirs, files in os.walk(os.path.join(V8, "usr")):
        for name in files:
            v8_paths.add(os.path.join(dirpath, name)[len(V8) + 1:])

    have, imports, neither = [], [], []
    for path in sorted(want):
        if path in inst:
            continue
        cands = tree.get(os.path.basename(path), [])
        if cands:
            have.append((path, want[path], cands))
        elif path.lstrip("/") in v8_paths:
            imports.append((path, want[path]))
        else:
            neither.append(path)

    print("%d paths named by the source, %d installed by the mkfile\n"
          % (len(want), len(set(want) & inst)))

    print("== IN THE TREE, NOT INSTALLED -- %d, each a missing install rule" % len(have))
    print("   (candidate by basename; check it before believing it)")
    for path, namer, cands in have:
        print("   %-30s <- %s" % (path, cands[0]))
        if verbose:
            for c in cands[1:]:
                print("   %-30s    %s" % ("", c))
            print("   %-30s    named by %s" % ("", namer))

    print("\n== NOT IN THE TREE, V8 HAS IT AT THE SAME PATH -- %d, each an import"
          % len(imports))
    for path, namer in imports:
        print("   %-30s <- v8/%s%s" % (path, path.lstrip("/"),
                                       ("   named by " + namer) if verbose else ""))

    print("\n== IN NEITHER TREE -- %d, nothing to do" % len(neither))
    if verbose:
        for path in neither:
            print("   ", path)


if __name__ == "__main__":
    main()
