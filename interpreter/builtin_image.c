/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in file-I/O functions
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "string.h"
#include "error.h"
#include "util.h"
#include "argument.h"
#include "image.h"
#include "builtin_fileio.h"

#include <stdio.h>

/*
 * (SYS-IMAGE-CREATE path) - builtin function
 */
treptr
treimage_builtin_create (treptr list)
{
    treptr  file;
    treptr  init_fun = treptr_nil;
    int r;

    while (list == treptr_nil || TREPTR_IS_ATOM(list))
        list = treerror (treptr_invalid, "argument list missing");

    if (TREPTR_IS_CONS(CDR(list)))
        init_fun = CADR(list);

	file = CAR(list);
	while (TRUE) {
		file = trearg_string (1, "pathname", file);

    	if (treimage_create (&TREATOM_STRING(file)->str, init_fun) == FALSE)
			break;

       	file = treerror (file, "cannot create image - tell new pathname");
	}

    return treptr_nil;
}

/*
 * (SYS-IMAGE-LOAD path) - builtin function
 */
treptr
treimage_builtin_load (treptr list)
{
    treptr  file = trearg_get (list);
    int     r;

	while (TRUE) {
    	file = trearg_string (1, "pathname", file);
    	r = treimage_load (&TREATOM_STRING(file)->str);
    	if (r == -2)
        	file = treerror (file, "incompatible image format - tell new pathname");
    	if (r)
        	file = treerror (file, "can't open image - tell new pathname");
	}

	/*NOTREACHED*/
    return treptr_invalid;
}
