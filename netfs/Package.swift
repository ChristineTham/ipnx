// swift-tools-version: 6.2
//
// The host half of Research Unix's netfs, phase N5.
//
// Two targets on purpose. `NetFS` is the whole server and has no dependency on
// anything a phone does not have -- Foundation and POSIX sockets, no
// Network.framework, no Dispatch queues that assume a main runloop. `netfsd` is
// a thin main() around it so the desktop can drive the thing against SIMH.
//
// That split is the entire point: N7 puts a netfs server inside the iPad app so
// the emulated VAX can mount a folder chosen in Files, and when it does, it
// compiles these same source files. Nothing here may grow a Mac-only
// dependency without breaking that.
//
// AND V10's 9P SERVER LIVES IN THE SAME TARGET, for the same reason.  The app
// compiles Sources/NetFS as a synchronised folder, so a file added there is in
// both app targets with no project edit; `ninepfsd' is its main(), as netfsd
// is netfs's.  ShareServer is what the app listens with: one port per share,
// netfs or 9P chosen by the connection's first byte.  `swift build' works on
// Linux, which is how the selftests and a booted V10 check it without a Mac.
import PackageDescription

let package = Package(
    name: "netfs",
    platforms: [.macOS(.v26)],
    targets: [
        .target(name: "NetFS"),
        .executableTarget(name: "netfsd", dependencies: ["NetFS"]),
        .executableTarget(name: "ninepfsd", dependencies: ["NetFS"]),
    ]
)
