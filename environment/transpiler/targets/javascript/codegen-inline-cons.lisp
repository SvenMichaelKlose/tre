(def-js-codegen tre_cons (x y)
  `("new " ,(compiled-function-name '%cons) "(" ,x "," ,y ")"))

(progn
  ,@(@ [`(progn
           (def-js-codegen ,_. (x)
             `(%%native ,,(js-nil? x) " ? null : " ,,x "." ,._.))
           (def-js-codegen ,._. (v x)
             `(%%native ,,x "." ,._. " = " ,,v)))]
       '((tre_car _)
         (tre_cdr __))))
