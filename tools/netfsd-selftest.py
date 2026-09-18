#!/usr/bin/env python3
"""Exercise tools/netfsd.py the way a V8 kernel would, without a VAX.

    tools/netfsd-selftest.py            # exits 0 if every check passes

WHY THIS EXISTS.  There are two servers for one protocol -- the Swift package
that ships in the app and tools/netfsd.py for hosts with no Swift -- and
docs/netfs-protocol.md is the contract between them.  Booting the golden proves
the Python server works, and it costs ten minutes and a simulator; this proves
the same wire in under a second, so a change to either side has something cheap
to fail against.

IT SPEAKS THE WIRE AND NOT THE API.  Everything below is built with struct at
the offsets the protocol doc tabulates, sent over a real socket, and checked by
reading the reply's bytes back at their own offsets.  A test that called the
server's own functions would agree with the server about a layout they had both
got wrong, which is the one thing it needs to be unable to do.
"""

import os
import shutil
import socket
import struct
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
NETFSD = os.path.join(HERE, "netfsd.py")

NETVERSION = 1
NSTAT, NWRT, NREAD, NFREE, NTRUNC, NUPDAT, NGET, NNAMI, NPUT = range(1, 10)
NROOT, NDEL, NLINK, NCREAT, NOMATCH, NSTART = range(10, 16)
ROOTINO = 2
DIRSIZ = 14

fails = []


def check(label, got, want):
    if got == want:
        print("  ok   %-42s %r" % (label, got))
    else:
        print("  FAIL %-42s got %r want %r" % (label, got, want))
        fails.append(label)


def senda(cmd, trannum=1, flags=0, uid=0, gid=0, dev=64, tag=0, mode=0,
          newuid=0, newgid=0, ino=0, count=0, offset=0, ta=0, tm=0):
    """docs/netfs-protocol.md, `struct senda' -- 52 bytes, holes included."""
    return struct.pack("<BBBBiHHHHiiHHiiiIii",
                       NETVERSION, cmd, flags, 0, trannum,
                       uid, gid, dev, 0,            # the hole at 14
                       tag, mode, newuid, newgid,
                       ino, count, offset,
                       0,                            # buf: a client pointer
                       ta, tm)


class Rcva:
    """Read the reply back at the offsets the doc gives, not by unpacking a
    struct this file also defines -- the point is to check the server's."""

    def __init__(self, b):
        assert len(b) == 48, len(b)
        self.raw = b
        self.trannum = struct.unpack_from("<i", b, 0)[0]
        self.errno = b[4]
        self.flags = b[5]
        self.dev = struct.unpack_from("<H", b, 6)[0]
        self.size = struct.unpack_from("<i", b, 8)[0]
        self.mode = struct.unpack_from("<H", b, 12)[0]
        self.uid = struct.unpack_from("<H", b, 14)[0]
        self.gid = struct.unpack_from("<H", b, 16)[0]
        self.hole = struct.unpack_from("<H", b, 18)[0]
        self.tag = struct.unpack_from("<i", b, 20)[0]
        self.nlink = struct.unpack_from("<H", b, 24)[0]
        self.rsvd = struct.unpack_from("<H", b, 26)[0]
        self.ino = struct.unpack_from("<i", b, 28)[0]
        self.count = struct.unpack_from("<i", b, 32)[0]
        self.tm = struct.unpack_from("<iii", b, 36)


class Client:
    def __init__(self, port):
        for _ in range(100):                 # the server may still be binding
            try:
                self.s = socket.create_connection(("127.0.0.1", port), 5)
                break
            except OSError:
                time.sleep(0.05)
        else:
            raise SystemExit("selftest: could not connect to 127.0.0.1:%d" % port)
        self.s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.tn = 100

    def recv_exactly(self, n):
        buf = b""
        while len(buf) < n:
            c = self.s.recv(n - len(buf))
            if not c:
                raise SystemExit("selftest: server closed the connection")
            buf += c
        return buf

    def start(self, dev=64):
        # One byte of version ON ITS OWN, then a senda, then a 48-byte reply.
        self.s.sendall(bytes([NETVERSION]))
        self.s.sendall(senda(NSTART, trannum=0, dev=dev, ta=int(time.time())))
        return Rcva(self.recv_exactly(48))

    def call(self, cmd, payload=b"", **kw):
        self.tn += 1
        kw.setdefault("trannum", self.tn)
        if payload:
            kw.setdefault("count", len(payload))
        self.s.sendall(senda(cmd, **kw))
        # The payload always follows its header as a SEPARATE write, never
        # inside it -- send()'s own shape, and NREAD is the exception because
        # for a read `count' means "how much I want".
        if payload and cmd != NREAD:
            self.s.sendall(payload)
        y = Rcva(self.recv_exactly(48))
        data = b""
        if y.errno == 0 and cmd == NREAD and y.count > 0:
            data = self.recv_exactly(y.count)
        return y, data


def name14(s):
    """NNAMI carries DIRSIZ bytes, NUL-padded."""
    return s.encode()[:DIRSIZ].ljust(DIRSIZ, b"\0")


def parse_dir(image):
    """struct direct is `ino_t d_ino; char d_name[DIRSIZ];' -- 16 bytes."""
    out = []
    for i in range(0, len(image) - 15, 16):
        ino = struct.unpack_from("<H", image, i)[0]
        nm = image[i + 2:i + 16].split(b"\0", 1)[0].decode()
        out.append((nm, ino))
    return out


def main():
    root = tempfile.mkdtemp(prefix="netfs-selftest-")
    try:
        os.mkdir(os.path.join(root, "sub"))
        with open(os.path.join(root, "hello"), "w") as f:
            f.write("hello netfs\n")
        with open(os.path.join(root, "a-very-long-name-indeed"), "w") as f:
            f.write("truncated\n")
        with open(os.path.join(root, "sub", "inner"), "w") as f:
            f.write("x" * 5000)             # bigger than one 4096 NREAD
        os.symlink("hello", os.path.join(root, "link"))
        os.mkfifo(os.path.join(root, "fifo"))   # a type V8 cannot use

        port = 9377
        srv = subprocess.Popen([sys.executable, NETFSD, "-p", str(port), root],
                               stderr=subprocess.DEVNULL)
        try:
            c = Client(port)

            print("handshake")
            y = c.start(dev=64)
            check("NSTART errno", y.errno, 0)
            check("NSTART trannum echoed", y.trannum, 0)

            print("NGET(dev, 2) -- the only way to name the root")
            y, _ = c.call(NGET, ino=ROOTINO)
            check("root errno", y.errno, 0)
            check("root ino", y.ino, ROOTINO)
            check("root is a directory", (y.mode & 0o170000) == 0o040000, True)
            check("reply hole at 18 is zero", y.hole, 0)
            check("reply rsvd at 26 is zero", y.rsvd, 0)
            check("dev echoed", y.dev, 64)
            root_tag, root_size = y.tag, y.size

            print("NREAD on the root -- a forged directory image")
            y, image = c.call(NREAD, tag=root_tag, ino=ROOTINO, count=4096, offset=0)
            check("dir read errno", y.errno, 0)
            check("dir size matches NGET", len(image), root_size)
            check("image is whole 16-byte records", len(image) % 16, 0)
            ents = parse_dir(image)
            names = [n for n, _ in ents]
            check("first entry is .", names[0], ".")
            check("second entry is ..", names[1], "..")
            check(". points at the root", ents[0][1], ROOTINO)
            check("fifo is hidden", "fifo" in names, False)
            check("symlink is listed", "link" in names, True)
            check("long name truncated to 14", "a-very-long-na" in names, True)

            print("NNAMI -- one component at a time")
            y, _ = c.call(NNAMI, payload=name14("hello"), tag=root_tag, ino=ROOTINO)
            check("lookup errno", y.errno, 0)
            check("lookup flags", y.flags, 0)
            hello_tag, hello_ino = y.tag, y.ino
            check("hello size", y.size, 12)

            y, _ = c.call(NNAMI, payload=name14("nonesuch"), tag=root_tag, ino=ROOTINO)
            check("missing errno", y.errno, 0)          # not an error
            check("missing flags NOMATCH", y.flags, NOMATCH)

            y, _ = c.call(NNAMI, payload=name14(".."), tag=root_tag, ino=ROOTINO)
            check(".. at the root flags NROOT", y.flags, NROOT)
            y, _ = c.call(NNAMI, payload=name14("."), tag=root_tag, ino=ROOTINO)
            check(". never raises NROOT", y.flags, 0)

            y, _ = c.call(NNAMI, payload=name14("a-very-long-name-indeed"),
                          tag=root_tag, ino=ROOTINO)
            check("a truncated name still resolves", y.errno, 0)
            check("  and is not NOMATCH", y.flags, 0)

            print("NREAD on a file")
            y, data = c.call(NREAD, tag=hello_tag, ino=hello_ino, count=4096, offset=0)
            check("file contents", data, b"hello netfs\n")
            y, data = c.call(NREAD, tag=hello_tag, ino=hello_ino, count=4096, offset=12)
            check("EOF is a ZERO-length reply", (y.errno, y.count), (0, 0))
            y, data = c.call(NREAD, tag=hello_tag, ino=hello_ino, count=5, offset=6)
            check("offset and count honoured", data, b"netfs")

            print("NREAD across the 4096 boundary")
            y, _ = c.call(NNAMI, payload=name14("sub"), tag=root_tag, ino=ROOTINO)
            sub_tag, sub_ino = y.tag, y.ino
            y, _ = c.call(NNAMI, payload=name14("inner"), tag=sub_tag, ino=sub_ino)
            in_tag, in_ino = y.tag, y.ino
            check("inner size", y.size, 5000)
            y, d1 = c.call(NREAD, tag=in_tag, ino=in_ino, count=4096, offset=0)
            y, d2 = c.call(NREAD, tag=in_tag, ino=in_ino, count=4096, offset=len(d1))
            check("two reads cover the file", len(d1) + len(d2), 5000)

            print("NSTAT -- the only op that returns tm[3]")
            y, _ = c.call(NSTAT, tag=hello_tag, ino=hello_ino)
            check("stat errno", y.errno, 0)
            check("stat size", y.size, 12)
            check("stat times are set", all(t > 0 for t in y.tm), True)

            print("read-only is read-only")
            y, _ = c.call(NWRT, payload=b"nope", tag=hello_tag, ino=hello_ino, offset=0)
            check("NWRT refused EROFS", y.errno, 30)
            y, _ = c.call(NNAMI, payload=name14("newfile"), flags=NCREAT,
                          tag=root_tag, ino=ROOTINO, mode=0o644)
            check("NNAMI+NCREAT refused EROFS", y.errno, 30)
            check("nothing was created", os.path.exists(os.path.join(root, "newfile")), False)

            print("NPUT and NFREE")
            y, _ = c.call(NPUT, tag=hello_tag, ino=hello_ino)
            check("put errno", y.errno, 0)
            y, _ = c.call(NFREE, tag=sub_tag, ino=sub_ino)
            check("free errno", y.errno, 0)
            y, _ = c.call(NGET, ino=ROOTINO)
            check("the root survives NPUT", y.errno, 0)

            c.s.close()
        finally:
            srv.terminate()
            srv.wait(timeout=10)

        # -- and the same again with -w, which is the only difference
        print("read/write mode")
        port += 1
        srv = subprocess.Popen([sys.executable, NETFSD, "-w", "-p", str(port), root],
                               stderr=subprocess.DEVNULL)
        try:
            c = Client(port)
            c.start(dev=65)
            y, _ = c.call(NGET, ino=ROOTINO)
            rt = y.tag
            y, _ = c.call(NNAMI, payload=name14("made"), flags=NCREAT,
                          tag=rt, ino=ROOTINO, mode=0o644)
            check("NCREAT errno", y.errno, 0)
            check("NCREAT cleared NOMATCH", y.flags, 0)
            made_tag, made_ino = y.tag, y.ino
            y, _ = c.call(NWRT, payload=b"written\n", tag=made_tag, ino=made_ino, offset=0)
            check("NWRT errno", y.errno, 0)
            check("it landed on the host",
                  open(os.path.join(root, "made")).read(), "written\n")
            y, d = c.call(NREAD, tag=made_tag, ino=made_ino, count=4096, offset=0)
            check("and reads back", d, b"written\n")
            y, _ = c.call(NTRUNC, tag=made_tag, ino=made_ino)
            check("NTRUNC errno", y.errno, 0)
            check("truncated on the host", os.path.getsize(os.path.join(root, "made")), 0)
            y, _ = c.call(NNAMI, payload=name14("made"), flags=NDEL, tag=rt, ino=ROOTINO)
            check("NDEL errno", y.errno, 0)
            check("gone from the host", os.path.exists(os.path.join(root, "made")), False)
            c.s.close()
        finally:
            srv.terminate()
            srv.wait(timeout=10)
    finally:
        shutil.rmtree(root, ignore_errors=True)

    print()
    if fails:
        print("%d CHECK(S) FAILED: %s" % (len(fails), ", ".join(fails)))
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
