;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *functions* nil)
(push '*functions* *universe*)

(defun function-native (x) x)

(defmacro %set-atom-fun (x v) `(setf (symbol-function ',x) ,v))

(defmacro %defun-quiet (name args &body body)
  (push (cons name (cons args body)) *functions*)
  `(progn
     (defun ,name ,args ,@body)
     (setf (gethash #',name *function-atom-sources*) ',(cons args body))))

(defmacro %defun (name args &body body)
  (print `(%defun ,name ,args))
  `(%defun-quiet ,name ,args ,@body))

(%defmacro %defun-quiet (name args &body body)
  (push (cons name (cons args body)) *functions*)
  `(progn
     (defun ,name ,args ,@body)
     (setf (gethash #',name *function-atom-sources*) ',(cons args body))))

(%defmacro %defun (name args &body body)
  (print `(%defun ,name ,args))
  `(%defun-quiet ,name ,args ,@body))

(defvar *function-atom-sources* (make-hash-table :test #'eq))

(defun function-source (x)
  (or (functionp x)
      (error "Not a function."))
  (gethash x *function-atom-sources*))

(defun =-function-source (v x) (setf (gethash x *function-atom-sources*) v))

(defun function-bytecode (x) x nil)
