(fn transpiler-make-code-expander (tr)
  (let expander-name ($ (transpiler-name tr) '-codegen)
    (= (transpiler-codegen-expander tr) (define-expander expander-name))))

(defmacro define-codegen-macro (tr name &rest x)
  (print-definition `(define-transpiler-macro ,tr ,name ,x.))
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,name ,@x))

(defmacro def-codegen-infix (tr name)
  (print-definition `(def-codegen-infix ,tr ,name))
  `(define-codegen-macro ,tr ,name (x y)
     `(%%native ,,x " " ,(downcase (string name)) " " ,,y)))

(defmacro def-codegen-binary (tr op repl-op)
  (print-definition `(def-codegen-binary ,tr ,op))
  `(define-codegen-macro ,tr ,op (&rest x)
     (? .x
        (pad x ,repl-op)
        (list ,repl-op x.))))
