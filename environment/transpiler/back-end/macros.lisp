;;;;; tré – Copyright (c) 2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-code-expander (tr)
  (let expander-name ($ (transpiler-name tr) '-codegen)
    (= (transpiler-codegen-expander tr) expander-name)
    (define-expander (transpiler-codegen-expander tr))))

(defmacro define-codegen-macro (tr name &rest x)
  (when *show-definitions*
	(print `(define-transpiler-macro ,tr ,x.)))
  `(progn
     (transpiler-add-unwanted-function ,tr ',name)
     (transpiler-add-inline-exception ,tr ',name)
     (define-expander-macro ,(transpiler-codegen-expander (eval tr)) ,name ,@x)))
