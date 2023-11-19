;;; This is to avoid having the transpiler detect functions with no
;;; side effects.  TODO: Add that to the transpiler.
;;; For reasons yet unknown SBCL does not detect them either automactically.
;;; Only has effect on non-CL targets.

(var *functionals* nil)

(%defmacro functional (&rest names)
  (print-definition `(functional ,@names))
  `(setq *functionals* (append ',names *functionals*)))

(%fn functional? (name)
  (member name *functionals* :test #'eq))

(functional identity
            + - * / mod
            number+ number- number* number/
            number? == < >
            number== number< number>
            character== character< character>
            bit-or bit-and bit-xor
            << >>
            integer integer?
            character?  code-char char-code
            atom not eq eql
            symbol make-symbol make-package
            symbol-value %type %%id %make-ptr
            symbol-function symbol-package symbol?
            function? builtin? macro?
            cons? cons list car cdr
            elt length
            string?
            make-string string== string-concat string symbol-name
            list-string
            make-array array? aref
            slot-value %slot-value
            href hash-table?
            object?)
