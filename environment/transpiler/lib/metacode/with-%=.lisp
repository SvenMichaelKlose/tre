(defmacro with-%= (place value x &body body)
  (with-gensym g
    `(with (,g      ,x
            ,place  (cadr ,g)
            ,value  (caddr ,g))
       ,@body)))
