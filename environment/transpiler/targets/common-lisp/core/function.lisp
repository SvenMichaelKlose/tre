;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *functions* nil)
(push '*functions* *universe*)

(defun function-native (x) x)

(defmacro %set-atom-fun (x v) `(setf (symbol-function ',x) ,v))

(defmacro %defun-quiet (name args &body body)
  `(progn
     (cl:push (. name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)
     (cl:setf (cl:gethash #',name *function-atom-sources*) ',(. args body))))

(defmacro %defun (name args &body body)
  (print `(%defun ,name ,args))
  `(%defun-quiet ,name ,args ,@body))

(defvar *function-atom-sources* (make-hash-table :test #'eq))

(defun function-source (x)
  (| (cl:functionp x)
     (cl:error "Not a function."))
  (cl:gethash x *function-atom-sources*))

(defun =-function-source (v x)
  (cl:setf (cl:gethash x *function-atom-sources*) v))

(defun function-bytecode (x) x nil)
