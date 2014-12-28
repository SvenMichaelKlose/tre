; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defmacro defbuiltin (name args &body body)
  (print-definition `(defbuiltin ,name ,args))
  (push name *cl-builtins*)
  `(defun ,name ,args ,@body))
