;;;;; tré - Copyright (c) 2010,2012,2014 Sven Michael Klose <pixel@hugbox.org>

(defun unique (x &key (test #'eql))
  (when x
	(? (member x. .x :test test)
	   (unique .x :test test)
	   (. x. (unique .x :test test)))))
