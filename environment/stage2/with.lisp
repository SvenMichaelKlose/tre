;;;;; TRE environment
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(defun copy-head-if (pred x)
  (when (and x
			 (funcall pred (car x)))
	(cons (car x)
		  (copy-head-if pred (cdr x)))))

(define-test "COPY-HEAD-IF"
  ((copy-head-if #'numberp '(1 2 3 a)))
  '(1 2 3))

(defun find-cons (fcpred x)
  (when x
    (if (funcall fcpred (car x))
	    x
	    (find-cons fcpred (cdr x)))))

(define-test "FIND-CONS"
  ((find-cons #'numberp '(a b 1 2)))
  '(1 2))

(define-test "FIND-CONS with FN"
  ((find-cons (fn (not (numberp _))) '(1 2 a b 1 2)))
  '(a b 1 2))

(defun collect (pred x)
  (values (copy-head-if pred x)
		  (find-cons (fn (not (funcall pred _))) x)))

(defmacro with (alst &rest body)
  ; Make new WITH for rest of assignment list.
  (labels ((sub (x)
             (if (cddr x)
                 `((with ,(cddr x)
					 ,@body))
                 body)))

	; Get first pair.
    (let* ((plc (first alst))
           (val (second alst)))
      (if
	    ; MULTIPLE-VALUE-BIND if place is a cons.
	    (consp plc)
          `(multiple-value-bind ,plc ,val
		     ,@(sub alst))

	    ; Place function is set of value is a function.
		(lambda? val)
		  (multiple-value-bind (funs followers)
							   (collect (fn (lambda? (second _)))
									    (group alst 2))
		    `(labels ,(mapcar (fn `(,(first _) ,@(past-lambda (second _))))
							  funs)
			   ,@(sub (apply #'append followers))))

		; Value assignment to variable.
        `(let ,plc ,val
		   ,@(sub alst))))))

; XXX tests missing
