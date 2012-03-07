;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Simulate lexical scope in interpreter.

(defun %lx (lexicals fun-expr)
  (eval (macroexpand fun-expr)))

(defmacro lx (lexicals fun)
  `(%lx ',lexicals `,fun))
