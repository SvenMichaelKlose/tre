(defmacro define-tree-filter (name args &body body)
  (let iter (car (last args))
    `(fn ,name ,args
       (?
         ,@body
         (atom ,iter) ,iter
         (. (,name ,@(butlast args) (car ,iter))
            (,name ,@(butlast args) (cdr ,iter)))))))

(defmacro define-tree-filter2 (name args &body body)
  (let expargs (argument-expand-names name .args)
    `(fn ,name ,args
       (?
         ,@body
         (atom ,args.) ,args.
         (. (,name (car ,args.) ,@expargs)
            (,name (cdr ,args.) ,@expargs))))))
