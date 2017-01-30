(var *documentation* nil)    ; TODO: Move into own file.

(%defun %add-documentation (name body)
  (? (? (string? body.)
        .body)
     (progn
       (setq *documentation* (. (. name body.) *documentation*))
       .body)
     body))

(%defmacro defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  `(%defmacro ,name ,args
     (block nil
       (block ,name
         ,@(%add-documentation name body)))))

(%defmacro macro (name args &body body)
  `(defmacro ,name ,args ,@body))
