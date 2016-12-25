(defvar *documentation* nil)    ; TODO: Move into own file. Functions should be documented as well.

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
