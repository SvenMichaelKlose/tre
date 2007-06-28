/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * String-type related section.
 */

#ifndef LISP_STRING_H
#define LISP_STRING_H

struct lisp_string {
    unsigned  len;
    char      str;
};

extern lispptr lisp_strings;
extern lispptr lispstring_get (const char *string);
extern void lispstring_free (lispptr);
extern struct lisp_string *lispstring_get_raw (unsigned len);

extern struct lisp_sequence_type lispstring_seqtype;

extern void lispstring_copy (char *to, lispptr str);

#endif
