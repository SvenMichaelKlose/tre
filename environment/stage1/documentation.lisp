(var *documentation* nil)

(%defun %add-documentation (name body)
  (? (? (string? body.)
        .body)
     (progn
       (setq *documentation* (. (. name body.) *documentation*))
       .body)
     body))
