(defmacro pcase (x &body body)
  (with-gensym g
   `(let ,g ,x
      (?
        ,@(+@ [? ._
                 `((,_. ,g) ,@._)
                 _]
              (group body 2))))))
