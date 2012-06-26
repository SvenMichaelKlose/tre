;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

(defvar *current-expex* nil)
(defvar *expex-funinfo* nil)
(defvar *expex-warn?* t)

;;;; SYMBOLS

(defvar *expexsym-counter* nil)

(defun expex-sym ()
  ($ '~E (1+! *expexsym-counter*)))

;;;; GUEST CALLBACKS

(defun expex-guest-filter-expr (ex x)
  (funcall (expex-expr-filter ex) x))

(defun expex-guest-filter-setter (ex x)
  (funcall (expex-setter-filter ex) x))

(defun expex-guest-filter-arguments (ex x)
  (mapcar (fn funcall (expex-argument-filter ex) _) x))

;;;; UTILS

(defun expex-make-%setq (ex plc val)
  (expex-guest-filter-setter ex `(%setq ,plc ,(peel-identity val))))

(defun expex-funinfo-env-add ()
  (let s (expex-sym)
    (!? *expex-funinfo*
        (funinfo-env-add ! s)
	    (error "expression-expander: FUNINFO missing. Cannot make GENSYM"))
	s))

(defun expex-internal-symbol? (x)
  (let tr *current-transpiler*
    (or (function? x)
	    (keyword? x)
	    (member x (transpiler-predefined-symbols tr) :test #'eq)
	    (in? x nil t '~%ret 'this)
	    (transpiler-imported-variable? tr x)
	    (transpiler-defined-variable tr x)
	    (transpiler-macro? tr x)
        (assoc x *variables* :test #'eq))))

(defun expex-symbol-defined? (x)
  (or (funinfo-in-this-or-parent-env? *expex-funinfo* x)
      (expex-internal-symbol? x)
      (transpiler-late-symbol? *current-transpiler* x)))

(defun expex-warn (x)
  (and *expex-warn?*
	   (symbol? x)
	   (not (expex-symbol-defined? x))
       (not (transpiler-can-import? *current-transpiler* x))
	   (error "symbol ~A is not defined in function ~A.~%"
			  (symbol-name x) (funinfo-get-name *expex-funinfo*))))

;;;; PREDICATES

;; Check if an expression is expandable.
;;
;; Rejects atoms and expressions with meta-forms.
(defun expex-able? (ex x)
  (or (and (expex-move-lexicals? ex)
           (atom x)
           (not (in? x '~%ret))
           (funinfo-in-parent-env? *expex-funinfo* x)
           (not (funinfo-in-toplevel-env? *expex-funinfo* x)))
      (not (or (atom x)
		       (function-ref-expr? x)
               (in? x. '%%vm-go '%%vm-go-nil '%%vm-go-not-nil '%transpiler-native '%transpiler-string '%quote)))))

;; Check if an expression has a return value.
(defun expex-returnable? (ex x)
  (not (or (vm-jump? x)
		   (%var? x))))

;; Check if arguments to a function should be expanded.
(defun expex-expandable-args? (ex fun argdef)
  (not (or (eq argdef 'builtin)
           (funcall (expex-plain-arg-fun? ex) fun))))

;;;; ARGUMENT EXPANSION

;; XXX this sucks blood out of stones. Should have proper macro expansion
;; instead.
(defun expex-convert-quotes (x)
  (mapcar (fn ? (quote? _)
			    `(%quote ,._.)
			    _)
		  x))

;; Expand arguments to function.
(defun expex-argexpand-0 (ex fun args)
  (dolist (i args)
    (expex-warn i))
  (funcall (expex-function-collector ex) fun args)
  (let argdef (or (funinfo-get-local-function-args *expex-funinfo* fun)
                  (funcall (expex-function-arguments ex) fun))
	(? (expex-expandable-args? ex fun argdef)
   	   (expex-argument-expand fun argdef (? (and (not (in-cps-mode?))
                                                 (transpiler-cps-function? *current-transpiler* fun))
                                            .args
                                            args))
	   args)))

(defvar already-printed? nil)

;; Expand arguments if they are passed to a function.
(defun expex-argexpand (ex x)
  (with (new? (%new? x)
		 fun (? new? .x.  x.)
		 args (? new? ..x .x))
	`(,@(when new?
		  '(%new))
	  ,fun ,@(? (funcall (expex-functionp ex) fun)
	    	    (expex-convert-quotes (expex-argexpand-0 ex fun args))
	    	    args))))

;;;;; ARGUMENT VALUE EXPANSION

(defun expex-move-arg-inline (ex x)
  (with ((p a) (expex-move-args ex x))
	(cons p a)))

(defun expex-move-arg-vm-scope (ex x)
  (!? (%%vm-scope-body x)
      (let s (expex-funinfo-env-add)
        (cons (expex-body ex ! s) s))
	  (cons nil nil)))

(defun lambda-expression-needs-cps? (x)
  (and (lambda-expr? x)
       (funinfo-needs-cps? (get-lambda-funinfo x))))

(defun expex-move-arg-std (ex x)
  (with (s (expex-funinfo-env-add)
    	 (moved new-expr) (expex-expr ex x))
      (when (lambda-expression-needs-cps? x)
        (transpiler-add-cps-function *current-transpiler* s))
      (cons (append moved
		    		(? (expex-returnable? ex new-expr.)
		        	   (expex-make-%setq ex s new-expr.)
			    	   new-expr))
  	        s)))

(defun expex-move-arg-atom (ex x)
  (let s (expex-funinfo-env-add)
    (cons (expex-make-%setq ex s x) s)))

(defun expex-move-arg (ex x)
  (?
	(not (expex-able? ex x)) (cons nil x)
    (atom x) (expex-move-arg-atom ex x)
	(funcall (expex-inline? ex) x) (expex-move-arg-inline ex x)
    (%%vm-scope? x) (expex-move-arg-vm-scope ex x)
	(expex-move-arg-std ex x)))

(defun expex-filter-and-move-args (ex x)
  (with ((moved new-expr) (assoc-splice (mapcar (fn expex-move-arg ex _) (expex-guest-filter-arguments ex x))))
    (values (apply #'append moved) new-expr)))

(defun expex-move-slot-value (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex (list .x.)))
    (values moved `(%slot-value ,new-expr. ,..x.))))

(defun expex-move-args-0 (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex x))
    (values moved new-expr)))

;; Move subexpressions out of a parent.
;;
;; Returns the head of moved expressions and a new parent with
;; replaced arguments.
(defun expex-move-args (ex x)
  (? (%slot-value? x)
	 (expex-move-slot-value ex x)
	 (expex-move-args-0 ex x)))

;;;; EXPRESSION EXPANSION

(defun expex-expr-std (ex x)
  (with ((moved new-expr) (expex-move-args ex (expex-argexpand ex x)))
    (values moved (list new-expr))))

(defun expex-expr-setq (ex x)
  (with ((moved new-expr) (expex-move-args ex ..x))
	(values moved (expex-make-%setq ex .x. new-expr.))))

(defun expex-lambda (ex x)
  (with-temporary *expex-funinfo* (get-lambda-funinfo x)
    (values nil
		    (list `(function
					   ,@(awhen (lambda-name x)
						   (list !))
					   (,@(lambda-head x)
				        ,@(expex-body ex (lambda-body x))))))))

(defun expex-var (x)
  (funinfo-env-add *expex-funinfo* .x.)
  (values nil nil))

(defun expex-cps (x)
  (and (or (%setq? x)
            (%set-atom-fun? x))
       (lambda-expression-needs-cps? (%setq-value x))
       (transpiler-add-cps-function *current-transpiler* (%setq-place x))))

(defun expex-vm-go-nil (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex (list .x.)))
    (values moved `((%%vm-go-nil ,@new-expr ,..x.)))))

(defun expex-vm-go-not-nil (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex (list .x.)))
    (values moved `((%%vm-go-not-nil ,@new-expr ,..x.)))))

(defun peel-identity (x)
  (? (identity? x) .x. x))

(defun expex-expr (ex expr)
  (let x (expex-guest-filter-expr ex expr)
    (expex-cps x)
    (?
      (%%vm-go-nil? x) (expex-vm-go-nil ex x)
      (%%vm-go-not-nil? x) (expex-vm-go-not-nil ex x)
	  (%var? x) (expex-var x)
	  (lambda? x) (expex-lambda ex x)
      (not (expex-able? ex x)) (values nil (list x))
      (%%vm-scope? x) (values nil (expex-body ex (%%vm-scope-body x)))
      (and (%setq? x)
           (eq '%cps-mode (%setq-place x))) (progn
                                              (= *transpiler-except-cps?* (not (%setq-value x)))
                                              (print 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC)
                                              (print *transpiler-except-cps?*)
                                              (values nil nil))
      (%setq? x) (with (plc (%setq-place x)
                        val (peel-identity (%setq-value x)))
                   (let-when fun (and (cons? val) val.)
                     (unless (or (symbol? fun)
                                 (cons? fun))
                       (error "function must be a symbol or expression: misplaced ~A~%" x)))
                   (expex-expr-setq ex `(%setq ,plc ,val)))
      (expex-expr-std ex x))))

;;;; BODY EXPANSION

(defun expex-force-%setq (ex x)
  (or (when (metacode-expression-only x)
        (list x))
	  (expex-make-%setq ex '~%ret x)))

(defun expex-copy-%setq (ex x s)
  `(,x.
    ,@(expex-make-%setq ex s (cadr x.))))

(defun expex-make-return-value (ex s x)
  (let last (last x)
   	(? (expex-returnable? ex last.)
	   (append (butlast x)
			   (? (%setq? last.)
				  (? (eq s (cadr last.))
                     (expex-guest-filter-setter ex last.)
				     (expex-copy-%setq ex last s))
				  (expex-make-%setq ex s last.)))
		x)))

(defun expex-atom-to-identity-expr (x)
  (? (and (atom x)
	      (not (number? x)))
	 `(identity ,x)
	 x))

(defun expex-save-atoms (x)
  (mapcar #'expex-atom-to-identity-expr x))

(defun expex-list (ex x)
  (mapcan (fn with ((moved new-expr) (expex-expr ex _))
               (append moved (mapcan (fn expex-force-%setq ex _) new-expr)))
          x))

(defun expex-body (ex x &optional (s '~%ret))
  (expex-make-return-value ex s (expex-list ex (expex-save-atoms (list-without-noargs-tag x)))))

;;;; TOPLEVEL

(defun expression-expand (ex x)
  (when x
    (with-temporary *expexsym-counter* 0
	  (with-temporary *current-expex* ex
	    (with-temporary *expex-funinfo* (transpiler-global-funinfo *current-transpiler*)
          (expex-body ex x))))))
