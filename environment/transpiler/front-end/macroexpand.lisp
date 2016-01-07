; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(defun make-overlayed-std-macro-expander (tr expander-name)
  (aprog1 (define-expander expander-name)
    (with (mypred  (expander-pred !)
		   mycall  (expander-call !))
      (= (expander-pred !) [| (funcall mypred _)
                              (%%macro? _)]
         (expander-call !) [? (funcall mypred _)
                              (funcall mycall _)
                              (%%macrocall _)]))))

(defun transpiler-make-std-macro-expander (tr)
  (alet ($ (transpiler-name tr) (gensym) '-standard)
    (= (transpiler-std-macro-expander tr) (make-overlayed-std-macro-expander tr !))))

(defun transpiler-copy-std-macro-expander (tr-old tr-new)
  (with (exp-new (transpiler-make-std-macro-expander tr-new)
         old-ex  (transpiler-std-macro-expander tr-old)
         new-ex  exp-new)
    (= (expander-macros new-ex) (copy-hash-table (expander-macros old-ex)))
    (= (expander-argdefs new-ex) (copy-hash-table (expander-argdefs old-ex)))))

(defmacro define-transpiler-std-macro (tr name args &body body)
  (print-definition `(define-transpiler-std-macro ,tr ,name ,args))
  `(define-expander-macro (transpiler-std-macro-expander ,tr) ,name ,args ,@body))

(defun make-transpiler-std-macro (name args body)
  (eval (macroexpand `(define-transpiler-std-macro *transpiler* ,name ,args ,@body)))
  nil)

(defun transpiler-macroexpand (x)
  (with-temporary *=-function?* [| (defined-function _)
                                   (can-import-function? _)
                                   (%=-function? _)]
    (expander-expand (std-macro-expander) x)))
