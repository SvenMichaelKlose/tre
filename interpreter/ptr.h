/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_PTR_H
#define TRE_PTR_H

#include "config.h"
#include "type.h"

typedef size_t treptr;

#define TREPTR_FLAGS	((treptr) -1 << TREPTR_INDEX_WIDTH)

#define TRETYPE_INDEX_TO_PTR(type, index) \
	(((treptr) type << TREPTR_INDEX_WIDTH) | index)
#define TREATOM_TO_PTR(idx)	\
	(TRETYPE_INDEX_TO_PTR(tre_atom_types[idx], idx))

#define TREPTR_NIL()	TRETYPE_INDEX_TO_PTR(TRETYPE_SYMBOL, 0)

#define TREATOM_INDEX_TO_PTR(index) \
	TRETYPE_INDEX_TO_PTR(tre_atom_types[index], index)
#define TREPTR_TO_ATOM(ptr)	TRE_ATOM(TREPTR_INDEX(ptr))

#define TREATOM_NAME(ptr)		        ((char *) TREPTR_TO_ATOM(ptr).detail)
#define TREATOM_TYPE(ptr)		        (tre_atom_types[TREPTR_INDEX(ptr)])
#define TREATOM_VALUE(ptr)		        (TREPTR_TO_ATOM(ptr).value)
#define TREATOM_FUN(ptr)		        (TREPTR_TO_ATOM(ptr).fun)
#define TREATOM_COMPILED_FUN(ptr)		(TREPTR_TO_ATOM(ptr).compiled_fun)
#define TREATOM_COMPILED_EXPANDER(ptr)	(TREPTR_TO_ATOM(ptr).compiled_expander)
#define TREATOM_BINDING(ptr)	        (TREPTR_TO_ATOM(ptr).binding)
#define TREATOM_PACKAGE(ptr)	        (TREPTR_TO_ATOM(ptr).package)
#define TREATOM_ENV(ptr)	            (TREPTR_TO_ATOM(ptr).env)
#define TREATOM_DETAIL(ptr)		        (TREPTR_TO_ATOM(ptr).detail)
#define TREATOM_STRING(ptr)		        ((char *) TREATOM_DETAIL(ptr))
#define TREATOM_STRINGP(ptr)	        ((char *) TRESTRING_DATA(TREATOM_STRING(ptr)))
#define TREATOM_SET_FUN(ptr, val)	    (TREPTR_TO_ATOM(ptr).fun = val)
#define TREATOM_SET_DETAIL(ptr, val)	(TREPTR_TO_ATOM(ptr).detail = (void *) val)
#define TREATOM_SET_STRING(ptr, val)	(TREATOM_DETAIL(ptr) = (char *) val)
#define TREATOM_SET_TYPE(ptr, val)	    (TREATOM_TYPE(ptr) = val)

#define TREPTR_TYPE(ptr)		(ptr >> TREPTR_INDEX_WIDTH)
#define TREPTR_INDEX(ptr)		(ptr & ~TREPTR_FLAGS)
#define TREPTR_IS_CONS(ptr)		((ptr & TREPTR_FLAGS) == TRETYPE_CONS)
#define TREPTR_IS_ATOM(ptr)		(TREPTR_IS_CONS(ptr) == FALSE)
#define TREPTR_IS_SYMBOL(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_SYMBOL)
#define TREPTR_IS_NUMBER(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_NUMBER)
#define TREPTR_IS_STRING(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_STRING)
#define TREPTR_IS_ARRAY(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_ARRAY)
#define TREPTR_IS_BUILTIN(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_BUILTIN)
#define TREPTR_IS_SPECIAL(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_SPECIAL)
#define TREPTR_IS_MACRO(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_MACRO)
#define TREPTR_IS_FUNCTION(ptr)	(TREPTR_TYPE(ptr) == TRETYPE_FUNCTION)

#define IS_COMPILED_FUN(x) (TREPTR_IS_ARRAY(x) || ((TREPTR_IS_FUNCTION(x) || TREPTR_IS_MACRO(x)) && TREATOM_COMPILED_FUN(x)))

#define TREPTR_TRUTH(test) ((test) ? treptr_t : treptr_nil)

#define NULLP(x)           (x == treptr_nil)

extern const treptr treptr_nil;
extern const treptr treptr_t;
extern const treptr treptr_invalid;

extern treptr treatom_accent_circonflex;
extern treptr treatom_function;
extern treptr treatom_backquote;
extern treptr treatom_lambda;
extern treptr treatom_quasiquote;
extern treptr treatom_quasiquote_splice;
extern treptr treatom_quote;
extern treptr treatom_values;
extern treptr treatom_square;
extern treptr treatom_curly;

#endif /* #ifndef TRE_PTR_H */
