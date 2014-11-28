;;;;; tré – Copyright (c) 2009,2011,2014 Sven Michael Klose <pixel@hugbox.org>

(defun tree-size (x &optional (n 0))
  (? (cons? x)
     (integer+ 1 n (tree-size (car x)) (tree-size (cdr x)))
     n))
