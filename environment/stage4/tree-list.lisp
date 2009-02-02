;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun tree-list (x)
  (if (atom x)
	  x
      (if (consp x.)
	      (nconc (tree-list x.)
			     (tree-list .x))
	      (cons x.
			    (tree-list .x)))))
