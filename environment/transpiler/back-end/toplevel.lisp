;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code-generation top-level

;; After this pass:
;; - Symbols are obfuscated.
;; - Strings are encapsulated.
;; - Expressions are expanded via code generating macros.
;; - Everything is converted to strings and concatenated.
(defun transpiler-emit-code-compose (tr)
  (compose (fn (princ #\o)
			   (force-output)
			   _)
	  #'concat-stringtree
	  (fn transpiler-to-string tr _)
	  (fn expander-expand (transpiler-macro-expander tr) _)
	  (fn transpiler-finalize-sexprs tr _)
	  #'transpiler-encapsulate-strings
	  (fn transpiler-obfuscate tr _)))

(defun transpiler-emit-code (tr x)
  (let fun (transpiler-emit-code-compose tr)
    (mapcar (fn funcall fun _)
		    x)))

;; After this pass:
;; - Function prologues are generated.
;; - Unused places are removed.
;; - Places are transpated into vector ops.
(defun transpiler-generate-code-compose (tr)
  (compose
	  (fn (if (transpiler-lambda-export? tr)
			  (place-assign (place-expand _))
			  _))
	  #'opt-places-remove-unused
	  #'make-function-prologues))

(defun transpiler-generate-code (tr x)
  (with (emit (transpiler-emit-code-compose tr)
         gen (transpiler-generate-code-compose tr))
    (mapcar (fn funcall emit (funcall gen _))
		    x)))
