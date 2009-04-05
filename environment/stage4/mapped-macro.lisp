;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro mapcar-macro (arg param &rest body)
  `(progn
     ,,@(mapcar #'((,arg) ,@body)
                ,param)))

(defmacro mapcan-macro (arg param &rest body)
  `(progn
     ,,@(mapcan #'((,arg) ,@body)
                ,param)))
