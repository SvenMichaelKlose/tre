(defmacro let-when (x expr &body body)
  `(let ,x ,expr
     (when ,x
       ,@body)))
