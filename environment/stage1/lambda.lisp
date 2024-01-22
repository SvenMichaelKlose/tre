;;;; (FUNCTION name)
;;;; (FUNCTION [name] (arguments body…))
;;;; (FUNCTION [name] (LAMBDA (arguments body…)))

(fn lambda-name (x)
  (? (eq x. 'function)
     (? ..x
        .x.)))

(fn past-function (x)
  (? (eq x. 'function)
     (? ..x
        ..x.   ; (FUNCTION name lambda-expression)
        .x.)   ; (FUNCTION lambda-expression)
     x))

(fn past-lambda (x)
  (!= (past-function x)
    (? (eq !. 'lambda)
       .!
       !)))

(fn lambda-args (x)
  (car (past-lambda x)))

(fn lambda-body (x)
  (cdr (past-lambda x)))

(fn lambda-args-and-body (x)
  (values (lambda-args x)
          (lambda-body x)))

(fn function-expr? (x)
  (& (cons? x)
     (eq 'function x.)))

(fn lambda-expr? (x)
  (& (function-expr? x)
     (cons? .x)
     (cons? .x.)))

(fn lambda? (x)
  (& (lambda-expr? x)
     (let l (past-lambda .x.)
       (& (cons? l)
          (list? l.)))))

(fn named-lambda? (x)
  (& (function-expr? x)
     ..x
     x))

(fn any-lambda? (x)
  (| (lambda? x)
     (named-lambda? x)))

(fn lambda-call? (x)
  (& (cons? x)
     .x
     (lambda? x.)))
