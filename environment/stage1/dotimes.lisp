(defmacro dotimes ((iter times &rest result) &body body)
  (let g (gensym)
    `(let ,g (integer ,times)
       ,@(? *assert?*
            `((? (< ,g 0)
                 (error "DOTIMES: Number of iterations is negative: ~A." ,g))))
       (do ((,iter 0 (number+ 1 ,iter)))
           ((== ,iter ,g) ,@result)
         ,@body))))

(defmacro repeat (n &body body)
  `(dotimes (,(gensym) ,n)
     ,@body))
