/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Error handling.
 */

#ifndef LISP_DEBUG_H
#define LISP_DEBUG_H

#define _LISPDEBUG_CHK(x,y) \
    if (lispdebug_mode & x) lispdebug (y)

#define LISPDEBUGM_STEP		1

extern int lispdebug_mode;
extern lispptr lispdebug_next;

extern lispptr lispdebug_tmp;

#define LISPDEBUG_STEP(y) 	_LISPDEBUG_CHK(LISPDEBUGM_STEP, y)

extern lispptr lispdebug_get_parent (void);

extern lispptr lispdebug (void);
extern void lispdebug_init (void);
extern void lispdebug_chk_breakpoints (lispptr);
extern bool lispdebug_set_breakpoint (char *);
extern bool lispdebug_remove_breakpoint (char *);
extern void lispdebug_chk_next (void);

extern void lispdebug_cnt (void);

#endif	/* #ifndef LISP_DEBUG_H */
