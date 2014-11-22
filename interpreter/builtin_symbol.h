/*
 * tré – Copyright (c) 2005–2006,2008–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_SYMBOL_H
#define TRE_BUILTIN_SYMBOL_H

extern treptr tresymbol_make (treptr name, treptr package);
extern treptr tresymbol_value (treptr);
extern treptr tresymbol_set_value (treptr value, treptr);
extern treptr tresymbol_function (treptr);
extern treptr tresymbol_set_function (treptr function, treptr);
extern treptr tresymbol_package (treptr);

extern treptr tresymbol_builtin_make_package (treptr);

#endif	/* #ifndef TRE_BUILTIN_SYMBOL_H */
