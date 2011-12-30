/*
 * tré - Copyright (c) 2005-2008,2011 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_STRING_H
#define TRE_STRING_H

#include <sys/types.h>

#define TRESTRING_LEN(x) (*(size_t*)x)
#define TRESTRING_DATA(x) (((char*) x) + sizeof (size_t))

extern treptr tre_strings;
extern treptr trestring_get (const char *string);
extern void trestring_free (treptr);
extern char *trestring_get_raw (size_t len);

extern struct tre_sequence_type trestring_seqtype;

extern void trestring_copy (char *to, treptr str);

#endif
