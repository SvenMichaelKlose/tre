/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#include "ptr.h"

treptr
treptr_type (treptr x)
{
    return TREPTR_TYPE(x);
}

const char *
treptr_typename (treptr x)
{
    return tretype_name (TREPTR_TYPE(x));
}
    
treptr
treptr_index (treptr x)
{
    return TREPTR_INDEX(x);
}
