;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro mapcar-macro (param arg &rest body)
  `(progn
     ,,@(mapcar #'((,arg) ,@body)
                ,param)))

(defmacro mapcan-macro (param arg &rest body)
  `(progn
     ,,@(mapcan #'((,arg) ,@body)
                ,param)))
