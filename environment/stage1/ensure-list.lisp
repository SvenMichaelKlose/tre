; tré – Copyright (c) 2008,2011–2013,2016 Sven Michael Klose <pixel@copei.de>

(functional ensure-list)

(defun ensure-list (x)
  (? (list? x)
     x
     (list x)))
