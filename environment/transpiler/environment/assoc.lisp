;;;; TRE environment
;;;; Copyright (C) 2005-2006,2009 Sven Klose <pixel@copei.de>

(defun assoc (key lst &key (test nil))
  "Search value for key in associative list."
  (when-debug
	(when lst
	  (unless (consp lst)
	    (%error "list expected"))))
  (dolist (i lst)
    (when-debug
	  (when (consp i)
		(print i)
		(%error "not a pair")))
    (when (funcall (or test #'eql) key i.)
  	  (return i))))
