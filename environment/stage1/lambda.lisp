;;;; TRE environment
;;;; Copyright (c) 2006-2008  Sven Klose <pixel@copei.de>
;;;;
;;;; LAMBDA-related utilities.

(defun past-lambda-1 (x)
  (if (eq (first x) 'lambda)
	(cdr x)
	x))

(defun past-function (x)
  (if (eq (first x) 'function)
      (second x)
	  x))

(defun past-lambda (x)
  "Get cons after optional LAMBDA keyword in function expression."
  (let p (past-lambda-1 (past-function x))
	(if (eq '%funinfo (first p))
	  (cddr p)
	  p)))

(defun lambda-funinfo (x)
  (let p (past-lambda-1 (past-function x))
	(when (eq '%funinfo (first p))
	  (second p))))

(defun lambda-funinfo-expr (x)
  (let p (past-lambda-1 (past-function x))
	(when (eq '%funinfo (first p))
	  (list '%funinfo (second p)))))

(defun lambda-args (x)
  "Get arguments of function expression."
  (car (past-lambda x)))

(defun lambda-body (x)
  "Get body of function expression."
  (cdr (past-lambda x)))

(defun lambda-call-vals (x)
  "Get arguments to local function call (used to introduce local symbols)."
  (cdr x))

(defun lambda? (x)
  "Checks if expression is a function/LAMBDA expression."
  (and (consp x)
       (eq (car x) 'function)
       (consp (cdr x))
       (consp (cadr x))
	   (let l (past-lambda (cadr x))
		 (and l (consp l)
				(listp (car l))))))

(define-test "IS-LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(define-test "IS-LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(defun lambda-call? (x)
  "Checks if expression is a local function call."
  (and (consp x)
	   (cdr x)
       (lambda? (car x))))

(define-test "IS-LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)

(defun function-arguments (fun)
  "Returns arguments of a function."
  (first (symbol-value fun)))

(defun function-body (fun)
  "Returns body of a function."
  (cdr (symbol-value fun)))

(defun copy-recurse-into-lambda (x body-fun)
  `#'(,(lambda-args x)
       ,@(funcall body-fun (lambda-body x))))
