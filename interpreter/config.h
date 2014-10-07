/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_TRE_H
#define TRE_TRE_H

#include "_revision.h"

typedef int bool;

#define KILO	1024
#define MEGA	(1024 * 1024)

#ifndef TRE_INFO
#define TRE_INFO    "tré " TRE_REVISION_STRING " - " __DATE__ ", " __TIME__ ")\n"
#endif

#if 0
#define TRE_GC_DEBUG		      /* Run garbage collector everywhere. */
#define TRE_VERBOSE_GC 		      /* Print statistics after GC. */
#define TRE_VERBOSE_EVAL	      /* Print what is evaluated. */
#define TRE_VERBOSE_READ          /* Print READ expressions in read-eval loop. */
#define TRE_PRINT_MACROEXPANSIONS /* Print macroexpansions in read-eval loop. */
#endif

#define INTERPRETER

#ifndef TRE_QUIET_LOAD
#define TRE_VERBOSE_LOAD	        /* Print what files are loaded. */
#endif

#define TRE_MAX_SYMLEN		        (4 * KILO)
#define TRE_MAX_STRINGLEN	        (64 * KILO)

#define TRE_MAX_NESTED_FILES	    16
#define TRE_FILEIO_MAX_FILES        16
#define TRE_DEFAULT_TABSIZE         8

#define MAX_PACKAGES		        128

#define TREDEBUG_MAX_ARGS	        16
#define TREDEBUG_MAX_BREAKPOINTS	16

#ifndef NUM_LISTNODES
#define NUM_LISTNODES	            (64 * MEGA)
#endif

#ifndef NUM_ATOMS
#define NUM_ATOMS	                (NUM_LISTNODES / 16)
#endif

#define TRESTACK_SIZE	            (512 * KILO)
#define TRESTACK_SIZE_SECONDARY     (TRESTACK_SIZE / 32)

#ifndef NULL
#define NULL    ((void *) 0)
#endif

#ifndef FALSE
#define FALSE	0
#endif

#ifndef TRUE
#define TRUE	-1
#endif

#ifndef TRE_ENVIRONMENT
#define TRE_ENVIRONMENT  "."
#endif

#ifndef TRE_BOOTFILE
#define TRE_BOOTFILE	"environment/main.lisp"
#endif

#ifndef TRE_IMAGE_HEADER
#define TRE_IMAGE_HEADER  "#!/usr/local/bin/tre -i\n" TRE_INFO
#endif

#define TREPTR_INDEX_WIDTH	(sizeof (treptr) * 8 - TRETYPE_WIDTH)

#ifdef TRE_LITTLE_ENDIAN
#define TRE_ENDIANESS_STRING	"LITTLE"
#endif

#ifdef TRE_BIG_ENDIAN
#define TRE_ENDIANESS_STRING	"BIG"
#endif

#ifdef TRE_VERBOSE_GC
#define TRE_VERBOSE_SYMBOL_GC
#endif

#ifdef TRE_HAVE_NO_BYTECODE_ASSERTIONS
#undef TRE_HAVE_BYTECODE_ASSERTIONS
#endif

#endif /* #ifndef TRE_TRE_H */
