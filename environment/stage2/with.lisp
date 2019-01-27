(fn copy-while (pred x)
  (& x
     (funcall pred x.)
     (. x. (copy-while pred .x))))

(define-test "COPY-WHILE"
  ((copy-while #'number? '(1 2 3 a)))
  '(1 2 3))

(fn separate (pred x)
  (values (copy-while pred x)
		  (remove-if pred x)))

(defmacro with (lst &body body)
  (| lst  (error "Pair(s) of variable names and initializers expected."))
  (| body (error "Body expected."))
  (labels ((sub (x)
             (? x
                `((with ,x ,@body))
                body)))
    (let* ((alst (macroexpand lst))
           (plc alst.)
           (val .alst.))
      (?
	    (cons? plc) `(multiple-value-bind ,plc ,val
		               ,@(sub ..alst))

	    ; Accumulate this and all following functions into a LABEL,
        ; so they can call each other.
		(lambda? val) (multiple-value-bind (funs others) (separate [lambda? ._.] (group alst 2))
		                `(labels ,(@ [`(,_. ,@(past-lambda ._.))] funs)
			               ,@(sub (apply #'append others))))

        `(let ,plc ,val
		   ,@(sub ..alst))))))
