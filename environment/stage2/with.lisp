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
        (cons? plc)
          `(multiple-value-bind ,plc ,val
             ,@(sub ..alst))

        ; Accumulate this and all following functions into a LABEL,
        ; so they can call each other.
        ; TODO: A miracle this works. Try to keep the order. (pixel)
        (unnamed-lambda? val)
           (let* ((items   (group alst 2))
                  (funs    (remove-if-not [unnamed-lambda? ._.] items))
                  (others  (remove-if [unnamed-lambda? ._.] items)))
             `(labels ,(@ [`(,_. ,@(past-lambda ._.))] funs)
                ,@(sub (*> #'append others))))

        `(let ,plc ,val
           ,@(sub ..alst))))))
