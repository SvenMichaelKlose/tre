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

#define ATOM(ptr)        (tre_atoms[TREPTR_INDEX(ptr)])
#define ATOM_TYPE(ptr)   (tre_atom_types[TREPTR_INDEX(ptr)])

#define ATOM_SET(index, typ) \
	tre_atoms[index] = NULL; \
	tre_atom_types[index] = typ

extern treptr atom_alloc (int type);
extern void   atom_remove (treptr);

extern treptr atom_body_to_var (treptr body);
extern treptr atom_fun_body (treptr atomp);

extern void atom_init (void);

#endif
