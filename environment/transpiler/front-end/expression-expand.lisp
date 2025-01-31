(defstruct expex
  (argument-filter    #'identity)
  (assignment-filter  #'list)
  (inline?            [])
  (warnings?          t))

(var *expex* nil)

(fn compile-list (x) ; TODO: Look better in a more general section.
  (? (cons? x)
     `(. ,x. ,(compile-list .x))
     x))


;;;; SHARED ASSIGNMENT FILTER

(fn expex-compile-funcall (x)
  (!= ..x.
    (? (& (cons? !)
          (| (function-expr? !.)
             (funinfo-find *funinfo* !.)))
       (with-%= p v x
         (expex-body (*> #'+ (frontend `(((%= ,p (*> ,v. ,(compile-list .v)))))))))
       (… x))))


;;;; GUEST CALLBACKS

(fn expex-guest-filter-assignment (x)
  (~> (expex-assignment-filter *expex*) x))

(define-filter expex-guest-filter-arguments (x)
  (~> (expex-argument-filter *expex*) x))


;;;; UTILS

(fn make-%= (p v)
  (expex-guest-filter-assignment
      `(%= ,p ,(? (atom v)
                  (~> (expex-argument-filter *expex*) v)
                  v))))

(def-gensym expex-sym e)

(fn expex-make-var ()
  (funinfo-var-add *funinfo* (expex-sym)))


;;;; ARGUMENT EXPANSION

(fn compiled-expanded-argument (x)
  (?
    (%rest-or-%body? x)
      (compile-list .x)
    (%key? x)
      .x
    x))

(fn compiled-expanded-arguments (fun def vals)
  (@ #'compiled-expanded-argument
     (cdrlist (argument-expand fun def vals))))

(fn expex-argdef (fun)
  ; TODO: The variable containing the function gets assigned to another one…
  (| (!? (funinfo-get-local-function-args *funinfo* fun)
         (print !)) ; …so this doesn't happen.
     (transpiler-function-arguments *transpiler* fun)))

(fn expex-argexpand (x)
  (with (new?   (%new? x)
         fun    (? new? .x. x.)
         args   (? new? ..x .x))
    `(,@(& new? '(%new))
      ,@(!? fun (… !))
      ,@(expand-literal-characters
           (? (defined-function fun)
              (compiled-expanded-arguments fun (expex-argdef fun) args)
              args)))))


;;;;; MOVING ARGUMENTS

(fn expex-move-std (x)
  (with (s                 (expex-make-var)
         (moved new-expr)  (expex-expr x))
    (. (+ moved
          (? (has-return-value? new-expr.)
             (make-%= s new-expr.)
             new-expr))
       s)))

(fn unexpex-able? (x)
  (| (atom x)
     (literal-function? x)
     (in? x. '%go '%go-nil '%native '%string 'quote '%comment)))

(fn expex-inlinable? (x)
  (~> (expex-inline? *expex*) x))

(fn expex-move (x)
  (pcase x
    unexpex-able?
      (. nil x)
    expex-inlinable?
      (with ((moved new-expr) (expex-move-args x))
        (. moved new-expr))
    %block?
      (!? .x
          (let s (expex-make-var)
            (. (expex-body ! s) s))
            (. nil nil))
    (expex-move-std x)))

(fn expex-move-args (x)
  (with (args      (@ #'expex-move (expex-guest-filter-arguments x))
         moved     (carlist args)
         new-expr  (cdrlist args))
    (values (*> #'+ moved) new-expr)))


;;;; EXPRESSION EXPANSION

(fn expex-lambda (x)
  (with-lambda-funinfo x
    (values nil (… (copy-lambda x :body (expex-body (lambda-body x)))))))

(fn expex-expr (x)
  (pcase x
    %=?
      (with-%= p v x
        (with ((moved new-expr) (expex-move-args (… v)))
          (values moved (make-%= p new-expr.))))
    %go-nil?
      (with ((moved new-expr) (expex-move-args (… ..x.)))
        (values moved `((%go-nil ,.x. ,@new-expr))))
    %var?
      (progn
        (funinfo-var-add *funinfo* .x.)
        (values nil nil))
    named-lambda?
      (expex-lambda x)
    %block?        (values nil (expex-body .x))
    unexpex-able?  (values nil (… x))
    %collection?
      (values nil
              `((%collection ,.x.
                  ,@(@ [. '%inhibit-macro-expansion
                          (. ._.
                             (? .._
                                (with ((dummy expr) (expex-lambda .._))
                                  expr)))]
                       ..x))))
    (with ((moved new-expr) (expex-move-args (expex-argexpand x)))
      (values moved (… new-expr)))))


;;;; BODY EXPANSION

(fn expex-make-return-value (s x)
  (with (l (car (last x)))
    (? (has-return-value? l)
       (+ (butlast x)
          (? (%=? l)
             (? (eq s (%=-place l))
                (expex-guest-filter-assignment l)
                `(,l
                  ,@(make-%= s (%=-place l))))
             (make-%= s l)))
       x)))

(fn ensure-%= (x)
  (| (& (metacode-statement? x)
        (… x))
     (make-%= *return-id* x)))

(fn expex-body (x &optional (s *return-id*))
  (expex-make-return-value s
      (+@ [with ((moved new-expr) (expex-expr _))
            (+ moved (+@ #'ensure-%= new-expr))]
          (wrap-atoms (remove 'no-args x)))))


;;;; TOPLEVEL

(fn expression-expand (x)
  (& x
     (with-temporary *expex* (transpiler-expex *transpiler*)
       (= *expex-sym-counter* 0)
       (expex-body x))))
