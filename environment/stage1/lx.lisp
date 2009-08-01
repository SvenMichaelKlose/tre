;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Create function with lexical values. %LX can be redefined in
;;;;; transpilers to use native lexical scoping.

(defun %lx (lexicals fun-expr)
  (eval (macroexpand fun-expr)))

(defmacro lx (lexicals fun)
  `(%lx ',lexicals `,fun))
