;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defvar *c-builtins-descr*
	`(
	(treatom_
		(EQ             builtin_eq)
		(EQL            builtin_eql)
		(ATOM           builtin_atom)
		(%TYPE-ID       builtin_type_id)
		(%%ID           builtin_id)
		(SYMBOL?        builtin_symbolp)
		(FUNCTION?      builtin_functionp)
		(BUILTIN?       builtin_builtinp)
		(MACROP         builtin_macrop))

	(trearray_
    	(MAKE-ARRAY     builtin_make)
		(ARRAY?         builtin_p)
		(AREF           builtin_aref)
		(=-AREF         builtin_set_aref))

	(treerror_
		(%ERROR         builtin_error))

	(trefunction_
		(FUNCTION-NATIVE        native)
		(FUNCTION-BYTECODE      bytecode)
		(=-FUNCTION-BYTECODE    set_bytecode)
		(FUNCTION-SOURCE        source)
		(=-FUNCTION-SOURCE      set_source))

    (trebuiltin_
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

	(trenumber_
		(NUMBER+        builtin_plus)
		(NUMBER-        builtin_difference)
		(INTEGER+       builtin_plus)
		(INTEGER-       builtin_difference)
		(CHARACTER+     builtin_character_plus)
		(CHARACTER-     builtin_character_difference)
		(*              builtin_times)
		(/              builtin_quotient)
		(MOD            builtin_mod)
		(LOGXOR         builtin_logxor)
		(SQRT           builtin_sqrt)
		(SIN            builtin_sin)
		(COS            builtin_cos)
		(ATAN           builtin_atan)
		(ATAN2          builtin_atan2)
		(RANDOM         builtin_random)
		(EXP            builtin_exp)
		(POW            builtin_pow)
		(ROUND          builtin_round)
		(==             builtin_number_equal)
		(<              builtin_lessp)
		(>              builtin_greaterp)
		(NUMBER==       builtin_number_equal)
		(NUMBER<        builtin_lessp)
		(NUMBER>        builtin_greaterp)
		(INTEGER==      builtin_number_equal)
		(INTEGER<       builtin_lessp)
		(INTEGER>       builtin_greaterp)
		(CHARACTER==    builtin_number_equal)
		(CHARACTER<     builtin_lessp)
		(CHARACTER>     builtin_greaterp)

		(NUMBER?        builtin_numberp)
		(BIT-OR         builtin_bit_or)
		(BIT-AND        builtin_bit_and)
		(<<             builtin_bit_shift_left)
		(>>             builtin_bit_shift_right)
		(CODE-CHAR      builtin_code_char)
		(INTEGER        builtin_integer)
		(FLOAT          builtin_float)
		(CHARACTER?     builtin_characterp))

	(tresymbol_
		(MAKE-SYMBOL        builtin_make_symbol)
		(MAKE-PACKAGE       builtin_make_package)
		(SYMBOL-VALUE       builtin_symbol_value)
		(=-SYMBOL-VALUE     set_value)
		(SYMBOL-FUNCTION    builtin_symbol_function)
		(=-SYMBOL-FUNCTION  builtin_usetf_symbol_function)
		(SYMBOL-PACKAGE     builtin_symbol_package))

	(trelist_
		(CONS               get)
		(LIST               builtin_list)
    	(CAR)
		(CDR)
		(CPR)
		(RPLACA)
		(RPLACD)
		(RPLACP)
   	    (CONS?              builtin_consp))

	(tresequence_
    	(ELT                builtin_elt)
		(%SET-ELT           builtin_set_elt)
		(LENGTH             builtin_length))

	(trestring_
		(STRING?            builtin_stringp)
    	(MAKE-STRING        builtin_make)
		(STRING==           builtin_compare)
		(STRING-CONCAT      builtin_concat)
		(STRING             builtin_string)
		(SYMBOL-NAME        builtin_symbol_name)
		(LIST-STRING        builtin_list_string))

	(tremacro_
    	(MACROEXPAND-1      builtin_macroexpand_1)
		(MACROEXPAND        builtin_macroexpand))

	(trestream_
    	(%PRINC             builtin_princ)
		(%FORCE-OUTPUT      builtin_force_output)
		(%READ-CHAR         builtin_read_char)
    	(%FOPEN             builtin_fopen)
		(%FEOF              builtin_feof)
		(%FCLOSE            builtin_fclose)
		(%TERMINAL-RAW      builtin_terminal_raw)
		(%TERMINAL-NORMAL   builtin_terminal_normal))

	(tredebug_
		(END-DEBUG          builtin_end_debug)
		(INVOKE-DEBUGGER    builtin_invoke_debugger))

	(trealien_
    	(ALIEN-DLOPEN       builtin_dlopen)
		(ALIEN-DLCLOSE      builtin_dlclose)
		(ALIEN-DLSYM        builtin_dlsym)
    	(ALIEN-CALL         builtin_call))

	(treimage_
    	(SYS-IMAGE-CREATE   builtin_create)
		(SYS-IMAGE-LOAD     builtin_load))

	(tretime_
		(NANOTIME           builtin_nanotime))

	(trenet_
        (OPEN-SOCKET        builtin_open_socket)
        (ACCEPT             builtin_accept)
        (RECV               builtin_recv)
        (SEND               builtin_send)
        (CLOSE-CONNECTION   builtin_close_connection)
        (CLOSE-SOCKET       builtin_close_socket))))

;; Build hash table for name conversion.
(defvar *c-builtins*
  (let h (make-hash-table)
	(dolist (grp *c-builtins-descr* h)
	  (let head (string-downcase (symbol-name grp.))
		(dolist (f .grp)
          (& (href h f.)
             (error "Built-in function ~A is defined more than once." f.))
		  (= (href h f.) (+ head (string-downcase (symbol-name (| .f. f.))))))))))

(defun c-builtin-names ()
  (hashkeys *c-builtins*))

(defun c-builtin-name (x)
  (href *c-builtins* x))
