;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun assoc-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
	(dolist (i x h)
	  (= (href h i.) .i))))
