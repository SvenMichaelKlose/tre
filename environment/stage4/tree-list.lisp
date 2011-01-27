;;;;; TRE environment
;;;;; Copyright (c) 2008,2011 Sven Klose <pixel@copei.de>

(defun tree-list (x)
  (? (atom x)
	 x
     (? (cons? x.)
	    (nconc (tree-list x.)
		       (tree-list .x))
	    (cons x.
		      (tree-list .x)))))
