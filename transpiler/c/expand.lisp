;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

;; Define macro that is expanded _before_ standard macros.
(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

;; (FUNCTION symbol | lambda-expression)
;; Add symbol to list of wanted functions or obfuscate arguments of
;; LAMBDA-expression.
(define-c-std-macro function (x)
  (unless x
    (error "FUNCTION expects a symbol or form"))
  (if (atom x)
	  (progn
	    (transpiler-add-wanted-function *c-transpiler* x)
		`(symbol-function (%quote ,x)))
  	  `(function ,x)))

;; (DEFUN ...)
;;
;; Assign function to global variable.
;; XXX This could be generic if there wasn't *JS-TRANSPILER*.
(defun c-essential-defun (name args &rest body)
  (when *show-definitions*
    (print `(defun ,name)))
  (with (n (%defun-name name)
		 tr *c-transpiler*
		 fi-sym (when (eq '%FUNINFO args.)
				  (second args))
		 a (if fi-sym
			   (cddr args)
			   args))
    (transpiler-obfuscate-symbol tr n)
    (transpiler-add-function-args tr n a)
	(transpiler-add-defined-function tr n)
    `(%setq ,n
	        #'(,@(awhen fi-sym
				   `(%funinfo ,!))
			   ,a
   		         ,@(if (and (not *assert*)
		    	            (stringp body.))
				       .body
				       body)))))

(define-c-std-macro defun (name args &rest body)
  (with-gensym g
    (apply #'c-essential-defun name args body)))

(define-c-std-macro defmacro (name &rest x)
  (when *show-definitions*
    (print `(defmacro ,name )))
  (eval (transpiler-macroexpand *c-transpiler*
								`(define-c-std-macro ,name ,@x)))
  nil)

(define-c-std-macro defvar (name val)
  (let tr *c-transpiler*
    (when *show-definitions*
      (print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (error "variable ~A already defined" name))
    (transpiler-add-defined-variable tr name)
    (transpiler-obfuscate-symbol tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-c-std-macro cons (a d)
  `(_trelist_get ,a ,d))

;; Translate FUNCTION-expr functions.
(define-c-std-macro %setq (&rest x)
  (if (and (consp (second x))
		   (function-expr? (first (second x))))
	  `(%setq ,x. (,(second (second x))
				   ,@(cdr (second x))))
	  `(%setq ,@x)))
