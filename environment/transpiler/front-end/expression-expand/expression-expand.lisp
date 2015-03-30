; tré – Copyright (c) 2006–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *expex* nil)
(defvar *expex-import?* nil)

(define-gensym-generator expex-sym e)


;;;; IMPORT

(defun expex-import-function (x)
  (& *expex-import?*
     (alet (metacode-function-name x)
       (add-wanted-function !)
       (| (current-scope? x)
          (import-add-used !)))))

(defun expex-variable-name (x)
  (?
    (atom x)          x
    (%slot-value? x)  .x.))

(defun expex-import-variable (x)
  (!? (expex-variable-name x)
      (add-wanted-variable !)))

(defun expex-import-variables (x)
  (& *expex-import?*
     (import-variables?)
     (adolist x
       (expex-import-variable !))))


;;;; GUEST CALLBACKS

(defun expex-guest-filter-setter (x)
  (funcall (expex-setter-filter *expex*) x))

(defun expex-guest-filter-arguments (x)
  (@ [(expex-import-function _)
      (funcall (expex-argument-filter *expex*) _)]
     x))


;;;; UTILS

(defun expex-make-%= (plc val)
  (when (atom val)
    (= val (funcall (expex-argument-filter *expex*) val)))
  (expex-guest-filter-setter `(%= ,plc ,(? (%=? val)
                                           (%=-place val)
                                           val))))

(defun expex-add-var ()
  (funinfo-var-add *funinfo* (expex-sym)))


;;;; PREDICATES

(defun unexpex-able? (x)
  (| (atom x)
     (literal-function? x)
     (in? x. '%%go '%%go-nil '%%native '%%string 'quote '%%comment)))


;;;; ARGUMENT EXPANSION

(defun compiled-arguments (fun def vals)
  (with (f [& _ `(. ,_. ,(f ._))])
    (@ [?
         (%rest-or-%body? _)  (f ._)
         (%key? _)            ._
          _]
       (cdrlist (argument-expand fun def vals)))))

(defun expex-argdef (fun)
;  (| (funinfo-get-local-function-args *funinfo* fun) ; XXX Doesn't work, yet.
     (transpiler-function-arguments *transpiler* fun))

(defun expex-argexpand (x)
  (with (new?   (%new? x)
		 fun    (? new? .x. x.)
		 args   (? new? ..x .x)
	     eargs  (? (defined-function fun)
                   (compiled-arguments fun (expex-argdef fun) args)
                   args))
	`(,@(& new? '(%new)) ,fun ,@(expand-literal-characters eargs))))


;;;;; MOVING ARGUMENTS

(defun expex-move-atom (x)
  (alet (expex-add-var)
    (. (expex-make-%= ! x) !)))

(defun expex-move-inline (x)
  (with ((p a) (expex-move-args x))
	(. p a)))

(defun expex-move-%%block (x)
  (!? (%%block-body x)
      (let s (expex-add-var)
        (. (expex-body ! s) s))
	  (. nil nil)))

(defun expex-move-std (x)
  (with (s                (expex-add-var)
         (moved new-expr) (expex-expr x))
    (. (append moved
               (? (has-return-value? new-expr.)
                  (expex-make-%= s new-expr.)
                  new-expr))
       s)))

(defun expex-inlinable? (x)
  (funcall (expex-inline? *expex*) x))

(defun expex-move (x)
  (pcase x
	unexpex-able?     (. nil x)
    atom              (expex-move-atom x)
	expex-inlinable?  (expex-move-inline x)
    %%block?          (expex-move-%%block x)
	(expex-move-std x)))

(defun expex-move-args (x)
  (expex-import-variables x)
  (with (filtered          (expex-guest-filter-arguments x)
         (moved new-expr)  (assoc-splice (@ #'expex-move filtered)))
    (values (apply #'append moved) new-expr)))


;;;; EXPRESSION EXPANSION

(defun expex-lambda (x)
  (with-temporary *funinfo* (get-lambda-funinfo x)
    (values nil (list (copy-lambda x :body (expex-body (lambda-body x)))))))

(defun expex-var (x)
  (funinfo-var-add *funinfo* .x.)
  (values nil nil))

(defun expex-%%go-nil (x)
  (with ((moved new-expr) (expex-move-args (list ..x.)))
    (values moved `((%%go-nil ,.x. ,@new-expr)))))

(defun expex-expr-%= (x)
  (with-%= place val x
    (? (%=? val)
       (return (values nil (expex-body `(,val
                                         (%= ,place ,(%=-place val)))))))
    (expex-import-variable place)
    (with ((moved new-expr) (expex-move-args (list val)))
      (values moved (expex-make-%= place new-expr.)))))

(defun expex-expr-std (x)
  (expex-import-function x)
  (with ((moved new-expr) (expex-move-args (expex-argexpand x)))
    (values moved (list new-expr))))

(defun expex-expr (x)
  (with-default-listprop x
    (pcase x
      %=?            (expex-expr-%= x)
      %%go-nil?      (expex-%%go-nil x)
      %var?          (expex-var x)
      named-lambda?  (expex-lambda x)
      %%block?       (values nil (expex-body (%%block-body x)))
      unexpex-able?  (values nil (list x))
      (expex-expr-std x))))


;;;; BODY EXPANSION

(defun expex-make-return-value (s x)
  (with (l                     (car (last x))
         wanted-return-value?  #'(()
                                   (eq s (%=-place l)))
         make-return-value     #'(()
                                   `(,l
                                     ,@(expex-make-%= s (%=-place l)))))
    (? (has-return-value? l)
       (append (butlast x)
               (? (%=? l)
                  (? (wanted-return-value?)
                     (expex-guest-filter-setter l)
                     (make-return-value))
                  (expex-make-%= s l)))
       x)))

(defun expex-body (x &optional (s '~%ret))
  (with (ensure-%=  [| (& (| (metacode-expression? _)
                             (%%comment? _))
                          (list _))
                       (expex-make-%= '~%ret _)])
    (expex-make-return-value s 
        (mapcan [with ((moved new-expr) (expex-expr _))
                 (append moved (mapcan #'ensure-%= new-expr))]
                (wrap-atoms (list-without-noargs-tag x))))))


;;;; TOPLEVEL

(defun expression-expand (x)
  (& x
     (with-temporary *expex* (transpiler-expex *transpiler*)
       (= *expex-sym-counter* 0)
       (expex-body x))))
