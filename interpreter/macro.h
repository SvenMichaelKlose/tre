/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Macro expansion
 */

#ifndef LISP_MACRO_H
#define LISP_MACRO_H

extern lispptr lispptr_current_macro;

extern lispptr lispmacro_builtin_macroexpand_1 (lispptr);
extern lispptr lispmacro_builtin_macroexpand (lispptr);

extern void lispmacro_init (void);

#endif 	/* #ifndef LISP_MACRO_H */
