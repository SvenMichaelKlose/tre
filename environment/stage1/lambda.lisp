;;;; tré - Copyright (c) 2006-2012 Sven Michael Klose <pixel@copei.de>

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

;; The compiler stores function information before the arguments of
;; a LAMBDA-expression.
(defun past-lambda-before-funinfo (x)
  (past-lambda-1 (past-function x)))

(defun args-past-funinfo (x)
  (? (eq '%funinfo (car x))
     (cddr x)
     x))

;;;; Tré accepts the LAMBDA notation for anonymous functions also
;;;; without the LAMBDA symbol. PAST-LAMBDA gets you past the
;;;; LAMBDA symbol, if it's there.
(defun past-lambda (x)
  (args-past-funinfo (past-lambda-before-funinfo x)))

(defun lambda-funinfo (x)
  (let p (past-lambda-1 (past-function x))
	(when (eq '%funinfo (car p))
	  (cadr p))))

(defun lambda-funinfo-expr (x)
  (let p (past-lambda-1 (past-function x))
	(when (eq '%funinfo (car p))
	  (list '%funinfo (cadr p)))))

(defun lambda-head (x)
  (append (lambda-funinfo-expr x)
		  (list (lambda-args x))))

(defun lambda-args (x)
  (car (past-lambda x)))

(defun lambda-body (x)
  (cdr (past-lambda x)))

(defun lambda-call-vals (x)
  (cdr x))

(defun function-expr? (x)
  (and (cons? x)
       (eq 'FUNCTION (car x))))

(defun lambda-expr? (x)
  (and (function-expr? x)
       (cons? (cdr x))
       (cons? (cadr x))))

(defun lambda? (x)
  (and (lambda-expr? x)
	   (let l (past-lambda (cadr x))
		 (and (cons? l)
			  (listp (car l))))))

(define-test "IS-LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(define-test "IS-LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(defun lambda-call? (x)
  (and (cons? x)
	   (cdr x)
       (lambda? (car x))))

(define-test "IS-LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)

(defun copy-recurse-into-lambda (x body-fun)
  `#'(,@(lambda-head x)
         ,@(funcall body-fun (lambda-body x))))
