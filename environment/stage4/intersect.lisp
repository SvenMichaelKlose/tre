;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun intersect (a b)
  (when b
    (? (member b. a)
       (cons b. (intersect a .b))
       (intersect a .b))))
