/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * List-related section.
 */

#ifndef LISP_LIST_H
#define LISP_LIST_H

#define LAST_LISTNODE	(NUM_LISTNODES_TOTAL - 1)

struct lisp_list {
    lispptr car;
    lispptr cdr;
};

#define _CAR(x) 	(lisp_lists[x].car)
#define _CDR(x) 	(lisp_lists[x].cdr)

#define CONS(a,d)	_lisplist_get (a, d)

#ifdef LISP_DIAGNOSTICS
#define CAR(x) 		(lisplist_car (x))
#define CDR(x) 		(lisplist_cdr (x))
#else
#define CAR(x) 		_CAR(x)
#define CDR(x) 		_CDR(x)
#endif

#define CADR(x) 	CAR(CDR(x))
#define CAAR(x) 	CAR(CAR(x))
#define CDDR(x) 	CDR(CDR(x))
#define CADDR(x) 	CAR(CDR(CDR(x)))

#define RPLACA(x,v) 	(lisplist_rplaca (x, v))
#define RPLACD(x,v) 	(lisplist_rplacd (x, v))

#define _RPLACA(x,v) 	(_CAR(x) = v)
#define _RPLACD(x,v) 	(_CDR(x) = v)

#define LISPLIST_SET(ptr, a, b) \
	_CAR(ptr) = a;	\
	_CDR(ptr) = b

#define DOLIST(iter,lst) \
    for (iter = lst; iter != lispptr_nil; iter = CDR(iter))

#define _DOLIST(iter,lst) \
    for (iter = lst; iter != lispptr_nil; iter = _CDR(iter))

#define LISP_MARK(marks, i)     (marks[i >> 3] |= (1 << (i & 7)))
#define LISP_UNMARK(marks, i)   (marks[i >> 3] &= ~(1 << (i & 7)))
#define LISP_GETMARK(marks, i)  (marks[i >> 3] & (1 << (i & 7)))

#ifndef LISP_NO_MANUAL_FREE
#define LISPLIST_FREE_EARLY(l)		lisplist_free (l)
#define LISPLIST_FREE_TOPLEVEL_EARLY(l)	lisplist_free_toplevel (l)
#else
#define LISPLIST_FREE_EARLY(l)
#define LISPLIST_FREE_TOPLEVEL_EARLY(l)
#endif

#define LISPLIST_PUSH(stack, expr) \
    stack = _lisplist_get (expr, stack);

#define LISPLIST_POP(stack) \
    { int __llpp = CDR(stack); 	\
      lisplist_free (stack);	\
      stack = __llpp;		\
    }
#define LISPLIST_DEFREGS() \
	lispptr car;	\
	lispptr cdr

extern void lisplist_init (void);

extern struct lisp_list lisp_lists[NUM_LISTNODES_TOTAL];
extern lispptr lisplist_free_nodes;
extern unsigned lisplist_num_used;

extern lispptr _lisplist_get (lispptr car, lispptr cdr);
extern lispptr lisplist_copy (lispptr);
extern lispptr lisplist_copy_tree (lispptr);
extern lispptr lisplist_delete (unsigned, lispptr);
extern void lisplist_append (lispptr *lst, lispptr lst2);
extern lispptr lisplist_reverse (lispptr);
extern int lisplist_position (lispptr elt, lispptr lst);
extern unsigned lisplist_length (lispptr);
extern bool lisplist_equal (lispptr, lispptr);
extern lispptr lisplist_nth (lispptr, unsigned);
extern lispptr lisplist_last (lispptr);

extern void lisplist_free (lispptr);
extern void lisplist_free_expr (lispptr);
extern void lisplist_free_toplevel (lispptr);

extern struct lisp_sequence_type lisplist_seqtype;

extern bool lisplist_check_type (lispptr, unsigned atom_type);

#ifdef LISP_DIAGNOSTICS
extern lispptr lisplist_car (lispptr);
extern lispptr lisplist_cdr (lispptr);
#endif

extern void lisplist_rplaca (lispptr, lispptr);
extern void lisplist_rplacd (lispptr, lispptr);

#endif 	/* #ifndef LISP_LIST_H */
