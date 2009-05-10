;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun head-if (predicate x &key (butlast nil))
  (when x
	(if (and (funcall predicate x.)
			 (or (not keep-last)
				 .x))
		(cons x.
			  (head-if predicate .x :butlast butlast)))))

(defun head-atoms (x &key (butlast nil))
  (head-if #'atom x :butlast butlast))
