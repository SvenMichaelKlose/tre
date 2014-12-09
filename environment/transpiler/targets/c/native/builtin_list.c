/*
 * tré – Copyright (c) 2005–2010,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "error.h"
#include "number.h"
#include "builtin.h"
#include "builtin_list.h"
#include "xxx.h"
#include "gc.h"
#include "thread.h"
#include "function.h"
#include "symbol.h"
#include "assert.h"

#include "builtin_atom.h"

treptr
list_consp (treptr x)
{
    if (ATOMP(x))
        return NIL;
    return treptr_t;
}
