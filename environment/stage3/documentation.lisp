;;;;; tré - Copyright (c) 2005-2006,2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun documentation (sym)
  (!? (assoc-value sym *documentation*)
	  (format t "Documentation for ~A:~%~A~%" sym !))
  (awhen (symbol-function sym)
	(format t "Arguments to ~A:~%~A~%" sym (function-arguments !))))
