(defun list-without-noargs-tag (x)
  (remove 'no-args x))

(defun body-has-noargs-tag? (body)
  (eq 'no-args body.))

(defun body-with-noargs-tag (body)
  (& (body-has-noargs-tag? body)
     (error "Body already has NOARGS tag."))
  `(no-args ,@body))

(defun body-without-noargs-tag (body)
  (? (body-has-noargs-tag? body)
     .body
     body))
