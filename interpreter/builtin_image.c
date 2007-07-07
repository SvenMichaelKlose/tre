/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in file-I/O functions
 */

#include "lisp.h"
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
lispptr
lispimage_builtin_create (lispptr list)
{
    lispptr  file;
    lispptr  init_fun = lispptr_nil;
    int r;

    while (list == lispptr_nil || LISPPTR_IS_EXPR(list) == FALSE)
        list = lisperror (lispptr_invalid, "argument list missing");

    file = CAR(list);
    if (LISPPTR_IS_EXPR(CDR(list)))
        init_fun = CADR(list);

    if (LISPPTR_IS_STRING(file) == FALSE)
	return lisperror (file, "path string expected");

    r = lispimage_create (&LISPATOM_STRING(file)->str, init_fun);
    if (r)
        lisperror_norecover (list, "cannot create image");
    return lispptr_nil;
}

/*
 * (SYS-IMAGE-CREATE path) - builtin function
 */
lispptr
lispimage_builtin_load (lispptr list)
{
    lispptr  file = lisparg_get (list);
    int r;

    if (LISPPTR_IS_STRING(file) == FALSE)
	return lisperror (file, "path string expected");

    r = lispimage_load (&LISPATOM_STRING(file)->str);
    if (r == 2)
        lisperror_norecover (list, "incompatible image format");
    if (r)
        lisperror_norecover (list, "can't open image");
    return lispptr_nil;
}
