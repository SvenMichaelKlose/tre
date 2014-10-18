/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ASSERT_H
#define TRE_ASSERT_H

#include "config.h"
#include "type.h"

#define _ASSERT(x, pred, type) \
    if (!pred(x)) \
        treerror_norecover (x, type " expected.");

#ifdef TRE_NO_ASSERTIONS
#define ASSERT_CONS(x)
#define ASSERT_ATOM(x)
#define ASSERT_LIST(x)
#define ASSERT_SYMBOL(x)
#define ASSERT_NUMBER(x)
#define ASSERT_STRING(x)
#define ASSERT_ARRAY(x)
#define ASSERT_BUILTIN(x)
#define ASSERT_SPECIAL(x)
#define ASSERT_MACRO(x)
#define ASSERT_FUNCTION(x)
#define ASSERT_CALLABLE(x)
#define ASSERT_ANY_FUNCTION(x)
#else
#define ASSERT_CONS(x)     _ASSERT(x, CONSP,     "Cons")
#define ASSERT_ATOM(x)     _ASSERT(x, ATOMP,     "Atom")
#define ASSERT_LIST(x)     _ASSERT(x, LISTP,     "List")
#define ASSERT_SYMBOL(x)   _ASSERT(x, SYMBOLP,   "Symbol")
#define ASSERT_NUMBER(x)   _ASSERT(x, NUMBERP,   "Number")
#define ASSERT_STRING(x)   _ASSERT(x, STRINGP,   "String")
#define ASSERT_ARRAY(x)    _ASSERT(x, ARRAYP,    "Array")
#define ASSERT_BUILTIN(x)  _ASSERT(x, BUILTINP,  "Builtin")
#define ASSERT_SPECIAL(x)  _ASSERT(x, SPECIALP,  "Special form")
#define ASSERT_MACRO(x)    _ASSERT(x, MACROP,    "Macro")
#define ASSERT_FUNCTION(x)	_ASSERT(x, FUNCTIONP, "Function")
#define ASSERT_CALLABLE(x)	_ASSERT(x, CALLABLEP, "Function or macro")
#define ASSERT_ANY_FUNCTION(x)	_ASSERT(x, ANY_FUNCTIONP, "Any kind of function")
#endif

#endif /* #ifndef TRE_ASSERT_H */
