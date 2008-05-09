;;;; TRE environment
;;;; Copyright (c) 2006-2008  Sven Klose <pixel@copei.de>
;;;;
;;;; LAMBDA-related utilities.

(defun past-lambda (x)
  "Get cons after optional LAMBDA keyword in function expression."
  (if (eq (first x) 'lambda)
	(cdr x)
	x))

(defun lambda-args (x)
  "Get arguments of function expression."
  (car (past-lambda x)))

(defun lambda-body (x)
  "Get body of function expression."
  (cdr (past-lambda x)))

(defun lambda-call-vals (x)
  "Get arguments to local function call (used to introduce local symbols)."
  (cdr x))

(defun is-lambda? (x)
  "Checks if expression is a function/LAMBDA expression."
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
  "Checks if expression is a local function call."
  (and (consp x)
	   (cdr x)
       (is-lambda? (car x))))

(define-test "IS-LAMBDA-CALL? works"
  ((is-lambda-call? '(#'((x) x) nil)))
  t)

(defmacro with-lambda-call ((args vals body call) &rest exec-body)
  "Bind local function call components to variables for exec-body."
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
