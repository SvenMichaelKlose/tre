/*
 * tré – Copyright (c) 2006–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "config.h"
#include "atom.h"
#include "eval.h"
#include "stream.h"
#include "error.h"
#include "number.h"
#include "util.h"
#include "argument.h"
#include "string2.h"
#include "symtab.h"
#include "assert.h"
#include "builtin_stream.h"
#include "builtin_fs.h"

treptr
trestream_builtin_princ (treptr args)
{
    treptr obj;
    treptr handle;
    FILE * str;

    trearg_get2 (&obj, &handle, args);
    if (NOT_NIL(handle)) {
        ASSERT_NUMBER(handle);
        str = tre_fileio_handles[(int) TRENUMBER_VAL(handle)];
    } else
 		str = stdout;

    switch (TREPTR_TYPE(obj)) {
		case TRETYPE_STRING:
	    	fwrite (TREPTR_STRINGZ(obj), TREPTR_STRINGLEN(obj), 1, str);
	    	break;

		case TRETYPE_SYMBOL:
	    	fprintf (str, "%s", SYMBOL_NAME(obj));
	    	break;

		case TRETYPE_NUMBER:
	    	if (TRENUMBER_TYPE(obj) == TRENUMTYPE_CHAR)
                fputc ((int) TRENUMBER_VAL(obj), str);
	    	else
				fprintf (str, "%-g", TRENUMBER_VAL(obj));
	    	break;

  		default:
	    	return treerror (obj, "Type not supported.");
    }

    return obj;
}

int
trestream_builtin_get_handle_index (treptr args)
{
	treptr handle = trearg_get (args);
    ASSERT_NUMBER(handle);

    return (int) TRENUMBER_VAL(handle);
}

FILE *
trestream_builtin_get_handle (treptr args, FILE * default_stream)
{
	treptr handle = trearg_get (args);

    return (NOT_NIL(handle)) ?
               tre_fileio_handles[trestream_builtin_get_handle_index (args)] :
 		       default_stream;
}

treptr
trestream_builtin_file_exists (treptr args)
{
    treptr fname = trearg_get (args);
    ASSERT_STRING(fname);

    if (access (TREPTR_STRINGZ(fname), F_OK) != -1)
        return treptr_t;
    return NIL;
}

treptr
trestream_builtin_force_output (treptr args)
{
    FILE  * str = trestream_builtin_get_handle (args, stdout);

    fflush (str);
    return NIL;
}

treptr
trestream_builtin_feof (treptr args)
{
    FILE  * str = trestream_builtin_get_handle (args, stdin);

    return TREPTR_TRUTH(feof (str));
}

treptr
trestream_builtin_fclose (treptr args)
{
    long  str = trestream_builtin_get_handle_index (args);

    return TREPTR_TRUTH(trestream_fclose (str));
}

treptr
trestream_builtin_read_char (treptr args)
{
    FILE  * str = trestream_builtin_get_handle (args, stdin);
    int  c;

    c = fgetc (str);
    if (c == EOF)
        return NIL;
    return number_get_char (c);
}
