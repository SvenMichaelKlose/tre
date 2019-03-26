/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_PTR_H
#define TRE_PTR_H

#include "config.h"
#include "type.h"

#if NUM_LISTNODES > (256 * MEGA)
typedef size_t treptr;
typedef size_t tre_size;
#else
typedef unsigned int treptr;
typedef unsigned int tre_size;
#endif

#define TREPTR_FLAGS	        ((treptr) -1 << TREPTR_INDEX_WIDTH)

#define TRETYPE_INDEX_TO_PTR(type, index)   (((treptr) type << TREPTR_INDEX_WIDTH) | index)
#define TREINDEX_TO_PTR(idx)	            TRETYPE_INDEX_TO_PTR(tre_atom_types[idx], idx)

#define TREATOM(ptr)		    (tre_atoms[TREPTR_INDEX(ptr)])
#define TREATOM_TYPE(ptr)		(tre_atom_types[TREPTR_INDEX(ptr)])

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

#define IS_COMPILED_FUN(x)  ((TREPTR_IS_FUNCTION(x) || TREPTR_IS_MACRO(x)) && (TREFUNCTION_BYTECODE(x) != treptr_nil || TREFUNCTION_NATIVE(x)))

#define TREPTR_TRUTH(test)  ((test) ? treptr_t : treptr_nil)

#define NOT(x)              (x == treptr_nil)
#define NOT_NIL(x)          (x != treptr_nil)
#define LISTP(x)            (NOT(x) || TREPTR_IS_CONS(x))

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
extern treptr treatom_cons;

#endif /* #ifndef TRE_PTR_H */
