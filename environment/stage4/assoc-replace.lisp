;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun assoc-replace (x alst &key (test #'eql))
  (or (assoc-value x alst :test test)
      x))

(defun assoc-replace-many (x alst &key (test #'eql))
  (when x
	 (cons (assoc-replace x. alst :test test)
		   (assoc-replace-many .x alst :test test))))
