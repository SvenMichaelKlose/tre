/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "number.h"
#include "cons.h"
#include "list.h"
#include "string2.h"
#include "eval.h"
#include "error.h"
#include "array.h"
#include "gc.h"
#include "stream.h"
#include "symtab.h"
#include "thread.h"
#include "alloc.h"
#include "util.h"
#include "function.h"

#include "builtin_symbol.h"

void * atoms_free;
void * atoms[NUM_ATOMS];
tre_type tre_atom_types[NUM_ATOMS];

#define TREPTR_NIL_INDEX	0
#define TREPTR_T_INDEX		1
#define TREPTR_FIRST_INDEX	2

const treptr NIL = TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, TREPTR_NIL_INDEX);
const treptr treptr_t = TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, TREPTR_T_INDEX);
const treptr treptr_invalid = (treptr) -1;

treptr treptr_universe;

treptr atom_accent_circonflex;
treptr atom_backquote;
treptr atom_function;
treptr atom_lambda;
treptr atom_quote;
treptr atom_quasiquote;
treptr atom_quasiquote_splice;
treptr atom_values;
treptr atom_square;
treptr atom_curly;
treptr atom_cons;

treptr tre_package_keyword;

void
atom_init_atom_table (void)
{
	tre_size x;

    atoms_free = trealloc_item_init (
		&atoms[TREPTR_FIRST_INDEX],
		NUM_ATOMS - TREPTR_FIRST_INDEX,
		sizeof (void *)
	);
	DOTIMES(x, NUM_ATOMS)
	  tre_atom_types[x] = TRETYPE_UNUSED;
}

void
atom_init_truth (void)
{
	atoms[TREPTR_NIL_INDEX] = (void *) symtab_add (NIL, "NIL", NIL, NIL, NIL);
	atoms[TREPTR_T_INDEX] = (void *) symtab_add (treptr_t, "T", treptr_t, NIL, NIL);
}

void
atom_init (void)
{
    atom_init_atom_table ();
    atom_init_truth ();
}

treptr
atom_alloc (int type)
{
    size_t atomi;
	void * item;

	item = trealloc_item (&atoms_free);
	if (!item) {
        tregc_force ();
		item = trealloc_item (&atoms_free);
    	if (!item)
	    	return treerror (treptr_invalid, "Atom table full.");
    }

    atomi = ((size_t) item - (size_t) atoms) / sizeof (void *);
    TREGC_ALLOC_ATOM(atomi);
    ATOM_SET(atomi, type);

	return TRETYPE_INDEX_TO_PTR(type, atomi);
}

void
atom_free (treptr x)
{
    if (ATOM_TYPE(x) == TRETYPE_SYMBOL)
		symtab_remove (x);

    ATOM_TYPE(x) = TRETYPE_UNUSED;
	trealloc_free_item (&atoms_free, (void **) &atoms[TREPTR_INDEX(x)]);
}

treptr
atom_number_get (double value, int type)
{
    treptr      atom;
    trenumber * num;

    num = trenumber_alloc (value, type);
    atom = atom_alloc (TRETYPE_NUMBER);
    ATOM(atom) = num;

    return atom;
}

treptr
trenumber_get (double value)
{
    return atom_number_get (value, TRENUMTYPE_FLOAT);
}

treptr
trechar_get (double value)
{
    return atom_number_get (value, TRENUMTYPE_CHAR);
}

treptr
atom_seek (char * symbol, treptr package)
{
	return symtab_find (symbol, package);
}

void
atom_remove (treptr x)
{
    switch (TREPTR_TYPE(x)) {
        case TRETYPE_NUMBER:      trenumber_free (x); break;
        case TRETYPE_ARRAY:       trearray_free  (x); break;
        case TRETYPE_STRING:      trestring_free (x); break;
        case TRETYPE_FUNCTION:    trefunction_free (x); break;
        case TRETYPE_MACRO:       trefunction_free (x); break;
        case TRETYPE_USERSPECIAL: trefunction_free (x); break;
    }

    atom_free (x);
}

treptr
atom_body_to_var (treptr body)
{        
    tre_size a;
    tre_size b; 
	treptr tmp;

    for (a = 0; a < NUM_ATOMS; a++) {
        if (tre_atom_types[a] != TRETYPE_FUNCTION && tre_atom_types[a] != TRETYPE_MACRO)
	    	continue;

        if (CONSP(SYMBOL_VALUE(a)) == FALSE)
            continue;

        tmp = CDR(SYMBOL_VALUE(a));
        if (NOT(tmp) || CAR(tmp) != body)
	    	continue;

        for (b = 0; b < NUM_ATOMS; b++)
            if (tre_atom_types[b] == TRETYPE_SYMBOL
					&& atoms[b] != NULL
					&& SYMBOL_FUNCTION(b) == TREINDEX_TO_PTR(a))
                return TREINDEX_TO_PTR(b);
    }

    return NIL;
}

treptr
atom_fun_body (treptr atomp)
{
    treptr fun;

    if (SYMBOLP(atomp) == FALSE)
        treerror_internal (atomp, "Symbol expected.");

    fun = SYMBOL_FUNCTION(atomp);
    if (NOT_NIL(fun))
        return CDR(SYMBOL_VALUE(fun));

    return NIL;
}
