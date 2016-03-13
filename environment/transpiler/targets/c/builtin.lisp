; tré – Copyright (c) 2009–2016 Sven Michael Klose <pixel@hugbox.org>

(defvar *c-builtins-descr*
	`(
	(atom_
		(EQ             builtin_eq      &rest x)
		(EQL            builtin_eql     &rest x)
		(ATOM           builtin_atom    &rest x)
		(%TYPE-ID       type_id         x)
		(%%ID           id              x)
		(SYMBOL?        symbolp         x)
		(FUNCTION?      functionp       x)
		(BUILTIN?       builtinp        x)
		(MACRO?         macrop          x))

	(trearray_
    	(MAKE-ARRAY     builtin_make    &rest keys)
		(ARRAY?         p               x)
		(AREF           nil             arr &rest keys)
		(=-AREF         set_aref        value arr &rest keys))

	(treerror_
		(%ERROR         builtin_error     &rest x)
		(%STRERROR      builtin_strerror  &rest x))

	(trefunction_
		(FUNCTION-NATIVE        native          fun)
		(FUNCTION-BYTECODE      bytecode        fun)
		(=-FUNCTION-BYTECODE    set_bytecode    bytecode fun)
		(FUNCTION-SOURCE        source          fun)
		(=-FUNCTION-SOURCE      set_source      source-expr fun)
		(MAKE-FUNCTION          make_function   &optional (source-expr nil)))

    (trebuiltin_
		(QUIT           nil         &rest x)
		(LOAD           nil         &rest x)
		(EVAL           nil         &rest x)
		(APPLY          nil         &rest x)
		(PRINT          nil         &rest x)
		(GC             nil         &rest x)
		(DEBUG          nil         &rest x)
		(%MALLOC        malloc      &rest x)
		(%MALLOC-EXEC   malloc_exec &rest x)
		(%FREE          free        &rest x)
		(%FREE-EXEC     free_exec   &rest x)
		(%%SET          set         &rest x)
		(%%GET          get         &rest x))

	(trenumber_
		(%+             plus                    a b)
		(%-             difference              a b)
		(NUMBER+        builtin_plus            &rest x)
		(NUMBER-        builtin_difference      &rest x)
		(INTEGER+       builtin_plus            &rest x)
		(INTEGER-       builtin_difference      &rest x)
		(*              builtin_times           &rest x)
		(/              builtin_quotient        &rest x)
		(MOD            builtin_mod             &rest x)
		(SQRT           builtin_sqrt            &rest x)
		(SIN            builtin_sin             &rest x)
		(COS            builtin_cos             &rest x)
		(ATAN           builtin_atan            &rest x)
		(ATAN2          builtin_atan2           &rest x)
		(RANDOM         builtin_random          &rest x)
		(EXP            builtin_exp             &rest x)
		(POW            builtin_pow             &rest x)
		(ROUND          builtin_round           &rest x)
		(FLOOR          builtin_floor           &rest x)
		(==             equal                   a b)
		(<              lessp                   a b)
		(>              greaterp                a b)
		(NUMBER==       equal                   a b)
		(NUMBER<        lessp                   a b)
		(NUMBER>        greaterp                a b)
		(INTEGER==      equal                   a b)
		(INTEGER<       lessp                   a b)
		(INTEGER>       greaterp                a b)
		(CHARACTER==    equal                   a b)
		(CHARACTER<     lessp                   a b)
		(CHARACTER>     greaterp                a b)

		(NUMBER?        numberp                 x)
		(BIT-OR         builtin_bit_or          &rest x)
		(BIT-AND        builtin_bit_and         &rest x)
		(BIT-XOR        builtin_bit_xor         &rest x)
		(<<             builtin_bit_shift_left  &rest x)
		(>>             builtin_bit_shift_right &rest x)
		(CODE-CHAR      code_char               x)
		(INTEGER        builtin_integer         &rest x)
		(FLOAT          builtin_float           &rest x)
		(CHARACTER?     characterp              x))

	(tresymbol_
		(MAKE-SYMBOL        builtin_make_symbol     &rest x)
		(MAKE-PACKAGE       builtin_make_package    &rest x)
		(SYMBOL-VALUE       value                   x)
		(=-SYMBOL-VALUE     set_value               v x)
		(SYMBOL-FUNCTION    function                x)
		(=-SYMBOL-FUNCTION  set_function            fun x)
		(SYMBOL-PACKAGE     builtin_symbol_package  &rest x))

	(list_
		(CONS               (cons)       a b)
    	(CAR                (car)        x)
		(CDR                (cdr)        x)
		(CPR                (cpr)        x)
		(RPLACA             (rplaca)     x v)
		(RPLACD             (rplacd)     x v)
		(RPLACP             (rplacp)     x v)
   	    (CONS?              consp        x)
   	    (LAST               (last)       x)
   	    (COPY-LIST          (list_copy)  x)
   	    (NTHCDR             (trelist_nthcdr)  i x)
   	    (NTH                (trelist_nth)     i x)
   	    (FILTER             (filter)     fun x)
   	    (MAPCAR             (mapcar)     fun &rest x))

	(tresequence_
    	(ELT                builtin_elt     &rest x)
		(%SET-ELT           builtin_set_elt &rest x)
		(LENGTH             builtin_length  &rest x))

	(trestring_
		(STRING?            p                   x)
    	(MAKE-STRING        builtin_make        &rest x)
		(STRING==           builtin_compare     &rest x)
		(STRING-CONCAT      builtin_concat      &rest x)
		(STRING             builtin_string      &rest x)
		(SYMBOL-NAME        symbol_name         x)
		(LIST-STRING        builtin_list_string &rest x))

	(tremacro_
    	(MACROEXPAND-1      builtin_macroexpand_1   &rest x)
		(MACROEXPAND        builtin_macroexpand     &rest x))

	(trestream_
    	(%PRINC             builtin_princ           &rest x)
		(%FORCE-OUTPUT      builtin_force_output    &rest x)
		(%READ-CHAR         builtin_read_char       &rest x)
    	(FILE-EXISTS?       builtin_file_exists     &rest x)
    	(%FOPEN             builtin_fopen           &rest x)
		(%FEOF              builtin_feof            &rest x)
		(%FCLOSE            builtin_fclose          &rest x)
		(%DIRECTORY         builtin_directory       &rest x)
		(%STAT              builtin_stat            &rest x)
		(READLINK           builtin_readlink        &rest x))

	(treterminal_
		(%TERMINAL-RAW      builtin_raw             &rest x)
		(%TERMINAL-NORMAL   builtin_normal          &rest x))

	(tredebug_
		(END-DEBUG          builtin_end_debug       &rest x)
		(INVOKE-DEBUGGER    builtin_invoke_debugger &rest x))

	(trealien_
    	(ALIEN-DLOPEN       builtin_dlopen  &rest x)
		(ALIEN-DLCLOSE      builtin_dlclose &rest x)
		(ALIEN-DLSYM        builtin_dlsym   &rest x)
    	(ALIEN-CALL         builtin_call    &rest x))

	(treimage_
    	(SYS-IMAGE-CREATE   builtin_create  &rest x)
		(SYS-IMAGE-LOAD     builtin_load    &rest x))

	(tretime_
		(NANOTIME           builtin_nanotime    &rest x))

	(trenet_
        (OPEN-SOCKET        builtin_open_socket &rest x)
        (ACCEPT             builtin_accept      &rest x)
        (RECV               builtin_recv        &rest x)
        (SEND               builtin_send        &rest x)
        (CLOSE-CONNECTION   builtin_close_connection    &rest x)
        (CLOSE-SOCKET       builtin_close_socket        &rest x))))

(defvar *c-builtin-argdefs* (make-hash-table :test #'eq))

(defvar *c-builtins*
  (let h (make-hash-table)
	(@ (grp *c-builtins-descr* h)
	  (let head (downcase (symbol-name grp.))
		(@ (f .grp)
          (& (href h f.)
             (error "Built-in function ~A is defined more than once." f.))
		  (= (href h f.) (? (cons? .f.)
                            (downcase (symbol-name (car .f.)))
                            (+ head (downcase (symbol-name (| .f. f.))))))
		  (= (href *c-builtin-argdefs* f.) ..f))))))

(defun c-builtin-names ()
  (hashkeys *c-builtins*))

(defun c-builtin-name (x)
  (href *c-builtins* x))

(defun c-builtin-argdef (x)
  (href *c-builtin-argdefs* x))

(defun c-make-builtin-wrappers ()
  (& (backtrace?)
     (@ [alet (c-builtin-argdef _)
          `(defun ,_ ,!
             (,(make-symbol (c-builtin-name _))
              ,@(argument-expand-names 'builtin-wrapper !)))]
        (remove 'cons (c-builtin-names)))))
