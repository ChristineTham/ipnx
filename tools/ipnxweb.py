#!/usr/bin/env python3
"""Serve the ipnx browser terminal and bridge it to a simh console.

    python3 tools/ipnxweb.py [-p 8080] [-c 5100] [-r webterm] [-b 127.0.0.1]

      -p  HTTP port for the browser app (default 8080)
      -c  TCP port where simh is listening with `set console telnet=<port>'
      -r  directory of static files to serve (default webterm/)
      -b  address to bind (default 127.0.0.1)

WHY THIS EXISTS.  The app that ships is Swift and runs on iPadOS and macOS; it
draws the 5620 with Metal and cannot be built anywhere else.  None of that is
needed to USE the machine: simh will put its console on a TCP port, and a
browser can reach a TCP port through a WebSocket.  So this is the whole of the
host side of a browser front end, in the standard library and nothing else --
no framework, no npm, no build step.

STDLIB ONLY, AND THAT IS A CONSTRAINT WITH A REASON.  cdn.jsdelivr.net answers
403 through this project's egress proxy, so a browser app that loads a terminal
emulator from a CDN does not work here at all; and vendoring one would put a
megabyte of somebody else's JavaScript in a repository whose rule is that
binaries never enter git.  webterm/ draws its own terminal.  The same rule
applies on this side: http.server and socket, which python3 always has.

TELNET IAC IS STRIPPED AND NEVER ANSWERED.  simh's `set console telnet' speaks
telnet, so the stream carries IAC (0xFF) negotiation that a terminal must not
show the user.  This filters it out and REPLIES TO NOTHING -- the same rule
ConsoleLink(replyToIAC: false) states for the remote console, and for the same
reason: a client that answers negotiation on a simh console can silence that
session permanently.  IAC IAC is the escape for a literal 0xFF and is the one
case that produces a byte.
"""

import base64
import hashlib
import os
import select
import socket
import struct
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

# telnet
IAC, DONT, DO, WONT, WILL, SB, SE = 255, 254, 253, 252, 251, 250, 240


class Telnet(object):
    """Strip telnet negotiation from a byte stream, answering none of it.

    A three-state machine: normal, just-saw-IAC, and inside a subnegotiation.
    Commands 251-254 (WILL/WONT/DO/DONT) take one option byte; SB runs until
    IAC SE.  Everything else after IAC is a two-byte command with no argument.
    """

    NORMAL, IAC_SEEN, OPT_SEEN, SUB, SUB_IAC = range(5)

    def __init__(self):
        self.state = self.NORMAL

    def feed(self, data):
        out = bytearray()
        for b in data:
            if self.state == self.NORMAL:
                if b == IAC:
                    self.state = self.IAC_SEEN
                else:
                    out.append(b)
            elif self.state == self.IAC_SEEN:
                if b == IAC:                    # escaped literal 0xFF
                    out.append(IAC)
                    self.state = self.NORMAL
                elif b in (WILL, WONT, DO, DONT):
                    self.state = self.OPT_SEEN  # swallow the option byte next
                elif b == SB:
                    self.state = self.SUB
                else:
                    self.state = self.NORMAL    # two-byte command, no argument
            elif self.state == self.OPT_SEEN:
                self.state = self.NORMAL
            elif self.state == self.SUB:
                if b == IAC:
                    self.state = self.SUB_IAC
            elif self.state == self.SUB_IAC:
                self.state = self.NORMAL if b == SE else self.SUB
        return bytes(out)


# ------------------------------------------------------------------ frames --
# RFC 6455.  A server frame is never masked; a client frame always is, and a
# client that sends an unmasked one must be dropped.

def ws_frame(payload, opcode=0x2):
    n = len(payload)
    head = bytearray([0x80 | opcode])
    if n < 126:
        head.append(n)
    elif n < 65536:
        head.append(126)
        head += struct.pack(">H", n)
    else:
        head.append(127)
        head += struct.pack(">Q", n)
    return bytes(head) + payload


def ws_read(sock):
    """One frame -> (opcode, payload), or (None, None) at end of stream."""
    hdr = recv_exact(sock, 2)
    if hdr is None:
        return None, None
    fin_op, mask_len = hdr[0], hdr[1]
    opcode = fin_op & 0x0F
    masked = mask_len & 0x80
    n = mask_len & 0x7F
    if n == 126:
        ext = recv_exact(sock, 2)
        if ext is None:
            return None, None
        n = struct.unpack(">H", ext)[0]
    elif n == 127:
        ext = recv_exact(sock, 8)
        if ext is None:
            return None, None
        n = struct.unpack(">Q", ext)[0]
    if n > (1 << 20):                   # a console frame is never this big
        return None, None
    key = b""
    if masked:
        key = recv_exact(sock, 4)
        if key is None:
            return None, None
    payload = recv_exact(sock, n) if n else b""
    if payload is None:
        return None, None
    if masked:
        payload = bytes(payload[i] ^ key[i % 4] for i in range(len(payload)))
    return opcode, payload


def recv_exact(sock, n):
    out = bytearray()
    while len(out) < n:
        try:
            chunk = sock.recv(n - len(out))
        except (socket.error, OSError):
            return None
        if not chunk:
            return None
        out += chunk
    return bytes(out)


# ------------------------------------------------------------------ bridge --

def bridge(ws, console_port, host="127.0.0.1"):
    """Relay one WebSocket to one simh console until either end closes."""
    try:
        tcp = socket.create_connection((host, console_port), 10)
    except Exception as exc:
        try:
            ws.sendall(ws_frame(("\r\n[ipnx: no console on %s:%d -- %s]\r\n"
                                 % (host, console_port, exc)).encode(), 0x1))
        except Exception:
            pass
        return
    tcp.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    filt = Telnet()
    alive = [True]

    def to_browser():
        """simh -> browser.  Binary frames: the console is bytes, not text,
        and a partial UTF-8 sequence split across reads would be mangled by a
        text frame's validity rules."""
        try:
            while alive[0]:
                data = tcp.recv(4096)
                if not data:
                    break
                clean = filt.feed(data)
                if clean:
                    ws.sendall(ws_frame(clean, 0x2))
        except Exception:
            pass
        finally:
            alive[0] = False
            try:
                ws.shutdown(socket.SHUT_RDWR)
            except Exception:
                pass

    t = threading.Thread(target=to_browser)
    t.daemon = True
    t.start()

    try:
        while alive[0]:
            opcode, payload = ws_read(ws)
            if opcode is None or opcode == 0x8:      # closed
                break
            if opcode == 0x9:                        # ping -> pong
                ws.sendall(ws_frame(payload, 0xA))
                continue
            if opcode in (0x1, 0x2) and payload:
                tcp.sendall(payload)
    except Exception:
        pass
    finally:
        alive[0] = False
        for s in (tcp, ws):
            try:
                s.close()
            except Exception:
                pass


# -------------------------------------------------------------------- http --

def make_handler(cfg):
    class Handler(BaseHTTPRequestHandler):
        server_version = "ipnx"
        protocol_version = "HTTP/1.1"

        def log_message(self, fmt, *args):
            if cfg["verbose"]:
                sys.stderr.write("ipnxweb: " + (fmt % args) + "\n")

        def do_GET(self):
            path = self.path.split("?", 1)[0]
            if path == "/ws":
                return self.websocket()
            if path == "/health":
                body = b"ok\n"
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
                return
            return self.static(path)

        def static(self, path):
            if path in ("", "/"):
                path = "/index.html"
            # CONTAINMENT: the served path is the root plus components, and the
            # root is compared against the REALPATH of what was asked for, so a
            # `..' or a symlink cannot climb out of webterm/.
            full = os.path.realpath(os.path.join(cfg["root"], path.lstrip("/")))
            if full != cfg["root"] and not full.startswith(cfg["root"] + os.sep):
                self.send_error(403)
                return
            if not os.path.isfile(full):
                self.send_error(404)
                return
            ext = os.path.splitext(full)[1]
            ctype = {".html": "text/html; charset=utf-8",
                     ".js": "text/javascript; charset=utf-8",
                     ".css": "text/css; charset=utf-8",
                     ".svg": "image/svg+xml",
                     ".ico": "image/x-icon"}.get(ext, "application/octet-stream")
            with open(full, "rb") as f:
                body = f.read()
            self.send_response(200)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

        def websocket(self):
            key = self.headers.get("Sec-WebSocket-Key")
            if not key or "websocket" not in (self.headers.get("Upgrade") or "").lower():
                self.send_error(400)
                return
            accept = base64.b64encode(
                hashlib.sha1((key + WS_GUID).encode()).digest()).decode()
            self.wfile.write((
                "HTTP/1.1 101 Switching Protocols\r\n"
                "Upgrade: websocket\r\n"
                "Connection: Upgrade\r\n"
                "Sec-WebSocket-Accept: %s\r\n\r\n" % accept).encode())
            self.wfile.flush()
            # HAND THE RAW SOCKET TO THE BRIDGE and make sure the HTTP server
            # does not also try to keep talking on it.
            self.close_connection = True
            bridge(self.connection, cfg["console"], cfg["chost"])

    return Handler


def serve(cfg):
    srv = ThreadingHTTPServer((cfg["bind"], cfg["port"]), make_handler(cfg))
    srv.daemon_threads = True
    sys.stderr.write("ipnxweb: http://%s:%d/  -> console %s:%d\n"
                     % (cfg["bind"], cfg["port"], cfg["chost"], cfg["console"]))
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        srv.server_close()


def main(argv):
    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    cfg = {"port": 8080, "console": 5100, "bind": "127.0.0.1",
           "chost": "127.0.0.1", "root": os.path.join(here, "webterm"),
           "verbose": False}
    args = list(argv)
    while args:
        a = args.pop(0)
        if a in ("-p", "--port"):
            cfg["port"] = int(args.pop(0))
        elif a in ("-c", "--console"):
            cfg["console"] = int(args.pop(0))
        elif a in ("-b", "--bind"):
            cfg["bind"] = args.pop(0)
        elif a in ("-r", "--root"):
            cfg["root"] = args.pop(0)
        elif a in ("-v", "--verbose"):
            cfg["verbose"] = True
        elif a in ("-h", "--help"):
            sys.stderr.write(__doc__)
            return 0
        else:
            sys.stderr.write("ipnxweb: unknown argument %s\n" % a)
            return 2
    cfg["root"] = os.path.realpath(cfg["root"])
    if not os.path.isdir(cfg["root"]):
        sys.stderr.write("ipnxweb: no such directory: %s\n" % cfg["root"])
        return 2
    serve(cfg)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
