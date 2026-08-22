#!/usr/bin/env python3
"""Can the golden image be built from what is in the repository?

	tools/v10-scan.py [--verbose] [--only PHASE]

Four questions, each answered by reading v10/source rather than by recalling
what was there.  A phase that cannot answer says so; a phase that finds
nothing wrong prints the number it checked, because "no output" and "nothing
checked" look identical otherwise.

	1  EXTRACT     is every member of every archive present?
	2  INPUTS      does every thing the plan builds have its sources?
	3  HEADERS     does every #include resolve, transitively?
	4  5620        can the terminal be built from V10's OWN jerq tree
	               (milligan) instead of IX's?

WHY 4 IS A QUESTION AT ALL.  mux and 32ld are currently built from
src/history/ix -- a DIFFERENT operating system -- with 26 counted
substitutions in v10/src to excise the IX-specific parts.  milligan/jerq is
V10's own 5620 distribution, so the excision may be unnecessary.  The scan
compares the two trees file by file rather than assuming either way.

SCAN FOR `^[ \\t]*#[ \\t]*include', NEVER `#include'.  V10's cpp.c opens with
`# include <libc.h>' -- a space after the hash, ordinary 1970s style and
common in that tree.  A scan that missed it once declared every header
present and cost a whole boot.
"""

import argparse
import collections
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")
GEN = os.path.join(ROOT, "v10", "mk", "gen")
WORK = os.path.join(ROOT, "work")

INC = re.compile(r"^[ \t]*#[ \t]*include[ \t]*([<\"])([^>\"]+)[>\"]", re.M)
SYSINC = os.path.join(TREE, "include")

ARCHIVES = [("v10src.tar.bz2", "src", 0), ("v10blit.tar.bz2", "blit", 1),
            ("r70include.tar", "include", 1), ("v10-secombe.gz", "secombe", 1),
            ("v10-milligan.gz", "milligan", 1), ("v10-sellers.gz", "sellers", 1)]


def rows(name, gen=GEN):
    p = os.path.join(gen, name)
    if not os.path.exists(p):
        return []
    out = []
    for line in open(p):
        if line.startswith("#") or not line.strip():
            continue
        line = line.rstrip("\n")
        out.append(line.split("\t") if "\t" in line else line.split())
    return out


def unesc(n):
    out, i = [], 0
    m = {"b": "\b", "t": "\t", "n": "\n", "r": "\r", "f": "\f", "v": "\v",
         "\\": "\\"}
    while i < len(n):
        if n[i] == "\\" and i + 1 < len(n):
            if n[i + 1] in m:
                out.append(m[n[i + 1]]); i += 2; continue
            if n[i + 1:i + 4].isdigit():
                out.append(chr(int(n[i + 1:i + 4], 8))); i += 4; continue
        out.append(n[i]); i += 1
    return "".join(out)


# ---------------------------------------------------------- 1  EXTRACT ---

def phase_extract(v):
    """Every regular member of every archive, present as a file."""
    if not all(os.path.exists(os.path.join(WORK, a)) for a, _, _ in ARCHIVES):
        return None, ["work/ does not hold all six archives -- cannot check"]
    want = set()
    for tb, sub, strip in ARCHIVES:
        out = subprocess.run(["tar", "-tvf", os.path.join(WORK, tb)],
                             capture_output=True, text=True).stdout
        for line in out.splitlines():
            if not line.startswith("-"):
                continue
            n = unesc(line.split(None, 8)[-1].split(" link to ")[0])
            parts = n.split("/")[strip:]
            while parts and parts[0] in ("", "."):
                parts = parts[1:]
            if parts:
                want.add(os.path.join(sub, "/".join(parts)))
    have = set()
    for d, _, fs in os.walk(TREE):
        have.add(os.path.relpath(d, TREE))
        for f in fs:
            have.add(os.path.relpath(os.path.join(d, f), TREE))
    stored = {}
    cm = os.path.join(TREE, "CASEMAP")
    if os.path.exists(cm):
        for line in open(cm):
            if not line.startswith("#"):
                t, tr = line.rstrip("\n").split("\t")
                stored[tr] = t
    missing = sorted(p for p in want if p not in have and stored.get(p, p) not in have)
    return len(want), ["MISSING %s" % m for m in missing]


# ----------------------------------------------------------- 2  INPUTS ---

RULE = re.compile(r"^([^\s:=#][^:=]*):([^=].*|)$", re.M)


def rule_names_source(unitdir, obj):
    """Does the unit's build file build `obj' from a source it has?"""
    for bf in ("makefile", "Makefile", "mkfile", "MAKEFILE"):
        p = os.path.join(unitdir, bf)
        if not os.path.isfile(p):
            continue
        try:
            text = open(p, errors="replace").read().replace("\\\n", " ")
        except OSError:
            continue
        lines = text.splitlines()
        for i, line in enumerate(lines):
            m = RULE.match(line)
            if not m or obj not in m.group(1).split():
                continue
            toks = m.group(2).split()
            for j in range(i + 1, len(lines)):
                if lines[j][:1] not in ("\t", " ") or not lines[j].strip():
                    break
                toks += lines[j].split()
            for t in toks:
                t = t.strip("()$;\"'")
                if t.endswith((".c", ".y", ".l", ".s")) and \
                   os.path.exists(os.path.join(unitdir, t)):
                    return True
    return False


def phase_inputs(v):
    """Does every thing the plan builds have its sources on disk?"""
    bad, checked = [], 0

    # the toolchain
    for r in rows("tc.order"):
        checked += 1
        d = os.path.join(TREE, "src", r[1])
        if not os.path.isdir(d):
            bad.append("stage 1 %s: no %s" % (r[0], "src/" + r[1]))
        elif not any(f.endswith((".c", ".y", ".l")) for f in os.listdir(d)):
            bad.append("stage 1 %s: %s holds no source" % (r[0], r[1]))
        mk = os.path.join(GEN, r[0] + ".mk")
        if not os.path.exists(mk):
            bad.append("stage 1 %s: no generated makefile %s.mk" % (r[0], r[0]))

    # libc: every member of libc.ord must have a source
    src = {}
    for r in rows("libc.src"):
        if len(r) >= 2:
            src[r[0]] = r[1]
    drop = {r[0] for r in rows("libc.drop")}
    for r in rows("libc.ord"):
        obj = r[0]
        checked += 1
        if obj in drop:
            continue
        s = src.get(obj)
        if not s:
            bad.append("libc %s: no source row in libc.src" % obj)
            continue
        # libc.src's paths are relative to libc/, not to src/.
        if not os.path.exists(os.path.join(TREE, "src", "libc", s)):
            bad.append("libc %s: source libc/%s absent" % (obj, s))

    # the other libraries
    for r in rows("libs.txt"):
        if len(r) < 4:
            continue
        checked += 1
        d = os.path.join(TREE, "src", r[1])
        if not os.path.isdir(d):
            bad.append("lib %s: no src/%s" % (r[3], r[1]))

    # the commands: every object named must have a source beside it
    for r in rows("world.prog"):
        if len(r) < 8 or r[7] not in ("v10", "milligan"):
            continue
        name, d, inst, libs, objs, how, cflags, tree = r[:8]
        checked += 1
        base = os.path.join(TREE, d)
        if not os.path.isdir(base):
            bad.append("prog %s: no %s" % (name, d))
            continue
        if objs == "-":
            continue
        # A UNIT'S OBJECTS NEED NOT COME FROM ITS OWN DIRECTORY.
        # src/cmd/ccom/vax builds cgram.o from ../common/cgram.y, and the
        # tape does this wherever a program has a machine-independent half.
        # So search the unit, then its parent's whole subtree -- and skip an
        # object named by ABSOLUTE path (/lib/crt0.o is the C runtime, not a
        # source of ours).
        parent = os.path.dirname(base.rstrip("/"))
        for o in objs.split():
            if not o.endswith(".o") or o.startswith("/") or "*" in o:
                continue        # `*.o' in a link line is a glob, not a name
            if os.path.basename(o).startswith("."):
                continue        # .dep.o and friends are make's own artefacts
            stem = os.path.basename(o)[:-2]
            if stem in ("y.tab", "lex.yy"):     # a generator's own output
                continue
            # .e IS EFL AND .f IS FORTRAN, and both are compiled by this
            # tape: cmd/view2d builds co.o from co.e and Tri/box.o from
            # box.f.  A suffix list that stops at C reports those as missing
            # source when the source is sitting there.
            SUF = (".c", ".y", ".l", ".s", ".g", ".lex", ".S", ".e", ".f",
                   ".r", ".w")
            if any(os.path.exists(os.path.join(base, stem + e)) for e in SUF):
                continue
            hit = False
            for dp, _, fs in os.walk(parent):
                if any(stem + e in fs for e in SUF):
                    hit = True
                    break
            # AN OBJECT NEED NOT BE NAMED AFTER ITS SOURCE.  cmd/compat's
            # makefile builds v7run.o, v6run.o and rtrun.o from ONE file:
            #   v7run.o: defs.h unixhdr.h runcompat.c
            #           cc -c -O -DV7UNIX -DUNIX runcompat.c
            #           mv runcompat.o v7run.o
            # -- three objects, three sets of -D flags, one runcompat.c.  So
            # the unit's own rule for the object is the authority, and the
            # -D flags it carries are information the build needs, not noise.
            if not hit:
                hit = rule_names_source(base, o)
            if not hit:
                bad.append("prog %s (%s): object %s has no source"
                           % (name, d, o))
    return checked, bad


# ---------------------------------------------------------- 3  HEADERS ---

def build_index():
    """{basename: [paths]} for every header in the tree, once."""
    idx = collections.defaultdict(list)
    for d, _, fs in os.walk(TREE):
        for f in fs:
            idx[f].append(os.path.join(d, f))
    return idx


def resolve(name, kind, unitdir, idx, extra):
    """Where would cpp find this include?  None if nowhere."""
    if kind == '"':
        p = os.path.join(unitdir, name)
        if os.path.exists(p):
            return p
    p = os.path.join(SYSINC, name)
    if os.path.exists(p):
        return p
    for e in extra:
        p = os.path.join(e, name)
        if os.path.exists(p):
            return p
    if kind == '"':                     # last resort: same dir, again
        p = os.path.join(unitdir, name)
        if os.path.exists(p):
            return p
    return None


def closure(start, idx, extra, seen):
    """Follow every include transitively; return unresolved names."""
    bad, stack = [], [start]
    while stack:
        p = stack.pop()
        if p in seen:
            continue
        seen.add(p)
        try:
            text = open(p, errors="replace").read()
        except OSError:
            continue
        d = os.path.dirname(p)
        for kind, name in INC.findall(text):
            if name.startswith("/"):
                # AN ABSOLUTE INCLUDE NAMES A PATH THE BUILD CREATES.  Five
                # programs write #include "/usr/jerq/include/jioctl.h", and
                # the build installs milligan/jerq/include there -- so the
                # header is present at compile time and reporting it missing
                # is the same error as measuring /usr/include without
                # inc.extra.
                q = None
                for pre, real in (("/usr/jerq/include/",
                                   "milligan/jerq/include"),
                                  ("/usr/include/", "include")):
                    if name.startswith(pre):
                        q = os.path.join(TREE, real, name[len(pre):])
                        break
                if q is None:
                    q = os.path.join(TREE, name.lstrip("/"))
                if os.path.exists(q):
                    stack.append(q)
                else:
                    bad.append((p, name, "absolute"))
                continue
            q = resolve(name, kind, d, idx, extra)
            if q is None:
                bad.append((p, name, kind))
            else:
                stack.append(q)
    return bad


def inc_extra():
    """{header: source} that the build installs into /usr/include first.

    THE SCAN MUST HONOUR THIS OR IT MEASURES THE WRONG MACHINE.  inc.extra
    is applied by every harness before anything compiles, so a header listed
    there is present at compile time -- reporting it as blocking is the same
    error as the app's "it is in the golden, it will arrive on Reset".
    """
    out = {}
    for r in rows("inc.extra"):
        if len(r) >= 3:
            out[r[0]] = r[2]
    return out


def blocked(idx=None, apply_extra=True):
    """{program: (unit, [headers it cannot resolve])} for the planned build.

    THE DATA.  phase_headers displays this; tools/v10-headers.py consumes it.
    One statement, two consumers -- a list that appears twice will disagree,
    and an assertion comparing a list with itself is not an assertion.
    """
    idx = idx or build_index()
    jerq = os.path.join(TREE, "milligan", "jerq", "include")
    # apply_extra=False FOR THE GENERATOR.  tools/v10-headers.py both reads
    # this and writes inc.extra, so subtracting inc.extra here would make each
    # run drop whatever the previous run added -- the list erased itself, and
    # stdlib.h and stddef.h vanished from a file that had just installed them.
    have = set(inc_extra()) if apply_extra else set()
    out = {}
    for r in rows("world.prog"):
        if len(r) < 8 or r[7] not in ("v10", "milligan"):
            continue
        name, d, objs, how = r[0], r[1], r[4], r[5]
        base = os.path.join(TREE, d)
        # THE UNIT'S OWN SUBTREE IS ON -I, because the tape compiles in-tree:
        # cmd/bas wants "bas.h" and cmd/vi "retrofit.h", each beside a source
        # one directory over.  Without this they read as missing system
        # headers, which is what put dev.h, libv.h, tokens.h and trace.h into
        # a list of things to install into /usr/include.
        extra = [base, os.path.dirname(base.rstrip("/"))]
        if d.startswith("milligan/"):
            extra += [jerq, os.path.join(base, "proto")]
        SUF = (".c", ".y", ".l", ".s", ".e", ".f")
        stems = [os.path.basename(o)[:-2] for o in objs.split()
                 if o.endswith(".o") and not o.startswith("/") and "*" not in o]
        if not stems or how == "Admin/Mk":
            stems = [name]
        mine = []
        for st in stems:
            for e in SUF:
                q = os.path.join(base, st + e)
                if os.path.exists(q):
                    mine.append(q)
                    break
        miss = set()
        for p in mine:
            for _, nm, _k in closure(p, idx, extra, set()):
                # `#include "*** Must define PD_MACH ***"' is the tape's
                # poor-man's #error, not a header.
                if "*" in nm or " " in nm:
                    continue
                miss.add(nm)
        miss -= {"y.tab.h", "y.debug", "lex.yy.c"}
        miss -= have
        if miss:
            out[name] = (d, sorted(miss))
    return out


def phase_headers(v):
    """Which of the PROGRAMS THE PLAN BUILDS cannot resolve their headers?

    Not "which files have an unresolvable include" -- that counts cfront,
    gcc, icon, sml and worm, none of which the plan builds, and buries the
    answer.  The question is per PROGRAM: can this one compile?

    THE SEARCH PATH IS THE TAPE'S, NOT THE TREE'S.  A header is looked for in
    the unit's own directory (quoted includes), then /usr/include -- which is
    r70's reconstruction -- and, for milligan, /usr/jerq/include.  It is NOT
    looked for "anywhere in v10/source": cmd/lcc/include/sparc_sun/stdlib.h
    is a SUN header and resolving to it would report a program as buildable
    that cannot be built.  CLAUDE.md records that exact trap costing three
    optimistic measurements in a row.
    """
    total = sum(1 for r in rows("world.prog")
                if len(r) >= 8 and r[7] in ("v10", "milligan"))
    bad = blocked()
    why = collections.Counter()
    for _, (d, miss) in bad.items():
        for m in miss:
            why[m] += 1
    out = ["programs the plan builds: %d" % total,
           "   compile-ready              %d" % (total - len(bad)),
           "   blocked on a header        %d" % len(bad),
           "   (%d headers are installed first, from inc.extra)" % len(inc_extra()),
           "",
           "the headers that block them, most first:"]
    for nm, n in why.most_common():
        out.append("   %-26s %4d programs" % (nm, n))
    out.append("")
    out.append("blocked programs:")
    for name, (d, miss) in sorted(bad.items()):
        out.append("   %-16s %-34s %s" % (name, d, " ".join(miss[:4])))
    return total, out


# ------------------------------------------------------------- 4  5620 ---

def phase_5620(v):
    """Can the 5620 be built from V10's own jerq tree instead of IX's?"""
    out = []
    mil = os.path.join(TREE, "milligan", "jerq")
    ix = os.path.join(TREE, "src", "history", "ix", "src", "jerq")
    if not os.path.isdir(mil):
        return None, ["milligan/jerq absent"]

    need = {
        "the cross-compiler driver": "sgs/3cc.c",
        "the assembler":             "sgs/as",
        "the linker":                "sgs/ld",
        "the loader (host side)":    "sgs/32reloc.c",
        "mux, the host half":        "src/mux/mux.c",
        "muxterm, the terminal":     "src/mux/term/makefile",
        "the layer library":         "src/lib/layer",
        "the WE32100 libc":          "src/lib/c",
        "the jerq library":          "src/lib/j",
        "the protocol headers":      "include/mux.h",
    }
    for what, rel in sorted(need.items()):
        p = os.path.join(mil, rel)
        out.append("%-28s %-26s %s" % (what, rel,
                                       "present" if os.path.exists(p) else "ABSENT"))

    # the comparison that decides whether IX is still needed
    out.append("")
    out.append("V10's own jerq vs the IX tree currently used:")
    for rel in ("mux/mux.c", "32ld/32ld.c"):
        a = os.path.join(mil, "src", rel)
        b = os.path.join(ix, rel.replace("32ld/32ld.c", "mux/32ld.c"))
        la = len(open(a, errors="replace").read().splitlines()) if os.path.exists(a) else 0
        lb = len(open(b, errors="replace").read().splitlines()) if os.path.exists(b) else 0
        same = ""
        if la and lb:
            same = "identical" if open(a, "rb").read() == open(b, "rb").read() \
                   else "differ"
        out.append("   %-14s milligan %5s lines   ix %5s lines   %s"
                   % (rel, la or "-", lb or "-", same))

    # CAN THEY BE BUILT?  The include path is the makefile's own:
    # `INCL = $(PDIR)' and `CFLAGS = -g -I$(INCL) -I$(JINCL)', so mux compiles
    # against mux/proto and /usr/jerq/include.  32ld lives in its OWN
    # directory (src/32ld), not under mux/ -- which is why a scan looking for
    # src/mux/32ld.c reported it absent from a tree that has it.
    idx = build_index()
    out.append("")
    out.append("can V10's own copies compile?  (include path = the makefile's)")
    for rel, extra in (("src/mux/mux.c", ["src/mux/proto", "include"]),
                       ("src/32ld/32ld.c", ["src/32ld", "include"])):
        p = os.path.join(mil, rel)
        if not os.path.exists(p):
            out.append("   %-18s ABSENT" % os.path.basename(rel))
            continue
        miss = closure(p, idx, [os.path.join(mil, e) for e in extra], set())
        names = sorted({m[1] for m in miss})
        out.append("   %-18s %s" % (os.path.basename(rel),
                                    "every include resolves" if not names
                                    else "unresolved: " + " ".join(names)))
    return len(need), out


# ---------------------------------------------------------- 5  SECOMBE ---

def phase_secombe(v):
    """src and secombe are both /usr/src.  Where do they differ?

    NOT AN ACADEMIC COMPARISON.  src/cmd/compat is missing unixhdr.h,
    unixstart.c and unixtraps.c -- without which v6run, v7run, rtrun and
    their tracing variants cannot link -- and secombe has all three.  Dan
    Cross's tree lost files Norman's kept, so secombe is a FALLBACK SOURCE
    and not only a second opinion.

    The reverse holds too, which is why neither tree can simply replace the
    other and why they are extracted separately.
    """
    import hashlib
    def index(root):
        out = {}
        base = os.path.join(TREE, root)
        for d, _, fs in os.walk(base):
            for f in fs:
                p = os.path.join(d, f)
                out[os.path.relpath(p, base)] = p
        return out
    A, B = index("src"), index("secombe")
    onlyA = sorted(set(A) - set(B))
    onlyB = sorted(set(B) - set(A))
    both = sorted(set(A) & set(B))

    same = differ = 0
    diffs = []
    for r in both:
        try:
            ha = hashlib.sha256(open(A[r], "rb").read()).digest()
            hb = hashlib.sha256(open(B[r], "rb").read()).digest()
        except OSError:
            continue
        if ha == hb:
            same += 1
        else:
            differ += 1
            diffs.append(r)

    out = ["src        %6d files" % len(A),
           "secombe    %6d files" % len(B),
           "",
           "in both    %6d  of which identical %d, DIFFERENT %d"
           % (len(both), same, differ),
           "only in src      %6d" % len(onlyA),
           "only in secombe  %6d   <- files Dan Cross's tree does not have"
           % len(onlyB),
           ""]

    # what secombe adds, by top-level directory -- the actionable half
    bydir = collections.Counter(r.split("/")[0] for r in onlyB)
    out.append("what ONLY secombe has, by directory:")
    for k, n in bydir.most_common(12):
        out.append("   %-16s %5d" % (k, n))

    # the ones that unblock a build: sources for a unit src also has
    unblock = []
    for r in onlyB:
        if not r.endswith((".c", ".h", ".s", ".y", ".l")):
            continue
        d = os.path.dirname(r)
        if d and os.path.isdir(os.path.join(TREE, "src", d)):
            unblock.append(r)
    out.append("")
    out.append("SOURCE files secombe has in a directory src ALSO has: %d"
               % len(unblock))
    for r in unblock[:20]:
        out.append("   %s" % r)
    if len(unblock) > 20:
        out.append("   ... and %d more" % (len(unblock) - 20))

    # CLASSIFY THE DIFFERENCES.  A flat list of 162 is dominated by two
    # things that are not disagreements about the tape at all: OUR patches
    # (applied to src, not to secombe) and OBJECTS inside unpacked archives,
    # which differ because they were compiled on different days.  What is
    # left is where the two machines genuinely held different source.
    ours = set()
    ov = os.path.join(TREE, "OVERLAY")
    if os.path.exists(ov):
        for line in open(ov):
            f = line.split("\t")
            if len(f) >= 2 and f[1].startswith("src/"):
                ours.add(f[1][4:])
    mine = [r for r in diffs if r in ours]
    objs = [r for r in diffs if r not in ours and
            (r.endswith((".o", ".x", ".O")) or ".a/" in r)]
    real = [r for r in diffs if r not in ours and r not in set(objs)]
    out.append("")
    out.append("the %d differences, classified:" % differ)
    out.append("   OUR patches (applied to src, not secombe)   %4d" % len(mine))
    out.append("   objects inside unpacked archives            %4d" % len(objs))
    out.append("   GENUINE source differences                  %4d" % len(real))
    for r in real[:30]:
        out.append("      %s" % r)
    if len(real) > 30:
        out.append("      ... and %d more" % (len(real) - 30))
    return len(both) + len(onlyA) + len(onlyB), out


PHASES = [("extract", phase_extract, "every archive member present"),
          ("secombe", phase_secombe, "src vs secombe: differences and extras"),
          ("inputs", phase_inputs, "every build target has its sources"),
          ("headers", phase_headers, "every #include resolves, transitively"),
          ("5620", phase_5620, "V10's own jerq instead of IX's")]


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--only")
    a = ap.parse_args(argv)
    rc = 0
    for name, fn, what in PHASES:
        if a.only and a.only != name:
            continue
        print("=== %s -- %s ===" % (name, what))
        n, out = fn(a.verbose)
        if n is None:
            print("   COULD NOT CHECK"); rc = 1
        else:
            print("   checked %s" % format(n, ","))
        limit = len(out) if a.verbose else 25
        for line in out[:limit]:
            print("   %s" % line)
        if len(out) > limit:
            print("   ... and %d more (--verbose)" % (len(out) - limit))
        if name in ("extract", "inputs") and out:
            rc = 1
        print()
    return rc


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
