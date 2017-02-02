(functional $)

(fn $ (&rest args)
  (make-symbol (apply #'+ (@ #'string args))))
