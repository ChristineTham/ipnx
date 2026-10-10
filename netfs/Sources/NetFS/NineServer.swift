//
//  NineServer.swift -- one 9P2000.u connection: framing, the thirteen
//  messages, the fids.  tools/9pfsd.py's `Conn', message for message.
//
//  ONE MESSAGE AT A TIME.  9P allows many outstanding requests told apart by
//  tag; this answers them in arrival order, which is legal -- a server may
//  finish requests in any order it likes, this one included -- and is all the
//  guest asks for: netb.c serialises on NBUSY and 9pfs.c inherits it, so there
//  is never more than one T-message in flight.  Which is also why Tflush can be
//  answered at once: whatever it names was finished before it was read.
//
//  LENGTH-DRIVEN, NEVER READ-BOUNDARY-DRIVEN, for the reason Server.swift's
//  header gives: TCP splits and coalesces as it likes.  `Wire' is the same
//  length-exact reader the netfs side uses.
//
import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

public struct NineConfig: Sendable {
    public var root: String
    /// The default, and the absence of write permission is the whole guard.
    public var readOnly: Bool
    /// Every file is presented as owned by these.  The GUEST kernel runs the
    /// permission check against what stat reports, so they must be the guest
    /// account's numbers or a home directory arrives as someone else's.
    public var uid: UInt32
    public var gid: UInt32
    /// The largest message to negotiate: 8192 of data plus Twrite's header.
    public var msize: UInt32
    /// No 14-byte name fallback -- conformance testing only.
    public var strict: Bool
    /// Stat through symlinks rather than describe them (tools/9pfsd.py -L).
    /// The guest has nowhere to put a link, so the app always sets this.
    public var follow: Bool
    public var verbose: Bool

    public init(root: String, readOnly: Bool = true, uid: UInt32 = 0, gid: UInt32 = 0,
                msize: UInt32 = 8192 + 24, strict: Bool = false,
                follow: Bool = false, verbose: Bool = false) {
        self.root = root; self.readOnly = readOnly; self.uid = uid; self.gid = gid
        self.msize = msize; self.strict = strict; self.follow = follow
        self.verbose = verbose
    }
}

/// One client handle.  `path` is always an absolute host path inside the
/// share; containment is checked when a walk makes the fid, not when it is
/// used, so a fid cannot outlive its own validity by being held.
final class NineFid {
    var path: String
    var qid: NineQid
    /// nil until Topen or Tcreate succeeds.
    var mode: UInt8?
    /// The host descriptor, for an open regular file.
    var fd: Int32 = -1
    /// For an open directory: the snapshot reads are served from.
    var dirents: [[UInt8]]?
    var diroffs: [Int] = []
    /// ORCLOSE: remove on clunk.
    var rclose = false

    init(path: String, qid: NineQid) { self.path = path; self.qid = qid }

    func closeFile() {
        if fd >= 0 { close(fd); fd = -1 }
    }

    deinit { closeFile() }
}

/// `@unchecked Sendable` because the thread that runs it is the only one that
/// ever touches it; the one thing it shares, the export's qid table, locks.
final class NineConnection: @unchecked Sendable {
    let wire: Wire
    let ex: NineExport
    let cfg: NineConfig
    /// The configured ceiling, kept where the arithmetic on it is safe:
    /// msize + 24 and msize - 24 are both computed, and a UInt32 that
    /// overflows or underflows traps.  python3's integers never noticed.
    private let maxMsize: UInt32
    private var msize: UInt32
    /// Until Tversion says otherwise.
    private var dotu = true
    private var fids: [UInt32: NineFid] = [:]
    private var requests = 0
    /// False once a reply could not be written: the guest has gone.
    private var alive = true

    init(fd: Int32, export: NineExport, cfg: NineConfig) {
        self.wire = Wire(fd: fd)
        self.ex = export
        self.cfg = cfg
        self.maxMsize = min(max(cfg.msize, 256), 1 << 24)
        self.msize = maxMsize
    }

    func run() {
        defer {
            forgetAll()
            close(wire.fd)
        }
        log("9P connection: serving \(ex.root)\(ex.readOnly ? " (read-only)" : "")")
        while alive {
            guard let hdr = wire.readExactly(4) else { break }
            let size = le32(hdr, 0)
            guard size >= 7, size <= msize + Nine.iohdrsz else {
                // A framing error has no tag that can be trusted; say so and go.
                replyError(Nine.notag, NineError(EPROTO, "message size \(size) out of range"))
                break
            }
            guard let msg = wire.readExactly(Int(size) - 4) else { break }
            requests += 1
            let type = msg[0]
            let tag = UInt16(msg[1]) | UInt16(msg[2]) << 8
            if cfg.verbose { trace(type, tag, msg) }
            do {
                try dispatch(type, tag, NineParse(msg, from: 3))
            } catch let e as NineError {
                if cfg.verbose { log("  -> Rerror \(e.text) (\(e.num))") }
                replyError(tag, e)
            } catch {
                replyError(tag, NineError(EIO))
            }
        }
        log("9P connection closed after \(requests) requests")
    }

    // MARK: - Framing

    private func reply(_ type: UInt8, _ tag: UInt16, _ body: NineBuf = NineBuf()) {
        var m = NineBuf()
        m.u32(UInt32(7 + body.bytes.count))
        m.u8(type)
        m.u16(tag)
        m.raw(body.bytes)
        if !wire.writeAll(m.bytes) { alive = false }
    }

    private func replyError(_ tag: UInt16, _ e: NineError) {
        var b = NineBuf()
        b.string(e.text)
        if dotu { b.u32(UInt32(bitPattern: e.num)) }
        reply(NineType.Rerror, tag, b)
    }

    private func get(_ fid: UInt32) throws -> NineFid {
        guard let f = fids[fid] else { throw NineError(EBADF, "unknown fid") }
        return f
    }

    private func forgetAll() {
        for f in fids.values { f.closeFile() }
        fids.removeAll()
    }

    /// -v, with the fields that matter.  A bare message name says a directory
    /// read happened and nothing about why it came back empty, which is the
    /// one question this log is ever asked.
    private func trace(_ type: UInt8, _ tag: UInt16, _ msg: [UInt8]) {
        var p = NineParse(msg, from: 3)
        var extra = ""
        switch type {
        case NineType.Tread, NineType.Twrite:
            if let fid = try? p.u32(), let off = try? p.u64(), let n = try? p.u32() {
                extra = " fid=\(fid) offset=\(off) count=\(n)"
            }
        case NineType.Twalk:
            if let fid = try? p.u32(), let nfid = try? p.u32(), let n = try? p.u16() {
                var names: [String] = []
                for _ in 0 ..< n {
                    guard let s = try? p.string() else { break }
                    names.append(String(decoding: s, as: UTF8.self))
                }
                extra = " fid=\(fid)->\(nfid) " + (names.isEmpty ? "(clone)" : names.joined(separator: "/"))
            }
        case NineType.Topen:
            if let fid = try? p.u32(), let m = try? p.u8() { extra = " fid=\(fid) mode=0x\(String(m, radix: 16))" }
        case NineType.Tclunk, NineType.Tstat, NineType.Tremove, NineType.Twstat:
            if let fid = try? p.u32() { extra = " fid=\(fid)" }
        default:
            break
        }
        log("\(NineType.name(type)) tag=\(tag)\(extra)")
    }

    // MARK: - Dispatch

    private func dispatch(_ type: UInt8, _ tag: UInt16, _ p: NineParse) throws {
        var p = p
        switch type {
        case NineType.Tversion: try doVersion(tag, &p)
        case NineType.Tauth:    throw NineError(EPERM, "no authentication required")
        case NineType.Tattach:  try doAttach(tag, &p)
        case NineType.Tflush:   _ = try p.u16(); reply(NineType.Rflush, tag)
        case NineType.Twalk:    try doWalk(tag, &p)
        case NineType.Topen:    try doOpen(tag, &p)
        case NineType.Tcreate:  try doCreate(tag, &p)
        case NineType.Tread:    try doRead(tag, &p)
        case NineType.Twrite:   try doWrite(tag, &p)
        case NineType.Tclunk:   try doClunk(tag, &p)
        case NineType.Tremove:  try doRemove(tag, &p)
        case NineType.Tstat:    try doStat(tag, &p)
        case NineType.Twstat:   try doWstat(tag, &p)
        default:                throw NineError(ENOTSUP, "unknown message type \(type)")
        }
    }

    // MARK: - Session

    private func doVersion(_ tag: UInt16, _ p: inout NineParse) throws {
        let want = try p.u32()
        let version = String(decoding: try p.string(), as: UTF8.self)
        // Tversion resets the connection: every fid is forgotten.
        forgetAll()
        msize = max(256, min(want, maxMsize))
        // A version we do not speak is answered "unknown", the protocol's own
        // way of saying no -- not an Rerror.  Bare 9P2000 is a subset we can
        // serve, and from then on every reply is the shorter form.
        let answer: String
        if version == Nine.version || version.hasPrefix(Nine.version + ".") {
            answer = Nine.version; dotu = true
        } else if version == "9P2000" {
            answer = "9P2000"; dotu = false
        } else {
            answer = "unknown"; dotu = false
        }
        var b = NineBuf()
        b.u32(msize)
        b.string(answer)
        reply(NineType.Rversion, tag, b)
    }

    /// No authentication: the share is bound to 127.0.0.1 and reachable only
    /// from inside this process's own simulated network, which is the same
    /// guard netfs had and the one that matters.  .u's n_uname is ignored.
    private func doAttach(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        _ = try p.u32()                                  // afid
        _ = try p.string()                               // uname
        _ = try p.string()                               // aname
        guard fids[fid] == nil else { throw NineError(EBADF, "fid in use") }
        let q = ex.qid(try ex.attrs(ex.root))
        fids[fid] = NineFid(path: ex.root, qid: q)
        var b = NineBuf()
        b.qid(q)
        reply(NineType.Rattach, tag, b)
    }

    // MARK: - Namespace

    private func doWalk(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let newfid = try p.u32()
        let n = Int(try p.u16())
        guard n <= Nine.maxWelem else { throw NineError(EINVAL, "too many walk elements") }
        var names: [[UInt8]] = []
        for _ in 0 ..< n { names.append(try p.string()) }
        let f = try get(fid)
        guard f.mode == nil else { throw NineError(EINVAL, "fid is open") }
        if newfid != fid, fids[newfid] != nil { throw NineError(EBADF, "newfid in use") }

        var path = f.path
        var qids: [NineQid] = []
        for (i, name) in names.enumerated() {
            do {
                path = try ex.walk1(path, name)
                qids.append(ex.qid(try ex.attrs(path)))
            } catch let e as NineError {
                // A walk that fails part-way is not an error: the client is told
                // how far it got and NO new fid is made.  Only a failure on the
                // very first name is an Rerror.
                if i == 0 { throw e }
                replyQids(tag, qids)
                return
            }
        }
        fids[newfid] = NineFid(path: path, qid: qids.last ?? f.qid)
        replyQids(tag, qids)
    }

    private func replyQids(_ tag: UInt16, _ qids: [NineQid]) {
        var b = NineBuf()
        b.u16(UInt16(qids.count))
        for q in qids { b.qid(q) }
        reply(NineType.Rwalk, tag, b)
    }

    private func doStat(_ tag: UInt16, _ p: inout NineParse) throws {
        let f = try get(try p.u32())
        let st = try ex.attrs(f.path)
        let name = f.path == ex.root ? "/" : ex.baseName(f.path)
        let entry = ex.statBytes(f.path, st, name: Array(name.utf8), dotu: dotu)
        var b = NineBuf()
        b.u16(UInt16(truncatingIfNeeded: entry.count))
        b.raw(entry)
        reply(NineType.Rstat, tag, b)
    }

    // MARK: - Opening

    private func doOpen(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let mode = try p.u8()
        let f = try get(fid)
        guard f.mode == nil else { throw NineError(EINVAL, "already open") }
        let st = try ex.attrs(f.path)
        let acc = mode & 3
        if acc == Nine.OWRITE || acc == Nine.ORDWR || mode & Nine.OTRUNC != 0
            || mode & Nine.ORCLOSE != 0 {
            try ex.wr()
        }
        if st.isDirectory {
            guard acc == Nine.OREAD, mode & Nine.OTRUNC == 0 else { throw NineError(EISDIR, "directory") }
            try openDir(f)
        } else {
            var flags: Int32 = acc == Nine.OWRITE ? O_WRONLY : acc == Nine.ORDWR ? O_RDWR : O_RDONLY
            if mode & Nine.OTRUNC != 0 { flags |= O_TRUNC }
            // O_NOFOLLOW: a walk never resolves a final link, so opening one
            // here would be the one place the share could be left through a
            // link the guest can see.  With `follow' the link was resolved and
            // its target admitted at walk time, so following it is the point.
            if !ex.follow { flags |= O_NOFOLLOW }
            let fd = open(f.path, flags | O_CLOEXEC)
            guard fd >= 0 else { throw NineError.host() }
            f.fd = fd
        }
        f.mode = mode
        f.rclose = mode & Nine.ORCLOSE != 0
        f.qid = ex.qid(try ex.attrs(f.path))
        var b = NineBuf()
        b.qid(f.qid)
        b.u32(msize - Nine.iohdrsz)                       // iounit
        reply(NineType.Ropen, tag, b)
    }

    /// SNAPSHOT THE DIRECTORY AT OPEN, and serve reads out of the snapshot.
    /// 9P requires that a read at the offset the last one ended on continues
    /// where it left off, and that no entry is split across replies; reading
    /// the live directory each time cannot promise either once it changes,
    /// and the guest reads a directory in 512-byte bites.
    private func openDir(_ f: NineFid) throws {
        let (e, o) = try ex.snapshot(f.path, dotu: dotu)
        f.dirents = e
        f.diroffs = o
        if cfg.verbose { log("  -> opendir \(f.path): \(e.count) entries, \(o.last ?? 0) bytes") }
    }

    // MARK: - Data

    private func doRead(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let offset = try p.u64()
        let want = try p.u32()
        let f = try get(fid)
        guard let mode = f.mode else { throw NineError(EINVAL, "not open") }
        if mode & 3 == Nine.OWRITE { throw NineError(EACCES, "opened write-only") }
        let count = Int(min(want, msize - Nine.iohdrsz))
        let data: [UInt8]
        if f.dirents != nil {
            data = try readDir(f, offset, count)
        } else {
            guard f.fd >= 0 else { throw NineError(EINVAL, "not a readable file") }
            guard offset <= UInt64(Int64.max) else { throw NineError(EINVAL, "offset out of range") }
            var buf = [UInt8](repeating: 0, count: count)
            var got = 0
            // Until the count or the end of the file: pread may stop short of
            // either, and a short reply would read to the guest as less file.
            while got < count {
                let n = buf[got...].withUnsafeMutableBytes {
                    pread(f.fd, $0.baseAddress, count - got, off_t(offset) + off_t(got))
                }
                if n < 0 { if errno == EINTR { continue }; throw NineError.host() }
                if n == 0 { break }
                got += n
            }
            data = Array(buf[0 ..< got])
        }
        if cfg.verbose { log("  -> Rread \(data.count) bytes\(f.dirents != nil ? " (directory)" : "")") }
        var b = NineBuf()
        b.u32(UInt32(data.count))
        b.raw(data)
        reply(NineType.Rread, tag, b)
    }

    /// Offsets into a directory are opaque to the client but must be ones we
    /// handed back, so they are looked up in the table made at open rather than
    /// computed.  Anything that is not an entry boundary is EINVAL.
    private func readDir(_ f: NineFid, _ offset: UInt64, _ count: Int) throws -> [UInt8] {
        var idx: Int
        if offset == 0 {
            // A REWIND RE-READS THE DIRECTORY.  The guest holds one open fid per
            // directory for the life of its handle, so without this a file made
            // through the share never appears in a later listing -- measured on
            // the machine against the python3 server: `mkdir' and `echo > f'
            // both succeeded and the next `ls' showed only the mount-time tree.
            try openDir(f)
            idx = 0
        } else {
            guard offset <= UInt64(Int.max), let k = f.diroffs.firstIndex(of: Int(offset)) else {
                throw NineError(EINVAL, "bad directory offset")
            }
            idx = k
        }
        let ents = f.dirents ?? []
        var out: [UInt8] = []
        while idx < ents.count, out.count + ents[idx].count <= count {
            out += ents[idx]
            idx += 1
        }
        return out
    }

    private func doWrite(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let offset = try p.u64()
        let count = try p.u32()
        let data = Array(p.rest().prefix(Int(count)))
        let f = try get(fid)
        try ex.wr()
        guard let mode = f.mode else { throw NineError(EINVAL, "not open") }
        if mode & 3 == Nine.OREAD { throw NineError(EACCES, "opened read-only") }
        if f.dirents != nil { throw NineError(EISDIR, "directory") }
        guard f.fd >= 0 else { throw NineError(EINVAL, "not a writable file") }
        guard offset <= UInt64(Int64.max) else { throw NineError(EINVAL, "offset out of range") }
        var done = 0
        while done < data.count {
            let n = data[done...].withUnsafeBytes {
                pwrite(f.fd, $0.baseAddress, data.count - done, off_t(offset) + off_t(done))
            }
            if n < 0 {
                if errno == EINTR { continue }
                if done == 0 { throw NineError.host() }
                break                       // a short write reports what landed
            }
            done += n
        }
        var b = NineBuf()
        b.u32(UInt32(done))
        reply(NineType.Rwrite, tag, b)
    }

    // MARK: - Mutation

    private func doCreate(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let name = try p.string()
        let perm = try p.u32()
        let mode = try p.u8()
        let ext = p.atEnd ? [] : try p.string()
        let f = try get(fid)
        try ex.wr()
        guard f.mode == nil else { throw NineError(EINVAL, "fid is open") }
        guard !name.isEmpty, name != [0x2E], name != [0x2E, 0x2E],
              !name.contains(0x2F), !name.contains(0) else {
            throw NineError(EINVAL, "bad create name")
        }
        guard try ex.attrs(f.path).isDirectory else { throw NineError(ENOTDIR, "not a directory") }
        let new = ex.join(f.path, String(decoding: name, as: UTF8.self))
        guard ex.contains(new) else { throw NineError(EACCES, "outside the export") }
        let bits = mode_t(perm & 0o777)
        if perm & Nine.DMDIR != 0 {
            guard mkdir(new, bits) == 0 else { throw NineError.host() }
            f.path = new
            try openDir(f)
        } else if perm & Nine.DMSYMLINK != 0 {
            let target = String(decoding: ext, as: UTF8.self)
            guard symlink(target, new) == 0 else { throw NineError.host() }
            f.path = new
        } else if perm & Nine.DMNAMEDPIPE != 0 {
            guard mkfifo(new, bits) == 0 else { throw NineError.host() }
            f.path = new
        } else if perm & Nine.DMDEVICE != 0 {
            try makeDevice(new, bits, ext)
            f.path = new
        } else {
            let acc = mode & 3
            var flags = O_CREAT | O_EXCL | O_CLOEXEC
            flags |= (acc == Nine.ORDWR || acc == Nine.OWRITE) ? O_RDWR : O_RDONLY
            let fd = open(new, flags, bits)
            guard fd >= 0 else { throw NineError.host() }
            f.path = new
            f.fd = fd
        }
        f.mode = mode
        f.rclose = mode & Nine.ORCLOSE != 0
        f.qid = ex.qid(try ex.attrs(f.path))
        var b = NineBuf()
        b.qid(f.qid)
        b.u32(msize - Nine.iohdrsz)
        reply(NineType.Rcreate, tag, b)
    }

    /// .u's device create: the extension is `c major minor' or `b ...'.
    /// makedev() is a macro on both hosts and neither imports it, so the two
    /// encodings Host.swift's deviceNumbers reads are written out here.
    private func makeDevice(_ path: String, _ bits: mode_t, _ ext: [UInt8]) throws {
        let f = String(decoding: ext, as: UTF8.self).split(separator: " ")
        guard f.count == 3, f[0] == "c" || f[0] == "b",
              let maj = UInt64(f[1]), let min = UInt64(f[2]) else {
            throw NineError(EINVAL, "bad device extension")
        }
        #if canImport(Darwin)
        let dev = dev_t(truncatingIfNeeded: (maj << 24) | (min & 0xff_ffff))
        #else
        let lo: UInt64 = (min & 0xff) | ((maj & 0xfff) << 8)
        let hi: UInt64 = ((min & ~UInt64(0xff)) << 12) | ((maj & ~UInt64(0xfff)) << 32)
        let dev = dev_t(lo | hi)
        #endif
        let type = f[0] == "c" ? S_IFCHR : S_IFBLK
        guard mknod(path, bits | type, dev) == 0 else { throw NineError.host() }
    }

    private func doClunk(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let f = try get(fid)
        fids[fid] = nil
        f.closeFile()
        // ORCLOSE's failure is not reportable: the fid is already gone.
        if f.rclose, !ex.readOnly { try? ex.unlinkPath(f.path) }
        reply(NineType.Rclunk, tag)
    }

    private func doRemove(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        let f = try get(fid)
        // The fid is clunked whether or not the remove succeeds.  That is the
        // protocol's rule and it is easy to get wrong by returning early.
        fids[fid] = nil
        f.closeFile()
        try ex.wr()
        guard f.path != ex.root else { throw NineError(EACCES, "cannot remove the export root") }
        try ex.unlinkPath(f.path)
        reply(NineType.Rremove, tag)
    }

    private func doWstat(_ tag: UInt16, _ p: inout NineParse) throws {
        let fid = try p.u32()
        _ = try p.u16()                          // the wrapping size; the entry re-states it
        let f = try get(fid)
        try ex.wr()
        var s = NineParse(p.rest())
        _ = try s.u16()                          // size
        _ = try s.u16()                          // type
        _ = try s.u32()                          // dev
        _ = try s.u8(); _ = try s.u32(); _ = try s.u64()      // qid
        let mode = try s.u32()
        let atime = try s.u32()
        let mtime = try s.u32()
        let length = try s.u64()
        let name = try s.string()
        _ = try s.string(); _ = try s.string(); _ = try s.string()   // uid, gid, muid: not honoured
        // .u's extension and numeric ids may follow; a bare 9P2000 entry stops here.

        // RENAME FIRST, because everything after works on the new path, and a
        // rename that fails must not leave half a wstat applied.
        if !name.isEmpty {
            guard !name.contains(0x2F), name != [0x2E], name != [0x2E, 0x2E], !name.contains(0) else {
                throw NineError(EINVAL, "bad name")
            }
            let new = ex.join(ex.parent(f.path), String(decoding: name, as: UTF8.self))
            guard ex.contains(new) else { throw NineError(EACCES, "outside the export") }
            if new != f.path {
                // lstat, not exists(): python3's os.path.exists follows a link,
                // so a rename onto a DANGLING link replaced it.  Any entry under
                // the name refuses the rename.
                var st = stat()
                if lstat(new, &st) == 0 { throw NineError(EEXIST, "name exists") }
                guard rename(f.path, new) == 0 else { throw NineError.host() }
                f.path = new
            }
        }
        var lst = stat()
        guard lstat(f.path, &lst) == 0 else { throw NineError.host() }
        // A LINK IS NEVER CHANGED THROUGH WITHOUT `follow'.  chmod and truncate
        // follow a symlink, and without -L a walk admits one whatever it points
        // at -- so a Twstat on a link to a file outside the share changed that
        // file.  tools/9pfsd.py did exactly that; it refuses now, as this does.
        let throughLink = lst.isSymlink && !ex.follow
        if mode != Nine.notouch4 {
            if throughLink { throw NineError(EINVAL, "not through a symlink") }
            guard chmod(f.path, mode_t(mode & 0o777)) == 0 else { throw NineError.host() }
        }
        if atime != Nine.notouch4 || mtime != Nine.notouch4 {
            // UTIME_OMIT leaves the untouched one exactly as it was, rather than
            // rounding it to the second it would be read back as.
            var ts = [timespec(), timespec()]
            ts[0].tv_sec = Int(atime)
            ts[1].tv_sec = Int(mtime)
            if atime == Nine.notouch4 { ts[0].tv_nsec = hostUTimeOmit }
            if mtime == Nine.notouch4 { ts[1].tv_nsec = hostUTimeOmit }
            guard utimensat(AT_FDCWD, f.path, ts, throughLink ? AT_SYMLINK_NOFOLLOW : 0) == 0 else {
                throw NineError.host()
            }
        }
        if length != Nine.notouch8 {
            // TRUNCATE IS A wstat, not a message of its own; V10's t_trunc
            // lands here.
            if throughLink { throw NineError(EINVAL, "not through a symlink") }
            guard length <= UInt64(Int64.max) else { throw NineError(EINVAL, "length out of range") }
            let r = f.fd >= 0 ? ftruncate(f.fd, off_t(length)) : truncate(f.path, off_t(length))
            guard r == 0 else { throw NineError.host() }
        }
        reply(NineType.Rwstat, tag)
    }
}
