;;;; TRE environment
;;;; Copyright (C) 2005-2006,2009 Sven Klose <pixel@copei.de>

(defun assoc (key lst &key (test nil))
  "Search value for key in associative list."
  (when lst
	(unless (consp lst)
	  (%error "list expected"))
    (dolist (i lst)
      (if (consp i)
		  (if (funcall (or test #'eql) key (car i))
	  	  	  (return i))
		  (and (print i)
			   (%error "not a pair"))))))
