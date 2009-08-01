;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun %lx (lexicals fun-expr)
  (eval (macroexpand fun-expr)))

;; Simulate lexical scoping in the interpreter.
;; Checks type of scoping at run-time to share code between
;; interpreter and compiler.
(defmacro lx (lexicals fun)
  (print `(%lx ',lexicals `,fun)))
