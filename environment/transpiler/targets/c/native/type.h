/*
 * tré – Copyright (c) 2005–2007,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_TYPE_H
#define TRE_TYPE_H

/* NOTE: You must change %TYPE-ID callers with these. */
/* NOTE: Keep in sync with error.c:treerror_typename(). */
/* NOTE: Keep in sync with builtin_sequence.c:tre_sequence_types[]. */

#define TRETYPE_CONS		0
#define TRETYPE_SYMBOL      1
#define TRETYPE_NUMBER		2
#define TRETYPE_STRING		3
#define TRETYPE_ARRAY		4
#define TRETYPE_BUILTIN		5
#define TRETYPE_SPECIAL		6
#define TRETYPE_MACRO		7
#define TRETYPE_FUNCTION	8
#define TRETYPE_USERSPECIAL	9
#define TRETYPE_MAXTYPE		9
#define TRETYPE_UNUSED		10

#define TRETYPE_WIDTH		4

#define TRETYPECHK(argnum, object, type, descr) (trearg_typed (argnum, type, object, descr))

extern const char * tretype_name (unsigned);

#endif /* #ifndef TRE_TYPE_H */
