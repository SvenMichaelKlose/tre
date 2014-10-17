/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>

#include "atom.h"
#include "symtab.h"
#include "symbol.h"
#include "cons.h"
#include "thread.h"
#include "number.h"
#include "error.h"

#define TREPACKAGE_KEYWORD_INDEX    1

treptr
symbol_alloc_packaged (char * name, treptr package, treptr value)
{
    treptr  atom = treatom_alloc (TRETYPE_SYMBOL);

    if (value == treptr_invalid)
		value = atom;

	ATOM(atom) = symtab_add (atom, name, value, treptr_nil, package);

	return atom;
}

treptr
symbol_alloc (char * name, treptr value)
{
    return symbol_alloc_packaged (name, TRECONTEXT_PACKAGE(), value);
}

treptr
symbol_get_packaged (char * name, treptr package)
{   
    treptr  atom;

    atom = symtab_find (name, package);
    if (atom == treptr_invalid)
        return symbol_alloc_packaged (name, package, treptr_invalid);
    return atom;
}


treptr
symbol_get (char * name)
{   
    return symbol_get_packaged (name, TRECONTEXT_PACKAGE());
}

void
tresymbol_init (void)
{
    tre_package_keyword = symbol_alloc_packaged ("", treptr_nil, treptr_nil);
	symtab_set_package (TREPACKAGE_KEYWORD_INDEX, tre_package_keyword);

    treptr_universe = symbol_alloc_packaged ("*UNIVERSE*", treptr_nil, treptr_nil);
    EXPAND_UNIVERSE(treptr_t);

    EXPAND_UNIVERSE(tre_package_keyword);

	MAKE_SYMBOL("*KEYWORD-PACKAGE*", tre_package_keyword);
    tre_default_listprop = symbol_alloc_packaged ("*DEFAULT-LISTPROP*", treptr_nil, treptr_nil);
    EXPAND_UNIVERSE(tre_default_listprop);
}
