;;;; (FUNCTION [LAMBDA] [name] [arguments body...])
;;;; (FUNCTION name)

(defun past-lambda-1 (x)
  (? (eq x. 'lambda)
	 .x
	 x))

(defun lambda-name (x)
  (? (eq x. 'function)
     (? ..x
	    .x.)))

(defun past-function (x)
  (? (eq x. 'function)
	 (? ..x
	    ..x.   ; (FUNCTION name lambda-expression)
        .x.)   ; (FUNCTION lambda-expression)
	 x))

(defun past-lambda (x)
  (past-lambda-1 (past-function x)))

(defun lambda-args (x)
  (car (past-lambda x)))

(defun lambda-body (x)
  (cdr (past-lambda x)))

(defun lambda-args-and-body (x)
  (values (lambda-args x)
          (lambda-body x)))

(defun lambda-call-vals (x) .x)

(defun function-expr? (x)
  (& (cons? x)
     (eq 'function x.)))

(defun lambda-expr? (x)
  (& (function-expr? x)
     (cons? .x)
     (cons? .x.)))

(defun lambda? (x)
  (& (lambda-expr? x)
     (let l (past-lambda .x.)
       (& (cons? l)
          (list? l.)))))

(defun lambda-call? (x)
  (& (cons? x)
     .x
     (lambda? x.)))

(define-test "LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(define-test "LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(define-test "LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)
