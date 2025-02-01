(fn compile-list (x) ; TODO: Look better in a more general section.
  (? (cons? x)
     `(. ,x. ,(compile-list .x))
     x))

(fn expex-compile-funcall (x)
  (!= ..x.
    (? (& (cons? !)
          (| (function-expr? !.)
             (funinfo-find *funinfo* !.)))
       (expex-body (*> #'+ (frontend `(((%= ,.x. (*> ,!. ,(compile-list .!))))))))
       (… x))))


(fn make-%= (p v)
  (assignment-filter `(%= ,p ,(? (atom v)
                                 (argument-filter v)
                                 v))))

(def-gensym expex-sym e)

(fn expex-make-var ()
  (funinfo-var-add *funinfo* (expex-sym)))


;;;; ARGUMENT EXPANSION

(fn compiled-expanded-argument (x)
  (?
    (%rest-or-%body? x) (compile-list .x)
    (%key? x)           .x
    x))

(fn compiled-expanded-arguments (fun def vals)
  (@ #'compiled-expanded-argument (cdrlist (argument-expand fun def vals))))

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
  (with (s  (expex-make-var)
         !  (expex-expr x))
    (. (+ !.
          (? (has-return-value? .!.)
             (make-%= s .!.)
             .!))
       s)))

(fn unexpex-able? (x)
  (| (atom x)
     (literal-symbol-function? x)
     (in? x. '%go '%go-nil '%native '%string 'quote '%comment)))

(fn expex-move-arg (x)
  (pcase x
    unexpex-able?
      (. nil x)
    inline?
      (expex-move-args x)
    %block?
      (!= (expex-make-var)
        (. (expex-body .x !) !))
    (expex-move-std x)))

(fn expex-move-args (x)
  (!= (@ #'expex-move-arg (argument-filter x))
    (. (*> #'+ (carlist !))
       (cdrlist !))))


;;;; EXPRESSION EXPANSION

(fn expex-lambda (x)
  (with-lambda-funinfo x
    (. nil (… (copy-lambda x :body (expex-body (lambda-body x)))))))

(fn expex-expr (x)
  (pcase x
    %=?
      (!= (expex-move-args (… ..x.))
        (. !. (make-%= .x. .!.)))
    %go-nil?
      (!= (expex-move-args (… ..x.))
        (. !. `((%go-nil ,.x. ,@.!))))
    %var?
      (progn
        (funinfo-var-add *funinfo* .x.)
        (. nil nil))
    named-lambda?
      (expex-lambda x)
    %block?        (. nil (expex-body .x))
    unexpex-able?  (. nil (… x))
    %collection?
      (. nil
         `((%collection ,.x.
             ,@(@ [. '%inhibit-macro-expansion
                     (. ._.
                        (? .._
                           (cdr (expex-lambda .._))))]
                  ..x))))
    (!= (expex-move-args (expex-argexpand x))
      (. !. (… .!)))))


;;;; BODY EXPANSION

(fn expex-make-return-value (s x)
  (with (l (car (last x)))
    (? (has-return-value? l)
       (+ (butlast x)
          (? (%=? l)
             (? (eq s (%=-place l))
                (assignment-filter l)
                `(,l
                  ,@(make-%= s (%=-place l))))
             (make-%= s l)))
       x)))

(fn ensure-%= (x)
  (| (& (metacode-statement? x)
        (… x))
     (make-%= *return-symbol* x)))

(fn expex-body (x &optional (s *return-symbol*))
  (expex-make-return-value s
      (+@ [!= (expex-expr _)
            (+ !. (+@ #'ensure-%= .!))]
          (wrap-atoms (remove 'no-args x)))))


;;;; TOPLEVEL

(fn expression-expand (x)
  (when x
    (= *expex-sym-counter* 0)
    (expex-body x)))
