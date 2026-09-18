/*
 * A small terminal for ipnx, drawn on a canvas, with no dependencies.
 *
 * WHY NOT xterm.js.  Two reasons, and the second is the one that decides it:
 * cdn.jsdelivr.net answers 403 through this project's egress proxy, so a page
 * that loads a terminal from a CDN does not work here at all; and vendoring one
 * would put a megabyte of somebody else's JavaScript into a repository whose
 * first rule is that binaries never enter git.  A Research Unix console asks
 * for very little -- this is a glass tty, not a full VT220 -- so it is cheaper
 * to draw one than to carry one.
 *
 * MARK PARITY IS STRIPPED, AND IT IS NOT OPTIONAL.  getty's first banner
 * arrives with bit 7 SET on every character: `login:' is 0xEC 0xEF 0xE7...
 * Rendered as-is that is line noise, and it is the first thing anyone sees.
 * Every one of this project's own console drivers masks to 7 bits for exactly
 * this reason (tools/v10drive.py's docstring records it as costing a run), and
 * so does this.
 */
(function () {
  'use strict';

  var COLS = 80, ROWS = 24;
  var FONT_PX = 15;

  var canvas = document.getElementById('screen');
  var ctx = canvas.getContext('2d');
  var statusEl = document.getElementById('status');
  var hintEl = document.getElementById('hint');

  /* ------------------------------------------------------------- screen -- */
  var buf, cx = 0, cy = 0, inverse = false, cellW = 9, cellH = 18;

  function blankRow() {
    var r = new Array(COLS);
    for (var i = 0; i < COLS; i++) r[i] = { ch: ' ', inv: false };
    return r;
  }
  function reset() {
    buf = [];
    for (var y = 0; y < ROWS; y++) buf.push(blankRow());
    cx = cy = 0;
  }
  reset();

  function measure() {
    ctx.font = FONT_PX + 'px ui-monospace, SFMono-Regular, Menlo, "DejaVu Sans Mono", monospace';
    var m = ctx.measureText('M');
    cellW = Math.ceil(m.width);
    cellH = Math.ceil(FONT_PX * 1.35);
    var dpr = window.devicePixelRatio || 1;
    canvas.width = COLS * cellW * dpr;
    canvas.height = ROWS * cellH * dpr;
    canvas.style.width = (COLS * cellW) + 'px';
    canvas.style.height = (ROWS * cellH) + 'px';
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.textBaseline = 'top';
    ctx.font = FONT_PX + 'px ui-monospace, SFMono-Regular, Menlo, "DejaVu Sans Mono", monospace';
  }

  var cursorOn = true;
  function draw() {
    ctx.fillStyle = '#0d0b09';
    ctx.fillRect(0, 0, COLS * cellW, ROWS * cellH);
    ctx.font = FONT_PX + 'px ui-monospace, SFMono-Regular, Menlo, "DejaVu Sans Mono", monospace';
    ctx.textBaseline = 'top';
    for (var y = 0; y < ROWS; y++) {
      for (var x = 0; x < COLS; x++) {
        var c = buf[y][x];
        var isCursor = (x === cx && y === cy && cursorOn && focused);
        if (c.inv || isCursor) {
          ctx.fillStyle = '#e8dcc8';
          ctx.fillRect(x * cellW, y * cellH, cellW, cellH);
          ctx.fillStyle = '#0d0b09';
        } else {
          ctx.fillStyle = '#e8dcc8';
        }
        if (c.ch !== ' ') ctx.fillText(c.ch, x * cellW, y * cellH + 2);
      }
    }
  }

  function scroll() {
    buf.shift();
    buf.push(blankRow());
  }
  function put(ch) {
    if (cx >= COLS) { cx = 0; cy++; }
    if (cy >= ROWS) { scroll(); cy = ROWS - 1; }
    buf[cy][cx] = { ch: ch, inv: inverse };
    cx++;
  }
  function newline() {
    cy++;
    if (cy >= ROWS) { scroll(); cy = ROWS - 1; }
  }
  function eraseLine(mode) {
    var from = 0, to = COLS;
    if (mode === 0) from = cx; else if (mode === 1) to = cx + 1;
    for (var x = from; x < to; x++) buf[cy][x] = { ch: ' ', inv: false };
  }
  function eraseScreen(mode) {
    if (mode === 2) { reset(); return; }
    var y;
    if (mode === 0) {
      eraseLine(0);
      for (y = cy + 1; y < ROWS; y++) buf[y] = blankRow();
    } else {
      eraseLine(1);
      for (y = 0; y < cy; y++) buf[y] = blankRow();
    }
  }

  /* ------------------------------------------------------------- parser -- */
  var GROUND = 0, ESC = 1, CSI = 2;
  var state = GROUND, params = '';

  function csi(final) {
    var p = params.split(';').map(function (s) { return s === '' ? 0 : parseInt(s, 10); });
    var n = p[0] || 0;
    switch (final) {
      case 'H': case 'f':
        cy = Math.min(ROWS - 1, Math.max(0, (p[0] || 1) - 1));
        cx = Math.min(COLS - 1, Math.max(0, (p[1] || 1) - 1));
        break;
      case 'A': cy = Math.max(0, cy - (n || 1)); break;
      case 'B': cy = Math.min(ROWS - 1, cy + (n || 1)); break;
      case 'C': cx = Math.min(COLS - 1, cx + (n || 1)); break;
      case 'D': cx = Math.max(0, cx - (n || 1)); break;
      case 'J': eraseScreen(n); break;
      case 'K': eraseLine(n); break;
      case 'm':
        for (var i = 0; i < p.length; i++) {
          if (p[i] === 0) inverse = false;
          else if (p[i] === 7) inverse = true;
          else if (p[i] === 27) inverse = false;
        }
        break;
      default: break;   /* anything else is ignored rather than shown */
    }
  }

  function feed(bytes) {
    for (var i = 0; i < bytes.length; i++) {
      /* MARK PARITY: see the header comment.  Do this before anything else,
         so the parser never sees 0xEC where it expects 'l'. */
      var b = bytes[i] & 0x7F;
      if (state === ESC) {
        if (b === 0x5B) { state = CSI; params = ''; }
        else state = GROUND;
        continue;
      }
      if (state === CSI) {
        if (b >= 0x30 && b <= 0x3F) { params += String.fromCharCode(b); continue; }
        if (b >= 0x20 && b <= 0x2F) { continue; }   /* intermediates */
        csi(String.fromCharCode(b));
        state = GROUND;
        continue;
      }
      switch (b) {
        case 0x1B: state = ESC; break;
        case 0x07: flash(); break;
        case 0x08: cx = Math.max(0, cx - 1); break;
        case 0x09: cx = Math.min(COLS - 1, (cx + 8) & ~7); break;
        case 0x0A: case 0x0B: case 0x0C: newline(); break;
        case 0x0D: cx = 0; break;
        case 0x00: break;
        default:
          if (b >= 0x20 && b < 0x7F) put(String.fromCharCode(b));
          break;
      }
    }
    draw();
  }

  var flashTimer = null;
  function flash() {
    canvas.style.filter = 'invert(1)';
    clearTimeout(flashTimer);
    flashTimer = setTimeout(function () { canvas.style.filter = ''; }, 60);
  }

  /* ---------------------------------------------------------- websocket -- */
  var ws = null, retry = 0;

  function status(text, cls) {
    statusEl.textContent = text;
    statusEl.className = cls || '';
  }

  function connect() {
    var proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
    ws = new WebSocket(proto + '//' + location.host + '/ws');
    ws.binaryType = 'arraybuffer';
    status('connecting…');
    ws.onopen = function () { retry = 0; status('connected', 'up'); };
    ws.onmessage = function (ev) {
      feed(typeof ev.data === 'string'
        ? new TextEncoder().encode(ev.data)
        : new Uint8Array(ev.data));
    };
    ws.onclose = function () {
      status('disconnected', 'down');
      /* Back off, but keep trying: the machine may simply be booting. */
      retry = Math.min(retry + 1, 10);
      setTimeout(connect, 300 * retry);
    };
    ws.onerror = function () { try { ws.close(); } catch (e) {} };
  }

  function send(bytes) {
    if (ws && ws.readyState === 1) ws.send(new Uint8Array(bytes));
  }

  /* ---------------------------------------------------------- keyboard -- */
  var focused = false;
  canvas.addEventListener('focus', function () { focused = true; draw(); });
  canvas.addEventListener('blur', function () { focused = false; draw(); });
  canvas.addEventListener('mousedown', function () { canvas.focus(); });

  canvas.addEventListener('keydown', function (e) {
    if (e.metaKey) return;                  /* leave browser shortcuts alone */
    var k = e.key;
    var out = null;

    if (e.ctrlKey && k.length === 1) {
      var u = k.toUpperCase().charCodeAt(0);
      if (u >= 64 && u < 96) out = [u - 64];          /* Ctrl-A .. Ctrl-_ */
      else if (u >= 97 && u < 123) out = [u - 96];
    } else if (k.length === 1) {
      out = [k.charCodeAt(0) & 0x7F];
    } else {
      switch (k) {
        /* CR, NOT LF.  The tty is in canonical mode and the line is
           terminated by carriage return; sending LF gives a blank line and no
           command. */
        case 'Enter':     out = [0x0D]; break;
        case 'Backspace': out = [0x7F]; break;   /* DEL is the usual erase */
        case 'Tab':       out = [0x09]; break;
        case 'Escape':    out = [0x1B]; break;
        case 'ArrowUp':   out = [0x1B, 0x5B, 0x41]; break;
        case 'ArrowDown': out = [0x1B, 0x5B, 0x42]; break;
        case 'ArrowRight':out = [0x1B, 0x5B, 0x43]; break;
        case 'ArrowLeft': out = [0x1B, 0x5B, 0x44]; break;
        default: return;
      }
    }
    if (out) { e.preventDefault(); send(out); }
  });

  /* Paste, because typing a path twice is how a typo gets in. */
  canvas.addEventListener('paste', function (e) {
    var text = (e.clipboardData || window.clipboardData).getData('text');
    if (!text) return;
    e.preventDefault();
    var bytes = [];
    for (var i = 0; i < text.length; i++) {
      var c = text.charCodeAt(i);
      bytes.push(c === 0x0A ? 0x0D : (c & 0x7F));
    }
    send(bytes);
  });

  /* ------------------------------------------------------------- start -- */
  measure();
  draw();
  setInterval(function () { cursorOn = !cursorOn; draw(); }, 500);
  window.addEventListener('resize', function () { measure(); draw(); });
  hintEl.textContent = COLS + '×' + ROWS;
  connect();
  setTimeout(function () { canvas.focus(); }, 50);

  /* Exposed for the headless check in tools/webterm-check.py: the screen as
     text, which is what an assertion actually wants to look at. */
  window.ipnxScreenText = function () {
    return buf.map(function (row) {
      return row.map(function (c) { return c.ch; }).join('').replace(/\s+$/, '');
    }).join('\n');
  };
})();
