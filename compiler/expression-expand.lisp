;;;;; TRE compiler
;;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;; 
;;;;; Breaks up nested expressions into lists of assignments.
;;;;; Assign return values to gensyms.
;;;;; 
;;;;; Expressions inside expressions are moved in front of the parent
;;;;; expression, resulting in a head (the moved expressions) and a
;;;;; tail (the parent expression).

(defvar *expexsym-counter* 0)

(defstruct expex
  ; Callback to check if an object is a function.
  (function? (fn functionp (symbol-value _)))

  ; Callback to get the argument definition of a function.
  (function-arguments #'function-arguments)

  ; Callback to collect used functions.
  (function-collector #'((fun args)))

  ; Callback to collect used variables.
  (variable-collector #'((var)))

  (plain-arg-fun? #'((var))))

;; Returns new unique symbol.
(defun expex-sym ()
  (setf *expexsym-counter* (+ 1 *expexsym-counter*))
  (make-symbol (string-concat "~E" (string *expexsym-counter*))))

(defun expex-sym? (x)
  (and (atom x)
       (string= "~E" (subseq (symbol-name x) 0 2))))

(defun expex-collect-variables (ex lst)
  (mapcar (fn (when (symbolp _)
				(funcall (expex-variable-collector ex) _)))
		  lst))

;; Check if an expression is expandable.
;;
;; Declines atoms and expressions with meta-forms.
(defun expex-able? (ex x)
  (not (or (atom x)
           (in? x. '%stack
				   'vm-go 'vm-go-nil
				   '%transpiler-native '%transpiler-string
				   '%var
				   '%no-expex))))

;; Check if an expression is inline.
;;
;; These expressions are not moved out, but their arguments are expanded.
(defun expex-inline? (ex x)
  (and (consp x)
       (in? x. '%slot-value)))

;; Check if an expression has a return value.
(defun expex-returnable? (ex x)
  (not (or (vm-jump? x)
		   (and (consp x)
				(eq '%var x.)))))

(defun expex-assignment-inline (ex x)
  (with ((p a) (expex-args ex .x))
	(cons p
		  (cons x. a))))

(defun expex-assignment-vm-scope (ex x)
  (let s (expex-sym)
    (aif (vm-scope-body x)
         (cons (append `((%var ,s))
		               (expex-body ex ! s))
		       s)
	     (cons nil nil))))

(defun expex-assignment-std (ex x)
  (let s (expex-sym)
    (with ((head tail) (expex-expr ex x))
      (cons (append `((%var ,s))
					head
		    		(if (expex-returnable? ex tail.)
		        		`((%setq ,s ,@tail))
			    		tail))
  	        s))))

;; Transform moved expression to one which assigns its return
;; value to a gensym.
;;
;; Returns a CONS with the new head expressions in CAR and
;; the replacement symbol for the parent in CDR.
(defun expex-assignment (ex x)
  (if
	(expex-inline? ex x)
	  (expex-assignment-inline ex x)
	(not (expex-able? ex x))
      (cons nil x)
    (vm-scope? x)
	  (expex-assignment-vm-scope ex x)
	(expex-assignment-std ex x)))

;; Move subexpressions out of a parent.
;;
;; Returns the head of moved expressions and a new parent with
;; replaced arguments.
(defun expex-args (ex x)
  (with ((pre main) (assoc-splice (mapcar (fn expex-assignment ex _) x)))
    (values (apply #'append pre)
			main)))

(defun expex-expandable-args? (ex fun argdef)
  (or (eq '%%no-argexp argdef)
	  (funcall (expex-plain-arg-fun? ex) fun)))

(defun expex-argexpand-do (ex fun args)
  (funcall (expex-function-collector ex) fun args)
  (let argdef (funcall (expex-function-arguments ex) fun)
    (if (expex-expandable-args? ex fun argdef)
	    args
        (argument-expand-compiled-values fun
										 argdef
								         args))))

(defun expex-argexpand (ex fun args)
  (if (and (atom fun)
		   (funcall (expex-function? ex) fun))
	  (expex-argexpand-do ex fun args)
	  args))

;; Expands standard expression.
;;
;; The arguments are replaced by gensyms.
(defun expex-std-expr (ex x)
  (with (argexp (expex-argexpand ex x. .x)
		 (pre newargs) (expex-args ex (cons x. argexp)))
    (expex-collect-variables ex x)
    (values pre (list newargs))))

;; Expand expression depending on type.
;;
;; Recurses into LAMBDA-expressions and VM-SCOPEs.
;; Removes VM-SCOPEs.
(defun expex-expr (ex x)
  (if
	(lambda? x)
      (values nil (list `#'(lambda ,(lambda-args x)
						     ,@(expex-body ex (lambda-body x)))))
    (not (expex-able? ex x))
      (values nil (list x))
    (vm-scope? x)
	  (values nil (expex-body ex (vm-scope-body x)))
    (expex-std-expr ex x)))

;; Entry point.
;;
;; Simply concatenates the results of all expression
;; expansions in a body.
(defun expex-list (ex x)
  (when x
	(if (expex-able? ex x.)
        (with ((head tail) (expex-expr ex x.))
          (append head tail (expex-list ex .x)))
		(cons x. (expex-list ex .x)))))

(defun expex-make-return-value (ex e s)
  (with (b  (butlast e)
		 l  (last e)
		 la l.)
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
  (unless x	; Encapsulate NIL.
	(setf x '((identity nil))))
  (with (e (expex-list ex x))
   	(expex-make-return-value ex e s)))

(defun expression-expand (ex x)
  (when x
    (expex-body ex (if (vm-scope? x)
					   (vm-scope-body x)
					   x))))
