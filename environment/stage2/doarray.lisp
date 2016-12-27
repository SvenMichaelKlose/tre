(defmacro doarray ((v seq &rest result) &body body)
  (with-gensym (evald-seq idx)
    `(let ,evald-seq ,seq
       (when ,evald-seq
         (dotimes (,idx (length ,evald-seq) ,@result)
           (let ,v (aref ,evald-seq ,idx)
             ,@body))))))
