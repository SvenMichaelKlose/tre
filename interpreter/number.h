/*
 * tré – Copyright (c) 2005–2008,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_NUMBERS_H
#define TRE_NUMBERS_H

#define TRENUMTYPE_CHAR   	0
#define TRENUMTYPE_INTEGER  1
#define TRENUMTYPE_FLOAT 	2

struct tre_number {
    double  value;
    char    type;
};

#define TREPTR_NUMBER(ptr)     ((struct tre_number *) TREATOM_DETAIL(ptr))
#define TRENUMBER_VAL(ptr)     TREPTR_NUMBER(ptr)->value
#define TRENUMBER_INT(ptr)     ((int) TRENUMBER_VAL(ptr))
#define TRENUMBER_CHARPTR(ptr) ((char *) (long) TREPTR_NUMBER(ptr)->value)
#define TRENUMBER_TYPE(ptr)    TREPTR_NUMBER(ptr)->type

extern bool   trenumber_is_value (char *);

extern struct tre_number * trenumber_alloc (double value, int type);
extern void   trenumber_free (treptr);

extern void   trenumber_init (void);

#endif
