/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>

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

FILE * tre_fileio_handles[TRE_FILEIO_MAX_FILES];

treptr
trestream_fopen_wrapper (treptr path, treptr mode)
{
    treptr  handle;

	path = trearg_typed (1, TRETYPE_STRING, path, "pathname");
	mode = trearg_typed (2, TRETYPE_STRING, mode, "access mode");

    handle = trestream_fopen (path, mode);
    RETURN_NIL(handle);

    return number_get_integer ((double) handle);
}

treptr
trestream_builtin_fopen (treptr x)
{
    treptr  path;
    treptr  mode;

    trearg_get2 (&path, &mode, x);
    return trestream_fopen_wrapper (path, mode);
}
