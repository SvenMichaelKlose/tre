; tré – Copyright (c) 2011–2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro doarray ((var seq &rest result) &body body)
  (with-gensym (evald-seq idx)
    `(let ,evald-seq ,seq
       (when ,evald-seq
         (dotimes (,idx (length ,evald-seq) ,@result)
           (let ,var (aref ,evald-seq ,idx)
             ,@body))))))
