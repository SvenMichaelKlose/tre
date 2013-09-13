/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "string2.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "thread.h"
#include "argument.h"
#include "gc.h"
#include "symbol.h"
#include "builtin_string.h"

treptr
trestring_p (treptr object)
{
    return TREPTR_TRUTH(TREPTR_IS_STRING(object));
}

treptr
trestring_builtin_stringp (treptr list)
{
    return trestring_p (trearg_get (list));
}

treptr
trestring_builtin_make (treptr list)
{
    char * str;
    treptr  arg = trearg_typed (1, TRETYPE_NUMBER, trearg_get (list), "MAKE-STRING");
    treptr  atom;

    str = trestring_get_raw ((tre_size) TRENUMBER_VAL(arg));
    atom = treatom_alloc (TRETYPE_STRING);
    TREATOM(atom) = str;
    return atom;
}

treptr
trestring_builtin_list_string (treptr list)
{
    char *  news;
    treptr  p;
    treptr  atom;
    char *  newp;
    tre_size  len = 0;
	int	    i;

	treptr arg;

	arg = trearg_get (list);
	len = trelist_length (arg);

    news = trestring_get_raw (len);
    if (news == NULL) {
		tregc_force ();
    	news = trestring_get_raw (len);
    	if (news == NULL)
			treerror_norecover (treptr_invalid, "Out of memory.");
	}
    newp = TRESTRING_DATA(news);

	i = 0;
    DOLIST(p, arg) {
		if (CAR(p) == treptr_nil)
			continue;
		if (TREPTR_IS_NUMBER(CAR(p)) == FALSE)
			treerror_norecover (CAR(p), "Number expected.");
		newp[i++] = (unsigned char) TRENUMBER_VAL(CAR(p));
	}

    atom = treatom_alloc (TRETYPE_STRING);
    TREATOM(atom) = news;

    return atom;
}


treptr
trestring_builtin_compare (treptr list)
{
	char *    x;
	char *    y;
	treptr    p;
	treptr    car;
	unsigned  len;

	if (TREPTR_IS_STRING(CAR(list)) == FALSE)
		treerror_norecover (list, "String expected as first argument.");

	x = TREPTR_STRINGZ(CAR(list));
	len = strlen (x);
    DOLIST(p, CDR(list)) {
		car = CAR(p);
		if (TREPTR_IS_STRING(car) == FALSE)
			treerror_norecover (list, "String expected.");
		if (car == treptr_nil)
			continue;
		y = TREPTR_STRINGZ(car);
		if (len != strlen (y))
			return treptr_nil;
		if (strcmp (x, y))
			return treptr_nil;
	}

    return treptr_t;
}


treptr
trestring_builtin_concat (treptr list)
{
    char *    news;
    treptr    p;
    treptr    car;
    treptr    atom;
    char *    newp;
    tre_size  len = 0;
	int	      argnum = 1;

    DOLIST(p, list) {
		if (CAR(p) == treptr_nil)
			continue;
        car = trearg_typed (argnum++, TRETYPE_STRING, CAR(p), "STRING-CONCAT");
	   	len += strlen (TREPTR_STRINGZ(car));
    }

    news = trestring_get_raw (len);
    if (news == NULL) {
		tregc_force ();
    	news = trestring_get_raw (len);
    	if (news == NULL)
			treerror_norecover (treptr_invalid, "Out of memory.");
	}
    newp = TRESTRING_DATA(news);

    DOLIST(p, list) {
		if (CAR(p) == treptr_nil)
			continue;
		newp = stpcpy (newp, TREPTR_STRINGZ(CAR(p)));
	}

    atom = treatom_alloc (TRETYPE_STRING);
    TREATOM(atom) = news;

    return atom;
}

treptr
trestring_builtin_string (treptr list)
{
    char    buf[TRE_MAX_STRINGLEN];
    treptr  arg = trearg_get (list);

   	if (TREPTR_TYPE(arg) == TRETYPE_STRING)
		return arg;

	while (TRUE) {
       	if (TREPTR_TYPE(arg) == TRETYPE_NUMBER) {
			if (TRENUMBER_TYPE(arg) == TRENUMTYPE_CHAR) {
				buf[0] = TRENUMBER_VAL(arg);
				buf[1] = 0;
           		return trestring_get (buf);
           	}
           	snprintf (buf, TRE_MAX_STRINGLEN, "%g", TRENUMBER_VAL(arg));
           	return trestring_get (buf);
    	}
   		if (TREPTR_IS_ATOM(arg) && TRESYMBOL_NAME(arg)) {
   			strncpy (buf, TRESYMBOL_NAME(arg), TRE_MAX_STRINGLEN);
       		return trestring_get (buf);
		}
    	arg = treerror (arg, "String, number or named atom expected.");
	}

	/*NOTREACHED*/
	return treptr_invalid;
}

treptr
trestring_symbol_name (treptr symbol)
{
    char    buf[TRE_MAX_STRINGLEN];
    treptr  sym = trearg_typed (1, TRETYPE_SYMBOL, symbol, "SYMBOL-NAME");
    char *  an = TRESYMBOL_NAME(sym);

    buf[0] = 0;
    if (an)
        strcpy (buf, an);
    return trestring_get (buf);
}

treptr
trestring_builtin_symbol_name (treptr list)
{
    return trestring_symbol_name (trearg_get (list));
}
