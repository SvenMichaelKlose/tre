/*
 * tré – Copyright (c) 2005–2008,2010,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "util.h"
#include "symbol.h"
#include "alloc.h"

tre_size num_symbols;
struct tresymbol_root tresymbol_roots[MAX_PACKAGES];

struct tresymbol_page *
tresymbolpage_alloc ()
{
	void * r = malloc (sizeof (struct tresymbol_page));
	if (! r) {
		fprintf (stderr, "tresymbolpage: out of memory");
		exit (-1);
	}
	bzero (r, sizeof (struct tresymbol_page));

	return (struct tresymbol_page *) r;
}

struct tresymbol_page *
tresymbolpage_find_root (treptr package)
{
	int i;

	DOTIMES(i, MAX_PACKAGES)
		if (tresymbol_roots[i].package == package)
			return tresymbol_roots[i].root;

	DOTIMES(i, MAX_PACKAGES)
		if (tresymbol_roots[i].package == 0) {
			tresymbol_roots[i].package = package;
			return tresymbol_roots[i].root;
		}

	return NULL;
}

void
tresymbolpage_set_package (tre_size i, treptr package)
{
	tresymbol_roots[i].package = package;
}

struct tresymbol_page *
tresymbolpage_add_rec (struct tresymbol_page * p, char * name, treptr atom, char * np)
{
	int x = (int) (unsigned char) *np;

	p->num_entries++;

	if (* np) {
		if (p->entries[x] == NULL)
			p->entries[x] = tresymbolpage_alloc ();

		return tresymbolpage_add_rec (p->entries[x], name, atom, ++np);
	}

	if (p->name) {
		printf ("tresymbol_page: '%s' already set", name);
		exit (-1);
	}

	p->name = name;
	p->atom = atom;

    return p;
}

struct tresymbol_page *
tresymbolpage_add (treptr atom, char * name, treptr package)
{
    return tresymbolpage_add_rec (tresymbolpage_find_root (package), name, atom, name);
}

treptr tresymbolpage_find_rec (struct tresymbol_page * p, char * np);

treptr
tresymbolpage_find_rec (struct tresymbol_page * p, char * np)
{
	int x = (int) (unsigned char) *np;

	if (x && p->entries[x] == NULL)
		return treptr_invalid;

	if (x == 0)
		return p->name ? p->atom : treptr_invalid;

	return tresymbolpage_find_rec (p->entries[x], ++np);
}

treptr
tresymbolpage_find (char * name, treptr package)
{
	return tresymbolpage_find_rec (tresymbolpage_find_root (package), name);
}

tre_size
tresymbolpage_remove_rec (struct tresymbol_page * p, char * np)
{
	int x = (int) (unsigned char) *np;

	if (x) {
		if (tresymbolpage_remove_rec (p->entries[x], ++np) == 0) {
			free (p->entries[x]);
			p->entries[x] = NULL;
		}
	} else {
        tresymbol_free (p->name);
		p->name = NULL;
		p->atom = 0;
	}

	return --p->num_entries;
}

void
tresymbolpage_remove (treptr atom)
{
	(void) tresymbolpage_remove_rec (tresymbolpage_find_root (TRESYMBOL_PACKAGE(atom)), TRESYMBOL_NAME(atom));
}

void
tresymbolpage_init ()
{
	long i;

	bzero (&tresymbol_roots, sizeof (tresymbol_roots));

	for (i = 0; i < MAX_PACKAGES; i++)
		tresymbol_roots[i].root = tresymbolpage_alloc ();
}

char *
tresymbol_add (char * symbol)
{
    char * nstr;

    if (symbol == NULL)
		return NULL;

    nstr = malloc (strlen (symbol) + 1);
	if (! nstr) {
		printf ("tresymbol_add: out of memory\n");
		exit (-1);
	}

    strcpy (nstr, symbol);
    num_symbols++;

    return nstr;
}

void
tresymbol_free (char *symbol)
{
    if (symbol == NULL)
        return;

	free (symbol);
    num_symbols--;
}

void
tresymbol_clear ()
{
	int i;

    DOTIMES(i, NUM_ATOMS) {
		if (tre_atom_types[i] != TRETYPE_SYMBOL)
			continue;
		tresymbolpage_remove (i);
	}
}

void
tresymbol_init ()
{
    num_symbols = 0;
	tresymbolpage_init ();
    tresymbolpage_set_package (0, treptr_nil);
}
