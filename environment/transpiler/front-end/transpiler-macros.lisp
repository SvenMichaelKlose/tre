(fn make-transpiler-macro-expander (tr)
  (aprog1 (define-expander ($ (transpiler-name tr) '-standard (gensym)))
    (with (mypred (expander-pred !)
           mycall (expander-call !))
      (= (expander-pred !) [| (~> mypred _)
                              (%%macro? _)]
         (expander-call !) [? (~> mypred _)
                              (~> mycall _)
                              (%%macrocall _)]))))

(fn copy-transpiler-macro-expander (tr-old tr-new)
  (!= (make-transpiler-macro-expander tr-new)
    (= (transpiler-transpiler-macro-expander tr-new) !)
    (= (expander-macros !) (copy-hash-table (expander-macros (transpiler-transpiler-macro-expander tr-old))))))

(defmacro define-transpiler-macro (tr name args &body body)
  (print-definition `(define-transpiler-macro ,tr ,name ,args))
  `(def-expander-macro (transpiler-transpiler-macro-expander ,tr) ,name ,args
     ,@body))

(fn make-transpiler-macro (name args body)
  (eval (macroexpand
            `(define-transpiler-macro *transpiler* ,name ,args
               ,@body)))
  nil)

(fn transpiler-macroexpand (x)
  (with-temporary *=-function?* [| (defined-function _)
                                   (%=-function? _)]
    (expander-expand (transpiler-macro-expander) x)))

(progn
  ,@(@ [`(defmacro ,($ 'def- _ '-transpiler-macro) (name args &body body)
           `(define-transpiler-macro ,($ '* _ '-transpiler*) ,,name ,,args
              ,,@body))]
       *targets*))
