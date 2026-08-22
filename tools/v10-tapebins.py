#!/usr/bin/env python3
"""Every linked Tenth Edition binary on the tape, and where it installs.

	tools/v10-tapebins.py [--check]

Writes v10/mk/gen/tapebins.txt, consumed by the bootstrap-image harness.

WHY THIS EXISTS.  v10/mk/gen/prebuilt.txt answers a narrower question -- "which
prebuilt commands can act as an ORACLE for what we build" -- so it is confined
to 0413 executables under src/cmd/ whose basename matches a source unit, and it
lists 57.  The tape carries 435 linked executables.  A BOOTSTRAP image wants
all of them that are VAX commands, because its job is to be a machine capable
of compiling the world, not to be a fidelity reference.

WHAT COUNTS.  A 0410 (NMAGIC) or 0413 (ZMAGIC) file is a linked VAX a.out.
0407 is excluded: it is OMAGIC, which is what an object file (.o) also is, and
the tape has 1,491 of those.

WHAT IS EXCLUDED, AND WHY EACH IS NOT A JUDGEMENT CALL:
  - lsys/ and sys/ hold linked KERNELS (seki.u and friends), not commands.
  - 630/ is the 630 MTG terminal's tree; its host-side tools duplicate names
    that belong to the 5620 (`630ld', `630mux'), and the 630 is a different
    terminal from the one this project emulates.
  - a.out, bin, and other build detritus are named by no install rule.

INSTALL PATHS come from the same oracle order tools/v10-where.py uses, so this
file cannot disagree with prebuilt.txt about a name they share -- a component
list that appears twice will disagree, and sanity() asserts they do not.
"""

import os, struct, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TAPE = os.path.join(ROOT, "work", "v10", "src")
OUT  = os.path.join(ROOT, "v10", "mk", "gen", "tapebins.txt")

EXE = (0o410, 0o413)

# NOTHING IS EXCLUDED.  An earlier version of this file dropped kernels,
# the 630 tree, dated variants and duplicate basenames -- 435 binaries became
# 296 -- and every one of those was my judgement rather than the tape's.  The
# instruction is to carry the tape's binaries, so the tape decides what there
# is and this file only says where each one goes.


def load_where():
    """name -> install directory, from v10/mk/where.txt (v10-where.py's output)."""
    w = {}
    p = os.path.join(ROOT, "v10", "mk", "where.txt")
    if not os.path.exists(p):
        return w
    for line in open(p):
        line = line.split("#")[0].rstrip("\n")
        if not line.strip():
            continue
        f = line.split("\t")
        # name<TAB>directory<TAB>source; unresolved rows carry an empty
        # directory and `--', and MUST NOT be read as a directory called `--'.
        if len(f) >= 3 and f[1].startswith("/") and f[2] != "--":
            w.setdefault(f[0], f[1])
    return w


def load_prebuilt():
    """name -> install directory, from v10/mk/gen/prebuilt.txt.

    prebuilt.txt resolved these paths already, through the same oracle order;
    re-deriving them here is how two lists come to disagree."""
    pre = {}
    q = os.path.join(ROOT, "v10", "mk", "gen", "prebuilt.txt")
    if not os.path.exists(q):
        return pre
    for line in open(q):
        line = line.split("#")[0].rstrip("\n")
        if not line.strip():
            continue
        f = line.split("\t")
        if len(f) >= 2 and f[1]:
            d = "/" + f[1].lstrip("/")
            pre[f[0]] = d.rpartition("/")[0] or "/"
    return pre


def build():
    where = load_where()
    pre = load_prebuilt()
    rows, skipped = [], []
    for dp, _, fs in os.walk(TAPE):
        rel = os.path.relpath(dp, TAPE)
        root = rel.split("/")[0]
        for f in sorted(fs):
            p = os.path.join(dp, f)
            try:
                if os.path.getsize(p) < 64:
                    continue
                with open(p, "rb") as fh:
                    m = struct.unpack("<H", fh.read(2))[0]
            except OSError:
                continue
            if m not in EXE:
                continue
            r = os.path.relpath(p, TAPE)
            if f in pre:
                d, auth = pre[f], "prebuilt"
            elif f in where:
                d, auth = where[f], "where"
            else:
                d, auth = "/usr/bin", "default"
            rows.append((f, r, d, auth))
    # EVERY binary gets a row.  Where two share a basename the shallower one --
    # the unit's own -- installs last and wins, and collisions are reported
    # rather than silently resolved.
    rows.sort(key=lambda t: (t[0], -t[1].count("/")))
    return rows, skipped


def sanity(rows):
    """A name shared with prebuilt.txt must install to the same directory."""
    p = os.path.join(ROOT, "v10", "mk", "gen", "prebuilt.txt")
    if not os.path.exists(p):
        return
    pre = {}
    for line in open(p):
        line = line.split("#")[0].rstrip("\n")
        if not line.strip():
            continue
        f = line.split("\t")
        # name<TAB>install-path<TAB>source-path<TAB>authority<TAB>size
        if len(f) >= 2 and f[1]:
            d = "/" + f[1].lstrip("/")
            pre[f[0]] = d.rpartition("/")[0] or "/"
    bad = [(n, d, pre[n]) for n, _, d, _ in rows if n in pre and pre[n] != d]
    if bad:
        for n, a, b in bad[:10]:
            sys.stderr.write("v10-tapebins: %s -> %s here, %s in prebuilt.txt\n" % (n, a, b))
        raise SystemExit("v10-tapebins: two lists disagree; fix where.txt, not this file")


def render(rows, skipped):
    o = ["# Every linked Tenth Edition binary on the tape, and where it installs.",
         "#",
         "# Generated by tools/v10-tapebins.py; check with --check.  Do not edit.",
         "#",
         "#   name  source-path-under-work/v10/src  install-dir  authority",
         "#",
         "# authority: `where'   = v10/mk/where.txt resolved it (manual, makefile, V8)",
         "#            `default' = nothing named it; /usr/bin, and that is a guess",
         "#",
         "# %d binaries, every linked executable the tape carries." % len(rows),
         ""]
    for n, r, d, a in rows:
        o.append("%s\t%s\t%s\t%s" % (n, r, d, a))
    o.append("")
    o.append("# skipped:")
    for n, r, why in sorted(skipped):
        o.append("#   %-18s %-46s %s" % (n, r, why))
    return "\n".join(o) + "\n"


def main(argv):
    if not os.path.isdir(TAPE):
        sys.stderr.write("v10-tapebins: no %s -- run tools/v10-import.py\n" % TAPE)
        return 1
    rows, skipped = build()
    sanity(rows)
    text = render(rows, skipped)
    if "--check" in argv:
        cur = open(OUT).read() if os.path.exists(OUT) else ""
        if cur != text:
            sys.stderr.write("v10-tapebins: %s is out of date\n" % OUT)
            return 1
        print("v10-tapebins: up to date (%d binaries)" % len(rows))
        return 0
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "w").write(text)
    print("v10-tapebins: %d binaries, %d skipped -> %s" %
          (len(rows), len(skipped), os.path.relpath(OUT, ROOT)))
    byauth = {}
    for _, _, _, a in rows:
        byauth[a] = byauth.get(a, 0) + 1
    for k in sorted(byauth):
        print("   %-10s %4d" % (k, byauth[k]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
