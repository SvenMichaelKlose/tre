;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *allow-redefinitions?* nil)

(defun redef-warn (&rest args)
  (apply (? *allow-redefinitions?* #'warn #'error) args))

(defun apply-current-package (x)
  (!? (transpiler-current-package *current-transpiler*)
      (make-symbol (symbol-name x) !)
      x))

(defun shared-defun (name args &rest body)
  (= name (apply-current-package name))
  (when *show-definitions*
    (late-print `(defun ,name ,args)))
  (with (tr *current-transpiler*
		 (fi-sym a) (split-funinfo-and-args args))
    (when (transpiler-defined-function tr name)
      (redef-warn "redefinition of function ~A.~%" name))
	(transpiler-add-defined-function tr name a body)
	`((%defsetq ,name
	            #'(,@(awhen fi-sym
				      `(%funinfo ,!))
			       ,a
                   ,@(when (body-has-noargs-tag? body)
                       '(no-args))
                   (block ,name
                     ,@(and *log-functions?*
                            (not (eq '%%%log name))
                            `((when (function? raw-log)
                                (%%%log ,(symbol-name name)))))
   		             ,@(body-without-noargs-tag body))))
     ,@(when (and *have-compiler?* (not (transpiler-memorize-sources? *current-transpiler*)))
         `((%setq *defined-functions* (cons ,(list 'quote name) *defined-functions*))))
     ,@(when (transpiler-save-sources? tr)
         (apply #'transpiler-add-obfuscation-exceptions *current-transpiler* (collect-symbols (list name args body)))
         (? (transpiler-memorize-sources? *current-transpiler*)
            (and (acons! name (cons args body) (transpiler-memorized-sources *current-transpiler*))
                 nil)
            `((%setq (slot-value ,name '__source) ,(let source (assoc-value name *function-sources* :test #'eq)
                                                     (list 'quote (cons (or source. args)
                                                                        (unless (transpiler-save-argument-defs-only? tr)
                                                                          (or .source body))))))))))))
