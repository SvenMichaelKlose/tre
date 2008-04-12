/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Diagnostic functions.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "io.h"
#include "main.h"
#include "gc.h"
#include "util.h"
#include "diag.h"

#ifdef TRE_DIAGNOSTICS

int tre_user = 0;

/*************************************
 * Functions for manual diagnostics. *
 *************************************/

/* Check if cons is referenced by another. */
void
trediag_cons_used (treptr to)
{
    treptr i;
    treptr j;
    treptr elm;
    char    c;

    DOTIMES(i, sizeof (tregc_listmarks)) {
        c = tregc_listmarks[i];
        if (!c)
            continue;

        DOTIMES(j, 8) {
            if (!(c & 1)) {
                elm = (i << 3) + j;
                if (tre_lists[elm].car == to)
		    trewarn (-1, "%d ref in car of %d", to, elm);
                if (tre_lists[elm].cdr == to)
		    trewarn (-1, "%d ref in cdr of %d", to, elm);
            }
            c >>= 1;
        }    
    }
}

void
trediag_is_cons_of_r (treptr orig, treptr expr, treptr cons)
{
    treptr i;

    if (expr == treptr_nil || TREPTR_IS_ATOM(expr))
        return;

    if (expr == cons)
        treerror (-1, "%d ref in cdr of %d", cons, orig);

    for (i = expr; i != treptr_nil; i = _CDR(i))
        trediag_is_cons_of_r (orig, _CAR(expr), cons);
}

void
trediag_is_cons_of (treptr orig, treptr cons)
{
    trediag_is_cons_of_r (orig, orig, cons);
}

unsigned
trediag_atom_of (treptr p)
{
    unsigned  i;

    for (i = 0; i < NUM_ATOMS; i++)
        if (tre_atoms[i].type == ATOM_VARIABLE && TREPTR_INDEX(tre_atoms[i].fun) == TREPTR_INDEX(p))
	    return i;

    return -1;
}

#endif /* #ifdef TRE_DIAGNOSTICS */
