;;;;; tré – Copyright (c) 2005–2006,2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun values (&rest vals)
  (. 'values vals))

(defun values? (x)
  (& (cons? x)
     (eq 'values (car x))))
