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

;; Expand VM-SCOPE body and have the return value of the
;; last expression assigned to a gensym which will replace
;; it in the parent expression.
(defun expex-vmscope (x)
  (with (e (expex-body (vm-scope-body x))
    	 s (expex-sym)
		 l (car (last e)))
   	(cons (aif (butlast e)
			     (nconc ! `((%setq ,s ,l)))
                 `((%setq ,s ,(car e))))
		      s)))

;; Transform moved expression to one which assigns its return
;; value to a gensym.
;;
;; Returns a CONS with the new head expression in CAR and
;; the replacement symbol for the parent in CDR.
(defun expex-assignment (x)
  (if (not (expex-able? x))
	  (cons nil x)
  	  (if (vm-scope? x)
	      (expex-vmscope x) ; Special treatment for VM-SCOPE arguments.
  	      (with (s (expex-sym)
				 (head tail) (expex-toplevel x))
    	    (cons (nconc head
						 (if (vm-jump? (car tail))
							 tail
						     `((%setq ,s ,@tail))))
		  	      s)))))

;; Move subexpressions out of a parent.
;;
;; Returns the head of moved expressions and a new parent with
;; replaced arguments.
(defun expex-args (x)
  (with ((pre main) (assoc-splice (mapcar #'expex-assignment (cdr x))))
    (values (apply #'nconc pre)
			main)))

;; Check if an expression is expandable.
;;
;; Declines expression for meta-forms.
(defun expex-able? (x)
  (not (or (atom x)
           (in? (car x) '%funref 'vm-go 'vm-go-nil '%stack 'quote))))

;; Expands expression.
;;
;; The arguments are replaced by gensyms.
(defun expex-expr (x)
  (with ((pre newargs) (expex-args x))
    (values pre (list (cons (car x) newargs)))))

(defun expex-toplevel (x)
  (if (is-lambda? x)
      (values nil (list `#'(lambda ,(lambda-args (cadr  x))
						     ,@(expex-body (lambda-body (cadr x))))))
      (if (not (expex-able? x))
	      (values nil (list x))
  	      (if (vm-scope? x)
	          (values nil (expex-body (cdr x)))
	          (expex-expr x)))))

;; Entry point.
;;
;; Simply concatenates heads and tails.
(defun expex-body (x)
  (when x
     (with ((head tail) (expex-toplevel (car x)))
       (nconc head tail (expex-body (cdr x))))))

(define-expander 'expex)
(define-expander-macro 'expex %setq (plc val)
  (if (vm-jump? val)
	  val
	  `(%setq ,plc ,val)))

(defun expression-expand (x)
  (expander-expand 'expex (expex-body x)))
