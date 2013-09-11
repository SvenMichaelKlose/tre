;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

;;;; (FUNCTION [LAMBDA] [name] [arguments body...])
;;;; (FUNCTION name)

(defun past-lambda-1 (x)
  (? (eq (car x) 'lambda)
	 (cdr x)
	 x))

(defun lambda-name (x)
  (? (eq (car x) 'function)
     (? (cdr (cdr x))
	    (cadr x))))

(defun past-function (x)
  (? (eq (car x) 'function)
	 (? (cdr (cdr x))
	    (caddr x)	; (FUNCTION name lambda-expression)
        (cadr x))   ; (FUNCTION lambda-expression)
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

(defun lambda-call-vals (x)
  (cdr x))

(defun function-expr? (x)
  (& (cons? x)
     (eq 'function (car x))))

(defun lambda-expr? (x)
  (& (function-expr? x)
     (cons? (cdr x))
     (cons? (cadr x))))

(defun lambda? (x)
  (& (lambda-expr? x)
     (let l (past-lambda (cadr x))
       (& (cons? l)
          (list? (car l))))))

(defun lambda-call? (x)
  (& (cons? x)
     (cdr x)
     (lambda? (car x))))

(define-test "LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(define-test "LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(define-test "LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)
