;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun tree-size (x &optional (n 0))
  (if (consp x)
      (integer+ 1 n (tree-size x.)
             		(tree-size .x))
      n))
