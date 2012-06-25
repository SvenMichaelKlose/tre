;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun backslash-to-slash (x)
  (? (== #\\ x)
     #\/
     x))

(defun backslashes-to-slashes (x)
  (list-string (mapcar #'backslash-to-slash (string-list x))))
