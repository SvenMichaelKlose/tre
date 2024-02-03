(fn lambda-name (x)
  "Get name of FUNCTION form."
  (? (eq x. 'function)
     (? ..x
        .x.)))

(fn past-function (x)
  "Get LAMBDA expression of FUNCTION form."
  (? (eq x. 'function)
     (? ..x
        ..x.
        .x.)
     x))

(fn past-lambda (x)
  "Get LAMBDA expression of FUNCTION form without LAMBDA symbol."
  (!= (past-function x)
    (? (eq !. 'lambda)
       .!
       !)))

(fn lambda-args (x)
  "Get arguments of function form."
  (car (past-lambda x)))

(fn lambda-body (x)
  "Get body of function form."
  (cdr (past-lambda x)))

(fn lambda-args-and-body (x)
  "Get arguments of body of function form as VALUES."
  (values (lambda-args x)
          (lambda-body x)))

(fn function-expr? (x)
  "Test if expression starts with symbol FUNCTION."
  (& (cons? x)
     (eq 'function x.)))

(fn lambda-expr? (x)
  "Test if an unnamed FUNCTION form with a list argument."
  (& (function-expr? x)
     (cons? .x)
     (cons? .x.)))  ; Name would be a symbol here.

(fn unnamed-lambda? (x)
  "Test if an unnamed FUNCTION form with a argument definition."
  (& (lambda-expr? x)
     (let l (past-lambda .x.)
       (& (cons? l)
          (list? l.)))))

(fn named-lambda? (x)
  "Test if a named FUNCTION form."
  (& (function-expr? x)
     ..x
     x))

(fn lambda? (x)
  "Test if FUNCTION form."
  (| (unnamed-lambda? x)
     (named-lambda? x)))

(fn lambda-call? (x)
  "Test if expression has a FUNCTION form as the first element."
  (& (cons? x)
     .x
     (unnamed-lambda? x.)))
