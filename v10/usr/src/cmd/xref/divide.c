divide(np, base)
long *np;
{	/* ipnx divide -- see PATCHES.md */
	int r = *np % base;
	*np /= base;
	return r;
}
