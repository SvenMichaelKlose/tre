;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defmacro define-transpiler-infix (tr name)
  (when *show-definitions*
	(print `(define-transpiler-infix ,tr ,name)))
  (let tre (eval tr)
    (transpiler-add-inline-exception tre name)
    `(define-expander-macro ,(transpiler-macro-expander tre) ,name (x y)
	   `(%transpiler-native ,,x " " ,(string-downcase (string name)) " " ,,y))))

(defun transpiler-binary-expand (op args)
  (pad args op))

(defmacro define-transpiler-binary (tr op repl-op)
  (when *show-definitions*
	(print `(define-transpiler-binary ,tr ,op)))
  (let tre (eval tr)
    (transpiler-add-inline-exception tre op)
    (transpiler-add-plain-arg-fun tre op)
    `(define-expander-macro
	   ,(transpiler-macro-expander tre)
	   ,op
	   (&rest args)
       `("(" ,,@(transpiler-binary-expand ,repl-op args) ")"))))

(defun parenthized-comma-separated-list (x)
  `("(" ,@(comma-separated-list x) ")"))
