/*
 * tré – Copyright (c) 2005–2008 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_XXX_H
#define TRE_XXX_H

#define RETURN_NIL(x)	    if (x == treptr_nil) return treptr_nil;
#define RETURN_IF_NULL(x)   if (x == NULL) return;
#define RETURN_IF_NIL(x)    if (x == treptr_nil) return;

#define CRASH()		(*(char *) 0 = 0)

#define STR(x)		#x

#endif	/* #ifndef TRE_XXX_H */
