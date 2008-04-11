/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
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
#include "string.h"
#include "builtin_stream.h"

treptr
trestream_builtin_princ (treptr args)
{
    treptr obj;
    treptr handle;
    FILE    *str;

    trearg_get2 (&obj, &handle, args);
    if (handle != treptr_nil)
        str = tre_fileio_handles[(int) TRENUMBER_VAL(handle)];
    else
 		str = stdout;

    switch (TREPTR_TYPE(obj)) {
		case TRETYPE_STRING:
	    	fprintf (str, TREATOM_STRINGP(obj));
	    	break;

		case TRETYPE_VARIABLE:
	    	fprintf (str, TREATOM_NAME(obj));
	    	break;

		case TRETYPE_NUMBER:
	    	if (TRENUMBER_TYPE(obj) == TRENUMTYPE_CHAR)
                fputc ((int) TRENUMBER_VAL(obj), str);
	    	else
				fprintf (str, "%-g", TRENUMBER_VAL(obj));
	    	break;

  		default:
	    	return treerror (obj, "type not supported");
    }

    return obj;
}

treptr
trestream_builtin_force_output (treptr args)
{
    treptr handle = trearg_get (args);
    FILE    *str;

    if (handle != treptr_nil)
        str = tre_fileio_handles[(int) TRENUMBER_VAL(handle)];
    else
 		str = stdout;

    fflush (str);
    return treptr_nil;
}

treptr
trestream_builtin_feof (treptr args)
{
    treptr handle = trearg_get (args);
    FILE    *str;

    if (handle != treptr_nil)
        str = tre_fileio_handles[(int) TRENUMBER_VAL(handle)];
    else
 		str = stdin;

    if (feof (str))
        return treptr_t;
    return treptr_nil;
}

treptr
trestream_builtin_read_char (treptr args)
{
    treptr handle = trearg_get (args);
    FILE    *str;
    char c;

    if (handle != treptr_nil)
        str = tre_fileio_handles[(int) TRENUMBER_VAL(handle)];
    else
 		str = stdin;

    c = fgetc (str);

    return treatom_number_get ((double) c, TRENUMTYPE_CHAR);
}
