;;;;; tré - Copyright (c) 2005-2006,2008,2012 Sven Michael Klose <pixel@copei.de>

(defun documentation (sym)
  "Returns documentation string of function or macro."
  (!? (cdr (assoc sym *documentation*))
	  (format t "Documentation for ~A:~%~A~%" sym !)
	  (format t "No documentation for ~A. Sorry.~%" sym ))
  (awhen (symbol-function sym)
	(format t "Arguments to ~A:~%~A~%" sym (function-arguments !))))
