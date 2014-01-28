;;;;; tré – Copyright (c) 2009,2011 Sven Michael Klose <pixel@copei.de>

(defun tree-size (x &optional (n 0))
  (? (cons? x)
     (integer+ 1 n (tree-size x.) (tree-size .x))
     n))
