(defun dotimes-error-negative (x)
  (error "DOTIMES: Number of iterations is negative. It's ~A." x))

(defmacro dotimes ((iter times &rest result) &body body)
  (let g (gensym)
    `(let ,g (integer ,times)
       ,@(? *assert?*
            `((? (< ,g 0)
                 (dotimes-error-negative ,g))))
       (do ((,iter 0 (number+ 1 ,iter)))
	       ((== ,iter ,g) ,@result)
	     ,@body))))
