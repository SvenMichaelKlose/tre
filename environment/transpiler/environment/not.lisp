;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun not (&rest x)
  (dolist (i x t)
    (& i (return nil))))
