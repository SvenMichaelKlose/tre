(fn optimizer-message (fmt &rest args)
  (princ (+ "; " (apply #'format nil fmt args))))
