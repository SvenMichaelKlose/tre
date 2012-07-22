/*
 * tré – Copyright (c) 2005–2008,2012 Sven MichaelKlose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_MACRO_H
#define TRE_MACRO_H

extern treptr treptr_current_macro;

extern treptr tremacro_builtin_macroexpand_1 (treptr);
extern treptr tremacro_builtin_macroexpand (treptr);

extern void tremacro_init (void);

#endif 	/* #ifndef TRE_MACRO_H */

#endif /* #ifdef INTERPRETER */
