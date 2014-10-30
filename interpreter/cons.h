/*
 * tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
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

#define _CADR(x) 	_CAR(_CDR(x))

#define CONS(a, d)  cons (a, d)

#ifdef TRE_NO_ASSERTIONS
#define CAR(x) 		_CAR(x)
#define CDR(x) 		_CDR(x)
#define CPR(x) 		_CPR(x)
#else
#define CAR(x) 		(car (x))
#define CDR(x) 		(cdr (x))
#define CPR(x) 		(cpr (x))
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

#define RPLACA(x,v) 	(rplaca (x, v))
#define RPLACD(x,v) 	(rplacd (x, v))
#define RPLACP(x,v) 	(rplacp (x, v))

#define _RPLACA(x,v) 	(_CAR(x) = v)
#define _RPLACD(x,v) 	(_CDR(x) = v)
#define _RPLACP(x,v) 	(_CPR(x) = v)

#ifdef TRE_NO_ASSERTIONS
#define DOLIST(iter, lst) _DOLIST(iter, lst)
#else
#define DOLIST(iter, lst) \
    if (!LISTP(lst)) \
        treerror_norecover (lst, "DOLIST expects a list."); \
    else \
        for (iter = lst; NOT_NIL(iter); iter = CDR(iter))
#endif

#define _DOLIST(iter,lst) \
    for (iter = lst; NOT_NIL(iter); iter = _CDR(iter))

#define TRE_MARK(marks, i)     (marks[i >> 3] |= (1 << (i & 7)))
#define TRE_UNMARK(marks, i)   (marks[i >> 3] &= ~(1 << (i & 7)))
#define TRE_GETMARK(marks, i)  (marks[i >> 3] & (1 << (i & 7)))

extern void trecons_init (void);

extern struct   tre_list tre_lists[NUM_LISTNODES];
extern treptr   tre_listprops[NUM_LISTNODES];
extern treptr   tre_default_listprop;
extern treptr   conses_free;
extern tre_size conses_used;

extern treptr cons (treptr car, treptr cdr);

extern treptr car (treptr);
extern treptr cdr (treptr);
extern treptr cpr (treptr);

extern treptr rplaca (treptr, treptr);
extern treptr rplacd (treptr, treptr);
extern treptr rplacp (treptr, treptr);

extern void   cons_free (treptr);
extern void   cons_free_list (treptr);
extern void   cons_free_tree (treptr);

#endif 	/* #ifndef TRE_CONS_H */
