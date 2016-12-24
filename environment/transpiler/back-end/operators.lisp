; tré – Copyright (c) 2008–2009,2011–2016 Sven Michael Klose <pixel@copei.de>

(defmacro define-transpiler-infix (tr name)
  (print-definition `(define-transpiler-infix ,tr ,name))
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,name (x y)
     `(%%native ,,x " " ,(downcase (string name)) " " ,,y)))

(defmacro define-transpiler-binary (tr op repl-op)
  (print-definition `(define-transpiler-binary ,tr ,op))
  (transpiler-add-plain-arg-fun (symbol-value tr) op)
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,op (&rest x)
     (? .x
        (pad x ,repl-op)
        (list ,repl-op x.))))
