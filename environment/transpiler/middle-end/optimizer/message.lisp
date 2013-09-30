;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun optimizer-message (fmt &rest args)
  (apply #'format t fmt args))
