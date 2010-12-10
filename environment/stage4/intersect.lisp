;;;;; TRE compiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun intersect (a b)
  (when b
    (if (member b. a)
        (cons b. (intersect a .b))
        (intersect a .b))))
