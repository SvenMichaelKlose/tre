;;;; TRE environment
;;;; Copyright (C) 2005-2006,2009-2011 Sven Klose <pixel@copei.de>

(defun assoc (key lst &key (test #'eql))
  "Search value for key in associative list."
  (when-debug
	(when lst
	  (unless (cons? lst)
	    (%error "list expected"))))
  (dolist (i lst)
    (when-debug
	  (when (atom i)
		(print i)
		(%error "not a pair")))
    (when (funcall test key i.)
  	  (return i))))
