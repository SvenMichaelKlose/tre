/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Atom-related section.
 */

#ifndef TRE_ATOM_H
#define TRE_ATOM_H

#include "ptr.h"

/* Atom table. */
struct tre_atom {
    char   	*name;
    char	type;
    treptr	value;
    treptr	fun;
    treptr	binding;
    treptr	package;
    void 	*detail;
};

extern struct tre_atom tre_atoms[NUM_ATOMS];
extern treptr tre_atoms_free;

extern treptr treptr_universe;
extern treptr tre_package_keyword;

#define TRE_ATOM(index)	(tre_atoms[index])

#define ATOM_SET(index, nam, pack, typ) \
	tre_atoms[index].name = nam;	\
	tre_atoms[index].value = treptr_nil;	\
	tre_atoms[index].fun = treptr_nil;	\
	tre_atoms[index].binding = treptr_nil;	\
	tre_atoms[index].package = pack;	\
	tre_atoms[index].type = typ;	\
	tre_atoms[index].detail = NULL

#define EXPAND_UNIVERSE(ptr) \
    (TREATOM_VALUE(treptr_universe) = CONS(ptr, TREATOM_VALUE(treptr_universe)))

/* Initialise this section. */
extern void treatom_init (void);

/* Lookup atom. */
extern treptr treatom_seek (char *, treptr package);
#define ATOM_NOT_FOUND  ((treptr) -2)

/* Lookup or create atom. */
extern treptr treatom_get (char *, treptr package);

/* Create new number atom for computational values. */
extern treptr treatom_number_get (double, int type);

extern treptr treatom_alloc (char *symbol, treptr package, int type, treptr value);
extern void treatom_free (treptr);

extern void treatom_remove (treptr);

extern void treatom_set_value (treptr atom, treptr value);
extern void treatom_set_function (treptr atom, treptr value);
extern void treatom_set_binding (treptr atom, treptr value);

/* Lookup variable that points to function containing body. */
extern treptr treatom_body_to_var (treptr body);

/* Return body of function or macro. */
extern treptr treatom_fun_body (treptr atomp);

#endif
