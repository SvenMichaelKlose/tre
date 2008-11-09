/*
 * nix operating system project tre interpreter
 * Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
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

#include <stdlib.h>

treptr
trestream_builtin_princ (treptr args)
{
    treptr obj;
    treptr handle;
    FILE   * str;

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

int
trestream_builtin_get_handle_index (treptr args)
{
	treptr handle = trearg_get (args);

	while (handle != treptr_nil && TREPTR_IS_NUMBER(handle) == FALSE)
		handle = trearg_correct (1, TRETYPE_NUMBER, handle, "stream handle or NIL for stdout");
    return (int) TRENUMBER_VAL(handle);
}

FILE *
trestream_builtin_get_handle (treptr args, FILE * default_stream)
{
	treptr handle = trearg_get (args);

    return (handle != treptr_nil) ?
           tre_fileio_handles[trestream_builtin_get_handle_index (args)] :
 		   default_stream;
}

treptr
trestream_builtin_force_output (treptr args)
{
    FILE  * str = trestream_builtin_get_handle (args, stdout);

    fflush (str);
    return treptr_nil;
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
    char  c;

    c = fgetc (str);
    return treatom_number_get ((double) abs (c), TRENUMTYPE_CHAR);
}

#include <stdio.h>
#include <unistd.h>
#include <termios.h>

treptr
trestream_builtin_terminal_raw (treptr dummy)
{
    struct termios settings;
    long result;
    long desc = STDIN_FILENO;

    result = tcgetattr (desc, &settings);
    settings.c_lflag &= ~(ICANON | ECHO);
    settings.c_cc[VMIN] = 1;
    settings.c_cc[VTIME] = 0;
    result = tcsetattr (desc, TCSANOW, &settings);

	return treptr_nil;
}

treptr
trestream_builtin_terminal_normal (treptr dummy)
{
    struct termios settings;
    long result;
    long desc = STDIN_FILENO;

    result = tcgetattr (desc, &settings);
    settings.c_lflag |= ICANON | ECHO;
    settings.c_cc[VMIN] = 1;
    settings.c_cc[VTIME] = 0;
    result = tcsetattr (desc, TCSANOW, &settings);

	return treptr_nil;
}
