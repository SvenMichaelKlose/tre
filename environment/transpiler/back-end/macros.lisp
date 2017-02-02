(fn transpiler-make-code-expander (tr)
  (let expander-name ($ (transpiler-name tr) '-codegen)
    (= (transpiler-codegen-expander tr) (define-expander expander-name))))

(defmacro define-codegen-macro (tr name &rest x)
  (print-definition `(define-transpiler-macro ,tr ,name ,x.))
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,name ,@x))
