/*
 * tré – Copyright (c) 2005–2008,2010,2012–2014 Sven Michael Klose <pixel@copei.de>
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
#include "symtab.h"
#include "alloc.h"

struct symtab_root {
    treptr      package;
    tresymbol * root;
};

tre_size num_symbols;
struct symtab_root symtab_roots[MAX_PACKAGES];

char *
symtab_alloc_name (char * symbol)
{
    char * nstr;

    if (symbol == NULL)
		return NULL;

    nstr = malloc (strlen (symbol) + 1);
	if (! nstr) {
		printf ("symtab_add: out of memory\n");
		exit (-1);
	}

    strcpy (nstr, symbol);
    num_symbols++;

    return nstr;
}

void
symtab_free_name (char * symbol)
{
    if (symbol == NULL)
        return;

	free (symbol);
    num_symbols--;
}

tresymbol *
symtab_alloc ()
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
symtab_find_root (treptr package)
{
	int i;

	DOTIMES(i, MAX_PACKAGES)
		if (symtab_roots[i].package == package)
			return symtab_roots[i].root;

	DOTIMES(i, MAX_PACKAGES)
		if (symtab_roots[i].package == 0) {
			symtab_roots[i].package = package;
			return symtab_roots[i].root;
		}

	return NULL;
}

void
symtab_set_package (tre_size i, treptr package)
{
	symtab_roots[i].package = package;
}

tresymbol *
symtab_add_rec (tresymbol * p, char * name, treptr value, treptr fun, treptr package, treptr atom, char * np)
{
	int x = (int) (unsigned char) *np;

	p->num_entries++;

	if (* np) {
		if (p->entries[x] == NULL)
			p->entries[x] = symtab_alloc ();

		return symtab_add_rec (p->entries[x], name, value, fun, package, atom, ++np);
	}

	if (p->name) {
		printf ("symtab_page: '%s' already set", name);
		exit (-1);
	}

	p->name = symtab_alloc_name (name);
	p->value = value;
	p->function = fun;
	p->package = package;
	p->atom = atom;

    return p;
}

tresymbol *
symtab_add (treptr atom, char * name, treptr value, treptr fun, treptr package)
{
    return symtab_add_rec (symtab_find_root (package), name, value, fun, package, atom, name);
}

treptr symtab_find_rec (tresymbol * p, char * np);

treptr
symtab_find_rec (tresymbol * p, char * np)
{
	int x = (int) (unsigned char) *np;

	if (x && p->entries[x] == NULL)
		return treptr_invalid;

	if (x == 0)
		return p->name ? p->atom : treptr_invalid;

	return symtab_find_rec (p->entries[x], ++np);
}

treptr
symtab_find (char * name, treptr package)
{
	return symtab_find_rec (symtab_find_root (package), name);
}

tre_size
symtab_remove_rec (tresymbol * p, char * np)
{
	int x = (int) (unsigned char) *np;

	if (x) {
		if (symtab_remove_rec (p->entries[x], ++np) == 0) {
			free (p->entries[x]);
			p->entries[x] = NULL;
		}
	} else {
        symtab_free_name (p->name);
		p->name = NULL;
		p->atom = 0;
	}

	return --p->num_entries;
}

void
symtab_remove (treptr atom)
{
	(void) symtab_remove_rec (symtab_find_root (SYMBOL_PACKAGE(atom)), SYMBOL_NAME(atom));
}

void
symtab_clear ()
{
	int i;

    DOTIMES(i, NUM_ATOMS) {
		if (tre_atom_types[i] != TRETYPE_SYMBOL)
			continue;
		symtab_remove (i);
	}
}

void
symtab_init_packages ()
{
	long i;

	bzero (&symtab_roots, sizeof (symtab_roots));

	for (i = 0; i < MAX_PACKAGES; i++)
		symtab_roots[i].root = symtab_alloc ();
}

void
symtab_init ()
{
    num_symbols = 0;
	symtab_init_packages ();
    symtab_set_package (0, NIL);
}
