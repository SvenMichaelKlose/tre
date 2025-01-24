; These function expression formats are supported:
;
; 1. (LAMBDA args . body) or #'(args . body)
; 2. (FUNCTION args . body) or #'(args . body)
; 3. (FUNCTION name) – Essentially a literal SYMBOL-FUNCTION.
; 4. (FUNCTION name args . body) or #'(name args . body)
;
; TODO: It shouldn't matter if the keyword is LAMBDA or FUNCTION.

(fn lambda-name (x)
  "Get name in (FUNCTION [name] (args . body))."
  (? (eq x. 'function)
     (? ..x
        .x.)))

(fn past-function (x)
  "Get args and body of (FUNCTION [name] (args . body))."
  (? (eq x. 'function)
     (? ..x
        ..x.
        .x.)
     x))

(fn past-lambda (x)
  "Get rest of LAMBDA expression."
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
