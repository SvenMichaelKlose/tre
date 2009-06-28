/*
 * TRE interpreter
 * Copyright (c) 2005-2006,2009 Sven Klose <pixel@copei.de>
 *
 * Expression printing.
 */

#ifndef TRE_PRINT_H
#define TRE_PRINT_H

extern treptr treprint_highlight;

extern treptr treprint (treptr);

extern treptr treprint_builtin_princ (treptr);

#endif /* #ifndef TRE_PRINT_H */
