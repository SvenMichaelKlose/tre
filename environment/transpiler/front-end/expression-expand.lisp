(var *expex* nil)


(fn compiled-list (x)
  (? (cons? x)
     `(. ,x.
         ,(compiled-list .x))
     x))

;;;; SHARED SETTER FILTER

(fn expex-compiled-funcall (x)
  (!= ..x.
    (? (& (cons? !)
          (| (function-expr? !.)
             (funinfo-find *funinfo* !.)))
       (with-%= p v x
         (expex-body (apply #'+ (frontend `(((%= ,p (apply ,v. ,(compiled-list .v)))))))))
       (list x))))


;;;; GUEST CALLBACKS

(fn expex-guest-filter-setter (x)
  (funcall (expex-setter-filter *expex*) x))

(fn expex-guest-filter-arguments (x)
  (@ [funcall (expex-argument-filter *expex*) _] x))


;;;; UTILS

(fn make-%= (p v)
  (when (atom v)
    (= v (funcall (expex-argument-filter *expex*) v)))
  (expex-guest-filter-setter `(%= ,p ,(? (%=? v)
                                         .v.
                                         v))))

(define-gensym-generator expex-sym e)

(fn expex-add-var ()
  (funinfo-var-add *funinfo* (expex-sym)))


;;;; PREDICATES

(fn unexpex-able? (x)
  (| (atom x)
     (literal-function? x)
     (in? x. '%%go '%%go-nil '%%native '%%string 'quote '%%comment)))


;;;; ARGUMENT EXPANSION

(fn compiled-expanded-arguments (fun def vals)
  (@ [?
       (%rest-or-%body? _)  (compiled-list ._)
       (%key? _)            ._
        _]
     (cdrlist (argument-expand fun def vals))))

(fn expex-argdef (fun)
  ; TODO: The variable containing the function gets assigned to another one…
  (| (!? (funinfo-get-local-function-args *funinfo* fun)
         (print !)) ; …so this doesn't happen.
     (transpiler-function-arguments *transpiler* fun)))

(fn expex-argexpand (x)
  (with (new?   (%new? x)
         fun    (? new? .x. x.)
         args   (? new? ..x .x)
         eargs  (? (defined-function fun)
                   (compiled-expanded-arguments fun (expex-argdef fun) args)
                   args))
    `(,@(& new? '(%new)) ,@(!? fun (list !)) ,@(expand-literal-characters eargs))))


;;;;; MOVING ARGUMENTS

(fn expex-move-inline (x)
  (with ((moved new-expr) (expex-move-args x))
    (. moved new-expr)))

(fn expex-move-%%block (x)
  (!? .x
      (let s (expex-add-var)
        (. (expex-body ! s) s))
      (. nil nil)))

(fn expex-move-std (x)
  (with (s                 (expex-add-var)
         (moved new-expr)  (expex-expr x))
    (. (+ moved
          (? (has-return-value? new-expr.)
             (make-%= s new-expr.)
             new-expr))
       s)))

(fn expex-inlinable? (x)
  (funcall (expex-inline? *expex*) x))

(fn expex-move (x)
  (pcase x
    unexpex-able?     (. nil x)
    expex-inlinable?  (expex-move-inline x)
    %%block?          (expex-move-%%block x)
    (expex-move-std x)))

(fn expex-move-args (x)
  (with (args      (@ #'expex-move (expex-guest-filter-arguments x))
         moved     (carlist args)
         new-expr  (cdrlist args))
    (values (apply #'+ moved) new-expr)))


;;;; EXPRESSION EXPANSION

(fn expex-lambda (x)
  (with-lambda-funinfo x
    (values nil (list (copy-lambda x :body (expex-body (lambda-body x)))))))

(fn expex-var (x)
  (funinfo-var-add *funinfo* .x.)
  (values nil nil))

(fn expex-%%go-nil (x)
  (with ((moved new-expr) (expex-move-args (list ..x.)))
    (values moved `((%%go-nil ,.x. ,@new-expr)))))

(fn expex-expr-%= (x)
  (with-%= p v x
    (? (%=? v)
       (return (values nil (expex-body `(,v
                                         (%= ,p ,.v.))))))
    (with ((moved new-expr) (expex-move-args (list v)))
      (values moved (make-%= p new-expr.)))))

(fn expex-expr (x)
  (pcase x
    %=?            (expex-expr-%= x)
    %%go-nil?      (expex-%%go-nil x)
    %var?          (expex-var x)
    named-lambda?  (expex-lambda x)
    %%block?       (values nil (expex-body .x))
    unexpex-able?  (values nil (list x))
    (with ((moved new-expr) (expex-move-args (expex-argexpand x)))
      (values moved (list new-expr)))))


;;;; BODY EXPANSION

(fn expex-make-return-value (s x)
  (with (l                     (car (last x))
         wanted-return-value?  #'(()
                                   (eq s .l.))
         make-return-value     #'(()
                                   `(,l
                                     ,@(make-%= s .l.))))
    (? (has-return-value? l)
       (+ (butlast x)
          (? (%=? l)
             (? (wanted-return-value?)
                (expex-guest-filter-setter l)
                (make-return-value))
             (make-%= s l)))
       x)))

(fn expex-body (x &optional (s '~%ret))
  (with (ensure-%=  [| (& (| (metacode-expression? _)
                             (%%comment? _))
                          (list _))
                       (make-%= '~%ret _)])
    (expex-make-return-value s 
        (mapcan [with ((moved new-expr) (expex-expr _))
                  (+ moved (mapcan #'ensure-%= new-expr))]
                (wrap-atoms (remove 'no-args x))))))


;;;; TOPLEVEL

(fn expression-expand (x)
  (& x
     (with-temporary *expex* (transpiler-expex *transpiler*)
       (= *expex-sym-counter* 0)
       (expex-body x))))
