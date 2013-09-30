;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun cl:append (&rest x)
  (?
    (not x)  x
    (not .x) x.
    (apply #'nconc (filter #'copy-list (butlast x)) (car (last x)))))
