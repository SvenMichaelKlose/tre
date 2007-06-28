/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
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
#include "builtin_stream.h"

lispptr
lispstream_builtin_princ (lispptr args)
{
    lispptr obj;
    lispptr handle;
    FILE    *str;

    lisparg_get2 (&obj, &handle, args);
    if (handle != lispptr_nil)
        str = lisp_fileio_handles[(int) LISPNUMBER_VAL(handle)];
    else
 	str = stdout;

    switch (LISPPTR_TYPE(obj)) {
	case ATOM_STRING:
	    fprintf (str, LISPATOM_STRINGP(obj));
	    break;

	case ATOM_VARIABLE:
	    fprintf (str, LISPATOM_NAME(obj));
	    break;

	case ATOM_NUMBER:
	    if (LISPNUMBER_TYPE(obj) == LISPNUMTYPE_CHAR)
                fputc ((int) LISPNUMBER_VAL(obj), str);
	    else
		fprintf (str, "%-g", LISPNUMBER_VAL(obj));
	    break;

  	default:
	    return lisperror (obj, "type not supported");
    }

    return obj;
}

lispptr
lispstream_builtin_force_output (lispptr args)
{
    lispptr handle = lisparg_get (args);
    FILE    *str;

    if (handle != lispptr_nil)
        str = lisp_fileio_handles[(int) LISPNUMBER_VAL(handle)];
    else
 	str = stdout;

    fflush (str);
    return lispptr_nil;
}

lispptr
lispstream_builtin_feof (lispptr args)
{
    lispptr handle = lisparg_get (args);
    FILE    *str;

    if (handle != lispptr_nil)
        str = lisp_fileio_handles[(int) LISPNUMBER_VAL(handle)];
    else
 	str = stdin;

    if (feof (str))
        return lispptr_t;
    return lispptr_nil;
}

lispptr
lispstream_builtin_read_char (lispptr args)
{
    lispptr handle = lisparg_get (args);
    FILE    *str;
    char c;

    if (handle != lispptr_nil)
        str = lisp_fileio_handles[(int) LISPNUMBER_VAL(handle)];
    else
 	str = stdin;

    c = fgetc (str);

    return lispatom_number_get ((float) c, LISPNUMTYPE_CHAR);
}
