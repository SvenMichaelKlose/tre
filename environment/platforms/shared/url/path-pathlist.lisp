;;;;; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(defun path-pathlist (x)
  (split #\/ x))

(defun pathlist-path (x)
  (? x
     (apply #'string-concat (pad x "/"))
     ""))
