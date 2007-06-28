/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Number-related section.
 */

#ifndef LISP_BUILTIN_NUMBER_H
#define LISP_BUILTIN_NUMBER_H

extern lispptr lispnumber_builtin_numberp (lispptr);
extern lispptr lispnumber_builtin_code_char (lispptr);
extern lispptr lispnumber_builtin_integer (lispptr);
extern lispptr lispnumber_builtin_characterp (lispptr);

#endif
