;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro mapcar-macro (arg param &body body)
  `(progn
     ,@(mapcar (fn (eval (macroexpand `(#'((,arg) ,@body) ',_))))
               (eval param))))

(defmacro mapcan-macro (arg param &body body)
  `(progn
     ,@(mapcan (fn (eval (macroexpand `(#'((,arg) ,@body) ',_))))
               (eval param))))
