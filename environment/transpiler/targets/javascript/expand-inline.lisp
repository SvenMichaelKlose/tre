;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-js-std-macro eq (&rest x)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))

(define-js-std-macro make-string (&optional len)
  "")
