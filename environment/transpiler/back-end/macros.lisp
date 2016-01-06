; tré – Copyright (c) 2008–2009,2011–2013,2015 Sven Michael Klose <pixel@hugbox.org>

(defun transpiler-make-code-expander (tr)
  (let expander-name ($ (transpiler-name tr) '-codegen)
    (= (transpiler-codegen-expander tr) (define-expander expander-name))))

(defmacro define-codegen-macro (tr name &rest x)
  (print-definition `(define-transpiler-macro ,tr ,name ,x.))
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,name ,@x))
