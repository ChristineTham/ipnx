#!/usr/bin/env bash
#
# Extract the six V10 archives into v10tapes/, PRISTINE.
#
#	bash tools/v10-tapes.sh
#
# ONE ROOT PER TAPE, NEVER MERGED, NEVER PATCHED.  This is the evidence, not
# the build tree: the reconstruction reads it and builds a superset elsewhere,
# recording where every file came from.  Keeping the two apart is the point --
# the previous arrangement extracted and patched in one pass, so the tree the
# build read was neither the tape nor our corrections but a merge of both, and
# "what does the tape say" could not be answered from it at all.
#
# NOTHING IS UNPACKED HERE.  An ar archive stays an ar archive, a nested tar
# stays a tar.  Unpacking belongs to the reconstruction, where the member ORDER
# can be recorded beside the members -- extracting an archive into a directory
# keeps every byte and destroys the one thing a directory cannot hold.
#
# THE SIX:
#	norman      /usr/src, the larger of the two source tapes
#	secombe     /usr/src from a DIFFERENT machine -- newer in places
#	milligan    /usr/jerq, the 5620 distribution
#	sellers     /usr/man and vol2, the documentation
#	r70include  /usr/include, r70's reconstruction
#	blit        the 68000 Blit, a different terminal
#
# THREE THINGS A NAIVE EXTRACT GETS WRONG, each measured here, not assumed:
#
#   1  tar COUNTS THE LEADING `.' AS A COMPONENT, so `--strip 1' on
#      `./dk/cmd/x' leaves `dk/cmd/x'.  Removing the `./' in our own path
#      arithmetic AND THEN stripping one more made every path on the five
#      dot-rooted tapes short by a component, and the verify then called
#      21,538 present files missing.
#
#   2  A CASE COLLISION IS SOMETIMES ONE INODE WITH TWO NAMES.
#      games/sail/makefile is a HARD LINK to games/sail/Makefile, and tar says
#      so when asked for the link alone: "Hard-link target ... does not exist".
#      That is not two files competing for a slot; it is one file that a
#      case-insensitive filesystem cannot name twice.  One name is kept.
#
#   3  WHEN TWO REAL FILES COLLIDE, THE WINNER IS OFTEN THE ONE THAT FAILED.
#      tar fills the shared slot with whichever member it reaches first, so
#      under a lowercase-wins rule the file left missing is frequently the one
#      the rule says to keep.  Moving the loser aside does not put the winner
#      back: both sides are cleared and extracted again.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/v10tapes"
W="$ROOT/work"

for a in v10src.tar.bz2 v10-secombe.gz v10-milligan.gz v10-sellers.gz \
         r70include.tar v10blit.tar.bz2; do
    [[ -f "$W/$a" ]] || { echo "v10-tapes: no work/$a"; exit 1; }
done

rm -rf "$DEST"
mkdir -p "$DEST"

echo "== extract =="
python3 - "$DEST" "$W" <<'PY'
import collections, hashlib, os, subprocess, sys

dest, w = sys.argv[1], sys.argv[2]

# tape, archive, strip -- strip is what tar is given, counting the `.'
TAPES = [("norman",     "v10src.tar.bz2",  0),
         ("secombe",    "v10-secombe.gz",  1),
         ("milligan",   "v10-milligan.gz", 1),
         ("sellers",    "v10-sellers.gz",  1),
         ("r70include", "r70include.tar",  1),
         ("blit",       "v10blit.tar.bz2", 1)]


def taropt(arch):
    return ("-tf", "-xf") if arch.endswith((".bz2", ".tar")) else ("-tzf", "-xzf")


def unesc(n):
    """tar -t escapes non-printable bytes C-style; undo it.

    secombe/sys/io holds a file whose name contains a literal BACKSPACE -- tar
    prints it as `caa\bmac.oldc' -- so comparing tar's listing against the
    directory reports a file that is present as missing.  The byte is on the
    TAPE; the escaping is tar's.
    """
    out, i = [], 0
    while i < len(n):
        if n[i] == "\\" and i + 1 < len(n):
            c = n[i + 1]
            m = {"b": "\b", "t": "\t", "n": "\n", "r": "\r",
                 "f": "\f", "v": "\v", "\\": "\\"}
            if c in m:
                out.append(m[c]); i += 2; continue
            if n[i + 1:i + 4].isdigit():
                out.append(chr(int(n[i + 1:i + 4], 8))); i += 4; continue
        out.append(n[i]); i += 1
    return "".join(out)


def relpath(name, strip):
    """Where tar will put `name' under --strip <strip>.

    The `.' is dropped and the strip count reduced by one, which is the same
    arithmetic tar does -- note 1 in the header.  NOT lstrip("./"), which takes
    a CHARACTER SET and would turn `./.profile' into `profile'.
    """
    parts = [p for p in name.split("/") if p and p != "."]
    return "/".join(parts[strip - 1 if strip else 0:])


def listing(arch):
    """(raw-name, clean-name, isdir) for every line of an archive's index."""
    t, _ = taropt(arch)
    out = subprocess.run(["tar", t, os.path.join(w, arch)],
                         capture_output=True, text=True).stdout
    for line in out.splitlines():
        isdir = line.endswith("/")
        yield unesc(line), unesc(line[:-1] if isdir else line), isdir


# HOW COMMON IS EACH SPELLING?  Counted over every member of every archive, so
# "keep the more commonly used name" is a measurement and not a preference.
POP = collections.Counter()
for _tape, arch, _strip in TAPES:
    for _raw, name, isdir in listing(arch):
        if not isdir:
            POP[os.path.basename(name)] += 1

cmap = open(os.path.join(dest, "CASEMAP"), "w")
cmap.write("# tape\tpath-on-tape\tpath-on-disk\n")
hlog = open(os.path.join(dest, "HARDLINKS"), "w")
hlog.write("# tape\tdirectory\tkept\tdropped\n")

collisions = renamed = links = swept = 0
xlat = {}          # (tape, tape-path) -> disk-path
dropped = set()    # (tape, tape-path) deliberately not on disk

for tape, arch, strip in TAPES:
    _, xf = taropt(arch)
    members = [(raw, relpath(name, strip), isdir)
               for raw, name, isdir in listing(arch)
               if relpath(name, strip)]

    # -------------------------------------------------------- the renames ---
    # Every component of every path, grouped by parent and lowercased
    # spelling.  Directories appear both as members in their own right and as
    # components of the paths beneath them, so both are collected.
    kids = collections.defaultdict(set)
    for _, rel, _ in members:
        parts = rel.split("/")
        for i, comp in enumerate(parts):
            kids["/".join(parts[:i])].add(comp)

    ren = {}
    for parent, names in kids.items():
        g = collections.defaultdict(list)
        for n in names:
            g[n.lower()].append(n)
        for _low, spellings in g.items():
            if len(spellings) < 2:
                continue
            collisions += 1
            # THE ALL-LOWERCASE SPELLING KEEPS THE NAME; the others take a
            # `u_' prefix in front of their own, unaltered spelling:
            #     makefile  Makefile  ->  makefile   u_Makefile
            #     junk      Junk/     ->  junk       u_Junk/
            # Per COMPONENT, and directories too, so everything under a
            # renamed directory follows it.  Where no all-lowercase spelling
            # exists, the first in sort order keeps its name.
            lower = [n for n in spellings if n == n.lower()]
            keep = lower[0] if lower else sorted(spellings)[0]
            for n in sorted(spellings):
                if n != keep:
                    ren[(parent, n)] = "u_" + n
                    renamed += 1

    def translate(rel, _ren=ren):
        parts, out = rel.split("/"), []
        for i, comp in enumerate(parts):
            out.append(_ren.get(("/".join(parts[:i]), comp), comp))
        return "/".join(out)

    # ------------------------------------------------------- the bulk pass ---
    # tar is allowed to fail: the collisions are what the passes below are for.
    os.makedirs(os.path.join(dest, tape), exist_ok=True)
    a = ["tar", xf, os.path.join(w, arch), "-C", os.path.join(dest, tape)]
    if strip:
        a += ["--strip", str(strip)]
    subprocess.run(a, capture_output=True)

    # ---------------------------------------------------- contested slots ---
    # Anything renamed, and anything sharing a slot with something renamed --
    # note 3.  Both sides are cleared first, then extracted again.
    renamed_low = {rel.lower() for _, rel, _ in members if translate(rel) != rel}
    need = [(raw, rel) for raw, rel, isdir in members
            if not isdir and (translate(rel) != rel or rel.lower() in renamed_low)]

    scratch = os.path.join(dest, "scratch")
    if need:
        for _, rel in need:
            subprocess.run(["rm", "-rf", os.path.join(dest, tape, rel)])
        # Two members of one collision group cannot share a scratch tree
        # either, so they go in separate passes.
        byslot, seen = collections.defaultdict(list), collections.Counter()
        for raw, rel in need:
            k = rel.lower()
            byslot[seen[k]].append((raw, rel))
            seen[k] += 1
        for slot in sorted(byslot):
            subprocess.run(["rm", "-rf", scratch])
            os.makedirs(scratch, exist_ok=True)
            a = ["tar", xf, os.path.join(w, arch), "-C", scratch]
            if strip:
                a += ["--strip", str(strip)]
            # ONE PASS PER GROUP, NOT PER FILE.  bzip2 has no index, so pulling
            # one member costs a full decompression of the 75 MB stream, and
            # hundreds of those is a script that looks like it has hung.
            subprocess.run(a + [raw for raw, _ in byslot[slot]],
                           capture_output=True)
            for raw, rel in byslot[slot]:
                got = os.path.join(scratch, rel)
                if not os.path.lexists(got):
                    continue
                tgt = os.path.join(dest, tape, translate(rel))
                os.makedirs(os.path.dirname(tgt), exist_ok=True)
                os.replace(got, tgt)
        subprocess.run(["rm", "-rf", scratch])

    # -------------------------------------------------------- hard links ---
    # What is still absent but has a twin at the same slot is note 2: one inode
    # under two names.  ONE NAME IS KEPT -- the commoner spelling by count --
    # and the other is recorded as deliberately dropped.  A rename here would
    # invent a second file where the tape has one.
    on_disk = {}
    for _, rel, isdir in members:
        if isdir:
            continue
        f = os.path.join(dest, tape, translate(rel))
        if os.path.lexists(f):
            on_disk[rel.lower()] = (rel, f)
    for _, rel, isdir in members:
        if isdir:
            continue
        if os.path.lexists(os.path.join(dest, tape, translate(rel))):
            continue
        twin = on_disk.get(rel.lower())
        if not twin:
            continue
        kept_rel, kept_path = twin
        mine, theirs = os.path.basename(rel), os.path.basename(kept_rel)
        if POP.get(mine, 0) > POP.get(theirs, 0):
            newp = os.path.join(os.path.dirname(kept_path), mine)
            os.replace(kept_path, newp)
            on_disk[rel.lower()] = (rel, newp)
            keep_name, drop_name, drop_rel = mine, theirs, kept_rel
        else:
            keep_name, drop_name, drop_rel = theirs, mine, rel
        hlog.write("%s\t%s\t%s\t%s\n"
                   % (tape, os.path.dirname(rel) or ".", keep_name, drop_name))
        dropped.add((tape, drop_rel))
        links += 1

    # ------------------------------------------------------------- sweep ---
    # A net, not a plan.  Anything the rules did not anticipate is extracted by
    # name and COUNTED, because a silent net turns "the rules cover every case"
    # into a claim nobody checks.
    left = [(raw, rel) for raw, rel, isdir in members
            if not isdir and (tape, rel) not in dropped
            and not os.path.lexists(os.path.join(dest, tape, translate(rel)))]
    if left:
        subprocess.run(["rm", "-rf", scratch])
        os.makedirs(scratch, exist_ok=True)
        a = ["tar", xf, os.path.join(w, arch), "-C", scratch]
        if strip:
            a += ["--strip", str(strip)]
        subprocess.run(a + [raw for raw, _ in left], capture_output=True)
        for raw, rel in left:
            got = os.path.join(scratch, rel)
            if not os.path.lexists(got):
                continue
            tgt = os.path.join(dest, tape, translate(rel))
            os.makedirs(os.path.dirname(tgt), exist_ok=True)
            os.replace(got, tgt)
            swept += 1
        subprocess.run(["rm", "-rf", scratch])

    # ------------------------------------------------------------ record ---
    for _, rel, isdir in members:
        if isdir:
            continue
        t = translate(rel)
        if t != rel:
            cmap.write("%s\t%s\t%s\n" % (tape, rel, t))
        xlat[(tape, rel)] = t

    print("   %-11s %6d members" % (tape, sum(1 for _, _, d in members if not d)))

cmap.close()
hlog.close()
print("   %d colliding names, %d renamed with u_" % (collisions, renamed))
print("   %d were one inode under two names -- one kept (see HARDLINKS)" % links)
print("   %d recovered by the sweep" % swept)

# ------------------------------------------------------------------ verify ---
# EVERY REGULAR MEMBER MUST BE PRESENT, at its own name or the one CASEMAP
# gives it, unless HARDLINKS says it was deliberately dropped.  Not a count --
# a per-path check, because a count reconciles for the wrong reasons.
want = miss = 0
for tape, arch, strip in TAPES:
    for _raw, name, isdir in listing(arch):
        if isdir:
            continue
        rel = relpath(name, strip)
        if not rel:
            continue
        want += 1
        if (tape, rel) in dropped:
            continue
        # lexists, NOT exists: cmd/map/export/mapdata is a symlink to
        # /usr/maps, which the host does not have, so exists() follows it and
        # calls a file that is plainly there missing.
        if not os.path.lexists(os.path.join(dest, tape, xlat.get((tape, rel), rel))):
            miss += 1
            if miss <= 10:
                print("   MISSING %s/%s" % (tape, rel))
print("   archive members %d, dropped as duplicate names %d, MISSING %d"
      % (want, len(dropped), miss))

# ---------------------------------------------------------------- manifest ---
# EVERY FILE, ITS TAPE, SIZE, MTIME AND HASH.  This is what the reconstruction
# reads to decide which tape supplies a contested path.
n = 0
with open(os.path.join(dest, "MANIFEST"), "w") as f:
    f.write("# tape\tpath\tbytes\tmtime\tsha256-16\n")
    for tape, _a, _s in TAPES:
        d = os.path.join(dest, tape)
        for dp, _dn, fn in os.walk(d):
            for name in sorted(fn):
                p = os.path.join(dp, name)
                if os.path.islink(p):
                    continue
                try:
                    b = open(p, "rb").read()
                except OSError:
                    continue
                f.write("%s\t%s\t%d\t%d\t%s\n"
                        % (tape, os.path.relpath(p, d), len(b),
                           int(os.stat(p).st_mtime),
                           hashlib.sha256(b).hexdigest()[:16]))
                n += 1
print("   %d files in the manifest" % n)
sys.exit(1 if miss else 0)
PY
rc=$?

# ar PRESERVES A MEMBER'S STORED MODE AND SOME ARE 0000.  Harmless inside an
# archive; on disk it stops any pass that walks the tree.
u=$(find "$DEST" -type f ! -perm -u+r | wc -l | tr -d ' ')
find "$DEST" -type d -exec chmod u+rwx {} + 2>/dev/null
find "$DEST" -type f -exec chmod u+rw {} + 2>/dev/null
echo "   $u files had no read permission"
echo "== total: $(find "$DEST" -type f | wc -l | tr -d ' ') files in $DEST =="
exit $rc
