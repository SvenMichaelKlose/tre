/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Symbol database.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "util.h"
#include "symbol.h"
#include "alloc.h"

#define _GNU_SOURCE
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>

unsigned num_symbols;

struct tresymbol_entry {
	char *		   name;	/* Full symbol */
	unsigned long  atom;	/* Atom of the symbol. */
	struct tresymbol_page * page; /* Page for next character. */
};

struct tresymbol_page {
	struct tresymbol_entry  entries[256];
	unsigned long  num_entries;	/* Reference counter. */
};

struct tresymbol_root {
	treptr	package;
	struct tresymbol_page * root;
};

/* Root pages of all packages. */
struct tresymbol_root tresymbol_roots[MAX_PACKAGES];

/* Allocate a new node. */
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

/* Find root node of a package. */
struct tresymbol_page *
tresymbolpage_find_root (treptr package)
{
	int i;

	for (i = 0; i < MAX_PACKAGES; i++)
		if (tresymbol_roots[i].package == package)
			return tresymbol_roots[i].root;

	return NULL;
}

/* Set package for root node. */
void
tresymbolpage_set_package (unsigned long i, treptr package)
{
	tresymbol_roots[i].package = package;
}

/* Add symbol to node or continue with child. */
void
tresymbolpage_add_rec (struct tresymbol_page * p, char * name, treptr atom, char * np)
{
	unsigned long x = (unsigned long) *np;

	p->num_entries++; /* This node is occupied by one more symbol. */

	/* Continue with child node. */
	if (*np) {
		/* Allocate new node. */
		if (p->entries[x].page == NULL)
			p->entries[x].page = tresymbolpage_alloc ();

		tresymbolpage_add_rec (p->entries[x].page, name, atom, ++np);
		return;
	}

	/* End of symbol. */

	/* Check if symbol already exists. */
	if (p->entries[0].name) {
		printf ("tresymbol_page: '%s' already set", name);
		exit (-1);
	}

	/* Make entry. */
	p->entries[0].name = name;
	p->entries[0].atom = atom;
	p->entries[0].page = (struct tresymbol_page *) -1;
}

/* Add symbol to database. */
void
tresymbolpage_add (treptr atom)
{
	char * name = TREATOM_NAME(atom);
	if (name)
		tresymbolpage_add_rec (tresymbolpage_find_root (TREATOM_PACKAGE(atom)), name, atom, name);
}

treptr
tresymbolpage_find_rec (struct tresymbol_page * p, char * np)
{
	unsigned long x = (unsigned long) *np;

	if (p->entries[x].page == NULL)
		return treptr_invalid; /* Symbol doesn't exist. */

	if (x == 0) /* End of symbol. */
		return p->entries[x].page ? /* Exists? */
			   p->entries[0].atom : /* Return its atom. */
			   treptr_invalid; /* Symbol not found. */

	/* Continue with next character. */
	return tresymbolpage_find_rec (p->entries[x].page, ++np);
}

/* Find symbol in database. */
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
		/* Remove from children first. */
		if (tresymbolpage_remove_rec (p->entries[x].page, ++np) == 0) {
			trealloc_free (p->entries[x].page);
			bzero (&(p->entries[x]), sizeof (struct tresymbol_entry));
		}
	} else
		bzero (&(p->entries[0]), sizeof (struct tresymbol_entry));

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

/* Allocate space for symbol string. */
char *
tresymbol_add (char * symbol)
{
    char  * nstr;

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

/* Free symbol string. */
void
tresymbol_free (char *symbol)
{
    if (symbol == NULL)
        return;

	trealloc_free (symbol);
    num_symbols--;
}

void
tresymbol_init ()
{
    num_symbols = 0;
	tresymbolpage_init ();
}
