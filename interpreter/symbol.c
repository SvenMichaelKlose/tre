/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Symbol table
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

#ifdef TRE_VERBOSE_GC
#include <stdio.h>
#endif

char symbol_table[TRE_SYMBOL_TABLE_SIZE];
char *symbol_table_free;

unsigned num_symbols;

void
tresymbol_gc ()
{
    char      **reloc = malloc (num_symbols * sizeof (char *) * 2);
    char      **r;
    char      *o;
    char      *n;
    unsigned  i;
    unsigned  j;
    unsigned  l;

#ifdef TRE_VERBOSE_GC
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
    symbol_table_free = n;

    /* Correct symbol pointers in atoms. */
    DOTIMES(j, NUM_ATOMS) {
        if (tre_atoms[j].type == ATOM_UNUSED)
	    continue;

        r = reloc;
        DOTIMES(i, num_symbols) {
            if (*r++ == TREATOM_NAME(j)) {
		TREATOM_NAME(j) = *r;
		break;
            }
	    r++;
	}
    }

    free (reloc);
}

#define SYMBOL_TABLE_FULLP(len) \
    ((symbol_table_free + len + 2) >= &symbol_table[TRE_SYMBOL_TABLE_SIZE])

/* Add symbol to symbol table. */
char *
tresymbol_add (char *symbol)
{
    unsigned  l;
    char      *nstr;

    if (symbol == NULL)
	return NULL;

    l = strlen (symbol) + 1;

    if (SYMBOL_TABLE_FULLP(l)) {
	tresymbol_gc ();
        if (SYMBOL_TABLE_FULLP(l)) {
	    treerror_internal (treptr_invalid, "symbol table overflow");
	    return NULL;
        }
    }

    nstr = symbol_table_free;
    *nstr++ = l;
    symbol_table_free = (char *) stpcpy (nstr, symbol) + 1;
    num_symbols++;

    return nstr;
}

void
tresymbol_free (char *symbol)
{
    if (symbol == NULL)
        return;

    symbol--;
    while (*symbol)
        *symbol++ = 0;
    num_symbols--;
}

void
tresymbol_init ()
{
    bzero (symbol_table, TRE_SYMBOL_TABLE_SIZE);
    symbol_table_free = symbol_table;
    num_symbols = 0;
}
