/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
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

	car = trearg_string (1, "pathname", car);
	cdr = trearg_string (2, "access mode", cdr);

    handle = trestream_fopen (car, cdr);
    RETURN_NIL(handle);

    return treatom_number_get ((double) handle, TRENUMTYPE_INTEGER);
}
