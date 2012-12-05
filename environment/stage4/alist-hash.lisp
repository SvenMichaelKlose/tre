;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun alist-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
	(dolist (i x h)
	  (= (href h i.) .i))))

(defun hash-alist (x &key (test #'eql))
  (filter [cons _ (href x _)] (hashkeys x)))
