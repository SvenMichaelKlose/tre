(defmacro doarray ((v seq &rest result) &body body)
  (with-gensym (! idx)
    `(let-when ,! ,seq
       (dotimes (,idx (length ,!) ,@result)
         (let ,v (aref ,! ,idx)
           ,@body)))))
