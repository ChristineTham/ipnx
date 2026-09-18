/*
 * HARNESS: drive 9pfs.c's rf.h callbacks against a real tools/9pfsd.py.
 * Stubs libnetb (fserrno/rfuid/rfgid/rfdebug/rflog) and V10's libin
 * (tcp_sock/tcp_connect/in_address).  Everything else is the shipping file.
 */
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <rf.h>

int fserrno;
int rfdebug;
int rfuid = 0, rfgid = 0;
char *rfclient = "";
char *errstr = "";
Idmap *rfuidmap, *rfgidmap;
int rfotherdeny;

int rflog(char *f, ...) { return 0; }

/*
 * libnetb builds these from /etc/passwd and /etc/group on the guest and uses
 * them for every permission check.  None of that machinery is under test here
 * -- this harness calls the callbacks directly, so nothing consults a map --
 * so the stub records that it was called and returns nothing.
 */
int rfmkidmap_calls;
Idmap *rfmkidmap(char *file, Namemap *ex) { rfmkidmap_calls++; return (Idmap *)0; }

typedef unsigned long in_addr_t9;
struct tcpuser { int code; unsigned short lport, fport; unsigned long laddr, faddr; int param; };

static unsigned long g_faddr;
unsigned long in_address(char *h) { return (unsigned long)inet_addr(h); }
int tcp_sock(void) { return socket(AF_INET, SOCK_STREAM, 0); }
int tcp_connect(int fd, struct tcpuser *tu)
{
	struct sockaddr_in sa;
	memset(&sa, 0, sizeof sa);
	sa.sin_family = AF_INET;
	sa.sin_port = htons(tu->fport);
	sa.sin_addr.s_addr = (in_addr_t)tu->faddr;
	return connect(fd, (struct sockaddr *)&sa, sizeof sa);
}

/* ------------------------------------------------------------------ tests */
static int pass, fail;
static void ck(char *n, int c, char *d)
{
	if (c) { pass++; }
	else { fail++; printf("  FAIL %s %s\n", n, d ? d : ""); }
}

/*
 * dirread(2) records are TEXT: "nnnn\tname\0", the i-number in decimal ascii.
 * See netfs/serv/libdir.c's header and fs/fs.c:634.  Walk one record.
 */
static char *nextent(char *p, char *end, long *ino, char **name)
{
	char *tab;
	if (p >= end) return NULL;
	*ino = strtol(p, &tab, 10);
	if (*tab != '\t') return NULL;
	*name = tab + 1;
	p = *name + strlen(*name) + 1;
	return p;
}

int main(int argc, char **argv)
{
	Rfile *root, *f, *d, *up;
	char buf[8192];
	char nm[32];
	long off;
	int n, i, rw;
	char *av[3];

	rw = argc > 3 && strcmp(argv[3], "rw") == 0;
	av[0] = "9pfs"; av[1] = argv[1]; av[2] = argv[2];
	if ((root = fsinit(3, av)) == NULL) { printf("FAIL fsinit\n"); return 1; }
	ck("fsinit returns a directory", root->type == RFTDIR, NULL);
	ck("fsinit builds both id maps", rfmkidmap_calls == 2, NULL);
	ck("root ino is ROOTINO", root->ino == 2, NULL);

	/* walk + stat + read */
	fserrno = -1;
	f = fswalk(root, "hello");
	ck("fswalk hello", f != NULL, NULL);
	if (f) {
		ck("hello is a regular file", f->type == RFTREG, NULL);
		ck("hello size is 13", f->size == 13, NULL);
		ck("hello ino is dense", f->ino > 2 && f->ino < 65535, NULL);
		n = fsread(f, 0L, buf, sizeof buf);
		ck("fsread length", n == 13, NULL);
		ck("fsread content", n == 13 && memcmp(buf, "hello, world\n", 13) == 0, NULL);
		n = fsread(f, 7L, buf, 5);
		ck("fsread at an offset", n == 5 && memcmp(buf, "world", 5) == 0, NULL);
		ck("fsstat re-stats cleanly", fsstat(f) == 0, NULL);
		fsdone(f);
	}

	/* the 14-byte name that V10 would truncate */
	f = fswalk(root, "a_very_long_fi");
	ck("a truncated 14-byte name resolves", f != NULL, NULL);
	if (f) fsdone(f);

	/* .. out of the root: NULL with fserrno left at zero */
	fserrno = 12345;
	f = fswalk(root, "..");
	ck("'..' at the root returns NULL", f == NULL, NULL);
	ck("'..' at the root leaves fserrno 0 (popped out)", fserrno == 0, NULL);

	/* a missing file must set fserrno */
	fserrno = 0;
	f = fswalk(root, "nosuch");
	ck("missing file returns NULL", f == NULL, NULL);
	ck("missing file sets ENOENT", fserrno == RFENOENT, NULL);

	/* directory read: dots synthesised, then real entries, all as text */
	{
		int sawdot = 0, sawdotdot = 0, sawhello = 0, sawsub = 0;
		int sawlong = 0, total = 0, badino = 0;
		char *q, *end, *nm;
		long ino;
		off = 0;
		for (i = 0; i < 40; i++) {
			n = fsdirread(root, off, buf, sizeof buf, &off);
			if (n <= 0) break;
			q = buf; end = buf + n;
			while ((q = nextent(q, end, &ino, &nm)) != NULL) {
				total++;
				if (ino <= 0) badino = 1;
				if (strcmp(nm, ".") == 0) sawdot = 1;
				else if (strcmp(nm, "..") == 0) sawdotdot = 1;
				else if (strcmp(nm, "hello") == 0) sawhello = 1;
				else if (strcmp(nm, "sub") == 0) sawsub = 1;
				else if (strcmp(nm, "a_very_long_filename") == 0) sawlong = 1;
			}
		}
		ck("dirread synthesises '.'", sawdot, NULL);
		ck("dirread synthesises '..'", sawdotdot, NULL);
		ck("dirread lists hello", sawhello, NULL);
		ck("dirread lists sub", sawsub, NULL);
		ck("dirread gives FULL names, not 14 bytes", sawlong, NULL);
		ck("every record parses as nnnn TAB name NUL", total >= 6, NULL);
		ck("no zero i-numbers", !badino, NULL);
		ck("dirread terminates", i < 40, NULL);
	}

	/* a subdirectory, and '..' inside it is the parent's ino */
	d = fswalk(root, "sub");
	ck("fswalk sub", d != NULL && d->type == RFTDIR, NULL);
	if (d) {
		long updot = -1, ino;
		char *q, *end, *nm;
		off = 0;
		n = fsdirread(d, off, buf, sizeof buf, &off);
		ck("sub dirread returns data", n > 0, NULL);
		q = buf; end = buf + n;
		while ((q = nextent(q, end, &ino, &nm)) != NULL)
			if (strcmp(nm, "..") == 0) updot = ino;
		ck("'..' in a subdirectory is the parent's ino", updot == root->ino, NULL);
		f = fswalk(d, "deep");
		ck("walk two deep", f != NULL && f->size == 3000, NULL);
		if (f) fsdone(f);
		fsdone(d);
	}

	/* A short buffer must stop on a record boundary, never split one. */
	{
		char small[64];
		char *q, *end, *nm;
		long ino, o2 = 0;
		int rounds = 0, seen = 0, ok = 1;
		while (rounds++ < 40) {
			n = fsdirread(root, o2, small, sizeof small, &o2);
			if (n <= 0) break;
			if (n > (int)sizeof small) { ok = 0; break; }
			q = small; end = small + n;
			while ((q = nextent(q, end, &ino, &nm)) != NULL) seen++;
			if (q == NULL && small[n-1] != 0) ok = 0;
		}
		ck("a 64-byte buffer still lists everything", seen >= 6, NULL);
		ck("records are never split across replies", ok, NULL);
		ck("short-buffer dirread terminates", rounds < 40, NULL);
	}

	/* link is not in 9P2000.u */
	fserrno = 0;
	ck("fslink refuses with EXDEV", fslink(root, "x", root) < 0 && fserrno == RFEXDEV, NULL);

	/* read-only share: a create must be refused */
	if (!rw) {
		Rfile attr;
		fserrno = 0;
		f = fscreate(root, "nope", 0644, 0, 0);
		ck("fscreate refused on a read-only share", f == NULL, NULL);
		/*
		 * A NO-OP UPDATE MUST SUCCEED ON A READ-ONLY SHARE.  V10 sends
		 * one whenever it releases an inode (fs/netb.c:48), libnetb
		 * fills the unchanged fields with the current values, and
		 * forwarding that as a Twstat asks a read-only server to write
		 * -- EROFS, mapped to RFEACCES, surfacing as `Permission
		 * denied'.  That is what `ls -l' hit on a real machine while
		 * plain `ls' worked.
		 */
		f = fswalk(root, "hello");
		ck("walk for the no-op update", f != NULL, NULL);
		if (f) {
			attr = *f;
			fserrno = 0;
			ck("a no-op update succeeds on a read-only share",
			   fsupdate(f, &attr) == 0, NULL);
			/*
			 * libnetb hands us nbtofsmode(SUP_MODE), which
			 * funcs.c:59 masks to 07777, while f->mode carries
			 * IFREG or IFDIR too.  Comparing them unmasked makes
			 * every update look like a chmod.
			 */
			attr = *f;
			attr.mode = f->mode & 07777;
			fserrno = 0;
			ck("a permission-bits-only update is still a no-op",
			   fsupdate(f, &attr) == 0, NULL);
			attr = *f;
			attr.mode = 0600;
			fserrno = 0;
			ck("a REAL chmod is still refused there",
			   fsupdate(f, &attr) < 0 && fserrno == RFEACCES, NULL);
			fsdone(f);
		}
	} else {
		Rfile attr;
		f = fscreate(root, "made", 0644, 0, 0);
		ck("fscreate", f != NULL, NULL);
		if (f) {
			n = fswrite(f, 0L, "written\n", 8);
			ck("fswrite count", n == 8, NULL);
			n = fsread(f, 0L, buf, sizeof buf);
			ck("fsread back after write", n == 8 && memcmp(buf, "written\n", 8) == 0, NULL);
			/* chmod via fsupdate: size equal => no truncate */
			attr = *f;
			attr.mode = 0600;
			ck("fsupdate chmod", fsupdate(f, &attr) == 0, NULL);
			ck("chmod took", fsstat(f) == 0 && (f->mode & 0777) == 0600, NULL);
			/* truncate via fsupdate: size differs */
			attr = *f;
			attr.size = 0;
			ck("fsupdate truncate", fsupdate(f, &attr) == 0, NULL);
			ck("truncate took", fsstat(f) == 0 && f->size == 0, NULL);
			fsdone(f);
		}
		ck("fsmkdir", fsmkdir(root, "adir", 0755, 0, 0) == 0, NULL);
		ck("fsrmdir", fsrmdir(root, "adir") == 0, NULL);
		ck("fsdelete", fsdelete(root, "made") == 0, NULL);
		fserrno = 0;
		ck("fsdelete of a missing name fails", fsdelete(root, "gone") < 0, NULL);
	}

	printf("%d passed, %d failed\n", pass, fail);
	return fail ? 1 : 0;
}
