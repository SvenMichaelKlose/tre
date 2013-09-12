;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun remove-keywords (x)
  (remove-if #'keyword? x))
