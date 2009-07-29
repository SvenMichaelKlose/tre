;;;;; TRE compiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun doubles (a b)
  (when b
    (if (member b. a)
        (cons b. (doubles a .b))
        (doubles a .b))))
