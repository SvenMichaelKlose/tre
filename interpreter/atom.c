/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
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
#include "builtin.h"
#include "special.h"
#include "io.h"
#include "symbol.h"
#include "thread.h"
#include "alloc.h"
#include "util.h"
#include "function.h"
#include "symbol.h"

void * tre_atoms_free;
void * tre_atoms[NUM_ATOMS];
tre_type tre_atom_types[NUM_ATOMS];

#define TREPTR_NIL_INDEX	0
#define TREPTR_T_INDEX		1
#define TREPTR_FIRST_INDEX	2

#define TREPACKAGE_KEYWORD_INDEX	1

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
	tre_atoms[TREPTR_NIL_INDEX] = (void *) tresymbol_add (treptr_nil, "NIL", treptr_nil, treptr_nil, treptr_nil);
	tre_atoms[TREPTR_T_INDEX] = (void *) tresymbol_add (treptr_t, "T", treptr_t, treptr_nil, treptr_nil);
}

void
treatom_init_builtins (void)
{
    treptr name;
    treptr fun;
    size_t i;

    for (i = 0; tre_builtin_names[i] != NULL; i++) {
        fun = treatom_alloc (TRETYPE_BUILTIN);
        TREATOM(fun) = (void*) i;
        name = treatom_alloc_symbol (tre_builtin_names[i], treptr_nil, treptr_nil);
        TRESYMBOL_FUN(name) = fun;
        EXPAND_UNIVERSE(name);
    }

    for (i = 0; tre_special_names[i] != NULL; i++) {
        fun = treatom_alloc (TRETYPE_SPECIAL);
        TREATOM(fun) = (void*) i;
        name = treatom_alloc_symbol (tre_special_names[i], treptr_nil, treptr_nil);
        TRESYMBOL_FUN(name) = fun;
        EXPAND_UNIVERSE(name);
    }
}

void
treatom_init_keyword_package ()
{
    tre_package_keyword = treatom_alloc_symbol ("", treptr_nil, treptr_nil);
	tresymbol_set_package (TREPACKAGE_KEYWORD_INDEX, tre_package_keyword);
}

void
treatom_init_big_bang ()
{
    treptr_universe = treatom_alloc_symbol ("*UNIVERSE*", treptr_nil, treptr_nil);
    EXPAND_UNIVERSE(treptr_t);
    EXPAND_UNIVERSE(tre_package_keyword);
	MAKE_SYMBOL("*KEYWORD-PACKAGE*", tre_package_keyword);
    tre_default_listprop = treatom_alloc_symbol ("*DEFAULT-LISTPROP*", treptr_nil, treptr_nil);
    EXPAND_UNIVERSE(tre_default_listprop);
}

void
treatom_init (void)
{
    treatom_init_atom_table ();
    treatom_init_truth ();
	treatom_init_keyword_package ();
    treatom_init_big_bang ();
    treatom_init_builtins ();
}

treptr
treatom_set_value (treptr atom, treptr value)
{
    return TRESYMBOL_VALUE(atom) = value;
}

treptr
treatom_register_compiled_function (treptr sym, void * fun, void * expander_fun)
{
    if (TRESYMBOL_FUN(sym) == treptr_nil)
        TRESYMBOL_FUN(sym) = trefunction_make (TRETYPE_FUNCTION, treptr_nil);

    TREFUNCTION_NATIVE(TRESYMBOL_FUN(sym)) = fun;
    TREFUNCTION_NATIVE_EXPANDER(TRESYMBOL_FUN(sym)) = expander_fun;
	return sym;
}

treptr
treatom_get_value (treptr atom)
{
    return TRESYMBOL_VALUE(atom);
}

treptr
treatom_get_function (treptr atom)
{
	return TREPTR_IS_BUILTIN(atom) ? atom : TRESYMBOL_FUN(atom);
}

treptr
treatom_set_function (treptr atom, treptr value)
{
    return TRESYMBOL_FUN(atom) = value;
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


treptr
treatom_alloc_symbol (char * name, treptr package, treptr value)
{
    treptr  atom = treatom_alloc (TRETYPE_SYMBOL);

    if (value == treptr_invalid)
		value = atom;

	TREATOM(atom) = tresymbol_add (atom, name, value, treptr_nil, package);

	return atom;
}

void
treatom_free (treptr x)
{
    if (TREATOM_TYPE(x) == TRETYPE_SYMBOL)
		tresymbol_remove (x);

    TREATOM_TYPE(x) = TRETYPE_UNUSED;
	trealloc_free_item (&tre_atoms_free, (void **) &tre_atoms[TREPTR_INDEX(x)]);
}

treptr
treatom_number_get (double value, int type)
{
    treptr      atom;
    trenumber * num;

    num = trenumber_alloc (value, type);
    atom = treatom_alloc (TRETYPE_NUMBER);
    TREATOM(atom) = num;

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
	return tresymbol_find (symbol, package);
}

treptr
treatom_get (char * symbol, treptr package)
{   
    treptr  atom;
	double  dvalue;

    atom = treatom_seek (symbol, package);
    if (atom != ATOM_NOT_FOUND)
		return atom;

    if (trenumber_is_value (symbol)) {
		if (sscanf (symbol, "%lf", &dvalue) != 1)
			treerror (treptr_nil, "Illegal number format %s.", symbol);
        return treatom_number_get (dvalue, TRENUMTYPE_FLOAT);
	}

    return treatom_alloc_symbol (symbol, package, treptr_invalid);
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

        if (!TREPTR_IS_CONS(TRESYMBOL_VALUE(a)))
            continue;

        tmp = CDR(TRESYMBOL_VALUE(a));
        if (NULLP(tmp) || CAR(tmp) != body)
	    	continue;

        for (b = 0; b < NUM_ATOMS; b++)
            if (tre_atom_types[b] == TRETYPE_SYMBOL
					&& tre_atoms[b] != NULL
					&& TRESYMBOL_FUN(b) == TREINDEX_TO_PTR(a))
                return TREINDEX_TO_PTR(b);
    }

    return treptr_nil;
}

treptr
treatom_fun_body (treptr atomp)
{
    treptr fun;

    if (TREPTR_IS_SYMBOL(atomp) == FALSE)
        treerror_internal (atomp, "Symbol expected.");

    fun = TRESYMBOL_FUN(atomp);
    if (fun != treptr_nil)
        return CDR(TRESYMBOL_VALUE(fun));

    return treptr_nil;
}
