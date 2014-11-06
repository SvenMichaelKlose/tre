/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@hugbox.org>
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
#include "symtab.h"
#include "builtin_string.h"
#include "assert.h"

treptr
trestring_p (treptr object)
{
    return TREPTR_TRUTH(STRINGP(object));
}

treptr
trestring_builtin_stringp (treptr list)
{
    return trestring_p (trearg_get (list));
}

treptr
trestring_builtin_make (treptr list)
{
    char *  str;
    treptr  arg = trearg_typed (1, TRETYPE_NUMBER, trearg_get (list), "MAKE-STRING");
    treptr  atom;

    str = trestring_get_raw ((tre_size) TRENUMBER_VAL(arg));
    atom = atom_alloc (TRETYPE_STRING);
    ATOM(atom) = str;
    return atom;
}

treptr
trestring_builtin_list_string (treptr list)
{
	treptr    arg;
    treptr    atom;
	int	      i;
    tre_size  len = 0;
    char *    news;
    char *    newp;
    treptr    p;

	arg = trearg_get (list);
	len = list_length (arg);

    news = trestring_get_raw (len);
    if (news == NULL) {
		tregc ();
    	news = trestring_get_raw (len);
    	if (news == NULL)
			treerror_norecover (treptr_invalid, "Out of memory.");
	}
    newp = TRESTRING_DATA(news);

	i = 0;
    DOLIST(p, arg) {
		if (NOT(CAR(p)))
			continue;
        ASSERT_NUMBER(CAR(p));
		newp[i++] = (unsigned char) TRENUMBER_VAL(CAR(p));
	}

    atom = atom_alloc (TRETYPE_STRING);
    ATOM(atom) = news;

    return atom;
}


treptr
trestring_builtin_compare (treptr list)
{
	char *    x;
	char *    y;
	treptr    p;
	treptr    a;
	tre_size  len;

    ASSERT_STRING(CAR(list));

	x = TREPTR_STRINGZ(CAR(list));
	len = TREPTR_STRINGLEN(CAR(list));
    DOLIST(p, CDR(list)) {
		a = CAR(p);
        ASSERT_STRING(a);
		if (NOT(a))
			continue;
		y = TREPTR_STRINGZ(a);
		if (len != TREPTR_STRINGLEN(a))
			return NIL;
		if (memcmp (x, y, len))
			return NIL;
	}

    return treptr_t;
}


treptr
trestring_builtin_concat (treptr list)
{
    char *    news;
    treptr    p;
    treptr    a;
    treptr    atom;
    char *    newp;
    tre_size  len = 0;
	int	      argnum = 1;

    DOLIST(p, list) {
		if (NOT(CAR(p)))
			continue;
        a = trearg_typed (argnum++, TRETYPE_STRING, CAR(p), "STRING-CONCAT");
	   	len += TREPTR_STRINGLEN(a);
    }

    news = trestring_get_raw (len);
    if (news == NULL) {
		tregc ();
    	news = trestring_get_raw (len);
    	if (news == NULL)
			treerror_norecover (treptr_invalid, "Out of memory.");
	}
    newp = TRESTRING_DATA(news);

    DOLIST(p, list) {
        a = CAR(p);
		if (NOT(a))
			continue;

		len = TREPTR_STRINGLEN(a);
		memcpy (newp, TREPTR_STRINGZ(a), len);
		newp += len;
	}

    atom = atom_alloc (TRETYPE_STRING);
    ATOM(atom) = news;

    return atom;
}

treptr
trestring_builtin_string (treptr list)
{
    char    buf[TRE_MAX_STRINGLEN];
    treptr  arg = trearg_get (list);

   	if (STRINGP(arg))
		return arg;

	while (TRUE) {
       	if (NUMBERP(arg)) {
			if (TRENUMBER_TYPE(arg) == TRENUMTYPE_CHAR) {
				buf[0] = TRENUMBER_VAL(arg);
				buf[1] = 0;
           		return trestring_get (buf);
           	}
           	snprintf (buf, TRE_MAX_STRINGLEN, "%g", TRENUMBER_VAL(arg));
           	return trestring_get (buf);
    	}
   		if (ATOMP(arg) && SYMBOL_NAME(arg)) {
   			strncpy (buf, SYMBOL_NAME(arg), TRE_MAX_STRINGLEN);
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
    char *  an = SYMBOL_NAME(sym);

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
