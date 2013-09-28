;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

; This pass converts the input into a sequence of statements without
; %%BLOCKs, it expands arguments and moves statements out of
; arguments. Every instruction which is not a jump or tag is forced
; into a %SETQ assignment.


(defun peel-identity (x)
  (? (| (identity? x)
        (%identity? x))
     .x.
     x))

(defvar *expex* nil)


;;;; SYMBOLS

(defvar *expex-sym-counter* 0)

(defun expex-sym ()
  (alet ($ 'E (++! *expex-sym-counter*))
    (? (& (eq ! (symbol-value !))
          (not (symbol-function !)))
       !
       (expex-sym))))

(defun expex-function-name (x)
  (?
    (global-literal-function? x)  .x.
    (%%closure? x)                .x.
    (cons? x)                      x.
    x))

(defun expex-import-function (x)
  (alet (expex-function-name x)
    (transpiler-add-wanted-function *transpiler* !)
    (| (current-scope? x)
       (transpiler-import-add-used !))))


;;;; GUEST CALLBACKS

(defun expex-guest-filter-setter (x)
  (funcall (expex-setter-filter *expex*) x))

(defun expex-guest-filter-arguments (x)
  (filter [(expex-import-function _)
           (funcall (expex-argument-filter *expex*) _)]
           x))


;;;; UTILS

(defun expex-make-%setq (plc val)
  (+ (? (%setq? val)
        (expex-guest-filter-setter val))
     (expex-guest-filter-setter `(%setq ,plc ,(? (%setq? val)
                                                 (%setq-place val)
                                                 (peel-identity val))))))

(defun expex-funinfo-var-add ()
  (aprog1 (expex-sym)
    (funinfo-var-add *funinfo* !)))

(defun expex-warn (x)
  (& (transpiler-expex-warnings? *transpiler*)
     (symbol? x)
     (not (transpiler-defined-symbol? *funinfo* x)
          (transpiler-can-import? *transpiler* x))
     (error "Symbol ~A is not defined in ~A."
            (symbol-name x)
            (funinfo-scope-description *funinfo*))))


;;;; PREDICATES

(defun expex-able? (x)
  (| (& (expex-move-lexicals? *expex*)
        (atom x)
        (not (eq '~%ret x))
        (funinfo-parent-var? *funinfo* x)
        (not (funinfo-toplevel-var? *funinfo* x)))
     (not (| (atom x)
             (literal-function? x)
             (in? x. '%%go '%%go-nil '%%native '%%string '%quote)))))

(defun expex-expandable-args? (fun)
  (| (transpiler-defined-function *transpiler* fun)
     (not (transpiler-plain-arg-fun? *transpiler* fun))))


;;;; ARGUMENT EXPANSION

(defun expex-convert-quotes (x)
  (filter [? (quote? _)
		     `(%quote ,._.)
			 _]
		  x))

(defun expex-argexpand-0 (fun args)
  (adolist (args)
    (expex-warn !))
  (| (funinfo-var-or-lexical? *funinfo* fun)
     (transpiler-add-wanted-function *transpiler* fun))
  (let argdef (| (funinfo-get-local-function-args *funinfo* fun)
                 (current-transpiler-function-arguments fun))
    (transpiler-expand-literal-characters
	    (? (expex-expandable-args? fun)
   	       (expex-argument-expand fun argdef args)
	       args))))

(defun expex-function? (x)
  (& (atom x)
     (| (transpiler-function-arguments *transpiler* x)
        (function? (symbol-function x)))))

(defun expex-argexpand (x)
  (with (new? (%new? x)
		 fun  (? new? .x. x.)
		 args (? new? ..x .x))
	`(,@(& new? '(%new))
	  ,fun ,@(? (expex-function? fun)
	    	    (expex-convert-quotes (expex-argexpand-0 fun args))
	    	    args))))


;;;;; MOVING SINGLE ARGUMENTS

(defun expex-move-atom (x)
  (let s (expex-funinfo-var-add)
    (cons (expex-make-%setq s x) s)))

(defun expex-move-inline (x)
  (with ((p a) (expex-move-args x))
	(cons p a)))

(defun expex-move-%%block (x)
  (!? (%%block-body x)
      (let s (expex-funinfo-var-add)
        (cons (expex-body ! s) s))
	  (cons nil nil)))

(defun expex-move-std (x)
  (with (s                (expex-funinfo-var-add)
         (moved new-expr) (expex-expr x))
    (cons (+ moved
             (? (has-return-value? new-expr.)
                (expex-make-%setq s new-expr.)
                new-expr))
          s)))

(defun expex-move (x)
  (?
	(not (expex-able? x))                (cons nil x)
    (atom x)                             (expex-move-atom x)
	(funcall (expex-inline? *expex*) x)  (expex-move-inline x)
    (%%block? x)                         (expex-move-%%block x)
	(expex-move-std x)))


;;;; MOVING ARGUMENTS

(defun expex-filter-and-move-args (x)
  (with ((moved new-expr) (assoc-splice (filter #'expex-move (expex-guest-filter-arguments x))))
    (values (apply #'+ moved) new-expr)))

(defun expex-move-slot-value (x)
  (with ((moved new-expr) (expex-filter-and-move-args (list .x.)))
    (values moved `(%slot-value ,new-expr. ,..x.))))

(defun expex-move-args-0 (x)
  (with ((moved new-expr) (expex-filter-and-move-args x))
    (values moved new-expr)))

(defun expex-move-args (x)
  (? (%slot-value? x)
	 (expex-move-slot-value x)
	 (expex-move-args-0 x)))


;;;; EXPRESSION EXPANSION

(defun expex-lambda (x)
  (with-temporary *funinfo* (get-lambda-funinfo x)
    (values nil (list (copy-lambda x :body (expex-body (lambda-body x)))))))

(defun expex-var (x)
  (funinfo-var-add *funinfo* .x.)
  (values nil nil))

(defun expex-%%go-nil (x)
  (with ((moved new-expr) (expex-filter-and-move-args (list ..x.)))
    (values moved `((%%go-nil ,.x. ,@new-expr)))))

(defun expex-expr-%setq-0 (plc val)
;  (transpiler-add-wanted-variable *transpiler* plc)
;  (& (cons? val)
;     (adolist (.val)
;       (transpiler-add-wanted-variable *transpiler* !)))
  (with ((moved new-expr) (expex-move-args (list val)))
    (values moved (expex-make-%setq plc new-expr.))))

(defun expex-expr-%setq (x)
  (with (plc  (%setq-place x)
         val  (peel-identity (%setq-value x)))
    (? (%setq? val)
       (values nil (expex-body `(,val
                                 (%setq ,plc ,(%setq-place val)))))
       (expex-expr-%setq-0 plc val))))

(defun expex-expr-std (x)
  (expex-import-function x)
  (with ((moved new-expr) (expex-move-args (expex-argexpand x)))
    (values moved (list new-expr))))

(defun expex-expr (x)
  (with-default-listprop x
    (?
      (%%go-nil? x)            (expex-%%go-nil x)
	  (%var? x)                (expex-var x)
	  (named-lambda? x)        (expex-lambda x)
      (%%block? x)             (values nil (expex-body (%%block-body x)))
      (%setq? x)               (expex-expr-%setq x)
      (not (expex-able? x))    (values nil (list x))
      (expex-expr-std x))))


;;;; BODY EXPANSION

(defun expex-force-%setq (x)
  (| (& (metacode-expression-only x) (list x))
     (expex-make-%setq '~%ret x)))

(defun expex-make-return-value (s x)
  (with (last (car (last x))
         wanted-return-value? #'(()
                                   (eq s (%setq-place last)))
         make-return-value    #'(()
                                   `(,last
                                     ,@(expex-make-%setq s (%setq-place last)))))
    (? (has-return-value? last)
       (+ (butlast x)
          (? (%setq? last)
             (? (wanted-return-value?)
                (expex-guest-filter-setter last)
                (make-return-value))
             (expex-make-%setq s last)))
       x)))

(defun expex-body (x &optional (s '~%ret))
  (expex-make-return-value s (mapcan [with ((moved new-expr) (expex-expr _))
                                       (+ moved (mapcan #'expex-force-%setq new-expr))]
                                     (distinguish-vars-from-tags (list-without-noargs-tag x)))))


;;;; TOP LEVEL

(defun expression-expand (expex x)
  (& x
	 (with-temporary *expex* expex
       (with-global-funinfo
         (= *expex-sym-counter* 0)
         (expex-body x)))))
