/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Compile-time configuration.
 */

#ifndef LISP_LISP_H
#define LISP_LISP_H

typedef int bool;

#ifndef LISP_COPYRIGHT
#define LISP_COPYRIGHT \
	"nix list processor " LISP_VERSION " (" __DATE__ " " __TIME__ ")\n"
#endif

#define LISP_VERSION	"current"

#if 0
#define LISP_DIAGNOSTICS	/* Do diagnostic checks. */
#define LISP_GC_DEBUG		/* Run garbage collector everywhere. */
#define LISP_VERBOSE_GC 	/* Print statistics after GC. */
#define LISP_VERBOSE_LOAD	/* Print what files are loaded. */
#define LISP_VERBOSE_EVAL	/* Print what is evaluated. */
#define LISP_VERBOSE_READ       /* Print READ expressions in read-eval loop. */ */
#define LISP_PRINT_MACROEXPANSIONS ; Print macroexpansions in read-eval loop. */ */
#define LISP_READ_ECHO		/* Echo what is READ. */
#define LISP_NO_MANUAL_FREE	/* Don't free internal garbage manually. */
#endif

#define LISP_MAX_SYMLEN		64
#define LISP_MAX_STRINGLEN	1024
#define LISP_SYMBOL_TABLE_SIZE	65536
#define LISP_MAX_NESTED_FILES	16
#define LISP_FILEIO_MAX_FILES   16

#define LISPDEBUG_NAMESTACKSIZE	25600
#define LISPDEBUG_MAX_ARGS	16
#define LISPDEBUG_MAX_BREAKPOINTS	16

#ifndef NUM_NUMBERS
#define NUM_NUMBERS	(64 * 1024)
#endif

#ifndef NUM_ATOMS
#define NUM_ATOMS	(128 * 1024)
#endif

#ifndef NUM_LISTNODES
#define NUM_LISTNODES	(1024 * 1024)
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

#ifndef LISP_ENVIRONMENT
#define LISP_ENVIRONMENT  "."
#endif

#ifndef LISP_BOOTFILE
#define LISP_BOOTFILE	"environment/main.lisp"
#endif

#ifndef LISP_BOOT_IMAGE
#define LISP_BOOT_IMAGE	"~/.nix-lisp.image"
#endif

#ifndef LISP_IMAGE_HEADER
#define LISP_IMAGE_HEADER  "#!lisp -i\n" LISP_COPYRIGHT
#endif

#define LISPPTR_TYPESHIFT	27

#endif /* #ifndef LISP_LISP_H */
