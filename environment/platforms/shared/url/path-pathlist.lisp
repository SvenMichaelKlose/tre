;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun path-pathlist (x)
  (split #\/ x))

(defun pathlist-path (x)
  (? x
     (pad-string-concat x "/")
     ""))
