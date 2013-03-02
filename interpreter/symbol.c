/*
 * tré – Copyright (c) 2005–2008,2010,2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "util.h"
#include "symbol.h"
#include "alloc.h"

#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>

ulong num_symbols;

struct tresymbol_page {
	struct tresymbol_page * entries[256];
	ulong  atom;
	ulong  num_entries;
	char * name;
};

struct tresymbol_root {
	treptr	package;
	struct tresymbol_page * root;
};

struct tresymbol_root tresymbol_roots[MAX_PACKAGES];

struct tresymbol_page *
tresymbolpage_alloc ()
{
	void * r = trealloc (sizeof (struct tresymbol_page));
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
	long i;

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
tresymbolpage_set_package (ulong i, treptr package)
{
	tresymbol_roots[i].package = package;
}

void
tresymbolpage_add_rec (struct tresymbol_page * p, char * name, treptr atom, char * np)
{
	ulong x = (ulong) (unsigned char) *np;

	p->num_entries++;

	if (* np) {
		if (p->entries[x] == NULL)
			p->entries[x] = tresymbolpage_alloc ();

		tresymbolpage_add_rec (p->entries[x], name, atom, ++np);
		return;
	}

	if (p->name) {
		printf ("tresymbol_page: '%s' already set", name);
		exit (-1);
	}

	p->name = name;
	p->atom = atom;
}

void
tresymbolpage_add (treptr atom)
{
	char * name = TREATOM_NAME(atom);
	if (name)
		tresymbolpage_add_rec (tresymbolpage_find_root (TREATOM_PACKAGE(atom)), name, atom, name);
}

treptr tresymbolpage_find_rec (struct tresymbol_page * p, char * np) __attribute__ ((pure));

treptr
tresymbolpage_find_rec (struct tresymbol_page * p, char * np)
{
	ulong x = (ulong) (unsigned char) *np;

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

ulong
tresymbolpage_remove_rec (struct tresymbol_page * p, char * np)
{
	ulong x = (ulong) (unsigned char) *np;

	if (x) {
		if (tresymbolpage_remove_rec (p->entries[x], ++np) == 0) {
			trealloc_free (p->entries[x]);
			p->entries[x] = NULL;
		}
	} else {
		p->name = NULL;
		p->atom = 0;
	}

	return --p->num_entries;
}

void
tresymbolpage_remove (treptr atom)
{
	(void) tresymbolpage_remove_rec (tresymbolpage_find_root (TREATOM_PACKAGE(atom)), TREATOM_NAME(atom));
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

    nstr = trealloc (strlen (symbol) + 1);
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

	trealloc_free (symbol);
    num_symbols--;
}

void
tresymbol_clear ()
{
	ulong i;
	char  * symbol;

    DOTIMES(i, NUM_ATOMS) {
		if (tre_atoms[i].type == TRETYPE_UNUSED)
			continue;
		symbol = tre_atoms[i].name;
		if (! symbol)
			continue;
		tresymbolpage_remove (i);
		tresymbol_free (symbol);
	}
}

void
tresymbol_init ()
{
    num_symbols = 0;
	tresymbolpage_init ();
    tresymbolpage_set_package (0, treptr_nil);
}
