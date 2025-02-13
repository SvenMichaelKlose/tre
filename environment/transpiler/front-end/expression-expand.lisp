(fn make-%= (p v)
  (assignment-filter `(%= ,p ,v)))

(def-gensym expex-sym e)

(fn expex-make-var ()
  (funinfo-add-var *funinfo* (expex-sym)))


;;;;; MOVING ARGUMENTS

(fn unexpex-able? (x)
  (| (atom x)
     (sharp-quote-symbol? x)
     (in? x. '%go '%go-nil '%native '%string 'quote '%comment)))

(fn has-return-value? (x)
  (not (| (some-%go? x)
          (%var? x)
          (%comment? x))))

(fn expex-move-arg (x)
  (pcase x
    unexpex-able? (. nil x)
    inline?       (expex-move-args x)
    %block?       (!= (expex-make-var)
                    (. (expex-body .x !) !))
    (with (s (expex-make-var)
           ! (expex-expr x))
      (. (+ !.
            (? (has-return-value? .!.)
               (make-%= s .!.)
               .!))
         s))))

(fn expex-move-args (x)
  (!= (@ #'expex-move-arg x)
    (. (*> #'+ (carlist !))
       (cdrlist !))))


;;;; EXPRESSION EXPANSION

(fn expex-lambda (x)
  (. nil (… (do-lambda x :body (expex-body (lambda-body x))))))

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
        (funinfo-add-var *funinfo* .x.)
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
    (!= (expex-move-args x)
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
