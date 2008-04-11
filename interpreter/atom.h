/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Atom-related section.
 */

#ifndef TRE_ATOM_H
#define TRE_ATOM_H

typedef unsigned treptr;

#define ATOM_EXPR		0
#define ATOM_VARIABLE	1
#define ATOM_NUMBER		2
#define ATOM_STRING		3
#define ATOM_ARRAY		4
#define ATOM_BUILTIN	5
#define ATOM_SPECIAL	6
#define ATOM_MACRO		7
#define ATOM_FUNCTION		8
#define ATOM_USERSPECIAL	9
#define ATOM_PACKAGE	10
#define ATOM_MAXTYPE	10
#define ATOM_UNUSED		-1

#define TREPTR_NIL()	TYPEINDEX_TO_TREPTR(ATOM_VARIABLE, 0)

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

extern treptr tre_package_keyword;

#define TRE_INDEX_TO_ATOM(index)	(tre_atoms[index])

#define ATOM_SET(index, nam, pack, typ) \
	tre_atoms[index].name = nam;	\
	tre_atoms[index].value = treptr_nil;	\
	tre_atoms[index].fun = treptr_nil;	\
	tre_atoms[index].binding = treptr_nil;	\
	tre_atoms[index].package = pack;	\
	tre_atoms[index].type = typ;	\
	tre_atoms[index].detail = NULL

#define TREATOM_FLAGS	\
	(-1 << TREPTR_INDEX_WIDTH)
#define TYPEINDEX_TO_TREPTR(type, index) \
	((type << TREPTR_INDEX_WIDTH) | index)
#define TREATOM_PTR(idx)	\
	(TYPEINDEX_TO_TREPTR(TRE_INDEX_TO_ATOM(idx).type, idx))

#define ATOM_TO_TREPTR(index) \
	TYPEINDEX_TO_TREPTR(tre_atoms[index].type, index)
#define TREPTR_TO_ATOM(ptr)	TRE_INDEX_TO_ATOM(TREPTR_INDEX(ptr))

#define TREATOM_NAME(ptr)	(TREPTR_TO_ATOM(ptr).name)
#define TREATOM_TYPE(ptr)	(TREPTR_TO_ATOM(ptr).type)
#define TREATOM_VALUE(ptr)	(TREPTR_TO_ATOM(ptr).value)
#define TREATOM_FUN(ptr)	(TREPTR_TO_ATOM(ptr).fun)
#define TREATOM_BINDING(ptr)	(TREPTR_TO_ATOM(ptr).binding)
#define TREATOM_PACKAGE(ptr)	(TREPTR_TO_ATOM(ptr).package)
#define TREATOM_DETAIL(ptr)		(TREPTR_TO_ATOM(ptr).detail)
#define TREATOM_STRING(ptr)		((struct tre_string *) TREATOM_DETAIL(ptr))
#define TREATOM_STRINGP(ptr)	((char *) &(TREATOM_STRING(ptr)->str))
#define TREATOM_SET_DETAIL(ptr, val)	(TREPTR_TO_ATOM(ptr).detail = (void *) val)
#define TREATOM_SET_STRING(ptr, val)	(TREATOM_DETAIL(ptr) = (struct tre_string *) val)

#define TREPTR_TYPE(ptr)	(ptr >> TREPTR_INDEX_WIDTH)
#define TREPTR_INDEX(ptr)	(ptr & ~TREATOM_FLAGS)
#define TREPTR_IS_EXPR(ptr)		((ptr & TREATOM_FLAGS) == 0)
#define TREPTR_IS_ATOM(ptr)		(TREPTR_IS_EXPR(ptr) == FALSE)
#define TREPTR_IS_VARIABLE(ptr)	(TREPTR_TYPE(ptr) == ATOM_VARIABLE)
#define TREPTR_IS_SYMBOL(ptr)	(TREPTR_IS_VARIABLE(ptr) && \
								 TREATOM_VALUE(ptr) == ptr)
#define TREPTR_IS_NUMBER(ptr)		(TREPTR_TYPE(ptr) == ATOM_NUMBER)
#define TREPTR_IS_STRING(ptr)		(TREPTR_TYPE(ptr) == ATOM_STRING)
#define TREPTR_IS_ARRAY(ptr)		(TREPTR_TYPE(ptr) == ATOM_ARRAY)
#define TREPTR_IS_BUILTIN(ptr)		(TREPTR_TYPE(ptr) == ATOM_BUILTIN)
#define TREPTR_IS_SPECIAL(ptr)		(TREPTR_TYPE(ptr) == ATOM_SPECIAL)
#define TREPTR_IS_MACRO(ptr)		(TREPTR_TYPE(ptr) == ATOM_MACRO)
#define TREPTR_IS_FUNCTION(ptr)	(TREPTR_TYPE(ptr) == ATOM_FUNCTION)

#define TREPTR_TRUTH(test)	((test) ? treptr_t : treptr_nil)

#define EXPAND_UNIVERSE(ptr) \
    (TREATOM_VALUE(treptr_universe) = CONS(ptr, TREATOM_VALUE(treptr_universe)))

extern const treptr treptr_nil;
extern const treptr treptr_t;
extern const treptr treptr_invalid;
extern treptr treptr_universe;

/* Already looked-up atoms. */
extern treptr treatom_quote;
extern treptr treatom_lambda;
extern treptr treatom_backquote;
extern treptr treatom_quasiquote;
extern treptr treatom_quasiquote_splice;
extern treptr treatom_function;
extern treptr treatom_values;

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
