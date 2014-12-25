;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

; This pass converts the input into a sequence of statements without
; %%BLOCKs, it expands arguments and moves statements out of
; arguments. Every instruction which is not a jump or tag is forced
; into a %SETQ assignment.

(defvar *expex* nil)
(defvar *expex-import?* nil)

(define-gensym-generator expex-sym e)


;;;; IMPORT

(defun expex-import-function (x)
  (& *expex-import?*
     (alet (metacode-function-name x)
       (transpiler-add-wanted-function *transpiler* !)
       (| (current-scope? x)
          (transpiler-import-add-used !)))))

(defun expex-variable-name (x)
  (?
    (atom x)          x
    (%slot-value? x)  .x.))

(defun expex-import-variable (x)
  (!? (expex-variable-name x)
      (transpiler-add-wanted-variable *transpiler* !)))

(defun expex-import-variables (place val)
  (& *expex-import?*
     (when (transpiler-import-variables? *transpiler*)
       (expex-import-variable place)
       (? (atom val)
          (expex-import-variable val)
          (adolist (.val)
             (expex-import-variable !))))))


;;;; GUEST CALLBACKS

(defun expex-guest-filter-setter (x)
  (funcall (expex-setter-filter *expex*) x))

(defun expex-guest-filter-arguments (x)
  (filter [(expex-import-function _)
           (funcall (expex-argument-filter *expex*) _)]
           x))


;;;; UTILS

(defun expex-make-%= (plc val)
  (when (atom val)
    (= val (funcall (expex-argument-filter *expex*) val)))
  (+ (? (%=? val)
        (expex-guest-filter-setter val))
     (expex-guest-filter-setter `(%= ,plc ,(? (%=? val)
                                              (%=-place val)
                                              val)))))

(defun expex-funinfo-var-add ()
  (aprog1 (expex-sym)
    (funinfo-var-add *funinfo* !)))


;;;; PREDICATES

(defun expex-able? (x)
  (not (| (atom x)
          (literal-function? x)
          (in? x. '%%go '%%go-nil '%%native '%%string '%quote))))

(defun expex-expandable-args? (fun)
  (& (not (alien-package? fun))
     (| (transpiler-defined-function *transpiler* fun)
        (not (transpiler-plain-arg-fun? *transpiler* fun)))))


;;;; ARGUMENT EXPANSION

(defun expex-convert-quotes (x)
  (filter [? (quote? _)
		     `(%quote ,._.)
			 _]
		  x))

(defun expex-argexpand-0 (fun args)
  (let argdef (| (funinfo-get-local-function-args *funinfo* fun)
                 (current-transpiler-function-arguments fun))
    (transpiler-expand-literal-characters
	    (? (expex-expandable-args? fun)
   	       (expex-argument-expand fun argdef args)
	       args))))

(defun expex-function? (x)
  (& (atom x)
     (| (transpiler-function-arguments *transpiler* x)
        (fbound? x))))

(defun expex-argexpand (x)
  (with (new?   (%new? x)
		 fun    (? new? .x. x.)
		 args   (? new? ..x .x)
	     eargs  (? (expex-function? fun)
	    	       (expex-convert-quotes (expex-argexpand-0 fun args))
	    	       args))
	`(,@(& new? '(%new)) ,fun ,@eargs)))


;;;;; MOVING SINGLE ARGUMENTS

(defun expex-move-atom (x)
  (let s (expex-funinfo-var-add)
    (. (expex-make-%= s x) s)))

(defun expex-move-inline (x)
  (with ((p a) (expex-move-args x))
	(. p a)))

(defun expex-move-%%block (x)
  (!? (%%block-body x)
      (let s (expex-funinfo-var-add)
        (. (expex-body ! s) s))
	  (. nil nil)))

(defun expex-move-std (x)
  (with (s                (expex-funinfo-var-add)
         (moved new-expr) (expex-expr x))
    (. (+ moved
          (? (has-return-value? new-expr.)
             (expex-make-%= s new-expr.)
             new-expr))
       s)))

(defun expex-move (x)
  (?
	(not (expex-able? x))                (. nil x)
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

(defun expex-expr-%=-0 (place val)
  (expex-import-variables place val)
  (with ((moved new-expr) (expex-move-args (list val)))
    (values moved (expex-make-%= place new-expr.))))

(defun expex-expr-%= (x)
  (with (place  (%=-place x)
         val    (%=-value x)) ; XXX
    (? (%=? val)
       (values nil (expex-body `(,val
                                 (%= ,place ,(%=-place val)))))
       (expex-expr-%=-0 place val))))

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
      (%=? x)                  (expex-expr-%= x)
      (not (expex-able? x))    (values nil (list x))
      (expex-expr-std x))))


;;;; BODY EXPANSION

(defun expex-force-%= (x)
  (| (& (metacode-expression-only x)
        (list x))
     (expex-make-%= '~%ret x)))

(defun expex-make-return-value (s x)
  (with (last (car (last x))
         wanted-return-value? #'(()
                                   (eq s (%=-place last)))
         make-return-value    #'(()
                                   `(,last
                                     ,@(expex-make-%= s (%=-place last)))))
    (? (has-return-value? last)
       (+ (butlast x)
          (? (%=? last)
             (? (wanted-return-value?)
                (expex-guest-filter-setter last)
                (make-return-value))
             (expex-make-%= s last)))
       x)))

(defun expex-body (x &optional (s '~%ret))
  (expex-make-return-value s (mapcan [with ((moved new-expr) (expex-expr _))
                                       (+ moved (mapcan #'expex-force-%= new-expr))]
                                     (distinguish-vars-from-tags (list-without-noargs-tag x)))))


;;;; TOPLEVEL

(defun expression-expand (x)
  (with-temporary *expex* (transpiler-expex *transpiler*)
    (& x
       (= *expex-sym-counter* 0)
       (expex-body x))))
