;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun assoc-replace (x alst)
  (or (assoc-value x alst)
	   x))

(defun assoc-replace-many (x alst)
  (when x
	 (cons (assoc-replace x. alst)
		   (assoc-replace-many .x alst))))
