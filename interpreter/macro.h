/*
 * TRE tree processor
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Macro expansion
 */

#ifndef TRE_MACRO_H
#define TRE_MACRO_H

extern treptr treptr_current_macro;

extern treptr tremacro_builtin_macroexpand_1 (treptr);
extern treptr tremacro_builtin_macroexpand (treptr);

extern void tremacro_init (void);

#endif 	/* #ifndef TRE_MACRO_H */
