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
#include "argument.h"
#include "builtin_fs.h"
#include "xxx.h"
#include "string2.h"

FILE * tre_fileio_handles[TRE_FILEIO_MAX_FILES];

long
trestream_fopen (treptr path, treptr mode)
{
    char * spath = TREPTR_STRINGZ(path);
    char * smode = TREPTR_STRINGZ(mode);
    FILE * file  = fopen (spath, smode);
    size_t i;

    if (file == NULL)
        return NIL;

    DOTIMES(i, TRE_FILEIO_MAX_FILES) {
        if (tre_fileio_handles[i] != NULL)
            continue;

        tre_fileio_handles[i] = file;
        break;
    }

    if (i == TRE_FILEIO_MAX_FILES)
        return NIL;

    return i;
}

long
trestream_fclose (long handle)
{
	if (tre_fileio_handles[handle] == NULL || fclose (tre_fileio_handles[handle]))
		return -1;

	tre_fileio_handles[handle] = NULL;
	return 0;
}

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
