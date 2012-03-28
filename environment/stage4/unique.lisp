;;;;; tré - Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun unique (x &key (test #'eql))
  (when x
	(? (member x. .x :test test)
	   (unique .x :test test)
	   (cons x. (unique .x :test test)))))
