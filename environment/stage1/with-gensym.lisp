;;;;; tré – Copyright (c) 2006,2008,2011–2014 Sven Michael Klose <pixel@hugbox.org>

(defmacro with-gensym (q &body body)
  `(let* ,(mapcar [`(,_ (gensym))]
                  (ensure-list q))
     ,@body))
