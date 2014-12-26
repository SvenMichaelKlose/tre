; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defmacro defbuiltin (name args &body body)
  (push name *cl-builtins*)
  `(defun ,name ,args ,@body))
