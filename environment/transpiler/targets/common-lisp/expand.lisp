; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-cl-std-macro (name args &body body)
  `(define-transpiler-std-macro *cl-transpiler* ,name ,args ,@body))

(define-cl-std-macro %set-atom-fun (x v)
  `(cl:setf (cl:symbol-function ',x) ,v))

(define-cl-std-macro %defun (name args &body body)
  (transpiler-add-defined-function *transpiler* name args body)
  `(progn
     (push (. name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)
     (cl:setf (cl:gethash #',name *function-atom-sources*) ',(. args body))))

(define-cl-std-macro %defmacro (name args &body body)
  `(cl:push (. ',name
               (. ',args
                  #'(lambda ,(argument-expand-names 'define-cl-std-macro args)
                      ,@body)))
            *macros*))

(define-cl-std-macro %defvar (name &optional (init nil))
  (transpiler-add-defined-variable *transpiler* name)
  `(progn
     (push (. ',name ',init) *variables*)
     (cl:defvar ,name ,init)))
