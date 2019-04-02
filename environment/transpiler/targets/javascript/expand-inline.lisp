(define-js-std-macro eq (&rest x)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))
