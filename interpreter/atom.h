/*
 * tré – Copyright (c) 2005-2007,2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ATOM_H
#define TRE_ATOM_H

#include "ptr.h"

typedef char tre_type;

extern void * tre_atoms_free;
extern void * tre_atoms[NUM_ATOMS];
extern tre_type tre_atom_types[NUM_ATOMS];

#define ATOM_SET(index, typ) \
	tre_atoms[index] = NULL; \
	tre_atom_types[index] = typ

extern void treatom_init (void);

extern treptr treatom_alloc (int type);
extern void   treatom_remove (treptr);

extern treptr treatom_body_to_var (treptr body);

extern treptr treatom_fun_body (treptr atomp);

/* for compiled code */
extern treptr treatom_register_compiled_function (treptr sym, void * fun, void * expander_fun);

#endif
