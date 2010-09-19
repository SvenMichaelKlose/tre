/*
 * TRE interpreter
 * Copyright (c) 2007 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_IMAGE_H
#define TRE_IMAGE_H

extern treptr treimage_initfun;

extern void treimage_init (void);
extern int treimage_create (char *, treptr init_fun);
extern int treimage_load (char *);

#endif	/* #ifndef TRE_IMAGE_H */
