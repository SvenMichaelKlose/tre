/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>
 *
 * Streams
 */

#include "config.h"
#include "atom.h"
#include "eval.h"
#include "io.h"
#include "error.h"
#include "number.h"
#include "util.h"
#include "argument.h"
#include "stream.h"
#include "string2.h"

FILE* tre_fileio_handles[TRE_FILEIO_MAX_FILES];

long
trestream_fopen (treptr path, treptr mode)
{
    char   * spath = TREATOM_STRINGP(path);
    char   * smode = TREATOM_STRINGP(mode);
    FILE   * file = fopen (spath, smode);
    ulong  i;

    if (file == NULL)
        return treptr_nil;

    DOTIMES(i, TRE_FILEIO_MAX_FILES) {
        if (tre_fileio_handles[i] != NULL)
            continue;

        tre_fileio_handles[i] = file;
        break;
    }

    if (i == TRE_FILEIO_MAX_FILES)
        return treptr_nil;

    return i;
}

long
trestream_fclose (long handle)
{
	if (tre_fileio_handles[handle] == NULL)
		return -1;

	if (fclose (tre_fileio_handles[handle]))
		return -1;

	tre_fileio_handles[handle] = NULL;
	return 0;
}
