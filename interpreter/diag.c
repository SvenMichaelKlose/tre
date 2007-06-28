/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Diagnostic functions.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "io.h"
#include "main.h"
#include "gc.h"
#include "util.h"
#include "diag.h"

#ifdef LISP_DIAGNOSTICS

int lisp_user = 0;

/*************************************
 * Functions for manual diagnostics. *
 *************************************/

/* Check if cons is referenced by another. */
void
lispdiag_cons_used (lispptr to)
{
    lispptr i;
    lispptr j;
    lispptr elm;
    char    c;

    DOTIMES(i, sizeof (lispgc_listmarks)) {
        c = lispgc_listmarks[i];
        if (!c)
            continue;

        DOTIMES(j, 8) {
            if (!(c & 1)) {
                elm = (i << 3) + j;
                if (lisp_lists[elm].car == to)
		    lispwarn (-1, "%d ref in car of %d", to, elm);
                if (lisp_lists[elm].cdr == to)
		    lispwarn (-1, "%d ref in cdr of %d", to, elm);
            }
            c >>= 1;
        }    
    }
}

void
lispdiag_is_cons_of_r (lispptr orig, lispptr expr, lispptr cons)
{
    lispptr i;

    if (expr == lispptr_nil || LISPPTR_IS_EXPR(expr) == FALSE)
        return;

    if (expr == cons)
        lisperror (-1, "%d ref in cdr of %d", cons, orig);

    for (i = expr; i != lispptr_nil; i = _CDR(i))
        lispdiag_is_cons_of_r (orig, _CAR(expr), cons);
}

void
lispdiag_is_cons_of (lispptr orig, lispptr cons)
{
    lispdiag_is_cons_of_r (orig, orig, cons);
}

unsigned
lispdiag_atom_of (lispptr p)
{
    unsigned  i;

    for (i = 0; i < NUM_ATOMS; i++)
        if (lisp_atoms[i].type == ATOM_VARIABLE && LISPPTR_INDEX(lisp_atoms[i].fun) == LISPPTR_INDEX(p))
	    return i;

    return -1;
}

#endif /* #ifdef LISP_DIAGNOSTICS */
