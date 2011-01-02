;;;; TRE transpiler environment
;;;; Copyright (c) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defun list-string (lst)
  (apply #'string-concat (mapcar #'string lst)))
