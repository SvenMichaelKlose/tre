;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun shared-essential-defun (name args &rest body)
  (when *show-definitions*
    (late-print `(defun ,name ,@args)))
  (with (n (%defun-name name)
		 tr *current-transpiler*
		 (fi-sym a) (split-funinfo-and-args args))
    (transpiler-obfuscate-symbol tr n)
    (transpiler-add-function-args tr n a)
	(transpiler-add-function-body tr n (remove 'no-args body :test #'eq))
	(transpiler-add-defined-function tr n)
	`(%defsetq ,n
	           #'(,@(awhen fi-sym
				      `(%funinfo ,!))
			      ,a
                  ,(when *log-functions?*
                     `(log ,(symbol-name n)))
   		          ,@body))))
