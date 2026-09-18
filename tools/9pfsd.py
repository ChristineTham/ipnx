#!/usr/bin/env python3
"""9pfsd -- serve a directory to Research Unix over 9P2000.u.

    tools/9pfsd.py [-p port] [-w] [-v] [-u uid] [-g gid] [-m msize] [-T] <dir>

      -p  TCP port on 127.0.0.1 (default 9200)
      -w  read/write; the default is READ-ONLY and the absence of -w is the
          whole guard, exactly as it was for netfsd
      -v  trace every message
      -u  uid to present every file as (default 0)
      -g  gid to present every file as (default 0)
      -m  largest message to negotiate (default 8216 = 8192 + IOHDRSZ)
      -T  strict 9P: no 14-byte name fallback (see DIRSIZ below)
      -L  follow symlinks instead of describing them (see SYMLINKS below)

The guest reaches this at 10.0.2.2:<port>.  Nothing is forwarded: SLiRP
rewrites every address inside its virtual network to host loopback, so
10.0.2.2 IS 127.0.0.1 as far as a connection is concerned.

WHY 9P AND NOT netfs.  netfs was Weinberger's, it is in every V8 and V10
kernel, and it was never going to be in anything else -- one protocol, one
client, and a server we had to write twice (Swift for the app, python3 for a
host without Swift) with a 563-line specification standing between them to
keep the two honest.  9P is the same idea with a published wire format and
other implementations to check ours against.  The cost is that the guest needs
a client, because there is none: v10/usr/src/cmd/u9fs is a 9P *server* that
Bell Labs ran on V10 to serve Plan 9 machines, and it speaks the original
protocol (Tclone/Tclwalk/Tsession, NAMELEN 28, a fixed 116-byte Dir), not
9P2000.  v10/usr/sys/fs/net9.c is that client.

WHY 9P2000.u AND NOT 9P2000 OR 9P2000.L.  The deciding field is Rerror's.
Plain 9P2000 returns only a string, and the client half of this is a 1989
kernel whose entire error convention is `u.u_error = <errno>' -- netb.c:481
takes the number straight off the wire and assigns it.  A string would have to
be parsed back into an errno in kernel space, which is absurd.  9P2000.u adds
a numeric errno to Rerror and numeric n_uid/n_gid to stat, which is exactly the
Unix-shaped dialect this needs.  9P2000.L would also do that, and diod (the
one 9P server Ubuntu packages) speaks it -- but .L is three times the protocol
surface, it is Linux-shaped rather than Unix-shaped, and diod does not run on
macOS or inside an iPad, which are this project's actual hosts.  Measured, so
that nobody re-opens this by guessing: diod 1.0.24 answers Tversion("9P2000")
and Tversion("9P2000.u") alike with Rlerror EIO, and only "9P2000.L" gets an
Rversion.

SYMLINKS, AND WHY -L EXISTS.  9P2000.u can describe a symlink -- DMSYMLINK
with the target in the extension field -- and by default this server does,
because that is what the dialect is for.  The guest cannot use it.  netb's
<rf.h> gives an Rfile exactly two types, RFTREG and RFTDIR, so 9pfs.c has
nowhere to put a third; it maps DMSYMLINK to a regular file, and then the
Topen fails because a walk here never resolves a final symlink and the open
carries O_NOFOLLOW.  The result is a file the guest can see and cannot read.
With -L the server stats THROUGH a symlink instead, so the guest sees the
target as an ordinary file or directory and never learns a link was involved
-- which is what netfsd did and what u9fs does.  Containment is checked on the
RESOLVED path in that mode, because following is exactly the operation that
could otherwise leave the export.  A dangling link still appears, described as
the broken link it is, rather than failing the whole directory read.

DIRSIZ, AND THE ONE PLACE THIS IS NOT STRICT 9P.  V10's `struct direct' has a
14-byte name field, so the client cannot hand userland a longer name than
that, so a user who types what `ls' printed sends us a truncated name to walk.
netfsd had the same problem and solved it the same way.  With -T that fallback
is off and the server is strict, which is what the selftest uses when it is
checking conformance rather than behaviour.

WHAT IS DELIBERATELY NOT HERE: authentication.  Tauth is answered with
Rerror("no authentication required"), which is what a server without an auth
server is supposed to say, and Tattach proceeds regardless.  The share is
bound to 127.0.0.1 and reachable only from inside this process's own simulated
network; that is the same guard netfsd had and it is the one that matters.
"""

import errno as E
import os
import socket
import stat as S
import struct
import sys
import threading

# ---------------------------------------------------------------- protocol --
# Message types.  9P2000 numbers T-messages even and R-messages odd from 100.
Tversion, Rversion = 100, 101
Tauth,    Rauth    = 102, 103
Tattach,  Rattach  = 104, 105
Terror,   Rerror   = 106, 107          # 106 is illegal and never sent
Tflush,   Rflush   = 108, 109
Twalk,    Rwalk    = 110, 111
Topen,    Ropen    = 112, 113
Tcreate,  Rcreate  = 114, 115
Tread,    Rread    = 116, 117
Twrite,   Rwrite   = 118, 119
Tclunk,   Rclunk   = 120, 121
Tremove,  Rremove  = 122, 123
Tstat,    Rstat    = 124, 125
Twstat,   Rwstat   = 126, 127

TNAME = {
    Tversion: "Tversion", Tauth: "Tauth", Tattach: "Tattach", Tflush: "Tflush",
    Twalk: "Twalk", Topen: "Topen", Tcreate: "Tcreate", Tread: "Tread",
    Twrite: "Twrite", Tclunk: "Tclunk", Tremove: "Tremove", Tstat: "Tstat",
    Twstat: "Twstat",
}

NOTAG  = 0xFFFF
NOFID  = 0xFFFFFFFF
MAXWELEM = 16                   # most names one Twalk may carry

# qid.type
QTDIR, QTAPPEND, QTEXCL, QTMOUNT = 0x80, 0x40, 0x20, 0x10
QTAUTH, QTTMP, QTSYMLINK, QTFILE = 0x08, 0x04, 0x02, 0x00

# stat.mode -- the high bits.  The bottom nine are rwxrwxrwx unchanged.
DMDIR       = 0x80000000
DMAPPEND    = 0x40000000
DMEXCL      = 0x20000000
DMMOUNT     = 0x10000000
DMAUTH      = 0x08000000
DMTMP       = 0x04000000
DMSYMLINK   = 0x02000000        # .u
DMDEVICE    = 0x00800000        # .u
DMNAMEDPIPE = 0x00200000        # .u
DMSOCKET    = 0x00100000        # .u
DMSETUID    = 0x00080000        # .u
DMSETGID    = 0x00040000        # .u

# Topen/Tcreate mode
OREAD, OWRITE, ORDWR, OEXEC = 0, 1, 2, 3
OTRUNC, ORCLOSE = 0x10, 0x40

VERSION = "9P2000.u"
IOHDRSZ = 24                    # Twrite header: size+type+tag+fid+offset+count
DEFMSIZE = 8192 + IOHDRSZ

# "do not touch" -- every fixed-width field of a Twstat may be filled with 1s
# to mean `leave this alone'.  A zero would mean midnight 1970 or a zero-length
# file, so the distinction is not cosmetic.
NOTOUCH2, NOTOUCH4, NOTOUCH8 = 0xFFFF, 0xFFFFFFFF, 0xFFFFFFFFFFFFFFFF

DIRSIZ = 14                     # V10 <sys/dir.h>


class NineError(Exception):
    """An Rerror to send back.  `num' is what .u puts on the wire."""

    def __init__(self, num, text=None):
        self.num = num
        self.text = text or os.strerror(num)
        Exception.__init__(self, self.text)


def oserror(exc):
    """Turn an OSError into the Rerror we owe the client."""
    num = exc.errno if exc.errno else E.EIO
    return NineError(num, exc.strerror or os.strerror(num))


# ---------------------------------------------------------------- encoding --
# Everything is little-endian.  A string is a 2-byte count and that many bytes
# of UTF-8 with no terminator; 9P has no NUL anywhere.

class Buf(object):
    """A message being built."""

    def __init__(self):
        self.b = bytearray()

    def u8(self, v):    self.b += struct.pack("<B", v & 0xFF); return self
    def u16(self, v):   self.b += struct.pack("<H", v & 0xFFFF); return self
    def u32(self, v):   self.b += struct.pack("<I", v & 0xFFFFFFFF); return self
    def u64(self, v):   self.b += struct.pack("<Q", v & 0xFFFFFFFFFFFFFFFF); return self
    def raw(self, v):   self.b += v; return self

    def string(self, s):
        if isinstance(s, str):
            s = s.encode("utf-8", "surrogateescape")
        self.u16(len(s))
        self.b += s
        return self

    def qid(self, q):
        self.u8(q[0]).u32(q[1]).u64(q[2])
        return self


class Parse(object):
    """A message being taken apart.  Runs off the end -> EPROTO, not IndexError."""

    def __init__(self, data):
        self.d = data
        self.i = 0

    def need(self, n):
        if self.i + n > len(self.d):
            raise NineError(E.EPROTO, "short message")
        s = self.i
        self.i += n
        return self.d[s:self.i]

    def u8(self):  return struct.unpack("<B", self.need(1))[0]
    def u16(self): return struct.unpack("<H", self.need(2))[0]
    def u32(self): return struct.unpack("<I", self.need(4))[0]
    def u64(self): return struct.unpack("<Q", self.need(8))[0]

    def string(self):
        return self.need(self.u16()).decode("utf-8", "surrogateescape")

    def rest(self):
        s = self.i
        self.i = len(self.d)
        return self.d[s:]


# -------------------------------------------------------------------- fids --

class Fid(object):
    """One client handle.  `path' is always an absolute host path inside the
    export; containment is checked when a walk creates it, not when it is
    used, so a fid cannot outlive its own validity by being held."""

    __slots__ = ("path", "qid", "mode", "f", "dirents", "diroffs", "rclose")

    def __init__(self, path, qid):
        self.path = path
        self.qid = qid
        self.mode = None        # None until Topen/Tcreate succeeds
        self.f = None           # open file object, for a regular file
        self.dirents = None     # snapshot: list of encoded stat entries
        self.diroffs = None     # cumulative byte offsets into that snapshot
        self.rclose = False     # ORCLOSE: remove on clunk

    def close(self):
        if self.f is not None:
            try:
                self.f.close()
            except Exception:
                pass
            self.f = None


# ------------------------------------------------------------------ export --

class Export(object):
    """The served directory, and every policy decision about it."""

    def __init__(self, cfg):
        self.root = cfg["root"]
        # THE DENSE qid.path TABLE, AND WHY IT IS BACK.  9P's qid.path is 8
        # bytes and (st_dev,st_ino) would fit it with room to spare, which is
        # what this server did first.  The guest cannot use it.  V10's ino_t is
        # `unsigned short' (sys/types.h:40), so `struct direct' is 16 bytes and
        # `struct stat' carries a 16-bit st_ino -- a client handed a 64-bit
        # path has to fold it, and folding 10,000 files into 16 bits collides
        # about as often as not.  So the paths are handed out dense and small,
        # from 3 upward, exactly as netfsd's synthetic inode namespace did and
        # for exactly the same reason.  2 is reserved: param.h:51 is
        # `#define ROOTINO ((ino_t)2) /* i number of all roots */' and every
        # mounted root must carry it.
        self.qidpaths = {}
        self.nextpath = 3
        self.qidlock = threading.Lock()
        self.readonly = cfg["readonly"]
        self.uid = cfg["uid"]
        self.gid = cfg["gid"]
        self.strict = cfg["strict"]
        self.follow = cfg["follow"]
        self.uname = "root" if self.uid == 0 else str(self.uid)
        self.gname = "root" if self.gid == 0 else str(self.gid)
        rst = os.lstat(self.root)
        self.qidpaths[(rst.st_dev, rst.st_ino)] = 2      # ROOTINO

    # -- containment ------------------------------------------------------
    def contains(self, path):
        """Is `path' inside the export?  Compared on the REALPATH OF ITS
        PARENT plus the final component, never on realpath(path) itself: the
        second resolves a final symlink, so a symlink to /etc/shadow would
        test as outside and be refused even though 9P2000.u represents it as
        a symlink and never follows it.  The parent test is the one that
        stops a walk escaping."""
        parent = os.path.dirname(path)
        try:
            rp = os.path.realpath(parent)
        except OSError:
            return False
        if rp != self.root and not rp.startswith(self.root + os.sep):
            return False
        return True

    def wr(self):
        """The read-only guard.  Called by every mutating operation, and the
        absence of -w is the whole of it."""
        if self.readonly:
            raise NineError(E.EROFS, "read-only share")

    # -- names ------------------------------------------------------------
    def walk1(self, path, name):
        """One element of a walk.  Returns the new host path."""
        if name == "" or "/" in name:
            raise NineError(E.EINVAL, "bad walk name")
        if name == ".":
            return path
        if name == "..":
            # A walk out of the root stays at the root.  That is the 9P
            # convention for an exported tree and it is also the containment
            # guarantee: no sequence of ".." can climb out.
            if path == self.root:
                return path
            return os.path.dirname(path)
        new = os.path.join(path, name)
        if not self.contains(new):
            raise NineError(E.EACCES, "outside the export")
        try:
            os.lstat(new)
            if self.follow and not self.inside(new):
                raise NineError(E.EACCES, "symlink leaves the export")
            return new
        except OSError as exc:
            if exc.errno != E.ENOENT:
                raise oserror(exc)
        # THE 14-BYTE FALLBACK.  V10's struct direct holds 14 bytes of name,
        # so `ls' printed a truncated one and the user typed it back at us.
        # Only ever tried for a name that is exactly DIRSIZ long, because a
        # shorter one was not truncated and a longer one cannot have come from
        # this guest.  Ambiguity is refused rather than guessed: two files
        # sharing a 14-byte prefix get ENOENT, which is at least honest.
        if self.strict or len(name) != DIRSIZ:
            raise NineError(E.ENOENT, "no such file")
        try:
            hits = [n for n in os.listdir(path) if n[:DIRSIZ] == name]
        except OSError as exc:
            raise oserror(exc)
        if len(hits) != 1:
            raise NineError(E.ENOENT, "no such file")
        return os.path.join(path, hits[0])

    # -- attributes -------------------------------------------------------
    def lstat(self, path):
        """The stat every other method uses.  With -L this follows a symlink
        and falls back to the link itself when the target is missing, so a
        dangling link is reported rather than turning a directory read into an
        error."""
        try:
            if self.follow:
                try:
                    return os.stat(path)
                except OSError:
                    return os.lstat(path)
            return os.lstat(path)
        except OSError as exc:
            raise oserror(exc)

    def inside(self, path):
        """Is the FULLY RESOLVED path inside the export?  Only asked in -L
        mode, where following a link is the one operation that can leave."""
        try:
            rp = os.path.realpath(path)
        except OSError:
            return False
        return rp == self.root or rp.startswith(self.root + os.sep)

    def qid(self, st):
        """qid.path must be unique per file for the life of the server and
        qid.version must change when the contents do.  The table above gives
        the first, small enough for the guest to use as an i-number; mtime
        gives the second."""
        t = QTFILE
        if S.S_ISDIR(st.st_mode):
            t = QTDIR
        elif S.S_ISLNK(st.st_mode):
            t = QTSYMLINK
        key = (st.st_dev, st.st_ino)
        path = self.qidpaths.get(key)
        if path is None:
            with self.qidlock:
                path = self.qidpaths.get(key)
                if path is None:
                    path = self.nextpath
                    self.nextpath += 1
                    self.qidpaths[key] = path
        return (t, int(st.st_mtime) & 0xFFFFFFFF, path)

    def mode(self, st):
        m = st.st_mode & 0o777
        if S.S_ISDIR(st.st_mode):
            m |= DMDIR
        elif S.S_ISLNK(st.st_mode):
            m |= DMSYMLINK
        elif S.S_ISCHR(st.st_mode) or S.S_ISBLK(st.st_mode):
            m |= DMDEVICE
        elif S.S_ISFIFO(st.st_mode):
            m |= DMNAMEDPIPE
        elif S.S_ISSOCK(st.st_mode):
            m |= DMSOCKET
        if st.st_mode & S.S_ISUID:
            m |= DMSETUID
        if st.st_mode & S.S_ISGID:
            m |= DMSETGID
        return m

    def extension(self, path, st):
        """.u's one variable-width attribute: a symlink's target, or a device's
        kind and numbers as `c major minor'."""
        if S.S_ISLNK(st.st_mode):
            try:
                return os.readlink(path)
            except OSError:
                return ""
        if S.S_ISCHR(st.st_mode) or S.S_ISBLK(st.st_mode):
            kind = "c" if S.S_ISCHR(st.st_mode) else "b"
            return "%s %d %d" % (kind, os.major(st.st_rdev), os.minor(st.st_rdev))
        return ""

    def stat_bytes(self, path, st, name=None, dotu=True):
        """One machine-independent stat entry, its own 2-byte size included.
        The size counts everything after itself, which is why this is built
        into a scratch buffer and measured rather than computed.

        THE .u FIELDS ARE CONDITIONAL AND THAT IS NOT COSMETIC.  A stat entry
        under bare 9P2000 ends at muid; .u adds extension/n_uid/n_gid/n_muid.
        Sending the longer form to a client that agreed to the shorter one is
        a wire bug with no symptom on our side -- the first version of this
        file did exactly that, and it was 9fans.net/go/plan9, which speaks
        9P2000 and nothing else, that said `malformed Dir' and found it.  That
        is the whole argument for a protocol other people implement.
        """
        if name is None:
            name = os.path.basename(path) or "/"
        body = Buf()
        body.u16(0)                       # type[2]   -- for kernel use
        body.u32(0)                       # dev[4]    -- for kernel use
        body.qid(self.qid(st))
        body.u32(self.mode(st))
        body.u32(int(st.st_atime) & 0xFFFFFFFF)
        body.u32(int(st.st_mtime) & 0xFFFFFFFF)
        body.u64(st.st_size if not S.S_ISDIR(st.st_mode) else 0)
        body.string(name)
        body.string(self.uname)
        body.string(self.gname)
        body.string(self.uname)           # muid
        if dotu:
            body.string(self.extension(path, st))
            body.u32(self.uid)            # n_uid
            body.u32(self.gid)            # n_gid
            body.u32(self.uid)            # n_muid
        out = Buf()
        out.u16(len(body.b))
        out.raw(body.b)
        return bytes(out.b)


# -------------------------------------------------------------- connection --

class Conn(object):
    """One client.  9P allows many outstanding messages distinguished by tag;
    this server answers them one at a time in arrival order, which is legal
    (a server may finish requests in any order it likes, including this one)
    and is all the guest asks for -- netb.c serialises on NBUSY and the net9
    client inherits that, so there is never more than one T-message in
    flight."""

    def __init__(self, sock, export, cfg):
        self.sock = sock
        self.ex = export
        self.verbose = cfg["verbose"]
        self.msize = cfg["msize"]
        self.dotu = True          # until Tversion says otherwise
        self.fids = {}

    # -- framing ----------------------------------------------------------
    def recv_exact(self, n):
        out = bytearray()
        while len(out) < n:
            chunk = self.sock.recv(n - len(out))
            if not chunk:
                return None
            out += chunk
        return bytes(out)

    def recv_msg(self):
        hdr = self.recv_exact(4)
        if hdr is None:
            return None
        size = struct.unpack("<I", hdr)[0]
        if size < 7 or size > self.msize + IOHDRSZ:
            raise NineError(E.EPROTO, "message size %d out of range" % size)
        body = self.recv_exact(size - 4)
        if body is None:
            return None
        typ, tag = struct.unpack("<BH", body[:3])
        return typ, tag, body[3:]

    def reply(self, typ, tag, body=b""):
        msg = struct.pack("<IBH", 7 + len(body), typ, tag) + bytes(body)
        self.sock.sendall(msg)

    def reply_error(self, tag, err):
        b = Buf().string(err.text)
        if self.dotu:
            b.u32(err.num)
        self.reply(Rerror, tag, b.b)

    # -- fids -------------------------------------------------------------
    def get(self, fid):
        f = self.fids.get(fid)
        if f is None:
            raise NineError(E.EBADF, "unknown fid")
        return f

    def clunk(self, fid):
        f = self.fids.pop(fid, None)
        if f is not None:
            f.close()
        return f

    # -- loop -------------------------------------------------------------
    def serve(self):
        try:
            while True:
                try:
                    msg = self.recv_msg()
                except NineError as err:
                    # A framing error has no tag we can trust; say so and go.
                    self.reply_error(NOTAG, err)
                    return
                if msg is None:
                    return
                typ, tag, body = msg
                try:
                    self.dispatch(typ, tag, body)
                except NineError as err:
                    if self.verbose:
                        sys.stderr.write("  -> Rerror %s (%d)\n" % (err.text, err.num))
                    self.reply_error(tag, err)
                except OSError as exc:
                    err = oserror(exc)
                    if self.verbose:
                        sys.stderr.write("  -> Rerror %s (%d)\n" % (err.text, err.num))
                    self.reply_error(tag, err)
        except (socket.error, OSError):
            pass
        finally:
            for f in list(self.fids.values()):
                f.close()
            self.fids.clear()
            try:
                self.sock.close()
            except Exception:
                pass

    def dispatch(self, typ, tag, body):
        if self.verbose:
            sys.stderr.write("%s tag=%d\n" % (TNAME.get(typ, "T?%d" % typ), tag))
        p = Parse(body)
        if typ == Tversion:  return self.do_version(tag, p)
        if typ == Tauth:     raise NineError(E.EPERM, "no authentication required")
        if typ == Tattach:   return self.do_attach(tag, p)
        if typ == Tflush:    return self.do_flush(tag, p)
        if typ == Twalk:     return self.do_walk(tag, p)
        if typ == Topen:     return self.do_open(tag, p)
        if typ == Tcreate:   return self.do_create(tag, p)
        if typ == Tread:     return self.do_read(tag, p)
        if typ == Twrite:    return self.do_write(tag, p)
        if typ == Tclunk:    return self.do_clunk(tag, p)
        if typ == Tremove:   return self.do_remove(tag, p)
        if typ == Tstat:     return self.do_stat(tag, p)
        if typ == Twstat:    return self.do_wstat(tag, p)
        raise NineError(E.ENOTSUP, "unknown message type %d" % typ)

    # -- session ----------------------------------------------------------
    def do_version(self, tag, p):
        msize = p.u32()
        ver = p.string()
        # Tversion resets the connection: every fid is forgotten.
        for f in list(self.fids.values()):
            f.close()
        self.fids.clear()
        self.msize = max(256, min(msize, self.msize))
        # A version we do not speak is answered "unknown", which is the
        # protocol's own way of saying no -- not an Rerror.  A client offering
        # 9P2000.L gets that and may then offer 9P2000.u.
        if ver == VERSION or ver.startswith(VERSION + "."):
            out, self.dotu = VERSION, True
        elif ver == "9P2000":
            # Bare 9P2000 is a subset we can serve, but the client then has no
            # numeric errno and no extension field.  Accept it; the client
            # chose, and every reply from here on is the shorter form.
            out, self.dotu = "9P2000", False
        else:
            out, self.dotu = "unknown", False
        self.reply(Rversion, tag, Buf().u32(self.msize).string(out).b)

    def do_attach(self, tag, p):
        fid = p.u32()
        p.u32()                      # afid -- no authentication, see docstring
        p.string()                   # uname
        p.string()                   # aname
        if fid in self.fids:
            raise NineError(E.EBADF, "fid in use")
        st = self.ex.lstat(self.ex.root)
        q = self.ex.qid(st)
        self.fids[fid] = Fid(self.ex.root, q)
        self.reply(Rattach, tag, Buf().qid(q).b)

    def do_flush(self, tag, p):
        # Every request is finished before the next is read, so the message
        # being flushed is already answered.  An immediate Rflush is correct.
        p.u16()
        self.reply(Rflush, tag)

    # -- namespace --------------------------------------------------------
    def do_walk(self, tag, p):
        fid = p.u32()
        newfid = p.u32()
        n = p.u16()
        if n > MAXWELEM:
            raise NineError(E.EINVAL, "too many walk elements")
        names = [p.string() for _ in range(n)]
        f = self.get(fid)
        if f.mode is not None:
            raise NineError(E.EINVAL, "fid is open")
        if newfid != fid and newfid in self.fids:
            raise NineError(E.EBADF, "newfid in use")

        path, qids = f.path, []
        for i, name in enumerate(names):
            try:
                path = self.ex.walk1(path, name)
                qids.append(self.ex.qid(self.ex.lstat(path)))
            except NineError:
                # A walk that fails part-way is not an error: the client is
                # told how far it got and NO new fid is established.  It is an
                # error only if it failed on the very first element.
                if i == 0:
                    raise
                self.reply(Rwalk, tag, self._qids(qids))
                return
        if len(qids) == len(names):
            nf = Fid(path, qids[-1] if qids else f.qid)
            self.fids[newfid] = nf
        self.reply(Rwalk, tag, self._qids(qids))

    @staticmethod
    def _qids(qids):
        b = Buf().u16(len(qids))
        for q in qids:
            b.qid(q)
        return b.b

    def do_stat(self, tag, p):
        f = self.get(p.u32())
        st = self.ex.lstat(f.path)
        name = "/" if f.path == self.ex.root else os.path.basename(f.path)
        sb = self.ex.stat_bytes(f.path, st, name, self.dotu)
        self.reply(Rstat, tag, Buf().u16(len(sb)).raw(sb).b)

    # -- opening ----------------------------------------------------------
    def do_open(self, tag, p):
        fid = p.u32()
        mode = p.u8()
        f = self.get(fid)
        if f.mode is not None:
            raise NineError(E.EINVAL, "already open")
        st = self.ex.lstat(f.path)
        acc = mode & 3
        if acc in (OWRITE, ORDWR) or (mode & OTRUNC) or (mode & ORCLOSE):
            self.ex.wr()
        if S.S_ISDIR(st.st_mode):
            if acc != OREAD or (mode & OTRUNC):
                raise NineError(E.EISDIR, "directory")
            self._opendir(f)
        else:
            flags = {OREAD: os.O_RDONLY, OWRITE: os.O_WRONLY,
                     ORDWR: os.O_RDWR, OEXEC: os.O_RDONLY}[acc]
            if mode & OTRUNC:
                flags |= os.O_TRUNC
            # O_NOFOLLOW: a walk never resolves a final symlink (lstat), so
            # opening one here would be the one place the export could be
            # escaped through a link the client can see but must not follow.
            # In -L mode the link was resolved and containment-checked at walk
            # time, so following it here is the whole point.
            if not self.ex.follow:
                flags |= getattr(os, "O_NOFOLLOW", 0)
            try:
                fd = os.open(f.path, flags)
                f.f = os.fdopen(fd, "r+b" if acc in (ORDWR, OWRITE) else "rb")
            except OSError as exc:
                raise oserror(exc)
        f.mode = mode
        f.rclose = bool(mode & ORCLOSE)
        f.qid = self.ex.qid(self.ex.lstat(f.path))
        self.reply(Ropen, tag, Buf().qid(f.qid).u32(self.msize - IOHDRSZ).b)

    def _opendir(self, f):
        """SNAPSHOT THE DIRECTORY AT OPEN, and serve reads out of the
        snapshot.  9P requires that a Tread at the offset the last Rread
        finished on continues where it left off, and that entries are never
        split across replies.  Reading the live directory each time cannot
        promise either once anything in it changes, and the guest reads a
        directory in 512-byte bites."""
        try:
            names = sorted(os.listdir(f.path))
        except OSError as exc:
            raise oserror(exc)
        # NO "." OR ".." HERE.  A 9P directory read returns only real entries;
        # the two dot names are a walk's business, not a read's.  The guest is
        # where they have to reappear, because a V10 `struct direct' reader
        # expects them -- net9.c's t_dirread synthesises the pair.
        ents, offs, pos = [], [0], 0
        for name in names:
            full = os.path.join(f.path, name)
            try:
                st = os.lstat(full)
            except OSError:
                continue            # vanished between listdir and lstat
            sb = self.ex.stat_bytes(full, st, name, self.dotu)
            ents.append(sb)
            pos += len(sb)
            offs.append(pos)
        f.dirents, f.diroffs = ents, offs

    # -- data -------------------------------------------------------------
    def do_read(self, tag, p):
        fid = p.u32()
        offset = p.u64()
        count = p.u32()
        f = self.get(fid)
        if f.mode is None:
            raise NineError(E.EINVAL, "not open")
        if (f.mode & 3) == OWRITE:
            raise NineError(E.EACCES, "opened write-only")
        count = min(count, self.msize - IOHDRSZ)
        if f.dirents is not None:
            data = self._readdir(f, offset, count)
        else:
            try:
                f.f.seek(offset)
                data = f.f.read(count)
            except OSError as exc:
                raise oserror(exc)
        self.reply(Rread, tag, Buf().u32(len(data)).raw(data).b)

    def _readdir(self, f, offset, count):
        """Offsets into a directory are opaque to the client but must be the
        ones we handed back, so they are looked up in the table built at open
        rather than arithmetic'd.  Offset 0 rewinds; anything else that is not
        an entry boundary is EINVAL, which is what the protocol asks for."""
        if offset == 0:
            idx = 0
        else:
            try:
                idx = f.diroffs.index(offset)
            except ValueError:
                raise NineError(E.EINVAL, "bad directory offset")
        out = bytearray()
        while idx < len(f.dirents) and len(out) + len(f.dirents[idx]) <= count:
            out += f.dirents[idx]
            idx += 1
        return bytes(out)

    def do_write(self, tag, p):
        fid = p.u32()
        offset = p.u64()
        count = p.u32()
        data = p.rest()[:count]
        f = self.get(fid)
        self.ex.wr()
        if f.mode is None:
            raise NineError(E.EINVAL, "not open")
        if (f.mode & 3) == OREAD:
            raise NineError(E.EACCES, "opened read-only")
        if f.dirents is not None:
            raise NineError(E.EISDIR, "directory")
        try:
            f.f.seek(offset)
            n = f.f.write(data)
            f.f.flush()
        except OSError as exc:
            raise oserror(exc)
        self.reply(Rwrite, tag, Buf().u32(n if n is not None else len(data)).b)

    # -- mutation ---------------------------------------------------------
    def do_create(self, tag, p):
        fid = p.u32()
        name = p.string()
        perm = p.u32()
        mode = p.u8()
        ext = p.string() if p.i < len(p.d) else ""
        f = self.get(fid)
        self.ex.wr()
        if f.mode is not None:
            raise NineError(E.EINVAL, "fid is open")
        if name in ("", ".", "..") or "/" in name:
            raise NineError(E.EINVAL, "bad create name")
        st = self.ex.lstat(f.path)
        if not S.S_ISDIR(st.st_mode):
            raise NineError(E.ENOTDIR, "not a directory")
        new = os.path.join(f.path, name)
        if not self.ex.contains(new):
            raise NineError(E.EACCES, "outside the export")
        bits = perm & 0o777
        try:
            if perm & DMDIR:
                os.mkdir(new, bits)
                f.path = new
                self._opendir(f)
            elif perm & DMSYMLINK:
                os.symlink(ext, new)
                f.path = new
            elif perm & DMNAMEDPIPE:
                os.mkfifo(new, bits)
                f.path = new
            elif perm & DMDEVICE:
                kind, major, minor = ext.split()
                os.mknod(new, bits | (S.S_IFCHR if kind == "c" else S.S_IFBLK),
                         os.makedev(int(major), int(minor)))
                f.path = new
            else:
                acc = mode & 3
                flags = os.O_CREAT | os.O_EXCL
                flags |= os.O_RDWR if acc in (ORDWR, OWRITE) else os.O_RDONLY
                fd = os.open(new, flags, bits)
                f.path = new
                f.f = os.fdopen(fd, "r+b" if acc in (ORDWR, OWRITE) else "rb")
        except OSError as exc:
            raise oserror(exc)
        except ValueError:
            raise NineError(E.EINVAL, "bad device extension")
        f.mode = mode
        f.rclose = bool(mode & ORCLOSE)
        f.qid = self.ex.qid(self.ex.lstat(f.path))
        self.reply(Rcreate, tag, Buf().qid(f.qid).u32(self.msize - IOHDRSZ).b)

    def do_clunk(self, tag, p):
        fid = p.u32()
        f = self.get(fid)
        rclose, path = f.rclose, f.path
        self.clunk(fid)
        if rclose and not self.ex.readonly:
            try:
                self._unlink(path)
            except Exception:
                pass            # ORCLOSE failure is not reportable: the fid is gone
        self.reply(Rclunk, tag)

    def do_remove(self, tag, p):
        fid = p.u32()
        f = self.get(fid)
        path = f.path
        # The fid is clunked whether or not the remove succeeds.  That is the
        # protocol's rule and it is easy to get wrong by returning early.
        self.clunk(fid)
        self.ex.wr()
        if path == self.ex.root:
            raise NineError(E.EACCES, "cannot remove the export root")
        self._unlink(path)
        self.reply(Rremove, tag)

    def _unlink(self, path):
        try:
            if S.S_ISDIR(os.lstat(path).st_mode):
                os.rmdir(path)
            else:
                os.unlink(path)
        except OSError as exc:
            raise oserror(exc)

    def do_wstat(self, tag, p):
        fid = p.u32()
        p.u16()                      # the wrapping size; the entry re-states it
        f = self.get(fid)
        self.ex.wr()
        s = Parse(p.rest())
        s.u16()                      # stat size
        s.u16()                      # type
        s.u32()                      # dev
        s.u8(); s.u32(); s.u64()     # qid
        mode = s.u32()
        atime = s.u32()
        mtime = s.u32()
        length = s.u64()
        name = s.string()
        s.string(); s.string(); s.string()   # uid, gid, muid -- not honoured
        # .u's extension/n_uid/n_gid/n_muid may or may not be present; a
        # client that sends a bare 9P2000 entry simply stops here.

        # RENAME FIRST, because everything after it works on the new path and
        # because a rename that fails must not leave half a wstat applied.
        if name != "":
            new = os.path.join(os.path.dirname(f.path), name)
            if "/" in name or name in (".", ".."):
                raise NineError(E.EINVAL, "bad name")
            if not self.ex.contains(new):
                raise NineError(E.EACCES, "outside the export")
            if new != f.path:
                if os.path.exists(new):
                    raise NineError(E.EEXIST, "name exists")
                try:
                    os.rename(f.path, new)
                except OSError as exc:
                    raise oserror(exc)
                f.path = new
        if mode != NOTOUCH4:
            try:
                os.chmod(f.path, mode & 0o777)
            except OSError as exc:
                raise oserror(exc)
        if atime != NOTOUCH4 or mtime != NOTOUCH4:
            st = self.ex.lstat(f.path)
            a = st.st_atime if atime == NOTOUCH4 else atime
            m = st.st_mtime if mtime == NOTOUCH4 else mtime
            try:
                os.utime(f.path, (a, m))
            except OSError as exc:
                raise oserror(exc)
        if length != NOTOUCH8:
            # TRUNCATE IS A wstat, not a message of its own.  This is the one
            # the V10 client's t_trunc lands on.
            try:
                if f.f is not None:
                    f.f.truncate(length)
                    f.f.flush()
                else:
                    os.truncate(f.path, length)
            except OSError as exc:
                raise oserror(exc)
        self.reply(Rwstat, tag)


# ------------------------------------------------------------------- serve --

def serve_forever(cfg):
    export = Export(cfg)
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # 127.0.0.1 AND NOT 0.0.0.0.  SLiRP rewrites 10.0.2.2 to host loopback
    # inside the same process, so loopback is everything the guest needs and
    # binding wider would put the share on the network for real.
    srv.bind(("127.0.0.1", cfg["port"]))
    srv.listen(8)
    if cfg["verbose"]:
        sys.stderr.write("9pfsd: %s on 127.0.0.1:%d, %s\n" % (
            cfg["root"], cfg["port"], "rw" if not cfg["readonly"] else "ro"))
    while True:
        try:
            sock, _ = srv.accept()
        except KeyboardInterrupt:
            return
        # TCP_NODELAY: every exchange is one small request and one small
        # reply, and Nagle turns that into a 40ms round trip.
        sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        t = threading.Thread(target=Conn(sock, export, cfg).serve)
        t.daemon = True
        t.start()


def main(argv):
    cfg = {"port": 9200, "readonly": True, "verbose": False, "uid": 0,
           "gid": 0, "msize": DEFMSIZE, "strict": False, "follow": False,
           "root": None}
    args = list(argv)
    while args:
        a = args.pop(0)
        if a == "-p":
            cfg["port"] = int(args.pop(0))
        elif a == "-w":
            cfg["readonly"] = False
        elif a == "-v":
            cfg["verbose"] = True
        elif a == "-u":
            cfg["uid"] = int(args.pop(0))
        elif a == "-g":
            cfg["gid"] = int(args.pop(0))
        elif a == "-m":
            cfg["msize"] = int(args.pop(0))
        elif a == "-T":
            cfg["strict"] = True
        elif a == "-L":
            cfg["follow"] = True
        elif a in ("-h", "--help"):
            sys.stderr.write(__doc__)
            return 0
        else:
            cfg["root"] = a
    if cfg["root"] is None:
        sys.stderr.write("9pfsd: no directory to export\n")
        return 2
    # Resolve ONCE, here, and with realpath rather than abspath: every path
    # the server builds is this one plus components, a relative root would
    # follow a chdir, and a symlinked root would make the containment test
    # compare against a name nothing else ever produces.
    cfg["root"] = os.path.realpath(cfg["root"])
    if not os.path.isdir(cfg["root"]):
        sys.stderr.write("9pfsd: %s is not a directory\n" % cfg["root"])
        return 2
    serve_forever(cfg)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
