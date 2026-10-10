//
//  NineExport.swift -- the served directory, and every policy decision about
//  it: containment, names, attributes.  tools/9pfsd.py's `Export', and where
//  the two differ the note says why and the python3 server now agrees.
//
//  THE GUEST IS A 1989 KERNEL WITH A 16-BIT ino_t, and that shapes two things:
//
//  1. qid.path IS HANDED OUT DENSE AND SMALL, from 3 upward, with the root at 2.
//     (st_dev, st_ino) would fit 9P's 8-byte path with room to spare, and the
//     guest cannot use it: V10's ino_t is `unsigned short' (sys/types.h:40), so
//     9pfs.c folds a qid.path into 16 bits, and folding 10,000 files collides
//     about as often as not.  2 is reserved because param.h:51 is `#define
//     ROOTINO ((ino_t)2)' and every mounted root must carry it.  The table is
//     shared by every connection to one share, so a remount keeps its numbers.
//
//  2. NAMES ARE 14 BYTES ON THE GUEST, so a user who types what `ls' printed
//     sends a truncated name.  A walk of exactly 14 bytes that finds nothing
//     is retried against every name whose first 14 bytes match, and only a
//     unique match is taken (-T turns this off, for conformance testing).
//
//  SYMLINKS, AND WHY `follow' EXISTS.  9P2000.u can describe a symlink and by
//  default this does.  The guest cannot use one: netb's <rf.h> gives an Rfile
//  exactly two types, so 9pfs.c maps DMSYMLINK to a regular file whose Topen
//  then fails, because a walk never resolves a final link and the open carries
//  O_NOFOLLOW.  With `follow' (the python3 server's -L, and what the app always
//  uses) a link is stat'ed THROUGH, and containment is checked on the RESOLVED
//  path, because following is exactly the operation that could leave the share.
//
import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

final class NineExport: @unchecked Sendable {
    /// The realpath of the exported directory.  Resolved ONCE: every path the
    /// server builds is this plus components, and a symlinked root would make
    /// the containment test compare against a name nothing else produces --
    /// on iOS the container is under /var, which is /private/var.
    let root: String
    let readOnly: Bool
    let uid: UInt32
    let gid: UInt32
    let strict: Bool
    let follow: Bool
    let uname: String
    let gname: String

    private struct Key: Hashable { let dev: UInt64; let ino: UInt64 }
    private var qidPaths: [Key: UInt64] = [:]
    private var nextPath: UInt64 = 3
    private let lock = NSLock()

    init(_ cfg: NineConfig) throws {
        guard let r = Self.resolve(cfg.root) else { throw NineError.host() }
        var st = stat()
        guard lstat(r, &st) == 0 else { throw NineError.host() }
        guard st.isDirectory else { throw NineError(ENOTDIR, "\(r) is not a directory") }
        root = r
        readOnly = cfg.readOnly
        uid = cfg.uid
        gid = cfg.gid
        strict = cfg.strict
        follow = cfg.follow
        uname = cfg.uid == 0 ? "root" : String(cfg.uid)
        gname = cfg.gid == 0 ? "root" : String(cfg.gid)
        qidPaths[Self.key(st)] = 2                                  // ROOTINO
    }

    // MARK: - Paths

    static func resolve(_ p: String) -> String? {
        guard let r = realpath(p, nil) else { return nil }
        defer { free(r) }
        return String(cString: r)
    }

    /// realpath that resolves AS FAR AS IT CAN and appends the rest, which is
    /// python3's os.path.realpath and so the answer tools/9pfsd.py's
    /// containment tests are asked against.  C's realpath fails outright on a
    /// dangling link, and using it here refused a link to a file not yet
    /// created inside the share, which the python3 server lists and describes.
    /// A loop stops at the depth limit with the path as it stands, as
    /// python3's does: following it fails with ELOOP, so nothing escapes.
    private func lenient(_ p: String, _ depth: Int = 0) -> String {
        if let r = Self.resolve(p) { return r }
        guard depth < 40 else { return p }
        var st = stat()
        if lstat(p, &st) == 0, st.isSymlink {
            var buf = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
            let n = readlink(p, &buf, buf.count - 1)
            guard n > 0 else { return p }
            let t = String(decoding: buf[0 ..< n].map { UInt8(bitPattern: $0) }, as: UTF8.self)
            return lenient(t.hasPrefix("/") ? t : join(parent(p), t), depth + 1)
        }
        let up = parent(p)
        guard up != p else { return p }
        let base = lenient(up, depth + 1)
        switch baseName(p) {
        case "", ".": return base
        case "..": return parent(base)
        case let name: return join(base, name)
        }
    }

    func join(_ dir: String, _ name: String) -> String {
        dir == "/" ? "/" + name : dir + "/" + name
    }

    func parent(_ p: String) -> String {
        guard let i = p.lastIndex(of: "/") else { return "." }
        return i == p.startIndex ? "/" : String(p[..<i])
    }

    func baseName(_ p: String) -> String {
        guard let i = p.lastIndex(of: "/") else { return p }
        return String(p[p.index(after: i)...])
    }

    private func within(_ rp: String) -> Bool {
        root == "/" || rp == root || rp.hasPrefix(root + "/")
    }

    /// Is `path` inside the export?  Asked of the REALPATH OF ITS PARENT plus
    /// the final component, never of realpath(path): the second resolves a
    /// final symlink, so a link to /etc/passwd would test as outside and be
    /// refused although 9P describes it and never follows it.  The parent test
    /// is the one that stops a walk escaping through a directory link.
    func contains(_ path: String) -> Bool {
        within(lenient(parent(path)))
    }

    /// Is the FULLY RESOLVED path inside?  Only asked with `follow', where
    /// following a link is the one operation that can leave.
    func inside(_ path: String) -> Bool {
        within(lenient(path))
    }

    /// The read-only guard.  Called by every mutating operation, and the
    /// absence of write permission is the whole of it.
    func wr() throws {
        if readOnly { throw NineError(EROFS, "read-only share") }
    }

    // MARK: - Names

    /// One element of a walk; the new host path.
    func walk1(_ path: String, _ raw: [UInt8]) throws -> String {
        guard !raw.isEmpty, !raw.contains(0x2F), !raw.contains(0) else {
            throw NineError(EINVAL, "bad walk name")
        }
        if raw == [0x2E] { return path }
        if raw == [0x2E, 0x2E] {
            // Out of the root stays at the root: the 9P convention for an
            // exported tree, and the guarantee that no run of `..' can climb.
            return path == root ? path : parent(path)
        }
        let direct = join(path, String(decoding: raw, as: UTF8.self))
        // CONTAINMENT FIRST, before anything is asked of the name, as
        // tools/9pfsd.py does: under a directory link that leaves the share
        // every name is EACCES, so ENOENT never says what exists out there.
        guard contains(direct) else { throw NineError(EACCES, "outside the export") }
        var found = direct
        var st = stat()
        if lstat(direct, &st) != 0 {
            let e = errno
            guard e == ENOENT else { throw NineError(e) }
            // THE 14-BYTE FALLBACK, for a name exactly DIRSIZ long only: a
            // shorter one was not truncated and a longer one cannot have come
            // from this guest.  Bytes, not characters, because 14 BYTES is what
            // the guest cut.  Ambiguity is refused rather than guessed.
            guard !strict, raw.count == Nine.dirsiz else { throw NineError(ENOENT, "no such file") }
            let hits = try names(in: path).filter { Array($0.utf8.prefix(Nine.dirsiz)) == raw }
            guard hits.count == 1 else { throw NineError(ENOENT, "no such file") }
            found = join(path, hits[0])
        }
        // AND THE FOLLOW CHECK ON WHATEVER WAS FOUND, the fallback's match
        // included.  tools/9pfsd.py checked only a direct hit, so under -L a
        // link with a long name out of the tree was followed when walked by its
        // first 14 bytes; fixed there too, and the selftest now asks.
        if follow && !inside(found) { throw NineError(EACCES, "symlink leaves the export") }
        return found
    }

    /// The directory's entries, sorted, without `.' and `..', which a 9P read
    /// never carries (9pfs.c synthesises the pair for V10's readers).  A name
    /// that is not UTF-8 is left out: 9P names are UTF-8, and one repaired to
    /// make it so would be a name nothing on the host answers to.
    func names(in dir: String) throws -> [String] {
        guard let d = opendir(dir) else { throw NineError.host() }
        defer { closedir(d) }
        var out: [String] = []
        while let ent = readdir(d) {
            let name = withUnsafeBytes(of: ent.pointee.d_name) { raw -> String? in
                let b = raw.bindMemory(to: UInt8.self)
                return String(validating: b[..<(b.firstIndex(of: 0) ?? b.count)], as: UTF8.self)
            }
            guard let n = name, n != ".", n != ".." else { continue }
            out.append(n)
        }
        // Byte order, which is code-point order, which is what python3's
        // sorted() gives -- so the two servers list a directory identically.
        return out.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }
    }

    // MARK: - Attributes

    /// The stat every walked path is described by.  With `follow' it goes
    /// through a link and falls back to the link itself when the target is
    /// missing, so a dangling link is reported rather than failing a whole
    /// directory read.  Only ever asked of a path a walk has already admitted.
    func attrs(_ path: String) throws -> stat {
        var st = stat()
        if follow, stat(path, &st) == 0 { return st }
        guard lstat(path, &st) == 0 else { throw NineError.host() }
        return st
    }

    /// The stat a DIRECTORY LISTING describes an entry by.  Without `follow'
    /// that is lstat, as it is for a walk.  With it, a link that stays inside
    /// is stat'ed through -- the same answer a walk of the name gives, so the
    /// i-number the guest lists (9pfs.c builds V10's dirread record from the
    /// listing's qid.path) is the one stat(2) then returns for the same name.
    /// tools/9pfsd.py listed every entry by lstat, so under -L a link listed
    /// as one file and stat'ed as another; it agrees with this now.  A link
    /// that leaves stays described as the link: stat'ing through it would
    /// report the size and times of a file outside the share.
    func listAttrs(_ path: String) -> stat? {
        var st = stat()
        guard lstat(path, &st) == 0 else { return nil }      // vanished
        if follow, st.isSymlink, inside(path) {
            var t = stat()
            if stat(path, &t) == 0 { return t }
        }
        return st
    }

    private static func key(_ st: stat) -> Key {
        Key(dev: UInt64(truncatingIfNeeded: st.st_dev), ino: UInt64(truncatingIfNeeded: st.st_ino))
    }

    /// qid.path is unique per file for the life of the share and small enough
    /// to be an i-number; qid.version changes when the contents do.
    func qid(_ st: stat) -> NineQid {
        let type: UInt8 = st.isDirectory ? Nine.QTDIR : st.isSymlink ? Nine.QTSYMLINK : Nine.QTFILE
        let k = Self.key(st)
        lock.lock()
        defer { lock.unlock() }
        let path: UInt64
        if let p = qidPaths[k] {
            path = p
        } else {
            path = nextPath
            nextPath += 1
            qidPaths[k] = path
        }
        return NineQid(type: type, version: UInt32(truncatingIfNeeded: st.mtimeSeconds), path: path)
    }

    func mode(_ st: stat) -> UInt32 {
        var m = st.modeBits & 0o777
        if st.isDirectory { m |= Nine.DMDIR }
        else if st.isSymlink { m |= Nine.DMSYMLINK }
        else if st.isCharDevice || st.isBlockDevice { m |= Nine.DMDEVICE }
        else if st.isFIFO { m |= Nine.DMNAMEDPIPE }
        else if st.isSocket { m |= Nine.DMSOCKET }
        if st.modeBits & 0o4000 != 0 { m |= Nine.DMSETUID }
        if st.modeBits & 0o2000 != 0 { m |= Nine.DMSETGID }
        return m
    }

    /// .u's one variable-width attribute: a symlink's target, or a device's
    /// kind and numbers as `c major minor'.
    func extensionBytes(_ path: String, _ st: stat) -> [UInt8] {
        if st.isSymlink {
            var buf = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
            let n = readlink(path, &buf, buf.count - 1)
            return n > 0 ? buf[0 ..< n].map { UInt8(bitPattern: $0) } : []
        }
        if st.isCharDevice || st.isBlockDevice {
            let (maj, min) = st.deviceNumbers
            return Array("\(st.isCharDevice ? "c" : "b") \(maj) \(min)".utf8)
        }
        return []
    }

    /// One machine-independent stat entry, its own 2-byte size included.
    ///
    /// THE .u FIELDS ARE CONDITIONAL AND THAT IS NOT COSMETIC.  Under bare
    /// 9P2000 an entry ends at muid; sending .u's four extra fields to a client
    /// that agreed to the shorter form is a wire bug with no symptom on our
    /// side.  The python3 server's first version did it, and it took
    /// 9fans.net/go/plan9, which speaks 9P2000 and nothing else, to say
    /// `malformed Dir'.
    func statBytes(_ path: String, _ st: stat, name: [UInt8], dotu: Bool) -> [UInt8] {
        var body = NineBuf()
        body.u16(0)                                       // type -- for kernel use
        body.u32(0)                                       // dev  -- for kernel use
        body.qid(qid(st))
        body.u32(mode(st))
        body.u32(UInt32(truncatingIfNeeded: st.atimeSeconds))
        body.u32(UInt32(truncatingIfNeeded: st.mtimeSeconds))
        body.u64(st.isDirectory ? 0 : UInt64(truncatingIfNeeded: st.st_size))
        body.string(name)
        body.string(uname)
        body.string(gname)
        body.string(uname)                                // muid
        if dotu {
            body.string(extensionBytes(path, st))
            body.u32(uid)                                 // n_uid
            body.u32(gid)                                 // n_gid
            body.u32(uid)                                 // n_muid
        }
        var out = NineBuf()
        out.u16(UInt16(truncatingIfNeeded: body.bytes.count))
        out.raw(body.bytes)
        return out.bytes
    }

    /// The listing a directory fid serves its reads from: each entry encoded
    /// once, and the byte offset each one starts at.
    func snapshot(_ dir: String, dotu: Bool) throws -> (entries: [[UInt8]], offsets: [Int]) {
        var entries: [[UInt8]] = []
        var offsets = [0]
        var pos = 0
        for n in try names(in: dir) {
            let full = join(dir, n)
            guard let st = listAttrs(full) else { continue }
            let e = statBytes(full, st, name: Array(n.utf8), dotu: dotu)
            entries.append(e)
            pos += e.count
            offsets.append(pos)
        }
        return (entries, offsets)
    }

    /// Remove a file or an empty directory.
    func unlinkPath(_ path: String) throws {
        var st = stat()
        guard lstat(path, &st) == 0 else { throw NineError.host() }
        let r = st.isDirectory ? rmdir(path) : unlink(path)
        guard r == 0 else { throw NineError.host() }
    }
}
