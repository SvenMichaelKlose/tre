/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_XXX_H
#define TRE_XXX_H

#define RETURN_NIL(x)	    if (NOT(x)) return NIL;
#define RETURN_IF_NULL(x)   if (x == NULL) return;
#define RETURN_IF_NIL(x)    if (NOT(x)) return;

#define STR(x)		#x

#endif	/* #ifndef TRE_XXX_H */
