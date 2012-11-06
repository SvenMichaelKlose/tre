;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun copy-while (pred x)
  (& x (funcall pred (car x))
     (cons (car x) (copy-while pred (cdr x)))))

(define-test "COPY-WHILE"
  ((copy-while #'number? '(1 2 3 a)))
  '(1 2 3))

(defun separate (pred x)
  (values (copy-while pred x)
		  (remove-if pred x)))

(defmacro with (alst &body body)
  (unless body
	(error "body expected"))
  (labels ((sub (x)
             (? x
                `((with ,x
					,@body))
                body)))
    (let* ((plc (car alst))
           (val (cadr alst)))
      (?
	    (cons? plc) `(multiple-value-bind ,plc ,val
		               ,@(sub (cddr alst)))

	    ; Accumulate this and all following functions into a LABEL,
        ; so they can call each other.
		(lambda? val) (multiple-value-bind (funs others) (separate [lambda? (cadr _)] (group alst 2))
		                `(labels ,(mapcar ^(,(car _) ,@(past-lambda (cadr _))) funs)
			               ,@(sub (apply #'append others))))

        `(let ,plc ,val
		   ,@(sub (cddr alst)))))))

; XXX tests missing
