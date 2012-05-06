;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

;; After this pass:
;; - Symbols are obfuscated.
;; - Strings are encapsulated.
;; - Expressions are expanded via code generating macros.
;; - Everything is converted to strings and concatenated.
(transpiler-pass transpiler-generate-code (tr)
    concat-stringtree   #'concat-stringtree
    to-string           (fn transpiler-to-string tr _)
    obfuscate           (fn transpiler-obfuscate tr _)
    codegen-expand      (fn expander-expand (transpiler-codegen-expander tr) _)
    finalize-sexprs     #'transpiler-finalize-sexprs
    encapsulate-strings #'transpiler-encapsulate-strings
    function-names      (fn translate-function-names tr nil _))

(transpiler-pass transpiler-backend-make-places ()
    place-assign            #'place-assign
    place-expand            #'place-expand
    make-function-prologues #'make-function-prologues)

;; After this pass:
;; - Function prologues are generated.
;; - Places are translated into vector ops.
(defun transpiler-backend-prepare (tr x)
  (? (transpiler-lambda-export? tr)
     (transpiler-backend-make-places x)
	 (make-function-prologues x)))

(defun transpiler-backend (tr x)
  (concat-stringtree (mapcar (fn transpiler-generate-code tr (transpiler-backend-prepare tr (list _))) x)))
