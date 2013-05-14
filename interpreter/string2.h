/*
 * tré – Copyright (c) 2005–2008,2011,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_STRING_H
#define TRE_STRING_H

#include <sys/types.h>

#define TRESTRING_LEN(x) (*(size_t*)x)
#define TRESTRING_DATA(x) (((char*) x) + sizeof (size_t))
#define TREPTR_STRING(ptr)              TREATOM_DETAIL(ptr)                                                             
#define TREPTR_STRINGZ(ptr)             TRESTRING_DATA(TREPTR_STRING(ptr))
#define TREATOM_SET_STRING(ptr, val)    (TREATOM_DETAIL(ptr) = (char *) val)

extern treptr tre_strings;
extern treptr trestring_get (const char *string);
extern treptr trestring_get_binary (const char *string, size_t len);
extern void   trestring_free (treptr);
extern char * trestring_get_raw (size_t len);

extern struct tre_sequence_type trestring_seqtype;

extern void   trestring_copy (char *to, treptr str);

#endif
