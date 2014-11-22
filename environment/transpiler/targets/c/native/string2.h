/*
 * tré – Copyright (c) 2005–2008,2011,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_STRING_H
#define TRE_STRING_H

#include <sys/types.h>

#define TRESTRING_LEN(x)                (*(tre_size *)x)
#define TRESTRING_DATA(x)               ((char *) x + sizeof (tre_size))
#define TREPTR_STRING(ptr)              ATOM(ptr)                                                             
#define TREPTR_STRINGLEN(ptr)           TRESTRING_LEN(TREPTR_STRING(ptr))
#define TREPTR_STRINGZ(ptr)             TRESTRING_DATA(TREPTR_STRING(ptr))

extern treptr tre_strings;
extern treptr trestring_get         (const char *string);
extern treptr trestring_get_binary  (const char *string, tre_size len);
extern void   trestring_free        (treptr);
extern char * trestring_get_raw     (tre_size len);

extern struct tre_sequence_type trestring_seqtype;

extern void   trestring_copy (char * to, treptr str);

#endif
