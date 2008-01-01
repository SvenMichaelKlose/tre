;;;; nix operating system project
;;;; lisp compiler
;;;; (c) 2005 Sven Klose <pixel@copei.de>
;;;;
;;;; LAMBDA-related utilities.

(defun past-lambda (x)
  (if (eq (first x) 'lambda)
	(cdr x)
	x))

(defun lambda-args (x)
  (car (past-lambda x)))

(defun lambda-body (x)
  (cdr (past-lambda x)))

(defun lambda-call-vals (x)
  (cdr x))

(defun is-lambda? (x)
  (and (consp x)
       (eq (car x) 'function)
       (consp (cdr x))
       (consp (cadr x))
	   (with (l (past-lambda (cadr x)))
		 (and l (consp l) (listp (car l))))))

(define-test "IS-LAMBDA? works"
  ((is-lambda? '#'((x) x)))
  t)

(define-test "IS-LAMBDA? works with LAMBDA"
  ((is-lambda? '#'(lambda (x) x)))
  t)

(defun is-lambda-call? (x)
  (and (consp x)
	   (cdr x)
       (is-lambda? (car x))))

(define-test "IS-LAMBDA-CALL? works"
  ((is-lambda-call? '(#'((x) x) nil)))
  t)

(defmacro with-lambda-call ((args vals body call) &rest xs)
  (with-gensym (tmp l)
    `(with (,tmp ,call
	   	    ,l (second (car ,tmp))
       	    ,args (lambda-args ,l)
       	    ,vals (lambda-call-vals ,tmp)
       	    ,body (lambda-body ,l))
       ,@xs)))

(defun function-arguments (fun)
  "Returns arguments of a function."
  (first (symbol-value fun)))

(defun function-body (fun)
  "Returns body of a function."
  (cdr (symbol-value fun)))
