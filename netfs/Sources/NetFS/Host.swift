//
//  Host.swift -- the places Darwin and Glibc spell POSIX apart.
//
//  This folder is compiled into the app AND built by SwiftPM on Linux, and the
//  Package.swift header says nothing in it may grow a Mac-only dependency.  It
//  had anyway, quietly: `st_atimespec' is Darwin's name for a field Glibc calls
//  `st_atim', `st_dev' is an Int32 on Darwin and a UInt64 on Glibc, SOCK_STREAM
//  is an Int32 on one and an enum on the other, and IPPROTO_TCP an Int32 and an
//  Int.  The package failed to compile on Linux on all four counts -- found 10
//  Oct 2026, the first time it was built there since the python3 netfsd made a
//  Linux Swift unnecessary -- while CLAUDE.md said it built.  What is below is
//  the whole difference, so nothing else has to know it exists.
//
import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

extension stat {
    /// Seconds since the epoch.
    var atimeSeconds: Int {
        #if canImport(Darwin)
        return Int(st_atimespec.tv_sec)
        #else
        return Int(st_atim.tv_sec)
        #endif
    }

    var mtimeSeconds: Int {
        #if canImport(Darwin)
        return Int(st_mtimespec.tv_sec)
        #else
        return Int(st_mtim.tv_sec)
        #endif
    }

    var ctimeSeconds: Int {
        #if canImport(Darwin)
        return Int(st_ctimespec.tv_sec)
        #else
        return Int(st_ctim.tv_sec)
        #endif
    }

    /// The file type bits, as one width on both hosts: `mode_t' is a UInt16 on
    /// Darwin and a UInt32 on Glibc, and so are the S_IF* constants beside it.
    var fileType: UInt32 {
        UInt32(truncatingIfNeeded: st_mode) & UInt32(truncatingIfNeeded: S_IFMT)
    }

    var isDirectory: Bool { fileType == UInt32(truncatingIfNeeded: S_IFDIR) }
    var isSymlink: Bool { fileType == UInt32(truncatingIfNeeded: S_IFLNK) }
    var isRegular: Bool { fileType == UInt32(truncatingIfNeeded: S_IFREG) }
    var isCharDevice: Bool { fileType == UInt32(truncatingIfNeeded: S_IFCHR) }
    var isBlockDevice: Bool { fileType == UInt32(truncatingIfNeeded: S_IFBLK) }
    var isFIFO: Bool { fileType == UInt32(truncatingIfNeeded: S_IFIFO) }
    var isSocket: Bool { fileType == UInt32(truncatingIfNeeded: S_IFSOCK) }

    /// The permission and set-id bits, as a UInt32 on both hosts.
    var modeBits: UInt32 { UInt32(truncatingIfNeeded: st_mode) & 0o7777 }

    /// A device's numbers.  Both are macros in C and neither is imported, and
    /// the encodings differ: Darwin packs 8 bits of major over 24 of minor,
    /// Glibc splits each across the low and high words (sys/sysmacros.h).
    var deviceNumbers: (major: UInt64, minor: UInt64) {
        let d = UInt64(truncatingIfNeeded: st_rdev)
        #if canImport(Darwin)
        return ((d >> 24) & 0xff, d & 0xff_ffff)
        #else
        return (((d >> 8) & 0xfff) | ((d >> 32) & 0xffff_f000),
                (d & 0xff) | ((d >> 12) & 0xffff_ff00))
        #endif
    }
}

/// `socket(AF_INET, hostSockStream, 0)`.  SOCK_STREAM is an Int32 on Darwin and
/// a `__socket_type` enum on Glibc.
let hostSockStream: Int32 = {
    #if canImport(Darwin)
    return SOCK_STREAM
    #else
    return Int32(SOCK_STREAM.rawValue)
    #endif
}()

/// IPPROTO_TCP is an Int32 on Darwin and an Int on Glibc.
let hostIPProtoTCP = Int32(IPPROTO_TCP)

/// utimensat's "leave this one alone".  A macro on both hosts, with different
/// values: -2 on Darwin, (1 << 30) - 2 on Glibc.
let hostUTimeOmit: Int = {
    #if canImport(Darwin)
    return -2
    #else
    return (1 << 30) - 2
    #endif
}()
