#!/usr/bin/env python3
"""Put the seed for V10's C++ bootstrap where the guest can read it.

    tools/v10-cfseed.py [V8IMAGE [OUTDIR]]

V8IMAGE defaults to work/myv8/ipnx-v8-rp07.img, which is what `git lfs pull'
then `tar -xSjf image/ipnx-v8-rp07.img.tar.bz2 -C work/myv8' leaves, or else
work/myv8/rp07new, the name the V8 build itself writes; OUTDIR defaults to
work/cfseed, which the guest reads over the share: `cfboot
/n/macos/work/cfseed' where /n/macos is this repository (tools/ipnx web,
tools/v10-launch.sh), and cfboot's default where /n/home is the Mac's home.

WHY A SEED AT ALL.  cfront is written in C++, and no V10 tape carries a
cfront binary, so none of the tape's seven cfront trees can be built from the
tapes alone.  V8's golden carries Bell's VAX cfront (<<cfront 7/04/85>>), its
munch and its libC.a -- three of the files V8 shipped without source
(v8/mk/gen/carry.txt:67,81,1117) -- and that translator, with three of its
bugs worked around by build/src/cf85fix.c, translates cfront 2.00, which
translates cfront 2.1.  build/cfboot runs the stages; docs/v10-build.md says
what each one proved.

WHAT GOES IN OUTDIR.
  bin/cfront bin/munch lib/libC.a   V8's, read off the V8 disk's /usr.
  include/   V8's /usr/include/CC, from this repository's v8/ tree, plus:
    stdio.h    BUFSIZ 4096 and _NFILE 120, V10 libc's.  Stage 1 links V10's
               libc, and cfront 2.00's error.c setbuf()s stderr with a
               char[BUFSIZ] buffer, which V10's stdio fills to 4096.
    stdlib.h malloc.h new.h ctype.h   headers cfront 2.00 includes and V8 never
               had, in the 1985 dialect: V10's CC versions wrap themselves in
               extern "C", which the 1985 translator cannot parse.
  ORIGIN     what each file is and where it came from.  cfboot refuses a seed
             whose first line is not the one it was written for.
"""
import hashlib, os, shutil, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import v8fs

FORMAT = "cfseed 1"

# The bytes the bootstrap was proven with, 8 Oct 2026.  A different image may
# well work; it is said, not refused, because nothing about the V8 build
# should change a file it lifts from the committed image (CLAUDE.md, stage 8).
KNOWN = {
    "bin/cfront": ("/usr/bin/cfront", "de2bb817cc5e71972fc2448ccf6af517f6a12ba60487a407cb305e99bf3e038f"),
    "bin/munch": ("/usr/bin/munch", "1e37bb13d6542ba78a5acde9eb5408204d8abcdb06884a79c8b0c7fa2b00d8d7"),
    "lib/libC.a": ("/usr/lib/libC.a", "4074aedd222f26dd7e60c0b0a762bbbfe137760c3c9f2d2e872257c03f31a056"),
}

SHIMS = {
    "stdlib.h": """\
/* ipnx bootstrap shim.  V10's CC/stdlib.h is `#include <libc.h>' in the 2.x
   dialect; this is the same for the 1985 translator, which has no extern "C".
   exit and atoi are declared as V8's stdio.h declares them. */
#ifndef __STDLIB_H
#define __STDLIB_H 1
#include <libc.h>
extern char* malloc(unsigned);
extern void free(char*);
extern char* realloc(char*, unsigned);
extern char* calloc(unsigned, unsigned);
extern void exit(int);
extern int atoi(char*);
#endif
""",
    "malloc.h": """\
/* ipnx bootstrap shim: V10's CC/malloc.h without extern "C". */
#ifndef __MALLOC__H
#define __MALLOC__H 1
extern char* malloc(unsigned);
extern void free(char*);
extern char* realloc(char*, unsigned);
extern char* calloc(unsigned, unsigned);
#endif
""",
    "new.h": """\
/* ipnx bootstrap shim: V10's CC/new.h without the 2.0 placement new. */
#ifndef _NEW_H
#define _NEW_H 1
extern void (*set_new_handler(void(*)()))();
#endif
""",
}


def main():
    if len(sys.argv) > 1:
        img = sys.argv[1]
    else:
        img = os.path.join(ROOT, "work/myv8/ipnx-v8-rp07.img")
        if not os.path.isfile(img) and os.path.isfile(os.path.join(ROOT, "work/myv8/rp07new")):
            img = os.path.join(ROOT, "work/myv8/rp07new")
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, "work/cfseed")
    if not os.path.isfile(img):
        sys.exit("v10-cfseed: no %s\n"
                 "v10-cfseed: git lfs pull; mkdir -p work/myv8; "
                 "tar -xSjf image/ipnx-v8-rp07.img.tar.bz2 -C work/myv8" % img)
    if os.path.getsize(img) < 1024 * 1024:
        sys.exit("v10-cfseed: %s is %d bytes -- an LFS pointer?  git lfs pull"
                 % (img, os.path.getsize(img)))
    fs = v8fs.V8FS(img, v8fs.usrpart(img))
    if os.path.isdir(out):
        shutil.rmtree(out)
    origin = [FORMAT,
              "# written by tools/v10-cfseed.py; read by v10/usr/src/build/cfboot",
              "image %s:%s" % (os.path.relpath(img, ROOT), fs.part)]
    for rel, (path, want) in sorted(KNOWN.items()):
        ip = fs.lookup(path[len("/usr"):])
        if ip is None:
            sys.exit("v10-cfseed: %s has no %s" % (img, path))
        data = fs.read(ip)
        got = hashlib.sha256(data).hexdigest()
        dest = os.path.join(out, rel)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(data)
        os.chmod(dest, 0o755 if rel.startswith("bin/") else 0o644)
        note = "" if got == want else "  NOT THE BYTES THE BOOTSTRAP WAS PROVEN WITH"
        if note:
            print("v10-cfseed: %s: sha256 %s, expected %s" % (path, got, want))
        origin.append("%-10s V8 %-16s %7d bytes sha256 %s%s" % (rel, path, len(data), got, note))
    src = os.path.join(ROOT, "v8/usr/include/CC")
    inc = os.path.join(out, "include")
    shutil.copytree(src, inc)
    with open(os.path.join(inc, "stdio.h")) as f:
        stdio = f.read()
    for old, new in (("#define\tBUFSIZ 1024\n", "#define\tBUFSIZ 4096\t/* ipnx: V10 libc's, not V8's 1024 */\n"),
                     ("#define\t_NFILE 20\n", "#define\t_NFILE 120\t/* ipnx: V10 libc's */\n")):
        if old not in stdio:
            sys.exit("v10-cfseed: v8/usr/include/CC/stdio.h has no %r" % old)
        stdio = stdio.replace(old, new)
    with open(os.path.join(inc, "stdio.h"), "w") as f:
        f.write(stdio)
    for name, text in SHIMS.items():
        with open(os.path.join(inc, name), "w") as f:
            f.write(text)
    # ctype.h is V10's own, less the two lines of extern "C" around it.
    with open(os.path.join(ROOT, "v10/usr/include/CC/ctype.h")) as f:
        lines = f.readlines()
    kept = [l for l in lines if l.strip() not in ('extern "C" {', "}")]
    if len(lines) - len(kept) != 2:
        sys.exit("v10-cfseed: v10/usr/include/CC/ctype.h: expected one extern \"C\" block")
    with open(os.path.join(inc, "ctype.h"), "w") as f:
        f.write('/* ipnx bootstrap shim: V10\'s CC/ctype.h without extern "C". */\n')
        f.writelines(kept)
    origin.append("include    v8/usr/include/CC; stdio.h BUFSIZ and _NFILE edited; "
                  "shims stdlib.h malloc.h new.h ctype.h")
    with open(os.path.join(out, "ORIGIN"), "w") as f:
        f.write("\n".join(origin) + "\n")
    print("v10-cfseed: %s ready" % os.path.relpath(out, ROOT))
    for l in origin[2:]:
        print("  " + l)


if __name__ == "__main__":
    main()
