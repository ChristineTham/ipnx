extern jerq;

label(s)
char *s;
{
	int i;

	for(i=0; s[i++]; )
		;
	write(jerq, s, i);
}
