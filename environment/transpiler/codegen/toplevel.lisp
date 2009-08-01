;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code-generation top-level

(defun transpiler-generate-code-compose (tr)
  (compose (fn (princ #\o)
			   (force-output)
			   _)

		   #'concat-stringtree

		   (fn transpiler-to-string tr _)

		   ; Expand expressions to strings.
		   (fn expander-expand (transpiler-macro-expander tr) _)

		   ; Expand top-level symbols, add expression separators.
		   (fn transpiler-finalize-sexprs tr _)

		   ; Wrap strings in %TRANSPILER-STRING expressions.
		   #'transpiler-encapsulate-strings

		   ; Obfuscate symbol-names.
		   (fn transpiler-obfuscate tr _)))

(defun transpiler-generate-code (tr x)
  (mapcar (fn funcall (transpiler-generate-code-compose tr) _)
		  x))
