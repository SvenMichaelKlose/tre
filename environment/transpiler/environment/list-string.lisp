;;;;; tré – Copyright (c) 2005–2009,2011 Sven Michael Klose <pixel@copei.de>

(defun list-string (lst)
  (apply #'string-concat (mapcar #'string lst)))
