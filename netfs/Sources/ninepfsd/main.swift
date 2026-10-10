//
//  ninepfsd -- serve a host directory to Research Unix V10 over 9P2000.u.
//
//  Usage: ninepfsd [-p port] [-w] [-v] [-u uid] [-g gid] [-m msize] [-T] [-L] [-N] <directory>
//
//    -p  TCP port on 127.0.0.1 (default 9200)
//    -w  read/write; the default is READ-ONLY, and the absence of -w is the
//        whole guard
//    -v  trace every message
//    -u  uid to present every file as (default 0)
//    -g  gid to present every file as (default 0)
//    -m  largest message to negotiate (default 8216 = 8192 + IOHDRSZ)
//    -T  strict 9P: no 14-byte name fallback
//    -L  follow symlinks instead of describing them
//    -N  ALSO speak netfs on the same port, telling the two apart by the first
//        byte -- exactly how the app's shares listen, so that path is the one
//        the selftests and a booted guest check
//
//  The same flags as tools/9pfsd.py, so either is a drop-in for the other and
//  tools/9pfsd-selftest.py --server checks both.  The guest reaches this at
//  10.0.2.2:<port>: SLiRP rewrites every address inside its virtual network to
//  host loopback, so nothing is forwarded.
//
//  Named ninepfsd and not 9pfsd because a Swift module name cannot begin with
//  a digit, and the target's name is its module's.
//
import Foundation
import NetFS

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

// A reply to a guest that has gone must not take the server down with it:
// write(2) to a closed socket raises SIGPIPE.  The app refuses it per socket
// (SO_NOSIGPIPE, ShareServer.swift); Linux has no such option, so here it is
// ignored, and the write fails with EPIPE instead.
signal(SIGPIPE, SIG_IGN)

var port: UInt16 = 9200
var readOnly = true
var verbose = false
var uid: UInt32 = 0
var gid: UInt32 = 0
var msize: UInt32 = 8192 + 24
var strict = false
var follow = false
var alsoNetfs = false
var root: String? = nil

func usage() -> Never {
    print("usage: ninepfsd [-p port] [-w] [-v] [-u uid] [-g gid] [-m msize] [-T] [-L] [-N] <directory>")
    exit(2)
}

var args = Array(CommandLine.arguments.dropFirst())

/// The next argument as a number of type T, or the usage message.
@MainActor func number<T: FixedWidthInteger>() -> T {
    guard !args.isEmpty, let v = T(args.removeFirst()) else { usage() }
    return v
}

while let arg = args.first {
    args.removeFirst()
    switch arg {
    case "-p": port = number()
    case "-w": readOnly = false
    case "-v": verbose = true
    case "-u": uid = number()
    case "-g": gid = number()
    case "-m": msize = number()
    case "-T": strict = true
    case "-L": follow = true
    case "-N": alsoNetfs = true
    case "-h", "--help": usage()
    default: root = arg
    }
}

guard let root else {
    FileHandle.standardError.write(Data("ninepfsd: no directory to export\n".utf8))
    exit(2)
}

var st = stat()
guard stat(root, &st) == 0, (st.st_mode & S_IFMT) == S_IFDIR else {
    FileHandle.standardError.write(Data("ninepfsd: \(root) is not a directory\n".utf8))
    exit(2)
}

// netfs's Export works on the path it is given, so it gets an absolute one, as
// netfsd's main makes it; the 9P side takes the realpath itself.
let absolute = (root as NSString).isAbsolutePath
    ? root : FileManager.default.currentDirectoryPath + "/" + root
let nine = NineConfig(root: absolute, readOnly: readOnly, uid: uid, gid: gid,
                      msize: msize, strict: strict, follow: follow, verbose: verbose)
let netfs = alsoNetfs
    ? NetFSConfig(root: (absolute as NSString).standardizingPath, port: port, readOnly: readOnly,
                  mapUID: UInt16(clamping: uid), mapGID: UInt16(clamping: gid), verbose: verbose)
    : nil

let server = ShareServer(port: port, netfs: netfs, nine: nine)
do {
    try server.start()
} catch {
    FileHandle.standardError.write(Data("ninepfsd: \(error)\n".utf8))
    exit(1)
}
server.serveForever()
