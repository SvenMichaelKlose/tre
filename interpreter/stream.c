/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Streams
 */

#include "lisp.h"
#include "atom.h"
#include "eval.h"
#include "io.h"
#include "error.h"
#include "number.h"
#include "util.h"
#include "argument.h"
#include "stream.h"
#include "string.h"

FILE* lisp_fileio_handles[LISP_FILEIO_MAX_FILES];

int
lispstream_fopen (lispptr path, lispptr mode)
{
    char      *spath = LISPATOM_STRINGP(path);
    char      *smode = LISPATOM_STRINGP(mode);
    FILE      *file = fopen (spath, smode);
    unsigned  i;

    if (file == NULL)
        return lispptr_nil;

    DOTIMES(i, LISP_FILEIO_MAX_FILES) {
        if (lisp_fileio_handles[i] != NULL)
            continue;

        lisp_fileio_handles[i] = file;
        break;
    }

    if (i == LISP_FILEIO_MAX_FILES)
        return lispptr_nil;

    return i;
}
