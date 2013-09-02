;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-js-std-macro eq (&rest x)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))

(define-js-std-macro funcall (fun &rest args)
  (with-gensym (f e a)
    `(with (,f ,fun
            ,e (slot-value ,f 'tre-exp))
       (? ,e
          (let ,a (list ,@args)
            ((slot-value ,e 'apply) nil (%%native "[" ,a "]")))
          (,f ,@args)))))

(define-js-std-macro make-string (&optional len)
  "")
