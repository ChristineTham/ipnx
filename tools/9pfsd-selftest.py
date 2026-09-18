#!/usr/bin/env python3
"""Exercise tools/9pfsd.py over a real socket, without a simulator.

    python3 tools/9pfsd-selftest.py [-v]

Every check here is a message on the wire and a reply parsed back, against a
server started on a scratch directory in a temporary tree.  Nothing is mocked:
the point is that the framing, the offsets and the error numbers are the ones
a guest will actually see, and half of what this catches is a field written at
the right value in the wrong place.

It is the netfs selftest's counterpart and exists for the same reason -- that
the alternative way to find a wire bug is a two-hour world build failing in a
way that reads like a compiler problem.
"""

import errno as E
import os
import shutil
import socket
import struct
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
SERVER = os.path.join(HERE, "9pfsd.py")

Tversion, Rversion = 100, 101
Tauth = 102
Tattach, Rattach = 104, 105
Rerror = 107
Tflush, Rflush = 108, 109
Twalk, Rwalk = 110, 111
Topen, Ropen = 112, 113
Tcreate, Rcreate = 114, 115
Tread, Rread = 116, 117
Twrite, Rwrite = 118, 119
Tclunk, Rclunk = 120, 121
Tremove, Rremove = 122, 123
Tstat, Rstat = 124, 125
Twstat, Rwstat = 126, 127

QTDIR, QTSYMLINK = 0x80, 0x02
DMDIR = 0x80000000
DMSYMLINK = 0x02000000
OREAD, OWRITE, ORDWR = 0, 1, 2
OTRUNC = 0x10
NOTOUCH2, NOTOUCH4, NOTOUCH8 = 0xFFFF, 0xFFFFFFFF, 0xFFFFFFFFFFFFFFFF

VERBOSE = "-v" in sys.argv[1:]
PASS = [0]
FAIL = []


def check(name, cond, detail=""):
    if cond:
        PASS[0] += 1
        if VERBOSE:
            print("  ok   %s" % name)
    else:
        FAIL.append((name, detail))
        print("  FAIL %s %s" % (name, detail))


# ---------------------------------------------------------------- the wire --

class Client(object):
    def __init__(self, port):
        self.s = socket.create_connection(("127.0.0.1", port), 10)
        self.s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.tag = 0

    def close(self):
        try:
            self.s.close()
        except Exception:
            pass

    def rpc(self, typ, body, tag=None):
        if tag is None:
            self.tag = (self.tag + 1) & 0xFFFE
            tag = self.tag
        msg = struct.pack("<IBH", 7 + len(body), typ, tag) + body
        self.s.sendall(msg)
        hdr = self._exact(4)
        n = struct.unpack("<I", hdr)[0]
        rest = self._exact(n - 4)
        rtyp, rtag = struct.unpack("<BH", rest[:3])
        return rtyp, rtag, rest[3:]

    def _exact(self, n):
        out = b""
        while len(out) < n:
            c = self.s.recv(n - len(out))
            if not c:
                raise IOError("server closed")
            out += c
        return out

    # convenience wrappers ------------------------------------------------
    def version(self, ver="9P2000.u", msize=8216):
        t, _, b = self.rpc(Tversion, struct.pack("<IH", msize, len(ver)) + ver.encode(), 0xFFFF)
        if t != Rversion:
            return None
        m, l = struct.unpack("<IH", b[:6])
        return m, b[6:6 + l].decode()

    def attach(self, fid=0):
        body = struct.pack("<II", fid, 0xFFFFFFFF) + pstr("root") + pstr("")
        return self.rpc(Tattach, body)

    def walk(self, fid, newfid, names):
        body = struct.pack("<IIH", fid, newfid, len(names))
        for n in names:
            body += pstr(n)
        return self.rpc(Twalk, body)

    def open(self, fid, mode=OREAD):
        return self.rpc(Topen, struct.pack("<IB", fid, mode))

    def read(self, fid, off, count):
        return self.rpc(Tread, struct.pack("<IQI", fid, off, count))

    def write(self, fid, off, data):
        return self.rpc(Twrite, struct.pack("<IQI", fid, off, len(data)) + data)

    def clunk(self, fid):
        return self.rpc(Tclunk, struct.pack("<I", fid))

    def stat(self, fid):
        return self.rpc(Tstat, struct.pack("<I", fid))

    def remove(self, fid):
        return self.rpc(Tremove, struct.pack("<I", fid))

    def create(self, fid, name, perm, mode, ext=""):
        return self.rpc(Tcreate, struct.pack("<I", fid) + pstr(name)
                        + struct.pack("<IB", perm, mode) + pstr(ext))


def pstr(s):
    b = s.encode() if isinstance(s, str) else s
    return struct.pack("<H", len(b)) + b


def gstr(b, i):
    n = struct.unpack("<H", b[i:i + 2])[0]
    return b[i + 2:i + 2 + n].decode("utf-8", "surrogateescape"), i + 2 + n


def rerror(b):
    """Pull (text, errno) out of an Rerror body."""
    text, i = gstr(b, 0)
    num = struct.unpack("<I", b[i:i + 4])[0] if len(b) >= i + 4 else None
    return text, num


def unqid(b, i=0):
    t = b[i]
    ver = struct.unpack("<I", b[i + 1:i + 5])[0]
    path = struct.unpack("<Q", b[i + 5:i + 13])[0]
    return (t, ver, path), i + 13


def unstat(b, i=0):
    """One stat entry -> dict, and the index just past it."""
    size = struct.unpack("<H", b[i:i + 2])[0]
    end = i + 2 + size
    j = i + 2
    d = {}
    d["type"] = struct.unpack("<H", b[j:j + 2])[0]; j += 2
    d["dev"] = struct.unpack("<I", b[j:j + 4])[0]; j += 4
    d["qid"], j = unqid(b, j)
    d["mode"] = struct.unpack("<I", b[j:j + 4])[0]; j += 4
    d["atime"] = struct.unpack("<I", b[j:j + 4])[0]; j += 4
    d["mtime"] = struct.unpack("<I", b[j:j + 4])[0]; j += 4
    d["length"] = struct.unpack("<Q", b[j:j + 8])[0]; j += 8
    d["name"], j = gstr(b, j)
    d["uid"], j = gstr(b, j)
    d["gid"], j = gstr(b, j)
    d["muid"], j = gstr(b, j)
    if j < end:
        d["ext"], j = gstr(b, j)
        d["n_uid"] = struct.unpack("<I", b[j:j + 4])[0]; j += 4
        d["n_gid"] = struct.unpack("<I", b[j:j + 4])[0]; j += 4
    return d, end


# ---------------------------------------------------------------- fixtures --

def make_tree(root):
    os.makedirs(os.path.join(root, "sub"))
    open(os.path.join(root, "hello"), "w").write("hello, world\n")
    open(os.path.join(root, "sub", "deep"), "w").write("x" * 3000)
    # 20 chars: longer than V10's 14-byte struct direct, which is the whole
    # reason the fallback exists.
    open(os.path.join(root, "a_very_long_filename"), "w").write("long\n")
    os.symlink("hello", os.path.join(root, "link"))
    os.symlink("/etc/passwd", os.path.join(root, "escape"))


def start(root, port, extra=()):
    args = [sys.executable, SERVER, "-p", str(port)] + list(extra) + [root]
    p = subprocess.Popen(args, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    for _ in range(200):
        try:
            socket.create_connection(("127.0.0.1", port), 0.2).close()
            return p
        except Exception:
            time.sleep(0.05)
    raise SystemExit("9pfsd did not come up on port %d" % port)


def freeport():
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    p = s.getsockname()[1]
    s.close()
    return p


# ------------------------------------------------------------------- tests --

def test_session(port):
    c = Client(port)
    m, v = c.version()
    check("Tversion 9P2000.u negotiates", v == "9P2000.u", repr(v))
    check("msize is not enlarged", m <= 8216, m)
    c.close()

    c = Client(port)
    check("bare 9P2000 accepted", c.version("9P2000")[1] == "9P2000")
    c.close()

    c = Client(port)
    check("unknown version refused by name", c.version("9P2000.L")[1] == "unknown")
    c.close()

    c = Client(port)
    check("msize is clamped down", c.version("9P2000.u", 1 << 20)[0] <= 8216)
    c.close()

    c = Client(port)
    c.version()
    t, _, b = c.rpc(Tauth, struct.pack("<I", 1) + pstr("root") + pstr(""))
    check("Tauth refused", t == Rerror, t)
    t, _, b = c.rpc(Tflush, struct.pack("<H", 1))
    check("Tflush answered", t == Rflush, t)
    t, _, b = c.clunk(77)
    check("clunk of unknown fid is EBADF", t == Rerror and rerror(b)[1] == E.EBADF,
          rerror(b) if t == Rerror else t)
    check("Rerror carries a numeric errno (.u)", rerror(b)[1] is not None)
    c.close()


def test_walk_stat(port):
    c = Client(port)
    c.version()
    t, _, b = c.attach(0)
    check("Tattach succeeds", t == Rattach, t)
    q, _ = unqid(b)
    check("root qid is a directory", q[0] & QTDIR, hex(q[0]))

    t, _, b = c.walk(0, 1, [])
    check("Twalk with no names clones", t == Rwalk and struct.unpack("<H", b[:2])[0] == 0, t)

    t, _, b = c.walk(0, 2, ["hello"])
    check("Twalk one name", t == Rwalk and struct.unpack("<H", b[:2])[0] == 1, t)

    t, _, b = c.walk(0, 3, ["sub", "deep"])
    check("Twalk two names", t == Rwalk and struct.unpack("<H", b[:2])[0] == 2, t)

    t, _, b = c.walk(0, 4, ["nosuch"])
    check("Twalk failing on the first name is Rerror",
          t == Rerror and rerror(b)[1] == E.ENOENT, rerror(b) if t == Rerror else t)

    t, _, b = c.walk(0, 5, ["sub", "nosuch"])
    check("Twalk failing later returns a short Rwalk",
          t == Rwalk and struct.unpack("<H", b[:2])[0] == 1, t)
    t, _, _ = c.clunk(5)
    check("a short Twalk establishes no fid", t == Rerror, t)

    t, _, b = c.walk(0, 6, ["..", "..", ".."])
    check("walking .. out of the root stays at the root", t == Rwalk, t)
    t, _, b = c.stat(6)
    st, _ = unstat(b, 2)
    check("root after .. is still the root", st["mode"] & DMDIR, hex(st["mode"]))

    t, _, b = c.stat(2)
    st, _ = unstat(b, 2)
    check("Tstat name", st["name"] == "hello", st["name"])
    check("Tstat length", st["length"] == 13, st["length"])
    check("Tstat uid string", st["uid"] == "root", st["uid"])
    check("Tstat n_uid present (.u)", st.get("n_uid") == 0, st.get("n_uid"))

    t, _, b = c.walk(0, 7, ["link"])
    t, _, b = c.stat(7)
    st, _ = unstat(b, 2)
    check("symlink is DMSYMLINK", st["mode"] & DMSYMLINK, hex(st["mode"]))
    check("symlink qid type", st["qid"][0] & QTSYMLINK, hex(st["qid"][0]))
    check("symlink target in extension", st.get("ext") == "hello", st.get("ext"))

    # A symlink pointing outside is described, never followed: opening it is
    # where the export could leak, and O_NOFOLLOW is what stops that.
    t, _, b = c.walk(0, 8, ["escape"])
    check("symlink out of the tree can be walked (lstat, not stat)", t == Rwalk, t)
    t, _, b = c.open(8)
    check("opening it is refused", t == Rerror, t)

    t, _, b = c.walk(0, 9, ["sub/deep"])
    check("a slash in a walk name is refused", t == Rerror, t)
    c.close()


def test_bare_9p2000(port):
    """A client that negotiated 9P2000 must get 9P2000 ON THE WIRE, not .u
    with the extra fields tacked on.  The first version of the server agreed
    to 9P2000 and kept sending extension/n_uid/n_gid/n_muid anyway; our own
    selftest could not see it because it parses both, and 9fans.net/go/plan9
    -- the Plan 9 client, which speaks 9P2000 and nothing else -- reported
    `malformed Dir' on the first Tstat."""
    c = Client(port)
    check("9P2000 negotiates as itself", c.version("9P2000")[1] == "9P2000")
    c.attach(0)
    c.walk(0, 1, ["hello"])
    t, _, b = c.stat(1)
    size = struct.unpack("<H", b[2:4])[0]
    st, end = unstat(b, 2)
    check("a 9P2000 stat entry stops at muid", "ext" not in st, st)
    check("and its size field agrees", end == 4 + size, (end, size))
    check("Tstat wrapper size agrees", struct.unpack("<H", b[:2])[0] == size + 2)
    t, _, b = c.clunk(77)
    check("a 9P2000 Rerror carries no errno", t == Rerror and len(b) == 2 + struct.unpack("<H", b[:2])[0],
          len(b))
    c.close()


def test_read(port):
    c = Client(port)
    c.version()
    c.attach(0)
    c.walk(0, 1, ["hello"])
    t, _, b = c.open(1)
    check("Topen a file", t == Ropen, t)
    iounit = struct.unpack("<I", b[13:17])[0]
    check("Ropen iounit fits the msize", 0 < iounit <= 8216, iounit)
    t, _, b = c.read(1, 0, 100)
    n = struct.unpack("<I", b[:4])[0]
    check("Tread returns the file", b[4:4 + n] == b"hello, world\n", b[4:4 + n])
    t, _, b = c.read(1, 7, 5)
    n = struct.unpack("<I", b[:4])[0]
    check("Tread honours the offset", b[4:4 + n] == b"world", b[4:4 + n])
    t, _, b = c.read(1, 1000, 10)
    check("Tread past EOF is a zero count", struct.unpack("<I", b[:4])[0] == 0)

    # A read larger than the negotiated message must come back capped, not
    # truncate the reply frame.
    c.walk(0, 2, ["sub", "deep"])
    c.open(2)
    t, _, b = c.read(2, 0, 100000)
    n = struct.unpack("<I", b[:4])[0]
    check("a huge Tread is capped to the msize", 0 < n <= 8216 - 24, n)

    t, _, b = c.write(1, 0, b"nope")
    check("Twrite on a read-only share is EROFS",
          t == Rerror and rerror(b)[1] == E.EROFS, rerror(b) if t == Rerror else t)
    c.close()


def test_readdir(port):
    c = Client(port)
    c.version()
    c.attach(0)
    c.walk(0, 1, [])
    t, _, b = c.open(1)
    check("Topen a directory", t == Ropen, t)

    names, offs, off = [], [], 0
    while True:
        t, _, b = c.read(1, off, 200)     # small on purpose: forces several reads
        n = struct.unpack("<I", b[:4])[0]
        if n == 0:
            break
        data, i = b[4:4 + n], 0
        while i < len(data):
            st, i = unstat(data, i)
            names.append(st["name"])
        offs.append(off)
        off += n
    check("directory read lists every entry",
          sorted(names) == sorted(["sub", "hello", "a_very_long_filename",
                                   "link", "escape"]), names)
    check("directory read needed more than one Tread", len(offs) > 1, offs)
    check("no . or .. in a 9P directory read",
          "." not in names and ".." not in names, names)

    t, _, b = c.read(1, 3, 200)
    check("a non-boundary directory offset is EINVAL",
          t == Rerror and rerror(b)[1] == E.EINVAL, rerror(b) if t == Rerror else t)
    t, _, b = c.read(1, 0, 200)
    check("offset 0 rewinds", struct.unpack("<I", b[:4])[0] > 0)

    t, _, b = c.walk(1, 20, ["hello"])
    check("walking an open fid is refused", t == Rerror, t)
    c.close()


def test_dirsiz(port, strictport):
    c = Client(port)
    c.version()
    c.attach(0)
    t, _, b = c.walk(0, 1, ["a_very_long_fi"])       # exactly 14 bytes
    check("a 14-byte truncated name resolves", t == Rwalk, t)
    t, _, b = c.walk(0, 2, ["a_very_long_f"])        # 13 -- never truncated
    check("a 13-byte prefix does not", t == Rerror, t)
    c.close()

    c = Client(strictport)
    c.version()
    c.attach(0)
    t, _, b = c.walk(0, 1, ["a_very_long_fi"])
    check("-T turns the fallback off", t == Rerror, t)
    c.close()


def test_write(root, port):
    c = Client(port)
    c.version()
    c.attach(0)
    c.walk(0, 1, [])
    t, _, b = c.create(1, "made", 0o644, ORDWR)
    check("Tcreate a file", t == Rcreate, t)
    check("the file is there", os.path.exists(os.path.join(root, "made")))
    t, _, b = c.write(1, 0, b"written\n")
    check("Twrite reports the count",
          t == Rwrite and struct.unpack("<I", b[:4])[0] == 8, t)
    check("and it landed", open(os.path.join(root, "made")).read() == "written\n")
    t, _, b = c.read(1, 0, 100)
    n = struct.unpack("<I", b[:4])[0]
    check("read back through the same fid", b[4:4 + n] == b"written\n", b[4:4 + n])
    c.clunk(1)

    c.walk(0, 2, [])
    t, _, b = c.create(2, "adir", DMDIR | 0o755, OREAD)
    check("Tcreate a directory", t == Rcreate, t)
    check("mkdir happened", os.path.isdir(os.path.join(root, "adir")))
    c.clunk(2)

    c.walk(0, 3, [])
    t, _, b = c.create(3, "alink", DMSYMLINK | 0o777, OREAD, "target")
    check("Tcreate a symlink (.u)", t == Rcreate, t)
    check("symlink points where asked",
          os.readlink(os.path.join(root, "alink")) == "target")
    c.clunk(3)

    # wstat: rename, chmod, truncate
    c.walk(0, 4, ["made"])
    body = wstat_entry(name="renamed")
    t, _, b = c.rpc(Twstat, struct.pack("<I", 4) + struct.pack("<H", len(body)) + body)
    check("Twstat renames", t == Rwstat, rerror(b) if t == Rerror else t)
    check("the new name exists", os.path.exists(os.path.join(root, "renamed")))
    check("the old name is gone", not os.path.exists(os.path.join(root, "made")))

    body = wstat_entry(mode=0o600)
    t, _, b = c.rpc(Twstat, struct.pack("<I", 4) + struct.pack("<H", len(body)) + body)
    check("Twstat chmods", t == Rwstat, rerror(b) if t == Rerror else t)
    check("mode took", (os.stat(os.path.join(root, "renamed")).st_mode & 0o777) == 0o600)

    body = wstat_entry(length=3)
    t, _, b = c.rpc(Twstat, struct.pack("<I", 4) + struct.pack("<H", len(body)) + body)
    check("Twstat truncates", t == Rwstat, rerror(b) if t == Rerror else t)
    check("length took", os.stat(os.path.join(root, "renamed")).st_size == 3)

    t, _, b = c.remove(4)
    check("Tremove", t == Rremove, t)
    check("the file is gone", not os.path.exists(os.path.join(root, "renamed")))
    t, _, b = c.clunk(4)
    check("Tremove clunked the fid too", t == Rerror, t)

    c.walk(0, 5, [])
    t, _, b = c.remove(5)
    check("the export root cannot be removed", t == Rerror, t)
    c.close()


def wstat_entry(name="", mode=NOTOUCH4, atime=NOTOUCH4, mtime=NOTOUCH4,
                length=NOTOUCH8):
    """A Twstat entry with everything not named left untouched."""
    body = struct.pack("<HI", NOTOUCH2, NOTOUCH4)
    body += bytes([0xFF]) + struct.pack("<IQ", NOTOUCH4, NOTOUCH8)   # qid
    body += struct.pack("<IIIQ", mode, atime, mtime, length)
    body += pstr(name) + pstr("") + pstr("") + pstr("")
    body += pstr("") + struct.pack("<III", NOTOUCH4, NOTOUCH4, NOTOUCH4)
    return struct.pack("<H", len(body)) + body


def test_badmsg(port):
    c = Client(port)
    c.version()
    c.attach(0)
    t, _, b = c.rpc(66, b"")
    check("an unknown message type is refused", t == Rerror, t)
    # A Twalk whose body stops short must be EPROTO, not a traceback.
    t, _, b = c.rpc(Twalk, struct.pack("<II", 0, 30) + b"\x05\x00")
    check("a truncated message is EPROTO",
          t == Rerror and rerror(b)[1] == E.EPROTO, rerror(b) if t == Rerror else t)
    c.close()


def main():
    tmp = tempfile.mkdtemp(prefix="9pfsd-selftest.")
    ro = os.path.join(tmp, "ro")
    rw = os.path.join(tmp, "rw")
    os.makedirs(ro)
    os.makedirs(rw)
    make_tree(ro)
    procs = []
    try:
        p1, p2, p3 = freeport(), freeport(), freeport()
        procs.append(start(ro, p1))
        procs.append(start(ro, p2, ["-T"]))
        procs.append(start(rw, p3, ["-w"]))
        print("session")
        test_session(p1)
        print("walk and stat")
        test_walk_stat(p1)
        print("bare 9P2000")
        test_bare_9p2000(p1)
        print("read")
        test_read(p1)
        print("directory read")
        test_readdir(p1)
        print("the 14-byte fallback")
        test_dirsiz(p1, p2)
        print("write, create, wstat, remove")
        test_write(rw, p3)
        print("malformed input")
        test_badmsg(p1)
    finally:
        for p in procs:
            p.terminate()
            try:
                p.wait(timeout=5)
            except Exception:
                p.kill()
        shutil.rmtree(tmp, ignore_errors=True)

    print("\n%d checks passed, %d failed" % (PASS[0], len(FAIL)))
    for name, detail in FAIL:
        print("  FAIL %s %s" % (name, detail))
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
