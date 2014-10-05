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
#define ASSERT_CONSP(x)
#define ASSERT_ATOMP(x)
#define ASSERT_LISTP(x)
#define ASSERT_SYMBOLP(x)
#define ASSERT_NUMBERP(x)
#define ASSERT_STRINGP(x)
#define ASSERT_ARRAYP(x)
#define ASSERT_BUILTINP(x)
#define ASSERT_SPECIALP(x)
#define ASSERT_MACROP(x)
#define ASSERT_FUNCTIONP(x)
#else
#define ASSERT_CONSP(x)     _ASSERT(x, CONSP,     "Cons")
#define ASSERT_ATOMP(x)     _ASSERT(x, ATOMP,     "Atom")
#define ASSERT_LISTP(x)     _ASSERT(x, LISTP,     "List")
#define ASSERT_SYMBOLP(x)   _ASSERT(x, SYMBOLP,   "Symbol")
#define ASSERT_NUMBERP(x)   _ASSERT(x, NUMBERP,   "Number")
#define ASSERT_STRINGP(x)   _ASSERT(x, STRINGP,   "String")
#define ASSERT_ARRAYP(x)    _ASSERT(x, ARRAYP,    "Array")
#define ASSERT_BUILTINP(x)  _ASSERT(x, BUILTINP,  "Builtin")
#define ASSERT_SPECIALP(x)  _ASSERT(x, SPECIALP,  "Special form")
#define ASSERT_MACROP(x)    _ASSERT(x, MACROP,    "Macro")
#define ASSERT_FUNCTIONP(x)	_ASSERT(x, FUNCTIONP, "Function")
#endif

#endif /* #ifndef TRE_ASSERT_H */
