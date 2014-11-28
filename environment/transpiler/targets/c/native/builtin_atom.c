/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "error.h"
#include "argument.h"
#include "builtin_atom.h"
#include "string2.h"
#include "thread.h"
#include "xxx.h"
#include "function.h"
#include "symtab.h"
#include "funcall.h"
#include "gc.h"
#include "builtin_string.h"

treptr
atom_symbolp (treptr x)
{
    return TREPTR_TRUTH(SYMBOLP(x));
}

treptr
atom_functionp (treptr x)
{
    return TREPTR_TRUTH(FUNCTIONP(x) ||
           MACROP(x) ||
           BUILTINP(x) ||
           COMPILED_FUNCTIONP(x) ||
           is_compiled_closure (x));
}

treptr
atom_builtinp (treptr x)
{
    return TREPTR_TRUTH(BUILTINP(x));
}

treptr
atom_macrop (treptr x)
{
    return TREPTR_TRUTH(MACROP(x));
}

treptr
atom_type_id (treptr x)
{
	return number_get_integer (TREPTR_TYPE(x));
}

treptr
atom_id (treptr x)
{
    return number_get_integer (x);
}

treptr
atom_builtin_not (treptr list)
{
	treptr x;

	do {
		x = CAR(list);
    	if (NOT_NIL(x))
            return NIL;
		list = CDR(list);
	} while (NOT_NIL(list));

	return treptr_t;
}

treptr
atom_builtin_eq (treptr list)
{
	treptr first;
	treptr x;

    first = CAR(list);
	list = CDR(list);
	do {
		x = CAR(list);
    	RETURN_NIL(TREPTR_TRUTH(first == x));
		list = CDR(list);
	} while (NOT_NIL(list));

	return treptr_t;
}

treptr
atom_eql (treptr x, treptr y)
{
    treptr tmp;
   	if (NUMBERP(x)) {
       	if (NUMBERP(y) == FALSE)
    		return NIL;
       	if (TRENUMBER_TYPE(x) != TRENUMBER_TYPE(y))
    		return NIL;
       	RETURN_NIL(TREPTR_TRUTH(TRENUMBER_VAL(x) == TRENUMBER_VAL(y)));
   	} else if (STRINGP(x)) { /* XXX Should EQL also compare strings? */
       	if (STRINGP(y) == FALSE)
    		return NIL;
        tmp = CONS(y, NIL);
        tregc_push (tmp);
        tmp = trestring_builtin_compare (CONS(x, tmp));
        tregc_pop ();
        return tmp;
   	} else
   		RETURN_NIL(TREPTR_TRUTH(x == y));

	return treptr_t;
}

treptr
atom_builtin_eql (treptr list)
{
	treptr first;
	treptr x;

    first = CAR(list);
	list = CDR(list);
	do {
		x = CAR(list);
		RETURN_NIL(atom_eql (first, x));
		list = CDR(list);
	} while (NOT_NIL(list));

	return treptr_t;
}

treptr
atom_builtin_atom (treptr list)
{
    treptr x;

	DOLIST(x, list)
        if (CONSP(CAR(x)))
		    return NIL;
    return treptr_t;
}
