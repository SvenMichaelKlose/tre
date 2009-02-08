/*
 * TRE interpreter
 * Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
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
#include "builtin_stream.h"

#include <stdlib.h>

/*tredoc
  (cmd :name %PRINC
	(arg :name obj :type (variable number string))
	(arg :type interpreter-stream-handle)
	(descr "Prints object through interpreter-stream.")
	(returns-argument obj))
 */
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
	    	fprintf (str, "%s", TREATOM_STRINGP(obj));
	    	break;

		case TRETYPE_VARIABLE:
	    	fprintf (str, "%s", TREATOM_NAME(obj));
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

/*tredoc
  (cmd :name %FORCE-OUTPUT
	(arg :type interpreter-stream-handle)
	(descr "Flushes all pending output of a stream.")
	(see-also-manpage fflush))
 */
treptr
trestream_builtin_force_output (treptr args)
{
    FILE  * str = trestream_builtin_get_handle (args, stdout);

    fflush (str);
    return treptr_nil;
}

/*tredoc
  (cmd :name %FEOF
	(arg :type interpreter-stream-handle)
	(descr "Checks if stream reached the end of its input,")
	(returns boolean))
 */
treptr
trestream_builtin_feof (treptr args)
{
    FILE  * str = trestream_builtin_get_handle (args, stdin);

    return TREPTR_TRUTH(feof (str));
}

/*tredoc
  (cmd :name %FCLOSE
	(arg :type interpreter-stream-handle)
	(descr "Closes interpreter-stream,"))
 */
treptr
trestream_builtin_fclose (treptr args)
{
    long  str = trestream_builtin_get_handle_index (args);

    return TREPTR_TRUTH(trestream_fclose (str));
}

/*tredoc
  (cmd :name %READ-CHAR
	(arg :type interpreter-stream-handle)
	(descr "Reads character from interpreter-stream,")
	(returns character))
 */
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

/*tredoc
  (cmd :name %TERMINAL-RAW
	(descr "Switches current terminal to raw I/O."))
 */
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

/*tredoc
  (cmd :name %TERMINAL-NORMAL
	(descr "Switches current terminal to buffered I/O."))
 */
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
