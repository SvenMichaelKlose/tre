/*
 * tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
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

extern treptr trelist_copy (treptr);
extern treptr trelist_copy_tree (treptr);
extern treptr trelist_delete (ulong, treptr);
extern void   trelist_append (treptr *lst, treptr lst2);
extern long   trelist_position (treptr elt, treptr lst);
extern long   trelist_position_name (treptr elt, treptr lst);
extern size_t trelist_length (treptr);
extern bool   trelist_equal (treptr, treptr);
extern treptr trelist_nth (treptr, ulong);
extern treptr trelist_last (treptr);
extern bool   trelist_check_type (treptr, ulong atom_type);

#endif 	/* #ifndef TRE_LIST_H */
