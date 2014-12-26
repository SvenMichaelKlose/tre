; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-cl-std-macro (name args &body body)
  `(define-transpiler-std-macro *cl-transpiler* ,name ,args ,@body))

(define-cl-std-macro %set-atom-fun (x v)
  `(cl:setf (cl:symbol-function ',x) ,v))

(define-cl-std-macro %defun (name args &body body)
  (print-definition `(%defun ,name ,args))
  (add-defined-function name args body)
  `(progn
     ,@(& (save-sources?)
          `((push (. name ',(. args (& (not (save-argdefs-only?))
                                       body)))
                  *functions*)))
     (cl:defun ,name ,args ,@body)
     ,@(& (save-sources?)
          `(cl:setf (cl:gethash #',name *function-atom-sources*)
                    ',(. args (& (not (save-argdefs-only?))
                                 body))))))

(define-cl-std-macro defun (&rest x) `(%defun ,@x))

(define-cl-std-macro %defmacro (name args &body body)
  (print-definition `(%defmacro ,name ,args))
  `(cl:push (. ',name
               (. ',args
                  #'(lambda ,(argument-expand-names 'define-cl-std-macro args)
                      ,@body)))
            *macros*))

(define-cl-std-macro %defvar (name &optional (init nil))
  (print-definition `(%defvar ,name))
  (add-defined-variable name)
  `(progn
     ,@(& (save-sources?)
          `((push (. ',name ',init) *variables*)))
     (cl:defvar ,name ,init)))
