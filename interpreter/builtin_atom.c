/*
 * TRE interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 *
 * Built-in atom-related functions
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "error.h"
#include "argument.h"
#include "builtin_atom.h"
#include "string2.h"
#include "thread.h"
#include "xxx.h"

/*tredoc
 (cmd :name EQ :essential T
	(arg :occurrence rest x)
	(returns :type boolean)
 	(param "Test if arguments are identical."))
 */
treptr
treatom_builtin_eq (treptr list)
{
	treptr first;
	treptr x;

    first = CAR(list);
	list = CDR(list);
	do {
		x = CAR(list);
    	RETURN_NIL(TREPTR_TRUTH(first == x));
		list = CDR(list);
	} while (list != treptr_nil);

	return treptr_t;
}

/*tredoc
 (cmd :name EQL
	(args x y)
	(returns :type boolean)
 	(para
	  "Return T if the two objects are identical, or numbers with the "
	  "same value."))
 */
treptr
treatom_builtin_eql (treptr list)
{
	treptr first;
	treptr x;

    first = CAR(list);
	list = CDR(list);
	do {
		x = CAR(list);
    	if (TREPTR_IS_NUMBER(first)) {
        	if (TREPTR_IS_NUMBER(x) == FALSE)
	    		return treptr_nil;
        	if (TRENUMBER_TYPE(first) != TRENUMBER_TYPE(x))
	    		return treptr_nil;
        	RETURN_NIL(TREPTR_TRUTH(TRENUMBER_VAL(first) == TRENUMBER_VAL(x)));
    	} else
    		RETURN_NIL(TREPTR_TRUTH(first == x));
		list = CDR(list);
	} while (list != treptr_nil);

	return treptr_t;
}

/*tredoc
  (cmd :name MAKE-SYMBOL
	(arg :type string)
	(returns :type symbol)
	(para
 	  "Returns newly created self-referencing atom."))
 */
treptr
treatom_builtin_make_symbol (treptr args)
{
	ulong num_args = trelist_length (args);
	treptr name;
	treptr package;

	if (num_args == 0 || num_args > 2)
		args = treerror (treptr_nil, "name and optional package required");
	name = CAR(args);
    name = trearg_typed (1, TRETYPE_STRING, name, "symbol name");
	package = num_args == 2 ?
			  CADR(args) :
			  TRECONTEXT_PACKAGE();

    return treatom_get (TREATOM_STRINGP(name), package);
}

/*tredoc
  (cmd :name ATOM
	(arg obj)
	(returns :type boolean)
	(para "Returns T if obj is not a cons."))
 */
treptr
treatom_builtin_atom (treptr list)
{
    treptr x;

	DOLIST(x, list)
        if (TREPTR_IS_CONS(CAR(x)))
		    return treptr_nil;
    return treptr_t;
}

treptr
treatom_builtin_arg (treptr list)
{
    return trearg_typed (1, TRETYPE_ATOM, trearg_get (list), NULL);
}

/*tredoc
  (cmd :name SYMBOL-VALUE
	(arg :type symbol x)
	(descr "Returns value bound to atom."))
 */
treptr
treatom_builtin_symbol_value (treptr list)
{
    treptr arg = treatom_builtin_arg (list);
    return TREATOM_VALUE(arg);
}

/*tredoc
  (cmd :name SYMBOL-FUNCTION
	(arg obj)
    (para "Returns function bound to atom."))
 */
treptr
treatom_builtin_symbol_function (treptr list)
{
    treptr arg = treatom_builtin_arg (list);
    return TREATOM_FUN(arg);
}

/*
  (cmd :name SYMBOL-PACKAGE
	(arg obj)
    (para "Returns function bound to atom."))
 */
treptr
treatom_builtin_symbol_package (treptr list)
{
    treptr arg = treatom_builtin_arg (list);
    return TREATOM_PACKAGE(arg);
}

/*tredoc
  (cmd :name %SET-ATOM-FUN
	(arg :name obj :type atom)
	(arg :name value :type obj)
    (para "Set function of atom."))
 */
treptr
treatom_builtin_set_atom_fun (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);

	car = trearg_typed (1, TRETYPE_ATOM, car, NULL);
    cdr = treeval (cdr);
    treatom_set_function (car, cdr);
    return cdr;
}

/*tredoc
  (cmd :name FUNCTIONP
	(arg :name obj)
	(para "Returns T if the argument is a number. NIL otherwise."))
 */
treptr
treatom_builtin_functionp (treptr list)
{
    treptr arg = trearg_get (list);

    return TREPTR_TRUTH(TREPTR_IS_FUNCTION(arg) || TREPTR_IS_BUILTIN(arg));
}

/*tredoc
  (cmd :name BOUNDP
	(arg obj)
	(para "Returns T if global symbol is bound to a variable."))
 */
treptr
treatom_builtin_boundp (treptr list)
{
    treptr arg = trearg_get (list);

    return TREPTR_TRUTH(TREATOM_VALUE(arg) != arg);
}

/*tredoc
 (cmd :name FBOUNDP
	(arg obj)
 	(para "Check on function."))
 */
treptr
treatom_builtin_fboundp (treptr list)
{
    treptr arg = trearg_get (list);

    return TREPTR_TRUTH(TREATOM_FUN(arg) != treptr_nil);
}

/*tredoc
  (cmd :name MACROP
	(arg obj)
	(para "Check on macro."))
 */
treptr
treatom_builtin_macrop (treptr list)
{
    treptr arg = trearg_get (list);

    return TREPTR_TRUTH(TREPTR_IS_MACRO(arg));
}

treptr
treatom_builtin_atom_list_s (treptr ret)
{
    struct tre_atom *a = tre_atoms;
    ulong  n;

    for (n = 0; n < NUM_ATOMS; n++) {
		if (a->type == TRETYPE_FUNCTION) {
            TRELIST_PUSH(ret, TRETYPE_INDEX_TO_PTR(TRETYPE_FUNCTION, n));
		}
		a++;
    }
              
    return ret;
}

/*tredoc
  (cmd :name %ATOM-LIST
	(para "Returns list of all atoms."))
 */
treptr
treatom_builtin_atom_list (treptr no_args)
{
    (void) no_args;

    return treatom_builtin_atom_list_s (treptr_nil);
}

treptr
treatom_builtin_type_id (treptr args)
{
    treptr arg = trearg_get (args);

	if (TREPTR_IS_CONS(arg))
		return treatom_number_get (0, TRENUMTYPE_INTEGER);
    return treatom_number_get (TREATOM_TYPE(arg), TRENUMTYPE_INTEGER);
}

treptr
treatom_builtin_id (treptr args)
{
    treptr arg = trearg_get (args);

    return treatom_number_get (arg, TRENUMTYPE_INTEGER);
}
