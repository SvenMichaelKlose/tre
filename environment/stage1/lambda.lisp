;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

;;;; A LAMBDA-expression is an anonymous function.  In many other dialects
;;:: the LAMBDA symbol is required to describe anonymous functions:
;;;;
;;;; #'(lambda (x) x)
;;;;
;;;; tré will ignore the LAMBDA symbol, so this is also valid:
;;;;
;;;; #'((x) x)
;;;;
;;;; This is NOT a LAMBDA-expression:
;;;;
;;;; #'foo

;;;; Please don't hate me but the compiler stores the ID of function
;;;; information as the first argument.
;;;; If an argument list points to a FUNINFO structure, it starts
;;;; with the symbol %FUNINFO followed by the ID.
;;;;
;;;; #'((%funinfo ID x) x)

(defun past-lambda-1 (x)
  (? (eq (car x) 'lambda)
	 (cdr x)
	 x))

;; Get name of FUNCTION.
(defun lambda-name (x)
  (? (eq (car x) 'function)
     (? (cdr (cdr x))
	    (cadr x))))

;; Get LAMBDA of FUNCTION.
(defun past-function (x)
  (? (eq (car x) 'function)
	 (? (cdr (cdr x))
	    (caddr x)	; (FUNCTION name lambda-expression)
        (cadr x)) ; (FUNCTION lambda-expression)
	 x))

(defun past-lambda-before-funinfo (x)
  (past-lambda-1 (past-function x)))

(defun args-past-funinfo (x)
  (? (eq '%funinfo (car x))
     (cddr x)
     x))

;;;; tré accepts the LAMBDA notation for anonymous functions also
;;;; without the LAMBDA symbol. PAST-LAMBDA gets you past the
;;;; LAMBDA symbol, if it's there.
(defun past-lambda (x)
  (args-past-funinfo (past-lambda-before-funinfo x)))

(defun lambda-funinfo (x)
  (let p (past-lambda-1 (past-function x))
	(& (eq '%funinfo (car p))
	   (cadr p))))

(defun lambda-funinfo-expr (x)
  (let p (past-lambda-1 (past-function x))
	(& (eq '%funinfo (car p))
	   (list '%funinfo (cadr p)))))

(defun lambda-head (x)
  (append (lambda-funinfo-expr x)
		  (list (lambda-args x))))

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
     (eq 'FUNCTION (car x))))

(defun lambda-expr? (x)
  (& (function-expr? x)
     (cons? (cdr x))
     (cons? (cadr x))))

(defun lambda? (x)
  (& (lambda-expr? x)
     (let l (past-lambda (cadr x))
       (& (cons? l)
          (listp (car l))))))

(define-test "IS-LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(define-test "IS-LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(defun lambda-call? (x)
  (& (cons? x)
     (cdr x)
     (lambda? (car x))))

(define-test "IS-LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)

(defun copy-recurse-into-lambda (x body-fun)
  `#'(,@(lambda-head x)
         ,@(funcall body-fun (lambda-body x))))
