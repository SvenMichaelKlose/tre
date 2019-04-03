(define-js-macro tre_cons (x y)
  `("new " ,(compiled-function-name '%cons) "(" ,x "," ,y ")"))

{,@(@ [`{(define-js-macro ,_. (x)
           `(%%native ,,(js-nil? x) " ? null : " ,,x "." ,._.))
         (define-js-macro ,._. (v x)
           `(%%native ,,x "." ,._. " = " ,,v))}]
      '((tre_car _)
        (tre_cdr __)))}
