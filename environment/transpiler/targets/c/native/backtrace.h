/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BACKTRACE_H
#define TRE_BACKTRACE_H

extern treptr  treptr_backtrace;

extern void    trebacktrace_push (treptr);
extern void    trebacktrace_pop (void);

extern treptr  trebacktrace (void);
extern void    trebacktrace_init (void);

#endif	/* #ifndef TRE_BACKTRACE_H */
