/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * String-type related section.
 */

#ifndef LISP_BUILTIN_STRING_H
#define LISP_BUILTIN_STRING_H

extern lispptr lispstring_builtin_stringp (lispptr);
extern lispptr lispstring_builtin_concat (lispptr);
extern lispptr lispstring_builtin_make (lispptr);

extern lispptr lispstring_builtin_symbol_name (lispptr);
extern lispptr lispstring_builtin_string (lispptr);

#endif
