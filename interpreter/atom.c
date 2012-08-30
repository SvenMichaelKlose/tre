/*
 * tré – Copyright (c) 2005–2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "number.h"
#include "list.h"
#include "string2.h"
#include "eval.h"
#include "error.h"
#include "array.h"
#include "diag.h"
#include "gc.h"
#include "builtin.h"
#include "special.h"
#include "env.h"
#include "io.h"
#include "symbol.h"
#include "thread.h"
#include "alloc.h"
#include "util.h"

/*
 * The atom list is a growing table.
 */
void * tre_atoms_free;
struct tre_atom tre_atoms[NUM_ATOMS];

#define TREPTR_NIL_INDEX	0 /* NIL and T are allocated manually. */
#define TREPTR_T_INDEX		1
#define TREPTR_FIRST_INDEX	2 /* First allocator index. */

#define TREPACKAGE_KEYWORD_INDEX	1

const treptr treptr_nil = TRETYPE_INDEX_TO_PTR(TRETYPE_VARIABLE, TREPTR_NIL_INDEX);
const treptr treptr_t = TRETYPE_INDEX_TO_PTR(TRETYPE_VARIABLE, TREPTR_T_INDEX);
const treptr treptr_invalid = (treptr) -1;

treptr treptr_universe; /* *UNIVERSE* variable */

treptr treatom_quote;
treptr treatom_backquote;
treptr treatom_quasiquote;
treptr treatom_quasiquote_splice;
treptr treatom_function;
treptr treatom_values;
treptr treatom_lambda;

treptr tre_package_keyword;

void
treatom_init_truth (void)
{
    /* Initialise NIL atom manually to make list functions work. */
    ATOM_SET(TREPTR_NIL_INDEX, tresymbol_add ("NIL"), treptr_nil, TRETYPE_VARIABLE);
    tre_atoms[TREPTR_NIL_INDEX].value = TRETYPE_INDEX_TO_PTR(TRETYPE_VARIABLE, TREPTR_NIL_INDEX);
    tre_atoms[TREPTR_NIL_INDEX].fun = treptr_nil;
    tre_atoms[TREPTR_NIL_INDEX].binding = treptr_nil;
	tresymbolpage_add (treptr_nil);

    ATOM_SET(TREPTR_T_INDEX, tresymbol_add ("T"), treptr_nil, TRETYPE_VARIABLE);
    tre_atoms[TREPTR_T_INDEX].value = TRETYPE_INDEX_TO_PTR(TRETYPE_VARIABLE, TREPTR_T_INDEX);
    tre_atoms[TREPTR_T_INDEX].fun = treptr_nil;
    tre_atoms[TREPTR_T_INDEX].binding = treptr_nil;
	tresymbolpage_add (treptr_t);
}

void
treatom_init_atom_table (void)
{
	ulong x;

    tre_atoms_free = trealloc_item_init (
		&tre_atoms[TREPTR_FIRST_INDEX],
		NUM_ATOMS - TREPTR_FIRST_INDEX,
		sizeof (struct tre_atom)
	);
	DOTIMES(x, NUM_ATOMS - TREPTR_FIRST_INDEX) {
	  tre_atoms[x + TREPTR_FIRST_INDEX].type = TRETYPE_UNUSED;
	}
}

void
treatom_init_builtins (void)
{
    treptr   atom;
    ulong  i;

    /* Builtin functions. */
    for (i = 0; tre_builtin_names[i] != NULL; i++) {
        atom = treatom_alloc (tre_builtin_names[i], treptr_nil,
                              TRETYPE_BUILTIN, treptr_nil);
        TREATOM_SET_DETAIL(atom, i);
        EXPAND_UNIVERSE(atom);
    }

    /* Special forms. */
    for (i = 0; tre_special_names[i] != NULL; i++) {
        atom = treatom_alloc (tre_special_names[i], treptr_nil,
                              TRETYPE_SPECIAL, treptr_nil);
        TREATOM_SET_DETAIL(atom, i);
        EXPAND_UNIVERSE(atom);
    }
}

void
treatom_init_keyword_package ()
{
    tre_package_keyword = treatom_alloc ("", treptr_nil, TRETYPE_PACKAGE, treptr_nil);
	tresymbolpage_set_package (TREPACKAGE_KEYWORD_INDEX, tre_package_keyword);
}

void
treatom_init_big_bang ()
{
    treptr_universe = treatom_alloc ("*UNIVERSE*", treptr_nil, TRETYPE_VARIABLE, treptr_nil);
    EXPAND_UNIVERSE(treptr_t);
    EXPAND_UNIVERSE(tre_package_keyword);
	MAKE_VAR("*KEYWORD-PACKAGE*", tre_package_keyword);
}

/*
 * Initialise atom table.
 */
void
treatom_init (void)
{
    treatom_init_truth ();
    treatom_init_atom_table ();
	treatom_init_keyword_package ();
    treatom_init_big_bang ();
    treatom_init_builtins ();
}

void
treatom_set_name (treptr atom, char *name)
{
	if (TREATOM_VALUE(atom) != atom)
		trewarn (atom, "changing name of %s '%s'", treerror_typename (TREPTR_TYPE(atom)), TREATOM_NAME(atom));
    TREATOM_NAME(atom) = name;
}

treptr
treatom_set_value (treptr atom, treptr value)
{
    return TREATOM_VALUE(atom) = value;
}

treptr
treatom_register_compiled_function (treptr sym, void * fun)
{
    if (TREATOM_FUN(sym) == treptr_nil)
        TREATOM_FUN(sym) = treatom_alloc (NULL, treptr_nil, TRETYPE_FUNCTION, treptr_nil);

    TREATOM_COMPILED_FUN(TREATOM_FUN(sym)) = fun;
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
	return (TREPTR_IS_BUILTIN(atom)) ?
			atom :
    		TREATOM_FUN(atom);
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

/* Allocate an atom. */
treptr
treatom_alloc (char * symbol, treptr package, int type, treptr value)
{
    ulong  atomi;
    treptr   ret;
	void     * item;

	item = trealloc_item (&tre_atoms_free);
	if (!item) {
        tregc_force ();
		item = trealloc_item (&tre_atoms_free);
    	if (!item)
	    	return treerror (treptr_invalid, "atom table full");
    }

    atomi = ((ulong) item - (ulong) tre_atoms) / sizeof (struct tre_atom);
    TREGC_ALLOC_ATOM(atomi);

    /* Make symbol. */
    if (value == treptr_invalid)
		value = TRETYPE_INDEX_TO_PTR(type, atomi);

    symbol = tresymbol_add (symbol);

    ATOM_SET(atomi, symbol, package, type);
    TREATOM_VALUE(atomi) = value;

    /* Make typed pointer. */
    ret = TRETYPE_INDEX_TO_PTR(type, atomi);
	tresymbolpage_add (ret);
	return ret;
}

/* Free an atom. */
void
treatom_free (treptr x)
{
    TREATOM_TYPE(x) = TRETYPE_UNUSED;

    /* Release symbol string. */
    if (TREATOM_NAME(x) != NULL) {
		tresymbolpage_remove (x);
        tresymbol_free (TREATOM_NAME(x));
    	TREATOM_NAME(x) = NULL;
    }

	trealloc_free_item (&tre_atoms_free, &tre_atoms[TREPTR_INDEX(x)]);
}

/*
 * Get number atom.
 *
 * Already existing numbers with the same value are not reused.
 */
treptr
treatom_number_get (double value, int type)
{
    treptr   atom;
    ulong  num;

    atom = treatom_alloc (NULL, treptr_nil, TRETYPE_NUMBER, treptr_nil);
	CHKPTR(atom);
    num = trenumber_alloc (value, type);
    TREATOM_SET_DETAIL(atom, num);
	CHKPTR(atom);

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

/* Seek symbolic atom. */
treptr
treatom_seek (char * symbol, treptr package)
{
	return tresymbolpage_find (symbol, package);
}

/*
 * Seek or create symbolic atom.
 *
 * Create or reuse atom of name 'symbol'.
 */
treptr
treatom_get (char * symbol, treptr package)
{   
    treptr  atom;
	double  dvalue;

    /* Reuse existing atom. */
    atom = treatom_seek (symbol, package);
    if (atom != ATOM_NOT_FOUND)
		return atom;

    /* Create number. */
    if (trenumber_is_value (symbol)) {
		if (sscanf (symbol, "%lf", &dvalue) != 1) {
			printf ("Illegal number: '%s'", symbol);
			treerror (treptr_nil, "illegal number format");
		}
        return treatom_number_get (dvalue, TRENUMTYPE_FLOAT);
	}

    return treatom_alloc (symbol, package, TRETYPE_VARIABLE, treptr_invalid);
}

/*
 * Remove atom and object.
 */
void
treatom_remove (treptr el)
{
    /* Do type specific clean-up. */
    switch (TREPTR_TYPE(el)) {
        case TRETYPE_NUMBER:
            trenumber_free (el);
	    	break;

        case TRETYPE_ARRAY:
	    	trearray_free (el);
	    	break;

        case TRETYPE_STRING:
	    	trestring_free (el);
	    	break;
    }

    treatom_free (el);
}

/* Lookup variable that points to function containing body. */
treptr
treatom_body_to_var (treptr body)
{        
    ulong  a;
    ulong  b; 
	treptr    tmp;

    for (a = 0; a < NUM_ATOMS; a++) {
        if (tre_atoms[a].type != TRETYPE_FUNCTION && tre_atoms[a].type != TRETYPE_MACRO)
	    	continue;

        tmp = CDR(tre_atoms[a].value);
        if (NULLP(tmp) || CAR(tmp) != body)
	    	continue;

        for (b = 0; b < NUM_ATOMS; b++)
            if (tre_atoms[b].type == TRETYPE_VARIABLE
					&& tre_atoms[b].name != NULL
					&& tre_atoms[b].fun == TREATOM_INDEX_TO_PTR(a))
                return TREATOM_INDEX_TO_PTR(b);
    }

    return treptr_nil;
}

/* Return body of user-defined form. */
treptr
treatom_fun_body (treptr atomp)
{
    treptr fun;

    if (TREPTR_IS_VARIABLE(atomp) == FALSE) {
        treerror_internal (atomp, "variable expected");
		return treptr_nil;
    }

    fun = TREATOM_FUN(atomp);
    if (fun != treptr_nil)
        return CDR(TREATOM_VALUE(fun));

    return treptr_nil;
}
