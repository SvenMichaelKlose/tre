/*
 * tré – Copyright (c) 2005–2007,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "string2.h"
#include "error.h"
#include "util.h"
#include "argument.h"
#include "image.h"
#include "builtin_fileio.h"

treptr
treimage_builtin_create (treptr list)
{
    treptr  file;
    treptr  init_fun = treptr_nil;

    while (list == treptr_nil || TREPTR_IS_ATOM(list))
        list = treerror (treptr_invalid, "Argument list missing.");

    if (TREPTR_IS_CONS(CDR(list)))
        init_fun = CADR(list);

	file = CAR(list);
	while (TRUE) {
		file = trearg_typed (1, TRETYPE_STRING, file, "pathname");

    	if (treimage_create (TREPTR_STRINGZ(file), init_fun) == FALSE)
			break;

       	file = treerror (file, "Cannot create image - please provide a new path.");
	}

    return treptr_nil;
}

treptr
treimage_builtin_load (treptr list)
{
    treptr  file = trearg_get (list);
    long    r;

	while (TRUE) {
    	file = trearg_typed (1, TRETYPE_STRING, file, "pathname");
    	r = treimage_load (TREPTR_STRINGZ(file));
    	if (r == -2) {
        	file = treerror (file, "Incompatible image format - please provide a new path.");
            continue;
        }
    	if (r)
        	file = treerror (file, "Can't open image - please provide a new path.");
	}

	/*NOTREACHED*/
    return treptr_invalid;
}
