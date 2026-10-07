#!/usr/bin/env python3
"""Read a V10 filesystem out of a SIMH RA73/RA81 image, from the host.

	tools/v10fs.py ls    IMAGE[:PART] [path]
	tools/v10fs.py cat   IMAGE[:PART] path
	tools/v10fs.py stat  IMAGE[:PART]
	tools/v10fs.py diff  IMAGE_A[:PART] IMAGE_B[:PART] [path]
	tools/v10fs.py tree  IMAGE[:PART] DIR [root ...]

PART defaults to `a' (root) for ls/cat/stat/diff and to `f' (/usr) for
tree.  `tree' compares the disk against a host directory -- normally this
repository's v10/usr -- over the build/usrtrees roots read from DIR itself,
or over the roots named after DIR.

WHY THIS EXISTS.  docs/v10-build.md says v10/ "is the machine's own /usr,
byte for byte what taripnx writes", and that was proven once, on 4 Sep 2026,
by tarring a live machine onto the share and comparing it with SHA-256.
Nothing checked it again.  By 7 Oct, 98 files under v10/usr had been edited
in this repository since the golden was cut -- dmesg, docgen, troff, sdb,
the kernel's printf arguments, vol2 -- and no channel carried any of them
to a machine: updatebuild delivers build/ and the build/mkfiles rows, and
these were neither.  The golden disk said one thing and v10/ another, and
the only way to find out was to boot.  The disk is a 1980s V7 derivative
with no journal and no compression, so the host can read it directly and
answer in seconds -- which is what turns "the golden matches the tree"
from a claim into a check.

THE FORMAT, quoted from the tree rather than from memory:

  usr/include/sys/param.h	BITFS(dev): BSIZE 4096, INOPB 64, NINDIR
				1024; SUPERB 1, ROOTINO 2;
				itod(x) = (x + 2*INOPB - 1) / INOPB
				itoo(x) = (x + 2*INOPB - 1) % INOPB
  usr/include/sys/ino.h		64-byte dinode; di_addr is "39 used; 13
				addresses of 3 bytes each"
  usr/include/sys/dir.h		16-byte direct: ino_t + char[14]
  usr/include/sys/types.h	ino_t is unsigned short, daddr_t long
  usr/sys/os/subr.c bmap	"blocks 0..NADDR-4 are direct blocks", then
				single, double, triple indirect
  usr/sys/io/ra.c		ra_sizes[], in 512-byte SECTORS from the
				start of the drive -- no cylinders, MSCP
				hides the geometry
  usr/src/build/mkimage		mkbitfs ra10 1280, ra14 31231, ra15 392528:
				every filesystem ipnx writes is a bitfs, so
				every block here is 4096 bytes

The 3-byte addresses are VAX order, little-endian with a zero high byte, as
tools/v8fs.py records from l3tol.c.  The layout is V8's at four times the
block size, which is why this file reads like that one.
"""

import hashlib
import os
import posixpath
import sys
import time

BSIZE = 4096			# BSIZE(dev), the BITFS case
INOPB = 64			# INOPB(dev) to match
NINDIR = BSIZE // 4		# 1024
SUPERB = 1
ROOTINO = 2
NADDR = 13

# ra.c's ra_sizes[]: partition -> (sectors, sector offset).  HUGE runs to the
# end of the drive; the drive's size comes from the image file.
HUGE = None
RA_SIZES = {
    "a": (10240, 0),
    "b": (20480, 10240),
    "c": (249848, 30720),
    "d": (249848, 280568),
    "e": (249848, 530416),
    "f": (HUGE, 780264),
    "g": (749544, 30720),
    "h": (HUGE, 0),
}

IFMT, IFDIR, IFCHR, IFBLK, IFREG, IFLNK = 0o170000, 0o40000, 0o20000, 0o60000, 0o100000, 0o120000


def u16(b, o):
    return b[o] | b[o + 1] << 8


def i16(b, o):
    v = u16(b, o)
    return v - 0x10000 if v & 0x8000 else v


def u32(b, o):
    return b[o] | b[o + 1] << 8 | b[o + 2] << 16 | b[o + 3] << 24


def addr3(b, o):
    return b[o] | b[o + 1] << 8 | b[o + 2] << 16


class Inode(object):
    __slots__ = ("num", "mode", "nlink", "uid", "gid", "size", "addr",
                 "atime", "mtime", "ctime")

    @property
    def kind(self):
        t = self.mode & IFMT
        return {IFDIR: "d", IFCHR: "c", IFBLK: "b", IFLNK: "l", IFREG: "-"}.get(t, "?")

    @property
    def isdir(self):
        return (self.mode & IFMT) == IFDIR

    @property
    def isreg(self):
        return (self.mode & IFMT) == IFREG

    @property
    def islnk(self):
        return (self.mode & IFMT) == IFLNK

    @property
    def isdev(self):
        return (self.mode & IFMT) in (IFCHR, IFBLK)

    @property
    def rdev(self):
        d = self.addr[0] & 0xFFFF
        return (d >> 8, d & 0xFF)


class V10FS(object):
    def __init__(self, path, part="a"):
        if part not in RA_SIZES:
            raise SystemExit("v10fs: no partition %s (have %s)"
                             % (part, " ".join(sorted(RA_SIZES))))
        self.path = path
        self.part = part
        self.f = open(path, "rb")
        drive = os.fstat(self.f.fileno()).st_size // 512
        nsec, off = RA_SIZES[part]
        if nsec is HUGE:
            nsec = drive - off
        if off >= drive:
            raise SystemExit("v10fs: %s is %d sectors; partition %s starts at %d"
                             % (path, drive, part, off))
        self.base = off * 512
        self.nblocks = nsec // 8
        self._icache = {}
        # A partition that holds no filesystem reads as garbage, and garbage
        # walks.  Refuse it here, where the reason can be said.
        sb = self.super()
        if not (2 < sb["isize"] < sb["fsize"] <= self.nblocks):
            raise SystemExit("v10fs: %s:%s holds no bitfs (s_isize %d, s_fsize %d, "
                             "partition %d blocks)" % (path, part, sb["isize"],
                                                       sb["fsize"], self.nblocks))

    def block(self, n):
        self.f.seek(self.base + n * BSIZE)
        b = self.f.read(BSIZE)
        return b if len(b) == BSIZE else b + b"\0" * (BSIZE - len(b))

    def super(self):
        """filsys.h, VAX alignment: the first long sits on 4, not 2."""
        b = self.block(SUPERB)
        return {
            "isize": u16(b, 0),
            "fsize": u32(b, 4),
            "time": u32(b, 216),
            "tfree": u32(b, 220),
            "tinode": u16(b, 224),
            "fsmnt": b[230:244].split(b"\0")[0].decode("ascii", "replace"),
        }

    def inode(self, num):
        if num in self._icache:
            return self._icache[num]
        blk = (num + 2 * INOPB - 1) // INOPB
        off = ((num + 2 * INOPB - 1) % INOPB) * 64
        b = self.block(blk)[off:off + 64]
        ip = Inode()
        ip.num = num
        ip.mode = u16(b, 0)
        ip.nlink = i16(b, 2)
        ip.uid = i16(b, 4)
        ip.gid = i16(b, 6)
        ip.size = u32(b, 8)
        ip.addr = [addr3(b, 12 + 3 * i) for i in range(NADDR)]
        ip.atime = u32(b, 52)
        ip.mtime = u32(b, 56)
        ip.ctime = u32(b, 60)
        self._icache[num] = ip
        return ip

    def bmap(self, ip, bn):
        """Logical block bn of ip -> physical block, or 0 for a hole."""
        if bn < NADDR - 3:
            return ip.addr[bn]
        bn -= NADDR - 3
        for level in range(3):
            span = NINDIR ** (level + 1)
            if bn < span:
                nb = ip.addr[NADDR - 3 + level]
                for sh in range(level, -1, -1):
                    if nb == 0:
                        return 0
                    b = self.block(nb)
                    nb = u32(b, ((bn // (NINDIR ** sh)) % NINDIR) * 4)
                return nb
            bn -= span
        return 0

    def read(self, ip):
        out = bytearray()
        for i in range((ip.size + BSIZE - 1) // BSIZE):
            pb = self.bmap(ip, i)
            out += self.block(pb) if pb else b"\0" * BSIZE
        return bytes(out[:ip.size])

    def readdir(self, ip):
        """(name, inum) pairs, skipping . and .. and cleared slots."""
        data = self.read(ip)
        for o in range(0, len(data) - 15, 16):
            inum = u16(data, o)
            if inum == 0:
                continue
            name = data[o + 2:o + 16].split(b"\0")[0].decode("latin-1")
            if name in (".", ".."):
                continue
            yield name, inum

    def walk(self, start="/"):
        """(path, inode) for everything under start, sorted, loop-safe."""
        ip = self.lookup(start)
        if ip is None:
            raise SystemExit("v10fs: no %s on %s:%s" % (start, self.path, self.part))
        seen = set()
        stack = [(start.rstrip("/") or "", ip)]
        while stack:
            path, dirip = stack.pop()
            if dirip.num in seen:
                continue
            seen.add(dirip.num)
            kids = sorted(self.readdir(dirip), key=lambda e: e[0])
            for name, inum in reversed(kids):
                child = self.inode(inum)
                cpath = path + "/" + name
                yield cpath, child
                if child.isdir:
                    stack.append((cpath, child))

    def lookup(self, path):
        # readdir skips `..', so resolve it by name first: build/preserve's
        # upas rows are spelled `upas/attin/../common/sys.h'.
        path = posixpath.normpath("/" + path)
        ip = self.inode(ROOTINO)
        for part in path.strip("/").split("/"):
            if not part:
                continue
            if not ip.isdir:
                return None
            for name, inum in self.readdir(ip):
                if name == part:
                    ip = self.inode(inum)
                    break
            else:
                return None
        return ip


def openspec(spec, default="a"):
    """IMAGE or IMAGE:PART."""
    path, part = spec, default
    if ":" in spec:
        head, tail = spec.rsplit(":", 1)
        if tail in RA_SIZES:
            path, part = head, tail
    return V10FS(path, part)


def describe(ip):
    if ip.isdev:
        return "%s %4o %3d %3d %5s" % (ip.kind, ip.mode & 0o7777, ip.uid, ip.gid,
                                       "%d,%d" % ip.rdev)
    return "%s %4o %3d %3d %7d" % (ip.kind, ip.mode & 0o7777, ip.uid, ip.gid, ip.size)


def cmd_ls(args):
    fs = openspec(args[0])
    for path, ip in fs.walk(args[1] if len(args) > 1 else "/"):
        line = "%s %s" % (describe(ip), path)
        if ip.islnk:
            line += " -> " + fs.read(ip).decode("latin-1")
        print(line)


def cmd_stat(args):
    fs = openspec(args[0])
    sb = fs.super()
    print("%s:%s" % (fs.path, fs.part))
    print("  partition %d blocks (%d sectors)" % (fs.nblocks, fs.nblocks * 8))
    print("  s_fsize   %d blocks" % sb["fsize"])
    print("  s_isize   %d blocks (%d inodes)" % (sb["isize"], (sb["isize"] - 2) * INOPB))
    print("  s_tfree   %d blocks free (%.1f%% used)"
          % (sb["tfree"], 100.0 * (sb["fsize"] - sb["tfree"]) / sb["fsize"]))
    print("  s_tinode  %d inodes free" % sb["tinode"])
    print("  s_time    %s" % time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(sb["time"])))
    print("  s_fsmnt   %s" % sb["fsmnt"])
    nd = nf = nl = total = 0
    for _, ip in fs.walk("/"):
        if ip.isdir:
            nd += 1
        elif ip.isreg:
            nf += 1
            total += ip.size
        elif ip.islnk:
            nl += 1
    print("  contents  %d dirs, %d files (%d bytes), %d symlinks" % (nd, nf, total, nl))


def cmd_cat(args):
    fs = openspec(args[0])
    ip = fs.lookup(args[1])
    if ip is None:
        raise SystemExit("v10fs: no such file %s" % args[1])
    sys.stdout.buffer.write(fs.read(ip))


def digest(fs, ip):
    if ip.isdev:
        return "dev:%d,%d" % ip.rdev
    if ip.isdir:
        return "dir"
    return hashlib.sha256(fs.read(ip)).hexdigest()


def cmd_diff(args):
    a = openspec(args[0])
    b = openspec(args[1])
    root = args[2] if len(args) > 2 else "/"
    amap = dict(a.walk(root))
    bmap = dict(b.walk(root))
    only_a = sorted(set(amap) - set(bmap))
    only_b = sorted(set(bmap) - set(amap))
    for p in only_a:
        print("only in A  %s %s" % (describe(amap[p]), p))
    for p in only_b:
        print("only in B  %s %s" % (describe(bmap[p]), p))
    same = differ = 0
    for p in sorted(set(amap) & set(bmap)):
        ia, ib = amap[p], bmap[p]
        if (ia.mode & IFMT) != (ib.mode & IFMT):
            print("type       %s (A %s, B %s)" % (p, ia.kind, ib.kind))
            differ += 1
        elif digest(a, ia) != digest(b, ib):
            print("content    %s (A %d, B %d bytes)" % (p, ia.size, ib.size))
            differ += 1
        else:
            same += 1
    print("")
    print("A only %d, B only %d, differ %d, identical %d"
          % (len(only_a), len(only_b), differ, same))


def usrtrees(d):
    """build/usrtrees's roots: the lines that start with [a-z0-9], the same
    match taripnx, mkipnx and mkimage use, read from the tree being compared
    so the two sides are measured over one statement of the shape."""
    with open(os.path.join(d, "src", "build", "usrtrees")) as f:
        return [ln.split()[0] for ln in f if ln[:1].isalnum() and ln[:1] == ln[:1].lower()]


def hosttree(top, root):
    """path -> ('d'|'-'|'l', payload) for everything under top/root.

    A symlink is compared by its target, the way the disk stores one; a
    directory by being one."""
    out = {}
    base = os.path.join(top, root)
    if not os.path.isdir(base):
        return out
    out["/" + root] = ("d", None)
    for dirpath, dirnames, filenames in os.walk(base):
        rel = os.path.relpath(dirpath, top)
        for n in list(dirnames):
            p = os.path.join(dirpath, n)
            if os.path.islink(p):
                out["/" + os.path.join(rel, n)] = ("l", os.readlink(p).encode("latin-1"))
                dirnames.remove(n)
            else:
                out["/" + os.path.join(rel, n)] = ("d", None)
        for n in filenames:
            p = os.path.join(dirpath, n)
            if os.path.islink(p):
                out["/" + os.path.join(rel, n)] = ("l", os.readlink(p).encode("latin-1"))
            else:
                out["/" + os.path.join(rel, n)] = ("-", p)
    return out


def compare(fs, top, roots):
    """The disk against a host directory over roots.

    Returns (findings, identical): findings is a sorted list of (what, path,
    detail), what being `only on disk', `only in tree', `type', `link' or
    `content', and path /-rooted and relative to the filesystem.  An empty
    directory on the disk says so in its detail -- git cannot hold one, so a
    caller will want to tell it apart."""
    disk = {}
    for r in roots:
        ip = fs.lookup("/" + r)
        if ip is None:
            continue
        disk["/" + r] = ip
        disk.update(fs.walk("/" + r))
    host = {}
    for r in roots:
        host.update(hosttree(top, r))
    out = []
    for p in sorted(set(disk) - set(host)):
        ip = disk[p]
        detail = describe(ip)
        if ip.isdir and not any(True for _ in fs.readdir(ip)):
            detail += " (empty)"
        out.append(("only on disk", p, detail))
    for p in sorted(set(host) - set(disk)):
        out.append(("only in tree", p, host[p][0]))
    same = 0
    for p in sorted(set(disk) & set(host)):
        ip = disk[p]
        kind, payload = host[p]
        if ip.kind != kind:
            out.append(("type", p, "disk %s, tree %s" % (ip.kind, kind)))
        elif kind == "d":
            same += 1
        elif kind == "l":
            if fs.read(ip) != payload:
                out.append(("link", p, "disk -> %s, tree -> %s"
                            % (fs.read(ip).decode("latin-1"), payload.decode("latin-1"))))
            else:
                same += 1
        else:
            data = fs.read(ip)
            with open(payload, "rb") as f:
                mine = f.read()
            if data != mine:
                out.append(("content", p, "disk %d, tree %d bytes" % (len(data), len(mine))))
            else:
                same += 1
    return out, same


def cmd_tree(args):
    """Disk against a host directory, over the usrtrees roots.

    Exit status 1 when anything differs, so a script can ask."""
    spec, top = args[0], args[1]
    fs = openspec(spec, "f")
    roots = args[2:] or usrtrees(top)
    found, same = compare(fs, top, roots)
    for what, p, detail in found:
        print("%-13s %s (%s)" % (what, p, detail))
    count = {}
    for what, _, _ in found:
        count[what] = count.get(what, 0) + 1
    print("")
    print("roots: %s" % " ".join(roots))
    print("disk only %d, tree only %d, differ %d, identical %d"
          % (count.get("only on disk", 0), count.get("only in tree", 0),
             sum(count.get(k, 0) for k in ("type", "link", "content")), same))
    return 1 if found else 0


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__.strip())
    cmd, args = sys.argv[1], sys.argv[2:]
    cmds = {"ls": cmd_ls, "cat": cmd_cat, "stat": cmd_stat, "diff": cmd_diff,
            "tree": cmd_tree}
    if cmd not in cmds:
        sys.exit("v10fs: unknown command %s" % cmd)
    try:
        sys.exit(cmds[cmd](args) or 0)
    except BrokenPipeError:
        os._exit(0)


if __name__ == "__main__":
    main()
