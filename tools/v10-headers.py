#!/usr/bin/env python3
"""Which headers must be installed into /usr/include, and from where?

	tools/v10-headers.py [--check] [--verbose]

Writes v10/mk/gen/inc.extra.  r70's /usr/include keeps several headers ONLY
inside a compiler's variant directory -- include/lcc, include/CC, include/olcc,
include/oCC -- and the job is to pick the variant pcc2 can actually read.  That
is a SYSTEM-LAYOUT decision, not a source patch: the tape holds four copies of
stdlib.h and the question is which one belongs at /usr/include.

THE TEST IS MECHANICAL, AND IT REPRODUCES EVERY CHOICE STAGE 2 MADE BY HAND --
including the one no obvious rule should have caught.  lcc/stdarg.h is pure
#defines and parses perfectly, but its macro says

	_littleendian_va_arg(list, mode, 3U)

and pcc2 lexes `3U' as 3 followed by the identifier U.  The header compiles;
the EXPANSION fails hundreds of lines away.  CC/stdarg.h is the one installed,
and a hand-maintained table said lcc's for a week.

THE SEARCH IS RESTRICTED BY PROVENANCE, because resolving "anywhere in the
tree" is how three optimistic measurements in a row were produced:

	allowed   include/            r70's own /usr/include and its variants
	          src/sys src/lsys    V10's own kernel headers
	          milligan/jerq       the 5620's, for /usr/jerq/include only
	REFUSED   sparc_sun sgi       another machine's
	          cfront/libC         C++
	          blit/ 630/ history/ another terminal, another system

A header with no acceptable candidate is REPORTED, never silently dropped:
netdb.h, netinet/in.h and sys/socket.h are BSD's socket interface, which V10
does not have (it has sys/inet/ and the /dev/tcp model), and termio.h and
sys/sysmacros.h are System V's.  Those are facts about the programs that want
them, not gaps in the tape.
"""

import argparse
import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREE = os.path.join(ROOT, "v10", "source")
GEN = os.path.join(ROOT, "v10", "mk", "gen")
INC = os.path.join(TREE, "include")

# r70 keeps its variants here, best first: CC and lcc are the two ANSI-era
# compilers' copies, olcc and oCC the superseded generation of each.
VARIANTS = ("CC", "lcc", "olcc", "oCC", "libc", "local")

REFUSE = ("sparc_sun", "/sgi", "cfront", "/blit/", "/630/", "/history/",
          "sun3", "sun4", "mips", "sparc", "/vax-v9/")

# Interfaces V10 does not have.  Named with the reason, because "no candidate"
# and "a different operating system's interface" are not the same finding.
FOREIGN = {
    "netdb.h":          "BSD sockets -- V10 has sys/inet/ and the /dev/tcp model",
    "netinet/in.h":     "BSD sockets",
    "netinet/tcp.h":    "BSD sockets",
    "sys/socket.h":     "BSD sockets",
    "sys/un.h":         "BSD sockets",
    "arpa/inet.h":      "BSD sockets",
    "sys/resource.h":   "BSD",
    "sys/wait.h":       "BSD",
    "sys/file.h":       "BSD",
    "termio.h":         "System V terminal interface -- V10 has sys/ttyio.h",
    "sys/termio.h":     "System V",
    "sys/sysmacros.h":  "System V",
    "sys/ustat.h":      "System V",
    "ustat.h":          "System V",
    "sys/sys3b.h":      "the AT&T 3B, a different machine",
    # MEASURED, NOT JUDGED.  The tape's own manual settles both of these.
    "sys/ioctl.h":      "Berkeley.  V10's ioctl(2) SYNOPSIS is "
                        "`#include <sys/filio.h>' and the only page on the "
                        "tape naming <sys/ioctl.h> is jobs(3j), Berkeley job "
                        "control.  V10 has filio.h, ttyio.h and pioctl.h",
    "sys/time.h":       "BSD.  r70's time.h is struct tm (ctime(3)) with ZERO "
                        "mentions of timeval -- installing it here would "
                        "compile and then fail on struct timeval",
    "dirent.h":         "System V directory reader -- V10 has dirread(2) and "
                        "resdir.c, `research-style' in its own words",
    "sys/vtimes.h":     "Berkeley job control, with jobs(3j)",
    "telnet.h":         "BSD networking",
    "utime.h":          "System V",
    "sysent.h":         "cfront's, and C++ only",
    "locale.h":         "ANSI; r70 has it only as prototypes pcc2 cannot read",
    "unistd.h":         "POSIX -- V10 predates it; libc.h is its equivalent",
    "malloc.h":         "System V; V10 declares malloc in stdlib.h/libc.h",
    "memory.h":         "System V; V10 has string.h",
    "iostream.h":       "cfront's C++ library, not a C header",
    "stream.h":         "cfront's C++ library",
    "generic.h":        "cfront's C++ library",
}

# pcc2 (1985 K&R) cannot read any of these.
ANSI = (
    (re.compile(r'extern\s+"C"'),                     'extern "C"'),
    (re.compile(r"\bvoid\s*\*"),                      "void *"),
    (re.compile(r"\bconst\b"),                        "const"),
    (re.compile(r"\bvolatile\b"),                     "volatile"),
    (re.compile(r"\benum\s*\{"),                      "anonymous enum"),
    # a prototype: a declarator with a TYPE inside its parentheses
    (re.compile(r"\b\w+\s*\(\s*(?:void|char|int|long|short|unsigned|float|"
                r"double|struct|const|size_t|FILE)\b[^)]*\)\s*;"), "a prototype"),
    (re.compile(r"\b\d+[uUlL][uUlL]?\b"),             "an ANSI integer suffix"),
)


def installable(path):
    """Can pcc2 read this header?  (reason it cannot, or None)"""
    try:
        text = open(path, errors="replace").read()
    except OSError as e:
        return str(e)
    # strip comments first: a `const' inside prose is not a keyword
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    for rx, why in ANSI:
        m = rx.search(text)
        if m:
            return "%s (%s)" % (why, m.group(0).strip()[:28])
    return None


def candidates(name):
    """Where could this header come from?  Best provenance first."""
    out = []
    # r70's own /usr/include, then each variant directory
    p = os.path.join(INC, name)
    if os.path.exists(p):
        out.append((p, "r70", name))
    for v in VARIANTS:
        p = os.path.join(INC, v, name)
        if os.path.exists(p):
            out.append((p, "r70", "%s/%s" % (v, name)))
    # V10's own kernel trees, and our overlay
    # r70 KEEPS SOME sys/ HEADERS AT TOP LEVEL.  utsname.h is at
    # include/utsname.h and every consumer writes <sys/utsname.h>, so where it
    # is INSTALLED is a layout decision the tape's own includes settle.
    if name.startswith("sys/"):
        p = os.path.join(INC, name[4:])
        if os.path.exists(p):
            out.append((p, "r70", name[4:]))
        for v in VARIANTS:
            p = os.path.join(INC, v, name[4:])
            if os.path.exists(p):
                out.append((p, "r70", "%s/%s" % (v, name[4:])))
    for root, tag in (("src/include", "ours"), ("src/sys", "tape"),
                      ("src/lsys", "tape"), ("secombe/sys", "secombe")):
        p = os.path.join(TREE, root, name)
        if os.path.exists(p):
            out.append((p, tag, "%s/%s" % (root, name)))
        # sys/X.h also lives as <tree>/sys/X.h
        if name.startswith("sys/"):
            p = os.path.join(TREE, root, name[4:])
            if os.path.exists(p):
                out.append((p, tag, "%s/%s" % (root, name[4:])))
    return [c for c in out if not any(r in c[0] for r in REFUSE)]


def wanted():
    """Headers a planned program needs and /usr/include does not have.

    Read out of the scan's own analysis so the two cannot disagree: a list
    that appears twice will disagree, and an assertion comparing a list with
    itself is not an assertion.
    """
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "v10scan", os.path.join(ROOT, "tools", "v10-scan.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    want = collections.Counter()
    for _prog, (_d, miss) in m.blocked(apply_extra=False).items():
        for h in miss:
            want[h] += 1
    return want


HEAD = """# Headers to install into /usr/include before compiling anything.
#
# Generated by tools/v10-headers.py; check with --check.  r70 keeps these only
# inside a compiler's variant directory and the job is to pick the one pcc2 can
# read -- a SYSTEM-LAYOUT decision, not a source patch, since the tape holds
# four copies of some of them.  The test is mechanical (see the generator) and
# it reproduces every choice stage 2 made by hand, including CC/stdarg.h over
# lcc/stdarg.h -- lcc's parses perfectly and its macro says `3U', which pcc2
# lexes as 3 followed by the identifier U, so the EXPANSION fails hundreds of
# lines away.
#
# fields: header  r70|ours|tape  path (under v10/source)
#
"""


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args(argv)

    want = wanted()
    rows, foreign, none, rejected = [], [], [], []
    for name in sorted(want):
        if name.startswith(("/", "..")) or name in ("y.tab.h", "config.h"):
            continue                      # a path, not a system header
        if name in FOREIGN:
            foreign.append((name, want[name], FOREIGN[name]))
            continue
        cands = candidates(name)
        if not cands:
            none.append((name, want[name]))
            continue
        for path, tag, rel in cands:
            why = installable(path)
            if why is None:
                rows.append((name, tag, rel))
                break
            rejected.append((name, rel, why))
        else:
            none.append((name, want[name]))

    # the choices already made and still required, kept whatever the survey says
    for name, tag, rel in [("shares.h", "ours", "include/shares.h"),
                           ("sys/lnode.h", "ours", "include/sys/lnode.h")]:
        if name not in {r[0] for r in rows}:
            rows.append((name, tag, rel))
    rows.sort()

    body = HEAD + "".join("%-16s %-8s %s\n" % r for r in rows)
    p = os.path.join(GEN, "inc.extra")
    if a.check:
        if not os.path.exists(p) or open(p).read() != body:
            print("v10-headers: inc.extra is stale"); return 1
        print("v10-headers: inc.extra current (%d headers)" % len(rows))
        return 0
    open(p, "w").write(body)

    print("v10-headers: %d headers -> v10/mk/gen/inc.extra" % len(rows))
    for r in rows:
        print("   %-16s %-8s %s" % r)
    if foreign:
        print("\n   NOT INSTALLABLE -- another system's interface (%d):" % len(foreign))
        for n, c, why in sorted(foreign, key=lambda x: -x[1]):
            print("      %-20s %2d programs   %s" % (n, c, why))
    if none:
        print("\n   no acceptable candidate anywhere (%d):" % len(none))
        for n, c in sorted(none, key=lambda x: -x[1]):
            print("      %-20s %2d programs" % (n, c))
    if a.verbose and rejected:
        print("\n   variants rejected by the parse test:")
        for n, rel, why in rejected:
            print("      %-16s %-28s %s" % (n, rel, why))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
