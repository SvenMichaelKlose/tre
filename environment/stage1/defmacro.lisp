; tré – Copyright (c) 2005–2008,2011–2015 Sven Michael Klose <pixel@copei.de>

(defvar *documentation* nil)

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
