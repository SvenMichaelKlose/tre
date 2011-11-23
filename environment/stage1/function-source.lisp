;;;; tré - Copyright (c) 2006-2011 Sven Klose <pixel@copei.de>

(defun function-arguments (fun)
  (if (builtin? fun)
	  '(&rest args-to-builtin)
      (car (symbol-value fun))))

(defun function-body (fun)
  (cdr (symbol-value fun)))
