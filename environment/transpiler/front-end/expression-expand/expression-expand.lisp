;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

(defvar *current-expex* nil)
(defvar *expex-funinfo* nil)
(defvar *expex-warn?* t)

;;;; SYMBOLS

(defvar *expexsym-counter* 0)

(defun expex-sym ()
  (alet ($ '~E (1+! *expexsym-counter*))
    (? (& (eq ! (symbol-value !))
          (not (symbol-function !)))
       !
       (expex-sym))))

;;;; GUEST CALLBACKS

(defun expex-guest-filter-expr (ex x)
  (funcall (expex-expr-filter ex) x))

(defun expex-guest-filter-setter (ex x)
  (funcall (expex-setter-filter ex) x))

(defun expex-guest-filter-arguments (ex x)
  (filter [funcall (expex-argument-filter ex) _] x))

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
    (| (function? x)
       (keyword? x)
       (member x (transpiler-predefined-symbols tr) :test #'eq)
       (in? x nil t '~%ret 'this)
       (transpiler-imported-variable? tr x)
       (transpiler-defined-variable tr x)
       (transpiler-macro? tr x)
       (transpiler-host-variable? tr x))))

(defun expex-symbol-defined? (x)
  (| (funinfo-in-this-or-parent-env? *expex-funinfo* x)
     (expex-internal-symbol? x)
     (transpiler-late-symbol? *current-transpiler* x)))

(defun expex-warn (x)
  (& *expex-warn?*
     (symbol? x)
     (not (expex-symbol-defined? x)
          (transpiler-can-import? *current-transpiler* x))
     (error "symbol ~A is not defined in function ~A.~%"
            (symbol-name x)
            (funinfo-get-name *expex-funinfo*))))

;;;; PREDICATES

;; Check if an expression is expandable.
;;
;; Rejects atoms and expressions with meta-forms.
(defun expex-able? (ex x)
  (| (& (expex-move-lexicals? ex)
        (atom x)
        (not (eq '~%ret x))
        (funinfo-in-parent-env? *expex-funinfo* x)
        (not (funinfo-in-toplevel-env? *expex-funinfo* x)))
     (not (| (atom x)
             (function-ref-expr? x)
             (in? x. '%%vm-go '%%vm-go-nil '%%vm-go-not-nil '%transpiler-native '%transpiler-string '%quote)))))

;; Check if arguments to a function should be expanded.
(defun expex-expandable-args? (ex fun argdef)
  (not (funcall (expex-plain-arg-fun? ex) fun)))

;;;; ARGUMENT EXPANSION

;; XXX this sucks blood out of stones. Should have proper macro expansion
;; instead.
(defun expex-convert-quotes (x)
  (filter [? (quote? _)
		     `(%quote ,._.)
			 _]
		  x))

;; Expand arguments to function.
(defun expex-argexpand-0 (ex fun args)
  (dolist (i args)
    (expex-warn i))
  (funcall (expex-function-collector ex) fun args)
  (let argdef (| (funinfo-get-local-function-args *expex-funinfo* fun)
                 (current-transpiler-function-arguments fun))
	(? (expex-expandable-args? ex fun argdef)
   	   (expex-argument-expand fun argdef (? (& (not (in-cps-mode?))
                                               (transpiler-cps-function? *current-transpiler* fun))
                                            .args
                                            args))
	   args)))

(defvar already-printed? nil)

;; Expand arguments if they are passed to a function.
(defun expex-argexpand (ex x)
  (with (new? (%new? x)
		 fun  (? new? .x. x.)
		 args (? new? ..x .x))
	`(,@(& new? '(%new))
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
  (& (lambda-expr? x)
     (funinfo-needs-cps? (get-lambda-funinfo x))))

(defun expex-move-arg-std (ex x)
  (with (s                (expex-funinfo-env-add)
    	 (moved new-expr) (expex-expr ex x))
      (& (lambda-expression-needs-cps? x)
         (transpiler-add-cps-function *current-transpiler* s))
      (cons (append moved
		    		(? (has-return-value? new-expr.)
		        	   (expex-make-%setq ex s new-expr.)
			    	   new-expr))
  	        s)))

(defun expex-move-arg-atom (ex x)
  (let s (expex-funinfo-env-add)
    (cons (expex-make-%setq ex s x) s)))

(defun expex-move-arg (ex x)
  (?
	(not (expex-able? ex x))       (cons nil x)
    (atom x)                       (expex-move-arg-atom ex x)
	(funcall (expex-inline? ex) x) (expex-move-arg-inline ex x)
    (%%vm-scope? x)                (expex-move-arg-vm-scope ex x)
	(expex-move-arg-std ex x)))

(defun expex-filter-and-move-args (ex x)
  (with ((moved new-expr) (assoc-splice (filter [expex-move-arg ex _] (expex-guest-filter-arguments ex x))))
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

(defun expex-lambda (ex x)
  (with-temporary *expex-funinfo* (get-lambda-funinfo x)
    (values nil (list `(function ,@(awhen (lambda-name x) (list !))
					             (,@(lambda-head x)
				         ,@(expex-body ex (lambda-body x))))))))

(defun expex-var (x)
  (funinfo-env-add *expex-funinfo* .x.)
  (values nil nil))

(defun expex-cps (x)
  (& (| (%setq? x)
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

(defun %setq-cps-mode? (x)
  (& (%setq? x)
     (eq '%cps-mode (%setq-place x))))

(defun expex-%setq-cps-mode (x)
  (= *transpiler-except-cps?* (not (%setq-value x)))
  (values nil nil))

(defun expex-expr-%setq (ex x)
  (with (plc (%setq-place x)
         val (peel-identity (%setq-value x)))
    (let-when fun (& (cons? val) val.)
      (| (symbol? fun) (cons? fun)
         (error "function must be a symbol or expression: misplaced ~A~%" x)))
      (with ((moved new-expr) (expex-move-args ex (list val)))
        (values moved (expex-make-%setq ex plc new-expr.)))))

(defun expex-expr-std (ex x)
  (with ((moved new-expr) (expex-move-args ex (expex-argexpand ex x)))
    (values moved (list new-expr))))

(defun expex-expr (ex expr)
  (awhen (& (cons? expr) (cpr expr))
    (= *default-listprop* !))
  (let x (expex-guest-filter-expr ex expr)
    (expex-cps x)
    (?
      (%%vm-go-nil? x)         (expex-vm-go-nil ex x)
      (%%vm-go-not-nil? x)     (expex-vm-go-not-nil ex x)
	  (%var? x)                (expex-var x)
	  (lambda? x)              (expex-lambda ex x)
      (not (expex-able? ex x)) (values nil (list x))
      (%%vm-scope? x)          (values nil (expex-body ex (%%vm-scope-body x)))
      (%setq-cps-mode? x)      (expex-%setq-cps-mode x)
      (%setq? x)               (expex-expr-%setq ex x)
      (expex-expr-std ex x))))

;;;; BODY EXPANSION

(defun expex-force-%setq (ex x)
  (| (& (metacode-expression-only x) (list x))
     (expex-make-%setq ex '~%ret x)))

(defun expex-copy-%setq (ex x s)
  `(,x.
    ,@(expex-make-%setq ex s (cadr x.))))

(defun expex-make-return-value (ex s x)
  (let last (last x)
   	(? (has-return-value? last.)
	   (append (butlast x)
			   (? (%setq? last.)
				  (? (eq s (cadr last.))
                     (expex-guest-filter-setter ex last.)
				     (expex-copy-%setq ex last s))
				  (expex-make-%setq ex s last.)))
		x)))

(defun expex-atom-to-identity-expr (x)
  (? (& (atom x)
        (not (number? x)))
	 `(identity ,x)
	 x))

(defun expex-save-atoms (x)
  (filter #'expex-atom-to-identity-expr x))

(defun expex-list (ex x)
  (mapcan [with ((moved new-expr) (expex-expr ex _))
            (append moved (mapcan [expex-force-%setq ex _] new-expr))]
          x))

(defun expex-body (ex x &optional (s '~%ret))
  (expex-make-return-value ex s (expex-list ex (expex-save-atoms (list-without-noargs-tag x)))))

;;;; TOPLEVEL

(defun expression-expand (ex x)
  (& x
	 (with-temporary *current-expex* ex
	   (with-temporary *expex-funinfo* (transpiler-global-funinfo *current-transpiler*)
         (expex-body ex x)))))
