/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in file-I/O functions
 */

#include "config.h"
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

FILE* tre_fileio_handles[TRE_FILEIO_MAX_FILES];

/*
 * (> x y) - builtin function
 *
 * Returns T if number x is greater than number y.
 */
treptr
trestream_builtin_fopen (treptr list)
{
    treptr  car;
    treptr  cdr;
    treptr  handle;

    trearg_get2 (&car, &cdr, list);

    if (TREPTR_IS_STRING(car) == FALSE)
		return treerror (car, "string expected");
    if (TREPTR_IS_STRING(cdr) == FALSE)
		return treerror (cdr, "string expected");

    handle = trestream_fopen (car, cdr);
    RETURN_NIL(handle);

    return treatom_number_get ((float) handle, TRENUMTYPE_INTEGER);
}
