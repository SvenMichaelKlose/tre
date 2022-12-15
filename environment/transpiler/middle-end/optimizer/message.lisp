(fn optimizer-message (fmt &rest args)
  (& *development?*
     (princ (+ "; " (apply #'format nil fmt args)))))
