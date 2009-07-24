/*
 * TRE interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 *
 * Compile-time configuration.
 */

#ifndef TRE_TRE_H
#define TRE_TRE_H

typedef int bool;

#define KILO	1024
#define MEGA	(1024 * 1024)

#ifndef TRE_INFO
#define TRE_INFO \
	"TRE tree processor " TRE_VERSION " (" __DATE__ " " __TIME__ ")\n"
#endif

#ifndef TRE_COPYRIGHT
#define TRE_COPYRIGHT \
	"Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>\n"
#endif

#define TRE_VERSION	"current"

#if 0
#define TRE_DIAGNOSTICS		/* Do diagnostic checks. */
#define TRE_GC_DEBUG		/* Run garbage collector everywhere. */
#define TRE_VERBOSE_GC 		/* Print statistics after GC. Implies TRE_VERBOSE_SYMBOL_GC. */
#define TRE_VERBOSE_SYMBOL_GC 	/* Print statistics after GC. */
#define TRE_VERBOSE_EVAL	/* Print what is evaluated. */
#define TRE_VERBOSE_READ    /* Print READ expressions in read-eval loop. */
#define TRE_PRINT_MACROEXPANSIONS /* Print macroexpansions in read-eval loop. */
#define TRE_READ_ECHO		/* Echo what is READ. */
#define TRE_NO_MANUAL_FREE	/* Don't free internal garbage manually. */
#define TRE_EXIT_ON_STDIO_SIGINT /* Exit on SIGINT in stdio prompt. */
#endif

#define TRE_NO_BUILTIN_SEARCH

#ifndef TRE_QUIET_LOAD
#define TRE_VERBOSE_LOAD	/* Print what files are loaded. */
#endif

#define TRE_MAX_SYMLEN		(4 * KILO)
#define TRE_MAX_STRINGLEN	(4 * KILO)

#define TRE_MAX_NESTED_FILES	16
#define TRE_FILEIO_MAX_FILES   16

#define MAX_PACKAGES		2

#define TREDEBUG_MAX_ARGS	16
#define TREDEBUG_MAX_BREAKPOINTS	16

#ifndef NUM_LISTNODES
#define NUM_LISTNODES	(16 * MEGA)
#endif

#ifndef NUM_ATOMS
#define NUM_ATOMS	(NUM_LISTNODES / 4)
#endif

#ifndef NUM_NUMBERS
#define NUM_NUMBERS	NUM_ATOMS /* FIXME: bus error if less than atoms */
#endif

#ifndef NULL
#define NULL	((void *) 0)
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

#ifndef TRE_BOOT_IMAGE
#define TRE_BOOT_IMAGE	"~/.tre.image"
#endif

#ifndef TRE_IMAGE_HEADER
#define TRE_IMAGE_HEADER  "#!/usr/local/bin/tre -i\n" TRE_INFO
#endif

#define TREPTR_INDEX_WIDTH	(sizeof (treptr) * 8 - TRETYPE_WIDTH)

#ifdef LITTLE_ENDIAN
#define TRE_ENDIANESS_STRING	"LITTLE"
#endif

#ifdef BIG_ENDIAN
#define TRE_ENDIANESS_STRING	"BIG"
#endif

#ifdef TRE_VERBOSE_GC
#define TRE_VERBOSE_SYMBOL_GC
#endif

#ifndef TRE_NO_BUILTIN_SEARCH
#define TRE_BUILTIN_ASSOC
#define TRE_BUILTIN_MEMBER
#endif

#ifdef TRE_DIAGNOSTICS
#ifndef TRE_LIST_DIAGNOSTICS
#define TRE_LIST_DIAGNOSTICS
#endif
#endif

#endif /* #ifndef TRE_TRE_H */
