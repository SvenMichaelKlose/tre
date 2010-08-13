;;;;; TRE environment
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun count-tree-0 (v x init max test)
  (if
	(funcall test v x)  (integer-1+ max)
	(atom x)  max
	(let sum (count-tree-0 v x. init max test)
	  (if (and max
			   (<= max sum))
		  sum
	      (count-tree-0 v .x sum max test)))))

(defun count-tree (v x &key (max nil) (test #'eql))
  (count-tree-0 v x 0 max test))
