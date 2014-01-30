;;;;; tré – Copyright (c) 2006,2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro with-gensym (q &body body)
  `(let* (,@(mapcar ^(,_ (gensym))
                    (ensure-list q)))
     ,@body))
