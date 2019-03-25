(%defmacro defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  `(%defmacro ,name ,args
     (block nil
       (block ,name
         ,@(%add-documentation name body)))))

(%defmacro macro (name args &body body)
  `(defmacro ,name ,args ,@body))
