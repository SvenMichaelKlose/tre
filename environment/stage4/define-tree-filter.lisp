(defmacro define-tree-filter (name args &body body)
  (!= (argument-expand-names name .args)
    `(fn ,name ,args
       (?
         ,@body
         (atom ,args.) ,args.
         (. (,name (car ,args.) ,@!)
            (,name (cdr ,args.) ,@!))))))
