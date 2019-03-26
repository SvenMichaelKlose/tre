;;;;; tré – Copyright (c) 2008–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-transpiler-infix (tr name)
  (print-definition `(define-transpiler-infix ,tr ,name))
  (let tre (eval tr)
    `(define-expander-macro ,(transpiler-codegen-expander tre) ,name (x y)
	   `(%%native ,,x " " ,(downcase (string name)) " " ,,y))))

(defun transpiler-binary-expand (op x)
  (? .x
     (pad x op)
     (list op x.)))

(defmacro define-transpiler-binary (tr op repl-op)
  (print-definition `(define-transpiler-binary ,tr ,op))
  (let tre (eval tr)
    (transpiler-add-plain-arg-fun tre op)
    `(define-expander-macro ,(transpiler-codegen-expander tre) ,op (&rest args)
       `("(" ,,@(transpiler-binary-expand ,repl-op args) ")"))))
