/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in file-I/O functions
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "util.h"
#include "stream.h"
#include "argument.h"
#include "builtin_fileio.h"
#include "xxx.h"

#include <stdio.h>

FILE* lisp_fileio_handles[LISP_FILEIO_MAX_FILES];

/*
 * (> x y) - builtin function
 *
 * Returns T if number x is greater than number y.
 */
lispptr
lispstream_builtin_fopen (lispptr list)
{
    lispptr  car;
    lispptr  cdr;
    lispptr  handle;

    lisparg_get2 (&car, &cdr, list);

    if (LISPPTR_IS_STRING(car) == FALSE)
	return lisperror (car, "string expected");
    if (LISPPTR_IS_STRING(cdr) == FALSE)
	return lisperror (cdr, "string expected");

    handle = lispstream_fopen (car, cdr);
    RETURN_NIL(handle);

    return lispatom_number_get ((float) handle, LISPNUMTYPE_INTEGER);
}
