(fn optimizer-message (fmt &rest args)
  (& *development?*
     (princ (+ "; " (*> #'format nil fmt args)))))
