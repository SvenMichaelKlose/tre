; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-cl-std-macro (name args &body body)
  `(define-transpiler-std-macro *cl-transpiler* ,name ,args ,@body))

(define-cl-std-macro %set-atom-fun (x v)
  `(cl:setf (cl:symbol-function ',x) ,v))

(define-cl-std-macro %defun (name args &body body)
  `(progn
     (print `(%defun ,name ,args))
     (cl:push (. name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)
     (cl:setf (cl:gethash #',name *function-atom-sources*) ',(. args body))))

(define-cl-std-macro %define-cl-st-macro (name args &body body)
  (print `(%define-cl-std-macro ,name ,args))
  `(cl:push (. ',name
               (. ',args
                  #'(lambda ,(argument-expand-names 'define-cl-std-macro args)
                      ,@body)))
            *macros*))

(define-cl-std-macro %defvar (name &optional (init nil))
  (print `(%defvar ,name))
  `(progn
     (cl:push (. ',name ',init) *variables*)
     (cl:defvar ,name ,init)))
