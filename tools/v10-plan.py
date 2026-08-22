#!/usr/bin/env python3
"""The file-by-file plan for a Tenth Edition golden image.

	tools/v10-plan.py [--check]

Writes docs/v10-plan.md (to read) and v10/mk/gen/plan.txt (to build from).
Every path that will exist on the image gets a row saying WHERE IT COMES FROM
and HOW IT GETS THERE.  There is no `inherit' method and there never will be:
a file whose only source is the machine that built the image is a build
failure, and tools/v10-manifest.py fails the build on one.

WHICH ROOT SUPPLIES WHAT.  v10/source holds six archives, never merged, and
only some of them build.  Each decision is stated with its reason, because
"we only ever used this one" is not a reason:

	v10 (src)   BUILD.  Dan Cross's v10src -- the tree stages 1-3 are
	            already proven against, and the one our 49 patches are
	            written for.
	milligan    BUILD into /usr/jerq.  The 5620 distribution: jerq/sgs is
	            the cross-compiler (3cc), jerq/src/lib the WE32100
	            libraries, jerq/src/mux muxterm.  This is what rung 8 was
	            blocked on and it closes the terminal half.
	include     INSTALL to /usr/include.  r70's reconstruction, already
	            the measured default for V10 source.
	sellers     INSTALL to /usr/man and /usr/src/vol2.  The manuals.
	secombe     WITNESS, not built.  A second /usr/src from a different
	            machine: where our bytes differ from src's, secombe is a
	            third opinion -- the same role the 46 prebuilt binaries
	            play.  Building it would mean choosing one file per path
	            and calling the result "the tape".
	blit        PARKED.  The 68000 Blit, not the 5620 dmd_core emulates.
	ix          PARKED.  A different operating system built on V10.
	630         PARKED.  The 630 MTG, a different terminal.

A PARKED ROOT IS STILL EXTRACTED AND STILL SURVEYED.  Parking is a statement
about what the image carries, not about what the repository knows.
"""

import argparse
import collections
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(ROOT, "v10", "mk", "gen")
TREE = os.path.join(ROOT, "v10", "source")

BUILD_ROOTS = {"v10": "src", "milligan": "milligan"}
PARKED = {"secombe": "a second /usr/src -- a WITNESS, not a build source",
          "blit": "the 68000 Blit, not the 5620 this project emulates",
          "ix": "a different operating system, built on V10",
          "630": "the 630 MTG, a different terminal"}


def rows(name):
    p = os.path.join(GEN, name)
    if not os.path.exists(p):
        return []
    out = []
    for line in open(p):
        if line.startswith("#") or not line.strip():
            continue
        # THE GENERATED FILES ARE NOT ALL TAB-SEPARATED.  libs.txt is
        # space-separated and a blind split("\t") gives it ONE field, so a
        # `len(r) >= 4' guard drops all 27 libraries in silence -- the plan
        # printed no stage 4 at all and read like a design decision.
        line = line.rstrip("\n")
        out.append(line.split("\t") if "\t" in line else line.split())
    return out


def plan():
    """[(installed path, method, source, stage, note)] -- the whole image."""
    out = []

    # ---- stage 1: the toolchain, built first and used by everything after
    for r in rows("tc.order"):
        if len(r) >= 3:
            out.append(("/" + r[2], "build", "src/" + r[1], "1",
                        "the toolchain; stage 3 rebuilds it on the new libc"))

    # ---- stage 2: libc, compiled by stage 1's passes into the new image
    out.append(("/lib/libc.a", "build", "src/libc", "2",
                "%d members in the tape's own archive order (libc.ord); "
                "setupshares is a named exclusion" % len(rows("libc.ord"))))

    # ---- stage 4: the other libraries
    for r in rows("libs.txt"):
        if len(r) >= 4:
            out.append(("/usr/lib/" + r[3], "build", "src/" + r[1], "4",
                        "%s members" % (r[4] if len(r) > 4 else "?")))

    # ---- stage 5: every program the survey found, in the roots we build
    prog = rows("world.prog")
    for r in prog:
        if len(r) < 8:
            continue
        name, d, inst, libs, objs, how, cflags, tree = r[:8]
        if tree not in BUILD_ROOTS:
            continue
        st = "5" if tree == "v10" else "6"
        note = how if libs in ("-", "") else "%s, %s" % (how, libs)
        out.append((inst.rstrip("/") + "/" + name, "build", d, st, note))

    # ---- stage 7: the device nodes, from the generated table
    for r in rows("proto-dev"):
        if len(r) >= 5:
            out.append(("/dev/" + r[0], "mknod", "v10/mk/gen/proto-dev", "7",
                        "%s major %s minor %s mode %s" % (r[1], r[2], r[3], r[4])))

    # ---- stage 7: /etc, from OUR source, never captured off the builder
    for r in rows("proto-etc"):
        if len(r) >= 3:
            out.append(("/etc/" + r[0], "copy", "v10/src/etc/" + r[0], "7",
                        "mode %s -- %s" % (r[1], r[2])))

    # ---- stage 7: the headers
    inc = os.path.join(TREE, "include")
    if os.path.isdir(inc):
        n = sum(len(f) for _, _, f in os.walk(inc))
        out.append(("/usr/include/**", "tree", "include/", "7",
                    "%d files -- r70's reconstruction, the measured default "
                    "for V10 source" % n))

    # ---- stage 8: the manuals
    sel = os.path.join(TREE, "sellers")
    if os.path.isdir(sel):
        for sub, dest in (("man", "/usr/man"), ("vol2", "/usr/src/vol2")):
            d = os.path.join(sel, sub)
            if os.path.isdir(d):
                n = sum(len(f) for _, _, f in os.walk(d))
                out.append((dest + "/**", "tree", "sellers/" + sub, "8",
                            "%d files" % n))
    return out


MD_HEAD = """# The Tenth Edition golden image, file by file

Generated by `tools/v10-plan.py` from the survey in `v10/mk/gen/`. Do not
edit; change the survey or the generator.

## The three rules

1. **The source contains everything.** `v10/source` — the six V10 archives
   extracted file by file, with our 49 patches applied on top — is the only
   input. Not the builder's filesystem, not the Eighth Edition, not a previous
   golden, not a file a harness types in.
2. **No staging tree.** `$(DESTDIR)` is the new image, mounted, for the whole
   run. The generated makefiles were written for this: `init.mk` says
   `cp init $(DESTDIR)/etc/init`.
3. **The new toolchain runs on the new image.** After stage 1 the passes are
   on the image and stage 2 compiles with `cc -B$MNT/lib/`. By stage 3 the
   image compiles itself. The builder supplies a running kernel and nothing
   else.

**There is no `inherit` method in this plan and there never will be.** A file
whose only source is the machine that built the image is a build failure, and
`tools/v10-manifest.py` fails the build on one.

## Which archive supplies what

| root | files | role |
|---|---:|---|
"""


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args(argv)

    p = plan()
    p.sort(key=lambda r: (r[3], r[0]))

    txt = os.path.join(GEN, "plan.txt")
    md = os.path.join(ROOT, "docs", "v10-plan.md")
    body = "# path\tmethod\tsource\tstage\tnote\n"
    body += "".join("\t".join(r) + "\n" for r in p)

    if a.check:
        if not os.path.exists(txt) or open(txt).read() != body:
            print("v10-plan: v10/mk/gen/plan.txt is stale")
            return 1
        print("v10-plan: current (%d paths)" % len(p))
        return 0

    open(txt, "w").write(body)

    # the markdown
    counts = {}
    for r in ("src", "blit", "include", "secombe", "milligan", "sellers"):
        d = os.path.join(TREE, r)
        counts[r] = sum(len(f) for _, _, f in os.walk(d)) if os.path.isdir(d) else 0
    out = [MD_HEAD]
    role = {"src": "**BUILD.** Dan Cross's `v10src` — the tree stages 1–3 are "
                   "proven against and our 49 patches are written for.",
            "milligan": "**BUILD into `/usr/jerq`.** The 5620 distribution: "
                        "`jerq/sgs` is the cross-compiler (`3cc`), "
                        "`jerq/src/lib` the WE32100 libraries, "
                        "`jerq/src/mux` muxterm. Closes rung 8.",
            "include": "**INSTALL to `/usr/include`.** r70's reconstruction.",
            "sellers": "**INSTALL to `/usr/man`, `/usr/src/vol2`.** The manuals.",
            "secombe": "**WITNESS, not built.** A second `/usr/src` from a "
                       "different machine — a third opinion where our bytes "
                       "differ, the role the 46 prebuilt binaries play.",
            "blit": "**PARKED.** The 68000 Blit, not the 5620 `dmd_core` "
                    "emulates."}
    for r in ("src", "milligan", "include", "sellers", "secombe", "blit"):
        out.append("| `%s` | %s | %s |\n" % (r, format(counts[r], ","), role[r]))
    out.append("\n`src/history` (ix, 882 files) and `src/630` (1,098) are "
               "parked inside `src`: a different operating system and a "
               "different terminal. **A parked root is still extracted and "
               "still surveyed** — parking says what the image carries, not "
               "what the repository knows.\n")

    bystage = collections.OrderedDict()
    for r in p:
        bystage.setdefault(r[3], []).append(r)
    names = {"1": "Stage 1 — the toolchain",
             "2": "Stage 2 — libc",
             "4": "Stage 4 — the other libraries",
             "5": "Stage 5 — the commands",
             "6": "Stage 6 — /usr/jerq, the 5620",
             "7": "Stage 7 — /dev, /etc, /usr/include",
             "8": "Stage 8 — the manuals"}
    out.append("\n## What lands on the image: %s paths\n\n" % format(len(p), ","))
    out.append("| stage | paths |\n|---|---:|\n")
    for k in sorted(bystage):
        out.append("| %s | %s |\n" % (names.get(k, k), format(len(bystage[k]), ",")))

    for k in sorted(bystage):
        rs = bystage[k]
        out.append("\n## %s\n\n%s paths.\n\n" % (names.get(k, k),
                                                 format(len(rs), ",")))
        out.append("| installed path | method | source | note |\n|---|---|---|---|\n")
        for path, method, src, _, note in rs:
            out.append("| `%s` | %s | `%s` | %s |\n"
                       % (path, method, src, note.replace("|", "\\|")))
    open(md, "w").write("".join(out))

    print("v10-plan: %d paths -> docs/v10-plan.md, v10/mk/gen/plan.txt" % len(p))
    for k in sorted(bystage):
        print("   %-34s %5d" % (names.get(k, k), len(bystage[k])))
    meth = collections.Counter(r[1] for r in p)
    print("   methods: %s" % ", ".join("%s %d" % kv for kv in meth.most_common()))
    assert "inherit" not in meth, "there is no inherit method"
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
