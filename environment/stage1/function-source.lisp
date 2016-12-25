(defun function-arguments (fun)
  (?
    (builtin? fun)          '(&rest args-to-builtin)
    (function-bytecode fun) (aref (function-bytecode fun) 0)
    (car (function-source fun))))

(defun function-body (fun)
  (? (function-bytecode fun)
     (aref (function-bytecode fun) 1)
     (cdr (function-source fun))))
