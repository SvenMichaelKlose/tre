; tré – Copyright (c) 2013,2015 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception not)

(defun not (&rest x)
  (@ (i x t)
    (& i (return nil))))
