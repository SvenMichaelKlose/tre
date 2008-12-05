;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

(defmacro define-c-std-macro (name args body)
  `(define-transpiler-std-macro *c-transpiler* ,name ,args ,body))

(define-c-std-macro defun (name args &rest body)
  (progn
	(unless (in? name 'apply)
	  (acons! name args (transpiler-function-args tr)))
    `(%setq ,name
		    #'(,args
    		    ,@body))))

(define-c-std-macro defmacro (name args &rest body)
  (progn
	(eval (car (macroexpand `(define-c-std-macro ,name ,args ,@body))))
    nil))

(define-c-std-macro defvar (name val)
  `(%setq ,name ,val))
