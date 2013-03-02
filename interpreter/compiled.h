/*
 * tré – Copyright (c) 2009 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_COMPILED_H
#define TRE_COMPILED_H

#define _TREVEC(vec, index)  ((treptr *) TREATOM_DETAIL(vec)) [(unsigned long) index]
#define _TRELOCAL(index)     ((treptr *) _locals) [(unsigned long) index]

#endif /* #ifndef TRE_COMPILED_H */
