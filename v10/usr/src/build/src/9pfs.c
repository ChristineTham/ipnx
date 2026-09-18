/*
 * 9pfs -- present a remote 9P2000.u tree to V10 as a mounted filesystem.
 *
 *	cc -O -o 9pfs 9pfs.c -lnetb -lin
 *	runfs /n/macos /etc/9pfs 10.0.2.2 9200
 *
 * ipnx ADDITION, not a patch.  It replaces nafsmnt: the host no longer speaks
 * netfs at all, only 9P, and this program is what makes that possible without
 * touching the kernel.
 *
 * WHY THERE IS NO KERNEL 9P CLIENT HERE, WHICH WAS THE FIRST PLAN AND WAS
 * WRONG.  V10 has user-mounted filesystems, and that is the whole trick.
 * fmount(2) takes a FILE DESCRIPTOR and a filesystem type -- netfs/libnetb's
 * runfs.c is `pipe(); fork(); child: fmount(NBFS, pipefd, mpoint, dev);
 * parent: execv(server)' -- so the thing on the other end of a mount can be a
 * local user process reached through a pipe.  That is the FUSE arrangement,
 * about twenty years early, and it means a new protocol needs no new
 * fstypsw[] entry, no kernel rebuild and no reboot to test.
 *
 * So the shape is:
 *
 *	V10 kernel  --netb over a pipe-->  9pfs  --9P2000.u over TCP-->  host
 *	(fs/netb.c)                    (this file)                 (tools/9pfsd.py)
 *
 * and the netb half is BELL LABS' CODE ON BOTH SIDES: fs/netb.c in the kernel,
 * netfs/libnetb in userland.  We implement neither.  netb survives as a detail
 * between two programs that already shipped with the machine.
 *
 * NETFS IS NOT BEING RETIRED, and that is a decision rather than an oversight.
 * V8 has only neta -- the first of Weinberger's two protocols -- and no tape
 * carries a libneta, so the trick this file depends on is not available there:
 * V8 would need a kernel 9P client, for no gain.  So netfs/, tools/netfsd.py
 * and docs/netfs-protocol.md are V8's and stay exactly as they are, 9P is
 * V10's, and the app will have to serve both.
 *
 * WHAT THIS FILE IS, THEREFORE: the thirteen callbacks in <rf.h>, expressed as
 * 9P messages.  libnetb supplies main() (netfs/libnetb/setupmain.c), the setup
 * handshake, the tag table, the permission checks and the dispatch loop; it
 * calls fsinit once and then fswalk/fsstat/fsread/... per request.  zarf.c is
 * the worked example -- Bell Labs' own server for the local filesystem -- and
 * where this file and rf.h's comments disagree about an argument list, zarf.c
 * is right and the comments are stale (fsmkdir really does take mode/uid/gid;
 * fsrmdir really does not).
 *
 * THE ONE CONVENTION THAT IS NOT OBVIOUS: fswalk returns NULL with fserrno
 * LEFT AT ZERO to mean `that .. walked out of my root'.  funcs.c:352 turns
 * that into the netb NBROOT flag and computes how much of the pathname it
 * consumed, and the kernel then continues the lookup in the filesystem above
 * the mount point.  A walk that fails for an ordinary reason must set fserrno.
 *
 * AND ONE THAT COSTS A FID IF MISSED: libnetb keeps its own tag table and
 * de-duplicates on (Rfile.ino, Rfile.dev) -- funcs.c:141 -- calling fsdone on
 * whichever copy it does not keep.  So ino must be a stable per-file identity
 * or the same file gets two tags.  9P's qid.path is exactly that, and
 * tools/9pfsd.py hands out small dense ones on purpose, because V10's ino_t is
 * an unsigned short, so Rfile.ino has to survive the trip into a struct stat's
 * st_ino.  (dirread(2) renders an i-number as decimal text and is not bound by
 * that, but stat(2) is, and a folded i-number would make two files look like
 * links to each other.)
 *
 * TWO FIDS PER FILE, AND 9P REQUIRES IT.  A fid must be opened with Topen
 * before Tread or Twrite, and an opened fid may not be walked.  V10 hands us
 * one handle per file and expects to walk from it and read it, so each Rfile
 * carries a control fid (never opened; walk, stat, wstat, create, remove) and
 * an I/O fid cloned from it and opened on first use.  Getting this wrong
 * presents as `Twalk on an open fid' from the server and looks like a server
 * bug.
 *
 * K&R throughout: pcc2 is the compiler and it rejects a prototype outright.
 * No prototypes, no void, and declarations before statements.
 */
#include <sys/types.h>
#include <sys/inet/tcp_user.h>
#include <errno.h>
#include <stdio.h>
#include <rf.h>

/*
 * ------------------------------------------------------------ the protocol
 * 9P2000.u.  A message is size[4] type[1] tag[2] then a body; everything is
 * little-endian, which is also the VAX's, and a string is a 2-byte count and
 * that many bytes with no terminator.  9P has no NUL anywhere.
 *
 * The authority for the layout is the Plan 9 section 5 manual pages, checked
 * against 9fans.net/go/plan9 and plan9port's src/lib9/convS2M.c.  Those could
 * not simply be ported: Fcall.offset is a vlong and this compiler has no
 * 64-bit integer type, and Fcall is some 400 bytes (wqid[16] alone is 208).
 * Field order below is theirs; the marshalling is a cursor, not a struct.
 */
#define	N9VERSION	"9P2000.u"
#define	N9HDR		7
#define	N9IOHDR		24		/* the widest header: Twrite's */
#define	N9MSIZE		(8192+N9IOHDR)

#define	Tversion	100
#define	Rversion	101
#define	Tattach		104
#define	Rattach		105
#define	Rerror		107
#define	Twalk		110
#define	Rwalk		111
#define	Topen		112
#define	Ropen		113
#define	Tcreate		114
#define	Rcreate		115
#define	Tread		116
#define	Rread		117
#define	Twrite		118
#define	Rwrite		119
#define	Tclunk		120
#define	Rclunk		121
#define	Tremove		122
#define	Rremove		123
#define	Tstat		124
#define	Rstat		125
#define	Twstat		126
#define	Rwstat		127

#define	N9QTDIR		0x80
#define	N9QTSYMLINK	0x02

#define	N9DMDIR		0x80000000
#define	N9DMSYMLINK	0x02000000
#define	N9DMDEVICE	0x00800000
#define	N9DMNAMEDPIPE	0x00200000
#define	N9DMSOCKET	0x00100000
#define	N9DMSETUID	0x00080000
#define	N9DMSETGID	0x00040000

#define	N9OREAD		0
#define	N9OWRITE	1
#define	N9ORDWR		2
#define	N9OTRUNC	0x10

#define	N9NOFID		0xFFFFFFFFL
#define	N9NOTOUCH2	0xFFFF
#define	N9NOTOUCH4	0xFFFFFFFFL

/*
 * NAMES ARE NOT LIMITED TO 14 BYTES HERE, which is worth stating because the
 * disk's are.  <sys/dir.h>'s DIRSIZ bounds a name in a V10 DIRECTORY; netb
 * carries a name as a counted string in the namei message and dirread(2)
 * returns it as NUL-terminated text, so neither end of this program has a
 * fourteen-byte field in it.  netfs/serv/libdir.c -- Bell Labs' own portable
 * directory reader for a netb server -- passes dp->d_name through whole for
 * exactly that reason.  64 is this program's own buffer and nothing else's.
 */
#define	N9NAMELEN	64

/*
 * ------------------------------------------------------------ private data
 * Rfile.fs points at one of these.  See the header comment on the two fids.
 */
typedef struct {
	long	fid;		/* control fid: never opened */
	long	iofid;		/* clone, opened; -1 when there is none */
	int	omode;		/* what iofid was opened for */
	long	qpath;		/* qid.path, for the identity check in fsstat */
	char	*name;		/* last component, for the log only */
} Fsfile;

#define	fsp(f)	((Fsfile *)(f)->fs)

/*
 * ------------------------------------------------------------ global state
 * EVERY EXCHANGE IS SERIALISED, so one send buffer, one receive buffer and one
 * tag are enough, and keeping them out of the stack matters on a machine whose
 * kernel gave this process a small one.  libnetb's dispatch loop is
 * single-threaded by construction: it reads a netb request, calls one of the
 * callbacks below, writes the reply, and only then reads again.
 */
static int srvfd = -1;			/* the 9P connection */
static long msize = N9MSIZE;		/* negotiated in fsinit */
static unsigned char *sbuf, *rbuf;
static int sp;				/* send cursor */
static int rp;				/* receive cursor */
static int rlen;			/* bytes in rbuf */
static int stype;			/* type of the message being built */
static int rtype;			/* type of the reply */
static Rfile *rootf;

#define	NFID	512			/* fids in flight; V10 gives us 100 tags */
static char fidmap[NFID];

extern int errno;
extern char *errstr;			/* libin's diagnostic, set by tcp_connect */
char *malloc();
in_addr in_address();

/*
 * ------------------------------------------------------------ small helpers
 */
static
n9copy(d, s, n)
register char *d, *s;
register int n;
{
	while (--n >= 0)
		*d++ = *s++;
}

/*
 * MAP THE HOST'S errno ONTO ONE rf.h NAMES, rather than passing it through.
 * The numbers agree for the common cases because both descend from V7, but the
 * host is Linux or macOS and its private numbers mean nothing here -- an
 * ENOTSUP arriving as 95 would reach the kernel as a plausible-looking errno
 * for something else entirely.  Anything unrecognised becomes RFEIO, which is
 * at least honest.
 */
static
n9err(e)
int e;
{
	switch (e) {
	case 1:		return (RFEOWNER);
	case 2:		return (RFENOENT);
	case 5:		return (RFEIO);
	case 6:		return (RFENXIO);
	case 13:	return (RFEACCES);
	case 16:	return (RFEBUSY);
	case 17:	return (RFEEXIST);
	case 18:	return (RFEXDEV);
	case 20:	return (RFENOTDIR);
	case 21:	return (RFEISDIR);
	case 22:	return (RFEINVAL);
	case 28:	return (RFENOSPC);
	case 30:	return (RFEACCES);	/* EROFS: the read-only share */
	default:	return (RFEIO);
	}
}

/*
 * fid allocation.  0 is the root's and is never freed.
 */
static long
fidalloc()
{
	register int i;

	for (i = 1; i < NFID; i++)
		if (fidmap[i] == 0) {
			fidmap[i] = 1;
			return ((long)i);
		}
	rflog("9pfs: out of fids\n");
	fserrno = RFEBUSY;
	return (-1);
}

static
fidfree(f)
long f;
{
	if (f > 0 && f < NFID)
		fidmap[f] = 0;
}

/*
 * ------------------------------------------------------------ marshalling
 */
static
pstart(type)
int type;
{
	stype = type;
	sp = N9HDR;
}

static p8(v) int v; { sbuf[sp++] = v; }

static
p16(v)
register int v;
{
	sbuf[sp++] = v;
	sbuf[sp++] = v >> 8;
}

static
p32(v)
register long v;
{
	sbuf[sp++] = v;
	sbuf[sp++] = v >> 8;
	sbuf[sp++] = v >> 16;
	sbuf[sp++] = v >> 24;
}

/*
 * An 8-byte field from a 32-bit long.  Every offset and length in 9P is this
 * wide and nothing this machine can express needs the top half.
 */
static
p64(v)
long v;
{
	p32(v);
	p32(0L);
}

static
pstr(s)
register char *s;
{
	register int n;

	n = strlen(s);
	p16(n);
	n9copy((char *)sbuf + sp, s, n);
	sp += n;
}

static g8() { return (rp < rlen ? rbuf[rp++] : 0); }

static
g16()
{
	register int v;

	if (rp + 2 > rlen) { rp = rlen; return (0); }
	v = rbuf[rp] + (rbuf[rp+1] << 8);
	rp += 2;
	return (v);
}

static long
g32()
{
	register long v;

	if (rp + 4 > rlen) { rp = rlen; return (0L); }
	v = rbuf[rp] + (rbuf[rp+1] << 8)
	  + ((long)rbuf[rp+2] << 16) + ((long)rbuf[rp+3] << 24);
	rp += 4;
	return (v);
}

/* the low half of an 8-byte field; the high half is discarded */
static long
g64()
{
	register long v;

	v = g32();
	g32();
	return (v);
}

/*
 * A counted string into a fixed buffer, TRUNCATED IF IT DOES NOT FIT and the
 * cursor advanced past all of it either way.  Truncation is normal here, not
 * exceptional: V10 cannot name anything longer than 14 bytes.
 */
static
gstr(buf, max)
char *buf;
int max;
{
	register int n, k;

	n = g16();
	if (rp + n > rlen) { rp = rlen; buf[0] = 0; return (0); }
	k = n < max - 1 ? n : max - 1;
	n9copy(buf, (char *)rbuf + rp, k);
	buf[k] = 0;
	rp += n;
	return (n);
}

/*
 * ------------------------------------------------------------ the transport
 */
static
xwrite(fd, b, n)
int fd;
char *b;
int n;
{
	register int k, done;

	for (done = 0; done < n; done += k) {
		if ((k = write(fd, b + done, n - done)) <= 0)
			return (-1);
	}
	return (n);
}

static
xread(fd, b, n)
int fd;
char *b;
int n;
{
	register int k, done;

	for (done = 0; done < n; done += k) {
		if ((k = read(fd, b + done, n - done)) <= 0)
			return (-1);
	}
	return (n);
}

/*
 * Send the message built in sbuf and read its reply into rbuf.  Returns 0 with
 * rp positioned at the reply body, or -1 with fserrno set.
 *
 * ONE TAG IS ENOUGH because one request is outstanding at a time; see the
 * comment on the globals.  A server may answer in any order it likes, but
 * there is never anything for it to reorder.
 */
static
rpc(want)
int want;
{
	register long n;

	sbuf[0] = sp;
	sbuf[1] = sp >> 8;
	sbuf[2] = sp >> 16;
	sbuf[3] = sp >> 24;
	sbuf[4] = stype;
	sbuf[5] = 0;
	sbuf[6] = 0;
	if (xwrite(srvfd, (char *)sbuf, sp) < 0) {
		rflog("9pfs: write: %d\n", errno);
		fserrno = RFEIO;
		return (-1);
	}
	if (xread(srvfd, (char *)rbuf, 4) < 0) {
		rflog("9pfs: eof from server\n");
		fserrno = RFEIO;
		return (-1);
	}
	n = rbuf[0] + (rbuf[1] << 8) + ((long)rbuf[2] << 16) + ((long)rbuf[3] << 24);
	if (n < N9HDR || n > msize) {
		rflog("9pfs: reply length %ld\n", n);
		fserrno = RFEIO;
		return (-1);
	}
	if (xread(srvfd, (char *)rbuf + 4, (int)(n - 4)) < 0) {
		fserrno = RFEIO;
		return (-1);
	}
	rlen = n;
	rtype = rbuf[4];
	rp = N9HDR;
	if (rtype == Rerror) {
		char ename[64];

		gstr(ename, sizeof(ename));
		fserrno = n9err((int)g32());
		if (rfdebug)
			rflog("9pfs: Rerror %s (%d)\n", ename, fserrno);
		return (-1);
	}
	if (rtype != want) {
		rflog("9pfs: wanted type %d, got %d\n", want, rtype);
		fserrno = RFEIO;
		return (-1);
	}
	return (0);
}

/*
 * ------------------------------------------------------------ 9P operations
 */
static
n9clunk(fid)
long fid;
{
	if (fid < 0)
		return (0);
	pstart(Tclunk);
	p32(fid);
	return (rpc(Rclunk));
}

/*
 * A decoded stat entry.  Only the fields V10 can carry.
 */
typedef struct {
	int	qtype;
	long	qpath;
	long	mode;
	long	atime;
	long	mtime;
	long	length;
	char	name[N9NAMELEN];
} N9dir;

/*
 * Parse one stat entry at the cursor.  Returns 0, or -1 if it ran off the end.
 * The entry is `size[2]' and then that many bytes; the size is used to skip
 * whatever the server appended that we do not read, which is what lets a
 * 9P2000.u server and a plain 9P2000 one both work here.
 */
static
gdir(d)
register N9dir *d;
{
	register int size, end;
	char junk[32];

	size = g16();
	end = rp + size;
	if (end > rlen)
		return (-1);
	g16();				/* type, for kernel use */
	g32();				/* dev, for kernel use */
	d->qtype = g8();
	g32();				/* qid.version */
	d->qpath = g64();
	d->mode = g32();
	d->atime = g32();
	d->mtime = g32();
	d->length = g64();
	gstr(d->name, sizeof(d->name));
	gstr(junk, sizeof(junk));	/* uid  */
	gstr(junk, sizeof(junk));	/* gid  */
	gstr(junk, sizeof(junk));	/* muid */
	rp = end;			/* .u's extension/n_uid/n_gid/n_muid */
	return (0);
}

/*
 * Turn a 9P mode into a V10 one.  Rfile.type knows only RFTREG and RFTDIR --
 * rf.h says so and means it -- which is why tools/9pfsd.py is asked to follow
 * symlinks rather than describe them: a DMSYMLINK arriving here has nowhere to
 * go.  It is mapped to a regular file rather than dropped so that a share
 * served in strict mode is merely odd instead of broken.
 */
static long
n9mode(m)
register long m;
{
	register long v;

	v = m & 07777;
	if (m & N9DMDIR)
		v |= 0040000;			/* IFDIR */
	else if (m & N9DMSYMLINK)
		v |= 0100000;			/* IFREG; see above */
	else if (m & (N9DMDEVICE|N9DMNAMEDPIPE|N9DMSOCKET))
		v |= 0100000;			/* IFREG, and unreadable */
	else
		v |= 0100000;			/* IFREG */
	if (m & N9DMSETUID)
		v |= 04000;
	if (m & N9DMSETGID)
		v |= 02000;
	return (v);
}

static
unpack(f, d)
register Rfile *f;
register N9dir *d;
{
	f->ino = d->qpath;
	f->dev = 0;
	f->mode = n9mode(d->mode);
	f->type = (d->qtype & N9QTDIR) ? RFTDIR : RFTREG;
	f->nlink = (d->qtype & N9QTDIR) ? 2 : 1;
	/*
	 * OWNERSHIP FOLLOWS THE CALLER, deliberately.  The share presents every
	 * file as one owner -- 9pfsd's -u and -g, root by default -- so there
	 * is no per-file identity to carry across, and reporting a fixed uid
	 * would make the share unusable to anyone else on the machine.  Naming
	 * the caller as the owner is what netfsd did from the guest's point of
	 * view and is what makes perm.c's owner check pass for whoever mounted
	 * it.  rfuid is zero during fsinit, before any request has arrived,
	 * which is right: that is root building the root.
	 */
	f->uid = rfuid;
	f->gid = rfgid;
	f->rdev = 0;
	f->size = (d->qtype & N9QTDIR) ? 0 : d->length;
	f->ta = d->atime;
	f->tm = d->mtime;
	f->tc = d->mtime;
	fsp(f)->qpath = d->qpath;
}

/*
 * Clone a control fid without walking anywhere: Twalk with no names.  This is
 * how an I/O fid is made, and how a fid is obtained for Tcreate (which
 * CONSUMES the fid it is given, turning it into the new file).
 */
static long
n9clone(fid)
long fid;
{
	register long nf;

	if ((nf = fidalloc()) < 0)
		return (-1);
	pstart(Twalk);
	p32(fid);
	p32(nf);
	p16(0);
	if (rpc(Rwalk) < 0) {
		fidfree(nf);
		return (-1);
	}
	return (nf);
}

/*
 * Make sure f has an open I/O fid good for `mode'.  A fid already open for
 * reading is reopened when a write arrives, which is the only mode change that
 * happens in practice.
 */
static
n9io(f, mode)
register Rfile *f;
int mode;
{
	register long nf;

	if (fsp(f)->iofid >= 0) {
		if (mode == N9OREAD || fsp(f)->omode != N9OREAD)
			return (0);
		n9clunk(fsp(f)->iofid);
		fidfree(fsp(f)->iofid);
		fsp(f)->iofid = -1;
	}
	if ((nf = n9clone(fsp(f)->fid)) < 0)
		return (-1);
	pstart(Topen);
	p32(nf);
	p8(mode);
	if (rpc(Ropen) < 0) {
		n9clunk(nf);
		fidfree(nf);
		return (-1);
	}
	fsp(f)->iofid = nf;
	fsp(f)->omode = mode;
	return (0);
}

/*
 * Build an Rfile around a control fid, filling it in with one Tstat.
 */
static Rfile *
mkfile(fid, name)
long fid;
char *name;
{
	register Rfile *f;
	N9dir d;

	if ((f = (Rfile *)malloc(sizeof(Rfile))) == NULL)
		goto nomem;
	if ((f->fs = malloc(sizeof(Fsfile))) == NULL) {
		free((char *)f);
		goto nomem;
	}
	fsp(f)->fid = fid;
	fsp(f)->iofid = -1;
	fsp(f)->omode = -1;
	fsp(f)->name = NULL;
	if (name != NULL && (fsp(f)->name = malloc(strlen(name)+1)) != NULL)
		strcpy(fsp(f)->name, name);
	pstart(Tstat);
	p32(fid);
	if (rpc(Rstat) < 0)
		goto bad;
	g16();				/* the wrapping size */
	if (gdir(&d) < 0) {
		fserrno = RFEIO;
		goto bad;
	}
	unpack(f, &d);
	return (f);

nomem:
	rflog("9pfs: out of memory\n");
	fserrno = RFEINVAL;
	return (NULL);
bad:
	if (fsp(f)->name != NULL)
		free(fsp(f)->name);
	free(f->fs);
	free((char *)f);
	return (NULL);
}

/*
 * ONE dirread(2) RECORD: the i-number in decimal ascii, a tab, the name, a
 * NUL.  Writes nothing and returns -1 if it will not fit, which is what lets
 * the caller stop on a record boundary instead of half way through one.
 */
static
putent(pp, leftp, ino, name)
char **pp;
int *leftp;
long ino;
char *name;
{
	char num[16];
	register char *p, *t;
	register int i;
	int need;
	long m;

	i = sizeof(num);
	num[--i] = 0;
	m = ino;
	if (m == 0)
		num[--i] = '0';
	while (m > 0) {
		num[--i] = (int)(m % 10) + '0';
		m /= 10;
	}
	need = ((int)sizeof(num) - 1 - i) + 1 + strlen(name) + 1;
	if (need > *leftp)
		return (-1);
	p = *pp;
	for (t = &num[i]; *t; t++)
		*p++ = *t;
	*p++ = '\t';
	for (t = name; *t; t++)
		*p++ = *t;
	*p++ = 0;
	*leftp -= need;
	*pp = p;
	return (0);
}

/*
 * ------------------------------------------------------------ the callbacks
 */

/*
 * fsinit: connect, negotiate, attach, and hand back the root.
 *
 * The socket and the connect are the tape's own -- libin's tcp_sock() walks
 * the ODD minors of /dev/tcp?? because tcp_device.c refuses an even one whose
 * socket is not already active, and tcp_connect() decodes every TCPC_ code
 * into errstr.  Both facts cost an afternoon on V8 and are recorded at length
 * in nafsmnt.c; this file just calls them.  tcpconfig must already be running
 * or the connect blocks forever with no diagnostic.
 */
Rfile *
fsinit(argc, argv)
int argc;
char **argv;
{
	struct tcpuser tu;
	in_addr faddr;
	char ver[32];
	register int port;
	char *host;

	if (argc < 3) {
		rflog("usage: 9pfs host port\n");
		return (NULL);
	}
	host = argv[1];
	port = atoi(argv[2]);
	/*
	 * THE ID MAPS, AND NOTHING WORKS WITHOUT THEM.  libnetb translates
	 * user and group ids between this process and the client BY NAME,
	 * through two tables built from a password and a group file, and
	 * everything that consults them -- the ownership it reports, and every
	 * permission check in perm.c -- answers RFNOID (-1) while they are
	 * null.  Measured, on the machine: `ls -l' showed every file owned by
	 * `-1', and a write to a read/WRITE share came back `Permission
	 * denied', because the owner check could not match and the mode fell
	 * through to `other'.  zarf.c:101 does exactly this and it is not
	 * optional.
	 */
	rfuidmap = rfmkidmap("/etc/passwd", (Namemap *)0);
	rfgidmap = rfmkidmap("/etc/group", (Namemap *)0);
	if ((faddr = in_address(host)) == 0) {
		rflog("9pfs: bad address %s\n", host);
		return (NULL);
	}
	if ((srvfd = tcp_sock()) < 0) {
		rflog("9pfs: no free /dev/tcp?? (odd minors only)\n");
		return (NULL);
	}
	tu.laddr = INADDR_ANY;
	tu.faddr = faddr;
	tu.lport = 0;
	tu.fport = port;
	tu.param = 0;
	errstr = "";
	if (tcp_connect(srvfd, &tu) < 0) {
		rflog("9pfs: connect %s %d: %s\n", host, port, errstr);
		return (NULL);
	}
	if ((sbuf = (unsigned char *)malloc((int)msize)) == NULL
	 || (rbuf = (unsigned char *)malloc((int)msize)) == NULL) {
		rflog("9pfs: no room for %ld-byte buffers\n", msize);
		return (NULL);
	}
	/*
	 * Tversion.  The reply may shrink msize but never grow it, and a
	 * version we did not offer comes back as the string "unknown".
	 */
	pstart(Tversion);
	p32(msize);
	pstr(N9VERSION);
	if (rpc(Rversion) < 0)
		return (NULL);
	msize = g32();
	gstr(ver, sizeof(ver));
	if (strcmp(ver, N9VERSION) != 0) {
		rflog("9pfs: server speaks %s, not %s\n", ver, N9VERSION);
		return (NULL);
	}
	if (msize < 512 || msize > N9MSIZE) {
		rflog("9pfs: silly msize %ld\n", msize);
		return (NULL);
	}
	/*
	 * Tattach.  No authentication: afid is NOFID and the server is expected
	 * to say so rather than demand a ticket.  The share is on the host's
	 * loopback and reachable only from inside this machine's simulated
	 * network, which is the guard that actually holds.
	 */
	fidmap[0] = 1;
	pstart(Tattach);
	p32(0L);
	p32(N9NOFID);
	pstr("root");
	pstr("");
	p32(0L);			/* .u n_uname */
	if (rpc(Rattach) < 0)
		return (NULL);
	if ((rootf = mkfile(0L, "/")) == NULL)
		return (NULL);
	rflog("9pfs: %s %d, msize %ld\n", host, port, msize);
	return (rootf);
}

/*
 * fswalk: one component.  See the header comment -- NULL with fserrno zero is
 * the `popped out of root' signal and libnetb turns it into netb's NBROOT.
 */
Rfile *
fswalk(df, name)
Rfile *df;
char *name;
{
	register Rfile *f;
	register long nf;

	if (rfdebug)
		rflog("walk %ld '%s'\n", df->ino, name);
	if (df == rootf && strcmp(name, "..") == 0) {
		fserrno = 0;		/* pseudo-error: out of the root */
		return (NULL);
	}
	if (name[0] == 0 || strcmp(name, ".") == 0) {
		/*
		 * libnetb de-duplicates on (ino,dev), so returning a fresh
		 * Rfile for "." is correct and costs one fid it will clunk.
		 */
		name = ".";
	}
	if ((nf = fidalloc()) < 0)
		return (NULL);
	pstart(Twalk);
	p32(fsp(df)->fid);
	p32(nf);
	p16(1);
	pstr(name);
	if (rpc(Rwalk) < 0) {
		fidfree(nf);
		return (NULL);
	}
	/*
	 * A Twalk that matched fewer names than it was given is not an error at
	 * the protocol level; with one name, nwqid of 0 means it did not exist
	 * and no fid was established.
	 */
	if (g16() != 1) {
		fidfree(nf);
		fserrno = RFENOENT;
		return (NULL);
	}
	if ((f = mkfile(nf, name)) == NULL) {
		n9clunk(nf);
		fidfree(nf);
		return (NULL);
	}
	return (f);
}

Rfile *
fscreate(df, name, mode, uid, gid)
Rfile *df;
char *name;
int mode;
int uid, gid;
{
	register Rfile *f;
	register long nf;

	if (rfdebug)
		rflog("create %ld '%s' %o\n", df->ino, name, mode);
	/*
	 * Tcreate CONSUMES the fid it is given: the directory fid becomes the
	 * new file.  So clone first, or the directory's own handle is lost.
	 */
	if ((nf = n9clone(fsp(df)->fid)) < 0)
		return (NULL);
	pstart(Tcreate);
	p32(nf);
	pstr(name);
	p32((long)(mode & 0777));
	p8(N9ORDWR);
	pstr("");			/* .u extension */
	if (rpc(Rcreate) < 0) {
		n9clunk(nf);
		fidfree(nf);
		return (NULL);
	}
	/*
	 * The fid is now open, which means it cannot be walked -- so it becomes
	 * the I/O fid and a fresh control fid is walked to the same file from
	 * the directory.  One extra round trip per create, and the alternative
	 * is a file that can be written but never stat'd.
	 */
	if ((f = fswalk(df, name)) == NULL) {
		n9clunk(nf);
		fidfree(nf);
		return (NULL);
	}
	fsp(f)->iofid = nf;
	fsp(f)->omode = N9ORDWR;
	return (f);
}

int
fsmkdir(df, name, mode, uid, gid)
Rfile *df;
char *name;
int mode;
int uid, gid;
{
	register long nf;

	if ((nf = n9clone(fsp(df)->fid)) < 0)
		return (-1);
	pstart(Tcreate);
	p32(nf);
	pstr(name);
	p32(N9DMDIR | (long)(mode & 0777));
	p8(N9OREAD);
	pstr("");
	if (rpc(Rcreate) < 0) {
		n9clunk(nf);
		fidfree(nf);
		return (-1);
	}
	n9clunk(nf);
	fidfree(nf);
	return (0);
}

/*
 * Tremove serves for both, and it clunks the fid whether or not it succeeded.
 */
static
n9rm(df, name)
Rfile *df;
char *name;
{
	register long nf;

	if ((nf = fidalloc()) < 0)
		return (-1);
	pstart(Twalk);
	p32(fsp(df)->fid);
	p32(nf);
	p16(1);
	pstr(name);
	if (rpc(Rwalk) < 0) {
		fidfree(nf);
		return (-1);
	}
	if (g16() != 1) {
		fidfree(nf);
		fserrno = RFENOENT;
		return (-1);
	}
	pstart(Tremove);
	p32(nf);
	if (rpc(Rremove) < 0) {
		fidfree(nf);		/* gone regardless: Tremove clunks it */
		return (-1);
	}
	fidfree(nf);
	return (0);
}

int
fsrmdir(df, name)
Rfile *df;
char *name;
{
	return (n9rm(df, name));
}

int
fsdelete(df, name)
Rfile *df;
char *name;
{
	return (n9rm(df, name));
}

/*
 * 9P2000.u HAS NO LINK.  Tlink is 9P2000.L's, and .L is not what this speaks
 * (tools/9pfsd.py's header states why).  rf.h's own comment on RFEXDEV is
 * `link across devices (or just not allowed)', so this is the answer it
 * expects rather than an improvisation.
 */
int
fslink(df, name, f)
Rfile *df;
char *name;
Rfile *f;
{
	fserrno = RFEXDEV;
	return (-1);
}

int
fsdone(f)
register Rfile *f;
{
	if (f == rootf)			/* libnetb never discards the root */
		return (0);
	if (fsp(f)->iofid >= 0) {
		n9clunk(fsp(f)->iofid);
		fidfree(fsp(f)->iofid);
	}
	n9clunk(fsp(f)->fid);
	fidfree(fsp(f)->fid);
	if (fsp(f)->name != NULL)
		free(fsp(f)->name);
	free(f->fs);
	free((char *)f);
	return (0);
}

int
fsstat(f)
register Rfile *f;
{
	N9dir d;

	pstart(Tstat);
	p32(fsp(f)->fid);
	if (rpc(Rstat) < 0)
		return (-1);
	g16();
	if (gdir(&d) < 0) {
		fserrno = RFEIO;
		return (-1);
	}
	/*
	 * THE IDENTITY CHECK IS zarf's AND IT IS WORTH KEEPING.  A held handle
	 * whose name was replaced underneath us would otherwise report the new
	 * file's attributes against the old one's inode number, and nothing
	 * upstream would notice.
	 */
	if (fsp(f)->qpath != 0 && d.qpath != fsp(f)->qpath) {
		rflog("9pfs: fid %ld is a different file now\n", fsp(f)->fid);
		fserrno = RFEINVAL;
		return (-1);
	}
	unpack(f, &d);
	return (0);
}

/*
 * fsupdate: copy the attributes of nf onto f.  One Twstat, with `do not touch'
 * in every field we are not changing -- a zero there would mean midnight 1970
 * or an empty file, so the distinction is not cosmetic.
 *
 * uid and gid are accepted and ignored: the share presents every file as one
 * owner, which is 9pfsd's -u/-g, and pretending otherwise would report a
 * change that did not happen.
 */
int
fsupdate(f, nf)
register Rfile *f;
register Rfile *nf;
{
	int i;

	/*
	 * A Twstat THAT WOULD CHANGE NOTHING IS NOT SENT AT ALL, and that is
	 * not an optimisation -- it is the difference between a read-only share
	 * working and not.  V10 releases an inode with
	 *
	 *	if (ip->i_flag & ICHG) nbupdat(ip, &time, &time, 0)
	 *
	 * (fs/netb.c:48), so closing a file or a directory sends an update as a
	 * matter of course.  libnetb then fills in the CURRENT values for
	 * anything the message left at zero -- funcs.c:494-507 -- so what
	 * arrives here is usually every attribute exactly as we last reported
	 * it.  Sending that on as a Twstat asks a read-only server to write,
	 * which answers EROFS, which n9err maps to RFEACCES, which comes back
	 * to the guest as `Permission denied' -- reported against whatever
	 * syscall happened to do the iput.  Measured: with this unconditional,
	 * `ls' worked and `ls -l' said `ls: /n/9p: Permission denied', because
	 * -l is the flag that makes ls close what it opened.
	 *
	 * AND THE MODE COMPARISON IS MASKED, which is the whole of the second
	 * half of that bug.  What arrives is nbtofsmode(SUP_MODE), and
	 * funcs.c:59 defines that as `(m)&07777' -- permission bits only --
	 * while f->mode is what unpack() built, a full Unix mode with IFDIR or
	 * IFREG in it.  Comparing the two unmasked makes 0755 and 0040755
	 * differ on every single update, so the test above never fired and the
	 * spurious Twstat went out anyway: `ls -l' then worked and `ls -li'
	 * said `Permission denied', which is as arbitrary as it sounds.
	 */
	if ((nf->mode & 07777) == (f->mode & 07777)
	 && nf->ta == f->ta && nf->tm == f->tm && nf->size == f->size)
		return (0);

	pstart(Twstat);
	p32(fsp(f)->fid);
	/*
	 * A Twstat carries the entry twice over: the message has a 2-byte count
	 * and the entry inside it has its own.  Both are filled in after the
	 * body is built, because neither is known until then.
	 */
	p16(0);
	p16(0);
	i = sp;				/* first byte of the entry proper */
	p16(N9NOTOUCH2);		/* type */
	p32(N9NOTOUCH4);		/* dev */
	p8(0xFF);			/* qid.type */
	p32(N9NOTOUCH4);		/* qid.version */
	p32(N9NOTOUCH4);		/* qid.path, both halves */
	p32(N9NOTOUCH4);
	/*
	 * MODE AND THE TIMES ARE ALWAYS SENT, AND THE LENGTH ALMOST NEVER IS.
	 * That is not a guess; it is read off the library.  funcs.c:494 fills
	 * na.mode from the request unconditionally (netb's nbupdat always puts
	 * ip->i_mode on the wire, so 0 is a real chmod 000 and cannot serve as
	 * a sentinel), substitutes the current values for a zero atime or
	 * mtime itself at :498-504, and then sets `na.size = f->size' at :507
	 * with the comment `not set here'.
	 *
	 * Truncation arrives through the same callback from a different place:
	 * funcs.c:661 is `newf = *f; newf.size = 0; fsupdate(f, &newf)'.  So
	 * a size that DIFFERS from the one we last reported is a truncate and
	 * a size that matches is an update that must leave the file alone --
	 * sending the length either way would re-truncate a file that grew
	 * under a held handle.
	 */
	p32(nf->mode == f->mode ? N9NOTOUCH4 : (long)(nf->mode & 07777));
	p32(nf->ta == f->ta ? N9NOTOUCH4 : nf->ta);
	p32(nf->tm == f->tm ? N9NOTOUCH4 : nf->tm);
	if (nf->size != f->size && nf->type != RFTDIR)
		p64(nf->size);
	else {
		p32(N9NOTOUCH4);
		p32(N9NOTOUCH4);
	}
	pstr("");			/* name: no rename */
	pstr("");			/* uid  */
	pstr("");			/* gid  */
	pstr("");			/* muid */
	pstr("");			/* .u extension */
	p32(N9NOTOUCH4);		/* .u n_uid */
	p32(N9NOTOUCH4);		/* .u n_gid */
	p32(N9NOTOUCH4);		/* .u n_muid */
	sbuf[i-2] = sp - i;
	sbuf[i-1] = (sp - i) >> 8;
	sbuf[i-4] = sp - i + 2;
	sbuf[i-3] = (sp - i + 2) >> 8;
	if (rpc(Rwstat) < 0)
		return (-1);
	return (0);
}

int
fsread(f, off, buf, len)
register Rfile *f;
long off;
char *buf;
int len;
{
	register int n;

	if (n9io(f, N9OREAD) < 0)
		return (-1);
	if (len > msize - N9IOHDR)
		len = msize - N9IOHDR;
	pstart(Tread);
	p32(fsp(f)->iofid);
	p64(off);
	p32((long)len);
	if (rpc(Rread) < 0)
		return (-1);
	n = (int)g32();
	if (n < 0 || rp + n > rlen) {
		fserrno = RFEIO;
		return (-1);
	}
	n9copy(buf, (char *)rbuf + rp, n);
	return (n);
}

int
fswrite(f, off, buf, len)
register Rfile *f;
long off;
char *buf;
int len;
{
	register int n;

	if (n9io(f, N9ORDWR) < 0)
		return (-1);
	if (len > msize - N9IOHDR)
		len = msize - N9IOHDR;
	pstart(Twrite);
	p32(fsp(f)->iofid);
	p64(off);
	p32((long)len);
	n9copy((char *)sbuf + sp, buf, len);
	sp += len;
	if (rpc(Rwrite) < 0)
		return (-1);
	n = (int)g32();
	if (off + n > f->size)
		f->size = off + n;
	return (n);
}

/*
 * fsdirread: hand back directory entries IN THE FORMAT dirread(2) DEFINES,
 * which is text and not `struct direct'.  Each record is
 *
 *	nnnn TAB name NUL
 *
 * with nnnn the i-number in decimal ascii, and the return value is the number
 * of bytes used.  netfs/serv/libdir.c says so in its header comment and
 * fs/fs.c:634 is the kernel proving it -- fsdirread() there converts d_ino
 * digit by digit into a scratch buffer, writes a tab, copies the name and
 * appends a NUL, for every slot in the directory block.
 *
 * THIS COST A RUN AND IS WORTH THE PARAGRAPH.  The first version of this
 * function wrote binary `struct direct' records, on the assumption that a
 * directory read returns what a directory contains.  It does not: the whole
 * point of V10's dirread(2) is that the kernel converts, so a client never
 * sees an on-disk layout.  Everything worked -- the mount came up, cat read
 * files through it, the server logged correct Twalk/Topen/Tread traffic -- and
 * `ls' printed NOTHING, because ls hides `.' and `..' and those two were the
 * only records it could parse.  A wrong format here is invisible from the
 * server side and looks like an empty directory.
 *
 * A 9P directory read returns machine-independent stat entries and no dot
 * names at all: `.' and `..' are a walk's business there, not a read's.  V10
 * expects them, because readdir(3) on a real directory returns them and pwd
 * identifies a parent by i-number, so they are synthesised at offset zero --
 * and `..' costs one extra walk and stat to get the parent's real i-number,
 * which is what pwd is actually looking at.
 *
 * THE OFFSET IS OURS TO DEFINE.  libnetb hands back whatever *offp we set --
 * funcs.c:591 turns it into a delta from the requested offset and the kernel
 * adds that to u_offset -- and libdir.c's own comment says to leave it "set to
 * something we'll want to use next time".  So:
 *
 *	off == 0	the two dot records, then 9P entries from 9P offset 0
 *	off != 0	9P entries from 9P offset (off - 1)
 *
 * and we return 1 + the 9P offset we stopped at.  The bias is what keeps zero
 * meaning `the very beginning' for both sides at once.  9P offsets must be
 * ones the server handed back, so we stop on an entry boundary and never
 * compute one: an entry that will not fit is un-read by rewinding the cursor.
 */
int
fsdirread(f, off, buf, len, offp)
register Rfile *f;
long off;
char *buf;
int len;
long *offp;
{
	N9dir d;
	char *p;			/* not register: putent takes its address */
	long n9off;
	int n, avail, entry, left;

	if (n9io(f, N9OREAD) < 0)
		return (-1);
	p = buf;
	left = len;
	n9off = off ? off - 1 : 0;
	if (off == 0) {
		Rfile *up;
		long upino;

		upino = f->ino;
		if (f != rootf && (up = fswalk(f, "..")) != NULL) {
			upino = up->ino;
			fsdone(up);
		}
		fserrno = 0;		/* fswalk may have set it; not our error */
		if (putent(&p, &left, f->ino, ".") < 0
		 || putent(&p, &left, upino, "..") < 0) {
			fserrno = RFENOSPC;
			return (-1);
		}
	}
	avail = msize - N9IOHDR;
	pstart(Tread);
	p32(fsp(f)->iofid);
	p64(n9off);
	p32((long)avail);
	if (rpc(Rread) < 0)
		return (-1);
	n = (int)g32();
	if (n < 0 || rp + n > rlen) {
		fserrno = RFEIO;
		return (-1);
	}
	/*
	 * CLAMP rlen TO THIS REPLY'S DATA, deliberately: gdir() bounds every
	 * field against it, so this is what stops a short final entry being
	 * parsed out of whatever the previous reply left in the buffer.
	 */
	rlen = rp + n;
	while (rp < rlen) {
		entry = rp;
		if (gdir(&d) < 0)
			break;
		if (putent(&p, &left, d.qpath, d.name) < 0) {
			rp = entry;		/* un-read it */
			break;
		}
		n9off += rp - entry;
	}
	if (p == buf && rp < rlen) {	/* not even one record fitted */
		fserrno = RFENOSPC;
		return (-1);
	}
	*offp = n9off + 1;
	return (p - buf);
}
