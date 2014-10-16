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
symbol_alloc (char * name, treptr package, treptr value)
{
    treptr  atom = treatom_alloc (TRETYPE_SYMBOL);

    if (value == treptr_invalid)
		value = atom;

	TREATOM(atom) = symtab_add (atom, name, value, treptr_nil, package);

	return atom;
}

treptr
symbol_get (char * symbol, treptr package)
{   
    treptr  atom;
	double  dvalue;

    atom = symtab_find (symbol, package);
    if (atom != treptr_invalid)
		return atom;

    if (trenumber_is_value (symbol)) {
		if (sscanf (symbol, "%lf", &dvalue) != 1)
			treerror (treptr_nil, "Illegal number format %s.", symbol);
        return treatom_number_get (dvalue, TRENUMTYPE_FLOAT);
	}

    return symbol_alloc (symbol, package, treptr_invalid);
}

void
tresymbol_init (void)
{
    tre_package_keyword = symbol_alloc ("", treptr_nil, treptr_nil);
	symtab_set_package (TREPACKAGE_KEYWORD_INDEX, tre_package_keyword);

    treptr_universe = symbol_alloc ("*UNIVERSE*", treptr_nil, treptr_nil);
    EXPAND_UNIVERSE(treptr_t);

    EXPAND_UNIVERSE(tre_package_keyword);

	MAKE_SYMBOL("*KEYWORD-PACKAGE*", tre_package_keyword);
    tre_default_listprop = symbol_alloc ("*DEFAULT-LISTPROP*", treptr_nil, treptr_nil);
    EXPAND_UNIVERSE(tre_default_listprop);
}
