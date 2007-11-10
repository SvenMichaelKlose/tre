;;;; nix operating system project
;;;; lisp compiler
;;;; (c) 2005 Sven Klose <pixel@copei.de>
;;;;
;;;; LAMBDA-related utilities.

(defun past-lambda (expr)
  (if (eq (first expr) 'lambda)
	(cdr expr)
	expr))

(defun lambda-args (expr)
  (car (past-lambda expr)))

(defun lambda-body (expr)
  (cdr (past-lambda expr)))

(defun lambda-call-args (expr)
  (lambda-args (first expr)))

(defun lambda-call-body (expr)
  (lambda-body (first expr)))

(defun lambda-call-vals (expr)
  (cdr expr))

(defun is-lambda? (expr)
  (and (consp expr)
       (eq (car expr) 'function)
       (consp (cdr expr))
       (listp (cadr expr))
       (or (consp (caadr expr))
           (eq (caadr expr) 'lambda))))

(defun is-lambda-call? (expr)
  (and (consp expr)
       (is-lambda? (car expr))
       (listp (lambda-call-args expr))
       (listp (lambda-call-body expr))))

(defmacro with-lambda-call ((args vals body call) &rest exprs)
  (with-gensym (tmp start)
    `(with (,tmp ,call
	   	    ,start (past-lambda ,tmp)
       	    ,args (lambda-call-args ,start)
       	    ,vals (lambda-call-vals ,start)
       	    ,body (lambda-call-body ,start))
       ,@exprs)))

(defun function-arguments (fun)
  "Returns arguments of a function."
  (first (symbol-value fun)))

(defun function-body (fun)
  "Returns body of a function."
  (cdr (symbol-value fun)))
