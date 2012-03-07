;;;;; tré - Copyright (c) 2006,2008,2011-2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-gensym (q &body body)
  `(let* (,@(mapcar (fn `(,_ (gensym))) (force-list q)))
     ,@body))
