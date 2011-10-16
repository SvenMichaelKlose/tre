;;;;; TRE environmen
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(setq *universe*
	  (cons 'functional
		    *universe*))

(setq *defined-functions*
	  (cons 'functional?
		    *defined-functions*))

(defvar *functionals* nil)

(%set-atom-fun functional
  (macro (&rest names)
	(if *show-definitions*
	    (print `(functional ,@names)))
    `(progn
	   (setq *functionals* (%nconc ',names *functionals*)))))

(%set-atom-fun functional?
  (function ((name)
	(member name *functionals* :test #'eq))))

(functional identity
            + - * / mod
            number+ number- number* number/
            integer+ integer- integer* integer/
            character+ character-
            logxor number? = < >
            number= number< number>
            integer= integer< integer>
            character= character< character>
            bit-or bit-and
            << >>
            code-char integer
            character?
            not eq eql
            make-symbol make-package
            atom symbol-value %type-id %%id %make-ptr
            symbol-function symbol-package symbol-compiled-function
            function? builtin?
            boundp fboundp
            macrop
            cons list car cdr cons?
            assoc member
            elt length
            string?
            make-string string= string-concat string symbol-name
            list-string
            make-array array? aref
            slot-value %slot-value)
