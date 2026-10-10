//
//  ShareServer.swift -- one port, both share protocols, chosen per connection.
//
//  WHY ONE LISTENER AND NOT ONE PER PROTOCOL.  Both editions dial the same two
//  ports for the same two shares -- V8's /etc/rc runs `nmount 10.0.2.2 9200',
//  V10's `runfs /n/macos /etc/9pfs 10.0.2.2 9200' -- and the app's two shares
//  are one folder each, whoever mounts them.  So the port is the share and the
//  protocol is the client's choice, and the first byte says which:
//
//      netfs   the handshake opens with one byte of version, netVersion = 1,
//              sent on its own (Server.swift's handshake()).
//      9P      the first message is always Tversion, and its first byte is the
//              low byte of its size: 21 for "9P2000.u", 19 for "9P2000".  A
//              Tversion whose size ended in 0x01 would need a 244-byte version
//              string.
//
//  So the app never has to know which edition is running to serve it, and
//  nothing here knows about editions either.  With only one protocol
//  configured there is no sniffing at all: every connection is that protocol,
//  and `ninepfsd' without -N is exactly a 9P server.
//
//  THE LIFECYCLE IS NetFSServer's, deliberately: stop() closes the listener and
//  leaves live connections to finish, so a mount made before a stop keeps the
//  folder and the permissions it was made with until the guest unmounts.
//
import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

public final class ShareServer: @unchecked Sendable {
    public let port: UInt16
    let netfs: NetFSConfig?
    let nine: NineConfig?
    private var nineExport: NineExport?
    private var listenFD: Int32 = -1
    private let lock = NSLock()
    private var running = false

    /// `netfs` and `nine` are the two protocols' views of the share; either may
    /// be nil, not both.  `port` is the one bound -- NetFSConfig's own port
    /// field is not consulted.
    public init(port: UInt16, netfs: NetFSConfig? = nil, nine: NineConfig? = nil) {
        precondition(netfs != nil || nine != nil, "a share speaks at least one protocol")
        self.port = port
        self.netfs = netfs
        self.nine = nine
    }

    public enum StartError: Error, CustomStringConvertible {
        case export(String)
        case socket(String)
        public var description: String {
            switch self {
            case .export(let s): return s
            case .socket(let s): return s
            }
        }
    }

    private var isRunning: Bool {
        lock.lock(); defer { lock.unlock() }
        return running
    }

    /// Bind 127.0.0.1 and listen.  Loopback only, and that is not a limit:
    /// SLiRP redirects any address inside its virtual network to the host's
    /// loopback, so the guest dialling 10.0.2.2:PORT lands here with nothing
    /// forwarded -- which is also what makes this work unchanged inside the
    /// iOS sandbox, where an app may talk to its own loopback and nothing else.
    public func start() throws {
        if let nine {
            do {
                nineExport = try NineExport(nine)
            } catch let e as NineError {
                throw StartError.export("\(nine.root): \(e.text)")
            }
        }
        let fd = socket(AF_INET, hostSockStream, 0)
        guard fd >= 0 else { throw StartError.socket("socket: \(errnoText())") }
        var yes: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes, socklen_t(MemoryLayout<Int32>.size))
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = UInt32(0x7f00_0001).bigEndian    // 127.0.0.1
        let bound = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard bound == 0 else {
            let why = errnoText()
            close(fd)
            throw StartError.socket("bind 127.0.0.1:\(port): \(why)")
        }
        guard listen(fd, 8) == 0 else {
            let why = errnoText()
            close(fd)
            throw StartError.socket("listen: \(why)")
        }
        lock.lock()
        listenFD = fd
        running = true
        lock.unlock()
        let root = nineExport?.root ?? netfs?.root ?? "?"
        let protocols = [netfs != nil ? "netfs" : nil, nine != nil ? "9P2000.u" : nil]
            .compactMap { $0 }.joined(separator: " and ")
        let ro = (nine?.readOnly ?? netfs?.readOnly ?? true) ? "read-only" : "read/write"
        log("share listening on 127.0.0.1:\(port): \(root), \(ro), \(protocols)")
    }

    /// Accept until stop().  Each connection gets its own thread: one
    /// connection is one mount, and both protocols are strictly serialised.
    public func serveForever() {
        while isRunning {
            let fd = accept(listenFD, nil, nil)
            if fd < 0 { if errno == EINTR { continue }; break }
            // Nagle would hold every small reply 40 ms for a segment that is
            // never coming, and each path lookup is a round trip.
            var yes: Int32 = 1
            setsockopt(fd, hostIPProtoTCP, TCP_NODELAY, &yes, socklen_t(MemoryLayout<Int32>.size))
            #if canImport(Darwin)
            // A REPLY TO A GUEST THAT HAS GONE MUST NOT KILL THE APP.  write(2)
            // on a socket whose peer closed raises SIGPIPE, whose default is to
            // terminate the process -- and in the app that process is the whole
            // machine.  Darwin can refuse the signal per socket; the write then
            // fails with EPIPE and the connection ends quietly.  On Linux the
            // command-line servers ignore SIGPIPE instead.
            setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &yes, socklen_t(MemoryLayout<Int32>.size))
            #endif
            let t = Thread { [self] in self.handle(fd) }
            t.stackSize = 512 * 1024
            t.start()
        }
    }

    public func stop() {
        lock.lock()
        running = false
        let fd = listenFD
        listenFD = -1
        lock.unlock()
        if fd >= 0 { close(fd) }
    }

    private func handle(_ fd: Int32) {
        var speaksNetfs = netfs != nil
        if netfs != nil, nine != nil {
            // Wait for the first byte without consuming it.
            var b: UInt8 = 0
            var r: Int
            repeat { r = recv(fd, &b, 1, Int32(MSG_PEEK)) } while r < 0 && errno == EINTR
            guard r == 1 else { close(fd); return }
            speaksNetfs = b == netVersion
        }
        if speaksNetfs, let netfs {
            log("connection accepted: netfs")
            Connection(fd: fd, cfg: netfs).run()               // closes fd
        } else if let nine, let ex = nineExport {
            NineConnection(fd: fd, export: ex, cfg: nine).run()   // closes fd
        } else {
            close(fd)
        }
    }
}
