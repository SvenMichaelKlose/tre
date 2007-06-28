/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in string functions
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "string.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "sequence.h"
#include "thread.h"
#include "argument.h"
#include "builtin_string.h"

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>

/*
 * (STRINGP obj)
 *
 * Returns T if the argument is a string. NIL otherwise. 
 */
lispptr
lispstring_builtin_stringp (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_STRING(arg) == FALSE)
        return lispptr_nil;
    return lispptr_t;
}

/*
 * (MAKE-STRING n)
 *
 * Makes new string consisting of n elements.
 */
lispptr
lispstring_builtin_make (lispptr list)
{
    lispptr  arg = lisparg_get (list);
    struct lisp_string *str;
    lispptr atom;

    if (LISPPTR_IS_NUMBER(arg) == FALSE)
	return lisperror (arg, "integer expected");

    str = lispstring_get_raw ((unsigned) LISPNUMBER_VAL(arg));
    atom = lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_STRING, lispptr_nil);
    LISPATOM_SET_STRING(atom, str);
    return atom;
}

/*
 * (STRING-CONCAT string*)
 *
 * Concatenates string arguments in order as a new string.
 */
lispptr
lispstring_builtin_concat (lispptr list)
{
    struct lisp_string  *news;
    lispptr   p;
    lispptr   car;
    lispptr   atom;
    char      *newp;
    unsigned  len = 0;

    /* Sum up length of all elements in the list. */
    DOLIST(p, list) {
        car = CAR(p);
	if (LISPPTR_IS_STRING(car) == FALSE)
	    return lisperror (car, "can only concatenate strings");
	else
	    len += strlen (LISPATOM_STRINGP(car));
    }

    /* Copy elements to new string. */
    news = lispstring_get_raw (len);
    if (news == NULL)
	return lisperror (lispptr_invalid, "out of memory");
    newp = &news->str;

    DOLIST(p, list)
	newp = stpcpy (newp, LISPATOM_STRINGP(CAR(p)));

    /* Return new string atom. */
    atom = lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_STRING, lispptr_nil);
    LISPATOM_SET_STRING(atom, news);
    return atom;
}

/*
 * (STRING obj)
 *
 * Returns a copy of 'obj' of type string. If 'obj' is already a string,
 * returns the original.
 */
lispptr
lispstring_builtin_string (lispptr list)
{
    char     buf[LISP_MAX_STRINGLEN];
    lispptr  arg = lisparg_get (list);

    switch (LISPPTR_TYPE(arg)) {
        case ATOM_VARIABLE:
        case ATOM_BUILTIN:
	    /* Convert symbol to string. */
	    strcpy (buf, LISPATOM_NAME(arg));
            return lispstring_get (buf);

        case ATOM_STRING:
	    return arg;

        case ATOM_NUMBER:
            sprintf (buf, "%-g", LISPNUMBER_VAL(arg));
            return lispstring_get (buf);
    }

    return lisperror (lispptr_invalid, "conversion unsupported");
}

/*
 * (SYMBOL-NAME obj)
 *
 * Returns the symbol name of obj as a string.
 */
lispptr
lispstring_builtin_symbol_name (lispptr list)
{
    char     buf[LISP_MAX_STRINGLEN];
    lispptr  arg;
    char     *an;

    arg = lisparg_get (list);
    if (LISPPTR_IS_ATOM(arg) == FALSE)
        arg = lisperror (arg, "atom expected");

    an = LISPATOM_NAME(arg);

    buf[0] = 0;
    if (an)
        strcpy (buf, an);
    return lispstring_get (buf);
}
