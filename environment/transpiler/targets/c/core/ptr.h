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

#define TREPTR_TYPE(ptr)	(ptr >> TREPTR_INDEX_WIDTH)
#define TREPTR_INDEX(ptr)	(ptr & ~TREPTR_FLAGS)
#define CONSP(ptr)		    ((ptr & TREPTR_FLAGS) == TRETYPE_CONS)
#define ATOMP(ptr)		    (CONSP(ptr) == FALSE)
#define SYMBOLP(ptr)	    (TREPTR_TYPE(ptr) == TRETYPE_SYMBOL)
#define NUMBERP(ptr)	    (TREPTR_TYPE(ptr) == TRETYPE_NUMBER)
#define STRINGP(ptr)        (TREPTR_TYPE(ptr) == TRETYPE_STRING)
#define ARRAYP(ptr)	        (TREPTR_TYPE(ptr) == TRETYPE_ARRAY)
#define BUILTINP(ptr)	    (TREPTR_TYPE(ptr) == TRETYPE_BUILTIN)
#define SPECIALP(ptr)	    (TREPTR_TYPE(ptr) == TRETYPE_SPECIAL)
#define MACROP(ptr)	        (TREPTR_TYPE(ptr) == TRETYPE_MACRO)
#define FUNCTIONP(ptr)	    (TREPTR_TYPE(ptr) == TRETYPE_FUNCTION)

#define CALLABLEP(x)           (FUNCTIONP(x) || MACROP(x))
#define COMPILED_FUNCTIONP(x)  ((FUNCTIONP(x) || MACROP(x)) && (FUNCTION_BYTECODE(x) != NIL || FUNCTION_NATIVE(x)))
#define ANY_FUNCTIONP(x)  ((FUNCTIONP(x) || MACROP(x)) || BUILTINP(x) || is_compiled_closure (x))

#define TREPTR_TRUTH(test)  ((test) ? treptr_t : NIL)

#define NOT(x)              (x == NIL)
#define NOT_NIL(x)          (x != NIL)
#define LISTP(x)            (NOT(x) || CONSP(x))

extern const treptr NIL;
extern const treptr treptr_t;
extern const treptr treptr_invalid;

extern treptr atom_accent_circonflex;
extern treptr atom_function;
extern treptr atom_backquote;
extern treptr atom_lambda;
extern treptr atom_quasiquote;
extern treptr atom_quasiquote_splice;
extern treptr atom_quote;
extern treptr atom_values;
extern treptr atom_square;
extern treptr atom_curly;
extern treptr atom_cons;

extern treptr        treptr_type (treptr);
extern const char *  treptr_typename (treptr);
extern treptr        treptr_index (treptr);

#endif /* #ifndef TRE_PTR_H */