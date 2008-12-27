/*
 * TRE interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Error handling
 */

#ifndef TRE_ERROR_H
#define TRE_ERROR_H

extern void treerror_internal (treptr, const char *msg, ...);
extern treptr treerror (treptr, const char *msg, ...);
extern void treerror_norecover (treptr, const char *msg, ...);
extern void trewarn (treptr, const char *msg, ...);

extern const char * treerror_typename (ulong);

#endif	/* #ifndef TRE_ERROR_H */
