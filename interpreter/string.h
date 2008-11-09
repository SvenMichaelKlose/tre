/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * String-type related section.
 */

#ifndef TRE_STRING_H
#define TRE_STRING_H

struct tre_string {
    ulong	len;
    char	str;
};

extern treptr tre_strings;
extern treptr trestring_get (const char *string);
extern void trestring_free (treptr);
extern struct tre_string *trestring_get_raw (ulong len);

extern struct tre_sequence_type trestring_seqtype;

extern void trestring_copy (char *to, treptr str);

#endif
