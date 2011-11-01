;;;;; tré - Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defmacro define-codegen-macro (tr name &rest x)
  (when *show-definitions*
	(print `(define-transpiler-macro ,tr ,x.)))
  (let quoted-name (list 'quote name)
    `(progn
       (when (expander-has-macro? (transpiler-macro-expander ,tr) ,quoted-name)
         (error "Code generator macro ~A is already defined." ,quoted-name))
       (transpiler-add-unwanted-function ,tr ,quoted-name)
       (transpiler-add-inline-exception ,tr ,quoted-name)
       (define-expander-macro ,(transpiler-macro-expander (symbol-value tr)) ,name ,@x))))
