;;;;; tré – Copyright (c) 2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional ensure-list)

(defun ensure-list (x)
  (? (cons? x)
     x
     (list x)))
