(fn make-scoping-function (x)
  (with-gensym g
    `(labels ((,g ,@(make-lambdas (cadr x.))))
       (,g ,@(make-lambdas .x)))))

(fn make-anonymous-function (x)
  (!= (make-lambdas .x.)
    (? (equal ! '(nil))
       `(lambda nil nil)
       `(lambda ,@!))))

(fn lambda-expr-w/o-lambda-keyword? (x)
  (& (cons? x)
     (eq 'function x.)
     (not (atom .x.))
     (not (eq 'lambda .x..))))

(fn make-lambdas (x)
  (?
    (eq '&body x)   '&rest
    (atom x)        x
    (eq 'quote x.)  x
    (lambda-expr-w/o-lambda-keyword? x.) (make-scoping-function x)
    (lambda-expr-w/o-lambda-keyword? x)  (make-anonymous-function x)
    (@ #'make-lambdas x)))
