### COMPILE-TIME OPTIONS ####################################################

    Compile-time options are useful for debugging, or if the size of the
    application is to be reduced.

    TRE_BOOTFILE
        Path to environment toplevel file, relative to TRE_ENVIRONMENT.

    TRE_BOOT_IMAGE
        Path to cached environment dump which is loaded instead of
        TRE_BOOT_IMAGE (if exists).

    TRE_BOOT_IMAGE_HEADER
        String to prefix images with. Used to for hash bang and informative
        messages.

    TRE_DIAGNOSTICS
       Do diagnostic checks.

    TRE_GC_DEBUG          
	Run garbage collector everywhere.

    TRE_ENVIRONMENT
        Path to environment directory.

    TRE_NO_MANUAL_FREE    
	Don't free internal garbage manually, leave it for mark-and-sweep
	removal.

    TRE_PRINT_MACROEXPANSIONS
	Print macroexpansions in read-eval loop.

    TRE_READ_ECHO         
	Echo what is READ in the read-eval loop.

    TRE_VERBOSE_GC        
	Print statistics after GC.

    TRE_VERBOSE_SYMBOL_GC        
	Print ' *SYMBOL-GC* ' before symbol GC.

    TRE_VERBOSE_LOAD      
	Print what files are loaded.

    TRE_VERBOSE_EVAL      
	Print what is evaluated if global variable *VERBOSE-EVAL* is T.

    TRE_VERBOSE_READ      
	Print READ expressions in read-eval loop.

### TERMINOLOGY ############################################################

    expression, S-expression ("symbolic expression")
	A textual representation of an object.

    non-atomic S-expression ("dotted-pair")
	A binary tree of conses whose leaf nodes are atoms.

    pure list
	An S-expression where every element x

	    (AND (NOT (CONSP (CAR x)))
	         (LISTP (CDR x)))
	    => T
