;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun make-overlayed-std-macro-expander (tr expander-name)
  (with (e       (define-expander expander-name)
         mypred  (expander-pred e)
		 mycall  (expander-call e))
    (= (expander-pred e) (lx (tr mypred)
                           [| (funcall ,mypred _)
                              (? (transpiler-only-environment-macros? ,tr)
                                 (%%env-macro? _)
                                 (%%macro? _))])
       (expander-call e) (lx (tr mypred mycall)
                           [? (funcall ,mypred _) (funcall ,mycall _)
                              (transpiler-only-environment-macros? ,tr) (%%env-macrocall _)
                              (%%macrocall _)]))))

(defun transpiler-make-std-macro-expander (tr)
  (aprog1 ($ (transpiler-name tr) (gensym) '-standard)
    (= (transpiler-std-macro-expander tr) !)
    (make-overlayed-std-macro-expander tr !)))

(defun transpiler-copy-std-macro-expander (tr-old tr-new)
  (with (exp-new (transpiler-make-std-macro-expander tr-new)
         old-ex  (expander-get (transpiler-std-macro-expander tr-old))
         new-ex  (expander-get exp-new))
    (= (expander-macros new-ex) (copy-hash-table (expander-macros old-ex)))))

(defmacro define-transpiler-std-macro (tr name args &body body)
  (print-definition `(define-transpiler-std-macro ,tr ,name ,args))
  `(define-expander-macro ,(transpiler-std-macro-expander (eval tr)) ,name ,args ,@body))

(defun transpiler-macroexpand (x)
  (with-temporary *=-function?* [| (transpiler-defined-function *transpiler* _)
                                   (can-import-function? *transpiler* _)
                                   (%=-function? _)]
    (expander-expand (transpiler-std-macro-expander *transpiler*) x)))
