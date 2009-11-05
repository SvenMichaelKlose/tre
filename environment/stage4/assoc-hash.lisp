;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun assoc-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
	(dolist (i x h)
	  (setf (href h i.) .i))))
