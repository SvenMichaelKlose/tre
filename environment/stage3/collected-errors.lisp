;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *collected-errors* nil)

(defun collect-error (format-string &rest args)
  (push (apply #'format nil format-string args) *collected-errors*))

(defun issue-collected-errors ()
  (when *collected-errors*
	(alet (apply #'+ (filter [+ _ "~%"] *collected-errors*))
	  (= *collected-errors* nil)
	  (error (format nil !)))))
