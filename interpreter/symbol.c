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

struct tresymbol_root {
    treptr      package;
    tresymbol * root;
};

tre_size num_symbols;
struct tresymbol_root tresymbol_roots[MAX_PACKAGES];

char *
tresymbol_alloc_name (char * symbol)
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
tresymbol_free_name (char * symbol)
{
    if (symbol == NULL)
        return;

	free (symbol);
    num_symbols--;
}

tresymbol *
tresymbol_alloc ()
{
	void * r = malloc (sizeof (tresymbol));
	if (! r) {
		fprintf (stderr, "tresymbol: out of memory");
		exit (-1);
	}
	bzero (r, sizeof (tresymbol));

	return (tresymbol *) r;
}

tresymbol *
tresymbol_find_root (treptr package)
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
tresymbol_set_package (tre_size i, treptr package)
{
	tresymbol_roots[i].package = package;
}

tresymbol *
tresymbol_add_rec (tresymbol * p, char * name, treptr value, treptr fun, treptr package, treptr atom, char * np)
{
	int x = (int) (unsigned char) *np;

	p->num_entries++;

	if (* np) {
		if (p->entries[x] == NULL)
			p->entries[x] = tresymbol_alloc ();

		return tresymbol_add_rec (p->entries[x], name, value, fun, package, atom, ++np);
	}

	if (p->name) {
		printf ("tresymbol_page: '%s' already set", name);
		exit (-1);
	}

	p->name = tresymbol_alloc_name (name);
	p->value = value;
	p->function = fun;
	p->package = package;
	p->atom = atom;

    return p;
}

tresymbol *
tresymbol_add (treptr atom, char * name, treptr value, treptr fun, treptr package)
{
    return tresymbol_add_rec (tresymbol_find_root (package), name, value, fun, package, atom, name);
}

treptr tresymbol_find_rec (tresymbol * p, char * np);

treptr
tresymbol_find_rec (tresymbol * p, char * np)
{
	int x = (int) (unsigned char) *np;

	if (x && p->entries[x] == NULL)
		return treptr_invalid;

	if (x == 0)
		return p->name ? p->atom : treptr_invalid;

	return tresymbol_find_rec (p->entries[x], ++np);
}

treptr
tresymbol_find (char * name, treptr package)
{
	return tresymbol_find_rec (tresymbol_find_root (package), name);
}

tre_size
tresymbol_remove_rec (tresymbol * p, char * np)
{
	int x = (int) (unsigned char) *np;

	if (x) {
		if (tresymbol_remove_rec (p->entries[x], ++np) == 0) {
			free (p->entries[x]);
			p->entries[x] = NULL;
		}
	} else {
        tresymbol_free_name (p->name);
		p->name = NULL;
		p->atom = 0;
	}

	return --p->num_entries;
}

void
tresymbol_remove (treptr atom)
{
	(void) tresymbol_remove_rec (tresymbol_find_root (TRESYMBOL_PACKAGE(atom)), TRESYMBOL_NAME(atom));
}

void
tresymbol_clear ()
{
	int i;

    DOTIMES(i, NUM_ATOMS) {
		if (tre_atom_types[i] != TRETYPE_SYMBOL)
			continue;
		tresymbol_remove (i);
	}
}

void
tresymbol_init_packages ()
{
	long i;

	bzero (&tresymbol_roots, sizeof (tresymbol_roots));

	for (i = 0; i < MAX_PACKAGES; i++)
		tresymbol_roots[i].root = tresymbol_alloc ();
}

void
tresymbol_init ()
{
    num_symbols = 0;
	tresymbol_init_packages ();
    tresymbol_set_package (0, treptr_nil);
}
