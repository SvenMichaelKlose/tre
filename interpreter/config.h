/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Compile-time configuration.
 */

#ifndef TRE_TRE_H
#define TRE_TRE_H

typedef int bool;

#ifndef TRE_COPYRIGHT
#define TRE_COPYRIGHT \
	"nix list processor " TRE_VERSION " (" __DATE__ " " __TIME__ ")\n"
#endif

#define TRE_VERSION	"current"

#if 0
#define TRE_DIAGNOSTICS	/* Do diagnostic checks. */
#define TRE_GC_DEBUG		/* Run garbage collector everywhere. */
#define TRE_VERBOSE_GC 	/* Print statistics after GC. */
#define TRE_VERBOSE_LOAD	/* Print what files are loaded. */
#define TRE_VERBOSE_EVAL	/* Print what is evaluated. */
#define TRE_VERBOSE_READ       /* Print READ expressions in read-eval loop. */ */
#define TRE_PRINT_MACROEXPANSIONS ; Print macroexpansions in read-eval loop. */ */
#define TRE_READ_ECHO		/* Echo what is READ. */
#define TRE_NO_MANUAL_FREE	/* Don't free internal garbage manually. */
#define TRE_EXIT_ON_STDIO_SIGINT /* Exit on SIGINT in stdio prompt. */
#endif

#define TRE_MAX_SYMLEN		64
#define TRE_MAX_STRINGLEN	8192
#define TRE_SYMBOL_TABLE_SIZE	(16 * 1024)
#define TRE_MAX_NESTED_FILES	16
#define TRE_FILEIO_MAX_FILES   16

#define TREDEBUG_NAMESTACKSIZE	25600
#define TREDEBUG_MAX_ARGS	16
#define TREDEBUG_MAX_BREAKPOINTS	16

#ifndef NUM_NUMBERS
#define NUM_NUMBERS	(8 * 1024)
#endif

#ifndef NUM_ATOMS
#define NUM_ATOMS	(8 * 1024)
#endif

#ifndef NUM_LISTNODES
#define NUM_LISTNODES	(128 * 1024)
#endif

#define NUM_LISTNODES_TOTAL	(NUM_LISTNODES + NUM_ATOMS + NUM_NUMBERS)

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
#define TRE_BOOT_IMAGE	"~/.nix-tre.image"
#endif

#ifndef TRE_IMAGE_HEADER
#define TRE_IMAGE_HEADER  "#!tre -i\n" TRE_COPYRIGHT
#endif

#define TREPTR_TYPESHIFT	27

#endif /* #ifndef TRE_TRE_H */
