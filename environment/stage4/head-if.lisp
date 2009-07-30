;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun head-if (predicate x &key (but-last nil))
  (when x
	(if (and (funcall predicate x.)
			 (or (not but-last)
				 .x))
		(cons x.
			  (head-if predicate .x :but-last but-last)))))

(defun head-atoms (x &key (but-last nil))
  (head-if #'atom x :but-last but-last))
