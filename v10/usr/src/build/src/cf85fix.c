/*
 * cf85fix -- work around three bugs in V8's cfront (<<cfront 7/04/85>>) so
 * that it can translate cfront 2.00: stage 1 of build/cfboot.
 *
 *	cpp -C ... | cf85fix -i | cfront +f... | cf85fix -o > x.i
 *
 * Each bug was found by a crash of the cfront 2.00 it built, and measured on
 * the 1985 translator's own output before it was worked around.
 *
 * -i, on cpp's output, before the 1985 translator sees it:
 *
 *   1. wraps every sizeof(...) in parentheses.  The 1985 parser groups
 *	everything after `sizeof(type)' left to right, ahead of any
 *	operator in front of it: n*sizeof(int)+2 comes out as n*6,
 *	sizeof(S)+n*2 as (16+n)*2, n-sizeof(S)-2 as n-14 and
 *	new char[n*sizeof(S)+1] as n*17 bytes.  (sizeof(S)) is right, and
 *	so are `sizeof x', sizeof(*p) and casts.  cfront 2.00's norm2.c
 *	sized its free-list chunks this way and overran them into malloc's
 *	next block.
 *
 *   2. moves a for-init with more than one declarator in front of its
 *	for.  `for (Pname nx, nn=n; nn; nn=nx)' loses every initialiser
 *	unless the for is the first thing in an inner block, so nn is
 *	whatever the stack held; classdef::dcl walked its base classes
 *	from garbage this way.  A declaration statement keeps them, and a
 *	for-init's names belong to the enclosing block in C++ 2.0, so
 *	`Pname nx, nn=n; for (; nn; nn=nx)' means the same thing.  Each
 *	move is reported on stderr; a for that does not follow ; { or }
 *	(the body of an if, say) is reported and left alone.  cfront 2.00
 *	has thirteen, all after ; or {.
 *
 * -o, on the translator's output, before cc:
 *
 *   3. rewrites ( * ea0 ) as ( ea0 ).  A reference parameter's default
 *	argument -- cfront.h's `const ea& = *ea0' -- is translated as
 *	( struct ea * ) ( * ea0 ), a cast of a struct to a pointer, which
 *	cc rejects; an explicit *ea0 argument comes out as ea0 already.
 *	The tokens can be split across lines and `# NNN' directives, so
 *	this matches tokens, not text.
 */
#include <stdio.h>

#define	MAX	(4*1024*1024)
char	b1[MAX], b2[MAX];
int	n1, n2;

int
ident(c)
	int c;
{
	return c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
		(c >= '0' && c <= '9');
}

/*
 * If b[i] starts a string or character literal, a comment, or a `#' line,
 * return the index just past it; otherwise return i.
 */
int
skiplit(b, i, n)
	char *b;
	int i, n;
{
	int q;

	if (b[i] == '"' || b[i] == '\'') {
		q = b[i++];
		while (i < n && b[i] != q && b[i] != '\n')
			i += b[i] == '\\' ? 2 : 1;
		return i < n ? i+1 : n;
	}
	if (b[i] == '/' && i+1 < n && b[i+1] == '*') {
		for (i += 2; i+1 < n && !(b[i] == '*' && b[i+1] == '/'); i++)
			;
		return i+2 <= n ? i+2 : n;
	}
	if ((b[i] == '/' && i+1 < n && b[i+1] == '/') ||
	    (b[i] == '#' && (i == 0 || b[i-1] == '\n'))) {
		while (i < n && b[i] != '\n')
			i++;
		return i;
	}
	return i;
}

int
space(c)
	int c;
{
	return c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r';
}

/* the next significant character at or after i, skipping comments */
int
skipws(b, i, n)
	char *b;
	int i, n;
{
	int j;

	for (;;) {
		while (i < n && space(b[i]))
			i++;
		if (i >= n || b[i] == '"' || b[i] == '\'')
			return i;
		if ((j = skiplit(b, i, n)) == i)
			return i;
		i = j;
	}
}

/* the end of the token starting at significant character i */
int
tokend(b, i, n)
	char *b;
	int i, n;
{
	int j;

	if (ident(b[i])) {
		while (i < n && ident(b[i]))
			i++;
		return i;
	}
	if ((j = skiplit(b, i, n)) != i)
		return j;
	return i+1;
}

int
word(b, i, j, s)
	char *b, *s;
	int i, j;
{
	while (i < j && *s && b[i] == *s)
		i++, s++;
	return i == j && *s == 0;
}

int
lineno(b, i)
	char *b;
	int i;
{
	int l = 1;

	while (--i >= 0)
		if (b[i] == '\n')
			l++;
	return l;
}

/* 1: (sizeof(...)) for sizeof(...); from b1 to b2 */
void
wrapsizeof()
{
	int i, j, depth = 0, sp = 0;
	int stk[512];

	n2 = 0;
	for (i = 0; i < n1; ) {
		if ((j = skiplit(b1, i, n1)) != i) {
			while (i < j)
				b2[n2++] = b1[i++];
			continue;
		}
		if (b1[i] == '(') {
			depth++;
			b2[n2++] = b1[i++];
			continue;
		}
		if (b1[i] == ')') {
			depth--;
			b2[n2++] = b1[i++];
			while (sp > 0 && stk[sp-1] == depth) {
				b2[n2++] = ')';
				sp--;
			}
			continue;
		}
		if (ident(b1[i]) && (i == 0 || !ident(b1[i-1]))) {
			j = tokend(b1, i, n1);
			if (word(b1, i, j, "sizeof") &&
			    b1[skipws(b1, j, n1)] == '(' && sp < 512) {
				b2[n2++] = '(';
				stk[sp++] = depth;
			}
			while (i < j)
				b2[n2++] = b1[i++];
			continue;
		}
		b2[n2++] = b1[i++];
	}
}

int
notdecl(b, i, j)
	char *b;
	int i, j;
{
	return word(b, i, j, "delete") || word(b, i, j, "new") ||
		word(b, i, j, "sizeof") || word(b, i, j, "this") ||
		word(b, i, j, "return");
}

/* 2: hoist multi-declarator for-inits; from b2 to b1 */
void
hoistfor()
{
	int i, j, k, s, e, t1, t1e, t2, depth, commas, prev = ';';

	n1 = 0;
	for (i = 0; i < n2; ) {
		if ((j = skiplit(b2, i, n2)) != i) {
			if (b2[i] == '"' || b2[i] == '\'')
				prev = b2[i];
			while (i < j)
				b1[n1++] = b2[i++];
			continue;
		}
		if (!ident(b2[i]) || (i > 0 && ident(b2[i-1]))) {
			if (!space(b2[i]))
				prev = b2[i];
			b1[n1++] = b2[i++];
			continue;
		}
		j = tokend(b2, i, n2);
		if (!word(b2, i, j, "for") || b2[k = skipws(b2, j, n2)] != '(') {
			prev = 'a';
			while (i < j)
				b1[n1++] = b2[i++];
			continue;
		}
		/* for ( INIT ; ... -- find INIT's extent and shape */
		s = k+1;
		t1 = skipws(b2, s, n2);
		t1e = tokend(b2, t1, n2);
		t2 = skipws(b2, t1e, n2);
		depth = 0;
		commas = 0;
		for (e = t1; e < n2; e = tokend(b2, e, n2), e = skipws(b2, e, n2)) {
			if (b2[e] == '(' || b2[e] == '[' || b2[e] == '{')
				depth++;
			else if (b2[e] == ')' || b2[e] == ']' || b2[e] == '}') {
				if (--depth < 0)
					break;
			} else if (depth == 0 && b2[e] == ';')
				break;
			else if (depth == 0 && b2[e] == ',')
				commas++;
		}
		if (e >= n2 || b2[e] != ';' || commas == 0 || !ident(b2[t1]) ||
		    notdecl(b2, t1, t1e) ||
		    !(ident(b2[t2]) || b2[t2] == '*' || b2[t2] == '&')) {
			prev = 'a';
			while (i < j)
				b1[n1++] = b2[i++];
			continue;
		}
		if (prev != ';' && prev != '{' && prev != '}') {
			fprintf(stderr, "cf85fix: line %d: for-init not moved: follows `%c'\n",
				lineno(b2, i), prev);
			prev = 'a';
			while (i < j)
				b1[n1++] = b2[i++];
			continue;
		}
		fprintf(stderr, "cf85fix: line %d: moved for-init `", lineno(b2, i));
		fwrite(b2+t1, 1, e-t1, stderr);
		fprintf(stderr, "'\n");
		/* INIT ; for ( ; ...   keeping every newline */
		for (k = s; k < e; k++)
			b1[n1++] = b2[k];
		b1[n1++] = ';';
		b1[n1++] = ' ';
		for (k = i; k < s; k++)
			b1[n1++] = b2[k] == '\n' ? '\n' : b2[k];
		i = e;
		prev = '(';
	}
}

/* 3: ( * ea0 ) -> ( ea0 ); from b1 to b2 */
void
fixea0()
{
	int i, j;

	n2 = 0;
	for (i = 0; i < n1; i++) {
		if (b1[i] == '(') {
			j = skipws(b1, i+1, n1);
			if (j < n1 && b1[j] == '*') {
				j = skipws(b1, j+1, n1);
				if (j+3 <= n1 && b1[j] == 'e' && b1[j+1] == 'a' &&
				    b1[j+2] == '0' && (j+3 == n1 || !ident(b1[j+3]))) {
					j = skipws(b1, j+3, n1);
					if (j < n1 && b1[j] == ')') {
						strcpy(b2+n2, "( ea0 )");
						n2 += 7;
						i = j;
						continue;
					}
				}
			}
		}
		b2[n2++] = b1[i];
	}
}

main(argc, argv)
	int argc;
	char **argv;
{
	int c;

	if (argc != 2 || argv[1][0] != '-' ||
	    (argv[1][1] != 'i' && argv[1][1] != 'o') || argv[1][2]) {
		fprintf(stderr, "usage: cf85fix -i|-o\n");
		exit(2);
	}
	while (n1 < MAX && (c = getchar()) != EOF)
		b1[n1++] = c;
	if (n1 == MAX) {
		fprintf(stderr, "cf85fix: input too large\n");
		exit(1);
	}
	if (argv[1][1] == 'i') {
		wrapsizeof();
		hoistfor();
		fwrite(b1, 1, n1, stdout);
	} else {
		fixea0();
		fwrite(b2, 1, n2, stdout);
	}
	exit(0);
}
