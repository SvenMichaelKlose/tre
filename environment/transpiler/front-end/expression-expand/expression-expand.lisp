;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

; This pass converts the input into a sequence of statements without
; %%BLOCKs, it expands arguments and moves statements out of
; arguments. Every instruction which is not a jump or tag is forced
; into a %SETQ assignment.


(defun peel-identity (x)
  (? (identity? x) .x. x))

(defun %setq-cps-mode? (x)
  (& (%setq? x)
     (eq '%cps-mode (%setq-place x))))


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
  (+ (? (%setq? val)
        (expex-guest-filter-setter ex val))
     (expex-guest-filter-setter ex `(%setq ,plc ,(? (%setq? val)
                                                    (%setq-place val)
                                                    (peel-identity val))))))

(defun expex-funinfo-var-add ()
  (aprog1 (expex-sym)
    (funinfo-var-add *expex-funinfo* !)))

(defun expex-warn (x)
  (& *expex-warn?*
     (symbol? x)
     (not (transpiler-defined-symbol? *expex-funinfo* x)
          (transpiler-can-import? *transpiler* x))
     (error "symbol ~A is not defined in function ~A.~%"
            (symbol-name x)
            (funinfo-get-name *expex-funinfo*))))


;;;; PREDICATES

(defun expex-able? (ex x)
  (| (& (expex-move-lexicals? ex)
        (atom x)
        (not (eq '~%ret x))
        (funinfo-parent-var? *expex-funinfo* x)
        (not (funinfo-toplevel-var? *expex-funinfo* x)))
     (not (| (atom x)
             (literal-symbol-function? x)
             (in? x. '%%go '%%go-nil '%transpiler-native '%transpiler-string '%quote)))))

(defun expex-expandable-args? (ex fun argdef)
  (| (transpiler-defined-function *transpiler* fun)
     (not (funcall (expex-plain-arg-fun? ex) fun))))


;;;; ARGUMENT EXPANSION

(defun expex-convert-quotes (x)
  (filter [? (quote? _)
		     `(%quote ,._.)
			 _]
		  x))

(defun expex-argexpand-0 (ex fun args)
  (dolist (i args)
    (expex-warn i))
  (funcall (expex-function-collector ex) fun args)
  (let argdef (| (funinfo-get-local-function-args *expex-funinfo* fun)
                 (current-transpiler-function-arguments fun))
	(? (expex-expandable-args? ex fun argdef)
   	   (expex-argument-expand fun argdef args)
	   args)))

(defun expex-argexpand (ex x)
  (with (new? (%new? x)
		 fun  (? new? .x. x.)
		 args (? new? ..x .x))
	`(,@(& new? '(%new))
	  ,fun ,@(? (funcall (expex-functionp ex) fun)
	    	    (expex-convert-quotes (expex-argexpand-0 ex fun args))
	    	    args))))


;;;;; MOVING SINGLE ARGUMENTS

(defun expex-move-atom (ex x)
  (let s (expex-funinfo-var-add)
    (cons (expex-make-%setq ex s x) s)))

(defun expex-move-inline (ex x)
  (with ((p a) (expex-move-args ex x))
	(cons p a)))

(defun expex-move-%%block (ex x)
  (!? (%%block-body x)
      (let s (expex-funinfo-var-add)
        (cons (expex-body ex ! s) s))
	  (cons nil nil)))

(defun expex-move-std (ex x)
  (with (s                (expex-funinfo-var-add)
         (moved new-expr) (expex-expr ex x))
    (& (lambda-expression-needs-cps? x)
       (transpiler-add-cps-function *transpiler* s))
    (cons (+ moved
             (? (has-return-value? new-expr.)
                (expex-make-%setq ex s new-expr.)
                new-expr))
          s)))

(defun expex-move (ex x)
  (?
	(not (expex-able? ex x))       (cons nil x)
    (atom x)                       (expex-move-atom ex x)
	(funcall (expex-inline? ex) x) (expex-move-inline ex x)
    (%%block? x)                   (expex-move-%%block ex x)
	(expex-move-std ex x)))


;;;; MOVING ARGUMENTS

(defun expex-filter-and-move-args (ex x)
  (with ((moved new-expr) (assoc-splice (filter [expex-move ex _] (expex-guest-filter-arguments ex x))))
    (values (apply #'+ moved) new-expr)))

(defun expex-move-slot-value (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex (list .x.)))
    (values moved `(%slot-value ,new-expr. ,..x.))))

(defun expex-move-args-0 (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex x))
    (values moved new-expr)))

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
  (funinfo-var-add *expex-funinfo* .x.)
  (values nil nil))

(defun expex-cps (x)
  (& (| (%setq? x)
        (%set-atom-fun? x))
     (lambda-expression-needs-cps? (%setq-value x))
     (transpiler-add-cps-function *transpiler* (%setq-place x))))

(defun expex-%%go-nil (ex x)
  (with ((moved new-expr) (expex-filter-and-move-args ex (list .x.)))
    (values moved `((%%go-nil ,@new-expr ,..x.)))))

(defun expex-%setq-cps-mode (x)
  (= *transpiler-except-cps?* (not (%setq-value x)))
  (values nil nil))

(defun expex-expr-%setq (ex x)
  (with (plc (%setq-place x)
         val (peel-identity (%setq-value x)))
    (let-when fun (& (cons? val) val.)
      (| (symbol? fun) (cons? fun)
         (error "function must be a symbol or expression: misplaced ~A~%" x)))
    (? (%setq? val)
       (values nil (expex-body ex `(,val (%setq ,plc ,(%setq-place val)))))
       (with ((moved new-expr) (expex-move-args ex (list val)))
         (values moved (expex-make-%setq ex plc new-expr.))))))

(defun expex-expr-std (ex x)
  (with ((moved new-expr) (expex-move-args ex (expex-argexpand ex x)))
    (values moved (list new-expr))))

(defun expex-expr (ex expr)
  (make-default-listprop expr)
  (let x (expex-guest-filter-expr ex expr)
    (expex-cps x)
    (?
      (%%go-nil? x)            (expex-%%go-nil ex x)
	  (%var? x)                (expex-var x)
	  (lambda? x)              (expex-lambda ex x)
      (not (expex-able? ex x)) (values nil (list x))
      (%%block? x)             (values nil (expex-body ex (%%block-body x)))
      (%setq-cps-mode? x)      (expex-%setq-cps-mode x)
      (%setq? x)               (expex-expr-%setq ex x)
      (expex-expr-std ex x))))


;;;; BODY EXPANSION

(defun expex-force-%setq (ex x)
  (| (& (metacode-expression-only x) (list x))
     (expex-make-%setq ex '~%ret x)))

(defun expex-make-return-value (ex s x)
  (with (last (car (last x))
         wanted-return-value? #'(()
                                   (eq s (%setq-place last)))
         make-return-value    #'(()
                                   `(,last
                                     ,@(expex-make-%setq ex s (%setq-place last)))))
    (? (has-return-value? last)
       (+ (butlast x)
          (? (%setq? last)
             (? (wanted-return-value?)
                (expex-guest-filter-setter ex last)
                (make-return-value))
             (expex-make-%setq ex s last)))
       x)))

(defun expex-body (ex x &optional (s '~%ret))
  (expex-make-return-value ex s (mapcan [with ((moved new-expr) (expex-expr ex _))
                                          (+ moved (mapcan [expex-force-%setq ex _] new-expr))]
                                        (distinguish-vars-from-tags (list-without-noargs-tag x)))))


;;;; TOP LEVEL

(defun expression-expand (ex x)
  (& x
	 (with-temporaries (*current-expex* ex
	                    *expex-funinfo* (transpiler-global-funinfo *transpiler*))
       (expex-body ex x))))
