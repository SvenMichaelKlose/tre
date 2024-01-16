(defmacro define-tree-filter (name args &body body)
  (let iter (car (last args))
    `(fn ,name ,args
       (?
         ,@body
         (atom ,iter) ,iter
         (. (,name ,@(butlast args) (car ,iter))
            (,name ,@(butlast args) (cdr ,iter)))))))
