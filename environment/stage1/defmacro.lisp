;;;;; tré – Copyright (c) 2005–2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(defvar *documentation* nil)

(%defun %add-documentation (name body)
  (? (? (string? (car body))
        (cdr body))
     (progn
       (setq *documentation* (cons (cons name (car body)) *documentation*))
       (cdr body))
     body))

(%defmacro defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  `(block nil
     (%defmacro ,name ,args
       (block ,name
         ,@(%add-documentation name body)))))
