(fn body-with-noargs-tag (body)
  (& (eq 'no-args body.)
     (error "Body already has NOARGS tag."))
  `(no-args ,@body))
