/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Number-related section.
 */

#ifndef LISP_NUMBERS_H
#define LISP_NUMBERS_H

#define LISPNUMTYPE_CHAR   	0
#define LISPNUMTYPE_INTEGER   	1
#define LISPNUMTYPE_FLOAT 	2

struct lisp_number {
    float   value;
    int     type;
};

#define LISP_NUMBER(index) (&lisp_numbers[index])
#define LISPNUMBER_VAL(ptr) \
	((LISP_NUMBER((int) LISPATOM_DETAIL(ptr)))->value)
#define LISPNUMBER_TYPE(ptr) \
	((LISP_NUMBER((int) LISPATOM_DETAIL(ptr)))->type)

extern struct lisp_number lisp_numbers[NUM_NUMBERS];
extern lispptr lisp_numbers_unused;

/* Check if string contains a number. */
extern bool lispnumber_is_value (char *);

extern unsigned lispnumber_alloc (float value, int type);
extern void lispnumber_free (lispptr);

extern void lispnumber_init (void);

#endif
