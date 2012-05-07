;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *allow-redefinitions?* nil)

(defun redef-warn (&rest args)
  (apply (? *allow-redefinitions?* #'warn #'error) args))

(defun shared-defun (name args &rest body)
  (awhen (transpiler-current-package *current-transpiler*)
    (setf name (make-symbol (symbol-name name) !)))
  (when *show-definitions*
    (late-print `(defun ,name ,args)))
  (with (n (%defun-name name)
         tr *current-transpiler*
		 (fi-sym a) (split-funinfo-and-args args))
    (when (transpiler-defined-function tr name)
      (redef-warn "redefinition of function ~A.~%" name))
	(transpiler-add-defined-function tr n)
    (transpiler-add-function-args tr n a)
	(transpiler-add-function-body tr n body)
	`((%defsetq ,name
	           #'(,@(awhen fi-sym
				      `(%funinfo ,!))
			      ,a
                  ,@(when (body-has-noargs-tag? body)
                      '(no-args))
                  (block ,(? (cons? name) .name. name)
                    ,@(when *log-functions?*
                        `((when (function? raw-log)
                            (%%%log ,(symbol-name n)))))
   		            ,@(body-without-noargs-tag body))))
     ,@(when (and *have-compiler?* (not (transpiler-memorize-sources? *current-transpiler*)))
         `((%setq *defined-functions* (cons ,(list 'quote n) *defined-functions*))))
     ,@(when (transpiler-save-sources? tr)
         (apply #'transpiler-add-obfuscation-exceptions *current-transpiler* (collect-symbols (cons args body)))
         (? (transpiler-memorize-sources? *current-transpiler*)
            (and (acons! name (cons args body) (transpiler-memorized-sources *current-transpiler*))
                 nil)
            `((%setq (slot-value ,name '__source) ,(list 'quote (cons args (unless (transpiler-save-argument-defs-only? tr)
                                                                             (or (cddr (assoc name *function-sources* :test #'eq))
                                                                                 body)))))))))))
