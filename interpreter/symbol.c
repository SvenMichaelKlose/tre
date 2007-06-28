/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Symbol table
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "util.h"
#include "symbol.h"

#define _GNU_SOURCE
#include <string.h>
#include <strings.h>
#include <stdlib.h>

#ifdef LISP_VERBOSE_GC
#include <stdio.h>
#endif

char symbol_table[LISP_SYMBOL_TABLE_SIZE];
char *symbol_table_unused;

unsigned num_symbols;

void
lispsymbol_gc ()
{
    char      **reloc = malloc (num_symbols * sizeof (char *) * 2);
    char      **r;
    char      *o;
    char      *n;
    unsigned  i;
    unsigned  j;
    unsigned  l;

#ifdef LISP_VERBOSE_GC
    printf ("SYMBOL-GC");
    fflush (stdout);
#endif

    /* Compress strings in symbol table and create a relocation map from
     * old to new addresses.
     */
    r = reloc;
    o = symbol_table;
    n = symbol_table;
    DOTIMES(i, num_symbols) {
        while (!*o)
            o++;
        l = *o;
        *r++ = 1 + o;
	*r++ = 1 + n;
        n = 1 + stpcpy (n, o);
        o += 1 + l;
    }
    symbol_table_unused = n;

    /* Correct symbol pointers in atoms. */
    DOTIMES(j, NUM_ATOMS) {
        if (lisp_atoms[j].type == ATOM_UNUSED)
	    continue;

        r = reloc;
        DOTIMES(i, num_symbols) {
            if (*r++ == LISPATOM_NAME(j)) {
		LISPATOM_NAME(j) = *r;
		break;
            }
	    r++;
	}
    }

    free (reloc);
}

#define SYMBOL_TABLE_FULLP(len) \
    ((symbol_table_unused + len + 2) >= &symbol_table[LISP_SYMBOL_TABLE_SIZE])

/* Add symbol to symbol table. */
char *
lispsymbol_add (char *symbol)
{
    unsigned  l;
    char      *nstr;

    if (symbol == NULL)
	return NULL;

    l = strlen (symbol) + 1;

    if (SYMBOL_TABLE_FULLP(l)) {
	lispsymbol_gc ();
        if (SYMBOL_TABLE_FULLP(l)) {
	    lisperror_internal (lispptr_invalid, "symbol table overflow");
	    return NULL;
        }
    }

    nstr = symbol_table_unused;
    *nstr++ = l;
    symbol_table_unused = (char *) stpcpy (nstr, symbol) + 1;
    num_symbols++;

    return nstr;
}

void
lispsymbol_free (char *symbol)
{
    if (symbol == NULL)
        return;

    symbol--;
    while (*symbol)
        *symbol++ = 0;
    num_symbols--;
}

void
lispsymbol_init ()
{
    bzero (symbol_table, LISP_SYMBOL_TABLE_SIZE);
    symbol_table_unused = symbol_table;
    num_symbols = 0;
}
