#!/usr/bin/env python3
"""Drive the ipnx browser terminal in a headless browser and assert it works.

    python3 tools/webterm-check.py [--keep-shot]

This starts `tools/ipnx web', opens the page in Chromium, waits for the guest
to reach `login:', logs in, runs a command, and checks what is ON THE SCREEN --
not what was sent, and not what the socket carried.  That is the point: the
chain it proves is simh -> telnet console -> the WebSocket bridge -> the frame
decoder -> the VT parser -> the canvas, and every one of those can be wrong in
a way the others hide.

IT LOOKS AT THE SCREEN BUFFER, NOT PIXELS.  webterm/term.js exposes
window.ipnxScreenText() for exactly this; asserting on rendered glyphs would
make the check a font test.  A screenshot is still written, because when this
fails the picture is what says why.

Chromium is expected at PLAYWRIGHT_BROWSERS_PATH (/opt/pw-browsers here).  No
browser is ever downloaded: the environment ships one.
"""

import os
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOT = os.path.join(ROOT, "run", "webterm-check.png")
HTTP = 8080
CONSOLE = 5199          # not 5100: do not collide with a session someone is using


def chromium_path():
    """The bundled browser, or None to let playwright choose."""
    base = os.environ.get("PLAYWRIGHT_BROWSERS_PATH", "/opt/pw-browsers")
    cand = os.path.join(base, "chromium")
    if os.path.exists(cand):
        return cand
    import glob
    for pat in ("chromium-*/chrome-linux/chrome", "chromium-*/chrome-linux64/chrome"):
        hits = sorted(glob.glob(os.path.join(base, pat)))
        if hits:
            return hits[-1]
    return None


def wait_http(port, timeout=180):
    import socket
    end = time.time() + timeout
    while time.time() < end:
        s = socket.socket()
        s.settimeout(1)
        try:
            s.connect(("127.0.0.1", port))
            s.close()
            return True
        except Exception:
            time.sleep(0.5)
        finally:
            try:
                s.close()
            except Exception:
                pass
    return False


def main(argv):
    keep = "--keep-shot" in argv
    if subprocess.call(["pgrep", "-x", "vax780"], stdout=subprocess.DEVNULL) == 0:
        sys.exit("webterm-check: a vax780 is already running -- refusing to start a second")

    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        sys.exit("webterm-check: pip install playwright (the browser itself is "
                 "already at $PLAYWRIGHT_BROWSERS_PATH and is never downloaded)")

    web = subprocess.Popen(
        [sys.executable, os.path.join(ROOT, "tools", "ipnx"), "web",
         "-p", str(HTTP), "-c", str(CONSOLE), "--macos", ROOT],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    failures = []
    try:
        if not wait_http(HTTP):
            sys.exit("webterm-check: nothing listening on %d" % HTTP)

        with sync_playwright() as pw:
            # LAUNCH THE BROWSER THAT IS HERE, not the one this playwright
            # release happens to want.  The environment ships Chromium under
            # $PLAYWRIGHT_BROWSERS_PATH and pins nothing to the pip package's
            # build number, so a `pip install playwright' newer than the image
            # asks for a build that was never downloaded:
            #     Executable doesn't exist at .../chromium_headless_shell-1243/...
            # and then helpfully suggests `playwright install', which is exactly
            # what must not happen here.  The symlink is stable; use it.
            browser = pw.chromium.launch(executable_path=chromium_path())
            page = browser.new_page(viewport={"width": 1100, "height": 700})
            page.goto("http://127.0.0.1:%d/" % HTTP)

            def screen():
                return page.evaluate("window.ipnxScreenText()") or ""

            def wait_for(text, timeout, what):
                end = time.time() + timeout
                while time.time() < end:
                    if text in screen():
                        return True
                    page.wait_for_timeout(500)
                failures.append("%s: never saw %r" % (what, text))
                return False

            # The status pill says whether the bridge attached at all.
            page.wait_for_timeout(1500)
            st = page.text_content("#status")
            if st != "connected":
                failures.append("status is %r, not 'connected'" % st)

            def wait_quiet(settle=3.0, timeout=90):
                """Wait until the screen STOPS CHANGING.

                TYPING TOO EARLY IS THE BUG THIS EXISTS TO PREVENT, and the
                first version of this check had it.  It waited for `Tenth
                Edition' after sending `root' -- but that banner is printed
                BEFORE login as well, so the text was already on screen and the
                wait returned at once.  The keystrokes then went in while the
                post-login banner was still printing, the guest's tty dropped
                some of them, and the screen ended up reading

                    ecResearch Unix, Tenth Edition.
                    ho # webterm-ok
                    webterm-ok: not found

                -- `ec' and `ho ' are the echo of `echo' interleaved with the
                banner.  The check still PASSED, because `webterm-ok' did reach
                the screen: as the shell's complaint about a command it could
                not find.  Waiting for quiet is what makes the prompt real."""
                end = time.time() + timeout
                last, stable = None, time.time()
                while time.time() < end:
                    now = screen()
                    if now != last:
                        last, stable = now, time.time()
                    elif time.time() - stable >= settle:
                        return True
                    page.wait_for_timeout(300)
                return False

            # A cold boot runs fsck on three filesystems.
            if wait_for("login:", 300, "boot"):
                page.click("#screen")
                wait_quiet()
                page.keyboard.type("root")
                page.keyboard.press("Enter")
                if not wait_quiet():
                    failures.append("login: screen never settled")
                # MARKERS, NEVER PROMPTS, AND NEVER A LITERAL -- the project's
                # own rule.  The shell strips the quotes, so what is TYPED
                # contains IP'NX'WEB and what is PRINTED contains IPNXWEB, and
                # matching the printed form cannot match the echo of the typing.
                page.keyboard.type("echo IP'NX'WEB")
                page.keyboard.press("Enter")
                wait_for("IPNXWEB", 60, "command output")

            page.screenshot(path=SHOT)
            text = screen()
            browser.close()

        print("--- screen ---")
        print(text)
        print("--- end ---")
    finally:
        web.terminate()
        try:
            web.wait(timeout=20)
        except Exception:
            web.kill()
        for q in ("vax780",):
            subprocess.call(["pkill", "-x", q], stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL)
        if not keep:
            pass        # the screenshot is small and useful; it stays

    if failures:
        for f in failures:
            print("FAIL " + f)
        print("screenshot: %s" % SHOT)
        return 1
    print("webterm-check: ok -- booted, logged in and ran a command in the browser")
    print("screenshot: %s" % SHOT)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
