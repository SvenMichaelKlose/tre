;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code-generation top-level

;; After this pass:
;; - Symbols are obfuscated.
;; - Strings are encapsulated.
;; - Expressions are expanded via code generating macros.
;; - Everything is converted to strings and concatenated.
(defun transpiler-generate-code-compose (tr)
  (compose (fn (princ #\o)
			   (force-output)
			   _)
	  #'concat-stringtree
	  (fn transpiler-to-string tr _)
	  (fn expander-expand (transpiler-macro-expander tr) _)
	  (fn transpiler-finalize-sexprs tr _)
	  #'transpiler-encapsulate-strings
	  (fn transpiler-obfuscate tr _)))

(defun transpiler-generate-code (tr x)
  (mapcar (fn funcall (transpiler-generate-code-compose tr) _)
		  x))
