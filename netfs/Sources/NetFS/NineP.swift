//
//  NineP.swift -- 9P2000.u on the wire: the numbers, the encoder, the parser.
//
//  V10's share.  netfs is V8's and stays exactly as it is: V8 has only `neta',
//  the first of the two netfs protocols, and no tape carries a libneta, so V8
//  cannot be moved off it without a kernel client.  V10 needs no kernel client
//  at all, because its fmount(2) takes a FILE DESCRIPTOR -- runfs pipes a user
//  process onto a mount point, and that process (v10/usr/src/build/src/9pfs.c)
//  speaks netb to the kernel and 9P to this.  CLAUDE.md, "Two share protocols".
//
//  THIS IS THE SECOND SERVER FOR ONE PROTOCOL, AND THE FIRST IS THE SPEC.
//  tools/9pfsd.py is the server the guest was proven against -- boot after boot
//  and a whole V10 build over it -- and every behaviour here is that file's,
//  read off it rather than re-derived: the dense qid.paths with the root at 2,
//  the directory snapshot a rewind re-reads, the 14-byte name fallback, -L.
//  Where this one differs it says so at the place, and the python3 server was
//  changed to match.  tools/9pfsd-selftest.py --server holds the two to one
//  wire, which is the only thing that can: they share no code.
//
//  WHY 9P2000.u, in one line: Rerror's errno.  The client is a 1989 kernel whose
//  whole error convention is `u.u_error = <errno>', and plain 9P2000 sends only
//  a string.  9P2000.L would carry one too, at three times the surface and in
//  Linux's shape; tools/9pfsd.py's header has the measurement that settled it.
//
//  Everything is little-endian.  A string is a 2-byte count and that many bytes
//  with no terminator; 9P has no NUL anywhere.
//
import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// Message types.  9P2000 numbers T-messages even and R-messages odd from 100.
enum NineType {
    static let Tversion: UInt8 = 100, Rversion: UInt8 = 101
    static let Tauth: UInt8 = 102,    Rauth: UInt8 = 103
    static let Tattach: UInt8 = 104,  Rattach: UInt8 = 105
    static let Rerror: UInt8 = 107                       // 106 is illegal
    static let Tflush: UInt8 = 108,   Rflush: UInt8 = 109
    static let Twalk: UInt8 = 110,    Rwalk: UInt8 = 111
    static let Topen: UInt8 = 112,    Ropen: UInt8 = 113
    static let Tcreate: UInt8 = 114,  Rcreate: UInt8 = 115
    static let Tread: UInt8 = 116,    Rread: UInt8 = 117
    static let Twrite: UInt8 = 118,   Rwrite: UInt8 = 119
    static let Tclunk: UInt8 = 120,   Rclunk: UInt8 = 121
    static let Tremove: UInt8 = 122,  Rremove: UInt8 = 123
    static let Tstat: UInt8 = 124,    Rstat: UInt8 = 125
    static let Twstat: UInt8 = 126,   Rwstat: UInt8 = 127

    static func name(_ t: UInt8) -> String {
        switch t {
        case Tversion: return "Tversion"; case Tauth: return "Tauth"
        case Tattach: return "Tattach";   case Tflush: return "Tflush"
        case Twalk: return "Twalk";       case Topen: return "Topen"
        case Tcreate: return "Tcreate";   case Tread: return "Tread"
        case Twrite: return "Twrite";     case Tclunk: return "Tclunk"
        case Tremove: return "Tremove";   case Tstat: return "Tstat"
        case Twstat: return "Twstat"
        default: return "T?\(t)"
        }
    }
}

enum Nine {
    static let notag: UInt16 = 0xFFFF
    static let nofid: UInt32 = 0xFFFF_FFFF
    /// Most names one Twalk may carry.
    static let maxWelem = 16
    static let version = "9P2000.u"
    /// Twrite's header: size, type, tag, fid, offset, count.
    static let iohdrsz: UInt32 = 24
    static let defaultMsize: UInt32 = 8192 + iohdrsz

    // qid.type
    static let QTDIR: UInt8 = 0x80, QTSYMLINK: UInt8 = 0x02, QTFILE: UInt8 = 0x00

    // stat.mode -- the high bits; the bottom nine are rwxrwxrwx unchanged.
    static let DMDIR: UInt32 = 0x8000_0000
    static let DMSYMLINK: UInt32 = 0x0200_0000       // .u
    static let DMDEVICE: UInt32 = 0x0080_0000        // .u
    static let DMNAMEDPIPE: UInt32 = 0x0020_0000     // .u
    static let DMSOCKET: UInt32 = 0x0010_0000        // .u
    static let DMSETUID: UInt32 = 0x0008_0000        // .u
    static let DMSETGID: UInt32 = 0x0004_0000        // .u

    // Topen/Tcreate mode
    static let OREAD: UInt8 = 0, OWRITE: UInt8 = 1, ORDWR: UInt8 = 2, OEXEC: UInt8 = 3
    static let OTRUNC: UInt8 = 0x10, ORCLOSE: UInt8 = 0x40

    /// "Do not touch": every fixed-width field of a Twstat may be all ones to
    /// mean leave it alone.  A zero would mean 1970 or an empty file, so the
    /// distinction is not cosmetic.
    static let notouch2: UInt16 = 0xFFFF
    static let notouch4: UInt32 = 0xFFFF_FFFF
    static let notouch8: UInt64 = 0xFFFF_FFFF_FFFF_FFFF

    /// V10's `struct direct' name field, <sys/dir.h>.
    static let dirsiz = 14
}

/// An Rerror to send.  `num` is what .u puts on the wire, and it is the HOST's
/// errno, as tools/9pfsd.py sends it: 9pfs.c's n9err() maps the numbers V7
/// gave every Unix -- ENOENT, EACCES, EROFS and the rest, which Darwin, Glibc
/// and V10 agree on -- and turns anything else into EIO, so a host's private
/// numbering never reaches the kernel as something it is not.
struct NineError: Error {
    let num: Int32
    let text: String

    init(_ num: Int32, _ text: String? = nil) {
        self.num = num
        self.text = text ?? String(cString: strerror(num))
    }

    /// The errno a failed call just left, captured before anything else can
    /// overwrite it.
    static func host() -> NineError { NineError(errno) }
}

struct NineQid: Equatable {
    var type: UInt8
    var version: UInt32
    var path: UInt64
}

/// A message being built.
struct NineBuf {
    private(set) var bytes: [UInt8] = []

    init() {}

    mutating func u8(_ v: UInt8) { bytes.append(v) }
    mutating func u16(_ v: UInt16) { bytes.append(UInt8(v & 0xff)); bytes.append(UInt8(v >> 8)) }
    mutating func u32(_ v: UInt32) {
        for s in stride(from: 0, to: 32, by: 8) { bytes.append(UInt8((v >> UInt32(s)) & 0xff)) }
    }
    mutating func u64(_ v: UInt64) {
        for s in stride(from: 0, to: 64, by: 8) { bytes.append(UInt8((v >> UInt64(s)) & 0xff)) }
    }
    mutating func raw<S: Sequence>(_ v: S) where S.Element == UInt8 { bytes.append(contentsOf: v) }

    /// A 9P string from raw bytes.  Longer than a count can say is cut, which
    /// no name a filesystem hands out ever is.
    mutating func string(_ b: [UInt8]) {
        let n = min(b.count, Int(UInt16.max))
        u16(UInt16(n))
        bytes.append(contentsOf: b.prefix(n))
    }
    mutating func string(_ s: String) { string(Array(s.utf8)) }

    mutating func qid(_ q: NineQid) { u8(q.type); u32(q.version); u64(q.path) }
}

/// A message being taken apart.  Running off the end is EPROTO, never a trap:
/// a malformed message from the guest must cost it an Rerror, not cost us the
/// connection thread.
struct NineParse {
    let d: [UInt8]
    private(set) var i: Int

    init(_ d: [UInt8], from i: Int = 0) { self.d = d; self.i = i }

    var atEnd: Bool { i >= d.count }

    mutating func need(_ n: Int) throws -> ArraySlice<UInt8> {
        guard n >= 0, i + n <= d.count else { throw NineError(EPROTO, "short message") }
        defer { i += n }
        return d[i ..< i + n]
    }

    mutating func u8() throws -> UInt8 { try need(1).first! }
    mutating func u16() throws -> UInt16 {
        let s = try need(2)
        return UInt16(s[s.startIndex]) | UInt16(s[s.startIndex + 1]) << 8
    }
    mutating func u32() throws -> UInt32 {
        let s = try need(4)
        var v: UInt32 = 0
        for (k, b) in s.enumerated() { v |= UInt32(b) << UInt32(8 * k) }
        return v
    }
    mutating func u64() throws -> UInt64 {
        let s = try need(8)
        var v: UInt64 = 0
        for (k, b) in s.enumerated() { v |= UInt64(b) << UInt64(8 * k) }
        return v
    }

    /// The raw bytes of a string.  Raw, because a name the guest truncated to
    /// its 14 bytes can end part-way through a UTF-8 sequence, and the 14-byte
    /// fallback has to compare exactly those bytes.
    mutating func string() throws -> [UInt8] { Array(try need(Int(try u16()))) }

    mutating func rest() -> [UInt8] {
        defer { i = d.count }
        return Array(d[min(i, d.count)...])
    }
}

/// Little-endian reads straight out of a byte array, for the framing and the
/// trace, where a parser would be ceremony.
@inline(__always)
func le32(_ b: [UInt8], _ o: Int) -> UInt32 {
    UInt32(b[o]) | UInt32(b[o + 1]) << 8 | UInt32(b[o + 2]) << 16 | UInt32(b[o + 3]) << 24
}
