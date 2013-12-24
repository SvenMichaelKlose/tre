/*
 * tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_CONS_H
#define TRE_CONS_H

#include <stddef.h>

#define FIRST_LISTNODE	1
#define LAST_LISTNODE	(NUM_LISTNODES - 1)

struct tre_list {
    treptr car;
    treptr cdr;
};

#define _CAR(x) 	(tre_lists[x].car)
#define _CDR(x) 	(tre_lists[x].cdr)
#define _CPR(x) 	(tre_listprops[x])

#define CONS(a,d)	trelist_get (a, d)

#ifdef TRE_LIST_DIAGNOSTICS
#define CAR(x) 		(trelist_car (x))
#define CDR(x) 		(trelist_cdr (x))
#define CPR(x) 		(trelist_cpr (x))
#else
#define CAR(x) 		_CAR(x)
#define CDR(x) 		_CDR(x)
#define CPR(x) 		_CPR(x)
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
#define RPLACP(x,v) 	(trelist_rplacp (x, v))

#define _RPLACA(x,v) 	(_CAR(x) = v)
#define _RPLACD(x,v) 	(_CDR(x) = v)
#define _RPLACP(x,v) 	(_CPR(x) = v)

#define DOLIST(iter,lst) \
    for (iter = lst; NOT_NIL(iter); iter = CDR(iter))

#define _DOLIST(iter,lst) \
    for (iter = lst; NOT_NIL(iter); iter = _CDR(iter))

#define TRE_MARK(marks, i)     (marks[i >> 3] |= (1 << (i & 7)))
#define TRE_UNMARK(marks, i)   (marks[i >> 3] &= ~(1 << (i & 7)))
#define TRE_GETMARK(marks, i)  (marks[i >> 3] & (1 << (i & 7)))

extern void trecons_init (void);

extern struct tre_list tre_lists[NUM_LISTNODES];
extern treptr tre_listprops[NUM_LISTNODES];
extern treptr tre_default_listprop;
extern treptr tre_lists_free;
extern tre_size trelist_num_used;

extern treptr trelist_get (treptr car, treptr cdr);
extern void   trelist_free (treptr);
extern void   trelist_free_expr (treptr);
extern void   trelist_free_toplevel (treptr);

extern treptr trelist_car (treptr);
extern treptr trelist_cdr (treptr);
extern treptr trelist_cpr (treptr);

extern treptr trelist_rplaca (treptr, treptr);
extern treptr trelist_rplacd (treptr, treptr);
extern treptr trelist_rplacp (treptr, treptr);

#endif 	/* #ifndef TRE_CONS_H */
