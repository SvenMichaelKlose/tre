;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun concat-stringtree (&rest x)
  (apply #'string-concat (tree-list x)))
