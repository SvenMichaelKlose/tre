;;;; TRE environment
;;;; Copyright (c) 2005-2006, 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Documentation

(defun documentation (sym)
  "Returns documentation string of function or macro."
  (aif (cdr (assoc sym *documentation*))
	(format t "Documentation for ~A:~%~A~%" sym !)
	(format t "No documentation for ~A. Sorry.~%" sym ))
  (awhen (symbol-function sym)
	(format t "Arguments to ~A:~%~A~%" sym (function-arguments !))))
