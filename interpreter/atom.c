/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Atom related section.
 */

#include "lisp.h"
#include "atom.h"
#include "number.h"
#include "list.h"
#include "sequence.h"
#include "string.h"
#include "eval.h"
#include "error.h"
#include "array.h"
#include "diag.h"
#include "gc.h"
#include "util.h"
#include "builtin.h"
#include "special.h"
#include "env.h"
#include "io.h"
#include "main.h"
#include "symbol.h"
#include "print.h"

#define _GNU_SOURCE
#include <string.h>
#include <strings.h>
#include <stdlib.h>

/*
 * The atom list is a growing table.
 */
struct lisp_atom lisp_atoms[NUM_ATOMS];
lispptr lisp_atoms_free;

const lispptr lispptr_nil = TYPEINDEX_TO_LISPPTR(1, 0);
const lispptr lispptr_t = TYPEINDEX_TO_LISPPTR(1, 1);
const lispptr lispptr_invalid = (lispptr) -1;

lispptr lispptr_universe; /* *UNIVERSE* variable */

lispptr lispatom_quote;
lispptr lispatom_backquote;
lispptr lispatom_quasiquote;
lispptr lispatom_quasiquote_splice;
lispptr lispatom_function;
lispptr lispatom_values;
lispptr lispatom_lambda;

lispptr lisp_package_keyword;

void
lispatom_init_nil (void)
{
    /* Initialise NIL atom manually to make list functions work. */
    ATOM_SET(0, lispsymbol_add ("NIL"), lispptr_nil, ATOM_VARIABLE);

    /* Reinitialize every slot that takes NIL. */
    lisp_atoms[0].value = TYPEINDEX_TO_LISPPTR(ATOM_VARIABLE, 0), 1;
    lisp_atoms[0].fun = lispptr_nil;
    lisp_atoms[0].binding = lispptr_nil;
}

void
lispatom_init_atom_table (void)
{
    lispptr   p;
    unsigned  i;

    /* Prepare unused atom entries. */
    for (i = 1; i < NUM_ATOMS; i++) {
        ATOM_SET(i, NULL, lispptr_nil, ATOM_UNUSED);
    }

    /* Put atom entries on the free atom list, except NIL. */
    p = lispptr_nil;
    for (i = NUM_ATOMS - 1; i > 0; i--)
        p = CONS(i, p);
    lisp_atoms_free = p;
}

void
lispatom_init_builtins (void)
{
    lispptr   atom;
    unsigned  i;

    /* Builtin functions. */
    for (i = 0; lisp_builtin_names[i] != NULL; i++) {
        atom = lispatom_alloc (lisp_builtin_names[i], lispptr_nil,
                               ATOM_BUILTIN, lispptr_nil);
        LISPATOM_SET_DETAIL(atom, i);
        EXPAND_UNIVERSE(atom);
    }

    /* Special forms. */
    for (i = 0; lisp_special_names[i] != NULL; i++) {
        atom = lispatom_alloc (lisp_special_names[i], lispptr_nil,
                               ATOM_SPECIAL, lispptr_nil);
        LISPATOM_SET_DETAIL(atom, i);
        EXPAND_UNIVERSE(atom);
    }
}

/*
 * Initialise atom table.
 */
void
lispatom_init (void)
{
    lispptr t;

    lispatom_init_nil ();
    lispatom_init_atom_table ();

    t = lispatom_get ("T", lispptr_nil);
    lisp_package_keyword = lispatom_alloc ("", lispptr_nil, ATOM_PACKAGE, lispptr_nil);

    lispptr_universe = lispatom_alloc ("*UNIVERSE*", lispptr_nil, ATOM_VARIABLE, lispptr_nil);
    EXPAND_UNIVERSE(t);
    EXPAND_UNIVERSE(lisp_package_keyword);
    lispatom_init_builtins ();
}

void
lispatom_set_name (lispptr atom, char *name)
{
    LISPATOM_NAME(atom) = name;
}

void
lispatom_set_value (lispptr atom, lispptr value)
{
    LISPATOM_VALUE(atom) = value;
}

void
lispatom_set_function (lispptr atom, lispptr value)
{
    LISPATOM_FUN(atom) = value;
}

void
lispatom_set_binding (lispptr atom, lispptr value)
{
    LISPATOM_BINDING(atom) = value;
}

/* Allocate an atom. */
lispptr
lispatom_alloc (char *symbol, lispptr package, int type, lispptr value)
{
    unsigned  atomi;
    lispptr   ntop;

    if (lisp_atoms_free == lispptr_nil) {
        lispgc_force ();
        if (lisp_atoms_free == lispptr_nil)
	    return lisperror (lispptr_invalid, "atom table full");
    }

    /* Pop free atom from free atom list. */
    atomi = CAR(lisp_atoms_free);
#ifdef LISP_DIAGNOSTICS
    if (LISPPTR_TO_ATOM(atomi)->type != ATOM_UNUSED)
	lisperror_internal (lispptr_invalid, "trying to free unused atom");
#endif
    ntop = CDR(lisp_atoms_free);
    lisplist_free (lisp_atoms_free);
    lisp_atoms_free = ntop;

    /* Make self-referencing ordinary. */
    if (value == lispptr_invalid)
	value = TYPEINDEX_TO_LISPPTR(type, atomi);

    symbol = lispsymbol_add (symbol);
    ATOM_SET(atomi, symbol, package, type);
    lispatom_set_value (atomi, value);
    LISP_UNMARK(lispgc_atommarks, atomi);

    /* Return typed pointer. */
    return TYPEINDEX_TO_LISPPTR(type, atomi);
}

/* Free an atom. */
void
lispatom_free (lispptr atom)
{
#ifdef LISP_DIAGNOSTICS
    lispptr  i;

    /* Check if atom is already on the free atom list. */
    if (lisp_is_initialized) {
        _DOLIST(i, lisp_atoms_free) {
            if (_CAR(i) == LISPPTR_INDEX(atom))
                lisperror_internal (lispptr_invalid,
				    "atom %d already on free list",
				    LISPPTR_INDEX(atom));
        }
     }

    /* Check if atom is already marked as being unused. */
    if (LISPPTR_TO_ATOM(atom)->type == ATOM_UNUSED)
	lisperror_internal (lispptr_invalid, "trying to free unused atom");
#endif

                    if (TYPEINDEX_TO_LISPPTR(LISPATOM_TYPE(atom), atom)
== lispatom_quasiquote)
lisperror_internal (lispptr_invalid, "!!!!!!!!!!!!!!!");

    if (LISPATOM_VALUE(atom) != atom)
        lispatom_set_value (atom, lispptr_nil);
    lispatom_set_function (atom, lispptr_nil);
    lispatom_set_binding (atom, lispptr_nil);
    LISPPTR_TO_ATOM(atom)->type = ATOM_UNUSED;

    /* Add entry to list of free atoms. */
    lisp_atoms_free = CONS(LISPPTR_INDEX(atom), lisp_atoms_free);

    /* Release symbol string. */
    if (LISPATOM_NAME(atom) != NULL) {
        lispsymbol_free (LISPATOM_NAME(atom));
    	LISPATOM_NAME(atom) = NULL;
    }
}

/*
 * Get number atom.
 *
 * Already existing numbers with the same value are not reused.
 */
lispptr
lispatom_number_get (float value, int type)
{
    lispptr   atom;
    unsigned  num;

    atom = lispatom_alloc (NULL, lispptr_nil, ATOM_NUMBER, lispptr_nil);
    num = lispnumber_alloc (value, type);
    LISPATOM_SET_DETAIL(atom, num);

    return atom;
}

/* Seek symbolic atom. */
lispptr
lispatom_seek (char *symbol, lispptr package)
{   
    unsigned  a;

    /* Reuse existing atom. */
    for (a = 0; a < NUM_ATOMS; a++) {
	if (lisp_atoms[a].type == ATOM_UNUSED)
	    continue;

	if (lisp_atoms[a].name != NULL
	    && lisp_atoms[a].package == package
            && strcmp (lisp_atoms[a].name, symbol) == 0) {
	    return ATOM_TO_LISPPTR(a);
        }
    }

    return ATOM_NOT_FOUND;
}

/*
 * Seek or create symbolic atom.
 *
 * Create or reuse atom of name 'symbol'.
 */
lispptr
lispatom_get (char *symbol, lispptr package)
{   
    lispptr  atom;

    /* Reuse existing atom. */
    atom = lispatom_seek (symbol, package);
    if (atom != ATOM_NOT_FOUND)
	return atom;

    /* Create number. */
    if (lispnumber_is_value (symbol))
        return lispatom_number_get (valuetofloat (symbol), LISPNUMTYPE_FLOAT);

    return lispatom_alloc (symbol, package, ATOM_VARIABLE, lispptr_invalid);
}

/*
 * Remove atom and object.
 */
void
lispatom_remove (lispptr el)
{
    /* Do type specific clean-up. */
    switch (LISPPTR_TYPE(el)) {
        case ATOM_NUMBER:
            lispnumber_free (el);
	    break;

        case ATOM_ARRAY:
	    lisparray_free (el);
	    break;

        case ATOM_STRING:
	    lispstring_free (el);
	    break;
    }

    lispatom_free (el);
}

/* Lookup variable that points to function containing body. */
lispptr
lispatom_body_to_var (lispptr body)
{        
    unsigned  a;
    unsigned  b; 

    for (a = 0; a < NUM_ATOMS; a++) {
        if (lisp_atoms[a].type != ATOM_FUNCTION &&
	    lisp_atoms[a].type != ATOM_MACRO)
	    continue;

        if (CAR(CDR(lisp_atoms[a].value)) != body)
	    continue;

        for (b = 0; b < NUM_ATOMS; b++) {
            if (lisp_atoms[b].type == ATOM_VARIABLE &&
		lisp_atoms[b].name != NULL &&
                lisp_atoms[b].fun == LISPATOM_PTR(a))
                return LISPATOM_PTR(b);
        }
    }

    return lispptr_nil;
}

/* Return body of user-defined form. */
lispptr
lispatom_fun_body (lispptr atomp)
{
    lispptr fun;

    if (LISPPTR_IS_VARIABLE(atomp) == FALSE) {
        lisperror_internal (atomp, "variable expected");
	return lispptr_nil;
    }

    fun = LISPATOM_FUN(atomp);
    if (fun != lispptr_nil)
        return CDR(LISPATOM_VALUE(fun));

    return lispptr_nil;
}
