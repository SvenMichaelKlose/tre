/*
 * tré – Copyright (c) 2005–2007,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_DEBUG_H
#define TRE_DEBUG_H

#define _TREDEBUG_CHK(x,y) \
    if (tredebug_mode & x) tredebug (y)

#define TREDEBUGM_STEP		1
#define TREDEBUG_STEP(y) 	_TREDEBUG_CHK(TREDEBUGM_STEP, y)

extern int tredebug_mode;
extern treptr tredebug_next;

extern treptr treptr_milestone; /* Helps debugging across tré and C. */

extern treptr tredebug_get_parent (void);

extern treptr tredebug (void);
extern void   tredebug_init (void);
extern void   tredebug_init_late (void);
extern void   tredebug_chk_breakpoints (treptr);
extern bool   tredebug_set_breakpoint (char *);
extern bool   tredebug_remove_breakpoint (char *);
extern void   tredebug_chk_next (void);

extern void   tredebug_cnt (void);

extern treptr treptr_index (treptr);
extern treptr treptr_type (treptr);

#endif	/* #ifndef TRE_DEBUG_H */

#endif /* #ifdef INTERPRETER */
