;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun make-overlayed-std-macro-expander (tr expander-name)
  (with (e       (define-expander expander-name)
         mypred  (expander-pred e)
		 mycall  (expander-call e))
    (= (expander-pred e) (lx (tr mypred)
                            [| (funcall ,mypred _)
                               (? (transpiler-only-environment-macros? ,tr)
                                  (%%env-macrop _)
                                  (%%macrop _))])
       (expander-call e) (lx (tr mypred mycall)
                            [? (funcall ,mypred _) (funcall ,mycall _)
                               (transpiler-only-environment-macros? ,tr) (%%env-macrocall _)
                               (%%macrocall _)]))))

(defun transpiler-make-std-macro-expander (tr)
  (let expander-name ($ (transpiler-name tr) '-standard)
    (= (transpiler-std-macro-expander tr) expander-name)
    (make-overlayed-std-macro-expander tr expander-name)))

(defmacro define-transpiler-std-macro (tr name &rest args-and-body)
  (print-definition `(define-transpiler-std-macro ,tr ,name ,args-and-body.))
  `(progn
     (transpiler-add-inline-exception ,tr ',name)
     (define-expander-macro ,(transpiler-std-macro-expander (eval tr)) ,name ,@args-and-body)))

(defun transpiler-macroexpand (tr x)
  (with-temporary *=-function?* [| (transpiler-defined-function tr _)
                                   (transpiler-can-import? tr _)
                                   (%=-function? _)]
    (expander-expand (transpiler-std-macro-expander tr) x)))
