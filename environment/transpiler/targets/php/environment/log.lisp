;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun %%%log (txt)
  (%setq nil (echo txt))
  txt)

(defun logprint (x)
  (log (with-string-stream s
         (print x s)))
  x)
