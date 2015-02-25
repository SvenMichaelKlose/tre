/*
 * tré – Copyright (c) 2006–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <termios.h>
#include <unistd.h>

#include "ptr.h"
#include "builtin_terminal.h"

treptr
treterminal_builtin_raw (treptr no_args)
{
    struct termios settings;
    long desc = STDIN_FILENO;

    (void) no_args;

    (void) tcgetattr (desc, &settings);
    settings.c_lflag &= ~(ICANON | ECHO);
    settings.c_cc[VMIN] = 1;
    settings.c_cc[VTIME] = 0;
    (void) tcsetattr (desc, TCSANOW, &settings);

	return NIL;
}

treptr
treterminal_builtin_normal (treptr no_args)
{
    struct termios settings;
    long desc = STDIN_FILENO;

    (void) no_args;

    (void) tcgetattr (desc, &settings);
    settings.c_lflag |= ICANON | ECHO;
    settings.c_cc[VMIN] = 1;
    settings.c_cc[VTIME] = 0;
    (void) tcsetattr (desc, TCSANOW, &settings);

	return NIL;
}
