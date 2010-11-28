;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun shared-essential-defun (name args &rest body)
  (when *show-definitions*
    (late-print `(defun ,name ,args)))
  (with (n (%defun-name name)
		 tr *current-transpiler*
		 (fi-sym a) (split-funinfo-and-args args))
    (transpiler-obfuscate-symbol tr n)
    (transpiler-add-function-args tr n a)
	(transpiler-add-function-body tr n body)
	(transpiler-add-defined-function tr n)
	`(%defsetq ,name
	           #'(,@(awhen fi-sym
				      `(%funinfo ,!))
			      ,a
                  ,@(when (body-has-noargs-tag? body)
                      '(no-args))
                  (block ,(if (consp name)
                              (second name)
                              name)
                    ,@(when *log-functions?*
                        `((log ,(symbol-name n))))
   		            ,@(body-without-noargs-tag body))))))
