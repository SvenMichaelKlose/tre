; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defspecial %defun-quiet (name args &body body)
  `(cl:progn
     (cl:push (. name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)
     (cl:setf (cl:gethash #',name *function-atom-sources*) ',(. args body))))

(defspecial %defun (name args &body body)
  (print-definition `(%defun ,name ,args))
  `(%defun-quiet ,name ,args ,@body))

(defspecial %defmacro (name args &body body)
  (print-definition `(%defmacro ,name ,args))
  `(cl:push (. ',name
               (. ',args
                  #'(cl:lambda ,(argument-expand-names '%defmacro args)
                      ,@body)))
            *macros*))

(defspecial %defvar (name &optional (init nil))
  (print-definition `(%defvar ,name))
  `(cl:defvar ,name ,init))
