#!/usr/bin/env python3
"""Extract a subtree out of a V8 disk image to a host directory.

	tools/v8extract.py IMAGE[:PART] /src/path DESTDIR

Written for one job: the DMD 5620 userland.  `/usr/jerq' exists on the V8
golden as 365 Bell Labs binaries and is CARRIED there rather than built
(v8/mk/gen/carry.txt), so the files a V10 disk needs are on an image and not in
the repo.  netfs can then serve DESTDIR to the V10 builder.

It is an EXTRACTOR AND NOT A BLESSING.  tools/v8fs.py's own warning applies with
the same force -- if the reader is wrong, this writes the wrong bytes and
nothing downstream would know.  So every regular file's sha256 is printed to a
manifest beside the tree, and the count and byte total are asserted against the
image's own directory walk.  Compare that manifest with the image again before
trusting a tree this produced for anything that ships.

Modes are preserved because they matter for a terminal userland: /usr/jerq/bin
carries setuid and setgid bits (vismon is 2755) and a share served with the
wrong mode gives a guest that cannot exec.

AND IT DE-COLLIDES CASE, BECAUSE THE FIRST VERSION DID NOT AND LOST THE 5620 C
LIBRARY WITHOUT A WORD.  `/usr/jerq' distinguishes three pairs only by case --
`3cc'/`3CC', `libc.a'/`libC.a', `src/lib/c'/`src/lib/C', all C-versus-cfront --
and on case-insensitive APFS the second of each simply overwrote the first: the
run reported "1613 files" and the extracted `3cc' was `3CC', 2,322 bytes of
shell where 14,336 bytes of compiler should have been.  Nothing failed.

The convention is already this project's, from tools/v8-import.py: the loser of
each group is stored with its uppercase letters percent-escaped (`3CC' ->
`3%43%43'), the winner is the spelling with the fewest capitals with ties broken
lexicographically, and a CASEMAP beside the tree records the translation --
which `netfs/Sources/NetFS/CaseMap.swift' reads, so the GUEST sees the true
names and no copy step has to know.  Escaping a directory de-collides
everything under it, so CASEMAP is written parents-first.
"""

import hashlib
import importlib.util
import os
import stat
import sys


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def escape(name):
    """Percent-escape uppercase letters: C -> %43.  tools/v8-import.py's rule."""
    return "".join("%%%02X" % ord(c) if "A" <= c <= "Z" else c for c in name)


def resolve_collisions(rels):
    """rel -> stored rel, plus CASEMAP rows (true parent, stored, true).

    Case folding is per COMPONENT, so a collision is always between siblings.
    The winner is the spelling with the fewest capitals, ties lexicographic --
    which keeps the ordinary lower-case name unescaped, so a tree with no
    collisions is byte-for-byte what it always was.
    """
    import collections
    bydir = collections.defaultdict(lambda: collections.defaultdict(list))
    for rel in rels:
        parent, _, name = rel.rpartition("/")
        bydir[parent][name.lower()].append(name)

    renamed = {}                                        # (parent, name) -> stored
    rows = []
    for parent in sorted(bydir, key=lambda p: (p.count("/") if p else -1, p)):
        for _, names in sorted(bydir[parent].items()):
            if len(names) < 2:
                continue
            names.sort(key=lambda n: (sum(c.isupper() for c in n), n))
            for loser in names[1:]:
                stored = escape(loser)
                if stored.lower() in (n.lower() for n in names if n != loser):
                    raise SystemExit("v8extract: escaping %s/%s still collides"
                                     % (parent, loser))
                renamed[(parent, loser)] = stored
                rows.append((parent or ".", stored, loser))

    def stored(rel):
        out, true = [], ""
        for comp in rel.split("/"):
            out.append(renamed.get((true, comp), comp))
            true = "%s/%s" % (true, comp) if true else comp
        return "/".join(out)

    return {rel: stored(rel) for rel in rels}, rows


def main(argv):
    if len(argv) != 4:
        sys.stderr.write(__doc__)
        return 2
    here = os.path.dirname(os.path.abspath(argv[0]))
    v8 = load("v8fs", os.path.join(here, "v8fs.py"))

    spec, src, dest = argv[1], argv[2].rstrip("/") or "/", argv[3]
    # SPLIT ON THE LAST COLON, not the first: a Windows-style path cannot occur
    # here but an absolute path with no colon must not be mangled.
    if ":" in spec:
        img, part = spec.rsplit(":", 1)
    else:
        img, part = spec, "a"
    fs = v8.V8FS(img, part)
    sys.stderr.write("v8extract: %s partition %s -> %s\n" % (img, part, dest))

    top = fs.lookup(src)
    if top is None:
        sys.stderr.write("v8extract: no %s on %s:%s\n" % (src, img, part))
        return 1

    # ---- pass one: the whole inventory, so collisions can be seen at all ----
    entries = []                                        # (rel, inode)
    for path, ip in fs.walk(src):
        rel = path[len(src):].lstrip("/")
        if rel:
            entries.append((rel, ip))

    stored_of, casemap = resolve_collisions([r for r, _ in entries])
    if casemap:
        sys.stderr.write("v8extract: %d case collision(s) escaped\n" % len(casemap))
        for parent, spelling, true in casemap:
            sys.stderr.write("   %s/%s  stored as  %s\n" % (parent, true, spelling))

    os.makedirs(dest, exist_ok=True)
    lines = []
    ndir = nreg = nskip = 0
    total = 0
    for rel, ip in entries:
        out = os.path.join(dest, stored_of[rel])
        if ip.isdir:
            os.makedirs(out, exist_ok=True)
            ndir += 1
            continue
        if not ip.isreg:
            # Devices and anything else are NOT invented on the host: a node
            # has to be made on the guest with the right major, and a zero-byte
            # stand-in here would silently become a regular file over netfs.
            nskip += 1
            lines.append("skip\t%s\t%s" % (ip.kind, rel))
            continue
        data = fs.read(ip)[:ip.size]
        with open(out, "wb") as f:
            f.write(data)
        os.chmod(out, stat.S_IMODE(ip.mode))
        nreg += 1
        total += len(data)
        lines.append("%s\t%06o\t%d\t%s" % (hashlib.sha256(data).hexdigest(),
                                           stat.S_IMODE(ip.mode), len(data), rel))

    # ---- METADATA GOES BESIDE THE TREE, NEVER INSIDE IT ---------------------
    #
    # Both of these shipped on a V10 disk the first time round, and each for its
    # own reason:
    #
    #   * the manifest, 153 KB of sha256, was inside `jerq/', so the guest's
    #     `cd /n/dist/jerq; find . | cpio -pd' copied it like any other file.
    #     /usr/jerq/.v8extract on a shipped disk is build detritus wearing a
    #     system path -- the very thing this harness refuses elsewhere.
    #   * and CASEMAP was inside it too, which is WORSE than litter: netfsd's
    #     CaseMap reads `<share root>/CASEMAP', and the share root is the parent
    #     of this tree, so the map was never found and the guest saw the ESCAPED
    #     names.  `3%43%43' duly arrived on the disk and `3CC' did not.
    #
    # So the manifest becomes `<parent>/<name>.v8extract' and CASEMAP is
    # APPENDED to `<parent>/CASEMAP' with this tree's name on the front of each
    # parent column -- one map for a share carrying several trees.  Both are now
    # siblings of the tree, so `find .' inside it cannot see either.
    meta = os.path.dirname(os.path.abspath(dest))
    prefix = os.path.basename(os.path.abspath(dest))
    if casemap:
        cmpath = os.path.join(meta, "CASEMAP")
        fresh = not os.path.exists(cmpath)
        with open(cmpath, "a") as f:
            if fresh:
                f.write("# Paths these trees distinguish only by case.  The loser of each\n"
                        "# group is stored percent-escaped; netfsd reads this file at the\n"
                        "# SHARE ROOT and serves the TRUE name to the guest\n"
                        "# (netfs/Sources/NetFS/CaseMap.swift).\n"
                        "# Parents-first: escaping a directory de-collides its children.\n"
                        "# Generated by tools/v8extract.py -- do not edit.\n"
                        "# directory<TAB>stored-name<TAB>true-name\n\n")
            for parent, spelling, true in casemap:
                joined = prefix if parent == "." else "%s/%s" % (prefix, parent)
                f.write("%s\t%s\t%s\n" % (joined, spelling, true))

    man = os.path.join(meta, prefix + ".v8extract")
    with open(man, "w") as f:
        f.write("# %s:%s %s\n# dirs %d  files %d  bytes %d  skipped %d\n"
                % (img, part, src, ndir, nreg, total, nskip))
        f.write("\n".join(lines) + "\n")
    print("v8extract: %d dirs, %d files, %d bytes, %d non-regular skipped"
          % (ndir, nreg, total, nskip))
    print("v8extract: manifest %s" % man)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
