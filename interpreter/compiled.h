/*
 * TRE interpreter
 * Copyright (c) 2009 Sven Klose <pixel@copei.de>
 *
 * Macro for generated code
 */

#ifndef TRE_COMPILED_H
#define TRE_COMPILED_H

#define _TREVEC(vec, index) \
	((treptr *) TREATOM_DETAIL(vec)) [(unsigned long) index]

#define _TRELOCAL(index) \
	((treptr *) _locals) [(unsigned long) index]

#endif /* #ifndef TRE_COMPILED_H */
