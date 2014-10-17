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

void * tre_atoms_free;
void * tre_atoms[NUM_ATOMS];
tre_type tre_atom_types[NUM_ATOMS];

#define TREPTR_NIL_INDEX	0
#define TREPTR_T_INDEX		1
#define TREPTR_FIRST_INDEX	2

const treptr treptr_nil = TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, TREPTR_NIL_INDEX);
const treptr treptr_t = TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, TREPTR_T_INDEX);
const treptr treptr_invalid = (treptr) -1;

treptr treptr_universe;

treptr treatom_accent_circonflex;
treptr treatom_backquote;
treptr treatom_function;
treptr treatom_lambda;
treptr treatom_quote;
treptr treatom_quasiquote;
treptr treatom_quasiquote_splice;
treptr treatom_values;
treptr treatom_square;
treptr treatom_curly;
treptr treatom_cons;

treptr tre_package_keyword;

void
treatom_init_atom_table (void)
{
	tre_size x;

    tre_atoms_free = trealloc_item_init (
		&tre_atoms[TREPTR_FIRST_INDEX],
		NUM_ATOMS - TREPTR_FIRST_INDEX,
		sizeof (void *)
	);
	DOTIMES(x, NUM_ATOMS)
	  tre_atom_types[x] = TRETYPE_UNUSED;
}

void
treatom_init_truth (void)
{
	tre_atoms[TREPTR_NIL_INDEX] = (void *) symtab_add (treptr_nil, "NIL", treptr_nil, treptr_nil, treptr_nil);
	tre_atoms[TREPTR_T_INDEX] = (void *) symtab_add (treptr_t, "T", treptr_t, treptr_nil, treptr_nil);
}

void
treatom_init (void)
{
    treatom_init_atom_table ();
    treatom_init_truth ();
}

treptr
treatom_register_compiled_function (treptr sym, void * fun, void * expander_fun)
{
    if (BUILTINP(SYMBOL_FUNCTION(sym)))
        return sym;

    if (NOT(SYMBOL_FUNCTION(sym)))
        tresymbol_set_function (trefunction_make (TRETYPE_FUNCTION, treptr_nil), sym);

    FUNCTION_NATIVE(SYMBOL_FUNCTION(sym)) = fun;
    FUNCTION_NATIVE_EXPANDER(SYMBOL_FUNCTION(sym)) = expander_fun;

	return sym;
}

treptr
treatom_alloc (int type)
{
    size_t atomi;
	void * item;

	item = trealloc_item (&tre_atoms_free);
	if (!item) {
        tregc_force ();
		item = trealloc_item (&tre_atoms_free);
    	if (!item)
	    	return treerror (treptr_invalid, "Atom table full.");
    }

    atomi = ((size_t) item - (size_t) tre_atoms) / sizeof (void *);
    TREGC_ALLOC_ATOM(atomi);
    ATOM_SET(atomi, type);

	return TRETYPE_INDEX_TO_PTR(type, atomi);
}

void
treatom_free (treptr x)
{
    if (ATOM_TYPE(x) == TRETYPE_SYMBOL)
		symtab_remove (x);

    ATOM_TYPE(x) = TRETYPE_UNUSED;
	trealloc_free_item (&tre_atoms_free, (void **) &tre_atoms[TREPTR_INDEX(x)]);
}

treptr
treatom_number_get (double value, int type)
{
    treptr      atom;
    trenumber * num;

    num = trenumber_alloc (value, type);
    atom = treatom_alloc (TRETYPE_NUMBER);
    ATOM(atom) = num;

    return atom;
}

treptr
trenumber_get (double value)
{
    return treatom_number_get (value, TRENUMTYPE_FLOAT);
}

treptr
trechar_get (double value)
{
    return treatom_number_get (value, TRENUMTYPE_CHAR);
}

treptr
treatom_seek (char * symbol, treptr package)
{
	return symtab_find (symbol, package);
}

void
treatom_remove (treptr x)
{
    switch (TREPTR_TYPE(x)) {
        case TRETYPE_NUMBER:      trenumber_free (x); break;
        case TRETYPE_ARRAY:       trearray_free  (x); break;
        case TRETYPE_STRING:      trestring_free (x); break;
        case TRETYPE_FUNCTION:    trefunction_free (x); break;
        case TRETYPE_MACRO:       trefunction_free (x); break;
        case TRETYPE_USERSPECIAL: trefunction_free (x); break;
    }

    treatom_free (x);
}

treptr
treatom_body_to_var (treptr body)
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
					&& tre_atoms[b] != NULL
					&& SYMBOL_FUNCTION(b) == TREINDEX_TO_PTR(a))
                return TREINDEX_TO_PTR(b);
    }

    return treptr_nil;
}

treptr
treatom_fun_body (treptr atomp)
{
    treptr fun;

    if (SYMBOLP(atomp) == FALSE)
        treerror_internal (atomp, "Symbol expected.");

    fun = SYMBOL_FUNCTION(atomp);
    if (NOT_NIL(fun))
        return CDR(SYMBOL_VALUE(fun));

    return treptr_nil;
}
