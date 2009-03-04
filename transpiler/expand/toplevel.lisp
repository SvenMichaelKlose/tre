;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; TOPLEVEL

(defun transpiler-expand-compose (tr)
  (compose
	(fn (princ #\.)
		(force-output)
		_)

    ; Add names to top-level functions for those target languages
    ; that require it.
    (fn transpiler-make-named-functions tr _)

    ; Peephole-optimization. Removes some unused code.
    #'opt-peephole

	; Quote keywords.
    #'transpiler-quote-keywords

    ; Break up nested expressions.
    ; After this pass function arguments may only be literals,
    ; constants or variables.
    (fn transpiler-expression-expand tr `(vm-scope ,_))

	#'transpiler-restore-funs
	(fn (repeat-while-changes
	     (fn expander-expand 'TRANSPILER-FUNPROP _)
		 _))))

(defun transpiler-expand (tr x)
  (remove-if #'not
		     (mapcar (fn funcall (transpiler-expand-compose tr) _)
					 x)))

(defun transpiler-preexpand-compose (tr)
  (compose
    ; Make (SLOT-VALUE this ...) expressions for class members.
    (fn thisify (transpiler-thisify-classes tr) _)

	; Inline local functions and export constant LAMBDA expressions.
    (fn transpiler-lambda-expand tr _)

	; Make CHARACTER objects.
    #'transpiler-expand-characters

    ; Expand BACKQUOTEs and compiler-macros.
    #'special-form-expand

    (fn transpiler-macroexpand tr _)

	#'quasiquote-expand

    ; Alternative standard-macros.
    ; Some macros in this pass just rename expression to bypass the
    ; standard macro-expansion.
    (fn transpiler-macroexpand tr _)

    ; Convert object-dot-member symbols to %SLOT-VALUE expressions.
    #'dot-expand

    (fn funcall (transpiler-preprocessor tr) _)))

(defun transpiler-preexpand (tr x)
  (mapcan (fn (funcall (transpiler-preexpand-compose tr) (list _)))
		  x))

(defun transpiler-preexpand-and-expand (tr forms)
  (transpiler-expand tr (transpiler-preexpand tr forms)))
