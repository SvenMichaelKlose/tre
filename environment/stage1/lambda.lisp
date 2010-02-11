;;;; TRE environment
;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; LAMBDA-related utilities.

;;;; TRE accepts the LAMBDA notation for anonymous functions also
;;;; without the LAMBDA symbol. PAST-LAMBDA gets you past the
;;;; LAMBDA symbol, if it's there.

(defun past-lambda-1 (x)
  (if (eq (car x) 'lambda)
	(cdr x)
	x))

;; Get name of FUNCTION.
(defun function-name (x)
  (if (eq (car x) 'function)
	  (if (cdr (cdr x))
		  (cadr x))))

;; Get LAMBDA of FUNCTION.
(defun past-function (x)
  (if (eq (car x) 'function)
	  (if (cdr (cdr x))
		  (caddr x)	; (FUNCTION name lambda-expression)
      	  (cadr x)) ; (FUNCTION lambda-expression)
	  x))

;; The compiler stores function information before the arguments of
;; a LAMBDA-expression.
(defun past-lambda-before-funinfo (x)
  (past-lambda-1 (past-function x)))

(defun past-lambda (x)
  "Get cons after optional LAMBDA keyword in function expression."
  (let p (past-lambda-before-funinfo x)
	(if (eq '%funinfo (car p))
	  (cddr p)
	  p)))

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
  "Get arguments of function expression."
  (car (past-lambda x)))

(defun lambda-body (x)
  "Get body of function expression."
  (cdr (past-lambda x)))

(defun lambda-call-vals (x)
  "Get arguments to local function call (used to introduce local symbols)."
  (cdr x))

(defun function-expr? (x)
  (and (consp x)
       (eq 'FUNCTION (car x))))

(defun lambda-expr? (x)
  (and (function-expr? x)
       (consp (cdr x))
       (consp (cadr x))))

(defun lambda? (x)
  "Checks if expression is a function/LAMBDA expression."
  (and (lambda-expr? x)
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
  (if (builtinp fun)
	  '(&rest args-to-builtin)
      (car (symbol-value fun))))

(defun function-body (fun)
  "Returns body of a function."
  (cdr (symbol-value fun)))

(defun copy-recurse-into-lambda (x body-fun)
  `#'(,@(lambda-head x)
         ,@(funcall body-fun (lambda-body x))))
