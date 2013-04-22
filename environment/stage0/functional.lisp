;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(setq *universe*
	  (cons 'functional
		    *universe*))

(setq *defined-functions*
	  (cons 'functional?
		    *defined-functions*))

(defvar *functionals* nil)

(%set-atom-fun functional
  (macro (&rest names)
	(print-definition `(functional ,@names))
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
            logxor number? == < >
            number== number< number>
            integer== integer< integer>
            character== character< character>
            bit-or bit-and
            << >>
            code-char integer
            character?
            not eq eql
            make-symbol make-package
            atom symbol-value %type %%id %make-ptr
            symbol-function symbol-package symbol-compiled-function
            function? builtin? macrop
            cons list car cdr cons?
            elt length
            string?
            make-string string== string-concat string symbol-name
            list-string
            make-array array? aref
            slot-value %slot-value)
