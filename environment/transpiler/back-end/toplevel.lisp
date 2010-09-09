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
	  #'transpiler-finalize-sexprs
	  #'transpiler-encapsulate-strings
	  #'translate-function-names
	  (fn transpiler-obfuscate tr _)))

(defun transpiler-emit-code (tr x)
  (funcall (transpiler-emit-code-compose tr) x))

;; After this pass:
;; - Function prologues are generated.
;; - Places are translated into vector ops.
(defun transpiler-generate-code (tr x)
  (if (transpiler-lambda-export? tr)
	  (place-assign (place-expand (make-function-prologues x)))
	  (make-function-prologues x)))

(defun transpiler-backend (tr x)
  (funcall (transpiler-emit-code-compose tr)
  		   (transpiler-generate-code tr x)))
