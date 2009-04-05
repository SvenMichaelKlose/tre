;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro define-getset-alias (alias real &key (class nil))
  (let definer (if class
				   `(defmethod ,class)
				   '(defun))
    `(progn
       (,@definer ,($ 'get- alias) ()
         ,real)
       (,@definer ,($ 'set- alias) (x)
         (setf ,real x)))))
