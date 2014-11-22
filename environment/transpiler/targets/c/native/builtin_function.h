/*
 * tré – Copyright (c) 2005–2006,2008–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_FUNCTION_H
#define TRE_BUILTIN_FUNCTION_H

extern treptr trefunction_native (treptr);
extern treptr trefunction_bytecode (treptr);
extern treptr trefunction_set_bytecode (treptr, treptr);
extern treptr trefunction_name (treptr);
extern treptr trefunction_source (treptr);
extern treptr trefunction_set_source (treptr, treptr);
extern treptr trefunction_make_function (treptr source);

#endif	/* #ifndef TRE_BUILTIN_FUNCTION_H */
