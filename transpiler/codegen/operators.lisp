;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; OPERATOR EXPANSION

(defmacro define-transpiler-infix (tr name)
  (when *show-definitions*
	(print `(define-transpiler-infix ,tr ,name)))
  `(define-expander-macro ,(transpiler-macro-expander (eval tr)) ,name (x y)
	 `(%transpiler-native ,,x ,(string-downcase (string name)) " " ,,y)))

(defun transpiler-binary-expand (op args)
  (nconc (mapcan (fn `(,_ ,op))
				 (butlast args))
		 (last args)))

(defmacro define-transpiler-binary (tr op repl-op)
  (when *show-definitions*
	(print `(define-transpiler-binary ,tr ,op)))
  (transpiler-add-plain-arg-fun (eval tr) op)
  `(progn
	 (define-expander-macro
	   ,(transpiler-macro-expander (eval tr))
	   ,op
	   (&rest args)
       `("(" ,,@(transpiler-binary-expand ,repl-op args) ")"))))
