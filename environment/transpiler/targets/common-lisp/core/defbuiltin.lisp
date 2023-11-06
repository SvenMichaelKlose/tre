(CL:DEFVAR *builtin-atoms* (CL:MAKE-HASH-TABLE :TEST #'CL:EQ))

(defmacro defbuiltin (name args &body body)
  (print-definition `(defbuiltin ,name ,args))
  (push name *cl-builtins*)
  `(progn
     (fn ,name ,args ,@body)
     (CL:SETF (CL:GETHASH ',name *builtin-atoms*) #',name)))

(defbuiltin builtin? (x)
  (| (CL:GETHASH x *builtin-atoms*)
     (CL:MEMBER x +cl-function-imports+)))
