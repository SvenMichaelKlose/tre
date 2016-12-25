(defun transpiler-make-std-macro-expander (tr)
  (aprog1 (define-expander ($ (transpiler-name tr) '-standard (gensym)))
    (with (mypred  (expander-pred !)
		   mycall  (expander-call !))
      (= (expander-pred !) [| (funcall mypred _)
                              (%%macro? _)]
         (expander-call !) [? (funcall mypred _)
                              (funcall mycall _)
                              (%%macrocall _)]))))

(defun transpiler-copy-std-macro-expander (tr-old tr-new)
  (alet (transpiler-make-std-macro-expander tr-new)
    (= (transpiler-std-macro-expander tr-new) !)
    (= (expander-macros !) (copy-hash-table (expander-macros (transpiler-std-macro-expander tr-old))))))

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
