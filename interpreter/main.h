/*
 * tré – Copyright (c) 2005–2010.2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_MAIN_H
#define TRE_MAIN_H

extern treptr * trestack;
extern treptr * trestack_top;
extern treptr * trestack_ptr;

extern treptr * trestack_secondary;
extern treptr * trestack_top_secondary;
extern treptr * trestack_ptr_secondary;

extern treptr eval_toplevel_current;
extern bool   tre_is_initialized;
extern bool   tre_interrupt_debugger;

extern void   tre_exit      (int);
extern void   tre_restart   (treptr);

extern treptr tremain_line  (trestream *);
extern void   tremain       (void);

extern void   tremain_init_after_image_loaded (void);

#endif /* #ifndef TRE_MAIN_H */
