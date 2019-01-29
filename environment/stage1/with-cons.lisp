(defmacro with-cons (a d c &body body)
  `(when ,c
     (with (,a (car ,c)
            ,d (cdr ,c))
       ,@body)))
