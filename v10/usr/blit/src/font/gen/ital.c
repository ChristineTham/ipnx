#include <stdio.h>
char *temp = ".ital_temp";

FILE *
getopen(s)
char *s;
{
	FILE *f;
	if ((f = fopen(s,"r")) == (FILE *) NULL) {
		fprintf(stderr,"can't find %s\n",s);
		exit(0);
	}
	return(f);
}

pass(f)
FILE *f;
{
	register c;
	putchar(c = getc(f));
	return(c);
}

main(argc,argv)
int argc;
char *argv[];
{
	register c,i,n1,n2;
	FILE *ref,*inf;
	if (argc != 3) {
		fprintf(stderr,"usage: ital f.n fI.n\n");
		return(0);
	}
	freopen(temp,"w",stdout);
	ref = getopen(argv[1]);
	inf = getopen(argv[2]);
	c = getc(ref);
	n1 = (c<<8) | (getc(ref)&0377);
	c = pass(inf);
	n2 = (c<<8) | (pass(inf)&0377);
	if (n1 != n2) {
		fprintf(stderr,"%d vs %d chars?\n",n1,n2);
		return(0);
	}
	for (i = 0; i < 6; i++) {
		getc(ref);		/* skip over ref */
		pass(inf);		/* pass inf */
	}
	do {
		for (i = 0; i < 5; i++) {
			getc(ref);
			pass(inf);
		}
		getc(inf);		/* replace inf width */
		pass(ref);		/* by ref's */
	} while (--n2 > 0);
	while ((c = getc(inf)) != EOF)
		putchar(c);
	fclose(ref);
	fclose(inf);
	fclose(stdout);
	unlink(argv[2]);
	link(temp,argv[2]);
	unlink(temp);
}
