/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Atom-related section.
 */

#ifndef LISP_ATOM_H
#define LISP_ATOM_H

typedef unsigned lispptr;

#define ATOM_EXPR		0
#define ATOM_VARIABLE		1
#define ATOM_NUMBER		2
#define ATOM_STRING		3
#define ATOM_ARRAY		4
#define ATOM_BUILTIN		5
#define ATOM_SPECIAL		6
#define ATOM_MACRO		7
#define ATOM_FUNCTION		8
#define ATOM_USERSPECIAL	9
#define ATOM_PACKAGE		10
#define ATOM_MAXTYPE		10
#define ATOM_UNUSED		-1

#define LISPPTR_NIL()	TYPEINDEX_TO_LISPPTR(ATOM_VARIABLE, 0)

/* Atom table. */
struct lisp_atom {
    char   	*name;
    char	type;
    lispptr	value;
    lispptr	fun;
    lispptr	binding;
    lispptr	package;
    void 	*detail;
};

extern struct lisp_atom lisp_atoms[NUM_ATOMS];
extern lispptr lisp_atoms_free;

extern lispptr lisp_package_keyword;

#define LISP_ATOM(atomi)	(&lisp_atoms[atomi])

#define ATOM_SET(atomi, nam, pack, typ) \
	lisp_atoms[atomi].name = nam;	\
	lisp_atoms[atomi].value = lispptr_nil;	\
	lisp_atoms[atomi].fun = lispptr_nil;	\
	lisp_atoms[atomi].binding = lispptr_nil;	\
	lisp_atoms[atomi].package = pack;	\
	lisp_atoms[atomi].type = typ;	\
	lisp_atoms[atomi].detail = NULL

#define LISPATOM_FLAGS		(-1 << LISPPTR_TYPESHIFT)
#define TYPEINDEX_TO_LISPPTR(type, index) \
	((type << LISPPTR_TYPESHIFT) | index)
#define LISPATOM_PTR(idx)	(TYPEINDEX_TO_LISPPTR(LISP_ATOM(idx)->type, \
			                              idx))

#define ATOM_TO_LISPPTR(index) \
	TYPEINDEX_TO_LISPPTR(lisp_atoms[index].type, index)
#define LISPPTR_TO_ATOM(ptr)	(LISP_ATOM(LISPPTR_INDEX(ptr)))

#define LISPATOM_NAME(ptr)	(LISPPTR_TO_ATOM(ptr)->name)
#define LISPATOM_TYPE(ptr)	(LISPPTR_TO_ATOM(ptr)->type)
#define LISPATOM_VALUE(ptr)	(LISPPTR_TO_ATOM(ptr)->value)
#define LISPATOM_FUN(ptr)	(LISPPTR_TO_ATOM(ptr)->fun)
#define LISPATOM_BINDING(ptr)	(LISPPTR_TO_ATOM(ptr)->binding)
#define LISPATOM_PACKAGE(ptr)	(LISPPTR_TO_ATOM(ptr)->package)
#define LISPATOM_DETAIL(ptr)	(LISPPTR_TO_ATOM(ptr)->detail)
#define LISPATOM_SET_DETAIL(ptr, val)	(LISPPTR_TO_ATOM(ptr)->detail = (void *) val)
#define LISPATOM_STRING(ptr)	((struct lisp_string *) LISPATOM_DETAIL(ptr))
#define LISPATOM_SET_STRING(ptr, val)	(LISPATOM_DETAIL(ptr) = (struct lisp_string *) val)
#define LISPATOM_STRINGP(ptr)	((char *) &(LISPATOM_STRING(ptr)->str))

#define LISPPTR_TYPE(ptr)	(ptr >> LISPPTR_TYPESHIFT)
#define LISPPTR_INDEX(ptr)	(ptr & ~LISPATOM_FLAGS)
#define LISPPTR_IS_EXPR(ptr)		((ptr & LISPATOM_FLAGS) == 0)
#define LISPPTR_IS_ATOM(ptr)		(LISPPTR_IS_EXPR(ptr) == FALSE)
#define LISPPTR_IS_VARIABLE(ptr)	(LISPPTR_TYPE(ptr) == ATOM_VARIABLE)
#define LISPPTR_IS_SYMBOL(ptr) \
	(LISPPTR_IS_VARIABLE(ptr) && LISPATOM_VALUE(ptr) == ptr)
#define LISPPTR_IS_NUMBER(ptr)		(LISPPTR_TYPE(ptr) == ATOM_NUMBER)
#define LISPPTR_IS_STRING(ptr)		(LISPPTR_TYPE(ptr) == ATOM_STRING)
#define LISPPTR_IS_ARRAY(ptr)		(LISPPTR_TYPE(ptr) == ATOM_ARRAY)
#define LISPPTR_IS_BUILTIN(ptr)		(LISPPTR_TYPE(ptr) == ATOM_BUILTIN)
#define LISPPTR_IS_SPECIAL(ptr)		(LISPPTR_TYPE(ptr) == ATOM_SPECIAL)
#define LISPPTR_IS_MACRO(ptr)		(LISPPTR_TYPE(ptr) == ATOM_MACRO)
#define LISPPTR_IS_FUNCTION(ptr)	(LISPPTR_TYPE(ptr) == ATOM_FUNCTION)

#define LISPPTR_TRUTH(test)	((test) ? lispptr_t : lispptr_nil)

#define EXPAND_UNIVERSE(atom) \
    (LISPATOM_VALUE(lispptr_universe) = CONS(atom, LISPATOM_VALUE(lispptr_universe)))

extern const lispptr lispptr_nil;
extern const lispptr lispptr_t;
extern const lispptr lispptr_invalid;
extern lispptr lispptr_universe;

/* Already looked-up atoms. */
extern lispptr lispatom_quote;
extern lispptr lispatom_lambda;
extern lispptr lispatom_backquote;
extern lispptr lispatom_quasiquote_splice;
extern lispptr lispatom_function;
extern lispptr lispatom_values;

/* Initialise this section. */
extern void lispatom_init (void);

/* Lookup atom. */
extern lispptr lispatom_seek (char *, lispptr package);
#define ATOM_NOT_FOUND  ((lispptr) -2)

/* Lookup or create atom. */
extern lispptr lispatom_get (char *, lispptr package);

/* Create new number atom for computational values. */
extern lispptr lispatom_number_get (float, int type);

extern lispptr lispatom_alloc (char *symbol, lispptr package, int type, lispptr value);
extern void lispatom_free (lispptr);

extern void lispatom_remove (lispptr);

extern void lispatom_set_value (lispptr atom, lispptr value);
extern void lispatom_set_function (lispptr atom, lispptr value);
extern void lispatom_set_binding (lispptr atom, lispptr value);

/* Lookup variable that points to function containing body. */
extern lispptr lispatom_body_to_var (lispptr body);

/* Return body of function or macro. */
extern lispptr lispatom_fun_body (lispptr atomp);

#endif
