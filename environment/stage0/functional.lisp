(defvar *functionals* nil)

(%defmacro functional (&rest names)
  (print-definition `(functional ,@names))
  `(setq *functionals* (append ',names *functionals*)))

(%defun functional? (name)
  (member name *functionals* :test #'eq))

(functional identity
            + - * / mod
            number+ number- number* number/
            integer+ integer- integer* integer/
            number? == < >
            number== number< number>
            integer== integer< integer>
            character== character< character>
            bit-or bit-and bit-xor
            << >>
            code-char integer
            character?
            not eq eql
            make-symbol make-package
            atom symbol-value %type %%id %make-ptr
            symbol-function symbol-package function-native symbol?
            function? builtin? macro?
            cons list car cdr cons?
            elt length
            string?
            make-string string== string-concat string symbol-name
            list-string
            make-array array? aref
            slot-value %slot-value
            
            ; Not built–in (in C environment).
            list identity last copy-list integer? character?)
