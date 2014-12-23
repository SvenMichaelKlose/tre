; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(define-cl-st-macro %set-atom-fun (x v)
  `(cl:setf (cl:symbol-function ',x) ,v))

(define-cl-st-macro %defun (name args &body body)
  `(progn
     (print `(%defun ,name ,args))
     (cl:push (. name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)
     (cl:setf (cl:gethash #',name *function-atom-sources*) ',(. args body))))

(define-cl-st-macro %define-cl-st-macro (name args &body body)
  (print `(%define-cl-st-macro ,name ,args))
  `(cl:push (. ',name
               (. ',args
                  #'(lambda ,(argument-expand-names '%define-cl-st-macro args)
                      ,@body)))
            *macros*))

(define-cl-st-macro %defvar (name &optional (init nil))
  (print `(%defvar ,name))
  `(progn
     (cl:push (. ',name ',init) *variables*)
     (cl:defvar ,name ,init)))
