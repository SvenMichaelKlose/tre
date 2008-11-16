;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Utilities

(defun transpiler-concat-string-tree (x)
  (apply #'string-concat (tree-list x)))
