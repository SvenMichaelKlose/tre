(fn list-without-noargs-tag (x)
  (remove 'no-args x))

(fn body-has-noargs-tag? (body)
  (eq 'no-args body.))

(fn body-with-noargs-tag (body)
  (& (body-has-noargs-tag? body)
     (error "Body already has NOARGS tag."))
  `(no-args ,@body))
