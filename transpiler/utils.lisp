;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Utilities

(defun transpiler-concat-string-tree (&rest x)
  (apply #'string-concat (tree-list x)))

(defun copy-recurse-into-setq-lambda (x fun)
  `(%setq ,(%setq-place x)
		  ,(copy-recurse-into-lambda (%setq-value x) fun)))
