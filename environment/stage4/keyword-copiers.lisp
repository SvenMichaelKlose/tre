;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun keyword-copiers (&rest x)
  (mapcan [list (make-keyword _) _] x))
