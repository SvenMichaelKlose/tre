;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun shared-essential-defun (name args &rest body)
  (when *show-definitions*
    (late-print `(defun ,name ,args)))
  (when (transpiler-defined-function tr name)
    (warn "Redefinition of function ~A" name))
  (with (n (%defun-name name)
		 tr *current-transpiler*
		 (fi-sym a) (split-funinfo-and-args args))
	(transpiler-add-defined-function tr n)
    (transpiler-add-function-args tr n a)
	(transpiler-add-function-body tr n body)
	`(%defsetq ,name
	           #'(,@(awhen fi-sym
				      `(%funinfo ,!))
			      ,a
                  ,@(when (body-has-noargs-tag? body)
                      '(no-args))
                  (block ,(? (cons? name)
                             .name.
                             name)
                    ,@(when *log-functions?*
                        `((log ,(symbol-name n))))
   		            ,@(body-without-noargs-tag body))))))
