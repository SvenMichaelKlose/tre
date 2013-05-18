;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defvar *c-builtins-descr*
	`((trebuiltin_
		(QUIT)
		(LOAD)
		(EVAL)
		(APPLY)
		(PRINT)
		(GC)
		(DEBUG)
		(INTERN)
		(%MALLOC        malloc)
		(%MALLOC-EXEC   malloc_exec)
		(%FREE free)
		(%FREE-EXEC     free_exec)
		(%%SET set)
		(%%GET get))

	(treerror_builtin_
		(%ERROR error))

	(trenumber_builtin_
		(NUMBER+        plus)
		(NUMBER-        difference)
		(INTEGER+       plus)
		(INTEGER-       difference)
		(CHARACTER+     character_plus)
		(CHARACTER-     character_difference)
		(* times)
		(/ quotient)
		(MOD)
		(LOGXOR)
		(SQRT)
		(SIN)
		(COS)
		(ATAN)
		(ATAN2)
		(RANDOM)
		(EXP)
		(POW)
		(ROUND)
;		(NUMBER?         numberp)
		(==             number_equal)
		(<              lessp)
		(>              greaterp)
		(NUMBER==       number_equal)
		(NUMBER<        lessp)
		(NUMBER>        greaterp)
		(INTEGER==      number_equal)
		(INTEGER<       lessp)
		(INTEGER>       greaterp)
		(CHARACTER==    number_equal)
		(CHARACTER<     lessp)
		(CHARACTER>     greaterp)
		(BIT-OR         bit_or)
		(BIT-AND        bit_and)
		(<<             bit_shift_left)
		(>>             bit_shift_right)
		(CODE-CHAR      code_char)
		(INTEGER)
		(FLOAT)
		(CHARACTER?     characterp))

	(treatom_builtin_
;		(EQ)
		(EQL)
;		(ATOM)
		(%TYPE-ID   type_id)
		(%%ID id)
;		(SYMBOL?    symbolp)
;		(FUNCTION?  functionp)
;		(BUILTIN?   builtinp)
		(MACROP)
		(%ATOM-LIST atom_list))

	(tresymbol_builtin_
		(MAKE-SYMBOL        make_symbol)
		(MAKE-PACKAGE       make_package)
		(SYMBOL-VALUE       symbol_value)
		(=-SYMBOL-VALUE     usetf_symbol_value)
		(SYMBOL-FUNCTION    symbol_function)
		(=-SYMBOL-FUNCTION  usetf_symbol_function)
		(SYMBOL-PACKAGE     symbol_package))

	(trefunction_builtin_
		(FUNCTION-NATIVE        function_native)
		(FUNCTION-BYTECODE      function_bytecode)
		(=-FUNCTION-BYTECODE    usetf_function_bytecode)
		(FUNCTION-SOURCE        function_source))

	(trelist_builtin_
		;(CONS)
		(LIST)
;    	(CAR)
;		(CDR)
		(CPR)
		(RPLACA)
		(RPLACD)
		(RPLACP)
;   	    (CONS? consp))
)

	(tresequence_builtin_
    	(ELT)
		(%SET-ELT set_elt)
		(LENGTH))

	(trestring_builtin_
;		(STRING?            stringp)
    	(MAKE-STRING        make)
		(STRING==           compare)
		(STRING-CONCAT      concat)
		(STRING)
		(SYMBOL-NAME        symbol_name)
		(LIST-STRING        list_string))

	(trearray_builtin_
    	(MAKE-ARRAY         make)
;		(ARRAY?             p)
		(%AREF              aref)
		(=-%AREF            set_aref))

	(tremacro_builtin_
    	(MACROEXPAND-1      macroexpand_1)
		(MACROEXPAND))

	(trestream_builtin_
    	(%PRINC princ)
		(%FORCE-OUTPUT      force_output)
		(%READ-CHAR         read_char)
    	(%FOPEN             fopen)
		(%FEOF              feof)
		(%FCLOSE            fclose)
		(%TERMINAL-RAW      terminal_raw)
		(%TERMINAL-NORMAL   terminal_normal))

	(tredebug_builtin_
		(END-DEBUG          end_debug)
		(INVOKE-DEBUGGER    invoke_debugger))

	(trealien_builtin_
    	(ALIEN-DLOPEN       dlopen)
		(ALIEN-DLCLOSE      dlclose)
		(ALIEN-DLSYM        dlsym)
    	(ALIEN-CALL         call))

	(treimage_builtin_
    	(SYS-IMAGE-CREATE   create)
		(SYS-IMAGE-LOAD     load))

	(tretime_builtin_
		(NANOTIME))

	(trenet_builtin_
        (OPEN-SOCKET        open_socket)
        (ACCEPT accept)
        (RECV recv)
        (SEND send)
        (CLOSE-CONNECTION   close_connection)
        (CLOSE-SOCKET       close_socket))))

;; Build hash table for name conversion.
(defvar *c-builtins*
  (let h (make-hash-table)
	(dolist (grp *c-builtins-descr* h)
	  (let head (string-downcase (symbol-name grp.))
		(dolist (f .grp)
		  (= (href h f.)
		     (+ (? (starts-with? (symbol-name .f.) "=-") "" head)
                (string-downcase (symbol-name (| .f. f.))))))))))

(defun c-builtin-names ()
  (hashkeys *c-builtins*))

(defun c-builtin-name (x)
  (href *c-builtins* x))
