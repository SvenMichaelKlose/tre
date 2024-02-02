(defmacro define-tree-filter (name args &body body)
  (let expargs (argument-expand-names name .args)
    `(fn ,name ,args
       (?
         ,@body
         (atom ,args.) ,args.
         (. (,name (car ,args.) ,@expargs)
            (,name (cdr ,args.) ,@expargs))))))
