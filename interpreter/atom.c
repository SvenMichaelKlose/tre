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
#include "env.h"
#include "io.h"
#include "symbol.h"
#include "thread.h"
#include "alloc.h"
#include "util.h"

void * tre_atoms_free;
struct tre_atom tre_atoms[NUM_ATOMS];
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

treptr tre_package_keyword;

void
treatom_init_truth (void)
{
    ATOM_SET(TREPTR_NIL_INDEX, TRETYPE_SYMBOL);
    ATOM_SET_NAME(TREPTR_NIL_INDEX, tresymbol_add ("NIL"));
    tre_atoms[TREPTR_NIL_INDEX].value = TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, TREPTR_NIL_INDEX);
    tre_atoms[TREPTR_NIL_INDEX].fun = treptr_nil;
    tre_atoms[TREPTR_NIL_INDEX].binding = treptr_nil;
	tresymbolpage_add (treptr_nil);

    ATOM_SET(TREPTR_T_INDEX, TRETYPE_SYMBOL);
    ATOM_SET_NAME(TREPTR_T_INDEX, tresymbol_add ("T"));
    tre_atoms[TREPTR_T_INDEX].value = TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, TREPTR_T_INDEX);
    tre_atoms[TREPTR_T_INDEX].fun = treptr_nil;
    tre_atoms[TREPTR_T_INDEX].binding = treptr_nil;
	tresymbolpage_add (treptr_t);
}

void
treatom_init_atom_table (void)
{
	size_t x;

    tre_atoms_free = trealloc_item_init (
		&tre_atoms[TREPTR_FIRST_INDEX],
		NUM_ATOMS - TREPTR_FIRST_INDEX,
		sizeof (struct tre_atom)
	);
	DOTIMES(x, NUM_ATOMS - TREPTR_FIRST_INDEX)
	  tre_atom_types[x + TREPTR_FIRST_INDEX] = TRETYPE_UNUSED;
}

void
treatom_init_builtins (void)
{
    treptr name;
    treptr fun;
    size_t i;

    for (i = 0; tre_builtin_names[i] != NULL; i++) {
        fun = treatom_alloc (TRETYPE_BUILTIN);
        TREATOM_SET_DETAIL(fun, i);
        name = treatom_alloc_symbol (tre_builtin_names[i], treptr_nil, treptr_nil);
        TREATOM_SET_FUN(name, fun);
        EXPAND_UNIVERSE(name);
    }

    for (i = 0; tre_special_names[i] != NULL; i++) {
        fun = treatom_alloc (TRETYPE_SPECIAL);
        TREATOM_SET_DETAIL(fun, i);
        name = treatom_alloc_symbol (tre_special_names[i], treptr_nil, treptr_nil);
        TREATOM_SET_FUN(name, fun);
        EXPAND_UNIVERSE(name);
    }
}

void
treatom_init_keyword_package ()
{
    tre_package_keyword = treatom_alloc_symbol ("", treptr_nil, treptr_nil);
	tresymbolpage_set_package (TREPACKAGE_KEYWORD_INDEX, tre_package_keyword);
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
    treatom_init_truth ();
    treatom_init_atom_table ();
	treatom_init_keyword_package ();
    treatom_init_big_bang ();
    treatom_init_builtins ();
}

treptr
treatom_set_value (treptr atom, treptr value)
{
    return TREATOM_VALUE(atom) = value;
}

treptr
treatom_register_compiled_function (treptr sym, void * fun, void * expander_fun)
{
    if (TREATOM_FUN(sym) == treptr_nil)
        TREATOM_FUN(sym) = treatom_alloc (TRETYPE_FUNCTION);

    TREATOM_COMPILED_FUN(TREATOM_FUN(sym)) = fun;
    TREATOM_COMPILED_EXPANDER(TREATOM_FUN(sym)) = expander_fun;
	return sym;
}

treptr
treatom_get_value (treptr atom)
{
    return TREATOM_VALUE(atom);
}

treptr
treatom_get_function (treptr atom)
{
	return TREPTR_IS_BUILTIN(atom) ? atom : TREATOM_FUN(atom);
}

treptr
treatom_set_function (treptr atom, treptr value)
{
    return TREATOM_FUN(atom) = value;
}

treptr
treatom_set_binding (treptr atom, treptr value)
{
    return TREATOM_BINDING(atom) = value;
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
	    	return treerror (treptr_invalid, "atom table full");
    }

    atomi = ((size_t) item - (size_t) tre_atoms) / sizeof (struct tre_atom);
    TREGC_ALLOC_ATOM(atomi);
    ATOM_SET(atomi, type);

	return TRETYPE_INDEX_TO_PTR(type, atomi);
}


treptr
treatom_alloc_symbol (char * symbol, treptr package, treptr value)
{
    treptr  atom = treatom_alloc (TRETYPE_SYMBOL);
    size_t  atomi = TREPTR_INDEX(atom);

    if (value == treptr_invalid)
		value = atom;

    symbol = tresymbol_add (symbol);
    ATOM_SET_NAME(atomi, symbol);
    tre_atoms[atomi].value = value;
    tre_atoms[atomi].package = package;

	tresymbolpage_add (atom);

	return atom;
}

void
treatom_free (treptr x)
{
    if (TREATOM_TYPE(x) == TRETYPE_SYMBOL) {
		tresymbolpage_remove (x);
        tresymbol_free (TREATOM_DETAIL(x));
    }

    TREATOM_TYPE(x) = TRETYPE_UNUSED;
	trealloc_free_item (&tre_atoms_free, (void **) &tre_atoms[TREPTR_INDEX(x)]);
}

treptr
treatom_number_get (double value, int type)
{
    treptr atom;
    size_t num;

    num = trenumber_alloc (value, type);
    atom = treatom_alloc (TRETYPE_NUMBER);
    TREATOM_SET_DETAIL(atom, num);

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
	return tresymbolpage_find (symbol, package);
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
		if (sscanf (symbol, "%lf", &dvalue) != 1) {
			printf ("Illegal number: '%s'", symbol);
			treerror (treptr_nil, "illegal number format");
		}
        return treatom_number_get (dvalue, TRENUMTYPE_FLOAT);
	}

    return treatom_alloc_symbol (symbol, package, treptr_invalid);
}

void
treatom_remove (treptr x)
{
    switch (TREPTR_TYPE(x)) {
        case TRETYPE_NUMBER: trenumber_free (x); break;
        case TRETYPE_ARRAY:  trearray_free  (x); break;
        case TRETYPE_STRING: trestring_free (x); break;
    }

    treatom_free (x);
}

treptr
treatom_body_to_var (treptr body)
{        
    size_t a;
    size_t b; 
	treptr tmp;

    for (a = 0; a < NUM_ATOMS; a++) {
        if (tre_atom_types[a] != TRETYPE_FUNCTION && tre_atom_types[a] != TRETYPE_MACRO)
	    	continue;

        if (!TREPTR_IS_CONS(tre_atoms[a].value))
            continue;

        tmp = CDR(tre_atoms[a].value);
        if (NULLP(tmp) || CAR(tmp) != body)
	    	continue;

        for (b = 0; b < NUM_ATOMS; b++)
            if (tre_atom_types[b] == TRETYPE_SYMBOL
					&& tre_atoms[b].detail != NULL
					&& tre_atoms[b].fun == TREATOM_INDEX_TO_PTR(a))
                return TREATOM_INDEX_TO_PTR(b);
    }

    return treptr_nil;
}

treptr
treatom_fun_body (treptr atomp)
{
    treptr fun;

    if (TREPTR_IS_SYMBOL(atomp) == FALSE) {
        treerror_internal (atomp, "variable expected");
		return treptr_nil;
    }

    fun = TREATOM_FUN(atomp);
    if (fun != treptr_nil)
        return CDR(TREATOM_VALUE(fun));

    return treptr_nil;
}
