;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code-generating set of macros

(defmacro define-transpiler-macro (tr &rest x)
  (when *show-definitions*
	(print `(define-transpiler-macro ,tr ,x.)))
  (with (tre (eval tr)
		 name x.)
    (when (expander-has-macro? (transpiler-macro-expander tre) name)
      (error "Code-generator macro ~A already defined as standard macro."
			 name))
    (transpiler-add-unwanted-function tre name)
    (transpiler-add-inline-exception tre name)
	(transpiler-add-obfuscation-exceptions tre name)
    `(define-expander-macro ,(transpiler-macro-expander tre) ,@x)))
