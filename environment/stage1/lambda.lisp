;;;; (FUNCTION [LAMBDA] [name] [arguments body...])
;;;; (FUNCTION name)

(fn past-lambda-1 (x)
  (? (eq x. 'lambda)
     .x
     x))

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
  (past-lambda-1 (past-function x)))

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

(fn lambda-call? (x)
  (& (cons? x)
     .x
     (lambda? x.)))
