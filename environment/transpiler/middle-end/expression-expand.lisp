;;;;; TRE compiler
;;;;; Copyright (c) 2006-2010 Sven Klose <pixel@copei.de>
;;;;; 
;;;;; Expression-expander
;;;;;
;;;;; Breaks up nested expressions. The result is a pure list of
;;;;; assignments to temporary variables.

(defvar *expex-funinfo* nil)
(defvar *expex-warn?* nil)

;;;; CONFIGURATION

(defstruct expex
  (transpiler nil)

  ; Callback to check if an object is a function.
  (function? (fn functionp (symbol-value _)))

  ; Callback to get the argument definition of a function.
  (function-arguments #'function-arguments)

  ; Callback to collect used functions.
  (function-collector #'((fun args)))

  ; Callback to collect used variables.
  (argument-filter #'((var) var))

  (setter-filter #'((var) var))

  (expr-filter #'((var) var))

  (plain-arg-fun? #'((var)))

  (inline? #'((x))))

;;;; SYMBOLS

(defvar *expexsym-counter* 0)

;; Returns new unique symbol.
(defun expex-sym ()
  (setf *expexsym-counter* (+ 1 *expexsym-counter*))
  (make-symbol (string-concat "~E" (string *expexsym-counter*))))

(defun expex-sym? (x)
  (and (atom x)
       (string= "~E" (subseq (symbol-name x) 0 2))))

;;;; GUEST CALLBACKS

(defun expex-guest-filter-expr (ex x)
  (funcall (expex-expr-filter ex) x))

(defun expex-guest-filter-setter (ex x)
  (funcall (expex-setter-filter ex) x))

(defun expex-guest-filter-arguments (ex x)
  (mapcar (fn (funcall (expex-argument-filter ex) _))
		  x))

;;;; FUNINFO HELPERS FOR GUEST

(defun expex-in-env? (x)
  (and (atom x)
       (funinfo-in-this-or-parent-env? *expex-funinfo* x)))

(defun expex-global-variable? (x)
  (and (atom x)
       (not (expex-in-env? x))
       (global-variable? x)))

(defun expex-funinfo-env-add ()
  (let s (expex-sym)
    (aif *expex-funinfo*
      (funinfo-env-add ! s)
	  (error "expression-expander: FUNINFO missing. Cannot make GENSYM"))
	s))

(defun expex-stack-locals? (ex)
  (and *expex-funinfo* ; Is set if we're inside a function.
	   (transpiler-stack-locals? (expex-transpiler ex))))

(defun expex-warn (x)
  (and *expex-warn?*
	   (symbolp x)
	   (not (or (functionp x)
				(keywordp x)
				(in? x nil t '~%ret 'this)
	   			(funinfo-in-this-or-parent-env? *expex-funinfo* x)
				(assoc x *variables*)
	       		(expander-has-macro? (transpiler-std-macro-expander *current-transpiler*) x)
		       	(expander-has-macro? (transpiler-macro-expander *current-transpiler*) x)))
	   (warn "symbol ~A is not defined in function ~A.~%"
			 (symbol-name x) (funinfo-get-name *expex-funinfo*))))

;;;; PREDICATES

;; Check if an expression is expandable.
;;
;; Declines atoms and expressions with meta-forms.
(defun expex-able? (ex x)
  (not (or (atom x)
		   (function-ref-expr? x)
           (in? x. 'vm-go 'vm-go-nil
				   '%transpiler-native '%transpiler-string
				   '%quote))))

;; Check if an expression has a return value.
(defun expex-returnable? (ex x)
  (not (or (vm-jump? x)
		   (%var? x))))

;; Check if arguments to a function should be expanded.
(defun expex-expandable-args? (ex fun argdef)
  (not (funcall (expex-plain-arg-fun? ex) fun)))

;;;; ARGUMENT EXPANSION

;; XXX this sucks blood out of stones. Should have proper macro expansion
;; instead.
(defun expex-convert-quotes (x)
  (mapcar (fn (if (quote? _)
				  `(%quote ,._.)
				  _))
		  x))

;; Expand arguments to function.
(defun expex-argexpand-0 (ex fun args)
  (dolist (i args)
	(expex-warn i))
  (funcall (expex-function-collector ex) fun args)
  (let argdef (funcall (expex-function-arguments ex) fun)
	(if (eq argdef 'builtin)
		args
  	    (if (expex-expandable-args? ex fun argdef)
      	    (argument-expand-compiled-values fun argdef args)
    	    args))))

;; Expand arguments if they are passed to a function.
(defun expex-argexpand (ex x)
  (with (new? (%new? x)
		 fun (if new?
				 .x.
				 x.)
		 args (if new?
				  ..x
				  .x))
	`(,@(when new?
		  (list '%new))
	  ,fun
    	  ,@(if (funcall (expex-function? ex) fun)
	    	    (expex-convert-quotes
		    	    (expex-argexpand-0 ex fun args))
	    	    args))))

;;;;; ARGUMENT VALUE EXPANSION

;; Keep expression in argument but expand its arguments.
(defun expex-move-arg-inline (ex x)
  (with ((p a) (expex-move-args ex x))
	(cons p a)))

;; Move out VM-SCOPE if it contains something. Otherwise keep NIL.
(defun expex-move-arg-vm-scope (ex x)
  (let s (expex-funinfo-env-add)
    (aif (vm-scope-body x)
         (cons (expex-body ex ! s)
		       s)
	     (cons nil nil))))

(defun expex-move-arg-std (ex x)
  (with (s (expex-funinfo-env-add)
    	 (moved new-expr) (expex-expr ex x))
      (cons (append moved
		    		(if (expex-returnable? ex new-expr.)
		        		(list (expex-guest-filter-setter ex
								  `(%setq ,s ,@new-expr)))
			    		new-expr))
  	        s)))

;; Transform moved expression to one which assigns its return
;; value to a gensym.
;;
;; Returns a CONS with the new head expressions in CAR and
;; the replacement symbol for the parent in CDR.
(defun expex-move-arg (ex x)
  (if
	(not (expex-able? ex x))		(cons nil x)
	(funcall (expex-inline? ex) x)	(expex-move-arg-inline ex x)
    (vm-scope? x)					(expex-move-arg-vm-scope ex x)
	(expex-move-arg-std ex x)))

;; Move subexpressions out of a parent.
;;
;; Returns the head of moved expressions and a new parent with
;; replaced arguments.
(defun expex-move-args (ex x)
  (with ((moved new-expr)
			 (assoc-splice (mapcar (fn expex-move-arg ex _)
				        		   (expex-guest-filter-arguments ex x))))
    (values (apply #'append moved)
			new-expr)))

;;;; EXPRESSION EXPANSION

;; Expands standard expression.
;;
;; The arguments are replaced by gensyms.
;; XXX argument conversion by guest.
(defun expex-expr-std (ex x)
  (with ((moved new-expr) (expex-move-args ex
										   (expex-argexpand ex x)))
    (values moved
			(list new-expr))))

;; Expand %SETQ expression.
;;
;; The place to set must not be expanded.
(defun expex-expr-setq (ex x)
  (with ((moved new-expr) (expex-move-args ex ..x))
	(values moved
			(list (expex-guest-filter-setter ex
				      `(%setq ,.x. ,@new-expr))))))

;; Expand LAMBDA
;;
;; Saves its FUNINFO for the guest.
(defun expex-lambda (ex x)
  (with-temporary *expex-funinfo* (get-lambda-funinfo x)
    (values nil
		    (list `#'(,@(lambda-head x)
				         ,@(expex-body ex (lambda-body x)))))))

; Remove %VAR expression and register new FUNINFO variable.
(defun expex-var (x)
  (funinfo-env-add *expex-funinfo* .x.)
  (values nil nil))

;; Expand expression depending on type.
;;
;; Recurses into LAMBDA-expressions and VM-SCOPEs.
;; Removes VM-SCOPEs.
(defun expex-expr (ex expr)
  (let x (expex-guest-filter-expr ex expr)
    (if
	  (%var? x)						(expex-var x)
      (not (expex-able? ex x))		(values nil (list x))
	  (lambda? x)					(expex-lambda ex x)
      (vm-scope? x)					(values nil (expex-body ex (vm-scope-body x)))
      (%setq? x)					(expex-expr-setq ex x)
      (expex-expr-std ex x))))

;;;; BODY EXPANSION

;; Simply concatenates the results of all expression expansions in a body.
(defun expex-force-%setq (ex x)
  (if (or (atom x)
		  (%setq? x)
		  (vm-jump? x)
		  (%var? x))
	  x
	  (expex-guest-filter-setter ex `(%setq ~%ret ,x))))

;; Simply concatenates the results of all expression expansions in a body.
(defun expex-list (ex x)
  (when x
    (with ((moved new-expr) (expex-expr ex x.))
      (append moved
			  (mapcar (fn (expex-force-%setq ex _))
					  new-expr)
			  (expex-list ex .x)))))

;; Make second, following %SETQ expression that assigns to the
;; desired return-place.
(defun expex-make-setq-copy (ex x s)
  (if (eq s (second x.))
      x
      `(,x.
	    ,(expex-guest-filter-setter ex
									`(%setq ,s ,(second x.))))))

;; Make return-value assignment of last expression in body.
(defun expex-make-return-value (ex s x)
  (let last (last x)
   	(if (expex-returnable? ex last.)
		(append (butlast x)
				(if (%setq? last.)
					(if (eq s (second last.))
				        (list (expex-guest-filter-setter ex last.))
						(expex-make-setq-copy ex last s))
				    (list (expex-guest-filter-setter ex
							  `(%setq ,s ,@(or last
									  		   '(nil)))))))
		x)))

(defun expex-save-atoms (x)
  (mapcar (fn if (and (atom _)
					  (not (numberp _)))
				 `(identity ,_)
				 _)
		  (or x
			  (list nil))))

;; Expand VM-SCOPE body and have the return value of the last expression
;; assigned to a gensym which will replace it in the parent expression.
(defun expex-body (ex x &optional (s '~%ret))
  (expex-make-return-value ex s
						   (expex-list ex
									   (expex-save-atoms x))))

;;;; TOPLEVEL

(defun expression-expand (ex x)
  (when x
	(with-temporary *expex-funinfo* *global-funinfo*
      (expex-body ex x))))
