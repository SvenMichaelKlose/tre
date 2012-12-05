;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-concat-text (tr &rest x)
  (apply (transpiler-code-concatenator tr) x))

;; After this pass:
;; - Symbols are obfuscated.
;; - Strings are encapsulated.
;; - Expressions are expanded via code generating macros.
;; - Everything is converted to strings and concatenated.
(transpiler-pass transpiler-generate-code (tr)
    concat-stringtree   [transpiler-concat-text tr _]
    to-string           [? (transpiler-make-text? tr)
                           (transpiler-to-string tr _)
                           _]
    obfuscate           [? (transpiler-make-text? tr)
                           (transpiler-obfuscate tr _)
                           _]
    codegen-expand      [expander-expand (transpiler-codegen-expander tr) _]
    finalize-sexprs     #'transpiler-finalize-sexprs
    encapsulate-strings [? (transpiler-encapsulate-strings? tr)
                           (transpiler-encapsulate-strings _)
                           _]
    function-names      [? (transpiler-function-name-prefix tr)
                           (translate-function-names tr nil _)
                           _])

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
  (transpiler-concat-text tr (transpiler-generate-code tr (transpiler-backend-prepare tr x))))
