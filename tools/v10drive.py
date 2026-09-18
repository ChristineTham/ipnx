#!/usr/bin/env python3
"""Run a script of shell commands on a booted V10 guest, over the console.

    tools/v10drive.py run/v10-test.img tools/mycommands
    cp --sparse=always run/v10-golden run/v10-test.img     # ALWAYS a fresh copy

THE EXPECT-FREE HALF OF tools/v10-tryboot.exp, and it exists because expect is
not on every machine this is run from -- a Linux container with python3 and a
C compiler is enough to build open-simh and boot the committed golden, which is
how the V10 build was first tested against a machine rather than by reading.

Each line of the commands file is one shell command; blank lines and lines
beginning with # are skipped.  Output is printed per command.  The image is
booted, `root' is logged in, the script runs, and the machine is HALTED.

FOUR FACTS ABOUT THIS CONSOLE, each of which cost a run:

1. MARKERS, NEVER PROMPTS, AND NEVER A LITERAL.  The tty echoes what is typed
   into whatever is already printing, so a marker that appears in the command
   line appears twice and the first one is the echo.  Each command is sent as
   `<command>; echo IP'NX'DONE<n>' -- the shell strips the quotes, so what is
   TYPED contains IP'NX'DONE and what is PRINTED contains IPNXDONE, and
   matching the printed form cannot match the echo.

2. login: ARRIVES WITH MARK PARITY -- bit 7 set on getty's first banner -- so
   every pattern is matched against the text with the high bit stripped.

3. 256 BYTES IS THE LIMIT ON A LINE.  See cmd() below.

4. THE MACHINE IS HALTED, NOT DROPPED.  See close() below.
"""

import os, pty, re, select, subprocess, sys, time

# DERIVED, NEVER WRITTEN DOWN -- the same reason v10-launch.sh gives: a path
# spelled out here works on exactly one machine and silently points at nothing
# anywhere else, including in a checkout sitting beside it.
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SIM = os.path.join(ROOT, "work", "opensimh", "BIN", "vax780")


class Guest:
    def __init__(self, conf, logpath):
        self.mfd, sfd = pty.openpty()
        self.p = subprocess.Popen([SIM, conf], stdin=sfd, stdout=sfd,
                                  stderr=subprocess.STDOUT, close_fds=True)
        os.close(sfd)
        self.buf = ""
        self.log = open(logpath, "w")

    def read(self, timeout):
        end = time.time() + timeout
        while time.time() < end:
            r, _, _ = select.select([self.mfd], [], [], 0.4)
            if not r:
                continue
            try:
                d = os.read(self.mfd, 65536)
            except OSError:
                return False
            if not d:
                return False
            t = "".join(chr(b & 0x7F) for b in d)     # strip mark parity
            self.buf += t
            self.log.write(t)
            self.log.flush()
            return True
        return True

    def wait_for(self, pattern, timeout=600):
        rx = re.compile(pattern)
        end = time.time() + timeout
        while time.time() < end:
            m = rx.search(self.buf)
            if m:
                self.buf = self.buf[m.end():]
                return True
            if not self.read(min(5, end - time.time())):
                break
        return False

    def send(self, s):
        os.write(self.mfd, s.encode("ascii", "replace"))

    def cmd(self, line, n, timeout=300):
        """Run one shell command; return its output up to the printed marker.

        THE CONSOLE DROPS ANYTHING PAST 256 BYTES ON A LINE and says nothing:
        io/nttyld.c:28 is `#define CANBSIZ 256' and :348 is
        `static char canonb[CANBSIZ]'.  A 330-byte chmod wedged this driver --
        the line was truncated, the shell never saw a complete command, and the
        marker never printed, which reads exactly like a slow machine.
        """
        full = "%s; echo IP'NX'DONE%d" % (line, n)
        if len(full) > 240:
            return "DRIVER: %d bytes, over the tty's CANBSIZ of 256" % len(full)
        self.send(full + "\r")
        rx = re.compile(r"IPNXDONE%d" % n)
        end = time.time() + timeout
        while time.time() < end:
            m = rx.search(self.buf)
            if m:
                out = self.buf[:m.start()]
                self.buf = self.buf[m.end():]
                return out
            if not self.read(min(5, end - time.time())):
                break
        return None

    def close(self):
        """Halt the machine through /etc/down, never by pulling the plug.

        ^E-and-quit leaves every filesystem marked mounted, and the NEXT boot
        runs fsck, finds the files the killed run had open, and stops at
        `UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY' -- which is single user,
        with no login:, so a driver waiting for one hangs until its timeout.
        Measured: it cost a whole run.  /etc/down is the project's own halt --
        kill everything holding a mount, sync, umount -a, /etc/halt -- and the
        HALT drops simh back to its own prompt with the disk clean.
        """
        try:
            # `cd /' FIRST, AND IT IS NOT down's JOB.  down cds itself, but THIS
            # shell's cwd is wherever the last command left it -- /usr/src/cmd/uucp
            # on the run that found this -- and iget.c's ifsbusy counts a cwd as a
            # held inode, so umount -a answers `/usr: In use' and down correctly
            # refuses to halt.  The disk is then dirty for the next boot.
            self.send("cd /\r")
            self.read(3)
            self.send("/etc/down\r")
            self.wait_for(r"HALT instruction|sim>", 240)
        except Exception:
            pass
        # AND ^E ONLY IF THE HALT DID NOT ALREADY GET US THERE.  Sending it at a
        # prompt that is already `sim>' puts a stray character in front of the
        # next word, so `quit' arrives as `^Equit', simh rejects it, and the
        # process sits at its prompt forever -- which is how two simulators came
        # to be running at once against the same image, the one thing
        # tools/norun.sh exists to prevent.
        try:
            if not self.wait_for(r"sim>", 60):
                self.send("\005")
                self.wait_for(r"sim>", 30)
            self.send("quit\r")
            self.read(5)
        except Exception:
            pass
        try:
            self.p.wait(timeout=30)
        except Exception:
            self.p.kill()
            try:
                self.p.wait(timeout=10)
            except Exception:
                pass
        self.log.close()


def main():
    img, script = sys.argv[1], sys.argv[2]
    # TWO SIMULATORS MUST NEVER RUN AT ONCE -- tools/norun.sh says so for V8 and
    # the reason is the same here: two runs once overlapped and both exited 0,
    # one of them measuring a disk being rewritten underneath it.  It happened
    # again on 17 Sep 2026, when the close() bug above left one at its prompt
    # and the next run attached the same image.
    # `pgrep -x vax780', NOT `pgrep -f BIN/vax780'.  -f matches the whole command
    # LINE of every process, so any harness that merely mentions the path --
    # a monitor waiting for the simulator to exit, say -- counts as a simulator
    # and this refuses to start.  That happened.  -x matches the process NAME,
    # which only the simulator itself has.
    if subprocess.call(["pgrep", "-x", "vax780"],
                       stdout=subprocess.DEVNULL) == 0:
        sys.exit("v10drive: a vax780 is already running -- refusing to start a second")
    # BOOTING MOUNTS, AND MOUNTING REWRITES THE SUPERBLOCK, so a run against the
    # golden changes it even when everything passes.
    if os.path.realpath(img) == os.path.join(ROOT, "run", "v10-golden"):
        sys.exit("v10drive: that is the golden itself -- boot a copy of it")
    # AN OPTIONAL TAPE -- WHICH DOES NOT WORK ON THIS KERNEL YET, AND THE
    # ARGUMENT IS KEPT SO THE NEXT PERSON DOES NOT SPEND THE AFTERNOON FINDING
    # OUT AGAIN.  The device set is right: the kernel declares a Massbus
    # TM03/TE16 (ipnx-v10.m:137-138), simh's `show devices' puts TU on Massbus
    # adapter 1 where those lines ask for it, and Massbus addresses are fixed,
    # so adding `tu' floats no Unibus device and the machine stays the one
    # ipnx-v10.m was measured against.  What fails is the first open:
    #     >>MBA1: invalid adapter read mask, pa = 0x20012404, lnt = 2
    #     panic: mchk
    # -- a WORD read of te16.c's htds, which simh's MBA answers only longword.
    # See the note in ipnx-v10.m.  Until that is fixed, netfsd is the way in.
    tape = ""
    if len(sys.argv) > 3:
        tape = "set tu enable\nattach tu0 %s\n" % os.path.abspath(sys.argv[3])
    conf = os.path.join(ROOT, "run", "v10drive.conf")
    # The device set and its order are v10-golden.sh's, which is ipnx-v10.m's:
    # simh floats Unibus addresses over the SET of enabled devices, so a
    # different set is a different machine.
    open(conf, "w").write("""set noasynch
set cpu 128m
set vh disable
set rq enable
set rqb enable
set rqc enable
set rqd enable
set tq enable
set dz enable
set dz lines=32
set il enable
set il address=2013E800
set il vector=E8
attach il nat:
set tto 7b
set rq0 ra73
attach rq0 %s
%sload -o %s FA00
dep sp 200
dep r1 0
dep r3 0
dep r5 0
run FA02
""" % (img, tape, os.path.join(ROOT, "run", "uda")))

    g = Guest(conf, script + ".log")
    ok = g.wait_for(r"ogin", 900)
    if not ok:
        print("NO LOGIN PROMPT -- see %s.log" % script)
        g.close(); sys.exit(2)
    print("=== reached login: ===")
    g.send("root\r")
    time.sleep(3)
    g.read(10)
    # prove the shell answers before running anything real
    if g.cmd("echo hi", 0, 120) is None:
        print("SHELL DID NOT ANSWER"); g.close(); sys.exit(3)
    print("=== shell answers ===\n")

    n = 1
    for line in open(script):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        out = g.cmd(line, n, 600)
        n += 1
        print("$ %s" % line)
        if out is None:
            print("   <TIMED OUT>"); break
        for l in out.split("\n"):
            l = l.strip("\r")
            if l and "IPNXDONE" not in l and l != line and not l.endswith("; echo IP'NX'DONE%d" % (n - 1)):
                print("   %s" % l)
        print()
    g.close()


if __name__ == "__main__":
    main()
