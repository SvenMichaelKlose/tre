;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun pad-string-concat (x padding)
  (apply #'string-concat (pad x padding)))
