;;;;; nix operating system project ;;;;; lisp compiler
;;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;; 
;;;;; Breaks up nested expressions into lists of assignments.
;;;;; Assign return values to gensyms.
;;;;; 
;;;;; Expressions inside expressions are moved in front of the parent
;;;;; expression, resulting in a head (the moved expressions) and a
;;;;; tail (the parent expression).

(defvar *expexsym-counter* 0)

;; Returns newly created, unique symbol.
(defun expex-sym ()
  (setf *expexsym-counter* (+ 1 *expexsym-counter*))
  (make-symbol (string-concat "~E" (string *expexsym-counter*))))

;; Check if an expression is expandable.
;;
;; Declines atoms and expressions with meta-forms.
(defun expex-able? (x)
  (not (or (atom x)
           (in? (car x) '%funref 'vm-go 'vm-go-nil '%stack '%quote '%transpiler-string))))

;; Check if an expression has a return value.
(defun expex-returnable? (x)
  (not (vm-jump? x)))

(defun expex-make-return-value (e s)
  (with (b (butlast e)
		 l (last e))
   	(if (expex-returnable? (car l))
		(nconc b (if (%setq? (car l))
					(if (%setqret? (car l))
				        `((%setq ~%ret ,(caddar l)))
						`((%setq ,(cadar l) ,(caddar l))  ; Assign to return value.
						  (%setq ~%ret ,(caddar l))))
				    `((%setq ,s ,@(or l '(nil))))))
		e)))

;; Transform moved expression to one which assigns its return
;; value to a gensym.
;;
;; Returns a CONS with the new head expressions in CAR and
;; the replacement symbol for the parent in CDR.
(defun expex-assignment (x)
  (if (not (expex-able? x))
	  (cons nil x)
  	  (with (s (expex-sym))
  	  (if (vm-scope? x)
		  (if (vm-scope-body x)
	          (cons (expex-body (vm-scope-body x) s) ; Special treatment for VM-SCOPE arguments.
				    s)
			  (cons '(nil) s))
  	      (with ((head tail) (expex-expr x))
    	    (cons (nconc head (if (expex-returnable? (car tail))
								  `((%setq ,s ,@tail))
								  tail))
		  	      s))))))

;; Move subexpressions out of a parent.
;;
;; Returns the head of moved expressions and a new parent with
;; replaced arguments.
(defun expex-args (x)
  (with ((pre main) (assoc-splice (mapcar #'expex-assignment x)))
    (values (apply #'nconc pre)
			main)))

(defun expex-argexpand-do (fun args)
  (mapcar #'((x)
			   (if (and (consp x)
						(eq '&rest (car x)))
				   (simple-quote-expand (cdr x))
				   x))
		  (cdrlist (argument-expand (function-arguments (symbol-function fun)) args t))))

(defun expex-argexpand (fun args)
(print `(,fun ,@args))
  (if (and (atom fun)
		   (functionp (symbol-function fun)))
	  (expex-argexpand-do fun args)
	  args))

;; Expands standard expression.
;;
;; The arguments are replaced by gensyms.
(defun expex-std-expr (x)
  (with (argexp (expex-argexpand (car x) (cdr x))
		 (pre newargs) (expex-args argexp))
    (values pre
			(list (cons (car x) newargs)))))

;; Expand expression depending on type.
;;
;; Recurses into LAMBDA-expressions and VM-SCOPEs.
;; VM-SCOPES are removed.
(defun expex-expr (x)
  (if (is-lambda? x)
      (values nil (list `#'(lambda ,(lambda-args x)
						     ,@(expex-body (lambda-body x)))))
      (if (not (expex-able? x))
	      (values nil (list x))
  	      (if (vm-scope? x)
	          (values nil (expex-body (cdr x)))
	          (expex-std-expr x)))))

;; Entry point.
;;
;; Simply concatenates the results of all expression
;; expansions in a body.
(defun expex-list (x)
  (when x
     (with ((head tail) (expex-expr (car x)))
       (nconc head tail (expex-list (cdr x))))))

;; Expand VM-SCOPE body and have the return value of the
;; last expression assigned to a gensym which will replace
;; it in the parent expression.
(defun expex-body (x &optional (s '~%ret))
  (with (e (expex-list x))
   	(expex-make-return-value e s)))

(define-expander 'expex)
(define-expander-macro 'expex %setq (plc val)
  (if (vm-jump? val)
	  val
	  `(%setq ,plc ,val)))

(defun expression-expand (x)
  ;(expander-expand 'expex (expex-list x)))
  (expex-body x))
