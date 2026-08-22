#include	<stdio.h>
#include	"sizes.h"

char *proto[128] =
{
 "C113",	/* an arbitarry narrow character to fill char zero */
 "C112", "C085", "C054", "C051", "C052", "C053", "C056", "C055", "C093", "C050",
 "C092", "C057", "C026", "C027", "C035", "C029", "C030", "C031", "C032", "C045",
 "C034", "C036", "C037", "C038", "C039", "C040", "C041", "C028", "C042", "C043",
 "C044", "C048", "C046", "C047", "C033", "C049", "C063", "C108", "C006", "C129",
 "C130", "C131", "C109", "C076", "C083", "C075", "C104", "C106", "C086", "C058",
 "C117", "C003", "C066", "C080", "C107", "C101", "C105", "C017", "C118", "C018",
 "C096", "C009", "C020", "C010", "C001", "C097", "C111", "C002", "C064", "C062",
 "C061", "C067", "C126", "C015", "C065", "C004", "C071", "C008", "C098", "C069",
 "C099", "C091", "C103", "C121", "C115", "C113", "C025", "C123", "C119", "C016",
 "C059", "C100", "C060", "C132", "C019", "C077", "C072", "C058", "C014", "C068",
 "C122", "C116", "C114", "C011", "C024", "C124", "C128", "C120", "C102", "C094",
 "C078", "C095", "C021", "C090", "C127", "C012", "C023", "C070", "C110", "C117",
 "C133", "C081", "C082",
};

main(argc, argv)
	char **argv;
{
	register i, x, j;
	int a, b;
	struct frac sizes[20];

	for(argv++, argc--, i = 0; i < argc; i++)
	{
		x = atoi(argv[i]);
		if((x < 0) || (x >= (sizeof frac / sizeof frac[0])) || (frac[x].b == 0))
			sizes[i].a = x, sizes[i].b = 311;
		else
			sizes[i] = frac[x];
	}

	for(i = 0; i < 128; i++)
	{
		if(proto[i])
		{
			if((x = open(proto[i], 0)) == -1)
			{
				fprintf(stderr, "Warning: can't open %s\n", proto[i]);
				for(j = 0; j < argc; j++)
					printf("f %d s ", j);
			}
			else
			{
				close(x);
				printf("merg %s", proto[i]);
				for(j = 0; j < argc; j++)
					printf(" f %d p %d %d r", j, sizes[j].a, sizes[j].b);
			}
		}
		else
		{
			for(j = 0; j < argc; j++)
				printf("f %d s ", j);
		}
		printf("\n");
	}

	for(j = 0; j < argc; j++)
		printf("f %d w font.%s ", j, argv[j]);
	printf("\nq\n");
}
