;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun count-tree-0 (v x init max test)
  (?
	(funcall test v x)  (integer-1+ max)
	(atom x)  max
	(let sum (count-tree-0 v x. init max test)
	  (? (& max (<= max sum))
		  sum
	      (count-tree-0 v .x sum max test)))))

(defun count-tree (v x &key (max nil) (test #'eql))
  (count-tree-0 v x 0 max test))
