(var *documentation* nil)    ; TODO: Move into own file.

(%defun %add-documentation (name body)
  (? (? (string? body.)
        .body)
     (progn
       (setq *documentation* (. (. name body.) *documentation*))
       .body)
     body))
