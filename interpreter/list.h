/*
 * tré – Copyright (c) 2005–2009,2011–2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_LIST_H
#define TRE_LIST_H

#include <stddef.h>

#define LAST_LISTNODE	(NUM_LISTNODES - 1)

struct tre_list {
    treptr car;
    treptr cdr;
};

#define _CAR(x) 	(tre_lists[x].car)
#define _CDR(x) 	(tre_lists[x].cdr)

#define CONS(a,d)	_trelist_get (a, d)

#ifdef TRE_LIST_DIAGNOSTICS
#define CAR(x) 		(trelist_car (x))
#define CDR(x) 		(trelist_cdr (x))
#else
#define CAR(x) 		_CAR(x)
#define CDR(x) 		_CDR(x)
#endif

#define CADR(x) 	CAR(CDR(x))
#define CAAR(x) 	CAR(CAR(x))
#define CDDR(x) 	CDR(CDR(x))
#define CDAR(x) 	CDR(CAR(x))
#define CADAR(x) 	CAR(CDR(CAR(x)))
#define CADDR(x) 	CAR(CDR(CDR(x)))
#define CADDDR(x) 	CAR(CDR(CDR(CDR(x))))
#define CDDAR(x) 	CDR(CDR(CDR(x)))
#define CDDDR(x) 	CDR(CDR(CDR(x)))

#define FIRST(x) 	CAR(x)
#define SECOND(x) 	CADR(x)
#define THIRD(x) 	CADDR(x)

#define RPLACA(x,v) 	(trelist_rplaca (x, v))
#define RPLACD(x,v) 	(trelist_rplacd (x, v))

#define _RPLACA(x,v) 	(_CAR(x) = v)
#define _RPLACD(x,v) 	(_CDR(x) = v)

#define TRELIST_SET(ptr, a, b) \
	_CAR(ptr) = a;	\
	_CDR(ptr) = b

#define DOLIST(iter,lst) \
    for (iter = lst; iter != treptr_nil; iter = CDR(iter))

#define _DOLIST(iter,lst) \
    for (iter = lst; iter != treptr_nil; iter = _CDR(iter))

#define TRE_MARK(marks, i)     (marks[i >> 3] |= (1 << (i & 7)))
#define TRE_UNMARK(marks, i)   (marks[i >> 3] &= ~(1 << (i & 7)))
#define TRE_GETMARK(marks, i)  (marks[i >> 3] & (1 << (i & 7)))

#ifndef TRE_NO_MANUAL_FREE
#define TRELIST_FREE_EARLY(l)		trelist_free (l)
#define TRELIST_FREE_TOPLEVEL_EARLY(l)	trelist_free_toplevel (l)
#else
#define TRELIST_FREE_EARLY(l)
#define TRELIST_FREE_TOPLEVEL_EARLY(l)
#endif

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

extern void trelist_init (void);

extern struct tre_list tre_lists[NUM_LISTNODES];
extern treptr tre_lists_free;
extern size_t trelist_num_used;

extern treptr _trelist_get (treptr car, treptr cdr);
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

extern void   trelist_free (treptr);
extern void   trelist_free_expr (treptr);
extern void   trelist_free_toplevel (treptr);

extern struct tre_sequence_type trelist_seqtype;

extern bool   trelist_check_type (treptr, ulong atom_type) __attribute__((pure));

#ifdef TRE_LIST_DIAGNOSTICS
extern treptr trelist_car (treptr);
extern treptr trelist_cdr (treptr);
#endif

extern void   trelist_rplaca (treptr, treptr);
extern void   trelist_rplacd (treptr, treptr);

#endif 	/* #ifndef TRE_LIST_H */
