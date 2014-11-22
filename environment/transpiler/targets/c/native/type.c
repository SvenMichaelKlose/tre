/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#include "type.h"

const char *
tretype_name (unsigned x)
{
    const char * names[] = {
        "cons", "symbol", "number", "string", "array",
        "builtin", "special form", "macro", "function", "user-defined special"
    };

    if (x == TRETYPE_UNUSED)
        return "unused";
    if (x > TRETYPE_MAXTYPE)
        return "illegal";
    return names[x];
}
