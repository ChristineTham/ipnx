#!/usr/bin/env python3
"""Validate v10/ against v10tapes/ WITHOUT reusing the builder's logic.

    tools/v10-check.py            # every check
    tools/v10-check.py --list     # print the offending paths, not just counts

A validator that reuses v10-tree.py's selection would prove only that the code
agrees with itself.  These checks are CONTENT-BASED and BIDIRECTIONAL, and
share no reasoning with the builder:

    FORWARD   every byte-sequence on a tape appears somewhere in the tree,
              unless it is deliberately excluded
    BACKWARD  every file in the tree traces back to a tape file, an archive
              member, or an ORDER file we wrote

That pair catches the three ways a merge goes wrong quietly -- a file silently
overwritten, the wrong file at a path, and something present that no tape has --
none of which raises an error at the time.

AND A CASE-SLOT CHECK, because the whole class of fault this tree has already
hit is two paths sharing one slot on a case-insensitive filesystem: the second
write lands on the first and the only evidence is a count slightly too small.
"""

import argparse
import collections
import hashlib
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TAPES = os.path.join(ROOT, "v10tapes")
TREE = os.path.join(ROOT, "v10superset")

AR_MAGIC = b"!<arch>\n"
EXCLUDE_IX = ("norman", "history/ix")

# WHERE EACH TAPE LANDS.  This is layout -- a fact about the tree's shape --
# not the selection RULE, which is what must not be shared with the builder.
# Without it the check looks for blit's unpacked archives at lib/libc.a
# instead of blit/lib/libc.a and calls thirteen present files missing.
PREFIX = {"norman": "", "secombe": "", "sellers": "", "milligan": "",
          "r70include": "include", "blit": "blit"}


def sha(b):
    return hashlib.sha256(b).hexdigest()


def read(p):
    """Content of a file, and for a symlink the target string it names."""
    if os.path.islink(p):
        return os.readlink(p).encode()
    try:
        with open(p, "rb") as f:
            return f.read()
    except OSError:
        return None


def walk(root):
    for dp, _dn, fn in os.walk(root):
        for n in fn:
            p = os.path.join(dp, n)
            yield os.path.relpath(p, root), p


def ar_members(data):
    """(name, bytes) for every member of an ar archive, in order."""
    out, i = [], 8
    while i + 60 <= len(data):
        hdr = data[i:i + 60]
        name = hdr[0:16].decode("latin-1").rstrip()
        try:
            size = int(hdr[48:58].decode("latin-1").strip())
        except ValueError:
            break
        i += 60
        if name.startswith("#1/"):
            n = int(name[3:])
            name = data[i:i + n].decode("latin-1").rstrip("\0")
            i += n
            size -= n
        if name.endswith("/"):
            name = name[:-1]
        body = data[i:i + size]
        if name not in ("__.SYMDEF", "__.SYMDEF SORTED", "/", "//"):
            out.append((name, body))
        i += size + (size & 1)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true")
    args = ap.parse_args()

    for d in (TAPES, TREE):
        if not os.path.isdir(d):
            sys.exit("v10-check: no %s" % d)

    # Deliberate omissions, read from the extractor's own record so this does
    # not have to know the rule -- only that a decision was made and logged.
    dropped = set()
    hl = os.path.join(TAPES, "HARDLINKS")
    if os.path.exists(hl):
        for line in open(hl):
            if line.startswith("#"):
                continue
            f = line.rstrip("\n").split("\t")
            if len(f) == 4:
                d = f[1] if f[1] != "." else ""
                dropped.add((f[0], os.path.join(d, f[3]) if d else f[3]))

    # What the extractor renamed for case, read from its own record.
    untranslate = {}
    cm = os.path.join(TAPES, "CASEMAP")
    if os.path.exists(cm):
        for line in open(cm):
            if line.startswith("#"):
                continue
            t, was, now = line.rstrip("\n").split("\t")
            untranslate[(t, now)] = was

    # ------------------------------------------------------------- tapes ---
    tape_hash = collections.defaultdict(list)   # hash -> [tape/path]
    excluded = 0
    n_tape = 0
    for tape in sorted(os.listdir(TAPES)):
        d = os.path.join(TAPES, tape)
        if not os.path.isdir(d):
            continue
        for rel, p in walk(d):
            if tape == EXCLUDE_IX[0] and (rel == EXCLUDE_IX[1]
                                          or rel.startswith(EXCLUDE_IX[1] + "/")):
                excluded += 1
                continue
            if (tape, rel) in dropped:
                excluded += 1
                continue
            b = read(p)
            if b is None:
                continue
            n_tape += 1
            tape_hash[sha(b)].append("%s/%s" % (tape, rel))

    # -------------------------------------------------------------- tree ---
    tree_hash = collections.defaultdict(list)
    tree_paths = []
    order_files = 0
    for rel, p in walk(TREE):
        tree_paths.append(rel)
        if os.path.basename(rel) == "ORDER":
            order_files += 1
            continue
        b = read(p)
        if b is None:
            continue
        tree_hash[sha(b)].append(rel)

    # Members of the archives the tape carries -- a tree file may legitimately
    # be one of these rather than a tape file in its own right.
    member_hash = set()
    n_archives = 0
    for tape in sorted(os.listdir(TAPES)):
        d = os.path.join(TAPES, tape)
        if not os.path.isdir(d):
            continue
        for rel, p in walk(d):
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
            n_archives += 1
            for _name, body in ar_members(data):
                member_hash.add(sha(body))

    print("== inputs ==")
    print("   tape files (after exclusions) %7d" % n_tape)
    print("   excluded                      %7d" % excluded)
    print("   tree files                    %7d" % len(tree_paths))
    print("   of which ORDER                %7d" % order_files)
    print("   ar archives on the tapes      %7d" % n_archives)

    # ------------------------------------------------- 1. forward: content ---
    # A TAPE FILE MAY LEGITIMATELY BE ABSENT FOR TWO REASONS, and neither is a
    # fault: it lost a contest to a newer copy on another tape, or it was an
    # archive that got unpacked and is a directory now.  Everything else is a
    # file the merge dropped.
    #
    # The loser set is computed FROM THE TAPES -- group by destination path,
    # keep the newest mtime -- so this does not borrow the builder's rule; it
    # re-derives which copy ought to have survived and asks for that one.
    bydest = collections.defaultdict(list)
    for tape in sorted(os.listdir(TAPES)):
        d = os.path.join(TAPES, tape)
        if not os.path.isdir(d) or tape not in PREFIX:
            continue
        for rel, p in walk(d):
            if tape == EXCLUDE_IX[0] and (rel == EXCLUDE_IX[1]
                                          or rel.startswith(EXCLUDE_IX[1] + "/")):
                continue
            if (tape, rel) in dropped:
                continue
            tp = untranslate.get((tape, rel), rel)
            dest = os.path.join(PREFIX[tape], tp) if PREFIX[tape] else tp
            bydest[dest].append((tape, rel, p, int(os.lstat(p).st_mtime)))
    winners = set()
    for dest, cands in bydest.items():
        newest = max(c[3] for c in cands)
        for tape, rel, _p, mt in cands:
            if mt == newest:
                winners.add((tape, rel))
                break

    missing = []
    for h, paths in tape_hash.items():
        if h in tree_hash:
            continue
        for tp in paths:
            tape, rel = tp.split("/", 1)
            if (tape, rel) not in winners:
                continue                      # lost a contest -- expected
            dest = os.path.join(PREFIX.get(tape, ""),
                                untranslate.get((tape, rel), rel))
            d = os.path.join(TREE, dest)
            if os.path.isdir(d) and os.path.exists(os.path.join(d, "ORDER")):
                continue                      # unpacked archive -- expected
            missing.append(tp)
    print("\n== 1. forward: every winning tape file's content is in the tree ==")
    print("   missing %d" % len(missing))
    if missing and args.list:
        for m in sorted(missing)[:40]:
            print("      %s" % m)

    # ------------------------------------------------ 2. backward: origin ---
    stray = []
    for h, paths in tree_hash.items():
        if h in tape_hash or h in member_hash:
            continue
        stray.append(paths[0])
    print("\n== 2. backward: every tree file came from a tape ==")
    print("   with no tape origin %d" % len(stray))
    if stray and args.list:
        for sp in sorted(stray)[:40]:
            print("      %s" % sp)

    # ------------------------------------------------------ 3. case slots ---
    slots = collections.defaultdict(list)
    for rel in tree_paths:
        slots[rel.lower()].append(rel)
    clash = {k: v for k, v in slots.items() if len(v) > 1}
    print("\n== 3. no two tree paths share a case-slot ==")
    print("   clashing slots %d" % len(clash))
    if clash and args.list:
        for k, v in sorted(clash.items())[:40]:
            print("      %s" % " | ".join(v))

    # -------------------------------------------------------- 4. archives ---
    bad_order = []
    unpacked = 0
    for dp, dn, fn in os.walk(TREE):
        if "ORDER" not in fn:
            continue
        unpacked += 1
        want = [l.rstrip("\n") for l in open(os.path.join(dp, "ORDER"))]
        have = set(fn) - {"ORDER"}
        absent = [m for m in want if m not in have]
        if absent:
            bad_order.append((os.path.relpath(dp, TREE), len(want), absent[:3]))
    print("\n== 4. every unpacked archive has the members ORDER names ==")
    print("   archives in the tree %d, incomplete %d" % (unpacked, len(bad_order)))
    for rel, n, absent in bad_order[:20]:
        print("      %s (%d named) missing %s" % (rel, n, ", ".join(absent)))

    # --------------------------------------------------------- 5. the sum ---
    ok = not (missing or stray or clash or bad_order)
    print("\n== %s ==" % ("VALID" if ok else "PROBLEMS FOUND"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
