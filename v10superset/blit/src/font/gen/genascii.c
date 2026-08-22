#include	<stdio.h>
#include	"sizes.h"

char *proto[128] =
{
	0,	"C088",	"C075",	"C076",	"C120",	"C121",	"C072",	"C087",
	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0,	0,	0,	0,	0,	0,	0,
	"C014",	"C069",	"S125",	"S022",	"C077",	"C079",	"C053",	"C073",
	"C070",	"C071",	"C086",	"S058",	"C065",	"C072",	"C064",	"C080",
	"C063",	"C054",	"C055",	"C056",	"C057",	"C058",	"C059",	"C060",
	"C061",	"C062",	"C066",	"C067",	"S074",	"S061",	"S073",	"C068",
	"S013",	"C027",	"C028",	"C029",	"C030",	"C031",	"C032",	"C033",
	"C034",	"C035",	"C036",	"C037",	"C038",	"C039",	"C040",	"C041",
	"C042",	"C043",	"C044",	"C045",	"C046",	"C047",	"C048",	"C049",
	"C050",	"C051",	"C052",	"C084",	"S079",	"C085",	"S005",	"S117",
	"C074",	"C001",	"C002",	"C003",	"C004",	"C005",	"C006",	"C007",
	"C008",	"C009",	"C010",	"C011",	"C012",	"C013",	"C014",	"C015",
	"C016",	"C017",	"C018",	"C019",	"C020",	"C021",	"C022",	"C023",
	"C024",	"C025",	"C026",	"S087",	"S089",	"S088",	"S007",	0,
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
					if(i == ' ')
						printf(" f %d p %d %d white", j, sizes[j].a, sizes[j].b);
					else
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
		printf("f %d en 32 ", j);
	printf("\n");
	for(j = 0; j < argc; j++)
		printf("f %d w font.%s\n", j, argv[j]);
	printf("q\n");
}
