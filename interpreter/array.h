/*
 * tré – Copyright (c) 2005-2007,2009,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ARRAY_H
#define TRE_ARRAY_H

struct tre_array_t {
    treptr    sizes;
    treptr *  values;
};

typedef struct tre_array_t trearray;

#define TREPTR_ARRAY(ptr)    ((trearray *) ATOM(ptr))
#define TREARRAY_SIZES(ptr)  (TREPTR_ARRAY(ptr)->sizes)
#define TREARRAY_VALUES(ptr) (TREPTR_ARRAY(ptr)->values)
#define TREARRAY_SIZE(ptr)   (trearray_get_size (TREARRAY_SIZES(ptr)))

extern void trearray_init (void);

extern treptr   trearray_get (treptr sizes);
extern void     trearray_free (treptr);
extern tre_size trearray_get_size (treptr sizes);

extern struct tre_sequence_type trearray_seqtype;

/* for compiled code */
extern treptr trearray_make (tre_size size);

#endif
