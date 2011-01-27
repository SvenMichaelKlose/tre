;;;;; TRE environment
;;;;; Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>

(defun copy-while (pred x)
  (when (and x (funcall pred (car x)))
	(cons (car x)
		  (copy-while pred (cdr x)))))

(define-test "COPY-WHILE"
  ((copy-while #'number? '(1 2 3 a)))
  '(1 2 3))

(defun collect (pred x)
  (values (copy-while pred x)
		  (remove-if pred x)))

(defmacro with (alst &rest body)
  (unless body
	(error "body expected"))
  ; Make new WITH for rest of assignment list.
  (labels ((sub (x)
             (? (cddr x)
                `((with ,(cddr x)
					,@body))
                body)))

	; Get first pair.
    (let* ((plc (first alst))
           (val (second alst)))
      (?
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
