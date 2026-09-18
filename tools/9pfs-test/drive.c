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

struct direct16 { unsigned short d_ino; char d_name[14]; };

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

	/* directory read: dots synthesised, then real entries */
	{
		int sawdot = 0, sawdotdot = 0, sawhello = 0, sawsub = 0, total = 0;
		struct direct16 *de;
		off = 0;
		for (i = 0; i < 40; i++) {
			n = fsdirread(root, off, buf, sizeof buf, &off);
			if (n <= 0) break;
			for (de = (struct direct16 *)buf; (char *)de < buf + n; de++) {
				char nb[15];
				memcpy(nb, de->d_name, 14); nb[14] = 0;
				total++;
				if (strcmp(nb, ".") == 0) sawdot = 1;
				else if (strcmp(nb, "..") == 0) sawdotdot = 1;
				else if (strcmp(nb, "hello") == 0) sawhello = 1;
				else if (strcmp(nb, "sub") == 0) sawsub = 1;
			}
		}
		ck("dirread synthesises '.'", sawdot, NULL);
		ck("dirread synthesises '..'", sawdotdot, NULL);
		ck("dirread lists hello", sawhello, NULL);
		ck("dirread lists sub", sawsub, NULL);
		ck("dirread terminates", i < 40, NULL);
		ck("dirread entry count", total >= 6, NULL);
	}

	/* a subdirectory, and '..' inside it is the parent's ino */
	d = fswalk(root, "sub");
	ck("fswalk sub", d != NULL && d->type == RFTDIR, NULL);
	if (d) {
		struct direct16 *de;
		int updot = -1;
		off = 0;
		n = fsdirread(d, off, buf, sizeof buf, &off);
		ck("sub dirread returns data", n > 0, NULL);
		for (de = (struct direct16 *)buf; (char *)de < buf + n; de++) {
			char nb[15];
			memcpy(nb, de->d_name, 14); nb[14] = 0;
			if (strcmp(nb, "..") == 0) updot = de->d_ino;
		}
		ck("'..' in a subdirectory is the parent's ino", updot == (int)root->ino, NULL);
		f = fswalk(d, "deep");
		ck("walk two deep", f != NULL && f->size == 3000, NULL);
		if (f) fsdone(f);
		fsdone(d);
	}

	/* link is not in 9P2000.u */
	fserrno = 0;
	ck("fslink refuses with EXDEV", fslink(root, "x", root) < 0 && fserrno == RFEXDEV, NULL);

	/* read-only share: a create must be refused */
	if (!rw) {
		fserrno = 0;
		f = fscreate(root, "nope", 0644, 0, 0);
		ck("fscreate refused on a read-only share", f == NULL, NULL);
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
