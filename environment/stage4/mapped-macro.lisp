;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro mapcar-macro (arg param &body body)
  `(progn
     ,,@(mapcar #'((,arg) ,@body)
                ,param)))

(defmacro mapcan-macro (arg param &body body)
  `(progn
     ,,@(mapcan #'((,arg) ,@body)
                ,param)))
