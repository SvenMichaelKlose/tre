;;;;; tré - Copyright (c) 2006-2012 Sven Michael Klose <pixel@copei.de>

(defun function-arguments (fun)
  (?
    (builtin? fun) '(&rest args-to-builtin)
    (array? fun) (aref fun 0)
    (car (symbol-value fun))))

(defun function-body (fun)
  (cdr (symbol-value fun)))
