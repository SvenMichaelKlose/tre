/*
 * tré – Copyright (c) 2005-2007,2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ATOM_H
#define TRE_ATOM_H

#include "ptr.h"

typedef char tre_type;

extern void * tre_atoms_free;
extern void * tre_atoms[NUM_ATOMS];
extern tre_type tre_atom_types[NUM_ATOMS];

extern treptr treptr_universe;
extern treptr tre_package_keyword;

#define ATOM_SET(index, typ) \
	tre_atoms[index] = NULL; \
	tre_atom_types[index] = typ

#define EXPAND_UNIVERSE(ptr) \
    (TRESYMBOL_VALUE(treptr_universe) = CONS(ptr, TRESYMBOL_VALUE(treptr_universe)))

#define MAKE_HOOK_SYMBOL(var, symbol_name) \
    var = treatom_alloc_symbol (symbol_name, TRECONTEXT_PACKAGE(), treptr_nil); \
    EXPAND_UNIVERSE(var)

#define MAKE_SYMBOL(symbol_name, init) \
    if (treatom_seek (symbol_name, TRECONTEXT_PACKAGE()) == ATOM_NOT_FOUND) { \
        EXPAND_UNIVERSE(treatom_alloc_symbol (symbol_name, TRECONTEXT_PACKAGE(), init)); \
    } else { \
        TRESYMBOL_VALUE(treatom_get (symbol_name, TRECONTEXT_PACKAGE())) = init; \
    }

extern void treatom_init (void);

extern treptr treatom_seek (char *, treptr package);
#define ATOM_NOT_FOUND  treptr_invalid

extern treptr treatom_get (char *, treptr package);

extern treptr treatom_number_get (double, int type);

/* for compiled code */
extern treptr trenumber_get (double);
extern treptr trechar_get (double);
extern treptr treatom_get_value (treptr atom);
extern treptr treatom_get_function (treptr atom);
extern treptr treatom_register_compiled_function (treptr sym, void * fun, void * expander_fun);

extern treptr treatom_alloc (int type);
extern treptr treatom_alloc_symbol (char * symbol, treptr package, treptr value);
extern void   treatom_remove (treptr);

extern treptr treatom_set_value (treptr atom, treptr value);
extern treptr treatom_sym_set_value (char * symbol, treptr value);
extern treptr treatom_set_function (treptr atom, treptr value);

extern treptr treatom_body_to_var (treptr body);

extern treptr treatom_fun_body (treptr atomp);

#endif
