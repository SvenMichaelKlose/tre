(fn make-transpiler-macro-expander (tr)
  (aprog1 (define-expander ($ (transpiler-name tr) '-standard (gensym)))
    (with (mypred  (expander-pred !)
           mycall  (expander-call !))
      (= (expander-pred !) [| (funcall mypred _)
                              (%%macro? _)]
         (expander-call !) [? (funcall mypred _)
                              (funcall mycall _)
                              (%%macrocall _)]))))

(fn copy-transpiler-macro-expander (tr-old tr-new)
  (!= (make-transpiler-macro-expander tr-new)
    (= (transpiler-transpiler-macro-expander tr-new) !)
    (= (expander-macros !) (copy-hash-table (expander-macros (transpiler-transpiler-macro-expander tr-old))))))

(defmacro define-transpiler-macro (tr name args &body body)
  (print-definition `(define-transpiler-macro ,tr ,name ,args))
  `(define-expander-macro (transpiler-transpiler-macro-expander ,tr) ,name ,args ,@body))

(fn make-transpiler-macro (name args body)
  (eval (macroexpand `(define-transpiler-macro *transpiler* ,name ,args ,@body)))
  nil)

(fn transpiler-macroexpand (x)
  (with-temporary *=-function?* [| (defined-function _)
                                   (can-import-function? _)
                                   (%=-function? _)]
    (expander-expand (transpiler-macro-expander) x)))

{,@(@ [`(defmacro ,($ 'def- _ '-transpiler-macro) (name args &body body)
          `(define-transpiler-macro ,($ '* _ '-transpiler*) ,,name ,,args ,,@body))]
      *targets*)}