;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; EXPANSION OF ALTERNATIVE STANDARD MACROS

(defmacro define-transpiler-std-macro (tr &rest x)
  (when *show-definitions*
	(print `(define-transpiler-std-macro ,tr ,x.)))
  (with (tre (eval tr)
		 name x.)
	(when (expander-has-macro? (transpiler-macro-expander tre) name)
	  (error "Macro ~A already defined in code-generator." name))
	(transpiler-add-unwanted-function tre name)
    `(define-expander-macro ,(transpiler-std-macro-expander tre) ,@x)))
