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

    while (list == treptr_nil || TREPTR_IS_CONS(list) == FALSE)
        list = treerror (treptr_invalid, "argument list missing");

    file = CAR(list);
    if (TREPTR_IS_CONS(CDR(list)))
        init_fun = CADR(list);

    if (TREPTR_IS_STRING(file) == FALSE)
		return treerror (file, "path string expected");

    r = treimage_create (&TREATOM_STRING(file)->str, init_fun);
    if (r)
        treerror_norecover (list, "cannot create image");
    return treptr_nil;
}

/*
 * (SYS-IMAGE-CREATE path) - builtin function
 */
treptr
treimage_builtin_load (treptr list)
{
    treptr  file = trearg_get (list);
    int r;

    if (TREPTR_IS_STRING(file) == FALSE)
		return treerror (file, "path string expected");

    r = treimage_load (&TREATOM_STRING(file)->str);
    if (r == 2)
        treerror_norecover (list, "incompatible image format");
    if (r)
        treerror_norecover (list, "can't open image");
    return treptr_nil;
}
