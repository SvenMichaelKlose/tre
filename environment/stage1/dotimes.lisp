; tré – Copyright (c) 2005–2008,2010–2012,2015–2016 Sven Michael Klose <pixel@copei.de>

(defun dotimes-error-negative (x)
  (error "DOTIMES: Number of iterations is negative. It's ~A." x))

(defmacro dotimes ((iter times &rest result) &body body)
  (let g (gensym)
    `(let ,g ,times
       ,@(? *assert?*
            `((? (integer< ,g 0)
                 (dotimes-error-negative ,g))))
       (do ((,iter 0 (integer+ 1 ,iter)))
	       ((integer== ,iter ,g) ,@result)
	     ,@body))))
