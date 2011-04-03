;;;;; TRE to C transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Built-in interpreter functions

(defvar *c-builtins-descr*
	'((trebuiltin_
;		(IDENTITY)
		(QUIT)
		(LOAD)
		(EVAL)
		(%MACROCALL macrocall)
		(PRINT)
		(GC)
		(DEBUG)
		(INTERN)
		(%MALLOC malloc)
		(%MALLOC-EXEC malloc_exec)
		(%FREE free)
		(%FREE-EXEC free_exec)
		(%%SET set)
		(%%GET get))

	(trespecial_
		(APPLY apply_compiled))

	(treerror_builtin_
		(%ERROR error))

	(trenumber_builtin_
		(NUMBER+ plus)
		(NUMBER- difference)
		(INTEGER+ plus)
		(INTEGER- difference)
		(CHARACTER+ character_plus)
		(CHARACTER- character_difference)
		(* times)
		(/ quotient)
		(MOD)
		(LOGXOR)
;		(NUMBER?)
		(= number_equal)
		(< lessp)
		(> greaterp)
		(NUMBER= number_equal)
		(NUMBER< lessp)
		(NUMBER> greaterp)
		(INTEGER= number_equal)
		(INTEGER< lessp)
		(INTEGER> greaterp)
		(CHARACTER= number_equal)
		(CHARACTER< lessp)
		(CHARACTER> greaterp)
		(BIT-OR bit_or)
		(BIT-AND bit_and)
		(<< bit_shift_left)
		(>> bit_shift_right)
		(CODE-CHAR code_char)
		(INTEGER)
		(CHARACTER? characterp))

	(treatom_builtin_
;		(EQ)
		(EQL)
		(MAKE-SYMBOL make_symbol)
		(MAKE-PACKAGE make_package)
;		(ATOM)
		(SYMBOL-VALUE)
		(%TYPE-ID type_id)
		(%%ID id)
		(SYMBOL-VALUE symbol_value)
		(SYMBOL-FUNCTION symbol_function)
		(SYMBOL-PACKAGE symbol_package)
;		(FUNCTIONP)
;		(BUILTINP)
		(BOUNDP)
		(FBOUNDP)
		(MACROP)
		(%ATOM-LIST atom_list))

	(trelist_builtin_
		;(CONS)
		(LIST)
;    	(CAR)
;		(CDR)
		(RPLACA)
		(RPLACD)
;    	(CONS?)
		(ASSOC)
		(MEMBER))

	(tresequence_builtin_
    	(ELT)
		(%SET-ELT set_elt)
		(LENGTH))

	(trestring_builtin_
;		(STRINGP)
    	(MAKE-STRING make)
		(STRING= compare)
		(STRING-CONCAT concat)
		(STRING)
		(SYMBOL-NAME symbol_name)
		(LIST-STRING list_string))

	(trearray_builtin_
    	(MAKE-ARRAY make))
;		(ARRAY? p))
;		(AREF)
;		(%SET-AREF set_aref))

	(tremacro_builtin_
    	(MACROEXPAND-1 macroexpand_1)
		(MACROEXPAND))

	(trestream_builtin_
    	(%PRINC princ)
		(%FORCE-OUTPUT force_output)
		(%READ-CHAR read_char)
    	(%FOPEN fopen)
		(%FEOF feof)
		(%FCLOSE fclose)
		(%TERMINAL-RAW terminal_raw)
		(%TERMINAL-NORMAL terminal_normal))

	(tredebug_builtin_
		(END-DEBUG end_debug)
		(INVOKE-DEBUGGER invoke_debugger))

	(trealien_builtin_
    	(ALIEN-DLOPEN dlopen)
		(ALIEN-DLCLOSE dlclose)
		(ALIEN-DLSYM dlsym)
    	(ALIEN-CALL call))

	(treimage_builtin_
    	(SYS-IMAGE-CREATE create)
		(SYS-IMAGE-LOAD load))))

;; Build hash table for name conversion.
(defvar *c-builtins*
  (let h (make-hash-table)
	(dolist (grp *c-builtins-descr* h)
	  (let head (string-downcase (symbol-name grp.))
		(dolist (f .grp)
		  (setf (href h f.)
				(+ head (aif .f
				     (string-downcase (symbol-name !.))
					 (string-downcase (symbol-name f.))))))))))

(defun c-builtin-name (x)
  (href *c-builtins* x))

;; Make transpiler standard macros that convert arguments to built-in functions
;; to consed lists.
,`(progn
	,@(macroexpand (mapcar (fn `(define-c-std-macro ,_ (&rest x)
					 			  `(,(make-symbol (c-builtin-name _))
						 			    ,,(compiled-list x))))
			  			   (hashkeys *c-builtins*))))
