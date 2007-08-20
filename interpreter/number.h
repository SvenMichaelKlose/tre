/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Number-related section.
 */

#ifndef TRE_NUMBERS_H
#define TRE_NUMBERS_H

#define TRENUMTYPE_CHAR   	0
#define TRENUMTYPE_INTEGER   	1
#define TRENUMTYPE_FLOAT 	2

struct tre_number {
    float   value;
    int     type;
};

#define TRE_NUMBER(index) (&tre_numbers[index])
#define TRENUMBER_VAL(ptr) \
	((TRE_NUMBER((unsigned) TREATOM_DETAIL(ptr)))->value)
#define TRENUMBER_TYPE(ptr) \
	((TRE_NUMBER((unsigned) TREATOM_DETAIL(ptr)))->type)

extern struct tre_number tre_numbers[NUM_NUMBERS];
extern treptr tre_numbers_free;

/* Check if string contains a number. */
extern bool trenumber_is_value (char *);

extern unsigned trenumber_alloc (float value, int type);
extern void trenumber_free (treptr);

extern void trenumber_init (void);

#endif
