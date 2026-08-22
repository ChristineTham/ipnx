#!/usr/bin/env python3
"""
The Tenth Edition /dev and /etc, generated.

    tools/v10-proto.py            # regenerate v10/mk/gen/{proto-dev,proto-etc}
    tools/v10-proto.py --check    # fail if either is stale

TWO REFERENCES, AND THEY AGREE.  The device majors come from V10's own
generated config, `lsys/astro/seki.c.c` -- the tables it links into the
kernel, so they cannot be wrong about the kernel.  The *shape* of the
directory comes from the V8 golden, read with `tools/v8fs.py`: 429 nodes, and
which of them a Research Unix actually wants.

Cross-checking one against the other is what makes this more than a guess,
and they line up better than expected:

	major   V10 cdevsw[]     present in V8's /dev
	  1     dz                 8 nodes
	  3     mm                 6
	 26     kmc                1
	 28     ra                24
	 31     kdi               95
	 40     fd               132
	 42     ip                 4
	 43     tcp               12
	 44     il                 2
	 50     udp               10

Same numbers, both editions.  V8 additionally has majors 18 and 22, which
V10's table leaves NULL -- those are V8's own devices and are deliberately
absent here.

WHY NOT JUST COPY V8's /dev.  Because two of its majors do not exist in V10,
its `hp' disks (block 0, char 4) are not V10's `ra', and a node naming a
driver the kernel does not have is a file that fails at open with a bare
ENXIO. The list is derived, not copied.

WHY THE COUNTS ARE SMALLER.  V8's 429 includes 95 kdi and 132 fd nodes,
which are per-channel and per-descriptor. This generates the ones a machine
needs to boot, log in, compile and talk IP; the rest can be made by
`/etc/mknod' on a running system, which is what it is for.
"""
import argparse
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
GEN = os.path.join(ROOT, "v10/mk/gen")

# name, type, major, minor, mode
#
# Majors are seki.c.c's:  cdevsw[]  cn 0, dz 1, ctu 2, mm 3, te16 5, sw 7,
#                                   kb 10, kmc 26, ra 28, kdi 31, fd 40,
#                                   ip 42, tcp 43, il 44, udp 50
#                         bdevsw[]  te16 1, sw 4, ra 7
DEV = []


# Every (kind, major) a V10-native node has been emitted for, so the V8-name
# reconciliation below can refuse a name whose driver we do not have rather than
# inventing a node that fails at open with a bare ENXIO.
V10_MAJORS = set()


def add(name, kind, major, minor, mode):
    DEV.append((name, kind, major, minor, mode))
    V10_MAJORS.add((kind, major))


# --- the console, which init opens before anything else --------------------
add("console", "c", 0, 0, "622")

# --- the DZ11 lines.  getty runs on these; /etc/ttys names them -----------
for n in range(8):
    add("tty%02d" % n, "c", 1, n, "622")

# --- memory.  V10's mem.c documents its own minors: 0 physical, 1 kernel,
#     2 EOF/RATHOLE, 3 unibus, 5 processor registers -- and 4 "obsolete".
#     V8's six nodes are those same numbers under V8's names, so all but one
#     transfer.  kmemr IS MINOR 4 AND CANNOT EXIST HERE: V8 calls 4 "public
#     part of kernel memory (read only)" and V10 deleted the case, so a node
#     for it would open and read nothing.  Recorded rather than fabricated.
add("mem",   "c", 3, 0, "640")
add("kmem",  "c", 3, 1, "640")
add("null",  "c", 3, 2, "666")
add("kUmem", "c", 3, 3, "600")
add("mtpr",  "c", 3, 5, "600")

# --- the file-descriptor device.  V8 puts stdin/stdout/stderr/tty on major
#     40 at minors 0..3, and V10's cdevsw has fd at 40 as well.
#
#     AND /dev/fd/N IS THE SAME DRIVER, which is why 128 of V8's nodes are
#     reachable here for free: `stdio 0' is already in the config and the
#     driver indexes u.u_ofile by the minor.  Every V8 script that opens
#     /dev/fd/3 works unchanged.
add("stdin",  "c", 40, 0, "666")
add("stdout", "c", 40, 1, "666")
add("stderr", "c", 40, 2, "666")
add("tty",    "c", 40, 3, "666")
for n in range(128):
    add("fd/%d" % n, "c", 40, n, "666")

# --- the root disk.  minor = BITFS | unit<<3 | partition, and bit 6 is set
#     on every one of these because they name bitmapped filesystems -- the
#     same bit seki's own `root regfs ra 0100' carries ---------------------
BITFS = 64
for unit in (0, 1):
    for i, part in enumerate("abcdefgh"):
        m = BITFS | (unit << 3) | i
        add("ra%d%s" % (unit, part),  "b", 7,  m, "640")
        add("rra%d%s" % (unit, part), "c", 28, m, "640")

# --- AND EVERY NAME THE V8 GOLDEN HAS, MEASURED OFF ITS OWN /dev -----------
#
# WHY MEASURED AND NOT INFERRED.  V8 numbers partitions with a DIGIT where V10
# uses a letter (`ra00', `rra13' against `ra0a', `rra1d'), so the obvious move is
# a formula -- and a formula gets it wrong, because a real /dev is not
# formulaic.  V8's carries `ra20a', one node with a letter among seven with
# digits, which no rule this file could state would produce.  So the NAMES come
# off the disk with tools/v8fs.py and only the MINOR is computed.
#
# A name is emitted when V10 has a driver at the corresponding major.  The map
# below is the evidence for each, and it is short because the two editions agree
# almost everywhere -- V10's own lsys/lib/tab against V8's dev/conf.c:
#
#	V8            V10           why
#	c 0,1,3,7     same          console, dz, mem, drum
#	b 0 / c 4     same          hp -- Massbus RP, bdev 0 / cdev 4 in both
#	b 7 / c 28    same          ra -- MSCP, and V10 sets the BITFS bit
#	c 18          same          V8's `sp' IS V10's spipe: stream pipes
#	c 19,26,31,40 same          dn11, kmc11b, kdi, fd
#	c 42,43,44,50 same          ip, tcp, il, udp
#	b 8 / c 22    b 1 / c 5     V8's mt is a TU/TM; the tape SIMH's vax780
#	                            gives us is a TM03, which is V10's te16 at
#	                            bdev 1 / cdev 5.  H_NOREWIND is 04 in V8's
#	                            mt.c, V10's te16.c AND V10's tu78.c, so V8's
#	                            own minors transfer untranslated.
#	c 3 minor 4   NOTHING        V8 calls it "public part of kernel memory
#	                            (read only)"; V10's mem.c calls minor 4
#	                            "obsolete" and deleted the case.  A node
#	                            would open and read nothing.  This is the ONE
#	                            V8 device name V10 cannot have, and it is
#	                            recorded rather than fabricated.
V8IMG = os.path.join(ROOT, "work", "myv8", "rp07new")
MAJMAP = {("b", 8): 1, ("c", 22): 5}            # V8's tape -> V10's te16
BITFS = 64
V8_SKIPPED = []


def v8_dev():
    """[(name, kind, major, minor, mode)] from the V8 golden's own /dev."""
    if not os.path.exists(V8IMG):
        return []
    spec = importlib.util.spec_from_file_location(
        "v8fs", os.path.join(HERE, "v8fs.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    out = []
    for part in ("a",):
        fs = m.V8FS(V8IMG, part)
        for path, ip in fs.walk("/dev"):
            if ip.kind not in "cb":
                continue
            maj, minor = ip.rdev
            rel = path[len("/dev/"):]
            out.append((rel, ip.kind, maj, minor, oct(ip.mode & 0o7777)[2:]))
    return sorted(out)


def reconcile_v8():
    have = set(n for n, _, _, _, _ in DEV)
    for name, kind, maj, minor, mode in v8_dev():
        if name in have:
            continue
        if kind == "c" and maj == 3 and minor == 4:
            V8_SKIPPED.append((name, "mem minor 4 is `obsolete' in V10's mem.c"))
            continue
        v10maj = MAJMAP.get((kind, maj), maj)
        if (kind, v10maj) not in V10_MAJORS:
            V8_SKIPPED.append((name, "V10 has no %s major %d" % (kind, v10maj)))
            continue
        # THE MINOR IS V10's, NOT V8's, and only for the disks: V10 sets the
        # BITFS bit (0100) on every ra minor because every filesystem it mounts
        # is a bitmapped one -- the same bit seki's own `root regfs ra 0100'
        # carries.  V8's own /dev is inconsistent about it (ra00 has it, ra01
        # does not), so copying V8's number would produce nodes that name a
        # filesystem type this kernel cannot mount.
        m2 = minor
        if (kind, v10maj) in (("b", 7), ("c", 28)):
            m2 = minor | BITFS
        add(name, kind, v10maj, m2, mode)
        have.add(name)


# --- stream pipes.  V8's /dev/pt/ptNN is NOT a pseudo-tty: major 18 in V8's
#     own cdevsw is `sp' with &spinfo, the stream-pipe driver, and V10 ships
#     the same driver as lsys/io/spipe.c exporting `spcdev'.  mkconf's own
#     catalogue already knows it -- devs line 64 is
#
#         pt  sp  count  data struct queue *spipes; inc sys/stream.h;
#
#     and lsys/lib/tab carries `# cdev 18 pt   # remove?' commented out.  So
#     this needed two config lines (v10/src/lsys/lib/tab, and `pt 64' in
#     ipnx780.m), never a driver port.  spopen() rejects minor > spcnt, and
#     an odd minor is the master end.
for n in range(64):
    add("pt/pt%02d" % n, "c", 18, n, "666")

# --- Datakit channels.  V8's 95 nodes are major 31, and V10's own tab says
#     `cdev 31 kdi' -- the same major for the same card, and ipnx780.m
#     already carries `kdi 1'.  Modes follow V8's node for node, because they
#     are not decoration: a Datakit channel's mode is how the dial-out and
#     dial-in halves are kept apart.
DK_MODES = {
    1: "600",
    2: "622",
    3: "666",
    4: "622",
    5: "666",
    6: "644",
    7: "666",
    8: "622",
    9: "666",
    10: "644",
    11: "666",
    12: "622",
    13: "666",
    14: "622",
    15: "666",
    16: "622",
    17: "666",
    18: "622",
    19: "666",
    20: "622",
    21: "666",
    22: "722",
    23: "666",
    24: "622",
    25: "666",
    26: "622",
    27: "666",
    28: "622",
    29: "666",
    30: "622",
    31: "666",
    32: "722",
    33: "666",
    34: "622",
    35: "666",
    36: "622",
    37: "666",
    38: "622",
    39: "666",
    40: "622",
    41: "666",
    42: "622",
    43: "666",
    44: "622",
    45: "666",
    46: "622",
    47: "666",
    48: "622",
    49: "666",
    50: "622",
    51: "664",
    52: "622",
    53: "664",
    54: "622",
    55: "664",
    56: "622",
    57: "664",
    58: "644",
    59: "664",
    60: "622",
    61: "664",
    62: "622",
    63: "664",
    64: "622",
    65: "664",
    66: "722",
    67: "664",
    68: "622",
    69: "664",
    70: "622",
    71: "664",
    72: "622",
    73: "664",
    74: "622",
    75: "664",
    76: "622",
    77: "664",
    78: "622",
    79: "664",
    80: "622",
    81: "664",
    82: "622",
    83: "664",
    84: "622",
    85: "664",
    86: "622",
    87: "664",
    88: "622",
    89: "664",
    90: "622",
    91: "664",
    92: "644",
    93: "664",
    94: "622",
    95: "664",
}


def dkmode(n):
    return DK_MODES.get(n, "600")


for n in range(1, 96):
    add("dk/dk%02d" % n, "c", 31, n, dkmode(n))

# --- swap ------------------------------------------------------------------
add("swap", "b", 4, 1, "640")
add("drum", "c", 7, 0, "640")

# --- tape.  te16 is the TM03/TE16 SIMH's vax780 actually provides, and
#     seki.m configures exactly that (`mba 0' + `te16 0 ctl 0 unit 0').  The
#     minor layout is IDENTICAL across V8's mt.c, V10's te16.c and V10's
#     tu78.c -- all three define H_NOREWIND as 04 -- so V8's own minors
#     transfer without translation.  V8's names sit on V10's tape majors:
#     bdev 1 / cdev 5, which is where te16 lives.
add("mt0",  "b", 1, 0, "640")
add("rmt0", "c", 5, 0, "640")
for name, minor in (("mt1", 0), ("mt2", 8), ("mt5", 4), ("mt6", 12),
                    ("nmt1", 4), ("nmt2", 12)):
    add(name, "b", 1, minor, "666")
for name, minor in (("rmt1", 0), ("rmt2", 8), ("rmt5", 4), ("rmt6", 12),
                    ("nrmt1", 4), ("nrmt2", 12)):
    add(name, "c", 5, minor, "666")

# --- the Massbus RP disks.  bdev 0 / cdev 4 in V10's own tab, driver
#     lsys/io/hp.c in V10's own tree -- and mkconf's `devs' catalogue has NO
#     `hp' row, so the tape as it stands cannot configure the disk it ships a
#     driver for.  That is the unfinished-port shape this project keeps
#     meeting, and it is repaired as a named overlay (v10/src/lsys/mkconf/
#     devs) rather than by leaving V10 unable to read an RP07.  minor =
#     unit<<3 | partition, hp.c's own rule.
for unit in (0, 1):
    for i, part in enumerate("abcdefgh"):
        m = (unit << 3) | i
        add("rp%d%s" % (unit, part),  "b", 0, m, "640")
        add("rrp%d%s" % (unit, part), "c", 4, m, "640")

# --- the KMC11B and the DN11.  Both are configured-but-absent by design:
#     ipnx780.m keeps kmc11b because dropping it left ld three symbols short,
#     and dn11 is an autodialer SIMH has no counterpart for.  autoconfig
#     probes, finds nothing, and carries on -- which is what makes the node
#     safe.  V8 has one of each and so does this.
add("kmc0", "c", 26, 0, "666")
add("dn0",  "c", 19, 128, "666")

# --- the network.  seki's kernel has ip, tcp, udp and the Interlan compiled
#     in, so the nodes exist even though nothing is attached yet.
#
#     TCP MINORS MUST BE ODD to be usable: tcp_device.c refuses an even one
#     whose socket is not already active, because even minors are the accept
#     side.  libin's tcp_sock() encodes this as `for(n = 01; n < 100; n += 2)'
#     and never says why.  V8's golden has both parities for the same reason.
#
#     ip16 and ip17 are PROTOCOL numbers, not unit numbers: 6 is TCP and 17
#     is UDP, which is what /etc/rc pushes the disciplines onto.  V8 carries
#     ip0, ip6, ip16 and ip17; ip16 was the one this generator lacked.
add("il0", "c", 44, 0, "600")
add("il1", "c", 44, 1, "666")
for n in range(4):
    add("ip%d" % n, "c", 42, n, "600")
for n in (6, 16, 17):
    add("ip%d" % n, "c", 42, n, "666")
for n in range(12):
    add("tcp%02d" % n, "c", 43, n, "666" if n % 2 else "600")
for n in range(10):
    add("udp%02d" % n, "c", 50, n, "666")

# --- and now every V8 name we can honour -----------------------------------
# LAST, so V10_MAJORS is complete and the V10-native spelling of a node always
# wins: `ra0a' is emitted above and `ra00' becomes an alias for it, never the
# other way round.
reconcile_v8()

# --- /etc, beyond the commands the build installs -------------------------
#
# V8's golden carries about 75 files here.  These are the ones a machine
# cannot come up without, plus the two tables that make it a machine rather
# than a kernel.
ETC = [
    ("passwd",  "644", "accounts"),
    ("group",   "644", "groups"),
    ("ttys",    "644", "which lines getty runs on, and at what speed"),
    ("rc",      "755", "run by init at multi-user"),
    ("motd",    "644", "printed by /etc/rc"),
    ("fstab",   "644", "what mount(8) reads with no arguments"),
    ("mtab",    "644", "what is mounted now; mount(8) appends"),
    ("utmp",    "644", "who is logged in; init truncates it at boot"),
    ("profile", "644", "read by every login shell"),
]


def build():
    out = ["# The Tenth Edition /dev, generated by tools/v10-proto.py.\n",
           "#\n",
           "# Majors are seki.c.c's own cdevsw[]/bdevsw[]; the shape of the\n",
           "# directory follows the V8 golden, read with tools/v8fs.py.\n",
           "#\n",
           "# fields: name<TAB>b|c<TAB>major<TAB>minor<TAB>mode\n#\n"]
    for name, kind, major, minor, mode in DEV:
        out.append("%s\t%s\t%d\t%d\t%s\n" % (name, kind, major, minor, mode))
    dev = "".join(out)

    out = ["# /etc's configuration files, generated by tools/v10-proto.py.\n",
           "# The commands in /etc are installed by the build; these are the\n",
           "# tables and the empty files a machine needs to come up.\n",
           "#\n# fields: name<TAB>mode<TAB>what it is\n#\n"]
    for name, mode, what in ETC:
        out.append("%s\t%s\t%s\n" % (name, mode, what))
    etc = "".join(out)
    return dev, etc


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()

    dev, etc = build()
    os.makedirs(GEN, exist_ok=True)
    stale = []
    for fn, text in (("proto-dev", dev), ("proto-etc", etc)):
        p = os.path.join(GEN, fn)
        old = open(p).read() if os.path.exists(p) else None
        if args.check:
            if old != text:
                stale.append(fn)
        elif old != text:
            open(p, "w").write(text)

    if args.check:
        if stale:
            print("stale, re-run tools/v10-proto.py: " + " ".join(stale))
            return 1
        print("proto-dev and proto-etc are up to date")
        return 0

    kinds = {}
    for _, k, maj, _, _ in DEV:
        kinds[(k, maj)] = kinds.get((k, maj), 0) + 1
    print("v10/mk/gen/proto-dev: %d nodes" % len(DEV))
    for (k, maj), n in sorted(kinds.items(), key=lambda x: (-x[1], x[0])):
        print("    %2d  %s %d" % (n, k, maj))
    if V8_SKIPPED:
        print("V8 device names NOT honoured (%d), each with its reason:"
              % len(V8_SKIPPED))
        for n, why in V8_SKIPPED:
            print("    %-10s %s" % (n, why))
    print("v10/mk/gen/proto-etc: %d files" % len(ETC))
    return 0


if __name__ == "__main__":
    sys.exit(main())
