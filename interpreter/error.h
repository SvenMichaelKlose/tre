/*
 * tré – Copyright (c) 2005–2008,2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ERROR_H
#define TRE_ERROR_H

extern void   treerror_internal (treptr, const char *msg, ...);
extern treptr treerror (treptr, const char *msg, ...);
extern void   treerror_norecover (treptr, const char *msg, ...) __attribute((noreturn));
extern void   trewarn (treptr, const char *msg, ...);

#endif	/* #ifndef TRE_ERROR_H */
