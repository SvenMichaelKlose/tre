;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defmacro functional (macro (&rest names)
  (print-definition `(functional ,@names))
  `(setq *functionals* (%nconc ',names *functionals*))))

(defun functional? (name)
  (member name *functionals* :test #'eq))

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
            atom symbol-value %type-id %%id %make-ptr
            symbol-function symbol-package symbol-compiled-function
            function? builtin? macrop
            cons list car cdr cons?
            assoc member
            elt length
            string?
            make-string string== string-concat string symbol-name
            list-string
            make-array array? aref
            slot-value %slot-value)
