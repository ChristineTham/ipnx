/*
 * Two processes writing one file through one descriptor: does every byte
 * survive?  A V10 program; run it on the machine.
 *
 *	cc -o /tmp/sw /n/macos/tools/v10/sharedwrite.c && /tmp/sw
 *
 * The child writes NCHUNK chunks of CHUNK a's.  Meanwhile the parent writes
 * NMARK four-byte markers, spinning between them so that it is runnable
 * whenever the child sleeps inside write.  Both share one file table entry,
 * so the file must end up holding every a, every marker and no NUL, and the
 * exit status is 0 only then.
 *
 * On the tape's kernel it failed three runs of three, each time the same way:
 * 4 a's short and 4 NULs.  os/sys2.c read the shared f_offset before plock,
 * so a marker written while the child slept in writei took the child's stale
 * offset, waited for the lock and landed on the child's first four bytes; its
 * own offset update then added four to the end of the child's chunk, so the
 * next chunk began four bytes on and left the hole.  tcpmgr's log tore the
 * same way at boot (docs/v10-gaps.md, fifth pass).
 */
#define CHUNK	65536
#define NCHUNK	64
#define NMARK	2000
#define SPIN	2000
#define OUT	"/usr/tmp/sharedwrite"

char	big[CHUNK];
char	buf[CHUNK];

main()
{
	int fd, p[2], i, n;
	long a = 0, nul = 0, mark = 0, other = 0, size = 0;
	char c;

	if ((fd = creat(OUT, 0666)) < 0) {
		perror(OUT);
		exit(2);
	}
	for (i = 0; i < CHUNK; i++)
		big[i] = 'a';
	pipe(p);
	if (fork() == 0) {
		write(p[1], "g", 1);
		for (i = 0; i < NCHUNK; i++)
			write(fd, big, CHUNK);
		exit(0);
	}
	read(p[0], &c, 1);
	for (i = 0; i < NMARK; i++) {
		for (n = 0; n < SPIN; n++)
			;
		write(fd, "XYZ\n", 4);
	}
	wait((int *)0);
	close(fd);
	fd = open(OUT, 0);
	while ((n = read(fd, buf, sizeof buf)) > 0)
		for (i = 0; i < n; i++, size++)
			switch (buf[i]) {
			case 'a':	a++; break;
			case 0:		nul++; break;
			case 'X':	mark++; break;
			case 'Y': case 'Z': case '\n':	break;
			default:	other++;
			}
	close(fd);
	unlink(OUT);
	printf("%ld bytes: %ld of %ld a, %ld of %d markers, %ld NUL, %ld other\n",
		size, a, (long)CHUNK*NCHUNK, mark, NMARK, nul, other);
	exit(nul || other || a != (long)CHUNK*NCHUNK || mark != NMARK);
}
