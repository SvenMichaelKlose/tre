;;;;; nix operating system project
;;;;; lisp compiler
;;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;; 
;;;;; Breaks up nested expressions into lists of assignments.
;;;;; Assign return values to gensyms.
;;;;; 
;;;;; Expressions inside expressions are moved in front of the parent
;;;;; expression, resulting in a head (the moved expressions) and a
;;;;; tail (the parent expression).

(defvar *expexsym-counter* 0)

(defstruct expex
  (function? #'((x)
				  (functionp (symbol-value x))))
  (function-arguments #'function-arguments)
  (function-collector #'((fun args))))

;; Returns newly created, unique symbol.
(defun expex-sym ()
  (setf *expexsym-counter* (+ 1 *expexsym-counter*))
  (make-symbol (string-concat "~E" (string *expexsym-counter*))))

;; Check if an expression is expandable.
;;
;; Declines atoms and expressions with meta-forms.
(defun expex-able? (ex x)
  (not (or (atom x)
           (in? (car x) '%stack ;'%quote
						'vm-go 'vm-go-nil
						'%transpiler-native '%transpiler-string
						'%var
						'%funref '%no-expex))))

;; Check if an expression is inline.
;;
;; These expressions are not moved out, but their arguments are expanded.
(defun expex-inline? (ex x)
  (and (consp x)
       (in? (car x) '%slot-value)))

;; Check if an expression has a return value.
(defun expex-returnable? (ex x)
  (not (or (vm-jump? x)
		   (and (consp x)
				(eq '%var (car x))))))

;; Transform moved expression to one which assigns its return
;; value to a gensym.
;;
;; Returns a CONS with the new head expressions in CAR and
;; the replacement symbol for the parent in CDR.
(defun expex-assignment (ex x)
  (if (expex-inline? ex x)
	  (with ((p a) (expex-args ex (cdr x)))
		(cons p (cons (car x) a)))
	  (if (not (expex-able? ex x))
	      (cons nil x)
  	      (with (s (expex-sym))
  	        (if (vm-scope? x)
		        (if (vm-scope-body x)
	                (cons (expex-body ex (vm-scope-body x) s) ; Special treatment for VM-SCOPE arguments.
				          s)
			        (cons '(nil) s))
  	            (with ((head tail) (expex-expr ex x))
    	          (cons (append head (if (expex-returnable? ex (car tail))
								         `((%setq ,s ,@tail))
								         tail))
		  	            s)))))))

;; Move subexpressions out of a parent.
;;
;; Returns the head of moved expressions and a new parent with
;; replaced arguments.
(defun expex-args (ex x)
  (with ((pre main) (assoc-splice (mapcar #'((x)
											   (expex-assignment ex x))
										  x)))
    (values (apply #'append pre)
			main)))

(defun expex-argexpand-do (ex fun args)
  (funcall (expex-function-collector ex) fun args)
  (argument-expand-compiled-values fun (funcall (expex-function-arguments ex) fun) args))

(defun expex-argexpand (ex fun args)
  (if (and (atom fun)
		   (funcall (expex-function? ex) fun))
	  (expex-argexpand-do ex fun args)
	  args))

;; Expands standard expression.
;;
;; The arguments are replaced by gensyms.
(defun expex-std-expr (ex x)
  (with (argexp (expex-argexpand ex (car x) (cdr x))
		 (pre newargs) (expex-args ex (cons (car x) argexp)))
    (values pre (list newargs))))

;; Expand expression depending on type.
;;
;; Recurses into LAMBDA-expressions and VM-SCOPEs.
;; VM-SCOPES are removed.
(defun expex-expr (ex x)
  (if (is-lambda? x)
      (values nil (list `#'(lambda ,(lambda-args x)
						     ,@(expex-body ex (lambda-body x)))))
      (if (not (expex-able? ex x))
	      (values nil (list x))
  	      (if (vm-scope? x)
	          (values nil (expex-body ex (cdr x)))
	          (expex-std-expr ex x)))))

;; Entry point.
;;
;; Simply concatenates the results of all expression
;; expansions in a body.
(defun expex-list (ex x)
  (when x
	(if (expex-able? ex (car x))
        (with ((head tail) (expex-expr ex (car x)))
          (append head tail (expex-list ex (cdr x))))
		(cons (car x) (expex-list ex (cdr x))))))

(defun expex-make-return-value (ex e s)
  (with (b  (butlast e)
		 l  (last e)
		 la (car l))
   	(if (expex-returnable? ex la)
		(append b (if (%setq? la)
					  (if (eq s (second la))
				          l
						  `(,la
						    (%setq ,s ,(second la))))
				      `((%setq ,s ,@(or l '(nil))))))
		e)))

;; Expand VM-SCOPE body and have the return value of the
;; last expression assigned to a gensym which will replace
;; it in the parent expression.
(defun expex-body (ex x &optional (s '~%ret))
  (when (not x)	; Always return NIL.
	(setf x '((identity nil))))
  (with (e (expex-list ex x))
   	(expex-make-return-value ex e s)))

(defun expression-expand (ex x)
  (expex-body ex x))
