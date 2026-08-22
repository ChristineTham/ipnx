#ifndef	JERQFONT
#define	JERQFONT	"/usr/jerq/font"
#endif	JERQFONT

char tab[] = "X\\-\055dg\001em\002en\003fi\004fl\005hy\006sc\007";

main()
{
	int fd;
	char *f;
	char buf[256];

	tab[0] =  strlen(tab)/3;
	sprintf(buf, "%s/IMAP", JERQFONT);
	if((fd = creat(f = buf, 0664)) == -1)
	{
		perror(f);
		exit(1);
	}
	write(fd, tab, sizeof tab);
}
