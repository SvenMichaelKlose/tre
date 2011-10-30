;;;;; tré - Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defmacro define-codegen-macro (tr &rest x)
  (when *show-definitions*
	(print `(define-transpiler-macro ,tr ,x.)))
  (with (tre (eval tr)
		 name x.)
    (when (expander-has-macro? (transpiler-macro-expander tre) name)
      (warn "Code-generator macro ~A already defined as code generator macro." name))
    (transpiler-add-unwanted-function tre name)
    (transpiler-add-inline-exception tre name)
    `(define-expander-macro ,(transpiler-macro-expander tre) ,@x)))
