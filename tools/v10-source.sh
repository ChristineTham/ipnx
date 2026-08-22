#!/usr/bin/env bash
#
# Extract the Tenth Edition tape into the repository, with tar.
#
#	bash tools/v10-source.sh
#
# SIX ARCHIVES, SIX ROOTS, ONE COMMAND EACH.  No parser of ours reads a tar
# header; tar does, which is the point.
#
# THERE ARE TWO V10 DISTRIBUTIONS AT TUHS AND THIS PROJECT HAD ONLY ONE.
# Dan_Cross_v10 is v10src + v10blit; Norman_v10 is r70include AND THREE MORE
# ARCHIVES -- secombe, milligan, sellers -- 21,000 entries that had never been
# imported.  Every negative this project recorded about "the tape" was
# measured against Dan Cross's tree alone, and the one that cost most is now
# retracted outright:
#
#	CLAUDE.md   "THE 5620's COMPILER IS NOT IN THE V10 TARBALL"
#	milligan    jerq/sgs/3cc.c, 3nm.c, 32reloc.c, as/, ar/  -- 289 files
#	            jerq/src -- 1,498 files of 5620 userland, mux and jim
#
# So rung 8's "the terminal half cannot be built" was a fact about one
# archive.  Norman's README says milligan was "originally rooted at /usr,
# i.e. directory jerq in the archive was /usr/jerq" -- it IS the 5620
# distribution whose absence K10.2 worked around by creating /usr/jerq.
#
# EACH ARCHIVE KEEPS ITS OWN ROOT.  secombe and v10src are both /usr/src,
# from different machines at different times; merging them would silently
# pick one file per path and call the result "the tape".  Provenance stays in
# the path, and a comparison between the two snapshots stays possible.
#
# THE ONE THING TAR CANNOT DO HERE is hold two names that differ only in
# case, because macOS is case-insensitive -- it writes the second over the
# first and exits 0.  196 files vanish that way, and two of them matter:
# sys/io/Nttyld.c beside sys/io/nttyld.c, in the kernel, and
# libc/stdio/ostdio/doprnt.S beside doprnt.s.  So the losers are extracted by
# tar as well, one member at a time, under a name with the capitals
# percent-escaped, and CASEMAP records the true name.  Same rule as
# tools/v10-import.py: fewest capitals wins, ties lexicographically -- a rule
# rather than a judgement, so a re-extract lands on the same answer.
#
# ar ARCHIVES ARE UNPACKED with ar(1), into a directory named after the
# archive.  That is the tape's own idiom -- libplot's makefile reads
# `mkdir xplot; cd xplot; ar x ../tek.c.a' -- and it is what makes collisions
# impossible: flat, 408 members collide and 82 carry different bytes.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/v10/source"
W="$ROOT/work"

for t in v10src.tar.bz2 v10blit.tar.bz2 r70include.tar \
         v10-secombe.gz v10-milligan.gz v10-sellers.gz; do
    [[ -f "$W/$t" ]] || { echo "v10-source: no work/$t"; exit 1; }
done

rm -rf "$DEST"
mkdir -p "$DEST"/{src,blit,include,secombe,milligan,sellers}

# TAR IS ALLOWED TO FAIL HERE, AND THAT IS DELIBERATE.  Two of the archives
# carry a path that cannot exist on a case-insensitive filesystem beside its
# sibling, and tar says so and stops:
#
#   secombe   games/sail/makefile   beside games/sail/Makefile
#   sellers   vol2/index/junk       a FILE, beside vol2/index/Junk/ a DIRECTORY
#
# The case pass below resolves both -- `junk' wins and `Junk' becomes
# %4Aunk -- so the right response is to let the bulk extract do what it can
# and let the VERIFY be the judge.  Aborting here (set -e) skips the pass
# that fixes it, which is how a run ended with 25,491 of 30,205 files and no
# indication that anything was wrong beyond one tar message.
echo "== tar =="
ok=1
tar -xf "$W/v10src.tar.bz2"                -C "$DEST/src"      || ok=0
tar -xf "$W/v10blit.tar.bz2"    --strip 1  -C "$DEST/blit"     || ok=0
tar -xf "$W/r70include.tar"     --strip 1  -C "$DEST/include"  || ok=0
tar -xzf "$W/v10-secombe.gz"    --strip 1  -C "$DEST/secombe"  || ok=0
tar -xzf "$W/v10-milligan.gz"   --strip 1  -C "$DEST/milligan" || ok=0
tar -xzf "$W/v10-sellers.gz"    --strip 1  -C "$DEST/sellers"  || ok=0
[[ $ok = 1 ]] || echo "   (tar reported conflicts -- the case pass resolves them)"

# ------------------------------------------------- the case losers, by tar ---
# Ask tar what is in each tarball, group siblings by lowercased name, and
# re-extract every loser to an escaped spelling.
echo "== case collisions =="
: > "$DEST/CASEMAP"
python3 - "$DEST" "$W" <<'PY'
import os, subprocess, sys
dest, w = sys.argv[1], sys.argv[2]
TARS = [("v10src.tar.bz2", "src", 0),
        ("v10blit.tar.bz2", "blit", 1),
        ("r70include.tar", "include", 1),
        ("v10-secombe.gz", "secombe", 1),
        ("v10-milligan.gz", "milligan", 1),
        ("v10-sellers.gz", "sellers", 1)]

def unesc(n):
    """tar -tv escapes non-printable bytes C-style; undo it.

    secombe/sys/io holds a file whose name contains a literal BACKSPACE --
    tar prints it as caa\\bmac.oldc -- and comparing that string against the
    directory listing reports a file that is present as missing.
    """
    out, i = [], 0
    while i < len(n):
        if n[i] == "\\" and i + 1 < len(n):
            c = n[i + 1]
            m = {"b": "\b", "t": "\t", "n": "\n", "r": "\r",
                 "f": "\f", "v": "\v", "\\": "\\"}
            if c in m:
                out.append(m[c]); i += 2; continue
            if c.isdigit() and n[i + 1:i + 4].isdigit():
                out.append(chr(int(n[i + 1:i + 4], 8))); i += 4; continue
        out.append(n[i]); i += 1
    return "".join(out)


def relpath(n, strip):
    """A tarball member name, with `strip' leading components removed.

    NOT n.lstrip("./") -- that strips a CHARACTER SET, so ./.profile becomes
    `profile' and every dotfile in the tape is looked for under the wrong
    name.  Only a leading "./" is a prefix to remove.
    """
    parts = unesc(n).split("/")[strip:]
    while parts and parts[0] in ("", "."):
        parts = parts[1:]
    return "/".join(parts)


def esc(n):
    return "".join("%%%02X" % ord(c) if c.isupper() else c for c in n)

# RESOLVE CASE AT EVERY PATH COMPONENT, NOT JUST THE BASENAME.  Two of the
# tape's collisions are between DIRECTORIES -- vol2/Preface beside
# vol2/preface, index/Junk beside index/junk -- and a basename-only rule
# leaves those files unreachable under any spelling.  Walking depth by depth
# is v10-import.py's algorithm and this is the same one: at each level,
# fewest capitals wins, ties lexicographically, losers percent-escaped, and a
# child's stored path is built on its parent's stored path.
rows = []
LINKOF = {}
LINKTGT = {}          # (archive, member) -> (root, the target's true path)
LINKDST = {}          # (archive, member) -> where the target is STORED
for tb, sub, strip in TARS:
    out = subprocess.run(["tar", "-tvf", os.path.join(w, tb)],
                         capture_output=True, text=True).stdout
    names = []
    for line in out.splitlines():
        if not line.startswith("-"):        # regular files only
            continue
        raw = line.split(None, 8)[-1]
        n, _, tgt = raw.partition(" link to ")
        p = relpath(n, strip)
        if p:
            names.append((n, p))
            if tgt:
                # A HARD LINK NEEDS ITS TARGET IN THE SAME tar RUN.  secombe's
                # games/sail/makefile is a hard link to games/sail/Makefile --
                # the same inode, and on a case-insensitive filesystem the same
                # file -- so extracting the link alone fails with "Hard-link
                # target does not exist" and takes the whole round with it.
                LINKOF[(tb, n)] = tgt
                LINKTGT[(tb, n)] = (sub, relpath(tgt, strip))

    # every path component that appears, by depth
    bydepth = {}
    for _, p in names:
        parts = p.split("/")
        for i in range(len(parts)):
            bydepth.setdefault(i, set()).add("/".join(parts[:i + 1]))

    stored = {}                          # true path -> stored path
    for depth in sorted(bydepth):
        groups = {}
        for q in sorted(bydepth[depth]):
            parent, _, base = q.rpartition("/")
            groups.setdefault((parent, base.lower()), []).append(base)
        for (parent, _), g in sorted(groups.items()):
            sp = stored.get(parent, parent) if parent else ""
            win = sorted(g, key=lambda n: (sum(c.isupper() for c in n), n))[0]
            for base in g:
                spell = base if base == win else esc(base)
                true = (parent + "/" + base) if parent else base
                stored[true] = (sp + "/" + spell) if sp else spell

    # ANY PATH WITH A COLLIDING COMPONENT MUST BE RE-PLACED, not only the
    # losers.  jerq/src/lib/c (the C library) collides with jerq/src/lib/C
    # (the C++ one); `c' wins and `C' becomes %43, but every file UNDER c has
    # no collision of its own -- their basenames are unique -- so a rule that
    # looks at the basename leaves all sixteen of them inside the directory
    # tar happened to name `C'.  Collision is a property of the path, not of
    # the last component.
    siblings = {}
    for q in stored:
        parent, _, base = q.rpartition("/")
        siblings.setdefault((parent, base.lower()), set()).add(base)
    def collides(q):
        parts = q.split("/")
        for i in range(len(parts)):
            parent = "/".join(parts[:i])
            if len(siblings.get((parent, parts[i].lower()), ())) > 1:
                return True
        return False

    for (tbk, nk), (sb, tp) in list(LINKTGT.items()):
        if tbk == tb and tp in stored:      # resolve to where it will LAND
            LINKDST[(tbk, nk)] = os.path.join(sb, stored[tp])

    for orig, p in names:
        if stored[p] != p or collides(p):
            rows.append((tb, sub, orig, os.path.join(sub, stored[p]),
                         os.path.join(sub, p)))

# ONE TAR PASS PER TARBALL, NOT ONE PER FILE.  tar takes a list of members;
# invoking it 196 times over a bz2 archive decompresses 25,000 files each
# time and does not finish.  The losers of a group still collide with each
# other in the staging directory, so they go out in rounds: each round takes
# one member per (directory, lowercased name), which is at most a handful.
import shutil, tempfile
unplaced = []
byt = {}
for tb, sub, orig, target, true in rows:
    byt.setdefault(tb, []).append((orig, target))

for tb, items in byt.items():
    left = list(items)
    while left:
        # A ROUND MAY HOLD NO TWO PATHS THAT COLLIDE AT ANY COMPONENT.  Keying
        # on the basename alone is not enough: vol2/index/junk is a FILE and
        # vol2/index/Junk/ is a DIRECTORY, so the file blocks the directory in
        # the staging area and tar fails with "Not a directory".  A member is
        # admitted only if every prefix of its path is unclaimed or already
        # claimed by exactly this spelling.
        claimed, this, rest = {}, [], []
        for orig, target in left:
            parts = orig.split("/")
            pre = ["/".join(parts[:i + 1]) for i in range(len(parts))]
            if all(claimed.get(q.lower(), q) == q for q in pre):
                for q in pre:
                    claimed[q.lower()] = q
                this.append((orig, target))
            else:
                rest.append((orig, target))
        td = tempfile.mkdtemp()
        # PRE-CREATE THE PARENTS.  Given an explicit member list, bsdtar does
        # not necessarily create intermediate directories -- the directory
        # ENTRY is not in the list -- and fails with "Can't create
        # games/sail/makefile: No such file or directory" on a path whose
        # parent it made perfectly well in the previous round.
        for o, _ in this:
            d = os.path.dirname(o.lstrip("./"))
            if d:
                os.makedirs(os.path.join(td, d), exist_ok=True)
        want = [o for o, _ in this]
        for o, _ in this:                   # pull each link's target in too
            t = LINKOF.get((tb, o))
            if t and t not in want:
                d = os.path.dirname(t.lstrip("./"))
                if d:
                    os.makedirs(os.path.join(td, d), exist_ok=True)
                want.append(t)
        subprocess.run(["tar", "-xf", os.path.join(w, tb), "-C", td] + want,
                       check=False)
        for orig, target in this:
            srcf = os.path.join(td, orig)
            if not os.path.exists(srcf):
                # A HARD LINK IS THE SAME INODE, SO IT IS THE SAME BYTES.
                # secombe's games/sail/makefile is a hard link to Makefile;
                # in a case-insensitive staging directory only one of the two
                # names can exist, so the link's own name is never there.
                t = LINKOF.get((tb, orig))
                srcf = os.path.join(td, t.lstrip("./")) if t else srcf
                if not (t and os.path.exists(srcf)):
                    # LAST RESORT: THE TARGET IS ALREADY IN THE TREE.  tar
                    # walks an archive in order, so a round asking for a hard
                    # link BEFORE its target fails on the link and stops
                    # without writing the target either.  The target's own
                    # round ran first, though -- `Makefile' sorts before
                    # `makefile' -- so its bytes are on disk under its stored
                    # name, and a hard link is the same inode.
                    q = LINKDST.get((tb, orig))
                    srcf = os.path.join(dest, q) if q else srcf
                    if not (q and os.path.exists(srcf)):
                        unplaced.append((tb, orig, target))
                        continue
            dst = os.path.join(dest, target)
            # SPELL EVERY PARENT DIRECTORY THE WAY THE TARGET ASKS.  On a
            # case-insensitive filesystem os.makedirs("...\u002fc") is satisfied by
            # an existing "C" and leaves the wrong name in place, so the files
            # land inside the sibling's directory.  A case-only rename fixes
            # it; the sibling's own content has already been placed under its
            # escaped name by an earlier round.
            parts = os.path.dirname(target).split("/")
            for i in range(len(parts)):
                want = os.path.join(dest, *parts[:i + 1])
                if os.path.isdir(want):
                    # THE TRUE SPELLING COMES FROM THE PARENT'S LISTING.
                    # os.path.realpath() echoes back whatever case it was
                    # given on a case-insensitive filesystem, so it can never
                    # report the mismatch -- it said "c" about a directory
                    # named "C" and the rename never fired.
                    up = os.path.join(dest, *parts[:i]) if i else dest
                    real = next((e for e in os.listdir(up)
                                 if e.lower() == parts[i].lower()), parts[i])
                    if real != parts[i]:
                        tmp = os.path.join(up, real + ".casefix")
                        os.rename(os.path.join(up, real), tmp)
                        os.rename(tmp, want)
                else:
                    os.makedirs(want, exist_ok=True)
            # UNLINK FIRST.  On a case-insensitive filesystem, opening "b.i"
            # for writing reuses the existing directory entry -- which is
            # spelled "B.i" -- so the content is corrected and the NAME is
            # not.  Removing it makes the new entry carry the name asked for.
            if os.path.isdir(dst) and not os.path.islink(dst):
                shutil.rmtree(dst)      # a directory sitting on a file's name
            elif os.path.exists(dst):
                os.remove(dst)
            shutil.copyfile(srcf, dst)
        shutil.rmtree(td)
        left = rest

with open(os.path.join(dest, "CASEMAP"), "w") as fh:
    fh.write("# stored spelling\ttrue name -- macOS cannot hold both.\n")
    for _, _, _, target, true in sorted(rows):
        if target != true:                  # ANY component, not just the last
            fh.write("%s\t%s\n" % (target, true))
if unplaced:
    print("   %d members tar could not place:" % len(unplaced))
    for tb, o, t in unplaced[:8]:
        print("      %s  %s" % (tb, o))
print("   %d files in %d collision groups re-extracted"
      % (len(rows), len({os.path.dirname(t)+"/"+os.path.basename(t).lower()
                         for _,_,_,t,_ in rows})))
PY

# ------------------------------------------------------- ar archives, by ar ---
# BY MAGIC, NOT BY NAME.  `find -name "*.a"' misses eleven archives on this
# tape -- awktest.a is caught but src/cmd/awk/test.a's siblings are not the
# only shape: an archive's name need not end in .a at all.  And the inverse
# trap is already documented: libdbm is `mv dbm.o libdbm.a' and libsdb is
# `as dbxxx.s -o libsdb.a' -- bare objects wearing a .a name, which ar
# rejects.  Reading the magic number decides both.
echo "== ar archives =="
python3 - "$DEST" <<'PY2' > "$DEST/.arlist"
import os, sys
d = sys.argv[1]
for dp, _, fs in os.walk(d):
    for f in sorted(fs):
        p = os.path.join(dp, f)
        try:
            with open(p, "rb") as fh:
                if fh.read(8) == b"!<arch>\n":
                    print(p)
        except OSError:
            pass
PY2
# UNPACKING KEEPS EVERY BYTE AND DESTROYS ONE THING: THE ORDER OF THE MEMBERS.
# A directory listing is not an archive, and that order is Bell Labs' own answer
# to the ordering question -- load-bearing, because V10's ld makes ONE sequential
# pass without a current __.SYMDEF and the golden has neither lorder nor tsort to
# recompute it.  libc.a must be rebuilt in the tape's order or backward
# references go unresolved.  So every unpacked archive carries ORDER beside its
# members, written from the archive BEFORE it is removed.
write_order() {
    python3 - "$1" "$2" <<'PYO'
import os, sys
arc, out = sys.argv[1], sys.argv[2]
d = open(arc, "rb").read()
if d[:8] != b"!<arch>\n":
    raise SystemExit(0)
o, names = 8, []
while o + 60 <= len(d):
    h = d[o:o+60]
    if h[58:60] != b"`\n":
        break
    nm = h[0:16].decode("ascii", "replace").strip().rstrip("/")
    try:
        size = int(h[48:58].decode("ascii", "replace").strip())
    except ValueError:
        break
    if nm and nm != "__.SYMDEF":
        names.append(nm)
    o += 60 + size + (size & 1)
if names:
    open(os.path.join(out, "ORDER"), "w").write("".join(x + "\n" for x in names))
PYO
}

n=0; bad=0
while IFS= read -r a; do
    [[ -n "$a" ]] || continue
    tmp="$a.unpack"
    rm -rf "$tmp"; mkdir -p "$tmp"
    if ( cd "$tmp" && ar x "$a" ) 2>/dev/null; then
        rm -f "$tmp/__.SYMDEF"
        if [ -n "$(ls -A "$tmp")" ]; then
            write_order "$a" "$tmp"
            rm -f "$a" && mv "$tmp" "$a"      # the DIRECTORY takes the name
            n=$((n+1))
            continue
        fi
    fi
    # ar(1) ON macOS REFUSES THE WE32100 ARCHIVES -- 630/lib/lib{c,m,j,jj,jx,fw}.a
    # and the IX 5620 frame.a.  The ar FORMAT is the same; it is the objects
    # inside that macOS ar will not parse.  So read the format directly: a
    # 60-byte header per member, name in bytes 0-15, size in 48-57.
    if python3 - "$a" "$tmp" <<'PY3'
import os, sys
arc, out = sys.argv[1], sys.argv[2]
d = open(arc, "rb").read()
o, n = 8, 0
os.makedirs(out, exist_ok=True)
while o + 60 <= len(d):
    h = d[o:o+60]
    name = h[0:16].decode("ascii", "replace").strip().rstrip("/")
    try:
        size = int(h[48:58].decode("ascii", "replace").strip())
    except ValueError:
        break
    if name and name != "__.SYMDEF":
        open(os.path.join(out, name), "wb").write(d[o+60:o+60+size])
        n += 1
    o += 60 + size + (size & 1)
sys.exit(0 if n else 1)
PY3
    then
        write_order "$a" "$tmp"
        rm -f "$a" && mv "$tmp" "$a"
        n=$((n+1)); continue
    fi
    rm -rf "$tmp"; bad=$((bad+1))             # not an archive at all
done < "$DEST/.arlist"
rm -f "$DEST/.arlist"
echo "   $n archives unpacked, $bad left as files (ar could not read them)"

# ------------------------------------------------- cpio and tar, by their tools ---
# THE TAPE PACKAGES SOURCE IN cpio AND tar TOO, not only in ar.  Six .cpio and
# one .tar sit under cmd/ -- tbl, bcp, docgen, post.src, gnucpp, odist -- and
# they are source packages of exactly the kind the .c.a archives are.  Left
# packed they are invisible to every survey, and .gitignore excludes them by
# suffix besides, so they would not even reach the repository.
echo "== cpio and tar packages =="
c=0
while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    d="$f.unpack"; rm -rf "$d"; mkdir -p "$d"
    case "$f" in
    *.cpio) ( cd "$d" && cpio -idmu --quiet < "$f" ) 2>/dev/null || true ;;
    *.tar)  tar -xf "$f" -C "$d" 2>/dev/null || true ;;
    esac
    if [ -n "$(ls -A "$d" 2>/dev/null)" ]; then
        rm -f "$f" && mv "$d" "$f"; c=$((c+1))
    else
        rm -rf "$d"
    fi
done < <(find "$DEST" -type f \( -name '*.cpio' -o -name '*.tar' \))
echo "   $c packages unpacked"
echo "== total: $(find "$DEST" -type f | wc -l | tr -d ' ') files =="

# --------------------------------------------------------- our patches on top ---
# v10/src IS ROOTED AT THE TAPE'S src/, so v10/src/libc/stdio/printf.c is
# src/libc/stdio/printf.c here.  Getting that wrong is silent: the tree looks
# complete and carries none of our fixes.
#
# 33 of them supersede a tape file and 16 are ADDITIONS with no upstream at
# all -- nafsmnt.c, the headers reconstructed from the manual (shares.h,
# sys/lnode.h), our 780 kernel config, and the whole of /etc.  "src must
# contain EVERYTHING required to create a golden image", so both go in: one
# tree the builder can build from, with every deviation listed in OVERLAY.
# ------------------------------------------------------------- readable ---
# ar PRESERVES A MEMBER'S STORED MODE, AND SOME ARE 0000.
# src/cmd/worm/scsi/tcl/tcl.a holds a member with no permission bits at all,
# so `git add' stopped the whole staging run with "Permission denied /
# unable to index file" -- one file out of 54,094, and nothing was committed.
# git records only the executable bit, so widening read access loses nothing
# it would have kept, and the alternative is a tree that cannot be committed.
echo "== permissions =="
u=$(find "$DEST" -type f ! -perm -u+r | wc -l | tr -d ' ')
find "$DEST" -type d -exec chmod u+rwx {} +
find "$DEST" -type f -exec chmod u+rw {} +
echo "   $u files had no read permission (ar preserves the member's mode)"

echo "== our patches =="
: > "$DEST/OVERLAY"
o=0
while IFS= read -r f; do
    rel="${f#$ROOT/v10/src/}"
    [[ "$rel" == PATCHES.md ]] && continue
    dst="$DEST/src/$rel"
    if [[ -e "$dst" ]]; then
        printf 'patch\tsrc/%s\t%s\n' "$rel" "$(shasum -a256 "$dst" | cut -c1-16)" >> "$DEST/OVERLAY"
    else
        printf 'add\tsrc/%s\t-\n' "$rel" >> "$DEST/OVERLAY"
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$f" "$dst"
    o=$((o+1))
done < <(find "$ROOT/v10/src" -type f ! -name PATCHES.md | sort)
echo "   $o files from v10/src ($(grep -c '^patch' "$DEST/OVERLAY") patches, $(grep -c '^add' "$DEST/OVERLAY") additions)"

# ------------------------------------------------------------------ verify ---
# EVERY REGULAR MEMBER OF EVERY TARBALL MUST BE PRESENT, as itself or under
# its escaped spelling or inside an unpacked archive.  Not a count -- a
# per-path check, because a count reconciles for the wrong reasons.
echo "== verify =="
python3 - "$DEST" "$W" <<'PY2'
import os, subprocess, sys
dest, w = sys.argv[1], sys.argv[2]
def esc(n):
    return "".join("%%%02X" % ord(c) if c.isupper() else c for c in n)
want = set()
for tb, sub, strip in [("v10src.tar.bz2","src",0),("v10blit.tar.bz2","blit",1),
                       ("r70include.tar","include",1),
                       ("v10-secombe.gz","secombe",1),
                       ("v10-milligan.gz","milligan",1),
                       ("v10-sellers.gz","sellers",1)]:
    out = subprocess.run(["tar","-tvf",os.path.join(w,tb)],
                         capture_output=True,text=True).stdout
    for line in out.splitlines():
        if line.startswith("-"):
            n = line.split(None,8)[-1].split(" link to ")[0]
            # undo tar's C-style escaping of non-printable bytes
            out, i = [], 0
            while i < len(n):
                if n[i] == "\\" and i+1 < len(n):
                    m = {"b":"\b","t":"\t","n":"\n","r":"\r","f":"\f","v":"\v","\\":"\\"}
                    if n[i+1] in m: out.append(m[n[i+1]]); i += 2; continue
                    if n[i+1:i+4].isdigit(): out.append(chr(int(n[i+1:i+4],8))); i += 4; continue
                out.append(n[i]); i += 1
            parts = "".join(out).split("/")[strip:]
            while parts and parts[0] in ("", "."): parts = parts[1:]
            p = "/".join(parts)
            if p: want.add(os.path.join(sub,p))
have = {os.path.relpath(os.path.join(d,f),dest)
        for d,_,fs in os.walk(dest) for f in fs}
have |= {os.path.relpath(d,dest) for d,_,_ in os.walk(dest)}   # unpacked archives
# CASEMAP IS THE AUTHORITY ON WHERE AN ESCAPED PATH LIVES.  Escaping the
# basename alone is not enough: jerq/src/lib/C/_ctor.c is stored at
# jerq/src/lib/%43/_ctor.c, escaped at the PARENT, and a basename-only check
# reports all sixteen of them missing while they sit exactly where they
# belong.
stored = {}
cm = os.path.join(dest, "CASEMAP")
if os.path.exists(cm):
    for line in open(cm):
        if line.startswith("#"): continue
        t, tr = line.rstrip("\n").split("\t")
        stored[tr] = t
missing = sorted(p for p in want if p not in have and stored.get(p, p) not in have)
print("   tarball members %d, present %d, MISSING %d"
      % (len(want), len(want)-len(missing), len(missing)))
for m in missing[:10]:
    print("      %s" % m)
sys.exit(1 if missing else 0)
PY2
