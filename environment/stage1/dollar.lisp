(functional $)

(defun $ (&rest args)
  (make-symbol (apply #'+ (@ #'string args))))
