#!/usr/bin/env python3
"""netfsd for hosts without Swift -- serve a directory to Research Unix netfs.

    tools/netfsd.py [-p port] [-w] [-v] [-u uid] [-g gid] [-m maxread] <dir>

      -p  TCP port on 127.0.0.1 (default 9200)
      -w  read/write; the default is READ-ONLY and the absence of -w is the
          whole guard, exactly as it is for the Swift netfsd
      -v  trace every request
      -u  uid to present every file as (default 0)
      -g  gid to present every file as (default 0)
      -m  cap each NREAD reply to this many bytes (default 0 = no cap)

The guest reaches this at 10.0.2.2:<port>.  Nothing is forwarded: SLiRP
rewrites every address inside its virtual network to host loopback, so
10.0.2.2 IS 127.0.0.1 as far as a connection is concerned.

WHY THIS EXISTS BESIDE netfs/Sources/NetFS.  The Swift package is the real
server: it compiles into netfsd AND into the iPad app (FileShare.swift), which
is why Package.swift forbids it a Mac-only dependency.  None of that helps a
Linux box with no Swift toolchain -- and that is the machine this project's
V10 work gets driven from, where the golden boots under open-simh and the only
missing piece was a share.  This is that piece: python3 and nothing else.

TWO IMPLEMENTATIONS OF ONE PROTOCOL IS A RISK AND IT IS NAMED HERE.  The wire
format is not this file's to define -- docs/netfs-protocol.md is the authority,
derived from V8's own sources and MEASURED on the machine with
tools/v8-netfs-probe.exp -- and every offset below is quoted from its two
tables with the field name beside it.  Where behaviour rather than layout is at
stake (the synthetic inode namespace, forged directories, the truncation rules,
the held-descriptor revalidation) the Swift got there first and the comment
says so, so that a change to one has an obvious counterpart in the other.

WHAT IS DELIBERATELY NOT HERE: the ten-minute re-read of /usr/net/people and
/usr/net/friends, which the reference server does and neither of ours does; and
per-uid mapping, since both servers present every file as one uid.
"""

import errno as E
import os
import socket
import stat as S
import struct
import sys
import threading
import time

# ---- the wire ---------------------------------------------------------------
# docs/netfs-protocol.md, "struct senda" and "struct rcva".  Both layouts carry
# hand-written `rsvd' padding AND one hole each that 1985 VAX pcc inserted on
# its own; the holes are at senda+14 and rcva+18 and are written as fields here
# because a format string cannot express "two bytes nobody named".  `<' is
# little-endian AND unaligned, which is what lets the holes be explicit: the
# VAX-11/780 and every host this runs on agree about byte order, so there is no
# marshalling anywhere in this file beyond these two strings.
SENDA = "<BBBBiHHHHiiHHiiiIii"      # 52 bytes
RCVA = "<iBBHiHHHHiHHiiiii"         # 48 bytes
SENDA_SIZE = struct.calcsize(SENDA)
RCVA_SIZE = struct.calcsize(RCVA)
assert (SENDA_SIZE, RCVA_SIZE) == (52, 48), (SENDA_SIZE, RCVA_SIZE)

NETVERSION = 1

# neta.h's sixteen opcodes.  The kernel only ever puts nine of them in `cmd';
# 10-14 live in `flags' and share the number space, and 16 is defined and dead.
NSTAT, NWRT, NREAD, NFREE, NTRUNC, NUPDAT, NGET, NNAMI, NPUT = range(1, 10)
NROOT, NDEL, NLINK, NCREAT, NOMATCH, NSTART, NIOCTL = range(10, 17)
OPNAME = {NSTAT: "NSTAT", NWRT: "NWRT", NREAD: "NREAD", NFREE: "NFREE",
          NTRUNC: "NTRUNC", NUPDAT: "NUPDAT", NGET: "NGET", NNAMI: "NNAMI",
          NPUT: "NPUT", NROOT: "NROOT", NDEL: "NDEL", NLINK: "NLINK",
          NCREAT: "NCREAT", NOMATCH: "NOMATCH", NSTART: "NSTART",
          NIOCTL: "NIOCTL"}
COMMANDS = {NSTAT, NWRT, NREAD, NFREE, NTRUNC, NUPDAT, NGET, NNAMI, NPUT}

DIRSIZ = 14                 # sys/h/dir.h, and the reason half this file exists
DIRENT = 16                 # `ino_t d_ino; char d_name[DIRSIZ];'
ROOTINO = 2                 # sys/h/param.h, and iget() hardcodes it -- see below
MAXCOUNT = 8192             # ceiling on a client-supplied length; BUFSIZE is 4096

# V8's errno numbers (usr/include/errno.h).  1..32 match BSD and therefore
# Linux, so most of this is a no-op -- but V8 STOPS AT 35 and Linux runs past
# 100, so anything it has never heard of has to become something it has, or the
# guest indexes off the end of sys_errlist[].  ELOOP is the one that actually
# differs in the overlap: 40 on Linux, 35 here.  (On macOS it is 62; the Swift
# server maps the same way from its own host numbers, which is why both servers
# name the host's symbol rather than a number.)
V8_EPERM, V8_ENOENT, V8_EIO, V8_ENXIO = 1, 2, 5, 6
V8_EBADF, V8_ENOMEM, V8_EACCES, V8_EBUSY = 9, 12, 13, 16
V8_EEXIST, V8_EXDEV, V8_ENOTDIR, V8_EISDIR = 17, 18, 20, 21
V8_EINVAL, V8_EMFILE, V8_EFBIG, V8_ENOSPC = 22, 24, 27, 28
V8_EROFS, V8_EMLINK, V8_ELOOP = 30, 31, 35

_ERRMAP = {
    E.ENOENT: V8_ENOENT, E.EACCES: V8_EACCES, E.EPERM: V8_EPERM,
    E.EISDIR: V8_EISDIR, E.ENOTDIR: V8_ENOTDIR, E.EEXIST: V8_EEXIST,
    E.EINVAL: V8_EINVAL, E.ENOSPC: V8_ENOSPC, E.EROFS: V8_EROFS,
    E.EMFILE: V8_EMFILE, E.ENFILE: V8_EMFILE,
    E.ELOOP: V8_ELOOP,                  # 40 -> 35
    E.ENOTEMPTY: V8_EEXIST,             # V8 has no ENOTEMPTY
    E.EXDEV: V8_EXDEV, E.EMLINK: V8_EMLINK, E.EFBIG: V8_EFBIG,
    E.EBUSY: V8_EBUSY, E.ENOMEM: V8_ENOMEM, E.EBADF: V8_EBADF,
    E.ENXIO: V8_ENXIO, E.ENODEV: V8_ENXIO,
}


def v8errno(host):
    """Translate a host errno into something V8 can name."""
    if host == 0:
        return 0
    return _ERRMAP.get(host, V8_EIO)    # anything V8 never heard of


class Senda:
    """One request.  Field names and offsets are the protocol doc's table."""

    __slots__ = ("version", "cmd", "flags", "trannum", "uid", "gid", "dev",
                 "tag", "mode", "newuid", "newgid", "ino", "count", "offset",
                 "ta", "tm")

    def __init__(self, raw):
        (self.version, self.cmd, self.flags, _rsvd, self.trannum,
         self.uid, self.gid, self.dev, _hole,
         self.tag, self.mode, self.newuid, self.newgid,
         self.ino, self.count, self.offset,
         _buf,                       # a CLIENT-SIDE POINTER; meaningless here
         self.ta, self.tm) = struct.unpack(SENDA, raw)


class Rcva:
    """One reply.  Every field defaults to 0, which is what success looks like."""

    __slots__ = ("trannum", "errno", "flags", "dev", "size", "mode", "uid",
                 "gid", "tag", "nlink", "ino", "count", "tm")

    def __init__(self):
        self.trannum = self.errno = self.flags = self.dev = 0
        self.size = self.mode = self.uid = self.gid = self.tag = 0
        self.nlink = self.ino = self.count = 0
        self.tm = (0, 0, 0)

    def encode(self):
        return struct.pack(RCVA, self.trannum, self.errno, self.flags,
                           self.dev & 0xffff, _i32(self.size),
                           self.mode & 0xffff, self.uid & 0xffff,
                           self.gid & 0xffff, 0,          # the hole at 18
                           _i32(self.tag), self.nlink & 0xffff, 0,
                           _i32(self.ino), _i32(self.count),
                           _i32(self.tm[0]), _i32(self.tm[1]), _i32(self.tm[2]))


def _i32(v):
    """Clamp to a signed 32-bit field rather than let struct raise.

    st_size on a host file can exceed 2 GB and a VAX long cannot say so; a
    clamp is wrong but a traceback in the middle of a mount is worse, and the
    guest cannot read past 2 GB either way.
    """
    if v > 0x7fffffff:
        return 0x7fffffff
    if v < -0x80000000:
        return -0x80000000
    return int(v)


# ---- the case map -----------------------------------------------------------
class CaseMap:
    """Present the repo's case-escaped names to the guest under their true ones.

    The V8 tape distinguishes usr/src/cmd/Mail from usr/src/cmd/mail, and macOS
    and git between them cannot hold both, so the repo stores the loser of each
    colliding pair percent-escaped -- `Mail' as `%4Dail'.  A Linux checkout has
    the same escaped names, because the escaping is in the REPOSITORY and not in
    the filesystem, so this is needed here exactly as it is on a Mac.

    It is also not optional: a struct direct name field is 14 bytes and
    `%43%49%52%43%4C%45' -- escaped `CIRCLE' -- is 18.  The escaped spellings
    physically cannot be represented in a V8 directory entry.

    Ported from netfs/Sources/NetFS/CaseMap.swift, including the reason CASEMAP
    is written parents-first: the parent recorded in each row is a TRUE path,
    lookups arrive with the STORED path the filesystem actually has, so each
    parent is translated through the rows already read.
    """

    def __init__(self, root):
        self.to_true = {}       # stored-abs-parent -> {stored: true}
        self.to_stored = {}     # stored-abs-parent -> {true: stored}
        try:
            with open(os.path.join(root, "CASEMAP"), encoding="utf-8") as fh:
                text = fh.read()
        except OSError:
            return
        prefixes = []           # (stored, real), longest-lived first
        for line in text.split("\n"):
            if not line or line.startswith("#"):
                continue
            f = line.split("\t")
            if len(f) != 3:
                continue
            true_parent, stored, real = f
            sp = true_parent
            for pre_stored, pre_real in prefixes:
                if sp == pre_real or sp.startswith(pre_real + "/"):
                    sp = pre_stored + sp[len(pre_real):]
            abs_parent = root if sp == "." else os.path.join(root, sp)
            self.to_true.setdefault(abs_parent, {})[stored] = real
            self.to_stored.setdefault(abs_parent, {})[real] = stored
            prefixes.append((sp + "/" + stored, true_parent + "/" + real))

    def shown(self, parent, on_disk):
        """Listing: what the guest should see for a name that is on disk."""
        return self.to_true.get(parent, {}).get(on_disk, on_disk)

    def on_disk(self, parent, shown):
        """Lookup: what is on disk for a name the guest asked for."""
        return self.to_stored.get(parent, {}).get(shown, shown)


# ---- one open object --------------------------------------------------------
class Handle:
    """The netfs `netf' of usr/src/netfs/fserv.h."""

    __slots__ = ("tag", "ino", "path", "st", "dirimage", "fd", "writable")

    def __init__(self, tag, ino, path, st):
        self.tag = tag
        self.ino = ino
        self.path = path
        self.st = st
        self.dirimage = None
        self.fd = -1
        self.writable = False

    @property
    def isdir(self):
        return S.S_ISDIR(self.st.st_mode)

    @property
    def islink(self):
        return S.S_ISLNK(self.st.st_mode)

    @property
    def v8size(self):
        """What the guest is told, which for a directory is the forged image."""
        if self.dirimage is not None:
            return len(self.dirimage)
        return self.st.st_size

    def revalidate(self):
        """Drop a held descriptor that no longer refers to the file at `path'.

        A HELD DESCRIPTOR FOLLOWS THE INODE, NOT THE NAME, and this is the bug
        the Swift server's own comment records costing five builds: an editor
        that writes a temporary file and renames it over this one -- which is
        what most of them do, and what this project's tooling does -- leaves fd
        on the old, now-unlinked inode for as long as the handle lives, which is
        the whole mount.  NGET and NSTAT re-lstat and report the NEW size while
        NREAD serves the OLD bytes and hits EOF early, so v10's cp (which loops
        to EOF and never consults st_size) writes a SHORT FILE and exits 0.
        st_dev is compared too, which costs nothing and is right across a share
        that spans filesystems.
        """
        if self.fd < 0:
            return
        try:
            now = os.lstat(self.path)
            have = os.fstat(self.fd)
        except OSError:
            return
        if now.st_ino != have.st_ino or now.st_dev != have.st_dev:
            os.close(self.fd)
            self.fd = -1
            self.writable = False

    def close(self):
        if self.fd >= 0:
            os.close(self.fd)
            self.fd = -1


def visible(mode):
    """Is this a type V8 can make any sense of?

    Sockets and FIFOs are not, and handing a 1985 kernel a host object it has no
    driver for is worse than hiding it.  Devices are excluded for a different
    reason: a remote /dev/null would carry a host major/minor that means
    something else entirely on a VAX.
    """
    return S.S_ISREG(mode) or S.S_ISDIR(mode) or S.S_ISLNK(mode)


def v8name(name):
    """Truncate to what a struct direct can hold -- 14 BYTES, not 14 characters.

    A name with any multi-byte character in it has to be cut on the byte
    boundary the guest will see, so this encodes first and slices after.
    """
    return name.encode("utf-8", "surrogateescape")[:DIRSIZ]


# ---- one exported directory -------------------------------------------------
class Export:
    """One exported host directory, seen through 1985 eyes.

    Four consequences drive everything here, and all four are the Swift's
    (netfs/Sources/NetFS/Export.swift) because they are the protocol's:

    1. INODE NUMBERS ARE SYNTHETIC.  sys/h/types.h is `typedef u_short ino_t'
       and struct direct is a 2-byte ino plus a 14-byte name, while a host hands
       out 64-bit inode numbers as a matter of course.  So this keeps its own
       1..65534 namespace and a host (dev,ino) -> ours map, which also gives the
       stability the client's inode cache needs: the same host file must always
       come back as the same number or the guest ends up with two inodes for it.

    2. THE EXPORT ROOT IS ALWAYS INODE 2, and not by choice.  iget() crosses a
       mount by setting `ino = ROOTINO' and looking up again, so the client's
       very first request on a fresh mount is NGET(dev, 2) and there is no other
       way to name the root.

    3. DIRECTORIES ARE SYNTHESISED.  There is no readdir opcode: ls opens a
       directory and read(2)s 16-byte records out of it, which arrives here as
       an ordinary NREAD.  The image is built once per handle so that the size
       NGET reports and the bytes a later NREAD returns cannot disagree even if
       the host directory changes underneath.

    4. NAMES ARE TRUNCATED TO 14 BYTES in the listing AND in lookup.  A file the
       guest can see must be a file the guest can open.  Two children that
       truncate alike are a genuine collision; first match wins, and it is
       logged rather than hidden.
    """

    def __init__(self, root, mapuid, mapgid, trace):
        self.root = root
        self.mapuid = mapuid
        self.mapgid = mapgid
        self.trace = trace
        self.dev = 0                    # set from the NSTART senda
        self.casemap = CaseMap(root)
        self.ino_by_host = {}           # (st_dev, st_ino) -> our 16-bit ino
        self.path_by_ino = {ROOTINO: root}
        self.handles = {}               # tag -> Handle
        self.handle_by_ino = {}         # our 16-bit ino -> Handle
        self.next_ino = 3               # 2 is the root
        self.next_tag = 1               # 0 means "error" to the server

    # -- the synthetic inode namespace
    def ino_for(self, path, st):
        if path == self.root:
            return ROOTINO
        key = (st.st_dev, st.st_ino)
        n = self.ino_by_host.get(key)
        if n is not None:
            # Recall, but refresh the path: a hard link or a rename means the
            # same host inode is reachable under a different name now, and the
            # path is what actually gets opened.
            self.path_by_ino[n] = path
            return n
        if self.next_ino >= 0xffff:
            return None                 # 65534 files is a lot of 1985
        n = self.next_ino
        self.next_ino += 1
        self.ino_by_host[key] = n
        self.path_by_ino[n] = path
        return n

    # -- handles
    # KEYED BY OUR ino AND NOT BY PATH, which is how the Swift does it and the
    # difference is hard links: two names for one host inode get one ino from
    # ino_for(), so keying by path would hand out two tags for one object and
    # an NPUT on either would leave the other live.  One object, one handle.
    def handle_for_path(self, path):
        try:
            st = os.lstat(path)
        except OSError:
            return None
        ino = self.ino_for(path, st)
        if ino is None:
            return None
        h = self.handle_by_ino.get(ino)
        if h is not None:
            # Refresh: the client may have held this across a host-side change,
            # and a directory's forged image has to be rebuilt with it or the
            # size NGET just reported and the bytes NREAD returns disagree.
            h.st = st
            if h.isdir:
                h.dirimage = self.build_dirimage(path, ino)
            return h
        h = Handle(self.next_tag, ino, path, st)
        self.next_tag += 1
        if h.isdir:
            h.dirimage = self.build_dirimage(path, ino)
        self.handles[h.tag] = h
        self.handle_by_ino[ino] = h
        return h

    def handle_for_ino(self, ino):
        h = self.handle_by_ino.get(ino)
        if h is not None:
            try:
                h.st = os.lstat(h.path)
                if h.isdir:
                    h.dirimage = self.build_dirimage(h.path, ino)
            except OSError:
                pass
            return h
        path = self.path_by_ino.get(ino)
        if path is None:
            return None
        return self.handle_for_path(path)

    def handle(self, tag, or_root_ino=None):
        """Resolve a request's handle.

        V10'S CLIENT FAKES THE ROOT AND INVENTS ITS OWN TAG, and Bell Labs wrote
        down why -- lsys/fs/neta.c's nadomount():

            /*
             * fake the root, rather than sending NAGET now,
             * to avoid a deadlock when a server mounts itself
             * the next stat will correct it
             */
            rip->i_un.i_tag = (flag<<16)|ROOTINO;

        So where V8's client opens every mount with NGET(dev, ROOTINO) -- which
        is what allocates a tag here -- V10 deliberately skips it and synthesises
        one.  Its first request is therefore NSTAT with a tag out of the
        client's namespace, not ours.  The fallback is deliberately narrow: only
        ROOTINO, and only when the tag is unknown.
        """
        h = self.handles.get(tag)
        if h is not None:
            return h
        if or_root_ino == ROOTINO:
            return self.handle_for_ino(ROOTINO)
        return None

    def release(self, tag):
        """clrnetf(): drop a handle.

        THE ROOT IS NEVER RELEASED -- the reference server says so in as many
        words ("hold on to the root"), and the client asks for it again.
        """
        h = self.handles.get(tag)
        if h is None or h.ino == ROOTINO:
            return
        h.close()
        del self.handles[tag]
        self.handle_by_ino.pop(h.ino, None)

    # -- forged directories
    def build_dirimage(self, path, ino):
        out = bytearray()

        def add(name, n):
            out.extend(struct.pack("<H", n & 0xffff))
            out.extend(name.ljust(DIRSIZ, b"\0"))

        add(b".", ino)
        # `..' of the export root is the export root: the guest never sees past
        # the mount, and NNAMI answers a real `..' with NROOT so the client
        # splices in its own mount point.
        if path == self.root:
            parent_ino = ROOTINO
        else:
            parent = os.path.dirname(path)
            try:
                parent_ino = self.ino_for(parent, os.lstat(parent)) or ROOTINO
            except OSError:
                parent_ino = ROOTINO
        add(b"..", parent_ino)

        try:
            names = sorted(os.listdir(path))
        except OSError:
            return bytes(out)
        seen = set()
        for name in names:
            child = os.path.join(path, name)
            try:
                st = os.lstat(child)
            except OSError:
                continue
            if not visible(st.st_mode):
                continue
            short = v8name(self.casemap.shown(path, name))
            if short in seen:
                self.trace("collision: %s truncates onto an existing entry in %s"
                           % (name, path))
                continue
            n = self.ino_for(child, st)
            if n is None:
                continue
            seen.add(short)
            add(short, n)
        return bytes(out)

    # -- lookup: one component, which is all netfs ever resolves at a time
    def lookup(self, parent, raw):
        """Returns (handle, is_root) | ("nomatch", None) | ("error", v8errno)."""
        if not parent.isdir:
            return ("error", V8_ENOTDIR)
        name_bytes = raw.split(b"\0", 1)[0]     # fixnbuf() stops at the first NUL
        name = name_bytes.decode("utf-8", "surrogateescape")

        if not name_bytes or name == ".":
            return (parent, False)              # "." never raises NROOT
        if name == "..":
            if parent.path == self.root:
                # Walked out of the export.  Hand back the root with NROOT set
                # and let the client splice in its own mount point; without this
                # a `cd ..' from a netfs root would escape the export.
                h = self.handle_for_path(self.root)
                return (h, True) if h else ("error", V8_EIO)
            up = os.path.dirname(parent.path)
            h = self.handle_for_path(up)
            return (h, h.path == self.root) if h else ("error", V8_ENOENT)

        # The exact name first: the overwhelmingly common case, and it avoids
        # listing a big directory for every component of every path.
        direct = os.path.join(parent.path,
                              self.casemap.on_disk(parent.path, name))
        if len(name_bytes) < DIRSIZ:
            try:
                st = os.lstat(direct)
            except OSError:
                return ("nomatch", None)
            if not visible(st.st_mode):
                return ("nomatch", None)
            h = self.handle_for_path(direct)
            return (h, h.path == self.root) if h else ("error", V8_EIO)

        # Exactly DIRSIZ bytes means the guest may be holding a truncation of
        # something longer, so scan for the first child that truncates onto it.
        if len(name_bytes) == DIRSIZ:
            try:
                names = sorted(os.listdir(parent.path))
            except OSError:
                names = []
            for cand in names:
                if v8name(self.casemap.shown(parent.path, cand)) != name_bytes:
                    continue
                child = os.path.join(parent.path, cand)
                try:
                    cst = os.lstat(child)
                except OSError:
                    continue
                if not visible(cst.st_mode):
                    continue
                h = self.handle_for_path(child)
                if h:
                    return (h, False)
        return ("nomatch", None)

    # -- reading
    def read(self, h, offset, count):
        """Returns (bytes, 0) or (None, v8errno)."""
        if h.dirimage is not None:
            start = max(0, offset)
            if start >= len(h.dirimage):
                return (b"", 0)
            return (h.dirimage[start:start + count], 0)
        if h.islink:
            try:
                target = os.readlink(h.path).encode("utf-8", "surrogateescape")
            except OSError as e:
                return (None, v8errno(e.errno))
            start = min(offset, len(target))
            return (target[start:start + count], 0)
        h.revalidate()
        if h.fd < 0:
            try:
                h.fd = os.open(h.path, os.O_RDONLY)
            except OSError as e:
                return (None, v8errno(e.errno))
        try:
            os.lseek(h.fd, offset, os.SEEK_SET)
            return (os.read(h.fd, count), 0)
        except OSError as e:
            return (None, v8errno(e.errno))

    # -- writing (only reached when read-only is off)
    def write(self, h, offset, data):
        h.revalidate()
        if h.fd < 0 or not h.writable:
            if h.fd >= 0:
                os.close(h.fd)
            try:
                h.fd = os.open(h.path, os.O_RDWR)
            except OSError as e:
                h.fd = -1
                return v8errno(e.errno)
            h.writable = True
        try:
            os.lseek(h.fd, offset, os.SEEK_SET)
            sent = 0
            while sent < len(data):
                sent += os.write(h.fd, data[sent:])
            h.st = os.lstat(h.path)
            return 0
        except OSError as e:
            return v8errno(e.errno)

    def truncate(self, h):
        try:
            os.truncate(h.path, 0)
            h.st = os.lstat(h.path)
            return 0
        except OSError as e:
            return v8errno(e.errno)

    def update(self, h, mode, ta, tm, dtime, by_root):
        """NUPDAT.  `ta'/`tm' arrive on the CLIENT's clock; dtime is the skew
        the NSTART senda carried, and it is subtracted here to land back on
        ours."""
        try:
            if mode and (mode & 0o7777) != (h.st.st_mode & 0o7777):
                if not by_root and os.geteuid() != h.st.st_uid:
                    return V8_EPERM
                os.chmod(h.path, mode & 0o7777)
            if ta or tm:
                at = (ta - dtime) if ta else h.st.st_atime
                mt = (tm - dtime) if tm else h.st.st_mtime
                os.utime(h.path, (at, mt))
            h.st = os.lstat(h.path)
            return 0
        except OSError as e:
            return v8errno(e.errno)

    def create(self, path, mode):
        try:
            fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_RDWR, mode & 0o7777)
            os.close(fd)
        except OSError as e:
            return (None, v8errno(e.errno))
        self.invalidate_parent(path)
        h = self.handle_for_path(path)
        return (h, 0) if h else (None, V8_EIO)

    def unlink(self, h):
        try:
            if h.isdir:
                os.rmdir(h.path)
            else:
                os.unlink(h.path)
        except OSError as e:
            return v8errno(e.errno)
        self.invalidate_parent(h.path)
        return 0

    def invalidate_parent(self, path):
        """Rebuild the parent's cached image after a create or a delete."""
        parent = os.path.dirname(path)
        if parent == self.root:
            pino = ROOTINO
        else:
            try:
                pst = os.lstat(parent)
            except OSError:
                return
            pino = self.ino_by_host.get((pst.st_dev, pst.st_ino))
        ph = self.handle_by_ino.get(pino) if pino is not None else None
        if ph is not None and ph.isdir:
            ph.dirimage = self.build_dirimage(parent, ph.ino)

    # -- reply assembly
    def describe(self, h, y):
        """Fill the attribute fields every operation shares.

        In one place because getting `mode' or `size' right in one operation and
        wrong in another produces a guest that half-works, which is much harder
        to debug than one that fails outright.
        """
        y.mode = h.st.st_mode & 0xffff
        y.nlink = min(h.st.st_nlink, 0xffff)
        y.uid = self.mapuid
        y.gid = self.mapgid
        y.size = h.v8size
        y.tag = h.tag
        y.ino = h.ino
        y.dev = self.dev


# ---- one mounted connection -------------------------------------------------
class Connection:
    def __init__(self, sock, cfg):
        self.sock = sock
        self.cfg = cfg
        self.dtime = 0
        self.requests = 0
        self.export = Export(cfg["root"], cfg["uid"], cfg["gid"], self.trace)

    def log(self, s):
        sys.stderr.write(s + "\n")
        sys.stderr.flush()

    def trace(self, s):
        if self.cfg["verbose"]:
            self.log(s)

    # -- framing.  READ BY LENGTH, NEVER BY READ BOUNDARY: the reference server
    # reads with a 256-byte buffer and then insists on getting exactly 1 or
    # exactly 52, which is true on Datakit, where one write is one message, and
    # false on TCP in both directions.  docs/netfs-protocol.md, "Transport
    # requirements -- read this before writing a server".
    def read_exactly(self, n):
        if n == 0:
            return b""
        buf = bytearray()
        while len(buf) < n:
            try:
                chunk = self.sock.recv(n - len(buf))
            except OSError:
                return None
            if not chunk:
                return None
            buf.extend(chunk)
        return bytes(buf)

    def write_all(self, data):
        try:
            self.sock.sendall(data)
            return True
        except OSError:
            return False

    def run(self):
        try:
            if not self.handshake():
                return
            while True:
                header = self.read_exactly(SENDA_SIZE)
                if header is None:
                    break
                if not self.serve(Senda(header)):
                    break
        finally:
            for h in list(self.export.handles.values()):
                h.close()
            try:
                self.sock.close()
            except OSError:
                pass
            self.log("connection closed after %d requests" % self.requests)

    def handshake(self):
        """One byte of version on its own, then a senda, then a 48-byte reply."""
        v = self.read_exactly(1)
        if not v or v[0] != NETVERSION:
            return False
        header = self.read_exactly(SENDA_SIZE)
        if header is None:
            return False
        x = Senda(header)
        if x.version != NETVERSION:
            y = Rcva()
            y.trannum = -1
            self.write_all(y.encode())
            return False
        # Three fields of the opening senda are overloaded and carry setup data
        # rather than what their names say: `ta' is the client's time(0), `uid'
        # is a debug level, `dev' is the mount's device number.
        self.dtime = x.ta - int(time.time())
        self.export.dev = x.dev
        self.log("NSTART dev=%d debug=%d dtime=%ds cmd=%s"
                 % (x.dev, x.uid, self.dtime, OPNAME.get(x.cmd, x.cmd)))
        y = Rcva()
        y.trannum = x.trannum
        return self.write_all(y.encode())

    def respond(self, y, err):
        y.errno = err
        if err:
            self.trace("    -> errno %d" % err)
        return self.write_all(y.encode())

    def serve(self, x):
        """Returns False to close the connection, matching leave()."""
        self.requests += 1
        y = Rcva()
        y.trannum = x.trannum
        y.dev = self.export.dev

        if x.cmd not in COMMANDS:
            # 10-14 are FLAGS, not commands, and 16 is defined and dead.  Seeing
            # one in `cmd' means the stream has desynchronised, which is not
            # recoverable.
            self.log("%s is not a command; closing" % OPNAME.get(x.cmd, x.cmd))
            return False

        self.trace("#%d %s tag=%d ino=%d count=%d off=%d flags=%d uid=%d"
                   % (self.requests, OPNAME[x.cmd], x.tag, x.ino, x.count,
                      x.offset, x.flags, x.uid))

        if x.cmd == NGET:
            return self.do_get(x, y)
        if x.cmd == NNAMI:
            return self.do_nami(x, y)
        if x.cmd == NREAD:
            return self.do_read(x, y)
        if x.cmd == NSTAT:
            return self.do_stat(x, y)
        if x.cmd == NPUT:
            return self.do_put(x, y)
        if x.cmd == NFREE:
            return self.respond(y, 0)       # the reference server acknowledges
        if x.cmd == NUPDAT:
            return self.do_updat(x, y)
        if x.cmd == NWRT:
            return self.do_write(x, y)
        if x.cmd == NTRUNC:
            return self.do_trunc(x, y)
        return False

    def do_get(self, x, y):
        if x.ino <= 0 or x.ino > 0xffff:
            return self.respond(y, V8_ENOENT)
        h = self.export.handle_for_ino(x.ino)
        if h is None:
            return self.respond(y, V8_ENOENT)
        self.export.describe(h, y)
        self.trace("    -> %s mode=%o size=%d" % (h.path, h.st.st_mode, h.v8size))
        return self.respond(y, 0)

    def do_put(self, x, y):
        if x.tag == 0:
            return self.respond(y, V8_EIO)
        self.export.release(x.tag)
        return self.respond(y, 0)

    def do_stat(self, x, y):
        h = self.export.handle(x.tag, x.ino)
        if h is None:
            return self.respond(y, V8_ENOENT)
        try:
            h.st = os.lstat(h.path)
        except OSError:
            pass
        self.export.describe(h, y)
        y.tm = (_i32(int(h.st.st_atime)), _i32(int(h.st.st_mtime)),
                _i32(int(h.st.st_ctime)))
        return self.respond(y, 0)

    def do_nami(self, x, y):
        # The name is a payload AFTER the header and must be consumed even on
        # the error paths, or the stream desynchronises.
        if x.count < 0 or x.count > MAXCOUNT:
            return False
        name = self.read_exactly(x.count)
        if name is None:
            return False
        text = name.split(b"\0", 1)[0].decode("utf-8", "surrogateescape")

        parent = self.export.handle(x.tag, x.ino)
        if parent is None:
            return self.respond(y, V8_ENOENT)

        # A side effect was asked for.  Read-only means read-only, and saying so
        # here is what makes the guest report a sensible error rather than
        # half-completing something.
        if self.cfg["readonly"] and x.flags in (NDEL, NLINK, NCREAT):
            self.trace("    -> %s refused (read-only)" % OPNAME[x.flags])
            return self.respond(y, V8_EROFS)

        first, second = self.export.lookup(parent, name)
        if first == "error":
            return self.respond(y, second)
        if first == "nomatch":
            y.flags = NOMATCH
            self.trace("    -> NOMATCH %s" % text)
            if x.flags in (NCREAT, NLINK):
                return self.do_nami_create(x, y, parent, text)
            return self.respond(y, 0)

        h, is_root = first, second
        self.export.describe(h, y)
        if is_root:
            y.flags = NROOT
        if x.flags == NDEL:
            if is_root:
                return self.respond(y, V8_EPERM)
            err = self.export.unlink(h)
            if err == 0:
                self.export.release(h.tag)
            return self.respond(y, err)
        self.trace("    -> %s = ino %d %s%s"
                   % (text, h.ino, h.path, " [NROOT]" if is_root else ""))
        return self.respond(y, 0)

    def do_nami_create(self, x, y, parent, name):
        target = os.path.join(parent.path, name)
        if x.flags == NCREAT:
            h, err = self.export.create(target, x.mode)
            if h is None:
                return self.respond(y, err)
            self.export.describe(h, y)
            y.flags = 0
            self.trace("    -> created %s ino %d" % (target, h.ino))
            return self.respond(y, 0)
        # NLINK: dev/ino name the EXISTING file.
        if x.ino <= 0 or x.ino > 0xffff:
            return self.respond(y, V8_EXDEV)
        src = self.export.handle_for_ino(x.ino)
        if src is None:
            return self.respond(y, V8_EXDEV)
        try:
            os.link(src.path, target)
        except OSError as e:
            return self.respond(y, v8errno(e.errno))
        self.export.invalidate_parent(target)
        h = self.export.handle_for_path(target)
        if h is None:
            return self.respond(y, V8_EIO)
        self.export.describe(h, y)
        y.flags = 0
        return self.respond(y, 0)

    def do_read(self, x, y):
        h = self.export.handle(x.tag, x.ino)
        if h is None:
            return self.respond(y, V8_ENOENT)
        want = min(max(x.count, 0), MAXCOUNT)
        if self.cfg["maxread"] > 0:
            want = min(want, self.cfg["maxread"])
        data, err = self.export.read(h, x.offset, want)
        if data is None:
            return self.respond(y, err)
        # A SHORT REPLY IS NOT EOF -- only a zero-length one is.  naread()'s
        # loop comes back at the new offset for anything it did not get, which
        # is what makes capping a reply safe.
        y.count = len(data)
        self.trace("    -> %d bytes of %s" % (len(data), h.path))
        if not self.respond(y, 0):
            return False
        return self.write_all(data)

    def do_write(self, x, y):
        if x.count < 0 or x.count > MAXCOUNT:
            return False
        data = self.read_exactly(x.count)
        if data is None:
            return False
        if self.cfg["readonly"]:
            return self.respond(y, V8_EROFS)
        h = self.export.handle(x.tag, x.ino)
        if h is None:
            return self.respond(y, V8_ENOENT)
        err = self.export.write(h, x.offset, data)
        self.export.describe(h, y)
        return self.respond(y, err)

    def do_trunc(self, x, y):
        if self.cfg["readonly"]:
            return self.respond(y, V8_EROFS)
        h = self.export.handle(x.tag, x.ino)
        if h is None:
            return self.respond(y, V8_ENOENT)
        err = self.export.truncate(h)
        self.export.describe(h, y)
        return self.respond(y, err)

    def do_updat(self, x, y):
        """NUPDAT -- set mode, owner and times.

        In read-only mode this replies SUCCESS and does nothing, deliberately.
        The kernel emits NUPDAT from iupdat() on the ordinary close path, and
        answering EROFS there would make a plain `cat' of a remote file fail on
        close for no reason the user could act on.  A refusal that matters --
        chmod, chown -- is still refused.
        """
        h = self.export.handle(x.tag, x.ino)
        if h is None:
            return self.respond(y, V8_ENOENT)
        wants_meta = ((x.mode & 0xffff) != (h.st.st_mode & 0xffff)
                      or (x.uid == 0 and (x.newuid != self.export.mapuid
                                          or x.newgid != self.export.mapgid)))
        if self.cfg["readonly"]:
            if wants_meta:
                self.trace("    -> chmod/chown refused (read-only)")
                return self.respond(y, V8_EROFS)
            self.trace("    -> times ignored (read-only)")
            self.export.describe(h, y)
            return self.respond(y, 0)
        err = self.export.update(h, x.mode, x.ta, x.tm, self.dtime, x.uid == 0)
        self.export.describe(h, y)
        return self.respond(y, err)


# ---- listener ---------------------------------------------------------------
def serve_forever(cfg):
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # 127.0.0.1 AND NOT 0.0.0.0.  SLiRP rewrites 10.0.2.2 to host loopback, so
    # loopback is all the guest ever needs -- and it is what keeps an export
    # off the network the host is actually on.
    srv.bind(("127.0.0.1", cfg["port"]))
    srv.listen(4)
    sys.stderr.write("netfsd: listening on 127.0.0.1:%d, exporting %s %s\n"
                     % (cfg["port"], cfg["root"],
                        "read-only" if cfg["readonly"] else "read/write"))
    sys.stderr.write("netfsd: the guest reaches this as 10.0.2.2:%d through SLiRP\n"
                     % cfg["port"])
    sys.stderr.flush()
    while True:
        try:
            sock, _ = srv.accept()
        except OSError:
            break
        except KeyboardInterrupt:
            break
        # NAGLE WOULD COALESCE A REPLY HEADER WITH THE PAYLOAD BEHIND IT.  The
        # client survives that -- our reader is length-driven and the guest's
        # istread was fixed to be -- but a 40 ms delay on every one of the n
        # round trips a path costs is the difference between usable and not.
        sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        sys.stderr.write("netfsd: connection accepted\n")
        sys.stderr.flush()
        threading.Thread(target=Connection(sock, cfg).run, daemon=True).start()
    srv.close()


def main(argv):
    cfg = {"port": 9200, "readonly": True, "verbose": False,
           "uid": 0, "gid": 0, "maxread": 0, "root": None}
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
            cfg["maxread"] = int(args.pop(0))
        elif a in ("-h", "--help"):
            sys.stderr.write(__doc__)
            return 0
        else:
            cfg["root"] = a

    if cfg["root"] is None:
        sys.stderr.write("netfsd: no directory to export\n")
        return 2
    # Resolve to an absolute path ONCE, here.  Every path the server builds is
    # this one plus components, and a relative root would silently follow a
    # chdir.  realpath, not abspath: a symlinked root would otherwise make
    # `path == self.root' -- the test the whole inode-2 rule turns on -- false.
    cfg["root"] = os.path.realpath(cfg["root"])
    if not os.path.isdir(cfg["root"]):
        sys.stderr.write("netfsd: %s is not a directory\n" % cfg["root"])
        return 2
    serve_forever(cfg)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
