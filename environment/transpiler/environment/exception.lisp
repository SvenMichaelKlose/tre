;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei,de>

(defun throw (&rest x)
  (apply #'error x))
