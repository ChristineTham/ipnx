char *gets();
/*	@(#)flip.c	1.2	*/
#include <stdio.h>
#include <ctype.h>

main()
	{
	char line[BUFSIZ], *pl, *gets();

	while (pl = gets(line))
		{
		while (*pl != ':')
			++pl;
		*pl++ = '\0';
		while (isspace(*pl))
			++pl;
		printf("%s : %s\n", pl, line);
		}
	}
/* ipnx gets -- see PATCHES.md */
char *gets(s) char *s; {
	extern char *fgets();
	char *p;
	if (fgets(s, 1024, stdin) == 0) return 0;
	for (p = s; *p; p++) if (*p == 10) { *p = 0; break; }
	return s; }
