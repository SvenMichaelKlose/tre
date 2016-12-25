(cl:defvar *builtin-atoms* (cl:make-hash-table :test #'cl:eq))

(defmacro defbuiltin (name args &body body)
  (print-definition `(defbuiltin ,name ,args))
  (push name *cl-builtins*)
  `(progn
     (defun ,name ,args ,@body)
     (cl:setf (cl:gethash ',name *builtin-atoms*) #',name)))

(defbuiltin builtin? (x)
  (| (cl:gethash x *builtin-atoms*)
     (cl:member x +cl-function-imports+)))
