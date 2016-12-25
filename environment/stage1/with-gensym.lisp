(defmacro with-gensym (q &body body)
  `(let* ,(@ [`(,_ (gensym))] (ensure-list q))
     ,@body))
