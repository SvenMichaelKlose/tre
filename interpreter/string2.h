/*
 * TRE interpreter
 * Copyright (c) 2005-2008,2011 Sven Klose <pixel@copei.de>
 *
 * String-type related section.
 */

#ifndef TRE_STRING_H
#define TRE_STRING_H

#define TRESTRING_LEN(x) (*(ulong*)x)
#define TRESTRING_DATA(x) (((char*) x) + sizeof (ulong))

extern treptr tre_strings;
extern treptr trestring_get (const char *string);
extern void trestring_free (treptr);
extern char *trestring_get_raw (ulong len);

extern struct tre_sequence_type trestring_seqtype;

extern void trestring_copy (char *to, treptr str);

#endif
