; tré – Copyright (c) 2013,2015 Sven Michael Klose <pixel@copei.de>

(defun keyword-copiers (&rest x)
  (mapcan [list (make-keyword _) (make-symbol (symbol-name _))] x))
