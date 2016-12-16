; tré – Copyright (c) 2006–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *expex* nil)

; TODO
(defun expex-set-global-variable-value (x)
  (list x))

;;;; SHARED SETTER FILTER

(defun expex-compiled-funcall (x)
  (alet (%=-value x)
    (? (& (cons? !)
          (| (function-expr? !.)
             (funinfo-find *funinfo* !.)))
       (with-%= p v x
         (expex-body (apply #'+ (frontend `(((%= ,p (apply ,v. ,(compiled-list .v)))))))))
       (list x))))


;;;; GUEST CALLBACKS

(defun expex-guest-filter-setter (x)
  (funcall (expex-setter-filter *expex*) x))

(defun expex-guest-filter-arguments (x)
  (@ [funcall (expex-argument-filter *expex*) _] x))


;;;; UTILS

(defun make-%= (p v)
  (when (atom v)
    (= v (funcall (expex-argument-filter *expex*) v)))
  (expex-guest-filter-setter `(%= ,p ,(? (%=? v)
                                         (%=-place v)
                                         v))))

(define-gensym-generator expex-sym e)

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
  ; TODO: The variable containing the function gets assigned to another one…
  (| (!? (funinfo-get-local-function-args *funinfo* fun)
         (print !)) ; …so this doesn't happen.
     (transpiler-function-arguments *transpiler* fun)))

(defun expex-argexpand (x)
  (with (new?   (%new? x)
         fun    (? new? .x. x.)
         args   (? new? ..x .x)
         eargs  (? (defined-function fun)
                   (compiled-arguments fun (expex-argdef fun) args)
                   args))
    `(,@(& new? '(%new)) ,fun ,@(expand-literal-characters eargs))))


;;;;; MOVING ARGUMENTS

(defun expex-move-inline (x)
  (with ((moved new-expr) (expex-move-args x))
    (. moved new-expr)))

(defun expex-move-%%block (x)
  (!? .x
      (let s (expex-add-var)
        (. (expex-body ! s) s))
      (. nil nil)))

(defun expex-move-std (x)
  (with (s                 (expex-add-var)
         (moved new-expr)  (expex-expr x))
    (. (+ moved
          (? (has-return-value? new-expr.)
             (make-%= s new-expr.)
             new-expr))
       s)))

(defun expex-inlinable? (x)
  (funcall (expex-inline? *expex*) x))

(defun expex-move (x)
  (pcase x
    unexpex-able?     (. nil x)
    expex-inlinable?  (expex-move-inline x)
    %%block?          (expex-move-%%block x)
    (expex-move-std x)))

(defun expex-move-args (x)
  (with ((moved new-expr) (assoc-splice (@ #'expex-move (expex-guest-filter-arguments x))))
    (values (apply #'+ moved) new-expr)))


;;;; EXPRESSION EXPANSION

(defun expex-lambda (x)
  (with-lambda-funinfo x
    (values nil (list (copy-lambda x :body (expex-body (lambda-body x)))))))

(defun expex-var (x)
  (funinfo-var-add *funinfo* .x.)
  (values nil nil))

(defun expex-%%go-nil (x)
  (with ((moved new-expr) (expex-move-args (list ..x.)))
    (values moved `((%%go-nil ,.x. ,@new-expr)))))

(defun expex-expr-%= (x)
  (with-%= p v x
    (? (%=? v)
       (return (values nil (expex-body `(,v
                                         (%= ,p ,(%=-place v)))))))
    (with ((moved new-expr) (expex-move-args (list v)))
      (values moved (make-%= p new-expr.)))))

(defun expex-expr (x)
  (with-default-listprop x
    (pcase x
      %=?            (expex-expr-%= x)
      %%go-nil?      (expex-%%go-nil x)
      %var?          (expex-var x)
      named-lambda?  (expex-lambda x)
      %%block?       (values nil (expex-body .x))
      unexpex-able?  (values nil (list x))
      (with ((moved new-expr) (expex-move-args (expex-argexpand x)))
        (values moved (list new-expr))))))


;;;; BODY EXPANSION

(defun expex-make-return-value (s x)
  (with (l                     (car (last x))
         wanted-return-value?  #'(()
                                   (eq s (%=-place l)))
         make-return-value     #'(()
                                   `(,l
                                     ,@(make-%= s (%=-place l)))))
    (? (has-return-value? l)
       (+ (butlast x)
          (? (%=? l)
             (? (wanted-return-value?)
                (expex-guest-filter-setter l)
                (make-return-value))
             (make-%= s l)))
       x)))

(defun expex-body (x &optional (s '~%ret))
  (with (ensure-%=  [| (& (| (metacode-expression? _)
                             (%%comment? _))
                          (list _))
                       (make-%= '~%ret _)])
    (expex-make-return-value s 
        (mapcan [with ((moved new-expr) (expex-expr _))
                  (+ moved (mapcan #'ensure-%= new-expr))]
                (wrap-atoms (list-without-noargs-tag x))))))


;;;; TOPLEVEL

(defun expression-expand (x)
  (& x
     (with-temporary *expex* (transpiler-expex *transpiler*)
       (= *expex-sym-counter* 0)
       (expex-body x))))
