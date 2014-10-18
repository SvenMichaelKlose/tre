/*
 * tré – Copyright (c) 2005–2007,2009,2012,2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_FUNCALL_H
#define TRE_FUNCALL_H

extern treptr funcall_compiled  (treptr func, treptr args, bool do_eval);
extern treptr funcall           (treptr func, treptr args);

#endif	/* #ifndef TRE_FUNCALL_H */
