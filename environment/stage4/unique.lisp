;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun unique (x &key (test #'eql))
  (when x
	(if (member x. .x :test test)
	    (unique .x :test test)
		(cons x.
	    	  (unique .x :test test)))))
