/*
 * tré - Copyright (c) 2005-2008,2010,2012 Sven Michael Klose <pixel@copei.de>
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
	struct tresymbol_page * entries[256]; /* Page for next character. */
	ulong   atom;	/* Atom of the symbol. */
	ulong   num_entries;	/* Reference counter. */
	char    * name;
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

/* Set package for root node. */
void
tresymbolpage_set_package (ulong i, treptr package)
{
	tresymbol_roots[i].package = package;
}

/* Add symbol to node or continue with child. */
void
tresymbolpage_add_rec (struct tresymbol_page * p, char * name, treptr atom, char * np)
{
	ulong x = (ulong) (unsigned char) *np;

	p->num_entries++; /* This node is occupied by one more symbol. */

	/* Continue with child node. */
	if (* np) {
		/* Allocate new node. */
		if (p->entries[x] == NULL)
			p->entries[x] = tresymbolpage_alloc ();

		tresymbolpage_add_rec (p->entries[x], name, atom, ++np);
		return;
	}

	/* End of symbol. */

	/* Check if symbol already exists. */
	if (p->name) {
		printf ("tresymbol_page: '%s' already set", name);
		exit (-1);
	}

	/* Make entry. */
	p->name = name;
	p->atom = atom;
}

/* Add symbol to database. */
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
		return treptr_invalid; /* Symbol doesn't exist. */

	if (x == 0) /* End of symbol. */
		return p->name ? /* Exists? */
			   p->atom : /* Return its atom. */
			   treptr_invalid; /* Symbol not found. */

	/* Continue with next character. */
	return tresymbolpage_find_rec (p->entries[x], ++np);
}

/* Find symbol in database. */
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
		/* Remove from children first. */
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
tresymbol_clear ()
{
	ulong  i;
	char   * symbol;

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
