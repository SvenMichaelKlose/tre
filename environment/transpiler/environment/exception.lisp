(defun throw (&rest x)
  (apply #'error x))
