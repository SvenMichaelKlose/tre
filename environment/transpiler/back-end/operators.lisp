; tré – Copyright (c) 2008–2009,2011–2016 Sven Michael Klose <pixel@copei.de>

(defmacro define-transpiler-infix (tr name)
  (print-definition `(define-transpiler-infix ,tr ,name))
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,name (x y)
     `(%%native ,,x " " ,(downcase (string name)) " " ,,y)))

(defun transpiler-binary-expand (op x)
  (? .x
     (pad x op)
     (list op x.)))

(defmacro define-transpiler-binary (tr op repl-op)
  (print-definition `(define-transpiler-binary ,tr ,op))
  (transpiler-add-plain-arg-fun (symbol-value tr) op)
  `(define-expander-macro (transpiler-codegen-expander ,tr) ,op (&rest args)
     `("(" ,,@(transpiler-binary-expand ,repl-op args) ")")))
