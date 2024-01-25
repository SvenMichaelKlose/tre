(functional $)

(fn $ (&rest args)
  (make-symbol (*> #'+ (@ #'string args))))
