/*
 * tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BYECODE_H
#define TRE_BYECODE_H

extern void trecode_init ();
extern treptr trecode_exec (treptr bytecode_array);
extern treptr trecode_call (treptr fun, treptr args);

#endif
