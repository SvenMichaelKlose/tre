;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun tail-after-if (predicate x &key (keep-last nil))
  (when x
	(? (& (funcall predicate x.)
		  (| (not keep-last)
		     .x))
       (tail-after-if predicate .x :keep-last keep-last)
       x)))

(defun tail-after-atoms (x &key (keep-last nil))
  (tail-after-if #'atom x :keep-last keep-last))
