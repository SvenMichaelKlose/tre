/*
 * tré – Copyright (c) 2005–2009,2011–2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_LIST_H
#define TRE_LIST_H

#include <stddef.h>

#define TRELIST_PUSH(stack, expr) \
    stack = _trelist_get (expr, stack);

#define TRELIST_POP(stack) \
    { int __llpp = CDR(stack); 	\
      trelist_free (stack);	\
      stack = __llpp;		\
    }
#define TRELIST_DEFREGS() \
	treptr car;	\
	treptr cdr

extern struct tre_sequence_type trelist_seqtype;

extern treptr trelist_copy (treptr) __attribute__((pure));
extern treptr trelist_copy_tree (treptr) __attribute__((pure));
extern treptr trelist_delete (ulong, treptr);
extern void   trelist_append (treptr *lst, treptr lst2) __attribute__((pure));
extern long   trelist_position (treptr elt, treptr lst) __attribute__((pure));
extern long   trelist_position_name (treptr elt, treptr lst) __attribute__ ((pure));
extern size_t trelist_length (treptr) __attribute__((pure));
extern bool   trelist_equal (treptr, treptr) __attribute__((pure));
extern treptr trelist_nth (treptr, ulong) __attribute__((pure));
extern treptr trelist_last (treptr) __attribute__((pure));
extern bool   trelist_check_type (treptr, ulong atom_type) __attribute__((pure));

#endif 	/* #ifndef TRE_LIST_H */
