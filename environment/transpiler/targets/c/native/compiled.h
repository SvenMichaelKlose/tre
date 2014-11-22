/*
 * tré – Copyright (c) 2009,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_COMPILED_H
#define TRE_COMPILED_H

#define _TREVEC(vec, index)  ((TREARRAY_VALUES(vec)) [(size_t) index])
#define _TRELOCAL(index)     (((treptr *) _locals) [(size_t) index])

#endif /* #ifndef TRE_COMPILED_H */
