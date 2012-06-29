;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun assoc-replace (x alst &key (test #'eql))
  (| (assoc-value x alst :test test)
     x))

(defun assoc-replace-many (x alst &key (test #'eql))
  (& x (cons (assoc-replace x. alst :test test)
		     (assoc-replace-many .x alst :test test))))
