;;;;; tré – Copyright (c) 2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun head-if (predicate x &key (but-last nil))
  (& x
     (funcall predicate x.)
	 (| (not but-last)
        .x)
	 (cons x. (head-if predicate .x :but-last but-last))))
