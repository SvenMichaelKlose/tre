/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Symbol table.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "util.h"
#include "symbol.h"

#define _GNU_SOURCE
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>

unsigned num_symbols;

struct tresymbol_entry {
	char *		   name;
	unsigned long  atom;
	struct tresymbol_page * page;
};

struct tresymbol_page {
	struct tresymbol_entry  entries[256];
	unsigned long  num_entries;
};

struct tresymbol_root {
	treptr	package;
	struct tresymbol_page * root;
};

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

	for (i = 0; i < MAX_PACKAGES; i++)
		if (tresymbol_roots[i].package == package)
			return tresymbol_roots[i].root;

	return NULL;
}

void
tresymbolpage_set_package (unsigned long i, treptr package)
{
	tresymbol_roots[i].package = package;
}

void
tresymbolpage_add_rec (struct tresymbol_page * p, char * name, treptr atom, char * np)
{
	unsigned long x = (unsigned long) *np;

	p->num_entries++;

	if (*np) {
		if (p->entries[x].page == NULL)
			p->entries[x].page = tresymbolpage_alloc ();

		tresymbolpage_add_rec (p->entries[x].page, name, atom, ++np);
		return;
	}

	if (p->entries[0].name) {
		printf ("tresymbol_page: '%s' already set", name);
		exit (-1);
	}

	p->entries[0].name = name;
	p->entries[0].atom = atom;
	p->entries[0].page = (struct tresymbol_page *) -1;
}

void
tresymbolpage_add (treptr atom)
{
	char * name = TREATOM_NAME(atom);
	if (name) {
		tresymbolpage_add_rec (tresymbolpage_find_root (TREATOM_PACKAGE(atom)), name, atom, name);
}
}

treptr
tresymbolpage_find_rec (struct tresymbol_page * p, char * np)
{
	unsigned long x = (unsigned long) *np;

	if (p->entries[x].page == NULL)
		return treptr_invalid;

	if (x == 0)
		return p->entries[0].atom;

	return tresymbolpage_find_rec (p->entries[x].page, ++np);
}

treptr
tresymbolpage_find (char * name, treptr package)
{
	return tresymbolpage_find_rec (tresymbolpage_find_root (package), name);
}

unsigned long
tresymbolpage_remove_rec (struct tresymbol_page * p, char * np)
{
	unsigned long x = (unsigned long) *np;

	if (x) {
		if (tresymbolpage_remove_rec (p->entries[x].page, ++np) == 0) {
			free (p->entries[x].page);
			bzero (&(p->entries[x]), sizeof (struct tresymbol_entry));
		}
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
	int i;

	bzero (&tresymbol_roots, sizeof (tresymbol_roots));

	for (i = 0; i < MAX_PACKAGES; i++)
		tresymbol_roots[i].root = tresymbolpage_alloc ();
}

/* Add symbol to symbol table. */
char *
tresymbol_add (char * symbol)
{
    char  * nstr;

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
tresymbol_init ()
{
    num_symbols = 0;
	tresymbolpage_init ();
}
