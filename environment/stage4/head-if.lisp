;;;;; tré – Copyright (c) 2009,2012–2014 Sven Michael Klose <pixel@hugbox.org>

(defun head-if (predicate x &key (but-last nil))
  (& x
     (funcall predicate x.)
	 (| (not but-last)
        .x)
	 (. x. (head-if predicate .x :but-last but-last))))
