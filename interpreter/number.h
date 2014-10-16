/*
 * tré – Copyright (c) 2005–2008,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_NUMBERS_H
#define TRE_NUMBERS_H

#define TRENUMTYPE_CHAR   	0
#define TRENUMTYPE_INTEGER  1
#define TRENUMTYPE_FLOAT 	2

struct trenumber_t {
    double  value;
    char    type;
};

typedef struct trenumber_t trenumber;

#define TREPTR_NUMBER(ptr)     ((trenumber *) TREATOM(ptr))
#define TRENUMBER_VAL(ptr)     TREPTR_NUMBER(ptr)->value
#define TRENUMBER_INT(ptr)     ((int) TRENUMBER_VAL(ptr))
#define TRENUMBER_CHARPTR(ptr) ((char *) (long) TREPTR_NUMBER(ptr)->value)
#define TRENUMBER_TYPE(ptr)    TREPTR_NUMBER(ptr)->type

extern bool         trenumber_is_value (char *);

extern trenumber *  trenumber_alloc (double value, int type);
extern void         trenumber_free (treptr);

extern treptr       number_get (double, int type);                                                    
extern treptr       number_get_float (double);
extern treptr       number_get_integer (double);
extern treptr       number_get_char (double);

extern void   trenumber_init (void);

#endif
